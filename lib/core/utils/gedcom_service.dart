import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import '../../data/models/member_model.dart';
import '../../data/models/relationship_model.dart';
import '../../data/models/enums.dart';

/// Экспорт семейного дерева в формате GEDCOM 5.5.1
class GedcomService {
  static String _gedcomDate(DateTime? date) {
    if (date == null) return '';
    const months = [
      'JAN',
      'FEB',
      'MAR',
      'APR',
      'MAY',
      'JUN',
      'JUL',
      'AUG',
      'SEP',
      'OCT',
      'NOV',
      'DEC'
    ];
    return '${date.day} ${months[date.month - 1]} ${date.year}';
  }

  /// Строит строку GEDCOM из списка участников и связей
  static String buildGedcom(
    List<MemberModel> members,
    List<RelationshipModel> relationships,
  ) {
    final buf = StringBuffer();

    // Header
    buf.writeln('0 HEAD');
    buf.writeln('1 SOUR Eldertree');
    buf.writeln('2 VERS 1.0');
    buf.writeln('1 GEDC');
    buf.writeln('2 VERS 5.5.1');
    buf.writeln('1 CHAR UTF-8');
    buf.writeln('1 DATE ${_gedcomDate(DateTime.now())}');

    // Individuals
    for (final m in members) {
      buf.writeln('0 @I${m.id}@ INDI');
      buf.writeln('1 NAME ${m.firstName} /${m.lastName ?? ''}/');
      if (m.firstName.isNotEmpty) buf.writeln('2 GIVN ${m.firstName}');
      if ((m.lastName ?? '').isNotEmpty) buf.writeln('2 SURN ${m.lastName}');

      // Gender
      final genderTag = m.gender == Gender.female ? 'F' : 'M';
      buf.writeln('1 SEX $genderTag');

      // Birth date
      if (m.birthDate != null) {
        buf.writeln('1 BIRT');
        buf.writeln('2 DATE ${_gedcomDate(m.birthDate)}');
      }

      // Death date
      if (m.deathDate != null) {
        buf.writeln('1 DEAT Y');
        buf.writeln('2 DATE ${_gedcomDate(m.deathDate)}');
      }
    }

    // Family groups from spouse relationships
    int famIndex = 0;
    for (final rel in relationships) {
      if (rel.relationshipType == RelationshipType.spouse) {
        final famId = 'F${famIndex++}';
        buf.writeln('0 @$famId@ FAM');
        buf.writeln('1 HUSB @I${rel.member1Id}@');
        buf.writeln('1 WIFE @I${rel.member2Id}@');
      }
    }

    // Trailer
    buf.writeln('0 TRLR');
    return buf.toString();
  }

  /// Экспортирует GEDCOM-файл и открывает системный диалог отправки
  static Future<void> exportAndShare(
    List<MemberModel> members,
    List<RelationshipModel> relationships,
    String treeName,
  ) async {
    final gedcom = buildGedcom(members, relationships);
    final dir = await getTemporaryDirectory();
    final sanitized = treeName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final file = File('${dir.path}/$sanitized.ged');
    await file.writeAsString(gedcom);
    await Share.shareXFiles(
      [XFile(file.path)],
      subject: 'Family Tree: $treeName (.ged)',
    );
  }
}

import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class ExportService {
  static Future<void> exportJsonToDevice(
      Map<String, dynamic> data, String treeName) async {
    final String jsonString = const JsonEncoder.withIndent('  ').convert(data);

    final Directory tempDir = await getTemporaryDirectory();
    final String sanitizedName =
        treeName.replaceAll(RegExp(r'[^a-zA-Z0-9_\-]'), '_');
    final String filePath = '${tempDir.path}/${sanitizedName}_backup.json';

    final File file = File(filePath);
    await file.writeAsString(jsonString);

    await Share.shareXFiles(
      [XFile(filePath)],
      subject: 'Family Tree Backup: $treeName',
    );
  }
}

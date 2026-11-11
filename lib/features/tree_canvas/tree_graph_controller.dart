import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/supabase_providers.dart';
import 'config/tree_config.dart';
import '../../core/utils/notification_service.dart';
import '../../data/models/member_model.dart';
import '../../data/models/relationship_model.dart';
import '../../data/models/enums.dart';
import '../tree_list/current_tree_controller.dart';

part 'tree_graph_controller.g.dart';

class TreeGraphState {
  final List<MemberModel> members;
  final List<RelationshipModel> relationships;
  TreeGraphState(this.members, this.relationships);
}

@riverpod
class TreeGraphController extends _$TreeGraphController {
  static final List<MemberModel> _demoMembers = [
    MemberModel(
      id: 'demo-m1',
      treeId: 'demo-tree-1',
      firstName: 'Иван',
      lastName: 'Иванов',
      gender: Gender.male,
      birthDate: DateTime(1955, 5, 12),
      createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'demo-m2',
      treeId: 'demo-tree-1',
      firstName: 'Анна',
      lastName: 'Иванова',
      gender: Gender.female,
      birthDate: DateTime(1958, 8, 23),
      createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'demo-m3',
      treeId: 'demo-tree-1',
      firstName: 'Сергей',
      lastName: 'Иванов',
      gender: Gender.male,
      birthDate: DateTime(1982, 3, 15),
      createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'demo-m4',
      treeId: 'demo-tree-1',
      firstName: 'Елена',
      lastName: 'Иванова',
      gender: Gender.female,
      birthDate: DateTime(1985, 11, 4),
      createdAt: DateTime.now(),
    ),
    MemberModel(
      id: 'demo-m5',
      treeId: 'demo-tree-1',
      firstName: 'Михаил',
      lastName: 'Иванов',
      gender: Gender.male,
      birthDate: DateTime(2010, 7, 19),
      createdAt: DateTime.now(),
    ),
  ];

  static final List<RelationshipModel> _demoRelationships = [
    RelationshipModel(
      id: 'demo-r1',
      member1Id: 'demo-m1',
      member2Id: 'demo-m2',
      relationshipType: RelationshipType.spouse,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    RelationshipModel(
      id: 'demo-r2',
      member1Id: 'demo-m1',
      member2Id: 'demo-m3',
      relationshipType: RelationshipType.parent,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    RelationshipModel(
      id: 'demo-r3',
      member1Id: 'demo-m3',
      member2Id: 'demo-m4',
      relationshipType: RelationshipType.spouse,
      isActive: true,
      createdAt: DateTime.now(),
    ),
    RelationshipModel(
      id: 'demo-r4',
      member1Id: 'demo-m3',
      member2Id: 'demo-m5',
      relationshipType: RelationshipType.parent,
      isActive: true,
      createdAt: DateTime.now(),
    ),
  ];

  @override
  FutureOr<TreeGraphState> build() async {
    final currentTree = ref.watch(currentTreeControllerProvider);
    if (currentTree == null) return TreeGraphState([], []);

    final client = ref.watch(supabaseProvider);
    final user = client.auth.currentUser;

    if (user == null || currentTree.id.startsWith('demo-tree')) {
      // Режим тестирования: возвращаем локальных персон и связи строго для выбранного древа
      final members = _demoMembers
          .where((m) => m.treeId == currentTree.id)
          .take(maxTreeNodeCount)
          .toList();
      final memberIds = members.map((m) => m.id).toSet();
      final relationships = _demoRelationships
          .where((r) => memberIds.contains(r.member1Id) && memberIds.contains(r.member2Id))
          .toList();

      return TreeGraphState(members, relationships);
    }

    try {
      final membersRes =
          await client.from('members').select().eq('tree_id', currentTree.id);
      final members = membersRes
          .map((j) => MemberModel.fromJson(j))
          .take(maxTreeNodeCount)
          .toList();

      List<RelationshipModel> relationships = [];
      if (members.isNotEmpty) {
        final relsRes = await client
            .from('relationships')
            .select()
            .inFilter('member1_id', members.map((m) => m.id).toList());
        relationships =
            relsRes.map((j) => RelationshipModel.fromJson(j)).toList();
      }

      final notifService = ref.read(notificationServiceProvider);
      for (var m in members) {
        notifService.scheduleBirthdayNotification(m);
      }

      return TreeGraphState(members, relationships);
    } catch (_) {
      return TreeGraphState([], []);
    }
  }

  Future<void> addRelative({
    required String targetMemberId,
    required String firstName,
    String? lastName,
    DateTime? birthDate,
    DateTime? deathDate,
    required Gender gender,
    required String relationType,
  }) async {
    final currentTree = ref.watch(currentTreeControllerProvider);
    if (currentTree == null) return;

    final client = ref.watch(supabaseProvider);
    final user = client.auth.currentUser;

    if (user == null || currentTree.id.startsWith('demo-tree')) {
      final newMember = MemberModel(
        id: 'demo-m-${DateTime.now().millisecondsSinceEpoch}',
        treeId: currentTree.id,
        firstName: firstName,
        lastName: lastName,
        birthDate: birthDate,
        deathDate: deathDate,
        gender: gender,
        createdAt: DateTime.now(),
      );
      _demoMembers.add(newMember);

      if (relationType != 'self' && targetMemberId.isNotEmpty) {
        RelationshipModel rel;
        if (relationType == 'parent') {
          rel = RelationshipModel(
            id: 'demo-r-${DateTime.now().millisecondsSinceEpoch}',
            member1Id: newMember.id,
            member2Id: targetMemberId,
            relationshipType: RelationshipType.parent,
            isActive: true,
            createdAt: DateTime.now(),
          );
        } else if (relationType == 'child') {
          rel = RelationshipModel(
            id: 'demo-r-${DateTime.now().millisecondsSinceEpoch}',
            member1Id: targetMemberId,
            member2Id: newMember.id,
            relationshipType: RelationshipType.parent,
            isActive: true,
            createdAt: DateTime.now(),
          );
        } else {
          rel = RelationshipModel(
            id: 'demo-r-${DateTime.now().millisecondsSinceEpoch}',
            member1Id: targetMemberId,
            member2Id: newMember.id,
            relationshipType: RelationshipType.spouse,
            isActive: true,
            createdAt: DateTime.now(),
          );
        }
        _demoRelationships.add(rel);
      }

      ref.invalidateSelf();
      return;
    }

    final newMemberRes = await client
        .from('members')
        .insert({
          'tree_id': currentTree.id,
          'first_name': firstName,
          'last_name': lastName,
          'birth_date': birthDate?.toIso8601String(),
          'death_date': deathDate?.toIso8601String(),
          'gender': gender.name,
        })
        .select()
        .single();

    final newMember = MemberModel.fromJson(newMemberRes);

    if (relationType != 'self' && targetMemberId.isNotEmpty) {
      Map<String, dynamic> relData;
      if (relationType == 'parent') {
        relData = {
          'member1_id': newMember.id,
          'member2_id': targetMemberId,
          'relationship_type': RelationshipType.parent.name,
        };
      } else if (relationType == 'child') {
        relData = {
          'member1_id': targetMemberId,
          'member2_id': newMember.id,
          'relationship_type': RelationshipType.parent.name,
        };
      } else {
        relData = {
          'member1_id': targetMemberId,
          'member2_id': newMember.id,
          'relationship_type': RelationshipType.spouse.name,
        };
      }
      await client.from('relationships').insert(relData);
    }

    ref.invalidateSelf();
  }
}

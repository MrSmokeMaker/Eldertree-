import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../core/config/supabase_providers.dart';
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
  @override
  FutureOr<TreeGraphState> build() async {
    final currentTree = ref.watch(currentTreeControllerProvider);
    if (currentTree == null) return TreeGraphState([], []);

    final client = ref.watch(supabaseProvider);

    final membersRes =
        await client.from('members').select().eq('tree_id', currentTree.id);
    final members = membersRes.map((j) => MemberModel.fromJson(j)).toList();

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
  }

  Future<void> addRelative({
    required String targetMemberId,
    required String firstName,
    required Gender gender,
    required String relationType,
  }) async {
    final currentTree = ref.watch(currentTreeControllerProvider);
    if (currentTree == null) return;

    final client = ref.watch(supabaseProvider);

    final newMemberRes = await client
        .from('members')
        .insert({
          'tree_id': currentTree.id,
          'first_name': firstName,
          'gender': gender.name,
        })
        .select()
        .single();

    final newMember = MemberModel.fromJson(newMemberRes);

    if (relationType != 'self') {
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

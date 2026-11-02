import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_providers.dart';
import '../../data/models/member_model.dart';
import '../../data/models/relationship_model.dart';

part 'member_repository.g.dart';

@riverpod
MemberRepository memberRepository(MemberRepositoryRef ref) {
  return MemberRepository(ref.watch(supabaseProvider));
}

class MemberRepository {
  final SupabaseClient _client;
  MemberRepository(this._client);

  Future<List<MemberModel>> getMembers(String treeId) async {
    final response =
        await _client.from('members').select().eq('tree_id', treeId);
    return (response as List)
        .map((json) => MemberModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<List<RelationshipModel>> getRelationships(String treeId) async {
    final response =
        await _client.from('relationships').select().eq('tree_id', treeId);
    return (response as List)
        .map((json) => RelationshipModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  Future<void> deleteMember(String memberId) async {
    final member = await _client
        .from('members')
        .select('avatar_url')
        .eq('id', memberId)
        .single();

    final avatarUrl = member['avatar_url'] as String?;
    if (avatarUrl != null && avatarUrl.isNotEmpty) {
      try {
        final path = avatarUrl.split('avatars/').last;
        await _client.storage.from('avatars').remove([path]);
      } catch (_) {}
    }

    await _client.from('members').delete().eq('id', memberId);
  }
}

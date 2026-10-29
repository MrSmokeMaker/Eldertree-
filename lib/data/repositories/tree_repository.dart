import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_providers.dart';
import '../models/tree_model.dart';

part 'tree_repository.g.dart';

@riverpod
TreeRepository treeRepository(TreeRepositoryRef ref) {
  return TreeRepository(ref.watch(supabaseProvider));
}

class TreeRepository {
  final SupabaseClient _client;
  TreeRepository(this._client);

  Future<List<TreeModel>> getTrees() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client.from('trees').select().eq('owner_id', userId).order('created_at');
    return response.map((json) => TreeModel.fromJson(json)).toList();
  }

  Future<TreeModel> createTree(String name) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final response = await _client.from('trees').insert({
      'owner_id': userId,
      'name': name,
    }).select().single();
    return TreeModel.fromJson(response);
  }

  Future<Map<String, dynamic>> getTreeExportData(String treeId) async {
    final tree = await _client.from('trees').select().eq('id', treeId).single();
    final members = await _client.from('members').select().eq('tree_id', treeId);
    final memberIds = members.map((m) => m['id'] as String).toList();
    
    List<dynamic> relationships = [];
    List<dynamic> facts = [];
    List<dynamic> events = [];

    if (memberIds.isNotEmpty) {
      relationships = await _client.from('relationships').select().inFilter('member1_id', memberIds);
      facts = await _client.from('facts').select().inFilter('member_id', memberIds);
      events = await _client.from('timeline_events').select().inFilter('member_id', memberIds);
    }

    return {
      'export_date': DateTime.now().toIso8601String(),
      'tree': tree,
      'members': members,
      'relationships': relationships,
      'facts': facts,
      'timeline_events': events,
    };
  }
}

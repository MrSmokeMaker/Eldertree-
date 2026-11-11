// Tree repository with caching, demo fallback and export support
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../core/config/supabase_providers.dart';
import '../../core/cache/cache_manager.dart';
import '../models/tree_model.dart';

part 'tree_repository.g.dart';

@riverpod
TreeRepository treeRepository(TreeRepositoryRef ref) {
  return TreeRepository(ref.watch(supabaseProvider));
}

class TreeRepository {
  final SupabaseClient _client;
  TreeRepository(this._client);

  static final List<TreeModel> _demoTrees = [
    TreeModel(
      id: 'demo-tree-1',
      ownerId: 'demo-user',
      name: 'Семейное древо (Тестовое)',
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
    ),
  ];

  // Fetch trees with cache fallback
  Future<List<TreeModel>> getTreesCached() async {
    final cached = CacheManager.getTrees();
    if (cached != null && cached.isNotEmpty) return cached;
    return getTrees();
  }

  // Direct fetch without cache (used by controller)
  Future<List<TreeModel>> getTrees() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      // Режим тестирования без авторизации
      return List.unmodifiable(_demoTrees);
    }
    try {
      final response = await _client
          .from('trees')
          .select()
          .eq('owner_id', userId)
          .order('created_at');
      final trees = response.map((json) => TreeModel.fromJson(json)).toList();
      CacheManager.putTrees(trees);
      return trees;
    } catch (_) {
      return List.unmodifiable(_demoTrees);
    }
  }

  // Create a new tree
  Future<TreeModel> createTree(String name) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      // Режим тестирования: создаем дерево локально в памяти
      final newTree = TreeModel(
        id: 'demo-tree-${DateTime.now().millisecondsSinceEpoch}',
        ownerId: 'demo-user',
        name: name,
        createdAt: DateTime.now(),
      );
      _demoTrees.add(newTree);
      return newTree;
    }
    final response = await _client
        .from('trees')
        .insert({
          'owner_id': userId,
          'name': name,
        })
        .select()
        .single();
    return TreeModel.fromJson(response);
  }

  // Export tree data
  Future<Map<String, dynamic>> getTreeExportData(String treeId) async {
    if (treeId.startsWith('demo-tree')) {
      final tree = _demoTrees.firstWhere(
        (t) => t.id == treeId,
        orElse: () => _demoTrees.first,
      );
      return {
        'export_date': DateTime.now().toIso8601String(),
        'tree': tree.toJson(),
        'members': [],
        'relationships': [],
        'facts': [],
        'timeline_events': [],
      };
    }

    final tree = await _client.from('trees').select().eq('id', treeId).single();
    final members =
        await _client.from('members').select().eq('tree_id', treeId);
    final memberIds = members.map((m) => m['id'] as String).toList();

    List<dynamic> relationships = [];
    List<dynamic> facts = [];
    List<dynamic> events = [];

    if (memberIds.isNotEmpty) {
      relationships = await _client
          .from('relationships')
          .select()
          .inFilter('member1_id', memberIds);
      facts =
          await _client.from('facts').select().inFilter('member_id', memberIds);
      events = await _client
          .from('timeline_events')
          .select()
          .inFilter('member_id', memberIds);
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

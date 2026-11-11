// Cache manager for tree data
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/tree_model.dart';

class CacheManager {
  static const _boxName = 'treeCache';
  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox(_boxName);
  }

  static Box<dynamic> get _box => Hive.box(_boxName);

  static void putTrees(List<TreeModel> trees) =>
      _box.put('trees', trees.map((e) => e.toJson()).toList());

  static List<TreeModel>? getTrees() {
    final data = _box.get('trees') as List<dynamic>?;
    return data
        ?.map((json) => TreeModel.fromJson(json as Map<String, dynamic>))
        .toList();
  }
}

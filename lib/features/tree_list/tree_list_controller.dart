import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/tree_model.dart';
import '../../data/repositories/tree_repository.dart';
import '../../features/tree_canvas/config/tree_config.dart';

part 'tree_list_controller.g.dart';

@riverpod
class TreeListController extends _$TreeListController {
  @override
  FutureOr<List<TreeModel>> build() async {
    final trees = await ref.watch(treeRepositoryProvider).getTrees();
    return trees.take(maxTreeNodeCount).toList();
  }

  Future<void> createTree(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(treeRepositoryProvider).createTree(name);
      final trees = await ref.read(treeRepositoryProvider).getTrees();
      return trees.take(maxTreeNodeCount).toList();
    });
  }
}

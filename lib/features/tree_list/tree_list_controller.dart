import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/tree_model.dart';
import '../../data/repositories/tree_repository.dart';

part 'tree_list_controller.g.dart';

@riverpod
class TreeListController extends _$TreeListController {
  @override
  FutureOr<List<TreeModel>> build() async {
    return ref.watch(treeRepositoryProvider).getTrees();
  }

  Future<void> createTree(String name) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await ref.read(treeRepositoryProvider).createTree(name);
      return ref.read(treeRepositoryProvider).getTrees();
    });
  }
}

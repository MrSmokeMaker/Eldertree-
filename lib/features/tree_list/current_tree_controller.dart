import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/models/tree_model.dart';

part 'current_tree_controller.g.dart';

@Riverpod(keepAlive: true)
class CurrentTreeController extends _$CurrentTreeController {
  @override
  TreeModel? build() {
    return null;
  }

  void setTree(TreeModel tree) {
    state = tree;
  }
}

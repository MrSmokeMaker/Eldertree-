import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'lens_controller.g.dart';

class LensState {
  final bool isActive;
  final int year;

  LensState({required this.isActive, required this.year});
}

@riverpod
class LensController extends _$LensController {
  @override
  LensState build() {
    return LensState(isActive: false, year: DateTime.now().year);
  }

  void toggle(bool active) {
    state = LensState(isActive: active, year: state.year);
  }

  void setYear(int year) {
    state = LensState(isActive: state.isActive, year: year);
  }
}

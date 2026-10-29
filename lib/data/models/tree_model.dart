import 'package:freezed_annotation/freezed_annotation.dart';

part 'tree_model.freezed.dart';
part 'tree_model.g.dart';

@freezed
class TreeModel with _$TreeModel {
  const factory TreeModel({
    required String id,
    @JsonKey(name: 'owner_id') required String ownerId,
    required String name,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TreeModel;

  factory TreeModel.fromJson(Map<String, dynamic> json) => _$TreeModelFromJson(json);
}

import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'member_model.freezed.dart';
part 'member_model.g.dart';

@freezed
class MemberModel with _$MemberModel {
  const factory MemberModel({
    required String id,
    @JsonKey(name: 'tree_id') required String treeId,
    @JsonKey(name: 'first_name') required String firstName,
    @JsonKey(name: 'last_name') String? lastName,
    required Gender gender,
    @JsonKey(name: 'birth_date') DateTime? birthDate,
    @JsonKey(name: 'death_date') DateTime? deathDate,
    @JsonKey(name: 'avatar_url') String? avatarUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _MemberModel;

  factory MemberModel.fromJson(Map<String, dynamic> json) =>
      _$MemberModelFromJson(json);
}

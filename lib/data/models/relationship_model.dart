import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'relationship_model.freezed.dart';
part 'relationship_model.g.dart';

@freezed
class RelationshipModel with _$RelationshipModel {
  const factory RelationshipModel({
    required String id,
    @JsonKey(name: 'member1_id') required String member1Id,
    @JsonKey(name: 'member2_id') required String member2Id,
    @JsonKey(name: 'relationship_type')
    required RelationshipType relationshipType,
    @JsonKey(name: 'is_active') @Default(true) bool isActive,
    @JsonKey(name: 'end_date') DateTime? endDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _RelationshipModel;

  factory RelationshipModel.fromJson(Map<String, dynamic> json) =>
      _$RelationshipModelFromJson(json);
}

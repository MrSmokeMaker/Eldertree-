import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'fact_model.freezed.dart';
part 'fact_model.g.dart';

@freezed
class FactModel with _$FactModel {
  const factory FactModel({
    required String id,
    @JsonKey(name: 'member_id') required String memberId,
    required FactCategory category,
    required String value,
    @JsonKey(name: 'fact_date') DateTime? factDate,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _FactModel;

  factory FactModel.fromJson(Map<String, dynamic> json) => _$FactModelFromJson(json);
}

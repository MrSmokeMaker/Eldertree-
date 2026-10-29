import 'package:freezed_annotation/freezed_annotation.dart';
import 'enums.dart';

part 'subscription_model.freezed.dart';
part 'subscription_model.g.dart';

@freezed
class SubscriptionModel with _$SubscriptionModel {
  const factory SubscriptionModel({
    required String id,
    @JsonKey(name: 'user_id') required String userId,
    @JsonKey(name: 'tier_level') @Default(TierLevel.free) TierLevel tierLevel,
    @JsonKey(name: 'expires_at') DateTime? expiresAt,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _SubscriptionModel;

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) => _$SubscriptionModelFromJson(json);
}

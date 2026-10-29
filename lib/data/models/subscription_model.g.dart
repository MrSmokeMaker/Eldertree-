// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subscription_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$SubscriptionModelImpl _$$SubscriptionModelImplFromJson(
        Map<String, dynamic> json) =>
    _$SubscriptionModelImpl(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tierLevel: $enumDecodeNullable(_$TierLevelEnumMap, json['tier_level']) ??
          TierLevel.free,
      expiresAt: json['expires_at'] == null
          ? null
          : DateTime.parse(json['expires_at'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$SubscriptionModelImplToJson(
        _$SubscriptionModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'user_id': instance.userId,
      'tier_level': _$TierLevelEnumMap[instance.tierLevel]!,
      'expires_at': instance.expiresAt?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$TierLevelEnumMap = {
  TierLevel.free: 'free',
  TierLevel.standard: 'standard',
  TierLevel.pro: 'pro',
};

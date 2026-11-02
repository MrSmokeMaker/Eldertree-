// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$MemberModelImpl _$$MemberModelImplFromJson(Map<String, dynamic> json) =>
    _$MemberModelImpl(
      id: json['id'] as String,
      treeId: json['tree_id'] as String,
      firstName: json['first_name'] as String,
      lastName: json['last_name'] as String?,
      gender: $enumDecode(_$GenderEnumMap, json['gender']),
      birthDate: json['birth_date'] == null
          ? null
          : DateTime.parse(json['birth_date'] as String),
      deathDate: json['death_date'] == null
          ? null
          : DateTime.parse(json['death_date'] as String),
      avatarUrl: json['avatar_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$MemberModelImplToJson(_$MemberModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tree_id': instance.treeId,
      'first_name': instance.firstName,
      'last_name': instance.lastName,
      'gender': _$GenderEnumMap[instance.gender]!,
      'birth_date': instance.birthDate?.toIso8601String(),
      'death_date': instance.deathDate?.toIso8601String(),
      'avatar_url': instance.avatarUrl,
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$GenderEnumMap = {
  Gender.male: 'male',
  Gender.female: 'female',
  Gender.other: 'other',
};

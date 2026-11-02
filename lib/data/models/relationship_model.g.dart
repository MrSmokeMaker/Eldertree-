// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'relationship_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RelationshipModelImpl _$$RelationshipModelImplFromJson(
        Map<String, dynamic> json) =>
    _$RelationshipModelImpl(
      id: json['id'] as String,
      member1Id: json['member1_id'] as String,
      member2Id: json['member2_id'] as String,
      relationshipType:
          $enumDecode(_$RelationshipTypeEnumMap, json['relationship_type']),
      isActive: json['is_active'] as bool? ?? true,
      endDate: json['end_date'] == null
          ? null
          : DateTime.parse(json['end_date'] as String),
      createdAt: DateTime.parse(json['created_at'] as String),
    );

Map<String, dynamic> _$$RelationshipModelImplToJson(
        _$RelationshipModelImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'member1_id': instance.member1Id,
      'member2_id': instance.member2Id,
      'relationship_type':
          _$RelationshipTypeEnumMap[instance.relationshipType]!,
      'is_active': instance.isActive,
      'end_date': instance.endDate?.toIso8601String(),
      'created_at': instance.createdAt.toIso8601String(),
    };

const _$RelationshipTypeEnumMap = {
  RelationshipType.parent: 'parent',
  RelationshipType.spouse: 'spouse',
};

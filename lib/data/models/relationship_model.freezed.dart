// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'relationship_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RelationshipModel _$RelationshipModelFromJson(Map<String, dynamic> json) {
  return _RelationshipModel.fromJson(json);
}

/// @nodoc
mixin _$RelationshipModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'member1_id')
  String get member1Id => throw _privateConstructorUsedError;
  @JsonKey(name: 'member2_id')
  String get member2Id => throw _privateConstructorUsedError;
  @JsonKey(name: 'relationship_type')
  RelationshipType get relationshipType => throw _privateConstructorUsedError;
  @JsonKey(name: 'is_active')
  bool get isActive => throw _privateConstructorUsedError;
  @JsonKey(name: 'end_date')
  DateTime? get endDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RelationshipModelCopyWith<RelationshipModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RelationshipModelCopyWith<$Res> {
  factory $RelationshipModelCopyWith(
          RelationshipModel value, $Res Function(RelationshipModel) then) =
      _$RelationshipModelCopyWithImpl<$Res, RelationshipModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'member1_id') String member1Id,
      @JsonKey(name: 'member2_id') String member2Id,
      @JsonKey(name: 'relationship_type') RelationshipType relationshipType,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'end_date') DateTime? endDate,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$RelationshipModelCopyWithImpl<$Res, $Val extends RelationshipModel>
    implements $RelationshipModelCopyWith<$Res> {
  _$RelationshipModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? member1Id = null,
    Object? member2Id = null,
    Object? relationshipType = null,
    Object? isActive = null,
    Object? endDate = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      member1Id: null == member1Id
          ? _value.member1Id
          : member1Id // ignore: cast_nullable_to_non_nullable
              as String,
      member2Id: null == member2Id
          ? _value.member2Id
          : member2Id // ignore: cast_nullable_to_non_nullable
              as String,
      relationshipType: null == relationshipType
          ? _value.relationshipType
          : relationshipType // ignore: cast_nullable_to_non_nullable
              as RelationshipType,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RelationshipModelImplCopyWith<$Res>
    implements $RelationshipModelCopyWith<$Res> {
  factory _$$RelationshipModelImplCopyWith(_$RelationshipModelImpl value,
          $Res Function(_$RelationshipModelImpl) then) =
      __$$RelationshipModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'member1_id') String member1Id,
      @JsonKey(name: 'member2_id') String member2Id,
      @JsonKey(name: 'relationship_type') RelationshipType relationshipType,
      @JsonKey(name: 'is_active') bool isActive,
      @JsonKey(name: 'end_date') DateTime? endDate,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$RelationshipModelImplCopyWithImpl<$Res>
    extends _$RelationshipModelCopyWithImpl<$Res, _$RelationshipModelImpl>
    implements _$$RelationshipModelImplCopyWith<$Res> {
  __$$RelationshipModelImplCopyWithImpl(_$RelationshipModelImpl _value,
      $Res Function(_$RelationshipModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? member1Id = null,
    Object? member2Id = null,
    Object? relationshipType = null,
    Object? isActive = null,
    Object? endDate = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$RelationshipModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      member1Id: null == member1Id
          ? _value.member1Id
          : member1Id // ignore: cast_nullable_to_non_nullable
              as String,
      member2Id: null == member2Id
          ? _value.member2Id
          : member2Id // ignore: cast_nullable_to_non_nullable
              as String,
      relationshipType: null == relationshipType
          ? _value.relationshipType
          : relationshipType // ignore: cast_nullable_to_non_nullable
              as RelationshipType,
      isActive: null == isActive
          ? _value.isActive
          : isActive // ignore: cast_nullable_to_non_nullable
              as bool,
      endDate: freezed == endDate
          ? _value.endDate
          : endDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RelationshipModelImpl implements _RelationshipModel {
  const _$RelationshipModelImpl(
      {required this.id,
      @JsonKey(name: 'member1_id') required this.member1Id,
      @JsonKey(name: 'member2_id') required this.member2Id,
      @JsonKey(name: 'relationship_type') required this.relationshipType,
      @JsonKey(name: 'is_active') this.isActive = true,
      @JsonKey(name: 'end_date') this.endDate,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$RelationshipModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$RelationshipModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'member1_id')
  final String member1Id;
  @override
  @JsonKey(name: 'member2_id')
  final String member2Id;
  @override
  @JsonKey(name: 'relationship_type')
  final RelationshipType relationshipType;
  @override
  @JsonKey(name: 'is_active')
  final bool isActive;
  @override
  @JsonKey(name: 'end_date')
  final DateTime? endDate;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'RelationshipModel(id: $id, member1Id: $member1Id, member2Id: $member2Id, relationshipType: $relationshipType, isActive: $isActive, endDate: $endDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RelationshipModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.member1Id, member1Id) ||
                other.member1Id == member1Id) &&
            (identical(other.member2Id, member2Id) ||
                other.member2Id == member2Id) &&
            (identical(other.relationshipType, relationshipType) ||
                other.relationshipType == relationshipType) &&
            (identical(other.isActive, isActive) ||
                other.isActive == isActive) &&
            (identical(other.endDate, endDate) || other.endDate == endDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, member1Id, member2Id,
      relationshipType, isActive, endDate, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RelationshipModelImplCopyWith<_$RelationshipModelImpl> get copyWith =>
      __$$RelationshipModelImplCopyWithImpl<_$RelationshipModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RelationshipModelImplToJson(
      this,
    );
  }
}

abstract class _RelationshipModel implements RelationshipModel {
  const factory _RelationshipModel(
          {required final String id,
          @JsonKey(name: 'member1_id') required final String member1Id,
          @JsonKey(name: 'member2_id') required final String member2Id,
          @JsonKey(name: 'relationship_type')
          required final RelationshipType relationshipType,
          @JsonKey(name: 'is_active') final bool isActive,
          @JsonKey(name: 'end_date') final DateTime? endDate,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$RelationshipModelImpl;

  factory _RelationshipModel.fromJson(Map<String, dynamic> json) =
      _$RelationshipModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'member1_id')
  String get member1Id;
  @override
  @JsonKey(name: 'member2_id')
  String get member2Id;
  @override
  @JsonKey(name: 'relationship_type')
  RelationshipType get relationshipType;
  @override
  @JsonKey(name: 'is_active')
  bool get isActive;
  @override
  @JsonKey(name: 'end_date')
  DateTime? get endDate;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$RelationshipModelImplCopyWith<_$RelationshipModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

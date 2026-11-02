// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'member_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

MemberModel _$MemberModelFromJson(Map<String, dynamic> json) {
  return _MemberModel.fromJson(json);
}

/// @nodoc
mixin _$MemberModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'tree_id')
  String get treeId => throw _privateConstructorUsedError;
  @JsonKey(name: 'first_name')
  String get firstName => throw _privateConstructorUsedError;
  @JsonKey(name: 'last_name')
  String? get lastName => throw _privateConstructorUsedError;
  Gender get gender => throw _privateConstructorUsedError;
  @JsonKey(name: 'birth_date')
  DateTime? get birthDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'death_date')
  DateTime? get deathDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $MemberModelCopyWith<MemberModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $MemberModelCopyWith<$Res> {
  factory $MemberModelCopyWith(
          MemberModel value, $Res Function(MemberModel) then) =
      _$MemberModelCopyWithImpl<$Res, MemberModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tree_id') String treeId,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String? lastName,
      Gender gender,
      @JsonKey(name: 'birth_date') DateTime? birthDate,
      @JsonKey(name: 'death_date') DateTime? deathDate,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$MemberModelCopyWithImpl<$Res, $Val extends MemberModel>
    implements $MemberModelCopyWith<$Res> {
  _$MemberModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? treeId = null,
    Object? firstName = null,
    Object? lastName = freezed,
    Object? gender = null,
    Object? birthDate = freezed,
    Object? deathDate = freezed,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      treeId: null == treeId
          ? _value.treeId
          : treeId // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deathDate: freezed == deathDate
          ? _value.deathDate
          : deathDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$MemberModelImplCopyWith<$Res>
    implements $MemberModelCopyWith<$Res> {
  factory _$$MemberModelImplCopyWith(
          _$MemberModelImpl value, $Res Function(_$MemberModelImpl) then) =
      __$$MemberModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'tree_id') String treeId,
      @JsonKey(name: 'first_name') String firstName,
      @JsonKey(name: 'last_name') String? lastName,
      Gender gender,
      @JsonKey(name: 'birth_date') DateTime? birthDate,
      @JsonKey(name: 'death_date') DateTime? deathDate,
      @JsonKey(name: 'avatar_url') String? avatarUrl,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$MemberModelImplCopyWithImpl<$Res>
    extends _$MemberModelCopyWithImpl<$Res, _$MemberModelImpl>
    implements _$$MemberModelImplCopyWith<$Res> {
  __$$MemberModelImplCopyWithImpl(
      _$MemberModelImpl _value, $Res Function(_$MemberModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? treeId = null,
    Object? firstName = null,
    Object? lastName = freezed,
    Object? gender = null,
    Object? birthDate = freezed,
    Object? deathDate = freezed,
    Object? avatarUrl = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$MemberModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      treeId: null == treeId
          ? _value.treeId
          : treeId // ignore: cast_nullable_to_non_nullable
              as String,
      firstName: null == firstName
          ? _value.firstName
          : firstName // ignore: cast_nullable_to_non_nullable
              as String,
      lastName: freezed == lastName
          ? _value.lastName
          : lastName // ignore: cast_nullable_to_non_nullable
              as String?,
      gender: null == gender
          ? _value.gender
          : gender // ignore: cast_nullable_to_non_nullable
              as Gender,
      birthDate: freezed == birthDate
          ? _value.birthDate
          : birthDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      deathDate: freezed == deathDate
          ? _value.deathDate
          : deathDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      avatarUrl: freezed == avatarUrl
          ? _value.avatarUrl
          : avatarUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$MemberModelImpl implements _MemberModel {
  const _$MemberModelImpl(
      {required this.id,
      @JsonKey(name: 'tree_id') required this.treeId,
      @JsonKey(name: 'first_name') required this.firstName,
      @JsonKey(name: 'last_name') this.lastName,
      required this.gender,
      @JsonKey(name: 'birth_date') this.birthDate,
      @JsonKey(name: 'death_date') this.deathDate,
      @JsonKey(name: 'avatar_url') this.avatarUrl,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$MemberModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$MemberModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'tree_id')
  final String treeId;
  @override
  @JsonKey(name: 'first_name')
  final String firstName;
  @override
  @JsonKey(name: 'last_name')
  final String? lastName;
  @override
  final Gender gender;
  @override
  @JsonKey(name: 'birth_date')
  final DateTime? birthDate;
  @override
  @JsonKey(name: 'death_date')
  final DateTime? deathDate;
  @override
  @JsonKey(name: 'avatar_url')
  final String? avatarUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'MemberModel(id: $id, treeId: $treeId, firstName: $firstName, lastName: $lastName, gender: $gender, birthDate: $birthDate, deathDate: $deathDate, avatarUrl: $avatarUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$MemberModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.treeId, treeId) || other.treeId == treeId) &&
            (identical(other.firstName, firstName) ||
                other.firstName == firstName) &&
            (identical(other.lastName, lastName) ||
                other.lastName == lastName) &&
            (identical(other.gender, gender) || other.gender == gender) &&
            (identical(other.birthDate, birthDate) ||
                other.birthDate == birthDate) &&
            (identical(other.deathDate, deathDate) ||
                other.deathDate == deathDate) &&
            (identical(other.avatarUrl, avatarUrl) ||
                other.avatarUrl == avatarUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, treeId, firstName, lastName,
      gender, birthDate, deathDate, avatarUrl, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$MemberModelImplCopyWith<_$MemberModelImpl> get copyWith =>
      __$$MemberModelImplCopyWithImpl<_$MemberModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$MemberModelImplToJson(
      this,
    );
  }
}

abstract class _MemberModel implements MemberModel {
  const factory _MemberModel(
          {required final String id,
          @JsonKey(name: 'tree_id') required final String treeId,
          @JsonKey(name: 'first_name') required final String firstName,
          @JsonKey(name: 'last_name') final String? lastName,
          required final Gender gender,
          @JsonKey(name: 'birth_date') final DateTime? birthDate,
          @JsonKey(name: 'death_date') final DateTime? deathDate,
          @JsonKey(name: 'avatar_url') final String? avatarUrl,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$MemberModelImpl;

  factory _MemberModel.fromJson(Map<String, dynamic> json) =
      _$MemberModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'tree_id')
  String get treeId;
  @override
  @JsonKey(name: 'first_name')
  String get firstName;
  @override
  @JsonKey(name: 'last_name')
  String? get lastName;
  @override
  Gender get gender;
  @override
  @JsonKey(name: 'birth_date')
  DateTime? get birthDate;
  @override
  @JsonKey(name: 'death_date')
  DateTime? get deathDate;
  @override
  @JsonKey(name: 'avatar_url')
  String? get avatarUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$MemberModelImplCopyWith<_$MemberModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

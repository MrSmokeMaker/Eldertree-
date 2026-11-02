// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'tree_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TreeModel _$TreeModelFromJson(Map<String, dynamic> json) {
  return _TreeModel.fromJson(json);
}

/// @nodoc
mixin _$TreeModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'owner_id')
  String get ownerId => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TreeModelCopyWith<TreeModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TreeModelCopyWith<$Res> {
  factory $TreeModelCopyWith(TreeModel value, $Res Function(TreeModel) then) =
      _$TreeModelCopyWithImpl<$Res, TreeModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'owner_id') String ownerId,
      String name,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$TreeModelCopyWithImpl<$Res, $Val extends TreeModel>
    implements $TreeModelCopyWith<$Res> {
  _$TreeModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TreeModelImplCopyWith<$Res>
    implements $TreeModelCopyWith<$Res> {
  factory _$$TreeModelImplCopyWith(
          _$TreeModelImpl value, $Res Function(_$TreeModelImpl) then) =
      __$$TreeModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'owner_id') String ownerId,
      String name,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$TreeModelImplCopyWithImpl<$Res>
    extends _$TreeModelCopyWithImpl<$Res, _$TreeModelImpl>
    implements _$$TreeModelImplCopyWith<$Res> {
  __$$TreeModelImplCopyWithImpl(
      _$TreeModelImpl _value, $Res Function(_$TreeModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? ownerId = null,
    Object? name = null,
    Object? createdAt = null,
  }) {
    return _then(_$TreeModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      ownerId: null == ownerId
          ? _value.ownerId
          : ownerId // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$TreeModelImpl implements _TreeModel {
  const _$TreeModelImpl(
      {required this.id,
      @JsonKey(name: 'owner_id') required this.ownerId,
      required this.name,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$TreeModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TreeModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'owner_id')
  final String ownerId;
  @override
  final String name;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'TreeModel(id: $id, ownerId: $ownerId, name: $name, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TreeModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.ownerId, ownerId) || other.ownerId == ownerId) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, ownerId, name, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TreeModelImplCopyWith<_$TreeModelImpl> get copyWith =>
      __$$TreeModelImplCopyWithImpl<_$TreeModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TreeModelImplToJson(
      this,
    );
  }
}

abstract class _TreeModel implements TreeModel {
  const factory _TreeModel(
          {required final String id,
          @JsonKey(name: 'owner_id') required final String ownerId,
          required final String name,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$TreeModelImpl;

  factory _TreeModel.fromJson(Map<String, dynamic> json) =
      _$TreeModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'owner_id')
  String get ownerId;
  @override
  String get name;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$TreeModelImplCopyWith<_$TreeModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

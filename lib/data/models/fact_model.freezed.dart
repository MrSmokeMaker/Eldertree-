// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'fact_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

FactModel _$FactModelFromJson(Map<String, dynamic> json) {
  return _FactModel.fromJson(json);
}

/// @nodoc
mixin _$FactModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_id')
  String get memberId => throw _privateConstructorUsedError;
  FactCategory get category => throw _privateConstructorUsedError;
  String get value => throw _privateConstructorUsedError;
  @JsonKey(name: 'fact_date')
  DateTime? get factDate => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $FactModelCopyWith<FactModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $FactModelCopyWith<$Res> {
  factory $FactModelCopyWith(FactModel value, $Res Function(FactModel) then) =
      _$FactModelCopyWithImpl<$Res, FactModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'member_id') String memberId,
      FactCategory category,
      String value,
      @JsonKey(name: 'fact_date') DateTime? factDate,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$FactModelCopyWithImpl<$Res, $Val extends FactModel>
    implements $FactModelCopyWith<$Res> {
  _$FactModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? category = null,
    Object? value = null,
    Object? factDate = freezed,
    Object? createdAt = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FactCategory,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      factDate: freezed == factDate
          ? _value.factDate
          : factDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$FactModelImplCopyWith<$Res>
    implements $FactModelCopyWith<$Res> {
  factory _$$FactModelImplCopyWith(
          _$FactModelImpl value, $Res Function(_$FactModelImpl) then) =
      __$$FactModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'member_id') String memberId,
      FactCategory category,
      String value,
      @JsonKey(name: 'fact_date') DateTime? factDate,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$FactModelImplCopyWithImpl<$Res>
    extends _$FactModelCopyWithImpl<$Res, _$FactModelImpl>
    implements _$$FactModelImplCopyWith<$Res> {
  __$$FactModelImplCopyWithImpl(
      _$FactModelImpl _value, $Res Function(_$FactModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? category = null,
    Object? value = null,
    Object? factDate = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$FactModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      category: null == category
          ? _value.category
          : category // ignore: cast_nullable_to_non_nullable
              as FactCategory,
      value: null == value
          ? _value.value
          : value // ignore: cast_nullable_to_non_nullable
              as String,
      factDate: freezed == factDate
          ? _value.factDate
          : factDate // ignore: cast_nullable_to_non_nullable
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
class _$FactModelImpl implements _FactModel {
  const _$FactModelImpl(
      {required this.id,
      @JsonKey(name: 'member_id') required this.memberId,
      required this.category,
      required this.value,
      @JsonKey(name: 'fact_date') this.factDate,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$FactModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$FactModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'member_id')
  final String memberId;
  @override
  final FactCategory category;
  @override
  final String value;
  @override
  @JsonKey(name: 'fact_date')
  final DateTime? factDate;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'FactModel(id: $id, memberId: $memberId, category: $category, value: $value, factDate: $factDate, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$FactModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.category, category) ||
                other.category == category) &&
            (identical(other.value, value) || other.value == value) &&
            (identical(other.factDate, factDate) ||
                other.factDate == factDate) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType, id, memberId, category, value, factDate, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$FactModelImplCopyWith<_$FactModelImpl> get copyWith =>
      __$$FactModelImplCopyWithImpl<_$FactModelImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$FactModelImplToJson(
      this,
    );
  }
}

abstract class _FactModel implements FactModel {
  const factory _FactModel(
          {required final String id,
          @JsonKey(name: 'member_id') required final String memberId,
          required final FactCategory category,
          required final String value,
          @JsonKey(name: 'fact_date') final DateTime? factDate,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$FactModelImpl;

  factory _FactModel.fromJson(Map<String, dynamic> json) =
      _$FactModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'member_id')
  String get memberId;
  @override
  FactCategory get category;
  @override
  String get value;
  @override
  @JsonKey(name: 'fact_date')
  DateTime? get factDate;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$FactModelImplCopyWith<_$FactModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

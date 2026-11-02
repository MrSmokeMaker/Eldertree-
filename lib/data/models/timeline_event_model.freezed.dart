// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'timeline_event_model.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

TimelineEventModel _$TimelineEventModelFromJson(Map<String, dynamic> json) {
  return _TimelineEventModel.fromJson(json);
}

/// @nodoc
mixin _$TimelineEventModel {
  String get id => throw _privateConstructorUsedError;
  @JsonKey(name: 'member_id')
  String get memberId => throw _privateConstructorUsedError;
  @JsonKey(name: 'event_date')
  DateTime? get eventDate => throw _privateConstructorUsedError;
  String get title => throw _privateConstructorUsedError;
  String? get description => throw _privateConstructorUsedError;
  @JsonKey(name: 'image_url')
  String? get imageUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'audio_url')
  String? get audioUrl => throw _privateConstructorUsedError;
  @JsonKey(name: 'created_at')
  DateTime get createdAt => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $TimelineEventModelCopyWith<TimelineEventModel> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimelineEventModelCopyWith<$Res> {
  factory $TimelineEventModelCopyWith(
          TimelineEventModel value, $Res Function(TimelineEventModel) then) =
      _$TimelineEventModelCopyWithImpl<$Res, TimelineEventModel>;
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'member_id') String memberId,
      @JsonKey(name: 'event_date') DateTime? eventDate,
      String title,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'audio_url') String? audioUrl,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class _$TimelineEventModelCopyWithImpl<$Res, $Val extends TimelineEventModel>
    implements $TimelineEventModelCopyWith<$Res> {
  _$TimelineEventModelCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? eventDate = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? audioUrl = freezed,
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
      eventDate: freezed == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      createdAt: null == createdAt
          ? _value.createdAt
          : createdAt // ignore: cast_nullable_to_non_nullable
              as DateTime,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$TimelineEventModelImplCopyWith<$Res>
    implements $TimelineEventModelCopyWith<$Res> {
  factory _$$TimelineEventModelImplCopyWith(_$TimelineEventModelImpl value,
          $Res Function(_$TimelineEventModelImpl) then) =
      __$$TimelineEventModelImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      @JsonKey(name: 'member_id') String memberId,
      @JsonKey(name: 'event_date') DateTime? eventDate,
      String title,
      String? description,
      @JsonKey(name: 'image_url') String? imageUrl,
      @JsonKey(name: 'audio_url') String? audioUrl,
      @JsonKey(name: 'created_at') DateTime createdAt});
}

/// @nodoc
class __$$TimelineEventModelImplCopyWithImpl<$Res>
    extends _$TimelineEventModelCopyWithImpl<$Res, _$TimelineEventModelImpl>
    implements _$$TimelineEventModelImplCopyWith<$Res> {
  __$$TimelineEventModelImplCopyWithImpl(_$TimelineEventModelImpl _value,
      $Res Function(_$TimelineEventModelImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? memberId = null,
    Object? eventDate = freezed,
    Object? title = null,
    Object? description = freezed,
    Object? imageUrl = freezed,
    Object? audioUrl = freezed,
    Object? createdAt = null,
  }) {
    return _then(_$TimelineEventModelImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      memberId: null == memberId
          ? _value.memberId
          : memberId // ignore: cast_nullable_to_non_nullable
              as String,
      eventDate: freezed == eventDate
          ? _value.eventDate
          : eventDate // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      title: null == title
          ? _value.title
          : title // ignore: cast_nullable_to_non_nullable
              as String,
      description: freezed == description
          ? _value.description
          : description // ignore: cast_nullable_to_non_nullable
              as String?,
      imageUrl: freezed == imageUrl
          ? _value.imageUrl
          : imageUrl // ignore: cast_nullable_to_non_nullable
              as String?,
      audioUrl: freezed == audioUrl
          ? _value.audioUrl
          : audioUrl // ignore: cast_nullable_to_non_nullable
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
class _$TimelineEventModelImpl implements _TimelineEventModel {
  const _$TimelineEventModelImpl(
      {required this.id,
      @JsonKey(name: 'member_id') required this.memberId,
      @JsonKey(name: 'event_date') this.eventDate,
      required this.title,
      this.description,
      @JsonKey(name: 'image_url') this.imageUrl,
      @JsonKey(name: 'audio_url') this.audioUrl,
      @JsonKey(name: 'created_at') required this.createdAt});

  factory _$TimelineEventModelImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimelineEventModelImplFromJson(json);

  @override
  final String id;
  @override
  @JsonKey(name: 'member_id')
  final String memberId;
  @override
  @JsonKey(name: 'event_date')
  final DateTime? eventDate;
  @override
  final String title;
  @override
  final String? description;
  @override
  @JsonKey(name: 'image_url')
  final String? imageUrl;
  @override
  @JsonKey(name: 'audio_url')
  final String? audioUrl;
  @override
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @override
  String toString() {
    return 'TimelineEventModel(id: $id, memberId: $memberId, eventDate: $eventDate, title: $title, description: $description, imageUrl: $imageUrl, audioUrl: $audioUrl, createdAt: $createdAt)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimelineEventModelImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.memberId, memberId) ||
                other.memberId == memberId) &&
            (identical(other.eventDate, eventDate) ||
                other.eventDate == eventDate) &&
            (identical(other.title, title) || other.title == title) &&
            (identical(other.description, description) ||
                other.description == description) &&
            (identical(other.imageUrl, imageUrl) ||
                other.imageUrl == imageUrl) &&
            (identical(other.audioUrl, audioUrl) ||
                other.audioUrl == audioUrl) &&
            (identical(other.createdAt, createdAt) ||
                other.createdAt == createdAt));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(runtimeType, id, memberId, eventDate, title,
      description, imageUrl, audioUrl, createdAt);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$TimelineEventModelImplCopyWith<_$TimelineEventModelImpl> get copyWith =>
      __$$TimelineEventModelImplCopyWithImpl<_$TimelineEventModelImpl>(
          this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimelineEventModelImplToJson(
      this,
    );
  }
}

abstract class _TimelineEventModel implements TimelineEventModel {
  const factory _TimelineEventModel(
          {required final String id,
          @JsonKey(name: 'member_id') required final String memberId,
          @JsonKey(name: 'event_date') final DateTime? eventDate,
          required final String title,
          final String? description,
          @JsonKey(name: 'image_url') final String? imageUrl,
          @JsonKey(name: 'audio_url') final String? audioUrl,
          @JsonKey(name: 'created_at') required final DateTime createdAt}) =
      _$TimelineEventModelImpl;

  factory _TimelineEventModel.fromJson(Map<String, dynamic> json) =
      _$TimelineEventModelImpl.fromJson;

  @override
  String get id;
  @override
  @JsonKey(name: 'member_id')
  String get memberId;
  @override
  @JsonKey(name: 'event_date')
  DateTime? get eventDate;
  @override
  String get title;
  @override
  String? get description;
  @override
  @JsonKey(name: 'image_url')
  String? get imageUrl;
  @override
  @JsonKey(name: 'audio_url')
  String? get audioUrl;
  @override
  @JsonKey(name: 'created_at')
  DateTime get createdAt;
  @override
  @JsonKey(ignore: true)
  _$$TimelineEventModelImplCopyWith<_$TimelineEventModelImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

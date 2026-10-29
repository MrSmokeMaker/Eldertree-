import 'package:freezed_annotation/freezed_annotation.dart';

part 'timeline_event_model.freezed.dart';
part 'timeline_event_model.g.dart';

@freezed
class TimelineEventModel with _$TimelineEventModel {
  const factory TimelineEventModel({
    required String id,
    @JsonKey(name: 'member_id') required String memberId,
    @JsonKey(name: 'event_date') DateTime? eventDate,
    required String title,
    String? description,
    @JsonKey(name: 'image_url') String? imageUrl,
    @JsonKey(name: 'audio_url') String? audioUrl,
    @JsonKey(name: 'created_at') required DateTime createdAt,
  }) = _TimelineEventModel;

  factory TimelineEventModel.fromJson(Map<String, dynamic> json) =>
      _$TimelineEventModelFromJson(json);
}

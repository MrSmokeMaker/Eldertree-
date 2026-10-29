import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/supabase_providers.dart';
import '../../data/models/fact_model.dart';
import '../../data/models/timeline_event_model.dart';

part 'profile_controller.g.dart';

class UnifiedEvent {
  final String id;
  final DateTime date;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? audioUrl;
  final bool isFact;

  UnifiedEvent({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    this.imageUrl,
    this.audioUrl,
    this.isFact = false,
  });
}

class ProfileState {
  final List<FactModel> allFacts;
  final List<UnifiedEvent> timeline;
  ProfileState(this.allFacts, this.timeline);
}

@riverpod
class ProfileController extends _$ProfileController {
  @override
  FutureOr<ProfileState> build(String memberId) async {
    final client = ref.watch(supabaseProvider);
    final factsRes = await client.from('facts').select().eq('member_id', memberId);
    final facts = factsRes.map((j) => FactModel.fromJson(j)).toList();

    final eventsRes = await client.from('timeline_events').select().eq('member_id', memberId);
    final events = eventsRes.map((j) => TimelineEventModel.fromJson(j)).toList();

    final List<UnifiedEvent> timeline = [];
    
    for (var event in events) {
      timeline.add(UnifiedEvent(
        id: event.id,
        date: event.eventDate ?? event.createdAt,
        title: event.title,
        description: event.description,
        imageUrl: event.imageUrl,
        audioUrl: event.audioUrl,
      ));
    }
    for (var fact in facts) {
      if (fact.factDate != null) {
        timeline.add(UnifiedEvent(
          id: fact.id,
          date: fact.factDate!,
          title: 'Fact: ${fact.category.name}',
          description: fact.value,
          isFact: true,
        ));
      }
    }
    timeline.sort((a, b) => a.date.compareTo(b.date));

    return ProfileState(facts, timeline);
  }

  Future<void> addVoiceCapsule(String localPath) async {
    final client = ref.watch(supabaseProvider);
    final file = File(localPath);
    final fileName = '${memberId}_${const Uuid().v4()}.m4a';
    final storagePath = '${client.auth.currentUser!.id}/$fileName';

    try {
      await client.storage.from('audio').upload(storagePath, file);
      final audioUrl = client.storage.from('audio').getPublicUrl(storagePath);
      await client.from('timeline_events').insert({
        'member_id': memberId,
        'title': 'Voice Memory',
        'event_date': DateTime.now().toIso8601String(),
        'audio_url': audioUrl,
      });
      ref.invalidateSelf();
    } catch (e) {
      print('Audio upload failed: $e');
    }
  }
}

import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/supabase_providers.dart';
import '../../data/models/fact_model.dart';
import '../../data/models/timeline_event_model.dart';
import '../../data/models/enums.dart';

part 'profile_controller.g.dart';

class UnifiedEvent {
  final String id;
  final DateTime date;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final String? audioUrl;
  final bool isFact;

  UnifiedEvent({
    required this.id,
    required this.date,
    required this.title,
    this.description,
    this.imageUrl,
    this.videoUrl,
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
  // Локальное хранилище добавленных событий в демо-режиме
  static final Map<String, List<UnifiedEvent>> _customEventsByMember = {};

  @override
  FutureOr<ProfileState> build(String memberId) async {
    final client = ref.watch(supabaseProvider);
    final isGuest =
        client.auth.currentUser == null || memberId.startsWith('demo-');

    final List<UnifiedEvent> timeline = [];
    final List<FactModel> facts = [];

    if (!isGuest) {
      try {
        final factsRes =
            await client.from('facts').select().eq('member_id', memberId);
        facts.addAll(factsRes.map((j) => FactModel.fromJson(j)));

        final eventsRes = await client
            .from('timeline_events')
            .select()
            .eq('member_id', memberId);
        final events =
            eventsRes.map((j) => TimelineEventModel.fromJson(j)).toList();

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
      } catch (_) {
        // Fallback к демо-данным при ошибке сети/таблиц
      }
    }

    // Если нет фактов с сервера, наполняем базовыми семейными фактами
    if (facts.isEmpty) {
      facts.addAll([
        FactModel(
          id: 'df-1',
          memberId: memberId,
          category: FactCategory.birthplace,
          value: 'Родовое имение, Новгородская губерния',
          factDate: DateTime(1982, 3, 15),
          createdAt: DateTime.now(),
        ),
        FactModel(
          id: 'df-2',
          memberId: memberId,
          category: FactCategory.occupation,
          value: 'Хранитель семейного архива и летописи рода',
          createdAt: DateTime.now(),
        ),
        FactModel(
          id: 'df-3',
          memberId: memberId,
          category: FactCategory.story,
          value:
              'Передал правнукам старинные серебряные карманные часы с гербом',
          createdAt: DateTime.now(),
        ),
      ]);
    }

    // Если нет событий с сервера, добавляем начальные демо-события
    if (timeline.isEmpty) {
      timeline.addAll([
        UnifiedEvent(
          id: 'de-1',
          date: DateTime(1982, 3, 15),
          title: 'День рождения',
          description: 'Появление на свет в кругу большой семьи',
        ),
        UnifiedEvent(
          id: 'de-2',
          date: DateTime(2005, 7, 20),
          title: 'Брачный союз',
          description: 'Венчание и закладка новой родовой ветви',
        ),
        UnifiedEvent(
          id: 'de-3',
          date: DateTime(2010, 7, 19),
          title: 'Рождение первенца',
          description: 'Продолжение векового древа',
        ),
      ]);
    }

    // Добавляем пользовательские события, созданные в текущей сессии
    final userCreated = _customEventsByMember[memberId] ?? [];
    timeline.addAll(userCreated);

    // Добавляем факты с датами в общий таймлайн
    for (var fact in facts) {
      if (fact.factDate != null && !timeline.any((e) => e.id == fact.id)) {
        timeline.add(UnifiedEvent(
          id: fact.id,
          date: fact.factDate!,
          title: 'Семейная летопись: ${_factCategoryTitle(fact.category)}',
          description: fact.value,
          isFact: true,
        ));
      }
    }

    timeline.sort((a, b) => a.date.compareTo(b.date));

    return ProfileState(facts, timeline);
  }

  static String _factCategoryTitle(FactCategory category) {
    switch (category) {
      case FactCategory.birthplace:
        return 'Место рождения';
      case FactCategory.occupation:
        return 'Род деятельности';
      case FactCategory.trait:
        return 'Черта характера';
      case FactCategory.phrase:
        return 'Крылатая фраза';
      case FactCategory.story:
        return 'Семейная легенда';
      case FactCategory.custom:
        return 'Памятное событие';
    }
  }

  /// Добавление фото, видео или заметки на конкретную дату в таймлайне
  Future<void> addTimelineMemory({
    required DateTime date,
    required String title,
    String? description,
    String? imageUrl,
    String? videoUrl,
  }) async {
    final client = ref.watch(supabaseProvider);
    final isGuest =
        client.auth.currentUser == null || memberId.startsWith('demo-');

    final newEvent = UnifiedEvent(
      id: 'custom-${DateTime.now().millisecondsSinceEpoch}',
      date: date,
      title: title,
      description: description,
      imageUrl: (imageUrl != null && imageUrl.trim().isNotEmpty)
          ? imageUrl.trim()
          : null,
      videoUrl: (videoUrl != null && videoUrl.trim().isNotEmpty)
          ? videoUrl.trim()
          : null,
    );

    // Сохраняем локально для мгновенного отображения
    _customEventsByMember.putIfAbsent(memberId, () => []).add(newEvent);

    if (!isGuest) {
      try {
        await client.from('timeline_events').insert({
          'member_id': memberId,
          'title': title,
          'event_date': date.toIso8601String(),
          'description': description,
          'image_url': imageUrl,
        });
      } catch (_) {
        // Ошибка сервера не мешает локальному отображению
      }
    }

    ref.invalidateSelf();
  }

  Future<void> addVoiceCapsule(String localPath) async {
    final client = ref.watch(supabaseProvider);
    if (client.auth.currentUser == null) return;

    final file = File(localPath);
    final fileName = '${memberId}_${const Uuid().v4()}.m4a';
    final storagePath = '${client.auth.currentUser!.id}/$fileName';

    try {
      await client.storage.from('audio').upload(storagePath, file);
      final audioUrl = client.storage.from('audio').getPublicUrl(storagePath);
      await client.from('timeline_events').insert({
        'member_id': memberId,
        'title': 'Голосовая память',
        'event_date': DateTime.now().toIso8601String(),
        'audio_url': audioUrl,
      });
      ref.invalidateSelf();
    } catch (_) {}
  }
}

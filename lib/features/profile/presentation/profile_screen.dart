import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/theme.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/fact_model.dart';
import '../../../data/models/enums.dart';
import '../profile_controller.dart';
import 'widgets/voice_capsule_widgets.dart';
import '../../interview/presentation/interview_screen.dart';

class ProfileScreen extends ConsumerWidget {
  final MemberModel member;
  const ProfileScreen({super.key, required this.member});

  static void show(BuildContext context, MemberModel member) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.90,
        child: ProfileScreen(member: member),
      ),
    );
  }

  void _showAddMemoryDialog(BuildContext context, WidgetRef ref) {
    DateTime selectedDate = DateTime.now();
    int memoryTypeIndex = 0; // 0 - Заметка, 1 - Фото, 2 - Видео

    final titleController = TextEditingController();
    final descriptionController = TextEditingController();
    final mediaUrlController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogCtx) {
        return StatefulBuilder(
          builder: (ctx, setDialogState) {
            final isDark = Theme.of(ctx).brightness == Brightness.dark;
            final dateStr = DateFormat('d MMMM yyyy г.', 'ru').format(selectedDate);

            return AlertDialog(
              backgroundColor: isDark ? const Color(0xFF1A1F29) : Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: BorderSide(
                  color: AppTheme.primaryGold.withValues(alpha: 0.4),
                  width: 1.2,
                ),
              ),
              title: Row(
                children: [
                  const Icon(Icons.bookmark_add_rounded, color: AppTheme.primaryGold, size: 26),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Память в летопись',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: SingleChildScrollView(
                child: SizedBox(
                  width: 440,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Выбор даты
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        leading: const Icon(Icons.calendar_month_rounded, color: AppTheme.primaryGold),
                        title: const Text('Дата события:', style: TextStyle(fontSize: 13, color: Colors.grey)),
                        subtitle: Text(
                          dateStr,
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        trailing: OutlinedButton(
                          onPressed: () async {
                            final picked = await showDatePicker(
                              context: ctx,
                              initialDate: selectedDate,
                              firstDate: DateTime(1700),
                              lastDate: DateTime.now().add(const Duration(days: 365)),
                            );
                            if (picked != null) {
                              setDialogState(() => selectedDate = picked);
                            }
                          },
                          child: const Text('Выбрать'),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // Переключатель типа: Заметка / Фото / Видео
                      SegmentedButton<int>(
                        segments: const [
                          ButtonSegment(
                            value: 0,
                            icon: Icon(Icons.edit_note_rounded),
                            label: Text('Заметка'),
                          ),
                          ButtonSegment(
                            value: 1,
                            icon: Icon(Icons.photo_camera_rounded),
                            label: Text('Фото'),
                          ),
                          ButtonSegment(
                            value: 2,
                            icon: Icon(Icons.videocam_rounded),
                            label: Text('Видео'),
                          ),
                        ],
                        selected: {memoryTypeIndex},
                        onSelectionChanged: (set) {
                          setDialogState(() => memoryTypeIndex = set.first);
                        },
                      ),
                      const SizedBox(height: 16),

                      // Название события
                      TextField(
                        controller: titleController,
                        decoration: InputDecoration(
                          labelText: 'Название события / вехи *',
                          hintText: memoryTypeIndex == 1
                              ? 'Семейная фотография на веранде'
                              : (memoryTypeIndex == 2
                                  ? 'Видеохроника юбилея'
                                  : 'Важная памятная дата'),
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Текст заметки
                      TextField(
                        controller: descriptionController,
                        maxLines: 3,
                        decoration: InputDecoration(
                          labelText: 'Описание / воспоминание',
                          hintText: 'Расскажите об этом дне, участниках и атмосфере...',
                          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                      ),

                      // Поле для Фото или Видео
                      if (memoryTypeIndex == 1) ...[
                        const SizedBox(height: 14),
                        TextField(
                          controller: mediaUrlController,
                          decoration: InputDecoration(
                            labelText: 'Ссылка на изображение (URL)',
                            hintText: 'https://example.com/photo.jpg',
                            prefixIcon: const Icon(Icons.image_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.auto_fix_high),
                              tooltip: 'Пример семейного фото',
                              onPressed: () {
                                mediaUrlController.text =
                                    'https://images.unsplash.com/photo-1511895426328-dc8714191300?w=800';
                                setDialogState(() {});
                              },
                            ),
                          ),
                        ),
                      ] else if (memoryTypeIndex == 2) ...[
                        const SizedBox(height: 14),
                        TextField(
                          controller: mediaUrlController,
                          decoration: InputDecoration(
                            labelText: 'Ссылка на видео (YouTube / mp4)',
                            hintText: 'https://youtu.be/... или ссылка на файл',
                            prefixIcon: const Icon(Icons.video_library_outlined),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogCtx),
                  child: const Text('Отмена'),
                ),
                ElevatedButton.icon(
                  onPressed: () {
                    final title = titleController.text.trim();
                    if (title.isEmpty) return;

                    final description = descriptionController.text.trim();
                    final mediaUrl = mediaUrlController.text.trim();

                    ref.read(profileControllerProvider(member.id).notifier).addTimelineMemory(
                          date: selectedDate,
                          title: title,
                          description: description.isNotEmpty ? description : null,
                          imageUrl: memoryTypeIndex == 1 ? mediaUrl : null,
                          videoUrl: memoryTypeIndex == 2 ? mediaUrl : null,
                        );

                    Navigator.pop(dialogCtx);

                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Событие "$title" добавлено в летопись!'),
                        backgroundColor: const Color(0xFF1B3B2B),
                      ),
                    );
                  },
                  icon: const Icon(Icons.check, size: 18),
                  label: const Text('Сохранить'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryGold,
                    foregroundColor: const Color(0xFF10141A),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileStateAsync = ref.watch(profileControllerProvider(member.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF141820) : const Color(0xFFFFFFFF);

    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: profileStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (state) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.grey.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                      const SizedBox(height: 20),
                      // Геральдический медальон персоны
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: const LinearGradient(
                            colors: [AppTheme.primaryGoldLight, AppTheme.primaryGoldDark],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppTheme.primaryGold.withValues(alpha: 0.35),
                              blurRadius: 16,
                            ),
                          ],
                        ),
                        child: CircleAvatar(
                          radius: 50,
                          backgroundColor: isDark
                              ? const Color(0xFF1C222D)
                              : const Color(0xFFF7F4EE),
                          backgroundImage: member.avatarUrl != null
                              ? NetworkImage(member.avatarUrl!)
                              : null,
                          child: member.avatarUrl == null
                              ? Text(
                                  member.firstName.isNotEmpty ? member.firstName[0] : '?',
                                  style: const TextStyle(
                                    fontSize: 38,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryGold,
                                  ),
                                )
                              : null,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        member.firstName,
                        style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                      ),
                      if (member.birthDate != null)
                        Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Text(
                            '${member.birthDate!.year} – ${member.deathDate?.year ?? 'Ныне живущий'}',
                            style: const TextStyle(
                              color: AppTheme.primaryGold,
                              fontWeight: FontWeight.w500,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          FilledButton.icon(
                            onPressed: () => _showAddMemoryDialog(context, ref),
                            style: FilledButton.styleFrom(
                              backgroundColor: AppTheme.primaryGold,
                              foregroundColor: const Color(0xFF10141A),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            icon: const Icon(Icons.bookmark_add_rounded, size: 18),
                            label: const Text('Добавить веху'),
                          ),
                          const SizedBox(width: 12),
                          OutlinedButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => InterviewScreen(member: member),
                              ),
                            ),
                            icon: const Icon(Icons.forum_outlined, size: 18),
                            label: const Text('Интервью рода'),
                            style: OutlinedButton.styleFrom(
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

              // Факты и летопись
              SliverToBoxAdapter(
                child: _buildGhostFacts(context, state.allFacts),
              ),

              // Разделитель заголовка хроники
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                  child: Row(
                    children: [
                      const Icon(Icons.history_edu_rounded, color: AppTheme.primaryGold, size: 22),
                      const SizedBox(width: 8),
                      const Text(
                        'Летопись и хроника',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _showAddMemoryDialog(context, ref),
                        icon: const Icon(Icons.add, size: 16),
                        label: const Text('Память'),
                      ),
                    ],
                  ),
                ),
              ),

              // Список событий таймлайна
              SliverPadding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) => _buildTimelineEvent(
                      context,
                      state.timeline[index],
                      isLast: index == state.timeline.length - 1,
                    ),
                    childCount: state.timeline.length,
                  ),
                ),
              ),

              // Кнопка голосовой капсулы памяти
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(32.0),
                  child: Center(
                    child: VoiceRecorderButton(
                      onRecordComplete: (path) => ref
                          .read(profileControllerProvider(member.id).notifier)
                          .addVoiceCapsule(path),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildGhostFacts(BuildContext context, List<FactModel> facts) {
    if (!facts.any((f) => f.category == FactCategory.birthplace)) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => InterviewScreen(member: member),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.primaryGold.withValues(alpha: 0.08),
              border: Border.all(
                color: AppTheme.primaryGold.withValues(alpha: 0.3),
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_outline, color: AppTheme.primaryGold),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Расскажите, где родился ${member.firstName} \u2192',
                    style: const TextStyle(
                      color: AppTheme.primaryGold,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTimelineEvent(BuildContext context, UnifiedEvent event,
      {required bool isLast}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateDisplay = DateFormat('d MMMM yyyy г.', 'ru').format(event.date);

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Левая ось таймлайна с золотым узлом
          Column(
            children: [
              Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primaryGoldLight, AppTheme.primaryGoldDark],
                  ),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryGold.withValues(alpha: 0.5),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    color: AppTheme.primaryGold.withValues(alpha: 0.25),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          // Карточка события
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 28.0),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isDark
                      ? const Color(0xFF19202B).withValues(alpha: 0.8)
                      : const Color(0xFFF9F6EE),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppTheme.primaryGold.withValues(alpha: 0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Дата
                    Text(
                      dateDisplay,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryGold,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 4),

                    // Заголовок
                    Row(
                      children: [
                        if (event.imageUrl != null)
                          const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Icon(Icons.photo_camera_rounded, size: 16, color: AppTheme.primaryGold),
                          )
                        else if (event.videoUrl != null)
                          const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Icon(Icons.videocam_rounded, size: 16, color: AppTheme.primaryGold),
                          )
                        else
                          const Padding(
                            padding: EdgeInsets.only(right: 6.0),
                            child: Icon(Icons.auto_stories_rounded, size: 16, color: AppTheme.primaryGold),
                          ),
                        Expanded(
                          child: Text(
                            event.title,
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),

                    // Описание / Заметка
                    if (event.description != null && event.description!.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(
                        event.description!,
                        style: TextStyle(
                          fontSize: 14,
                          color: isDark ? const Color(0xFFE0E5EC) : const Color(0xFF333D4B),
                          height: 1.35,
                        ),
                      ),
                    ],

                    // Фото
                    if (event.imageUrl != null && event.imageUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(
                          event.imageUrl!,
                          height: 180,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (c, e, s) => Container(
                            height: 100,
                            color: Colors.grey.withValues(alpha: 0.2),
                            alignment: Alignment.center,
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.broken_image, size: 20),
                                SizedBox(width: 8),
                                Text('Изображение недоступно'),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],

                    // Видео карточка
                    if (event.videoUrl != null && event.videoUrl!.isNotEmpty) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1B3B2B).withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: const Color(0xFF2D4A3E).withValues(alpha: 0.4),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.play_circle_fill_rounded, color: AppTheme.primaryGold, size: 28),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                event.videoUrl!,
                                style: const TextStyle(fontSize: 13, decoration: TextDecoration.underline),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Аудиозапись
                    if (event.audioUrl != null) ...[
                      const SizedBox(height: 10),
                      VoicePlayerWidget(audioUrl: event.audioUrl!),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

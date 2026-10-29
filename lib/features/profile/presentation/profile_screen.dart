import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
        heightFactor: 0.85,
        child: ProfileScreen(member: member),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileStateAsync = ref.watch(profileControllerProvider(member.id));
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor =
        isDark ? const Color(0xFF1A1D24) : const Color(0xFFFFFFFF);

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
                          width: 40,
                          height: 4,
                          decoration: BoxDecoration(
                              color: Colors.grey.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(2))),
                      const SizedBox(height: 24),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.1),
                        backgroundImage: member.avatarUrl != null
                            ? NetworkImage(member.avatarUrl!)
                            : null,
                        child: member.avatarUrl == null
                            ? Text(member.firstName[0],
                                style: const TextStyle(fontSize: 40))
                            : null,
                      ),
                      const SizedBox(height: 16),
                      Text(member.firstName,
                          style: const TextStyle(
                              fontSize: 28, fontWeight: FontWeight.bold)),
                      if (member.birthDate != null)
                        Text(
                            '${member.birthDate!.year} – ${member.deathDate?.year ?? 'Present'}',
                            style: const TextStyle(color: Colors.grey)),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          OutlinedButton.icon(
                              onPressed: () {},
                              icon: const Icon(Icons.edit, size: 16),
                              label: const Text('Edit')),
                          const SizedBox(width: 12),
                          FilledButton.icon(
                            onPressed: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      InterviewScreen(member: member)),
                            ),
                            icon: const Icon(Icons.forum, size: 16),
                            label: const Text('Interview'),
                          ),
                        ],
                      )
                    ],
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: _buildGhostFacts(context, state.allFacts),
              ),
              SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
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
                builder: (context) => InterviewScreen(member: member)),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color:
                  Theme.of(context).colorScheme.primary.withValues(alpha: 0.05),
              border: Border.all(
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.2)),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.lightbulb_outline,
                    color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Tell us where ${member.firstName} was born \u2192',
                    style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontStyle: FontStyle.italic),
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
    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            children: [
              Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.primary,
                      shape: BoxShape.circle)),
              if (!isLast)
                Expanded(
                    child: Container(
                        width: 2,
                        color: Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.3))),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(event.date.year.toString(),
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.grey)),
                  const SizedBox(height: 4),
                  Text(event.title,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold)),
                  if (event.description != null) ...[
                    const SizedBox(height: 8),
                    Text(event.description!)
                  ],
                  if (event.imageUrl != null) ...[
                    const SizedBox(height: 8),
                    ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.network(event.imageUrl!,
                            height: 150,
                            width: double.infinity,
                            fit: BoxFit.cover))
                  ],
                  if (event.audioUrl != null) ...[
                    VoicePlayerWidget(audioUrl: event.audioUrl!)
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../tree_list/current_tree_controller.dart';
import '../domain/services/tree_layout_service.dart';
import '../domain/services/audio_service.dart';
import '../tree_graph_controller.dart';
import '../lens_controller.dart';
import '../search_provider.dart';
import '../../../core/utils/notification_service.dart';
import '../domain/models/graph_node.dart';
import '../../profile/presentation/profile_screen.dart';

import 'widgets/parallax_background.dart';
import 'widgets/branch_painter.dart';
import 'widgets/member_node_widget.dart';
import 'widgets/add_relative_sheet.dart';
import 'widgets/lens_overlay_widget.dart';

class TreeCanvasScreen extends ConsumerStatefulWidget {
  const TreeCanvasScreen({super.key});

  @override
  ConsumerState<TreeCanvasScreen> createState() => _TreeCanvasScreenState();
}

class _TreeCanvasScreenState extends ConsumerState<TreeCanvasScreen> {
  final TransformationController _transformationController =
      TransformationController();
  final TextEditingController _searchController = TextEditingController();
  bool _isScrolling = false;
  String? _selectedMemberId;
  StreamSubscription? _notifSubscription;
  bool _searchVisible = false;

  @override
  void initState() {
    super.initState();
    _transformationController.addListener(_onCanvasTransformed);
    WidgetsBinding.instance.addPostFrameCallback((_) => _centerCamera());

    _notifSubscription = ref
        .read(notificationServiceProvider)
        .onNotificationTap
        .listen((memberId) {
      final state = ref.read(treeGraphControllerProvider).value;
      if (state != null) {
        try {
          final member = state.members.firstWhere((m) => m.id == memberId);
          ProfileScreen.show(context, member);
        } catch (_) {}
      }
    });
  }

  void _onCanvasTransformed() {
    if (!_isScrolling) {
      _isScrolling = true;
      ref.read(audioServiceProvider).playScrollLeaves();
      Future.delayed(const Duration(milliseconds: 300), () {
        if (mounted) {
          _isScrolling = false;
          ref.read(audioServiceProvider).stopScrollLeaves();
        }
      });
    }
  }

  void _centerCamera() {
    final size = MediaQuery.of(context).size;
    _transformationController.value = Matrix4.identity()
      ..translate(size.width / 2, size.height / 2);
  }

  void _toggleSearch() {
    setState(() {
      _searchVisible = !_searchVisible;
      if (!_searchVisible) {
        _searchController.clear();
        ref.read(searchQueryProvider.notifier).state = '';
      }
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _searchController.dispose();
    _notifSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentTree = ref.watch(currentTreeControllerProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final searchQuery = ref.watch(searchQueryProvider).toLowerCase().trim();

    if (currentTree == null) {
      return const Scaffold(body: Center(child: Text('No tree selected')));
    }
    final graphStateAsync = ref.watch(treeGraphControllerProvider);

    return Scaffold(
      body: graphStateAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
        data: (graph) {
          final members = graph.members;
          final rels = graph.relationships;
          final rootId = currentTree.ownerId;

          if (members.isEmpty) {
            return Stack(
              children: [
                ParallaxBackground(
                    controller: _transformationController, isDark: isDark),
                Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.all(28),
                    constraints: const BoxConstraints(maxWidth: 420),
                    decoration: BoxDecoration(
                      color: (isDark ? const Color(0xFF141820) : Colors.white)
                          .withValues(alpha: 0.94),
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.6),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFFD4AF37).withValues(alpha: 0.2),
                          blurRadius: 24,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 64,
                          height: 64,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color:
                                const Color(0xFF2D4A3E).withValues(alpha: 0.15),
                            border: Border.all(
                              color: const Color(0xFFD4AF37),
                              width: 1.5,
                            ),
                          ),
                          child: const Icon(
                            Icons.nature_people_rounded,
                            size: 36,
                            color: Color(0xFFD4AF37),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          currentTree.name,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Древо пока пусто. Добавьте первого человека (основателя), от которого потянутся корни предков и ветви потомков.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            height: 1.4,
                            color: Theme.of(context)
                                .textTheme
                                .bodyMedium
                                ?.color
                                ?.withValues(alpha: 0.8),
                          ),
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton.icon(
                          onPressed: () {
                            AddRelativeSheet.show(
                              context,
                              'self',
                              ({
                                required firstName,
                                lastName,
                                required gender,
                                birthDate,
                              }) async {
                                await ref
                                    .read(treeGraphControllerProvider.notifier)
                                    .addRelative(
                                      targetMemberId: '',
                                      firstName: firstName,
                                      lastName: lastName,
                                      gender: gender,
                                      birthDate: birthDate,
                                      relationType: 'self',
                                    );
                                ref
                                    .read(audioServiceProvider)
                                    .playAddMemberChime();
                              },
                            );
                          },
                          icon: const Icon(Icons.add),
                          label: const Text(
                            'Посадить древо рода',
                            style: TextStyle(
                                fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF2D4A3E),
                            foregroundColor: const Color(0xFFF9F8F6),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 24,
                              vertical: 14,
                            ),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                              side: const BorderSide(
                                color: Color(0xFFD4AF37),
                                width: 1,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }

          final lensState = ref.watch(lensControllerProvider);
          int minYear = DateTime.now().year;
          for (var m in members) {
            if (m.birthDate != null && m.birthDate!.year < minYear) {
              minYear = m.birthDate!.year;
            }
          }
          if (minYear == DateTime.now().year) minYear = 1900;

          final Set<String> hiddenNodeIds = {};
          if (lensState.isActive) {
            for (var m in members) {
              if (m.birthDate != null && m.birthDate!.year > lensState.year) {
                hiddenNodeIds.add(m.id);
              }
            }
          }

          // Filter by search query
          final Set<String> searchHiddenIds = {};
          if (searchQuery.isNotEmpty) {
            for (var m in members) {
              final fullName =
                  '${m.firstName} ${m.lastName ?? ''}'.toLowerCase();
              if (!fullName.contains(searchQuery)) {
                searchHiddenIds.add(m.id);
              }
            }
          }

          final allHiddenIds = hiddenNodeIds.union(searchHiddenIds);

          final layoutMap =
              ref.watch(treeLayoutServiceProvider).calculateLayout(
                    ownerId: rootId,
                    members: members,
                    relationships: rels,
                  );

          final positions = layoutMap.map((k, v) => MapEntry(k, v.position));

          final dummyNodes = {
            for (var m in members)
              m.id: GraphNode(m)
                ..x = (positions[m.id]?.dx ?? 0)
                ..y = (positions[m.id]?.dy ?? 0)
          };

          return Stack(
            children: [
              ParallaxBackground(
                  controller: _transformationController, isDark: isDark),
              GestureDetector(
                onTap: () => setState(() => _selectedMemberId = null),
                child: InteractiveViewer(
                  transformationController: _transformationController,
                  minScale: 0.1,
                  maxScale: 2.5,
                  constrained: false,
                  boundaryMargin: const EdgeInsets.all(5000),
                  child: Stack(
                    clipBehavior: Clip.none,
                    children: [
                      CustomPaint(
                        painter: BranchPainter(
                          nodes: dummyNodes,
                          relationships: rels,
                          isDark: isDark,
                          hiddenNodeIds: allHiddenIds,
                        ),
                      ),
                      ...members.map((m) {
                        final layoutInfo = layoutMap[m.id];
                        final pos = layoutInfo?.position ?? Offset.zero;
                        final branchSize = layoutInfo?.branchSize ?? 'medium';
                        final isFlipped = layoutInfo?.isFlipped ?? false;
                        final isVisible = !allHiddenIds.contains(m.id);
                        final isHighlighted = searchQuery.isNotEmpty &&
                            !searchHiddenIds.contains(m.id);

                        final double nodeLeft;
                        final double nodeTop;
                        if (branchSize == 'large') {
                          nodeLeft = pos.dx - (isFlipped ? 76.5 : 93.5);
                          nodeTop = pos.dy - 73.8;
                        } else if (branchSize == 'small') {
                          nodeLeft = pos.dx - (isFlipped ? 60.7 : 74.3);
                          nodeTop = pos.dy - 55.2;
                        } else {
                          nodeLeft = pos.dx - (isFlipped ? 69.7 : 85.3);
                          nodeTop = pos.dy - 63.0;
                        }

                        return Positioned(
                          left: nodeLeft,
                          top: nodeTop,
                          child: IgnorePointer(
                            ignoring: !isVisible,
                            child: AnimatedOpacity(
                              duration: const Duration(milliseconds: 250),
                              opacity: isVisible ? 1.0 : 0.0,
                              child: MemberNodeWidget(
                                member: m,
                                isSelected: _selectedMemberId == m.id,
                                isVisible: isVisible,
                                isHighlighted: isHighlighted,
                                branchSize: branchSize,
                                isFlipped: isFlipped,
                                onTap: () =>
                                    setState(() => _selectedMemberId = m.id),
                                onAddTap: (relationType) async {
                                  AddRelativeSheet.show(
                                    context,
                                    relationType,
                                    ({
                                      required firstName,
                                      lastName,
                                      required gender,
                                      birthDate,
                                    }) async {
                                      await ref
                                          .read(treeGraphControllerProvider
                                              .notifier)
                                          .addRelative(
                                            targetMemberId: m.id,
                                            firstName: firstName,
                                            lastName: lastName,
                                            gender: gender,
                                            birthDate: birthDate,
                                            relationType: relationType,
                                          );
                                      ref
                                          .read(audioServiceProvider)
                                          .playAddMemberChime();
                                      final state = ref
                                          .read(treeGraphControllerProvider)
                                          .value;
                                      if (context.mounted &&
                                          state != null &&
                                          state.members.length == 2) {
                                        await ref
                                            .read(notificationServiceProvider)
                                            .requestPermissionGently(context);
                                      }
                                    },
                                  );
                                },
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              // Search bar overlay
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: SafeArea(
                  child: Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => context.pop(),
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.85),
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_searchVisible)
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              autofocus: true,
                              decoration: InputDecoration(
                                hintText: 'Поиск члена семьи...',
                                filled: true,
                                fillColor: Theme.of(context)
                                    .colorScheme
                                    .surface
                                    .withValues(alpha: 0.92),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide.none,
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    ref
                                        .read(searchQueryProvider.notifier)
                                        .state = '';
                                  },
                                ),
                              ),
                              onChanged: (v) => ref
                                  .read(searchQueryProvider.notifier)
                                  .state = v,
                            ),
                          )
                        else
                          const Spacer(),
                        IconButton(
                          icon: Icon(
                              _searchVisible ? Icons.search_off : Icons.search),
                          onPressed: _toggleSearch,
                          style: IconButton.styleFrom(
                            backgroundColor: Theme.of(context)
                                .colorScheme
                                .surface
                                .withValues(alpha: 0.85),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 40,
                left: 0,
                right: 0,
                child: Center(
                  child: LensOverlayWidget(
                    minYear: minYear,
                    maxYear: DateTime.now().year,
                  ),
                ),
              ),
              Positioned(
                bottom: 100,
                right: 24,
                child: FloatingActionButton(
                  onPressed: _centerCamera,
                  backgroundColor: Theme.of(context)
                      .colorScheme
                      .surface
                      .withValues(alpha: 0.8),
                  child: const Icon(Icons.my_location),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

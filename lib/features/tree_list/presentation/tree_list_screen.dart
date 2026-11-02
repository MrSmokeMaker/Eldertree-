import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_controller.dart';
import '../../../core/utils/export_service.dart';
import '../../../core/utils/gedcom_service.dart';
import '../../../data/models/member_model.dart';
import '../../../data/models/relationship_model.dart';
import '../../../data/repositories/tree_repository.dart';
import '../tree_list_controller.dart';
import '../current_tree_controller.dart';

class TreeListScreen extends ConsumerWidget {
  const TreeListScreen({super.key});

  void _showCreateDialog(BuildContext context, WidgetRef ref) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новое древо рода'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Например, Родословная Ивановых',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Отмена'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref
                    .read(treeListControllerProvider.notifier)
                    .createTree(controller.text.trim());
                Navigator.pop(context);
              }
            },
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportOptions(
    BuildContext context,
    WidgetRef ref,
    String treeId,
    String treeName,
  ) async {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 36,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/icons/gedcom_scroll.svg',
                    width: 32,
                    height: 32,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    'Экспорт: $treeName',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              ListTile(
                leading: const Icon(Icons.share, color: Color(0xFFD4AF37)),
                title: const Text('Стандарт GEDCOM (.ged)'),
                subtitle: const Text('Для MyHeritage, Ancestry и архивов'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Формирование GEDCOM...')),
                    );
                    final data = await ref
                        .read(treeRepositoryProvider)
                        .getTreeExportData(treeId);
                    final members = (data['members'] as List)
                        .map((j) =>
                            MemberModel.fromJson(j as Map<String, dynamic>))
                        .toList();
                    final rels = (data['relationships'] as List)
                        .map((j) => RelationshipModel.fromJson(
                            j as Map<String, dynamic>))
                        .toList();
                    await GedcomService.exportAndShare(members, rels, treeName);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка экспорта: $e')),
                    );
                  }
                },
              ),
              ListTile(
                leading: const Icon(Icons.code, color: Color(0xFF2D4A3E)),
                title: const Text('Резервная копия JSON'),
                subtitle: const Text('Полный архив данных со всеми связями'),
                onTap: () async {
                  Navigator.pop(ctx);
                  try {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Формирование JSON...')),
                    );
                    final data = await ref
                        .read(treeRepositoryProvider)
                        .getTreeExportData(treeId);
                    await ExportService.exportJsonToDevice(data, treeName);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Ошибка экспорта: $e')),
                    );
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treesState = ref.watch(treeListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Семейные древа'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Выйти',
            onPressed: () =>
                ref.read(authControllerProvider.notifier).signOut(),
          ),
        ],
      ),
      body: treesState.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error: $err')),
        data: (trees) {
          if (trees.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SvgPicture.asset(
                    'assets/icons/heraldic_tree.svg',
                    width: 90,
                    height: 90,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Древа пока не созданы.\nНажмите +, чтобы посадить первое!',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: trees.length,
            padding: const EdgeInsets.all(16),
            itemBuilder: (context, index) {
              final tree = trees[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: const Color(0xFFD4AF37).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  leading: Container(
                    width: 44,
                    height: 44,
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: const Color(0xFF2D4A3E).withValues(alpha: 0.1),
                      border: Border.all(
                        color: const Color(0xFFD4AF37).withValues(alpha: 0.4),
                      ),
                    ),
                    child: SvgPicture.asset(
                      'assets/icons/heraldic_tree.svg',
                      fit: BoxFit.contain,
                    ),
                  ),
                  title: Text(
                    tree.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                    ),
                  ),
                  subtitle: Text(
                    'Создано: ${tree.createdAt.toLocal().toString().split(' ')[0]}',
                    style: const TextStyle(fontSize: 12),
                  ),
                  trailing: IconButton(
                    icon: SvgPicture.asset(
                      'assets/icons/gedcom_scroll.svg',
                      width: 26,
                      height: 26,
                    ),
                    tooltip: 'Экспорт древа',
                    onPressed: () =>
                        _exportOptions(context, ref, tree.id, tree.name),
                  ),
                  onTap: () {
                    ref
                        .read(currentTreeControllerProvider.notifier)
                        .setTree(tree);
                    context.push('/canvas');
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showCreateDialog(context, ref),
        backgroundColor: const Color(0xFF2D4A3E),
        foregroundColor: const Color(0xFFF9F8F6),
        child: const Icon(Icons.add),
      ),
    );
  }
}

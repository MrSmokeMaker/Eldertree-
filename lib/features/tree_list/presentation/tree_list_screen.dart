import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../auth/auth_controller.dart';
import '../../../core/utils/export_service.dart';
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
        title: const Text('Create New Tree'),
        content: TextField(
          controller: controller,
          decoration:
              const InputDecoration(hintText: 'e.g., The Smiths Family'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
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
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  Future<void> _exportTree(BuildContext context, WidgetRef ref, String treeId,
      String treeName) async {
    try {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Preparing export...')));
      final data =
          await ref.read(treeRepositoryProvider).getTreeExportData(treeId);
      await ExportService.exportJsonToDevice(data, treeName);
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text('Export failed: $e')));
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final treesState = ref.watch(treeListControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Family Trees'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
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
            return const Center(
              child: Text('No trees yet. Tap + to create one!',
                  style: TextStyle(fontSize: 16)),
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
                    borderRadius: BorderRadius.circular(16)),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Text(tree.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(
                      'Created: ${tree.createdAt.toLocal().toString().split(' ')[0]}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.download),
                    tooltip: 'Export as JSON',
                    onPressed: () =>
                        _exportTree(context, ref, tree.id, tree.name),
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
        child: const Icon(Icons.add),
      ),
    );
  }
}

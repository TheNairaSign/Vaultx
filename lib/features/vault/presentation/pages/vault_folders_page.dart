import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaultx/core/theme/vault_colors.dart';
import 'package:vaultx/features/vault/domain/entities/vault_folder.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_event.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_state.dart';
import 'package:vaultx/features/vault/presentation/pages/folder_items_page.dart';
import 'package:vaultx/features/vault/presentation/widgets/add_item_sheet.dart';
import 'package:vaultx/features/vault/presentation/pages/create_secret_page.dart';

class VaultFoldersPage extends StatefulWidget {
  const VaultFoldersPage({super.key});

  @override
  State<VaultFoldersPage> createState() => _VaultFoldersPageState();
}

class _VaultFoldersPageState extends State<VaultFoldersPage> {
  @override
  void initState() {
    super.initState();
    context.read<VaultBloc>().add(FetchFolders());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Vault',
          style: TextStyle(
            color: VaultColors.textPrimary,
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: VaultColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSearchAndStats(),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 24, vertical: 8),
            child: Text(
              'COLLECTIONS',
              style: TextStyle(
                color: VaultColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: BlocBuilder<VaultBloc, VaultState>(
              builder: (context, state) {
                if (state is VaultLoading) {
                  return const Center(child: CircularProgressIndicator(color: VaultColors.primary));
                }

                if (state is VaultLoaded) {
                  final folders = state.folders;
                  if (folders.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: folders.length,
                    itemBuilder: (context, index) {
                      return _buildFolderRow(context, folders[index]);
                    },
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showAddOptions(context),
        backgroundColor: VaultColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }

  Widget _buildSearchAndStats() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: VaultColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: VaultColors.textMuted.withOpacity(0.1)),
            ),
            child: const Row(
              children: [
                Icon(Icons.search, color: VaultColors.textMuted, size: 20),
                SizedBox(width: 12),
                Text(
                  'Search secrets...',
                  style: TextStyle(color: VaultColors.textMuted, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFolderRow(BuildContext context, VaultFolder folder) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FolderItemsPage(folder: folder),
          ),
        );
      },
      onLongPress: () => _showDeleteDialog(context, folder),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: VaultColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: VaultColors.textMuted.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VaultColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.folder_shared, color: VaultColors.primary, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    folder.name,
                    style: const TextStyle(
                      color: VaultColors.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '12 items • Updated today',
                    style: TextStyle(
                      color: VaultColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: VaultColors.textMuted, size: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, size: 80, color: VaultColors.textMuted.withOpacity(0.2)),
          const SizedBox(height: 16),
          const Text(
            'Create your first collection\nto organize your secrets.',
            textAlign: TextAlign.center,
            style: TextStyle(color: VaultColors.textSecondary, fontSize: 16, height: 1.5),
          ),
        ],
      ),
    );
  }

  void _showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemSheet(
        onNewSecret: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const CreateSecretPage(),
            ),
          );
        },
        onNewFolder: () {
          Navigator.pop(context);
          _showCreateFolderDialog(context);
        },
        onImportFile: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  void _showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VaultColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('New Folder', style: TextStyle(color: VaultColors.textPrimary)),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: const TextStyle(color: VaultColors.textPrimary),
          decoration: const InputDecoration(
            hintText: 'Folder name...',
            hintStyle: TextStyle(color: VaultColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: VaultColors.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<VaultBloc>().add(CreateFolder(name: controller.text));
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, VaultFolder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VaultColors.cardBackground,
        title: Text('Delete ${folder.name}?', style: const TextStyle(color: VaultColors.textPrimary)),
        content: const Text(
          'Secrets inside will be moved to the main vault. This action is irreversible.',
          style: TextStyle(color: VaultColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<VaultBloc>().add(DeleteFolder(folder.id));
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: VaultColors.error)),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaultx/core/theme/vault_colors.dart';
import 'package:vaultx/features/vault/domain/entities/vault_folder.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_event.dart';
import 'package:vaultx/features/vault/presentation/pages/folder_items_page.dart';

class FolderItem extends StatelessWidget {
  const FolderItem(this.folder, {super.key});
  final VaultFolder folder;

  @override
  Widget build(BuildContext context) {
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
          border: Border.all(
            color: VaultColors.textMuted.withValues(alpha: .05),
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VaultColors.primary.withValues(alpha: .1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(
                Icons.folder_shared,
                color: VaultColors.primary,
                size: 28,
              ),
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
            const Icon(
              Icons.chevron_right,
              color: VaultColors.textMuted,
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, VaultFolder folder) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VaultColors.cardBackground,
        title: Text(
          'Delete ${folder.name}?',
          style: const TextStyle(color: VaultColors.textPrimary),
        ),
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
            child: const Text(
              'Delete',
              style: TextStyle(color: VaultColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
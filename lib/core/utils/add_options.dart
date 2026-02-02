import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaultx/core/theme/vault_colors.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_event.dart';
import 'package:vaultx/features/vault/presentation/pages/create_secret_page.dart';
import 'package:vaultx/features/vault/presentation/widgets/add_item_sheet.dart';

class AddOptions {

  static void showAddOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => AddItemSheet(
        onNewSecret: () {
          Navigator.pop(context);
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CreateSecretPage()),
          );
        },
        onNewFolder: () {
          Navigator.pop(context);
          showCreateFolderDialog(context);
        },
        onImportFile: () {
          Navigator.pop(context);
        },
      ),
    );
  }

  static void showCreateFolderDialog(BuildContext context) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: VaultColors.cardBackground,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'New Folder',
          style: TextStyle(color: VaultColors.textPrimary),
        ),
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
            child: const Text(
              'Cancel',
              style: TextStyle(color: VaultColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                context.read<VaultBloc>().add(
                  CreateFolder(name: controller.text),
                );
                Navigator.pop(context);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: VaultColors.primary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: const Text('Create', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  

}
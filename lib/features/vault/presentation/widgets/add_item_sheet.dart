import 'package:flutter/material.dart';
import 'package:vaultx/core/theme/vault_colors.dart';

class AddItemSheet extends StatelessWidget {
  final VoidCallback onNewSecret;
  final VoidCallback onNewFolder;
  final VoidCallback onImportFile;

  const AddItemSheet({
    super.key,
    required this.onNewSecret,
    required this.onNewFolder,
    required this.onImportFile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      decoration: const BoxDecoration(
        color: VaultColors.background,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: VaultColors.textMuted.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Add New Item',
            style: TextStyle(
              color: VaultColors.textPrimary,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          _buildOption(
            icon: Icons.vpn_key,
            title: 'New Secret',
            subtitle: 'Save passwords, API keys, or passkeys',
            onTap: onNewSecret,
          ),
          const SizedBox(height: 12),
          _buildOption(
            icon: Icons.folder,
            title: 'New Folder',
            subtitle: 'Organize your credentials by category',
            onTap: onNewFolder,
          ),
          // const SizedBox(height: 12),
          // _buildOption(
          //   icon: Icons.file_upload_outlined,
          //   title: 'Import File',
          //   subtitle: 'Upload backup or encrypted files',
          //   onTap: onImportFile,
          // ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: TextButton(
              onPressed: () => Navigator.pop(context),
              style: TextButton.styleFrom(
                backgroundColor: VaultColors.cardBackground,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: VaultColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: VaultColors.cardBackground,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: VaultColors.primary,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: VaultColors.primary.withOpacity(0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: VaultColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
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
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}

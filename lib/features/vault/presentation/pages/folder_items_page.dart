import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaultx/core/theme/vault_colors.dart';
import 'package:vaultx/features/vault/domain/entities/vault_folder.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_event.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_state.dart';
import 'package:vaultx/features/vault/presentation/widgets/add_item_sheet.dart';
import 'package:vaultx/features/vault/presentation/pages/create_secret_page.dart';
import 'package:vaultx/features/vault/presentation/pages/vault_item_details_page.dart';

class FolderItemsPage extends StatefulWidget {
  final VaultFolder folder;

  const FolderItemsPage({super.key, required this.folder});

  @override
  State<FolderItemsPage> createState() => _FolderItemsPageState();
}

class _FolderItemsPageState extends State<FolderItemsPage> {
  @override
  void initState() {
    super.initState();
    context.read<VaultBloc>().add(FetchItems(folderId: widget.folder.id));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: VaultColors.primary, size: 28),
          label: const Text(
            'Folders',
            style: TextStyle(color: VaultColors.primary, fontSize: 16),
          ),
        ),
        leadingWidth: 100,
        title: Text(
          widget.folder.name,
          style: const TextStyle(
            color: VaultColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: VaultColors.textSecondary),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          Expanded(
            child: BlocBuilder<VaultBloc, VaultState>(
              builder: (context, state) {
                if (state is VaultLoading) {
                  return const Center(child: CircularProgressIndicator(color: VaultColors.primary));
                }

                if (state is VaultLoaded) {
                  final items = state.items;
                  if (items.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    itemCount: items.length,
                    itemBuilder: (context, index) {
                      final item = items[index];
                      return _buildItemRow(context, item);
                    },
                  );
                }

                if (state is VaultError) {
                  return Center(child: Text(state.message, style: const TextStyle(color: VaultColors.error)));
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

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: VaultColors.secondary.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.filter_list, color: VaultColors.textMuted, size: 20),
            const SizedBox(width: 12),
            Text(
              'Sorted by name',
              style: TextStyle(color: VaultColors.textMuted.withValues(alpha: 0.7), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildItemRow(BuildContext context, dynamic item) {
    // Determine icon and color based on title (mocking logic from main-page.png)
    IconData iconData = Icons.vpn_key;
    Color iconColor = VaultColors.primary;
    String type = 'API Key';

    if (item.title.toLowerCase().contains('github')) {
      iconData = Icons.fingerprint;
      iconColor = const Color(0xFF10B981);
      type = 'Passkey';
    } else if (item.title.toLowerCase().contains('recovery')) {
      iconData = Icons.security;
      iconColor = const Color(0xFFF59E0B);
      type = 'Recovery Codes';
    } else if (item.title.toLowerCase().contains('kubernetes') || item.title.toLowerCase().contains('config')) {
      iconData = Icons.terminal;
      iconColor = const Color(0xFF3B82F6);
      type = 'Secure Note';
    } else if (item.title.toLowerCase().contains('stripe')) {
      iconData = Icons.code;
      iconColor = const Color(0xFF8B5CF6);
      type = 'API Key';
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => VaultItemDetailsPage(title: item.title),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Row(
          children: [
            Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(iconData, color: iconColor, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: const TextStyle(
                      color: VaultColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Last modified: 2 days ago • $type',
                    style: const TextStyle(
                      color: VaultColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: VaultColors.textMuted, size: 20),
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
          Icon(Icons.folder_open, size: 64, color: VaultColors.textMuted.withValues(alpha: 0.5)),
          const SizedBox(height: 16),
          const Text(
            'This folder is empty',
            style: TextStyle(color: VaultColors.textSecondary, fontSize: 16),
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
              builder: (context) => CreateSecretPage(initialFolder: widget.folder),
            ),
          );
        },
        onNewFolder: () {
          Navigator.pop(context);
          // Show new folder dialog
        },
        onImportFile: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}

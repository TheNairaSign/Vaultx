import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaultx/core/theme/vault_colors.dart';
import 'package:vaultx/core/utils/add_options.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_event.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_state.dart';
import 'package:vaultx/features/vault/presentation/widgets/folder_item.dart';
import 'package:vaultx/features/vault/presentation/widgets/search_box.dart';

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
            onPressed: () => context.read<VaultBloc>().add(VaultLockRequested()),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SearchBox(),
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

                  if (folders.isEmpty) return _buildEmptyState();

                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    itemCount: folders.length,
                    itemBuilder: (context, index) => FolderItem(folders[index])
                  );
                }

                return const SizedBox.shrink();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => AddOptions.showAddOptions(context),
        backgroundColor: VaultColors.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        child: const Icon(Icons.add, color: Colors.white, size: 32),
      ),
    );
  }


  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.folder_outlined, size: 80, color: VaultColors.textMuted.withValues(alpha: .2)),
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
  
}

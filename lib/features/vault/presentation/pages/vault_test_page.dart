import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaultx/core/security/session/vault_session_manager.dart';
import 'package:vaultx/core/services/vault_service.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_event.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_state.dart';
import 'package:vaultx/features/vault/domain/entities/encrypted_item.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_repository.dart';

class VaultTestPage extends StatefulWidget {
  final VaultService vaultService;
  final SessionManager sessionManager;
  final VaultItemRepository repository;

  const VaultTestPage({
    super.key,
    required this.vaultService,
    required this.sessionManager,
    required this.repository,
  });

  @override
  State<VaultTestPage> createState() => _VaultTestPageState();
}

class _VaultTestPageState extends State<VaultTestPage> {
  final _passwordController = TextEditingController(text: 'password123'); // Default for testing
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  bool _vaultExists = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkVault();
    widget.sessionManager.addListener(_onSessionChanged);
  }

  @override
  void dispose() {
    widget.sessionManager.removeListener(_onSessionChanged);
    _passwordController.dispose();
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _onSessionChanged() {
    if (mounted) setState(() {});
    if (widget.sessionManager.isUnlocked) {
      context.read<VaultBloc>().add(FetchItems());
    }
  }

  Future<void> _checkVault() async {
    final exists = await widget.vaultService.vaultExists();
    if (mounted) {
      setState(() {
        _vaultExists = exists;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    if (!_vaultExists) return _buildSetupView();
    if (!widget.sessionManager.isUnlocked) return _buildUnlockView();

    return _buildDashboardView();
  }

  Widget _buildSetupView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Setup Vault')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock_outline, size: 80, color: Colors.blue),
            const SizedBox(height: 24),
            const Text('Create your master password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  await widget.vaultService.createVault(_passwordController.text);
                  await _checkVault();
                },
                child: const Text('Initialize Vault'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnlockView() {
    return Scaffold(
      appBar: AppBar(title: const Text('Unlock Vault')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.lock, size: 80, color: Colors.orange),
            const SizedBox(height: 24),
            const Text('Enter master password', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Password', border: OutlineInputBorder()),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await widget.vaultService.unlockWithPassword(_passwordController.text);
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                  }
                },
                child: const Text('Unlock'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDashboardView() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VaultX Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_open),
            onPressed: () => widget.sessionManager.lock(),
          ),
        ],
      ),
      body: BlocBuilder<VaultBloc, VaultState>(
        builder: (context, state) {
          if (state is VaultLoading) return const Center(child: CircularProgressIndicator());
          if (state is VaultError) return Center(child: Text('Error: ${state.message}'));
          if (state is VaultLoaded) {
            if (state.items.isEmpty) return const Center(child: Text('No secrets saved yet.'));
            return ListView.builder(
              itemCount: state.items.length,
              itemBuilder: (context, index) {
                final item = state.items[index];
                return ListTile(
                  title: Text(item.title),
                  subtitle: Text('Last updated: ${item.updatedAt.toLocal()}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: () => context.read<VaultBloc>().add(DeleteVaultItem(item.id)),
                  ),
                  onTap: () => _showDecryptedItem(item),
                );
              },
            );
          }
          return const Center(child: Text('Unknown State'));
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddItemDialog,
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddItemDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Secret'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: _titleController, decoration: const InputDecoration(labelText: 'Title')),
            TextField(controller: _contentController, decoration: const InputDecoration(labelText: 'Secret Content')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
          TextButton(
            onPressed: () {
              context.read<VaultBloc>().add(AddVaultItem(
                title: _titleController.text,
                content: _contentController.text,
              ));
              _titleController.clear();
              _contentController.clear();
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  void _showDecryptedItem(EncryptedItem item) async {
    try {
      final decrypted = await widget.repository.decryptItem(item);
      if (!mounted) return;
      showModalBottomSheet(
        context: context,
        builder: (context) => Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.title, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              const Text('Decrypted Content:', style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 8),
              SelectableText(decrypted, style: const TextStyle(fontSize: 18, color: Colors.blue)),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Decryption failed: $e')));
    }
  }
}

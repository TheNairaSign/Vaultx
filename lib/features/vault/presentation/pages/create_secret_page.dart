import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaultx/core/theme/vault_colors.dart';
import 'package:vaultx/features/vault/domain/entities/vault_folder.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_event.dart';

class CreateSecretPage extends StatefulWidget {
  final VaultFolder? initialFolder;

  const CreateSecretPage({super.key, this.initialFolder});

  @override
  State<CreateSecretPage> createState() => _CreateSecretPageState();
}

class _CreateSecretPageState extends State<CreateSecretPage> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  String _selectedType = 'One-liner';
  bool _isContentHidden = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: TextButton.icon(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.chevron_left, color: VaultColors.primary),
          label: Text(
            widget.initialFolder?.name ?? 'Back',
            style: const TextStyle(color: VaultColors.primary, fontSize: 16),
          ),
        ),
        leadingWidth: 120,
        title: const Text(
          'New Secret',
          style: TextStyle(
            color: VaultColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel('TITLE'),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _titleController,
              hint: 'e.g., AWS Production Key',
            ),
            const SizedBox(height: 24),
            _buildLabel('SECRET TYPE'),
            const SizedBox(height: 8),
            _buildDropdown(
              value: _selectedType,
              items: ['One-liner', 'Passkey', 'Multi-Block'],
              onChanged: (val) => setState(() => _selectedType = val!),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildLabel('CONTENT'),
                GestureDetector(
                  onTap: () => setState(() => _isContentHidden = !_isContentHidden),
                  child: Row(
                    children: [
                      Icon(
                        _isContentHidden ? Icons.visibility : Icons.visibility_off_outlined,
                        color: VaultColors.primary,
                        size: 16,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        _isContentHidden ? 'Show' : 'Hide',
                        style: const TextStyle(
                          color: VaultColors.primary,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildTextField(
              controller: _contentController,
              hint: 'Enter secret content...',
              maxLines: 6,
              obscureText: _isContentHidden,
              fontFamily: 'KeysFont',
            ),
            const SizedBox(height: 8),
            const Text(
              'Content is encrypted locally before storage.',
              style: TextStyle(
                color: VaultColors.textMuted,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 24),
            _buildLabel('FOLDER'),
            const SizedBox(height: 8),
            _buildFolderPicker(),
            const SizedBox(height: 40),
            _buildSaveButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: VaultColors.textSecondary,
        fontSize: 12,
        fontWeight: FontWeight.bold,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool obscureText = false,
    String? fontFamily,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VaultColors.textMuted.withValues(alpha: 0.2)),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        obscureText: obscureText,
        style: TextStyle(
          color: VaultColors.textPrimary,
          fontFamily: fontFamily,
        ),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: const TextStyle(color: VaultColors.textMuted),
          contentPadding: const EdgeInsets.all(16),
          border: InputBorder.none,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VaultColors.textMuted.withValues(alpha: 0.2)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          dropdownColor: VaultColors.cardBackground,
          icon: const Icon(Icons.swap_vert, color: VaultColors.textSecondary, size: 20),
          isExpanded: true,
          items: items.map((e) => DropdownMenuItem(
            value: e,
            child: Text(e, style: const TextStyle(color: VaultColors.textPrimary)),
          )).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _buildFolderPicker() {
    return Container(
      decoration: BoxDecoration(
        color: VaultColors.cardBackground.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: VaultColors.textMuted.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(right: BorderSide(color: VaultColors.textMuted.withValues(alpha: 0.1))),
            ),
            child: const Icon(Icons.folder_shared_outlined, color: VaultColors.textSecondary, size: 20),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                widget.initialFolder?.name ?? 'No Folder',
                style: const TextStyle(
                  color: VaultColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: VaultColors.secondary.withValues(alpha: 0.5),
              borderRadius: const BorderRadius.horizontal(right: Radius.circular(16)),
            ),
            child: const Icon(Icons.lock_outline, color: VaultColors.textMuted, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
            context.read<VaultBloc>().add(AddVaultItem(
              title: _titleController.text,
              content: _contentController.text,
              folderId: widget.initialFolder?.id,
            ));
            Navigator.pop(context);
          }
        },
        icon: const Icon(Icons.save_outlined),
        label: const Text('Save Secret'),
        style: ElevatedButton.styleFrom(
          backgroundColor: VaultColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 8,
          shadowColor: VaultColors.primary.withValues(alpha: 0.5),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}

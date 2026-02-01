import 'package:flutter/material.dart';
import 'package:vaultx/core/theme/vault_colors.dart';
import 'package:vaultx/features/vault/presentation/widgets/action_icon_button.dart';
import 'package:vaultx/features/vault/presentation/widgets/secret_container.dart';
import 'package:vaultx/features/vault/presentation/widgets/secret_type_selector.dart';
import 'package:vaultx/features/vault/presentation/widgets/vault_details_widgets.dart';

class VaultItemDetailsPage extends StatefulWidget {
  final String title;

  const VaultItemDetailsPage({
    super.key,
    this.title = 'GitHub Recovery Codes',
  });

  @override
  State<VaultItemDetailsPage> createState() => _VaultItemDetailsPageState();
}

class _VaultItemDetailsPageState extends State<VaultItemDetailsPage> {
  SecretFormat _selectedFormat = SecretFormat.passkey;
  bool _isLocked = true;
  double _clipboardProgress = 0.62;
  int _secondsRemaining = 25;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: VaultColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: VaultColors.textPrimary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.title,
          style: const TextStyle(
            color: VaultColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.star_outline, color: VaultColors.textPrimary),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            
            // Header Info
            _buildHeaderInfo(),
            
            const SizedBox(height: 32),
            
            // Secret Format Section
            const Text(
              'SECRET FORMAT',
              style: TextStyle(
                color: VaultColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            SecretTypeSelector(
              selectedFormat: _selectedFormat,
              onFormatChanged: (format) => setState(() => _selectedFormat = format),
            ),
            
            const SizedBox(height: 32),
            
            // Main Secret Container
            SecretContainer(
              isLocked: _isLocked,
              format: _selectedFormat,
              secretData: _getMockData(),
              onUnlockTap: () => setState(() => _isLocked = false),
            ),
            
            const SizedBox(height: 32),
            
            // Actions
            _buildActionsRow(),
            
            const SizedBox(height: 48),
            
            // Clipboard Timer
            ClipboardTimer(
              progress: _clipboardProgress,
              secondsRemaining: _secondsRemaining,
            ),
            
            const SizedBox(height: 48),
            
            // Metadata Section
            const Text(
              'METADATA',
              style: TextStyle(
                color: VaultColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 12),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 2.2,
              children: const [
                MetadataCard(
                  icon: Icons.calendar_today_outlined,
                  label: 'Created',
                  value: '2 days ago',
                ),
                MetadataCard(
                  icon: Icons.category_outlined,
                  label: 'Category',
                  value: 'Developer',
                ),
                MetadataCard(
                  icon: Icons.update,
                  label: 'Modified',
                  value: 'Today',
                ),
                MetadataCard(
                  icon: Icons.security,
                  label: 'Strength',
                  value: 'Strong',
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  Widget _buildHeaderInfo() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: VaultColors.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: const Icon(Icons.shield_outlined, color: VaultColors.primary),
        ),
        const SizedBox(width: 16),
        const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Vault Item',
              style: TextStyle(
                color: VaultColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'Last modified 2 days ago',
              style: TextStyle(
                color: VaultColors.textMuted,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionsRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ActionIconButton(
          icon: Icons.copy,
          label: 'Copy',
          onTap: () {},
        ),
        ActionIconButton(
          icon: _isLocked ? Icons.visibility : Icons.visibility_off,
          label: _isLocked ? 'Show' : 'Hide',
          onTap: () => setState(() => _isLocked = !_isLocked),
        ),
        ActionIconButton(
          icon: Icons.edit_outlined,
          label: 'Edit',
          onTap: () {},
        ),
        ActionIconButton(
          icon: Icons.share_outlined,
          label: 'Share',
          onTap: () {},
        ),
      ],
    );
  }

  Widget _buildBottomNav() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16),
      decoration: BoxDecoration(
        color: VaultColors.background,
        border: Border(
          top: BorderSide(
            color: VaultColors.textMuted.withOpacity(0.1),
            width: 1,
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.lock, 'Vault', true),
          _buildNavItem(Icons.search, 'Search', false),
          _buildNavItem(Icons.settings, 'Settings', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool active) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: active ? VaultColors.primary : VaultColors.textMuted,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            color: active ? VaultColors.primary : VaultColors.textMuted,
            fontSize: 11,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  String _getMockData() {
    switch (_selectedFormat) {
      case SecretFormat.oneLiner:
        return 'ghp_aBct1234XyzRst90QwePqwMnbVcxZlKj';
      case SecretFormat.passkey:
        return 'ABCD-1234 EFGH-5678 IJKL-9012 MNOP-3456 QRST-7890 UVWX-1234';
      case SecretFormat.multiBlock:
        return '-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEA75h7mJ...\n-----END RSA PRIVATE KEY-----';
    }
  }
}

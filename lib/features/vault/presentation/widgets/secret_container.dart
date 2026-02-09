import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vaultx/core/theme/vault_colors.dart';
import 'package:vaultx/features/vault/presentation/widgets/secret_renderers.dart';
import 'package:vaultx/features/vault/presentation/widgets/secret_type_selector.dart';

class SecretContainer extends StatelessWidget {
  final bool isLocked;
  final SecretFormat format;
  final String secretData;
  final VoidCallback onUnlockTap;

  const SecretContainer({
    super.key,
    required this.isLocked,
    required this.format,
    required this.secretData,
    required this.onUnlockTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: VaultColors.cardBackground,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: VaultColors.textMuted.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Content
              _buildContent(),

              // Blur Overlay
              if (isLocked)
                Positioned.fill(
                  child: GestureDetector(
                    onTap: onUnlockTap,
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                      child: Container(
                        color: VaultColors.lockOverlay,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: VaultColors.primary.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.fingerprint,
                                color: VaultColors.primary,
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'TAP TO UNLOCK',
                              style: TextStyle(
                                color: VaultColors.textPrimary,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildContent() {
    switch (format) {
      case SecretFormat.oneLiner:
        return OneLineRenderer(secret: secretData);
      case SecretFormat.passkey:
        final segments = secretData.split(' ');
        return PasskeyGrid(segments: segments, onSegmentTap: (_) {});
      case SecretFormat.multiBlock:
        final blocks = secretData.split('\n');
        return MultiBlockRenderer(blocks: blocks);
    }
  }
}

import 'package:flutter/material.dart';
import 'package:vaultx/core/theme/vault_colors.dart';

class MetadataCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const MetadataCard({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VaultColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: VaultColors.textMuted.withOpacity(0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(icon, color: VaultColors.textMuted, size: 20),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label.toUpperCase(),
                style: const TextStyle(
                  color: VaultColors.textMuted,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  color: VaultColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ClipboardTimer extends StatelessWidget {
  final double progress; // 0.0 to 1.0
  final int secondsRemaining;

  const ClipboardTimer({
    super.key,
    required this.progress,
    required this.secondsRemaining,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.timer_outlined, size: 16, color: VaultColors.primary),
                const SizedBox(width: 8),
                Text(
                  'Clipboard clears in ${secondsRemaining}s',
                  style: const TextStyle(
                    color: VaultColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                color: VaultColors.textMuted,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: progress,
            backgroundColor: VaultColors.secondary,
            valueColor: const AlwaysStoppedAnimation<Color>(VaultColors.primary),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

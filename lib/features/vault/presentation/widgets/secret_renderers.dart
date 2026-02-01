import 'package:flutter/material.dart';
import 'package:vaultx/core/theme/vault_colors.dart';

class OneLineRenderer extends StatelessWidget {
  final String secret;

  const OneLineRenderer({super.key, required this.secret});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Text(
        secret,
        style: const TextStyle(
          color: VaultColors.textPrimary,
          fontFamily: 'KeysFont',
          fontSize: 16,
          letterSpacing: 1.2,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }
}

class PasskeyGrid extends StatelessWidget {
  final List<String> segments;
  final Function(String) onSegmentTap;

  const PasskeyGrid({
    super.key,
    required this.segments,
    required this.onSegmentTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Wrap(
        spacing: 12,
        runSpacing: 12,
        alignment: WrapAlignment.center,
        children: segments.map((segment) => _buildSegment(segment)).toList(),
      ),
    );
  }

  Widget _buildSegment(String text) {
    return GestureDetector(
      onTap: () => onSegmentTap(text),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: VaultColors.secondary,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: VaultColors.textMuted.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.vpn_key_outlined, size: 14, color: VaultColors.textMuted),
            const SizedBox(width: 8),
            Text(
              text,
              style: const TextStyle(
                color: VaultColors.textPrimary,
                fontFamily: 'KeysFont',
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MultiBlockRenderer extends StatelessWidget {
  final List<String> blocks;

  const MultiBlockRenderer({super.key, required this.blocks});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: blocks.map((block) => _buildBlock(block)).toList(),
      ),
    );
  }

  Widget _buildBlock(String text) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: VaultColors.secondary,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: const TextStyle(
          color: VaultColors.textPrimary,
          fontFamily: 'KeysFont',
          fontSize: 13,
          height: 1.5,
        ),
      ),
    );
  }
}

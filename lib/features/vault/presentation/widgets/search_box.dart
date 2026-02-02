import 'package:flutter/material.dart';
import 'package:vaultx/core/theme/vault_colors.dart';

class SearchBox extends StatefulWidget {
  const SearchBox({super.key});

  @override
  State<SearchBox> createState() => _SearchBoxState();
}

class _SearchBoxState extends State<SearchBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: VaultColors.cardBackground,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: VaultColors.textMuted.withValues(alpha: .1)),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, color: VaultColors.textMuted, size: 20),
                const SizedBox(width: 12),
                Text(
                  'Search secrets...',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: VaultColors.textMuted, fontSize: 16),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
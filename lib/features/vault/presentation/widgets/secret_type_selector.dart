import 'package:flutter/material.dart';
import 'package:vaultx/core/theme/vault_colors.dart';

enum SecretFormat { oneLiner, passkey, multiBlock }

class SecretTypeSelector extends StatelessWidget {
  final SecretFormat selectedFormat;
  final ValueChanged<SecretFormat> onFormatChanged;

  const SecretTypeSelector({
    super.key,
    required this.selectedFormat,
    required this.onFormatChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: VaultColors.secondary,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: SecretFormat.values.map((format) {
          final isSelected = selectedFormat == format;
          return Expanded(
            child: GestureDetector(
              onTap: () => onFormatChanged(format),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                curve: Curves.easeInOut,
                padding: const EdgeInsets.symmetric(vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? VaultColors.cardBackground : Colors.transparent,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ]
                      : null,
                ),
                child: Center(
                  child: Text(
                    _getLabel(format),
                    style: TextStyle(
                      color: isSelected ? VaultColors.textPrimary : VaultColors.textSecondary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      fontSize: 13,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  String _getLabel(SecretFormat format) {
    switch (format) {
      case SecretFormat.oneLiner:
        return 'One-liner';
      case SecretFormat.passkey:
        return 'Passkey';
      case SecretFormat.multiBlock:
        return 'Multi-Block';
    }
  }
}

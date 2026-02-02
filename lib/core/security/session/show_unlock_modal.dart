import 'package:flutter/material.dart';
import 'package:vaultx/features/vault/presentation/widgets/unlock_modal.dart';

Future<void> showUnlockModal(BuildContext context) {
  return showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    isDismissible: false,
    enableDrag: false,
    builder: (context) => const UnlockModal(),
  );
}

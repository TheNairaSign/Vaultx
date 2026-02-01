import 'package:vaultx/core/security/session/vault_session_manager.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_repository.dart';

class UnlockVaultUsecase {
  final VaultRepository repository;

  UnlockVaultUsecase(SessionManager sessionManager, {required this.repository});

  Future<void> unlockOrInitialize({required String password}) async {
    final metadata = await repository.getVaultMetadata();

    if (metadata == null) {
      await repository.initializeVault(password: password);
    } else {
      await repository.unlockVault(password: password);
    }
  }
}

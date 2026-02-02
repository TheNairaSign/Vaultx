import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vaultx/core/security/session/vault_session_manager.dart';
import 'package:vaultx/core/services/vault_service.dart';
import 'package:vaultx/features/vault/data/repositories/vault_crypto_impl.dart';
import 'package:vaultx/features/vault/data/repositories/vault_repository_impl.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_repository.dart';
import 'package:vaultx/features/vault/domain/usecases/unlock_bloc_use_case.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';

// --- Base Dependencies ---

final secureStorageProvider = Provider<FlutterSecureStorage>((ref) {
  return const FlutterSecureStorage();
});

final cryptoProvider = Provider<VaultCryptoImpl>((ref) {
  return VaultCryptoImpl();
});

final sessionManagerProvider = ChangeNotifierProvider<SessionManager>((ref) {
  return SessionManager();
});

// --- Services ---

final vaultServiceProvider = Provider<VaultService>((ref) {
  return VaultService(
    ref.watch(cryptoProvider),
    ref.watch(sessionManagerProvider),
    ref.watch(secureStorageProvider),
  );
});

// --- Repositories ---

final vaultRepositoryImplProvider = Provider<VaultRepositoryImpl>((ref) {
  return VaultRepositoryImpl(
    sessionManager: ref.watch(sessionManagerProvider),
    encryptionService: ref.watch(cryptoProvider),
    secureStorage: ref.watch(secureStorageProvider),
  );
});

// Interface aliases
final vaultRepositoryProvider = Provider<VaultRepository>((ref) {
  return ref.watch(vaultRepositoryImplProvider);
});

final vaultItemRepositoryProvider = Provider<VaultItemRepository>((ref) {
  return ref.watch(vaultRepositoryImplProvider);
});

// --- Use Cases ---

final unlockVaultUsecaseProvider = Provider<UnlockVaultUsecase>((ref) {
  return UnlockVaultUsecase(
    ref.watch(sessionManagerProvider),
    repository: ref.watch(vaultRepositoryProvider),
  );
});

// --- BLoC ---

final vaultBlocProvider = Provider<VaultBloc>((ref) {
  return VaultBloc(
    itemRepository: ref.watch(vaultItemRepositoryProvider),
    vaultRepository: ref.watch(vaultRepositoryProvider),
    crypto: ref.watch(cryptoProvider),
    sessionManager: ref.watch(sessionManagerProvider),
    unlockVaultUsecase: ref.watch(unlockVaultUsecaseProvider),
  );
});

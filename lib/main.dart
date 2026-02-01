import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vaultx/core/security/session/session_lifecycle_observer.dart';
import 'package:vaultx/core/security/session/vault_session_manager.dart';
import 'package:vaultx/core/services/vault_service.dart';
import 'package:vaultx/features/vault/data/repositories/vault_crypto_impl.dart';
import 'package:vaultx/features/vault/data/repositories/vault_repository_impl.dart';
import 'package:vaultx/features/vault/domain/usecases/unlock_bloc_use_case.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:vaultx/features/vault/presentation/pages/vault_test_page.dart';

void main(List<String> args) {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const VaultX());
}

class VaultX extends StatefulWidget {
  const VaultX({super.key});

  @override
  State<VaultX> createState() => _VaultXState();
}

class _VaultXState extends State<VaultX> {
  late final SessionManager sessionManager;
  late final VaultCryptoImpl crypto;
  late final FlutterSecureStorage secureStorage;
  late final VaultService vaultService;
  late final VaultRepositoryImpl repository;
  late final UnlockVaultUsecase unlockVaultUsecase;

  @override
  void initState() {
    super.initState();
    sessionManager = SessionManager();
    crypto = VaultCryptoImpl();
    secureStorage = const FlutterSecureStorage();
    vaultService = VaultService(crypto, sessionManager, secureStorage);
    unlockVaultUsecase = UnlockVaultUsecase(sessionManager, repository: repository);
    repository = VaultRepositoryImpl(
      sessionManager: sessionManager,
      encryptionService: crypto,
      secureStorage: secureStorage,
    );

    WidgetsBinding.instance.addObserver(SessionLifecycleObserver(sessionManager));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => VaultBloc(
        repository: repository,
        crypto: crypto,
        sessionManager: sessionManager,
        unlockVaultUsecase: unlockVaultUsecase
      ),
      child: MaterialApp(
        title: 'VaultX',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        home: VaultTestPage(
          vaultService: vaultService,
          sessionManager: sessionManager,
          repository: repository,
        ),
      ),
    );
  }
}
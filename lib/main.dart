import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultx/core/di/injector.dart';
import 'package:vaultx/core/security/session/session_lifecycle_observer.dart';
import 'package:vaultx/features/vault/presentation/pages/vault_folders_page.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_event.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: VaultX(),
    ),
  );
}

class VaultX extends ConsumerStatefulWidget {
  const VaultX({super.key});

  @override
  ConsumerState<VaultX> createState() => _VaultXState();
}

class _VaultXState extends ConsumerState<VaultX> {
  @override
  void initState() {
    super.initState();
    // Initialize the lifecycle observer with the session manager from Riverpod
    final sessionManager = ref.read(sessionManagerProvider);
    WidgetsBinding.instance.addObserver(SessionLifecycleObserver(sessionManager));
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ref.watch(vaultBlocProvider)..add(FetchFolders()),
      child: MaterialApp(
        title: 'VaultX',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: const Color(0xFF0A0E14),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        home: const VaultFoldersPage(),
      ),
    );
  }
}
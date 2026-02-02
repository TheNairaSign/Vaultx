import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:vaultx/core/di/injector.dart';
import 'package:vaultx/core/security/session/session_lifecycle_observer.dart';
import 'package:vaultx/core/security/session/vault_session_manager.dart';
import 'package:vaultx/core/security/session/show_unlock_modal.dart';
import 'package:vaultx/core/utils/loading_widget.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_bloc.dart';
import 'package:vaultx/features/vault/presentation/pages/vault_folders_page.dart';
import 'package:vaultx/features/vault/presentation/pages/unlock_page.dart';
import 'package:vaultx/features/vault/presentation/pages/setup_vault_page.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_event.dart';
import 'package:vaultx/features/vault/presentation/bloc/vault_state.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: VaultX()));
}

class VaultX extends ConsumerStatefulWidget {
  const VaultX({super.key});

  @override
  ConsumerState<VaultX> createState() => _VaultXState();
}

class _VaultXState extends ConsumerState<VaultX> {
  
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  bool _isModalShowing = false;
  bool _hasUnlockedOnce = false;
  SessionLifecycleObserver? _lifecycleObserver;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    
    // Set up lifecycle observer only once
    if (_lifecycleObserver == null) {
      final sessionManager = ref.read(sessionManagerProvider);
      _lifecycleObserver = SessionLifecycleObserver(sessionManager);
      WidgetsBinding.instance.addObserver(_lifecycleObserver!);
    }
  }

  @override
  void dispose() {
    if (_lifecycleObserver != null) {
      WidgetsBinding.instance.removeObserver(_lifecycleObserver!);
    }
    super.dispose();
  }

  void _handleSessionStateChange(VaultSessionState? previous, VaultSessionState current) {
    // Track if user has unlocked at least once
    if (current == VaultSessionState.unlocked && !_hasUnlockedOnce) {
      setState(() {
        _hasUnlockedOnce = true;
      });
    }

    // Show modal when vault locks after being unlocked
    if (current == VaultSessionState.locked && _hasUnlockedOnce && !_isModalShowing) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final context = _navigatorKey.currentContext;
        if (context != null && mounted) {
          _isModalShowing = true;
          showUnlockModal(context).then((_) {
            if (mounted) {
              setState(() {
                _isModalShowing = false;
              });
            }
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final sessionState = ref.watch(sessionManagerProvider.select((s) => s.state));
    
    // Listen for session state changes
    ref.listen<VaultSessionState>(
      sessionManagerProvider.select((s) => s.state),
      (previous, next) => _handleSessionStateChange(previous, next),
    );

    return BlocProvider(
      create: (context) => ref.watch(vaultBlocProvider)..add(CheckInitializationStatus()),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'VaultX',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'PrimaryFont',
          scaffoldBackgroundColor: const Color(0xFF0A0E14),
          colorScheme: ColorScheme.fromSeed(
            seedColor: Colors.blue,
            brightness: Brightness.dark,
          ),
        ),
        home: BlocBuilder<VaultBloc, VaultState>(
          builder: (context, state) {
            if (state is VaultLoading && state is! VaultLoaded) {
              return const Scaffold(body: LoadingWidget());
            }

            if (state is VaultLocked) {
              return const UnlockPage();
            }

            if (state is VaultNeedsSetup) {
              return const SetupVaultPage();
            }

            return !_hasUnlockedOnce && sessionState == VaultSessionState.locked
                ? const UnlockPage() 
                : const VaultFoldersPage();
          },
        ),
      ),
    );
  }
}
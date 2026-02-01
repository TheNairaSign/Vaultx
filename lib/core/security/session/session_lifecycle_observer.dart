import 'package:flutter/widgets.dart';
import 'package:vaultx/core/security/session/vault_session_manager.dart';

class SessionLifecycleObserver extends WidgetsBindingObserver {
  final SessionManager sessionManager;

  SessionLifecycleObserver(this.sessionManager);

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.detached) {
      sessionManager.lock();
    }
  }
}

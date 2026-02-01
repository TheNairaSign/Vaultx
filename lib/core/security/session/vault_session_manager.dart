
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:cryptography/cryptography.dart';
import 'package:vaultx/exceptions/vault_locked_exception.dart';

enum VaultSessionState { locked, unlocked }

class SessionManager extends ChangeNotifier {
  SecretKey? _masterKey;

  Timer? _autoLockTimer;

  VaultSessionState _state = VaultSessionState.locked;

  // 🔒 Session configuration
  static const Duration autoLockDuration = Duration(minutes: 2);

  VaultSessionState get state => _state;

  bool get isUnlocked => _masterKey != null;

  // ------------------------------------------------
  // Unlock Session
  // ------------------------------------------------
  void unlock(SecretKey masterKey) {
    _masterKey = masterKey;
    _state = VaultSessionState.unlocked;

    _startAutoLockTimer();
    notifyListeners();
  }

  // ------------------------------------------------
  // Lock Session
  // ------------------------------------------------
  void lock() {
    _destroySensitiveMemory();

    _state = VaultSessionState.locked;
    notifyListeners();
  }

  // ------------------------------------------------
  // Require Master Key (Safe Access)
  // ------------------------------------------------
  SecretKey requireMasterKey() {
    if (_masterKey == null) {
      throw VaultLockedException();
    }

    _refreshAutoLockTimer();

    return _masterKey!;
  }

  // ------------------------------------------------
  // Auto Lock Timer
  // ------------------------------------------------
  void _startAutoLockTimer() {
    _autoLockTimer?.cancel();

    _autoLockTimer = Timer(autoLockDuration, () {
      lock();
    });
  }

  void _refreshAutoLockTimer() {
    if (!isUnlocked) return;

    _startAutoLockTimer();
  }

  // ------------------------------------------------
  // Memory Cleanup
  // ------------------------------------------------
  void _destroySensitiveMemory() {
    _autoLockTimer?.cancel();
    _autoLockTimer = null;

    _masterKey = null;
  }
}

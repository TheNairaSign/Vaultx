import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vaultx/core/security/session/vault_session_manager.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_crypto.dart';

class VaultService {
  final VaultCrypto _crypto;
  final SessionManager _sessionManager;
  final FlutterSecureStorage _secureStorage;

  VaultService(this._crypto, this._sessionManager, this._secureStorage);

  Future<bool> vaultExists() async {
    return await _secureStorage.containsKey(key: 'vault_salt');
  }

  Future<void> createVault(String password) async {
    if (await vaultExists()) {
      throw Exception('Vault already exists');
    }
    
    final random = Random.secure();
    final salt = Uint8List.fromList(List.generate(16, (_) => random.nextInt(256)));

    final keyBytes = await _crypto.deriveKey(password: password, salt: salt);

    await _secureStorage.write(key: 'vault_salt', value: base64.encode(salt));
    // We store the encrypted master key wrapped by biometrics later? 
    // For now, let's just use the password derivation.

    _sessionManager.unlock(SecretKey(keyBytes));
  }

  Future<void> unlockWithPassword(String password) async {
    final saltString = await _secureStorage.read(key: 'vault_salt');

    if (saltString == null) {
      throw Exception('Vault not found');
    }

    final salt = base64Decode(saltString);
    final keyBytes = await _crypto.deriveKey(password: password, salt: salt);

    _sessionManager.unlock(SecretKey(keyBytes));
  }

  Future<void> unlockWithBiometrics() async {
    final wrappedKey = await _secureStorage.read(key: 'wrapped_key');

    if (wrappedKey == null) {
      throw Exception('Biometric unlock unavailable');
    }

    final keyBytes = base64Decode(wrappedKey);

  }
}

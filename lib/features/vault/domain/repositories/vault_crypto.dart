import 'dart:typed_data';

import 'package:cryptography/cryptography.dart';
import 'package:vaultx/core/crypto/encrypted_payload.dart';

abstract class VaultCrypto {
  Uint8List generateSalt();
  
  Future<Uint8List> deriveKey({
    required String password,
    required Uint8List salt,
  });

  Future<EncryptedPayload> encrypt({
    required Uint8List key,
    required String plaintext,
  });

  Future<Uint8List> decrypt({
    required SecretKey key,
    required EncryptedPayload payload,
  });
}

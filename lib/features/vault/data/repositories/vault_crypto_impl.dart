import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';

import 'package:argon2/argon2.dart';
import 'package:cryptography/cryptography.dart';
import 'package:vaultx/core/crypto/encrypted_payload.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_crypto.dart';

class VaultCryptoImpl implements VaultCrypto {
  final _algorithm = AesGcm.with256bits(); // Could switch to XChaCha20Poly1305()

  @override
  Uint8List generateSalt() {
    final random = Random.secure();
    return Uint8List.fromList(List.generate(32, (_) => random.nextInt(256)));
  }

  /// Derives a 256-bit key from a password + salt using Argon2id
  @override
  Future<Uint8List> deriveKey({
    required String password,
    required Uint8List salt, // 16–32 bytes random per user/vault
  }) async {
    final argon2 = Argon2id(
      parallelism: 4,
      memory: 64 * 1024, // 64 MiB
      iterations: 12,
      hashLength: 32,
    );

    final key = await argon2.deriveKey(secretKey: SecretKey(utf8.encode(password)), nonce: salt);
    final keyBytes = await key.extractBytes();
    return keyBytes.toUint8List();
  }

  /// Encrypts plaintext with a given key. Generates a random nonce per encryption.
  @override
  Future<EncryptedPayload> encrypt({
    required Uint8List key,
    required String plaintext,
  }) async {
    final secretKey = SecretKey(key);

    // Generate a random nonce
    final nonce = _algorithm.newNonce();

    final secretBox = await _algorithm.encrypt(
      utf8.encode(plaintext),
      secretKey: secretKey,
      nonce: nonce,
    );

    return EncryptedPayload(
      ciphertext: secretBox.cipherText.toUint8List(),
      nonce: secretBox.nonce.toUint8List(),
      mac: secretBox.mac.bytes.toUint8List(),
    );
  }

  @override
  Future<Uint8List> decrypt({
    required SecretKey key,
    required EncryptedPayload payload,
  }) async {
    final secretBox = SecretBox(
      payload.ciphertext,
      nonce: payload.nonce,
      mac: Mac(payload.mac),
    );

    final clearBytes = await _algorithm.decrypt(
      secretBox,
      secretKey: key,
    );

    return Uint8List.fromList(clearBytes);
  }
 
}

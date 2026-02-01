import 'dart:typed_data';
import 'package:vaultx/core/crypto/encrypted_payload.dart';

class EncryptedItem {
  final String id;
  final String title;
  final Uint8List ciphertext;
  final Uint8List nonce;
  final Uint8List mac;
  final DateTime createdAt;
  final DateTime updatedAt;

  final String? folderId;

  EncryptedItem({
    required this.id,
    required this.title,
    required this.ciphertext,
    required this.nonce,
    required this.mac,
    required this.createdAt,
    required this.updatedAt,
    this.folderId,
  });

  EncryptedPayload toPayload() => EncryptedPayload(
    ciphertext: ciphertext,
    nonce: nonce,
    mac: mac,
  );

  factory EncryptedItem.fromPayload({
    required String id,
    required String title,
    required EncryptedPayload payload,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? folderId,
  }) {
    final now = DateTime.now();
    return EncryptedItem(
      id: id,
      title: title,
      ciphertext: payload.ciphertext,
      nonce: payload.nonce,
      mac: payload.mac,
      createdAt: createdAt ?? now,
      updatedAt: updatedAt ?? now,
      folderId: folderId,
    );
  }
}

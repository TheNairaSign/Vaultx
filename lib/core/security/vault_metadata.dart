import 'dart:typed_data';

class VaultMetadata {
  final Uint8List salt;
  final DateTime createdAt;

  VaultMetadata({
    required this.salt,
    required this.createdAt,
  });
}

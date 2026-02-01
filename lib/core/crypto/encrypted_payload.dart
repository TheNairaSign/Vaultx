import 'dart:typed_data';

class EncryptedPayload {
  final Uint8List ciphertext;
  final Uint8List nonce;
  final Uint8List mac; // for AEAD integrity

  EncryptedPayload({
    required this.ciphertext,
    required this.nonce,
    required this.mac,
  });

  /// Serializes the payload to a byte list: [nonceLen, nonce, macLen, mac, ciphertext]
  Uint8List toUint8List() {
    final builder = BytesBuilder();
    builder.addByte(nonce.length);
    builder.add(nonce);
    builder.addByte(mac.length);
    builder.add(mac);
    builder.add(ciphertext);
    return builder.takeBytes();
  }

  /// Deserializes the payload from a dynamic list (usually Uint8List or List<int>)
  factory EncryptedPayload.fromList(List<int> data) {
    final bytes = Uint8List.fromList(data);
    int offset = 0;
    
    final nonceLen = bytes[offset++];
    final nonce = bytes.sublist(offset, offset + nonceLen);
    offset += nonceLen;
    
    final macLen = bytes[offset++];
    final mac = bytes.sublist(offset, offset + macLen);
    offset += macLen;
    
    final ciphertext = bytes.sublist(offset);
    
    return EncryptedPayload(
      ciphertext: ciphertext,
      nonce: nonce,
      mac: mac,
    );
  }
}

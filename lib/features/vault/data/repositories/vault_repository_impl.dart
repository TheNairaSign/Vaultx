import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:vaultx/core/security/session/vault_session_manager.dart';
import 'package:vaultx/core/security/vault_metadata.dart';
import 'package:vaultx/features/vault/data/repositories/vault_crypto_impl.dart';
import 'package:vaultx/features/vault/domain/entities/encrypted_item.dart';
import 'package:vaultx/features/vault/domain/entities/vault_folder.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_repository.dart';

class VaultRepositoryImpl implements VaultRepository, VaultItemRepository {
  final SessionManager sessionManager;
  final VaultCryptoImpl encryptionService;
  final FlutterSecureStorage secureStorage;

  static const String _itemsKey = 'vault_items_list';
  static const String _foldersKey = 'vault_folders_list';
  static const String _saltKey = 'vault_salt';
  static const String _createdKey = 'vault_created_at';

  VaultRepositoryImpl({
    required this.sessionManager,
    required this.encryptionService,
    required this.secureStorage,
  });

  @override
  Future<VaultMetadata?> getVaultMetadata() async {
    final saltBase64 = await secureStorage.read(key: _saltKey);
    final createdAtStr = await secureStorage.read(key: _createdKey);
    if (saltBase64 == null || createdAtStr == null) return null;
    return VaultMetadata(
      salt: base64Decode(saltBase64),
      createdAt: DateTime.parse(createdAtStr),
    );
  }

  @override
  Future<void> initializeVault({required String password}) async {
    // 1. Generate a new salt
    final salt = encryptionService.generateSalt();
    // 2. Derive the key (to verify it works and unlock immediately)
    final keyBytes = await encryptionService.deriveKey(
      password: password,
      salt: salt,
    );
    // 3. Save salt and metadata to secure storage
    await secureStorage.write(key: _saltKey, value: base64Encode(salt));
    await secureStorage.write(
      key: _createdKey,
      value: DateTime.now().toIso8601String(),
    );
    // 4. Unlock the session immediately
    sessionManager.unlock(SecretKey(keyBytes));
  }

  @override
  Future<void> unlockVault({required String password}) async {
    // 1. Get existing metadata
    final metadata = await getVaultMetadata();
    if (metadata == null) {
      throw Exception('Vault not initialized');
    }

    // 2. Re-derive the key using stored salt
    final keyBytes = await encryptionService.deriveKey(
      password: password,
      salt: metadata.salt,
    );

    // 3. Unlock session
    sessionManager.unlock(SecretKey(keyBytes));
  }

  @override
  Future<List<EncryptedItem>> getItems({String? folderId}) async {
    final data = await secureStorage.read(key: _itemsKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    
    final List<EncryptedItem> items = [];
    for (final id in jsonList) {
      final itemData = await secureStorage.read(key: 'vault_item_$id');
      if (itemData != null) {
        final map = json.decode(itemData);
        final item = EncryptedItem(
          id: id,
          title: map['title'],
          ciphertext: base64Decode(map['ciphertext']),
          nonce: base64Decode(map['nonce']),
          mac: base64Decode(map['mac']),
          createdAt: DateTime.parse(map['createdAt']),
          updatedAt: DateTime.parse(map['updatedAt']),
          folderId: map['folderId'],
        );
        
        // Filter by folderId if provided
        if (folderId == null || item.folderId == folderId) {
          items.add(item);
        }
      }
    }
    return items;
  }

  @override
  Future<void> saveItem(EncryptedItem item) async {
    final itemData = json.encode({
      'title': item.title,
      'ciphertext': base64Encode(item.ciphertext),
      'nonce': base64Encode(item.nonce),
      'mac': base64Encode(item.mac),
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': item.updatedAt.toIso8601String(),
      'folderId': item.folderId,
    });

    await secureStorage.write(key: 'vault_item_${item.id}', value: itemData);

    // Efficiently update the list of IDs without fetching all items
    final currentListJson = await secureStorage.read(key: _itemsKey) ?? '[]';
    final List<dynamic> ids = json.decode(currentListJson);

    if (!ids.contains(item.id)) {
      ids.add(item.id);
      await secureStorage.write(key: _itemsKey, value: json.encode(ids));
    }
  }

  @override
  Future<void> deleteItem(String id) async {
    await secureStorage.delete(key: 'vault_item_$id');
    
    final currentList = (await secureStorage.read(key: _itemsKey)) ?? '[]';
    final List<dynamic> ids = json.decode(currentList);
    ids.remove(id);
    await secureStorage.write(key: _itemsKey, value: json.encode(ids));
  }

  @override
  Future<String> decryptItem(EncryptedItem item) async {
    final masterKey = sessionManager.requireMasterKey();
    
    final decryptedBytes = await encryptionService.decrypt(
      key: masterKey,
      payload: item.toPayload(),
    );
    
    return utf8.decode(decryptedBytes);
  }

  @override
  Future<void> updateItem(EncryptedItem item) async {
    final itemData = json.encode({
      'title': item.title,
      'ciphertext': base64Encode(item.ciphertext),
      'nonce': base64Encode(item.nonce),
      'mac': base64Encode(item.mac),
      'createdAt': item.createdAt.toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'folderId': item.folderId,
    });

    await secureStorage.write(key: 'vault_item_${item.id}', value: itemData);
  }

  // --- Folder Operations ---

  @override
  Future<List<VaultFolder>> getFolders() async {
    final data = await secureStorage.read(key: _foldersKey);
    if (data == null) return [];

    final List<dynamic> jsonList = json.decode(data);
    final List<VaultFolder> folders = [];

    for (final id in jsonList) {
      final folderData = await secureStorage.read(key: 'vault_folder_$id');
      if (folderData != null) {
        folders.add(VaultFolder.fromJson(json.decode(folderData)));
      }
    }
    return folders;
  }

  @override
  Future<void> saveFolder(VaultFolder folder) async {
    final folderData = json.encode(folder.toJson());
    await secureStorage.write(key: 'vault_folder_${folder.id}', value: folderData);

    final currentListJson = await secureStorage.read(key: _foldersKey) ?? '[]';
    final List<dynamic> ids = json.decode(currentListJson);

    if (!ids.contains(folder.id)) {
      ids.add(folder.id);
      await secureStorage.write(key: _foldersKey, value: json.encode(ids));
    }
  }

  @override
  Future<void> deleteFolder(String id) async {
    await secureStorage.delete(key: 'vault_folder_$id');

    final currentList = await secureStorage.read(key: _foldersKey) ?? '[]';
    final List<dynamic> ids = json.decode(currentList);
    ids.remove(id);
    await secureStorage.write(key: _foldersKey, value: json.encode(ids));

    // Optional: Dissociate items from this folder (set their folderId to null)
    final items = await getItems(folderId: id);
    for (final item in items) {
      final updatedItem = EncryptedItem(
        id: item.id,
        title: item.title,
        ciphertext: item.ciphertext,
        nonce: item.nonce,
        mac: item.mac,
        createdAt: item.createdAt,
        updatedAt: item.updatedAt,
        folderId: null,
      );
      await saveItem(updatedItem);
    }
  }
}

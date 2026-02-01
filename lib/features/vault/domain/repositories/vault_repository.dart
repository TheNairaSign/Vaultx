import 'package:vaultx/core/security/vault_metadata.dart';
import 'package:vaultx/features/vault/domain/entities/encrypted_item.dart';
import 'package:vaultx/features/vault/domain/entities/vault_folder.dart';

abstract class VaultRepository {
  Future<void> initializeVault({required String password});
  Future<VaultMetadata?> getVaultMetadata();
  Future<void> unlockVault({required String password});
}

abstract class VaultItemRepository {
  Future<List<EncryptedItem>> getItems({String? folderId});
  Future<void> saveItem(EncryptedItem item);
  Future<void> deleteItem(String id);
  Future<String> decryptItem(EncryptedItem item);
  Future<void> updateItem(EncryptedItem item);

  // Folder operations
  Future<List<VaultFolder>> getFolders();
  Future<void> saveFolder(VaultFolder folder);
  Future<void> deleteFolder(String id);
}


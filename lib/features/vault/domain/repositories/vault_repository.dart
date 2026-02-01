import 'package:vaultx/core/security/vault_metadata.dart';
import 'package:vaultx/features/vault/domain/entities/encrypted_item.dart';

abstract class VaultRepository {
  Future<void> initializeVault({required String password});
  Future<VaultMetadata?> getVaultMetadata();
  Future<void> unlockVault({required String password});
}

abstract class VaultItemRepository {
  Future<List<EncryptedItem>> getItems();
  Future<void> saveItem(EncryptedItem item);
  Future<void> deleteItem(String id);
  Future<String> decryptItem(EncryptedItem item);
  Future<void> updateItem(EncryptedItem item);
}


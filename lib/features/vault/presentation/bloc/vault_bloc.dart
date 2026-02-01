import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaultx/core/security/session/vault_session_manager.dart';
import 'package:vaultx/features/vault/domain/entities/encrypted_item.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_crypto.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_repository.dart';
import 'package:vaultx/features/vault/domain/usecases/unlock_bloc_use_case.dart';
import 'vault_event.dart';
import 'vault_state.dart';

class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final VaultItemRepository repository;
  final VaultCrypto crypto;
  final SessionManager sessionManager;
  final UnlockVaultUsecase unlockVaultUsecase;

  VaultBloc({
    required this.repository,
    required this.crypto,
    required this.sessionManager,
    required this.unlockVaultUsecase,
  }) : super(VaultInitial()) {
    on<FetchItems>(_onFetchItems);
    on<AddVaultItem>(_onAddItem);
    on<DeleteVaultItem>(_onDeleteItem);
    on<UnlockVaultRequested>(_onUnlockVaultRequested);
  }

  Future<void> _onFetchItems(FetchItems event, Emitter<VaultState> emit) async {
    emit(VaultLoading());
    try {
      final items = await repository.getItems();
      emit(VaultLoaded(items));
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onAddItem(AddVaultItem event, Emitter<VaultState> emit) async {
    try {
      final masterKey = sessionManager.requireMasterKey();
      final keyBytes = await masterKey.extractBytes();
      
      final payload = await crypto.encrypt(
        key: Uint8List.fromList(keyBytes),
        plaintext: event.content,
      );

      final item = EncryptedItem.fromPayload(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        payload: payload,
      );

      await repository.saveItem(item);
      add(FetchItems());
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onDeleteItem(DeleteVaultItem event, Emitter<VaultState> emit) async {
    try {
      await repository.deleteItem(event.id);
      add(FetchItems());
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onUnlockVaultRequested(UnlockVaultRequested event, Emitter<VaultState> emit) async {
    emit(VaultLoading());
    try {
      await unlockVaultUsecase.unlockOrInitialize(password: event.password);
      add(FetchItems());
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }
}

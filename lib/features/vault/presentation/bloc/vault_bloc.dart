import 'dart:typed_data';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:vaultx/core/security/session/vault_session_manager.dart';
import 'package:vaultx/features/vault/domain/entities/encrypted_item.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_crypto.dart';
import 'package:vaultx/features/vault/domain/repositories/vault_repository.dart';
import 'package:vaultx/features/vault/domain/usecases/unlock_bloc_use_case.dart';
import 'vault_event.dart';
import 'vault_state.dart';

import 'package:vaultx/features/vault/domain/entities/vault_folder.dart';
import 'dart:developer' as developer;

class VaultBloc extends Bloc<VaultEvent, VaultState> {
  final VaultItemRepository itemRepository;
  final VaultRepository vaultRepository;
  final VaultCrypto crypto;
  final SessionManager sessionManager;
  final UnlockVaultUsecase unlockVaultUsecase;

  VaultBloc({
    required this.itemRepository,
    required this.vaultRepository,
    required this.crypto,
    required this.sessionManager,
    required this.unlockVaultUsecase,
  }) : super(VaultInitial()) {
    on<FetchItems>(_onFetchItems);
    on<FetchFolders>(_onFetchFolders);
    on<CreateFolder>(_onCreateFolder);
    on<DeleteFolder>(_onDeleteFolder);
    on<AddVaultItem>(_onAddItem);
    on<DeleteVaultItem>(_onDeleteItem);
    on<UnlockVaultRequested>(_onUnlockVaultRequested);
    on<CheckInitializationStatus>(_onCheckInitializationStatus);
    on<VaultLockRequested>(_onLockVaultRequest);
  }

  Future<void> _onCheckInitializationStatus(CheckInitializationStatus event, Emitter<VaultState> emit) async {
    emit(VaultLoading());
    try {
      final metadata = await vaultRepository.getVaultMetadata();
      if (metadata == null) {
        emit(VaultNeedsSetup());
      } else {
        emit(VaultInitial());
      }
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onLockVaultRequest(VaultLockRequested event, Emitter<VaultState> emit) async {
    emit(VaultLoading());

    try {
      sessionManager.lock();
      emit(VaultLocked());
    } catch (e) {
      developer.log('Lock vault error: $e', name: 'VaultBloc');
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onFetchItems(FetchItems event, Emitter<VaultState> emit) async {
    final List<VaultFolder> currentFolders = state is VaultLoaded ? (state as VaultLoaded).folders : [];
    emit(VaultLoading());
    try {
      final items = await itemRepository.getItems(folderId: event.folderId);
      final folders = currentFolders.isEmpty ? await itemRepository.getFolders() : currentFolders;
      emit(VaultLoaded(items: items, folders: folders));
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onFetchFolders(FetchFolders event, Emitter<VaultState> emit) async {
    final List<EncryptedItem> currentItems = state is VaultLoaded ? (state as VaultLoaded).items : [];
    emit(VaultLoading());
    try {
      final folders = await itemRepository.getFolders();
      emit(VaultLoaded(items: currentItems, folders: folders));
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onCreateFolder(CreateFolder event, Emitter<VaultState> emit) async {
    try {
      final folder = VaultFolder(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: event.name,
        createdAt: DateTime.now(),
        icon: event.icon,
      );
      await itemRepository.saveFolder(folder);
      add(FetchFolders());
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onDeleteFolder(DeleteFolder event, Emitter<VaultState> emit) async {
    try {
      await itemRepository.deleteFolder(event.id);
      add(FetchFolders());
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

      developer.log('Encrypted payload: ${payload.toString()}');

      final item = EncryptedItem.fromPayload(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        title: event.title,
        payload: payload,
        folderId: event.folderId,
      );

      developer.log('Encrypted item: ${item.toString()}');

      await itemRepository.saveItem(item);
      add(FetchItems(folderId: event.folderId));
    } catch (e) {
      developer.log("Error adding item $e", name: "VaultBloc");
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onDeleteItem(DeleteVaultItem event, Emitter<VaultState> emit) async {
    try {
      final String? currentFolderId = state is VaultLoaded ? (state as VaultLoaded).items.firstWhere((item) => item.id == event.id).folderId : null;
      await itemRepository.deleteItem(event.id);
      add(FetchItems(folderId: currentFolderId));
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }

  Future<void> _onUnlockVaultRequested(UnlockVaultRequested event, Emitter<VaultState> emit) async {
    emit(VaultLoading());
    try {
      await unlockVaultUsecase.unlockOrInitialize(password: event.password);
      // After unlocking, fetch both folders and items
      final folders = await itemRepository.getFolders();
      final items = await itemRepository.getItems();
      emit(VaultLoaded(items: items, folders: folders));
    } catch (e) {
      emit(VaultError(e.toString()));
    }
  }
}

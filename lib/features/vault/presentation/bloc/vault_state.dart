import 'package:equatable/equatable.dart';
import 'package:vaultx/features/vault/domain/entities/encrypted_item.dart';
import 'package:vaultx/features/vault/domain/entities/vault_folder.dart';

abstract class VaultState extends Equatable {
  const VaultState();

  @override
  List<Object?> get props => [];
}

class VaultInitial extends VaultState {}

class VaultLoading extends VaultState {}

class VaultLoaded extends VaultState {
  final List<EncryptedItem> items;
  final List<VaultFolder> folders;

  const VaultLoaded({this.items = const [], this.folders = const []});

  @override
  List<Object?> get props => [items, folders];

  VaultLoaded copyWith({
    List<EncryptedItem>? items,
    List<VaultFolder>? folders,
  }) {
    return VaultLoaded(
      items: items ?? this.items,
      folders: folders ?? this.folders,
    );
  }
}

class VaultError extends VaultState {
  final String message;

  const VaultError(this.message);

  @override
  List<Object?> get props => [message];
}

import 'package:equatable/equatable.dart';
import 'package:vaultx/features/vault/domain/entities/encrypted_item.dart';

abstract class VaultState extends Equatable {
  const VaultState();

  @override
  List<Object?> get props => [];
}

class VaultInitial extends VaultState {}

class VaultLoading extends VaultState {}

class VaultLoaded extends VaultState {
  final List<EncryptedItem> items;

  const VaultLoaded(this.items);

  @override
  List<Object?> get props => [items];
}

class VaultError extends VaultState {
  final String message;

  const VaultError(this.message);

  @override
  List<Object?> get props => [message];
}

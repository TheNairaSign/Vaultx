import 'package:equatable/equatable.dart';

abstract class VaultEvent extends Equatable {
  const VaultEvent();

  @override
  List<Object?> get props => [];
}

class FetchItems extends VaultEvent {}

class AddVaultItem extends VaultEvent {
  final String title;
  final String content;

  const AddVaultItem({required this.title, required this.content});

  @override
  List<Object?> get props => [title, content];
}

class DeleteVaultItem extends VaultEvent {
  final String id;

  const DeleteVaultItem(this.id);

  @override
  List<Object?> get props => [id];
}

class UnlockVaultRequested extends VaultEvent {
  final String password;

  const UnlockVaultRequested({required this.password});

  @override
  List<Object?> get props => [password];
}

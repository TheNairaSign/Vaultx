import 'package:equatable/equatable.dart';

abstract class VaultEvent extends Equatable {
  const VaultEvent();

  @override
  List<Object?> get props => [];
}

class CheckInitializationStatus extends VaultEvent {}

class FetchItems extends VaultEvent {
  final String? folderId;
  const FetchItems({this.folderId});

  @override
  List<Object?> get props => [folderId];
}

class FetchFolders extends VaultEvent {}

class VaultLockRequested extends VaultEvent {}

class CreateFolder extends VaultEvent {
  final String name;
  final String? icon;

  const CreateFolder({required this.name, this.icon});

  @override
  List<Object?> get props => [name, icon];
}

class DeleteFolder extends VaultEvent {
  final String id;
  const DeleteFolder(this.id);

  @override
  List<Object?> get props => [id];
}

class AddVaultItem extends VaultEvent {
  final String title;
  final String content;
  final String? folderId;

  const AddVaultItem({
    required this.title, 
    required this.content,
    this.folderId,
  });

  @override
  List<Object?> get props => [title, content, folderId];
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

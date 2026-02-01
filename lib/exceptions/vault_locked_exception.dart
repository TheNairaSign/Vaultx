class VaultLockedException implements Exception {
  final String message;

  VaultLockedException({this.message = 'Vault is locked'});

  @override
  String toString() => 'VaultLockedException: $message';
}


class VaultNotFoundException implements Exception {
  final String message;

  VaultNotFoundException({this.message = 'Vault not found'});

  @override
  String toString() => 'VaultNotFoundException: $message';
}
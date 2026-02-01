class VaultFolder {
  final String id;
  final String name;
  final DateTime createdAt;
  final String? icon; // Optional icon name for the folder

  VaultFolder({
    required this.id,
    required this.name,
    required this.createdAt,
    this.icon,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdAt': createdAt.toIso8601String(),
    'icon': icon,
  };

  factory VaultFolder.fromJson(Map<String, dynamic> json) => VaultFolder(
    id: json['id'],
    name: json['name'],
    createdAt: DateTime.parse(json['createdAt']),
    icon: json['icon'],
  );
}

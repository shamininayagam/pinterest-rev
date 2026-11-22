class Board {
  final String id;
  final String name;
  final String description;
  final String? coverPinId;
  final bool isPrivate;
  final DateTime createdAt;

  const Board({
    required this.id,
    required this.name,
    required this.description,
    this.coverPinId,
    required this.isPrivate,
    required this.createdAt,
  });

  factory Board.fromJson(Map<String, dynamic> json) {
    return Board(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? 'Untitled Board',
      description: json['description'] as String? ?? '',
      coverPinId: json['coverPinId'] as String?,
      isPrivate: json['isPrivate'] as bool? ?? false,
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'coverPinId': coverPinId,
      'isPrivate': isPrivate,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  Board copyWith({
    String? id,
    String? name,
    String? description,
    String? coverPinId,
    bool? isPrivate,
    DateTime? createdAt,
  }) {
    return Board(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      coverPinId: coverPinId ?? this.coverPinId,
      isPrivate: isPrivate ?? this.isPrivate,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

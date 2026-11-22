class Author {
  final String name;
  final String handle;
  final String avatar;

  const Author({
    required this.name,
    required this.handle,
    required this.avatar,
  });

  factory Author.fromJson(Map<String, dynamic> json) {
    return Author(
      name: json['name'] as String? ?? 'Creator',
      handle: json['handle'] as String? ?? 'creator',
      avatar: json['avatar'] as String? ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'handle': handle,
      'avatar': avatar,
    };
  }
}

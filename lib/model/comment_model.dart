class Comment {
  final String id;
  final String author;
  final String avatar;
  final String text;
  final String time;

  const Comment({
    required this.id,
    required this.author,
    required this.avatar,
    required this.text,
    required this.time,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as String? ?? '',
      author: json['author'] as String? ?? 'User',
      avatar: json['avatar'] as String? ??
          'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
      text: json['text'] as String? ?? '',
      time: json['time'] as String? ?? 'just now',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'author': author,
      'avatar': avatar,
      'text': text,
      'time': time,
    };
  }
}

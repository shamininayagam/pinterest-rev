import 'author_model.dart';
import 'comment_model.dart';

class Pin {
  final String id;
  final String title;
  final String description;
  final String imageUrl;
  final double aspectRatio; // height / width
  final String dominantColor;
  final Author author;
  final String? link;
  final String boardId;
  final String category;
  final int likesCount;
  final List<String> tags;
  final List<Comment> comments;
  final bool isLive;

  const Pin({
    required this.id,
    required this.title,
    required this.description,
    required this.imageUrl,
    required this.aspectRatio,
    required this.dominantColor,
    required this.author,
    this.link,
    required this.boardId,
    required this.category,
    required this.likesCount,
    required this.tags,
    required this.comments,
    this.isLive = false,
  });

  factory Pin.fromJson(Map<String, dynamic> json) {
    return Pin(
      id: json['id'] as String? ?? '',
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      aspectRatio: (json['aspectRatio'] as num?)?.toDouble() ?? 1.3,
      dominantColor: json['dominantColor'] as String? ?? '#E2E8F0',
      author: json['author'] != null
          ? Author.fromJson(json['author'] as Map<String, dynamic>)
          : const Author(
              name: 'Creator',
              handle: 'creator',
              avatar: 'https://images.unsplash.com/photo-1534528741775-53994a69daeb?auto=format&fit=crop&w=150&q=80',
            ),
      link: json['link'] as String?,
      boardId: json['boardId'] as String? ?? 'board-1',
      category: json['category'] as String? ?? 'General',
      likesCount: (json['likesCount'] as num?)?.toInt() ?? 0,
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e.toString()).toList() ?? [],
      comments: (json['comments'] as List<dynamic>?)
              ?.map((e) => Comment.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      isLive: json['isLive'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'imageUrl': imageUrl,
      'aspectRatio': aspectRatio,
      'dominantColor': dominantColor,
      'author': author.toJson(),
      'link': link,
      'boardId': boardId,
      'category': category,
      'likesCount': likesCount,
      'tags': tags,
      'comments': comments.map((c) => c.toJson()).toList(),
      'isLive': isLive,
    };
  }

  Pin copyWith({
    String? id,
    String? title,
    String? description,
    String? imageUrl,
    double? aspectRatio,
    String? dominantColor,
    Author? author,
    String? link,
    String? boardId,
    String? category,
    int? likesCount,
    List<String>? tags,
    List<Comment>? comments,
    bool? isLive,
  }) {
    return Pin(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
      aspectRatio: aspectRatio ?? this.aspectRatio,
      dominantColor: dominantColor ?? this.dominantColor,
      author: author ?? this.author,
      link: link ?? this.link,
      boardId: boardId ?? this.boardId,
      category: category ?? this.category,
      likesCount: likesCount ?? this.likesCount,
      tags: tags ?? this.tags,
      comments: comments ?? this.comments,
      isLive: isLive ?? this.isLive,
    );
  }
}

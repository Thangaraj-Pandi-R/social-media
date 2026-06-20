class PostEntity {
  final String id;
  final String authorId;
  final String authorName;
  final String authorPic;
  final String content;
  final String? imageUrl;
  final List<String> likes;
  final int commentCount;
  final DateTime createdAt;

  const PostEntity({
    required this.id,
    required this.authorId,
    required this.authorName,
    required this.authorPic,
    required this.content,
    this.imageUrl,
    required this.likes,
    required this.commentCount,
    required this.createdAt,
  });

  PostEntity copyWith({
    String? id,
    String? authorId,
    String? authorName,
    String? authorPic,
    String? content,
    String? imageUrl,
    List<String>? likes,
    int? commentCount,
    DateTime? createdAt,
  }) {
    return PostEntity(
      id: id ?? this.id,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPic: authorPic ?? this.authorPic,
      content: content ?? this.content,
      imageUrl: imageUrl ?? this.imageUrl,
      likes: likes ?? this.likes,
      commentCount: commentCount ?? this.commentCount,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

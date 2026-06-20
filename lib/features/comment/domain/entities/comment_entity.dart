class CommentEntity {
  final String id;
  final String postId;
  final String authorId;
  final String authorName;
  final String authorPic;
  final String content;
  final DateTime createdAt;

  const CommentEntity({
    required this.id,
    required this.postId,
    required this.authorId,
    required this.authorName,
    required this.authorPic,
    required this.content,
    required this.createdAt,
  });

  CommentEntity copyWith({
    String? id,
    String? postId,
    String? authorId,
    String? authorName,
    String? authorPic,
    String? content,
    DateTime? createdAt,
  }) {
    return CommentEntity(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      authorId: authorId ?? this.authorId,
      authorName: authorName ?? this.authorName,
      authorPic: authorPic ?? this.authorPic,
      content: content ?? this.content,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

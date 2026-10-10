class PostModel {
  final String id;
  final String userId;
  final String username;
  final String? userPhotoUrl;
  final String content;
  final String? imageUrl;
  final int likes;
  final DateTime createdAt;

  PostModel({
    required this.id,
    required this.userId,
    required this.username,
    this.userPhotoUrl,
    required this.content,
    this.imageUrl,
    this.likes = 0,
    required this.createdAt,
  });
}

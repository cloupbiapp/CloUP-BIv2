class UserModel {
  final String uid;
  final String username;
  final String email;
  final String? photoUrl;
  final String? bio;
  final int followers;
  final int following;
  final DateTime createdAt;

  UserModel({
    required this.uid,
    required this.username,
    required this.email,
    this.photoUrl,
    this.bio,
    this.followers = 0,
    this.following = 0,
    required this.createdAt,
  });
}

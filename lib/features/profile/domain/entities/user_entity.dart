class UserEntity {
  final String id;
  final String username;
  final String displayName;
  final String email;
  final String bio;
  final String profilePicUrl;
  final List<String> followers;
  final List<String> following;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.username,
    required this.displayName,
    required this.email,
    required this.bio,
    required this.profilePicUrl,
    required this.followers,
    required this.following,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? username,
    String? displayName,
    String? email,
    String? bio,
    String? profilePicUrl,
    List<String>? followers,
    List<String>? following,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      username: username ?? this.username,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      bio: bio ?? this.bio,
      profilePicUrl: profilePicUrl ?? this.profilePicUrl,
      followers: followers ?? this.followers,
      following: following ?? this.following,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

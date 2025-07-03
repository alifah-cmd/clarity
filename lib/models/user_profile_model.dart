class UserProfile {
  final String id;
  final String fullName;
  final String? avatarUrl;

  UserProfile({
    required this.id,
    required this.fullName,
    this.avatarUrl,
  });


  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'],
      fullName: map['full_name'],
      avatarUrl: map['avatar_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'avatar_url': avatarUrl,
    };
  }
}

class UserDetail {
  final String uid;
  final int id;
  final String name;
  final String email;
  final String? profileImage;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  UserDetail({
    required this.uid,
    required this.id,
    required this.name,
    required this.email,
    required this.profileImage,
    this.createdAt,
    this.updatedAt,
  });

  factory UserDetail.fromJson(Map<String, dynamic> json) {
    return UserDetail(
      uid: json['uid'] ?? 'default',
      id: json['id'],
      name: json['name'],
      email: json['email'],
      profileImage: json['profile_image'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }

  factory UserDetail.defaultUser() {
    return UserDetail(
      uid: 'default',
      id: 0,
      name: 'Default User',
      email: 'default@example.com',
      profileImage: 'default',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }
}

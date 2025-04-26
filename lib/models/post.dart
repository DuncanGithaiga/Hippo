import 'package:hippo/models/user.dart';

class Post {
  final int id;
  String? title;
  String? body;
  final UserDetail user; // Nested user object
  Post({
    required this.id,
    required this.title,
    required this.body,
    required this.user,
  });

  //convert JSON to dart object for dart to understand and view
  //map (Key Value) map each json keys to corresponding model fields
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'] ?? 0, // Default ID to 0 if null
      title: json['title'] ?? 'No Title',
      body: json['body'] ?? 'No Content',
      user:
          json['user'] != null
              ? UserDetail.fromJson(json['user'])
              : UserDetail.defaultUser(),
    );
  }
}

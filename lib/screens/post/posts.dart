import 'package:hippo/constants/customAppBar.dart';
import 'package:hippo/constants/loading.dart';
import 'package:hippo/models/post.dart';
import 'package:hippo/screens/post/postTile.dart';
import 'package:hippo/services/dbapi.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart' as intl;
import 'package:intl/intl.dart';

class Posts extends StatefulWidget {
  const Posts({super.key});

  @override
  State<Posts> createState() => _PostsState();
}

class _PostsState extends State<Posts> {
  String? token;
  String? userId;
  String? name;
  String? email;
  DateTime? created_at;

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // In the _UserProfileState class

  void initializePreferences() async {}

  void getUserData() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    final userId = await storage.read(key: 'user_id');
    final email = await storage.read(key: 'email');
    final name = await storage.read(key: 'name');
    final created_at = await storage.read(key: 'created_at');
    final dateTime =
        created_at != null
            ? DateTime.tryParse(created_at)
            : DateTime.now().toUtc();

    print(storage);

    setState(() {
      this.token = token;
      this.email = email;
      this.userId = userId;
      this.name = name;
      this.created_at = dateTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Posts',
        backgroundColor: Color.fromARGB(255, 99, 13, 114),
      ),
      body: FutureBuilder<List<Post>>(
        future: DbApi(token: token).getPosts(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("No posts available"));
          }
          print("Posts: ${snapshot.data}");
          final posts = snapshot.data!;
          return ListView.builder(
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];
              return PostTile(post: post);
            },
          );
        },
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:hippo/models/post.dart';

class PostTile extends StatelessWidget {
  final Post post;

  const PostTile({Key? key, required this.post}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 3,
      child: ListTile(
        contentPadding: EdgeInsets.all(10),
        title: Text(
          post.title ?? 'No Title',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 5),
            Text(
              post.body ?? 'No content',
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            SizedBox(height: 5),
            Row(
              children: [
                Icon(Icons.person, size: 14, color: Colors.lightBlue),
                SizedBox(width: 5),
                Text(
                  "By: ${post.user.name}",
                  style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic),
                ),
              ],
            ),
          ],
        ),
        leading: CircleAvatar(
          backgroundColor: Colors.purple.shade100,
          child: Text(
            post.user.name[0].toUpperCase(), // First letter of username
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        onTap: () {
          // Navigate to a detailed post page if needed
        },
      ),
    );
  }
}

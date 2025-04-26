import 'dart:convert'; // required to encode/decode json data
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:hippo/models/post.dart';
import 'package:hippo/models/product.dart';

class DbApi {
  // final String _url = 'http://localhost:8000/api/v1';
  //if you are using android studio emulator, change localhost to 10.0.2.2
  var token;

  DbApi({this.token});

  final storage = FlutterSecureStorage();
  String? imageUrl;

  Future<List<Post>> userPosts() async {
    var url = Uri.parse("http://10.0.2.2:8000/api/user/posts");
    String? token = await getToken();

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    print("Response status: ${response.statusCode}");
    print("Response body: ${response.body}");

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);

      if (responseBody.containsKey('posts') && responseBody['posts'] is List) {
        List<Post> posts =
            (responseBody['posts'] as List)
                .map((e) => Post.fromJson(e))
                .toList();
        debugPrint("Posts fetched successfully: $posts");
        // if (posts.isEmpty) {
        //   throw Exception("No posts found");
        // }
        return posts;
      } else {
        throw Exception(
          "Unexpected response format: 'posts' key missing or null",
        );
      }
    } else {
      throw Exception("Failed to load posts: ${response.statusCode}");
    }
  }

  Future<String?> getToken() async {
    String? token = await storage.read(key: 'token');
    print(token);
    return token;
  }

  Future<List<Post>> getPosts() async {
    var url = Uri.parse("http://10.0.2.2:8000/api/post");
    String? token = await getToken();
    if (token == null) {
      throw Exception("Token not found");
    }
    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['data'];

        debugPrint("Posts fetched successfully: $data");
        return data.map((e) => Post.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load posts");
      }
    } catch (e) {
      // Handle exceptions gracefully
      print("An error occurred: $e");
      return [];
    }
  }

  Future<bool> storePost(String title, String body) async {
    var url = Uri.parse("http://10.0.2.2:8000/api/post");
    String? token = await getToken();
    String? userId = await storage.read(key: 'user_id'); // Get user ID
    if (token == null || userId == null) {
      throw Exception("User authentication failed");
    }
    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'title': title,
          'body': body,
          'user_id': userId, // Attach user ID to post
        }),
      );
      if (response.statusCode == 201) {
        return true;
      } else {
        debugPrint("Failed to store post: ${response.body}");
        return false;
      }
    } catch (e) {
      debugPrint("An error occurred: $e");
      return false;
    }
  }

  Future<List<Product>> getProducts() async {
    var url = Uri.parse("http://10.0.2.2:8000/api/products");
    String? token = await getToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseBody = json.decode(response.body);
        final List<dynamic> data = responseBody['data'];

        print("Posts fetched successfully: $data");
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception("Failed to load posts");
      }
    } catch (e) {
      // Handle exceptions gracefully
      print("An error occurred: $e");
      return [];
    }
  }

  Future<List> searchProduct() async {
    var url = Uri.parse("http://10.0.2.2:8000/api/search");
    String? token = await getToken();
    if (token == null) {
      throw Exception("Token not found");
    }

    final response = await http.get(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseBody = json.decode(response.body);
      final List<dynamic> data = responseBody['data'];

      return data;
    } else {
      throw Exception("Failed to load products");
    }
  }

  // Future<void> fetchImageUrl() async {
  //   final response =
  //       await http.get(Uri.parse("http://10.0.2.2:8000/api/get-image"));
  //   if (response.statusCode == 200) {
  //     final data = jsonDecode(response.body);
  //     imageUrl = data[
  //         "url"]; // Laravel API should return {"url": "http://your-api.com/storage/images/example.jpg"}
  //   } else {
  //     throw Exception("Failed to load image");
  //   }
  // }

  Future<bool> deleteUser(int id) async {
    var url = Uri.parse("http://10.0.2.2:8000/api/user/$id/delete");
    String? token = await getToken();
    if (token == null) {
      throw Exception("Token not found");
    }
    final response = await http.delete(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      debugPrint("User deleted successfully");
      return true;
    } else if (response.statusCode == 403 || response.statusCode == 404) {
      debugPrint("User not found or already deleted");
      return false;
    } else {
      debugPrint("Failed to delete user: ${response.body}");
      return false;
    }
  }
}

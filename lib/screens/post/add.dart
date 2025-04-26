import 'package:hippo/models/user.dart';
import 'package:hippo/services/authapi.dart';
import 'package:hippo/services/dbapi.dart';
import 'package:flutter/material.dart';
import 'package:hippo/constants/customAppBar.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AddPost extends StatefulWidget {
  const AddPost({super.key});

  @override
  State<AddPost> createState() => _AddPostState();
}

class _AddPostState extends State<AddPost> {
  bool loading = false;
  String error = '';
  String? token;
  String title = '';
  String body = '';
  String? email;
  String? name;
  int? userId;
  String? imageUrl;
  UserDetail? user;
  bool isLoading = true;
  final _formPostKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    // getUserData();
  }

  void fetchUserDetails() async {
    try {
      UserDetail? fetchedUser = await AuthApi().getUserProfile();
      setState(() {
        debugPrint('User: $fetchedUser');
        user = fetchedUser;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  // void getUserData() async {
  //   final storage = FlutterSecureStorage();
  //   final token = await storage.read(key: 'token');
  //   final email = await storage.read(key: 'email');
  //   final name = await storage.read(key: 'name');
  //   final userIdString = await storage.read(key: 'user_id');
  //   final userId = userIdString != null ? int.tryParse(userIdString) : null;
  //   print(storage);

  //   if (!mounted) return; // Check if the widget is still mounted
  //   setState(() {
  //     this.token = token;
  //     this.email = email;
  //     this.name = name;
  //     this.userId = userId;
  //   });
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Add Post',
        backgroundColor: Color.fromARGB(255, 99, 13, 114),
      ),

      // Add a form to the body of the scaffold
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formPostKey,
            child: Column(
              children: [
                SizedBox(height: 20),
                // Add a text field to the form
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Title',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.purple.withOpacity(0.1),
                    filled: true,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter a title"; // ✅ Fixed validator return type
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      title = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                // Add a text field to the form
                TextFormField(
                  decoration: InputDecoration(
                    labelText: 'Body',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(18),
                      borderSide: BorderSide.none,
                    ),
                    fillColor: Colors.purple.withOpacity(0.1),
                    filled: true,
                  ),
                  maxLines: 5, // ✅ Allow body to have multiple lines
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Please enter body content";
                    }
                    return null;
                  },
                  onChanged: (value) {
                    setState(() {
                      body = value;
                    });
                  },
                ),
                SizedBox(height: 20),
                // Add a button to the form
                SizedBox(
                  width: 150,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () async {
                      // Add functionality here
                      if (_formPostKey.currentState!.validate()) {
                        setState(() {
                          loading = true;
                        });
                        try {
                          // Add the post to the database
                          bool result = await DbApi(
                            token: token,
                          ).storePost(title, body);
                          setState(() {
                            loading = false;
                            error =
                                result
                                    ? 'Post added successfully'
                                    : 'Failed to add post';
                          });
                          if (result) {
                            Navigator.pop(context); // Move this before setState
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                backgroundColor: Colors.green,
                                content: Text('Post added successfully'),
                              ),
                            );
                          } else {
                            setState(() {
                              error = 'Failed to add post. Please try again.';
                            });
                          }
                        } catch (e) {
                          setState(() {
                            error = 'An error occurred: $e';
                          });
                        } finally {
                          setState(() {
                            loading = false;
                          });
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      shape: const StadiumBorder(),
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Color.fromARGB(255, 99, 13, 114),
                    ),
                    child: Text(
                      'Submit Post',
                      style: const TextStyle(fontSize: 13, color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

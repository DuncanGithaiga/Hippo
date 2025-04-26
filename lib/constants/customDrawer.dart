import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:hippo/models/user.dart';
import 'package:hippo/screens/user/userProfile.dart';
import 'package:hippo/services/authapi.dart';
import 'package:hippo/screens/auth/authenticate.dart';
import 'package:hippo/screens/post/add.dart';
import 'package:hippo/screens/post/posts.dart';
import 'package:hippo/screens/product/products.dart';
import 'package:http/http.dart' as http;

class customDrawer extends StatefulWidget {
  const customDrawer({super.key});

  @override
  State<customDrawer> createState() => _customDrawerState();
}

class _customDrawerState extends State<customDrawer> {
  UserDetail? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    // getUserData();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   checkToken();
    // });
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

  Future<void> _fetchImage(int imageId) async {
    var url = Uri.parse("http://10.0.2.2:8000/api/get-image/$imageId");
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(response.body);
      String base64Image = jsonResponse['image'];

      setState(() {
        var _retrievedImage = base64Image;
      });
    } else {
      print("Failed to fetch image");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: <Color>[Colors.purple[800]!, Colors.purple[900]!],
        ),

        image: DecorationImage(
          image: AssetImage('assets/images/bck.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Drawer(
        elevation: 3.0,
        child: SafeArea(
          child: ListView(
            // Important: Remove any padding from the ListView.
            padding: EdgeInsets.zero,
            children: [
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  UserAccountsDrawerHeader(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: <Color>[
                          Colors.purple[800]!,
                          Colors.purple[900]!,
                        ],
                      ),

                      // color: Color.fromARGB(255, 99, 13, 114),
                    ),
                    // otherAccountsPictures: [
                    //   const Image(
                    //     image: AssetImage('assets/images/1.png'),
                    //     fit: BoxFit.cover,
                    //   ),
                    // ],
                    accountName: Text(
                      user?.name ?? "Loading...",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    accountEmail: Text(
                      user?.email ?? "",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    currentAccountPicture: CircleAvatar(
                      backgroundColor: Colors.white,
                      backgroundImage:
                          user != null &&
                                  user!.profileImage != null &&
                                  user!.profileImage!.isNotEmpty
                              ? NetworkImage(user!.profileImage!)
                                  as ImageProvider
                              : null,
                      child:
                          user != null &&
                                  (user!.profileImage == null ||
                                      user!.profileImage!.isEmpty)
                              ? Text(
                                user!.name.substring(0, 1),
                                style: TextStyle(
                                  fontSize: 25.0,
                                  color: Color.fromARGB(255, 99, 13, 114),
                                ),
                              )
                              : null,
                    ),
                  ),
                ],
              ),
              HoverListTile(
                icon: Icons.pages,
                title: 'Posts',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Posts()),
                  );
                },
              ),
              HoverListTile(
                icon: Icons.post_add,
                title: 'Add Post',
                onTap: () async {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => AddPost()),
                  );
                },
              ),
              HoverListTile(
                icon: Icons.production_quantity_limits_outlined,
                title: 'Products',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => Products()),
                  );
                },
              ),
              SizedBox(height: 300.0),
              Divider(),
              Column(
                children: [
                  HoverListTile(
                    icon: Icons.supervised_user_circle_outlined,
                    title: 'Users',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Userprofile()),
                      );
                    },
                  ),
                  HoverListTile(
                    icon: Icons.settings,
                    title: 'Settings',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Products()),
                      );
                    },
                  ),
                  InkWell(
                    child: Card(
                      borderOnForeground: true,
                      color: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      elevation: 3,
                      child: HoverListTile(
                        icon: Icons.logout,
                        title: 'Logout',
                        onTap: () async {
                          await AuthApi().logout();
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Authenticate(),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ), // Optional: Separates the bottom ListTile
            ],
          ),
        ),
      ),
    );
  }
}

class HoverListTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const HoverListTile({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
  }) : super(key: key);

  @override
  _HoverListTileState createState() => _HoverListTileState();
}

class _HoverListTileState extends State<HoverListTile> {
  bool isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => isHovered = true),
      onExit: (_) => setState(() => isHovered = false),
      child: Container(
        color: isHovered ? Colors.purple.withOpacity(0.2) : Colors.transparent,
        child: ListTile(
          leading: Icon(widget.icon, color: Colors.black87),
          title: Text(
            widget.title,
            style: TextStyle(
              fontWeight: isHovered ? FontWeight.bold : FontWeight.normal,
              color: isHovered ? Colors.purple : Colors.black,
            ),
          ),
          onTap: widget.onTap,
        ),
      ),
    );
  }
}

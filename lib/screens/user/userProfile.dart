import 'package:flutter/material.dart';
import 'package:hippo/screens/auth/authenticate.dart';
import 'package:intl/intl.dart';
import 'package:hippo/models/user.dart';
import 'package:hippo/screens/user/updateProfile.dart';
import 'package:hippo/services/authapi.dart';
import 'package:hippo/services/dbapi.dart';
import 'package:hippo/constants/customAppBar.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Userprofile extends StatefulWidget {
  const Userprofile({super.key});

  @override
  State<Userprofile> createState() => _UserprofileState();
}

class _UserprofileState extends State<Userprofile> {
  String? email;
  String? name;
  int? uId;
  String? profileImage;
  UserDetail? user;
  DateTime? createdAt;
  DateTime? updatedAt;
  bool isLoading = true;

  String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return "N/A";
    return DateFormat(
      'yyyy-MM-dd hh:mm a',
    ).format(dateTime); // Example: 2024-02-25 10:30 AM
  }

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
        debugPrint('Fetched profile image: ${user?.profileImage}');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'User Profile',
        backgroundColor: Color.fromARGB(255, 99, 13, 114),
      ),
      body: Center(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                children: <Widget>[
                  // CircleAvatar(
                  //   radius: 50,
                  //   backgroundImage: NetworkImage(user?.profileImage ?? ''),
                  // ),
                  CircleAvatar(
                    radius: 50,
                    backgroundImage:
                        user?.profileImage != null &&
                                user!.profileImage!.isNotEmpty
                            ? NetworkImage(user!.profileImage!) as ImageProvider
                            : AssetImage('assets/images/avatar.png'),
                  ),
                  SizedBox(height: 10),
                  Text(
                    user?.name ?? '',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ],
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                title: Row(
                  children: [
                    Icon(
                      Icons.supervised_user_circle_outlined,
                      color: Colors.lightBlue,
                    ),
                    SizedBox(width: 5),
                    Text(
                      'User ID',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 90),
                    Text(
                      user?.uid ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                title: Row(
                  children: [
                    Icon(Icons.email, color: Colors.lightBlue),
                    SizedBox(width: 5),
                    Text(
                      'Email',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 90),
                    Text(
                      user?.email ?? '',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                title: Row(
                  children: [
                    Icon(Icons.timer, color: Colors.lightBlue),
                    SizedBox(width: 5),
                    Text(
                      'Created At',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 50),
                    Text(
                      formatDateTime(
                        (user?.createdAt != null ? user!.createdAt! : null),
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Card(
              margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 3,
              child: ListTile(
                contentPadding: EdgeInsets.all(10),
                title: Row(
                  children: [
                    Icon(Icons.access_time_sharp, color: Colors.lightBlue),
                    SizedBox(width: 5),
                    Text(
                      'Updated At',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    SizedBox(width: 50),
                    Text(
                      formatDateTime(
                        user?.updatedAt != null ? user!.updatedAt : null,
                      ),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Container(
                padding: const EdgeInsets.only(left: 70.0),
                child: Row(
                  children: [
                    SizedBox(height: 100),
                    InkWell(
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurpleAccent,
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UpdateProfile(),
                            ),
                          );
                        },
                        child: Text(
                          'Edit Profile',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    SizedBox(width: 20),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                      ),
                      onPressed: () async {
                        bool result = await DbApi().deleteUser(user!.id);
                        if (result == true && user != null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('User deleted successfully'),
                            ),
                          );
                          // Clear user session
                          SharedPreferences prefs =
                              await SharedPreferences.getInstance();
                          await prefs.clear(); // Clear stored user data
                          await AuthApi().logout(); // ✅ Logout user
                          Navigator.pushReplacement(
                            context,
                            MaterialPageRoute(
                              builder: (context) => Authenticate(),
                            ),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Failed to delete user')),
                          );
                        }
                      },
                      child: Text(
                        'Delete Profile',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

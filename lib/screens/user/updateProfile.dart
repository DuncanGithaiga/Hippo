import 'package:flutter/material.dart';
import 'package:hippo/constants/customAppBar.dart';

class UpdateProfile extends StatefulWidget {
  const UpdateProfile({super.key});

  @override
  State<UpdateProfile> createState() => _UpdateProfileState();
}

class _UpdateProfileState extends State<UpdateProfile> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Edit Profile',
        backgroundColor: Color.fromARGB(255, 99, 13, 114),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text('Edit Profile'),
            ),
          ],
        ),
      ),
    );
  }
}

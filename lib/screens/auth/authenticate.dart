import 'package:hippo/screens/auth/login.dart';
import 'package:hippo/screens/auth/register.dart';
import 'package:flutter/material.dart';

class Authenticate extends StatefulWidget {
  const Authenticate({super.key});

  @override
  State<Authenticate> createState() => _AuthenticateState();
}

class _AuthenticateState extends State<Authenticate> {
  bool showSignIn = true;

  void toggleView() {
    setState(() {
      //it changes the showSignIn from true to false and vice versa
      showSignIn = !showSignIn;
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          toolbarHeight: 35.0,
          toolbarOpacity: 0.8,
          // shape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.only(
          //       bottomRight: Radius.circular(25),
          //       bottomLeft: Radius.circular(25)),
          // ),
          flexibleSpace: Image(
            image: AssetImage('assets/images/1.png'),
            fit: BoxFit.cover,
          ),
          bottom: const TabBar(
            tabs: [Tab(text: 'Login'), Tab(text: 'Register')],
            labelColor: Colors.black,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Colors.transparent,
            dividerColor: Colors.transparent,
          ),
          elevation: 0, //No shadow
          titleTextStyle: const TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        body: TabBarView(
          children: [Login(toggleView: () {}), Register(toggleView: () {})],
        ),
      ),
    );
  }
}

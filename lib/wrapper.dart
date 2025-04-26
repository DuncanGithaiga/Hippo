import 'package:hippo/screens/auth/authenticate.dart';
import 'package:hippo/screens/home.dart';
import 'package:hippo/services/authapi.dart';
import 'package:flutter/material.dart';

class Wrapper extends StatefulWidget {
  @override
  _WrapperState createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkToken();
    });
  }

  void checkToken() async {
    bool isValid = await AuthApi().isTokenValid();

    debugPrint('Is token valid: $isValid');

    if (!mounted) return; // Ensure widget is still mounted before navigation

    if (isValid) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (context) => Home()));
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => Authenticate()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Display a loading indicator while checking the token
    return const Center(child: CircularProgressIndicator());
  }
}

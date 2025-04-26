import 'package:animate_do/animate_do.dart';
import 'package:hippo/constants/loading.dart';
import 'package:hippo/screens/auth/authenticate.dart';
import 'package:hippo/screens/home.dart';
import 'package:hippo/services/authapi.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:google_fonts/google_fonts.dart';

class Login extends StatefulWidget {
  const Login({super.key, required void Function() toggleView});

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {
  // final AuthService _auth = AuthService();
  String error = '';
  bool loading = false;

  // text field state
  String email = '';
  String password = '';
  final _formInKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return loading
        ? Loading()
        : Scaffold(
          resizeToAvoidBottomInset: true,
          body: SingleChildScrollView(
            child: Stack(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                    vertical: 20.0,
                    horizontal: 30.0,
                  ),
                  child: SingleChildScrollView(
                    child: Form(
                      key: _formInKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          SizedBox(height: 10),
                          Container(
                            margin: const EdgeInsets.only(top: 80.0),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.hippo,
                                      color: Color.fromARGB(255, 99, 13, 114),
                                      size: 80,
                                    ),
                                    Container(),
                                  ],
                                ),
                                SizedBox(height: 10.0),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    FadeInLeft(
                                      duration: Duration(milliseconds: 1500),
                                      child: Text(
                                        'Log In',
                                        style: GoogleFonts.poppins(
                                          textStyle: TextStyle(
                                            fontSize: 30,
                                            fontWeight: FontWeight.bold,
                                            color: Color.fromARGB(
                                              255,
                                              99,
                                              13,
                                              114,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Text(
                                      'to your account',
                                      style: GoogleFonts.poppins(
                                        textStyle: TextStyle(
                                          fontSize: 20,
                                          color: Color.fromARGB(
                                            255,
                                            99,
                                            13,
                                            114,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            error,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14.0,
                            ),
                          ),
                          SizedBox(height: 10),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: 'Email Or Username',
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.purple.withOpacity(0.1),
                              filled: true,
                              prefixIcon: const Icon(Icons.person),
                            ),
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? "Please Enter Your Username OR Email"
                                        : null,
                            onChanged: (value) {
                              setState(() => email = value);
                            },
                          ),
                          SizedBox(height: 20),
                          TextFormField(
                            decoration: InputDecoration(
                              hintText: "Password",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(18),
                                borderSide: BorderSide.none,
                              ),
                              fillColor: Colors.purple.withOpacity(0.1),
                              filled: true,
                              prefixIcon: const Icon(Icons.password),
                            ),
                            obscureText: true,
                            validator:
                                (value) =>
                                    value!.isEmpty
                                        ? "Please Enter Your Password"
                                        : null,
                            onChanged: (value) {
                              setState(() {
                                password = value;
                              });
                            },
                          ),
                          SizedBox(height: 40),
                          SizedBox(
                            width: 150,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: () async {
                                if (_formInKey.currentState!.validate()) {
                                  setState(() {
                                    loading = true;
                                  });

                                  try {
                                    bool result = await AuthApi().login(
                                      email,
                                      password,
                                    );

                                    if (result == false) {
                                      setState(() {
                                        loading = false;
                                        error =
                                            'Could not sign in with those credentials';
                                      });
                                    } else {
                                      setState(() {
                                        loading = false;
                                      });
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => Home(),
                                        ),
                                      );
                                    }
                                  } catch (e) {
                                    setState(() {
                                      loading = false;
                                      error =
                                          'An error occurred. Please try again.';
                                    });
                                  }
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                shape: const StadiumBorder(),
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                backgroundColor: Color.fromARGB(
                                  255,
                                  99,
                                  13,
                                  114,
                                ),
                              ),
                              child: const Text(
                                "Login",
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 10.0),
                          TextButton(
                            onPressed: () {
                              setState(() {
                                print('Forgot');
                              });
                            },
                            child: Text(
                              'Forgot Password?',
                              style: TextStyle(
                                color: Color.fromARGB(255, 99, 13, 114),
                              ),
                            ),
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.google),
                                color: Color.fromARGB(255, 99, 13, 114),
                              ),
                              Text(
                                'Or',
                                style: TextStyle(
                                  color: Color.fromARGB(255, 99, 13, 114),
                                ),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: FaIcon(FontAwesomeIcons.facebook),
                                color: Color.fromARGB(255, 99, 13, 114),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
  }
}

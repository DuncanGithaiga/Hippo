import 'dart:io';

import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:hippo/screens/home.dart';
import 'package:hippo/services/authapi.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

class Register extends StatefulWidget {
  const Register({super.key, required void Function() toggleView});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formupKey = GlobalKey<FormState>();
  // final AuthService _auth = AuthService();
  bool loading = false;

  //text field state to store state
  String name = '';
  String email = '';
  String password = '';
  String confirmPassword = "";
  String error = '';
  // Variable to store the selected image
  File? _image;

  // Function to pick an image
  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
      bool loading = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SingleChildScrollView(
            child: Form(
              key: _formupKey,
              child: Column(
                children: [
                  Container(
                    margin: const EdgeInsets.only(top: 0.0),
                    child: Column(
                      children: [
                        _image != null
                            ? Image.file(_image!, height: 100, width: 100)
                            : Icon(
                              FontAwesomeIcons.userGear,
                              color: Color.fromARGB(255, 99, 13, 114),
                              size: 50,
                            ),
                        ElevatedButton(
                          onPressed: _pickImage,
                          child: Text("Pick Profile Image"),
                        ),
                        // Row(
                        //   mainAxisAlignment:
                        //       MainAxisAlignment.spaceBetween,
                        //   children: [
                        //     Icon(
                        //       FontAwesomeIcons.gears,
                        // ElevatedButton(
                        //   onPressed: _pickImage,
                        //   child: Text("Pick Profile Image"),
                        // ),
                        //       size: 80,
                        //     ),
                        //     Container(),
                        //   ],
                        // ),
                        // SizedBox(height: 30.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            FadeInLeft(
                              duration: Duration(milliseconds: 1500),
                              child: Text(
                                'Create',
                                style: GoogleFonts.poppins(
                                  textStyle: TextStyle(
                                    fontSize: 30,
                                    fontWeight: FontWeight.bold,
                                    color: Color.fromARGB(255, 99, 13, 114),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Text(
                              'your account',
                              style: GoogleFonts.poppins(
                                textStyle: TextStyle(
                                  fontSize: 20,
                                  color: Color.fromARGB(255, 99, 13, 114),
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
                    style: const TextStyle(color: Colors.red, fontSize: 14.0),
                  ),
                  SizedBox(height: 30),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Username",
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
                            value!.isEmpty ? "Please Enter a Username" : null,
                    onChanged: (value) {
                      setState(() {
                        name = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "User@email.com",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.email),
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty || !value.contains('@')
                                ? "Please Enter an Email"
                                : null,
                    onChanged:
                        (value) => setState(() {
                          email = value; // Update the state with the new value
                        }),
                  ),
                  const SizedBox(height: 20),
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
                    validator: (value) {
                      print(value);
                      if (value == null || value.trim().isEmpty) {
                        return "Please enter a password";
                      } else if (value.length < 6) {
                        return "Password should be at least 6 characters";
                      } else if (value.length > 15) {
                        return "Password should not be greater than 15 characters";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        password = value;
                      });
                    },
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    decoration: InputDecoration(
                      hintText: "Confirm Password",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(18),
                        borderSide: BorderSide.none,
                      ),
                      fillColor: Colors.purple.withOpacity(0.1),
                      filled: true,
                      prefixIcon: const Icon(Icons.password),
                    ),
                    obscureText: true,
                    validator: (value) {
                      print('password: $password');
                      print('confirmPassword: $confirmPassword');
                      if (value == null || value.trim().isEmpty) {
                        return "Please confirm your password";
                      } else if (value != password) {
                        return "Passwords do not match";
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        confirmPassword = value;
                      });
                    },
                  ),
                  SizedBox(height: 50),
                  SizedBox(
                    width: 200,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (_formupKey.currentState!.validate()) {
                          setState(() {
                            loading = true;
                          });

                          // Pick Image from Gallery or Camera
                          final pickedFile = await ImagePicker().pickImage(
                            source: ImageSource.gallery,
                          );
                          if (pickedFile != null) {
                            _image = File(pickedFile.path);
                          }

                          try {
                            bool result = await AuthApi().register(
                              _image, // Pass the selected image
                              name,
                              email,
                              password,
                            );

                            if (result == false) {
                              setState(() {
                                loading = false;
                                error =
                                    'Could not sign up with those credentials';
                              });
                            } else {
                              setState(() {
                                loading = false;
                              });
                              Navigator.of(context).pushReplacement(
                                MaterialPageRoute(builder: (context) => Home()),
                              );
                            }
                          } catch (e) {
                            setState(() {
                              loading = false;
                              error = 'An error occurred. Please try again.';
                            });
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        shape: const StadiumBorder(),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        backgroundColor: Color.fromARGB(255, 99, 13, 114),
                      ),
                      child: const Text(
                        "Register",
                        style: TextStyle(fontSize: 13, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

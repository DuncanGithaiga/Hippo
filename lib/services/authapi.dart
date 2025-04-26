import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:hippo/models/user.dart';
import 'package:hippo/screens/auth/authenticate.dart';
import 'package:hippo/screens/home.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
// import 'package:device_info_plus/device_info_plus.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:hippo/services/dbapi.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  DbApi dbApi = DbApi();
  final dio = Dio();
  final storage = FlutterSecureStorage();

  String greeting() {
    var hour = DateTime.now().hour;
    if (hour < 12) {
      return 'Good Morning';
    }
    if (hour < 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  Future<UserDetail?> getUserProfile() async {
    var url = Uri.parse("http://10.0.2.2:8000/api/user");

    String? token = await dbApi.getToken(); // Fetch saved token

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
      if (responseBody['deleted_at'] != null) {
        // ✅ User is soft deleted, log them out
        await logout();
        return null;
      }
      debugPrint('User profile: ${responseBody['data']}');
      return UserDetail.fromJson(responseBody['data']);
    } else {
      throw Exception("Failed to load user profile");
    }
  }

  Future<bool> login(String email, String password) async {
    // final deviceInfo = DeviceInfoPlugin();
    // String deviceName = "Unknown Device";

    try {
      // // Get device information
      // if (Platform.isAndroid) {
      //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      //   deviceName = androidInfo.id;
      // } else if (Platform.isIOS) {
      //   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      //   deviceName = iosInfo.identifierForVendor ?? "iOS Device";
      // } , 'device_name': deviceName

      // Prepare login request
      final response = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/auth/login"),
        headers: {'Content-Type': 'application/json; charset=UTF-8'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Handle API response
      if (response.statusCode == 200) {
        final responseData = jsonDecode(response.body);
        final token = responseData['token'];
        final userId = responseData['user_id']?.toString() ?? "";
        final name = responseData['name'] ?? "";
        final email = responseData['email'] ?? "";

        if (token != null) {
          await storage.write(key: 'token', value: token);
          await storage.write(key: 'user_id', value: userId);

          // Save non-sensitive data using SharedPreferences
          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('name', name);
          await prefs.setString('email', email);

          debugPrint('Login successful, token: $token');
          return true;
        } else {
          debugPrint('Token missing in login response');
        }
      } else {
        final responseData = jsonDecode(response.body);
        final errorMessage = responseData['message'] ?? 'Unknown error';
        debugPrint('Login failed: $errorMessage');
      }
    } on SocketException {
      debugPrint('No Internet connection.');
    } on FormatException {
      debugPrint('Invalid response format.');
    } catch (e) {
      debugPrint('Login exception: $e');
    }

    return false;
  }

  Future<bool> register(
    File? imageFile,
    String name,
    String email,
    String password,
  ) async {
    // final deviceInfo = DeviceInfoPlugin();
    // String deviceName = "Unknown Device";

    try {
      // Get device information
      // if (Platform.isAndroid) {
      //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
      //   deviceName = androidInfo.id;
      // } else if (Platform.isIOS) {
      //   IosDeviceInfo iosInfo = await deviceInfo.iosInfo;
      //   deviceName = iosInfo.identifierForVendor ?? "iOS Device";
      // }
      FormData formData = FormData.fromMap({
        "name": name,
        "email": email,
        "password": password,
        "confirm_password": password,
        if (imageFile != null)
          "profile_image": await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      // API request payload
      final response = await dio.post(
        "http://10.0.2.2:8000/api/auth/register",
        data: formData,
        options: Options(headers: {"Content-Type": "multipart/form-data"}),
      );

      // Check response status
      if (response.statusCode == 200) {
        debugPrint('Registration successful: ${response.data}');
        return true;
      } else {
        debugPrint('Registration failed: ${response.data}');
        return false;
      }
    } on DioException catch (e) {
      if (e.response != null) {
        debugPrint('Registration error: ${e.response?.data}');
        debugPrint('Status code: ${e.response?.statusCode}');
      } else {
        debugPrint('Network error: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unexpected error: $e');
    }

    return false;
  }

  Future<bool> logout() async {
    final token = await storage.read(key: 'token');

    if (token != null) {
      print('Token found: $token');
      // Make a request to the logout endpoint if necessary
      final logoutResponse = await http.post(
        Uri.parse("http://10.0.2.2:8000/api/auth/logout"),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
      );

      if (logoutResponse.statusCode == 200) {
        print('Logout successful');
        // Remove the token from secure storage
        await storage.delete(key: 'token');
        return true;
      } else {
        print('Logout failed: ${logoutResponse.body}');
        return false;
      }
    } else {
      print('No token found');
      return false;
    }
  }

  Future<bool> isTokenValid() async {
    try {
      // Read token from storage
      final String? token = await storage.read(key: 'token');

      if (token == null) {
        debugPrint('No token found.');
        return false;
      }

      // Check if the token is expired
      if (JwtDecoder.isExpired(token)) {
        debugPrint('Token has expired.');
        return false;
      }

      // Make API request to validate token
      final response = await http
          .get(
            Uri.parse("http://10.0.2.2:8000/api/auth/checkToken"),
            headers: {
              'Authorization': 'Bearer $token',
              'Accept': 'application/json',
            },
          )
          .timeout(Duration(seconds: 5)); // Prevent infinite waiting

      if (response.statusCode == 200) {
        final Map<String, dynamic>? responseBody = json.decode(response.body);

        if (responseBody != null && responseBody.containsKey('status')) {
          return responseBody['status'] == 'success';
        } else {
          debugPrint('Invalid response format.');
        }
      } else {
        debugPrint('Invalid token. Response Code: ${response.statusCode}');
      }
    } on SocketException {
      debugPrint('No Internet connection.');
    } on TimeoutException {
      debugPrint('Request timeout.');
    } on FormatException {
      debugPrint('Invalid response format.');
    } catch (e) {
      debugPrint('Error checking token validity: $e');
    }

    return false;
  }

  // Call this function in your UI instead of handling navigation inside isTokenValid()
  void checkTokenAndNavigate(BuildContext context) async {
    bool isValid = await isTokenValid();
    if (isValid) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => Home()));
    } else {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => Authenticate()));
    }
  }
}

File? _image;

Future<void> _uploadImage() async {
  if (_image == null) return;

  var url = Uri.parse("http://10.0.2.2:8000/api/upload-image");
  var request = http.MultipartRequest('POST', url);

  var stream = http.ByteStream(_image!.openRead());
  var length = await _image!.length();
  var multipartFile = http.MultipartFile(
    'image',
    stream,
    length,
    filename: basename(_image!.path),
  );

  request.files.add(multipartFile);
  request.headers.addAll({'Accept': 'application/json'});

  var response = await request.send();
  var responseData = await response.stream.bytesToString();

  if (response.statusCode == 200) {
    var jsonResponse = json.decode(responseData);
    int imageId = jsonResponse['image_id']; // Store this ID for retrieval
    print("Upload Successful, Image ID: $imageId");
  } else {
    print("Upload Failed: ${response.statusCode}");
  }
}

//   Future<bool> isTokenValid(BuildContext context) async {
//     final storage = FlutterSecureStorage();
//     final token = await storage.read(key: 'token');
//     final userId = await storage.read(key: 'user_id');
//     print('Token: $token');
//     print('User ID: $userId');

//     if (token == null || userId == null) {
//       return false;
//     }

//     // Check if the token is expired
//     if (JwtDecoder.isExpired(token)) {
//       debugPrint('Token has expired');
//       return false;
//     }

//     try {
//       final response = await http.get(
//         Uri.parse("http://10.0.2.2:8000/api/auth/checkToken"),
//         headers: <String, String>{
//           'Content-Type': 'application/json; charset=UTF-8',
//           'Authorization': 'Bearer $token',
//           'User-Id': userId,
//         },
//       );

//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseBody = json.decode(response.body);
//         if (responseBody['status'] == 'success') {
//           Navigator.of(context)
//               .pushReplacement(MaterialPageRoute(builder: (context) => Home()));
//         }
//         return true;
//       } else {
//         // Navigate to authentication page if token is invalid
//         Navigator.of(context).pushReplacement(
//             MaterialPageRoute(builder: (context) => Authenticate()));
//       }
//       return false;
//     } catch (e) {
//       print('Error checking token validity: $e');
//       // Navigate to authentication page if there's an error
//       Navigator.of(context).pushReplacement(
//           MaterialPageRoute(builder: (context) => Authenticate()));
//       return false;
//     }
//   }
// }


 // Future<bool> login(String email, String password) async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;

  //   try {
  //     // Prepare the login request
  //     final loginResponse = await http.post(
  //       Uri.parse("http://10.0.2.2:8000/api/auth/login"),
  //       headers: <String, String>{
  //         'Content-Type': 'application/json; charset=UTF-8',
  //       },
  //       body: jsonEncode(<String, String>{
  //         'email': email,
  //         'password': password,
  //         'device_name': androidInfo.id,
  //       }),
  //     );

  //     //
  //     // Check if the login was successful
  //     //
  //     if (loginResponse.statusCode == 200) {
  //       final response = jsonDecode(loginResponse.body);
  //       print(response);
  //       final token = response['token'];
  //       final userId = response['user_id'];
  //       final name = response['name'];
  //       final email = response['email'];
  //       if (token != null) {
  //         final storage = FlutterSecureStorage();
  //         await storage.write(key: 'token', value: token);
  //         await storage.write(key: 'user_id', value: userId);
  //         await storage.write(key: 'name', value: name);
  //         await storage.write(key: 'email', value: email);
  //         print('Login successful, token: $token');
  //         return true;
  //       } else {
  //         print('Token missing in login response');
  //         return false;
  //       }
  //     } else {
  //       print('Login failed with status: ${loginResponse.statusCode}');
  //       return false;
  //     }
  //   } catch (e) {
  //     print('Login exception: $e');
  //     return false;
  //   }
  // }


  //   Future<bool> register(String name, String email, String password) async {
  //   DeviceInfoPlugin deviceInfo = DeviceInfoPlugin();
  //   AndroidDeviceInfo androidInfo = await deviceInfo.androidInfo;
  //   // print('logging in with credentials');

  //   try {
  //     // Making the POST request for registration
  //     final response = await Dio().post(
  //       "http://10.0.2.2:8000/api/auth/register",
  //       data: {
  //         "name": name,
  //         "email": email,
  //         "password": password,
  //         "confirm_password": password,
  //         // "device_name": androidInfo.id,
  //         // "device_model": androidInfo.model,
  //         // "device_os": androidInfo.os,
  //         // "device_manufacturer": androidInfo.manufacturer,
  //         // "device_type": androidInfo.type,
  //         // "device_brand": androidInfo.brand,
  //         // "device_id": androidInfo.id,
  //         // "device_ip": androidInfo.ipAddress,
  //       },
  //     );

  //     // Checking if registration was successful
  //     if (response.statusCode == 200) {
  //       print('Registration successful: ${response.data}');
  //       print('Status code: ${response.statusCode}');
  //       return true;
  //     } else {
  //       print('Registration failed: ${response.data}');
  //       print('Status code: ${response.statusCode}');
  //       return false;
  //     }
  //   } on DioException catch (e) {
  //     // Handling Dio-specific exceptions
  //     if (e.response != null) {
  //       print('Registration error: ${e.response!.data}');
  //       print('Status code: ${e.response!.statusCode}');
  //       return false;
  //     } else {
  //       print('Registration error: ${e.message}');
  //       print('Status code: ${e.response!.statusCode}');
  //       return false;
  //     }
  //   } catch (e) {
  //     // Handling any other exceptions
  //     print('Unexpected error: $e');
  //     return false;
  //   }
  // }
import 'package:hippo/screens/splash.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:hippo/providers/authprovider.dart';

Future<void> main() async {
  // WidgetsFlutterBinding.ensureInitialized();

  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(
    ChangeNotifierProvider(create: (context) => AuthProvider(), child: MyApp()),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 1,
        ),
        useMaterial3: true,

        //Define the default brightness and colors.
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 99, 13, 114),
          primary: const Color.fromARGB(255, 99, 13, 114),
          // ···
          brightness: Brightness.light,
        ),

        //Define the default `TextTheme`. Use this to specify the default
        //text styling for headlines, titles, bodies of text, and more.
        textTheme: TextTheme(
          displayLarge: const TextStyle(
            fontSize: 72,
            fontWeight: FontWeight.bold,
          ),
          // ···
          titleLarge: GoogleFonts.poppins(
            color: Colors.black,
            fontWeight: FontWeight.bold,
            fontSize: 20,
            fontStyle: FontStyle.normal,
          ),
          bodyMedium: GoogleFonts.poppins(),
          displaySmall: GoogleFonts.poppins(),
          titleSmall: GoogleFonts.poppins(),
          bodySmall: GoogleFonts.poppins(),
          bodyLarge: GoogleFonts.poppins(),
          titleMedium: GoogleFonts.poppins(),
          displayMedium: GoogleFonts.poppins(),
        ),
      ),
      home: SplashScreen(),
    );
  }
}

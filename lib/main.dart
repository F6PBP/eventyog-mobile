import 'dart:io';
import 'package:eventyog_mobile/pages/auth/login.dart';
import 'package:eventyog_mobile/pages/forum/forum.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pbp_django_auth/pbp_django_auth.dart';
import 'package:provider/provider.dart';
import 'package:eventyog_mobile/pages/merchandise/merchandise_list.dart';

class MyHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..badCertificateCallback =
          (X509Certificate cert, String host, int port) => true;
  }
}

Future<void> main() async {
  runApp(const MyApp());
  HttpOverrides.global = MyHttpOverrides();
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Provider(
        create: (_) {
          CookieRequest request = CookieRequest();
          return request;
        },
        child: MaterialApp(
          title: 'Skibishop',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color.fromARGB(255, 0, 74, 254),
              primary: const Color.fromARGB(255, 0, 74, 254),
              secondary: const Color.fromARGB(255, 0, 233, 79),
            ),
            textTheme: GoogleFonts.dmSansTextTheme(
              Theme.of(context).textTheme,
            ),
            useMaterial3: true,
          ),
          home: const LoginPage(),
        ));
  }
}

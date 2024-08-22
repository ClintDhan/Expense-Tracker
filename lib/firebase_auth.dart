import 'dart:math';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_project/home_page.dart';
import 'package:flutter_application_project/login_page.dart';
import 'package:flutter_application_project/successful.dart';

class firebase_auth extends StatefulWidget {
  const firebase_auth({super.key});

  @override
  State<firebase_auth> createState() => _nameState();
}

class _nameState extends State<firebase_auth> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return SuccessfulScreen();
          } else {
            return Login_page();
          }
        },
      ),
    );
  }
}

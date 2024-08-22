import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_project/expense_home.dart';
import 'login_page.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

const purple = Color(0xff602e9e);
const babypowder = Color(0xfffefefa);
const darkBackground = Color(0xff121212);
const darkCard = Color(0xff1E1E1E);
const darkTextField = Color(0xff2C2C2C);
const lightText = Color(0xffE0E0E0);

class _SignupPageState extends State<SignupPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _usernameController = TextEditingController();

  void signIn(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      if (_passwordController.text == _confirmPasswordController.text) {
        // Attempt to create user
        UserCredential userCredential =
        await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text,
          password: _passwordController.text,
        );

        // Get the newly created user
        User? user = userCredential.user;

        // Add user data to Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .set({
          'email': _emailController.text,
          'username': _usernameController.text,
          'createdAt': DateTime.now().toIso8601String(),
        });

        Navigator.pop(context); // Close the CircularProgressIndicator dialog
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ExpenseHome()),
        );
      } else {
        Navigator.pop(context);
        showErrorMessage("Passwords don't match");
      }
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context); // Close the CircularProgressIndicator dialog
      showErrorMessage(e.message ?? "An error occurred");
    } catch (e) {
      Navigator.pop(context); // Close the CircularProgressIndicator dialog
      showErrorMessage("An unexpected error occurred: $e");
    }
  }

  void showErrorMessage(String message) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: darkCard,
          title: Center(
            child: Text(
              message,
              style: const TextStyle(
                color: babypowder,
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: babypowder,
                ),
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: ListView(
        children: [
          Center(
            child: Column(
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 70),
                  height: 25,
                  width: 90,
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'SIGN UP',
                      style: TextStyle(
                        fontSize: 20,
                        fontFamily: 'Comforta',
                        fontWeight: FontWeight.w600,
                        color: lightText,
                      ),
                    ),
                  ),
                ),
                Container(
                  margin: const EdgeInsets.only(top: 20),
                  width: 350,
                  height: 450,
                  decoration: BoxDecoration(
                    color: darkCard,
                    border: Border.all(color: darkCard),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20, left: 8),
                            child: Text(
                              'Email',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Comforta',
                                fontWeight: FontWeight.w600,
                                color: lightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(right: 8, left: 8),
                        child: TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            hintText: 'Your email',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: darkTextField,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: lightText),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 16, left: 8),
                            child: Text(
                              'Username',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Comforta',
                                fontWeight: FontWeight.w600,
                                color: lightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: TextFormField(
                          controller: _usernameController,
                          decoration: InputDecoration(
                            hintText: 'Your username',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: darkTextField,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: lightText),
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20, left: 8),
                            child: Text(
                              'Password',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Comforta',
                                fontWeight: FontWeight.w600,
                                color: lightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: TextFormField(
                          controller: _passwordController,
                          decoration: InputDecoration(
                            hintText: 'Your password',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: darkTextField,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: lightText),
                          obscureText: true,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: EdgeInsets.only(top: 20, left: 8),
                            child: Text(
                              'Confirm Password',
                              style: TextStyle(
                                fontSize: 12,
                                fontFamily: 'Comforta',
                                fontWeight: FontWeight.w600,
                                color: lightText,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        child: TextFormField(
                          controller: _confirmPasswordController,
                          decoration: InputDecoration(
                            hintText: 'Confirm Password',
                            hintStyle: TextStyle(color: Colors.grey[500]),
                            filled: true,
                            fillColor: darkTextField,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8.0),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          style: const TextStyle(color: lightText),
                          obscureText: true,
                        ),
                      )
                    ],
                  ),
                ),
                GestureDetector(
                  onTap: () => signIn(context),
                  child: Padding(
                    padding: const EdgeInsets.only(top: 16.0),
                    child: Container(
                      height: 60,
                      width: 350,
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xffd3d3d3)),
                        borderRadius: BorderRadius.circular(8),
                        color: purple,
                      ),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'SIGN UP',
                          style: TextStyle(
                            fontSize: 12,
                            color: babypowder,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const Login_page()),
                        );
                      },
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          decoration: TextDecoration.underline,
                          color: lightText,
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}

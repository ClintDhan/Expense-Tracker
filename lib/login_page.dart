import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_application_project/common/color_extension.dart';
import 'package:flutter_application_project/expense_home.dart';
import 'package:flutter_application_project/signup_page.dart';

class Login_page extends StatefulWidget {
  const Login_page({super.key});

  @override
  State<Login_page> createState() => _LoginPageState();
}

const purple = Color(0xff602e9e);
const babypowder = Color(0xfffefefa);
const darkBackground = Color(0xff121212);
const darkCard = Color(0xff1E1E1E);
const darkTextField = Color(0xff2C2C2C);
const lightText = Color(0xffE0E0E0);

class _LoginPageState extends State<Login_page> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void logIn(BuildContext context) async {
    showDialog(
      context: context,
      builder: (context) {
        return const Center(child: CircularProgressIndicator());
      },
    );

    try {
      await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text, password: _passwordController.text);
      Navigator.pop(context); // Close the CircularProgressIndicator dialog
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const ExpenseHome()),
      );
    } on FirebaseAuthException catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.code);
    } catch (e) {
      Navigator.pop(context);
      showErrorMessage(e.toString());
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
                  color: Colors.white,
                ),
              )),
          actions: <Widget>[
            TextButton(
              child: const Text(
                'OK',
                style: TextStyle(
                  color: Colors.white,
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
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.only(top: 120),
                height: 25,
                width: 72,
                child: const Align(
                  alignment: Alignment.center,
                  child: Text(
                    'LOGIN',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontFamily: 'Comforta',
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              Container(
                margin: const EdgeInsets.only(top: 20),
                height: 250,
                width: 350,
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
                          padding: EdgeInsets.only(
                            top: 20,
                            left: 8,
                          ),
                          child: Text(
                            'Email',
                            style: TextStyle(
                                color: lightText,
                                fontSize: 12,
                                fontFamily: 'Comforta',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          hintText: 'Enter your email',
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
                    const SizedBox(
                        height: 20), // Add some spacing between the text fields
                    const Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 8, top: 16),
                          child: Text(
                            'Password',
                            style: TextStyle(
                                color: lightText,
                                fontSize: 12,
                                fontFamily: 'Comforta',
                                fontWeight: FontWeight.w600),
                          ),
                        ),
                      ],
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 8, right: 8),
                      child: TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          hintText: 'Enter your password',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                          filled: true,
                          fillColor: darkTextField,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(color: lightText),
                        obscureText: true, // If it's a password field
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 16.0),
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => logIn(context), // Pass context to the logIn function

                    child: Container(
                      height: 60,
                      width: 350,
                      decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xffD3D3D3)),
                          borderRadius: BorderRadius.circular(8),
                          color: purple),
                      child: const Align(
                        alignment: Alignment.center,
                        child: Text(
                          'LOGIN',
                          style: TextStyle(
                              color: babypowder,
                              fontFamily: 'Comforta',
                              fontWeight: FontWeight.w600),
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
                        MaterialPageRoute(
                            builder: (context) => const SignupPage()),
                      );
                    },
                    child: const Text(
                      'Create Account',
                      style: TextStyle(
                        color: lightText,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}

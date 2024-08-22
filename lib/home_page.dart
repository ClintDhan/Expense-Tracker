import 'package:flutter/material.dart';
import 'package:flutter_application_project/login_page.dart';

// Define color constants
const purple = Color(0xff602e9e);
const babypowder = Color(0xfffefefa);
const darkBackground = Color(0xff121212);
const darkCard = Color(0xff1E1E1E);
const darkTextField = Color(0xff2C2C2C);
const lightText = Color(0xffE0E0E0);

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: darkBackground,
      body: Center(
        child: Column(
          children: [
            Container(
              margin: const EdgeInsets.only(top: 100.0),
              height: 60.0,
              width: 60.0,
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('lib/images/mainlogo.png'),
                  fit: BoxFit.fill,
                ),
              ),
            ),
            const SizedBox(
              height: 40,
              width: 300,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Expense Tracker',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 35,
                    fontFamily: 'Comforta',
                    color: lightText,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 66,
              width: 280,
              child: Align(
                alignment: Alignment.center,
                child: Text(
                  'Empower Your Student Budget: Track, Save, Succeed!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'Comforta',
                    color: lightText,
                  ),
                ),
              ),
            ),
            MouseRegion(
              cursor: SystemMouseCursors.click,
              child: GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const Login_page()),
                  );
                },
                child: Container(
                  margin: const EdgeInsets.only(top: 200.0),
                  height: 50,
                  width: 314,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: const Color(0xffD3D3D3)),
                    color: purple,
                  ),
                  child: const Align(
                    alignment: Alignment.center,
                    child: Text(
                      'START TRACKING',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12,
                        fontFamily: 'Comforta',
                        fontWeight: FontWeight.w600,
                        color: babypowder,
                      ),
                    ),
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

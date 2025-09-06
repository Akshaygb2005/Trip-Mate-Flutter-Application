import 'package:fare_calculator/working.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'login_page.dart'; // your target screen

class Splash extends StatefulWidget {
  @override
  SplashState createState() => SplashState();
}

class SplashState extends State<Splash> {
  double _opacity = 1.0;

  @override
  void initState() {
    super.initState();

    // Step 1: Wait for Lottie to finish (5s)
    Future.delayed(Duration(seconds: 4), () {
      // Step 2: Start fade out
      setState(() {
        _opacity = 0.0;
      });

      // time taken to navigate to next page after opacity is completed
      Future.delayed(Duration(milliseconds: 500), () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => Work()),
        );
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: Colors.white, // or your splash background color
      body: Center(
        child: AnimatedOpacity(
          opacity: _opacity,
          duration: Duration(seconds: 3), // smooth fade-out
          child: Lottie.asset(
            'assets/animations/Calculator.json',
            width: screenHeight*0.4,
            height: screenWidth*0.4,
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}

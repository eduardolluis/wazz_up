import 'package:flutter/material.dart';
import 'package:whatzapp/newScreen/login_screen.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SizedBox(
        height: height,
        width: width,
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 50),
              Text(
                "Welcome to WhatZapp",
                style: TextStyle(
                  color: Colors.teal,
                  fontSize: 29,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: height / 8),
              Image.asset(
                'assets/bg.png',
                color: Colors.greenAccent[700],
                width: 340,
              ),
              SizedBox(height: height / 9),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    style: TextStyle(color: Colors.black, fontSize: 15),
                    children: [
                      TextSpan(
                        text: "Agree and Continue to accept the ",
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                      TextSpan(
                        text: "WhatZapp Terms of Service and Privacy Policy",
                        style: TextStyle(color: Colors.cyan),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 20),
              InkWell(
                borderRadius: BorderRadius.circular(8),
                onTap: () {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (context) => LoginPage()),
                    (route) => false,
                  );
                },
                child: SizedBox(
                  width: width - 110,
                  height: 50,
                  child: Card(
                    margin: EdgeInsets.all(0),
                    elevation: 8,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    color: Colors.greenAccent[700],
                    child: Center(
                      child: Text(
                        "Agree and Continue",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

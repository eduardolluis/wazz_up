import 'package:flutter/material.dart';
import 'package:whatzapp/model/country_model.dart';
import 'package:whatzapp/newScreen/country_screen.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  String countryName = "Dominican Republic";
  String countryCode = "+1";
  String countryFlag = "🇩🇴";

  final TextEditingController phoneCtrl = TextEditingController();

  @override
  void dispose() {
    phoneCtrl.dispose();
    super.dispose();
  }

  void setCountryData(CountryModel countryModel) {
    setState(() {
      countryName = countryModel.name;
      countryCode = countryModel.code;
      countryFlag = countryModel.flag;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Text(
          "Enter your phone number",
          style: TextStyle(
            color: Colors.teal,
            fontWeight: FontWeight.w700,
            wordSpacing: 1,
          ),
        ),
        centerTitle: true,
        actions: [Icon(Icons.more_vert, color: Colors.black)],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 30),
        child: Column(
          children: [
            SizedBox(height: 10),
            Text(
              "WhatZapp will need to verify your phone number.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 13.5, color: Colors.grey[700]),
            ),
            SizedBox(height: 5),
            Text(
              "What's my number?",
              style: TextStyle(color: Colors.cyan, fontSize: 12.8),
            ),
            SizedBox(height: 20),

            countryCard(context),

            SizedBox(height: 15),

            Row(
              children: [
                Container(
                  padding: EdgeInsets.symmetric(horizontal: 10, vertical: 12),
                  decoration: BoxDecoration(
                    border: Border(
                      bottom: BorderSide(color: Colors.teal, width: 1.8),
                    ),
                  ),
                  child: Text(
                    countryCode,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                  ),
                ),
                SizedBox(width: 10),
                Expanded(
                  child: TextField(
                    controller: phoneCtrl,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      hintText: "Phone number",
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 1.8),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.teal, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            SizedBox(height: 40),

            SizedBox(
              width: width / 2.5,
              height: 42,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.greenAccent[700],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(6),
                  ),
                  elevation: 4,
                ),
                onPressed: () {
                  if (phoneCtrl.text.trim().isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Please enter your phone number")),
                    );
                    return;
                  }
                },
                child: Text(
                  "Next",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget countryCard(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => CountryScreen(setCountryData: setCountryData),
          ),
        );
      },
      child: Container(
        width: MediaQuery.of(context).size.width / 1.5,
        padding: EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: Colors.teal, width: 1.8)),
        ),
        child: Row(
          children: [
            Text(countryFlag, style: TextStyle(fontSize: 18)),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                countryName,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.arrow_drop_down, color: Colors.grey[700]),
          ],
        ),
      ),
    );
  }
}

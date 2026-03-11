import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:wazz_up/screens/camera_screen.dart';
import 'package:wazz_up/screens/home_screen.dart';

Future<void> main() async  {
  WidgetsFlutterBinding.ensureInitialized();

  cameras = await availableCameras();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "OpenSans",
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF075E54),
          primary: const Color(0xFF075E54),
          secondary: const Color(0xFF128C7E),
        ),
      ),
      home: HomeScreen(),
    );
  }
}

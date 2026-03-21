import 'dart:io';
import 'package:flutter/material.dart';

class FullScreenImagePage extends StatelessWidget {
  const FullScreenImagePage({
    super.key,
    required this.imagePath,
    required this.tag,
  });

  final String imagePath;
  final String tag;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Center(
        child: Hero(
          tag: tag,
          child: InteractiveViewer(
            minScale: 0.8,
            maxScale: 4.0,
            child: Image.file(
              File(imagePath),
              fit: BoxFit.contain,
              errorBuilder: (context, error, stackTrace) {
                return const Text(
                  "No se pudo cargar la imagen",
                  style: TextStyle(color: Colors.white),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
import 'dart:io';

import 'package:flutter/material.dart';

class CameraView extends StatelessWidget {
  const CameraView({super.key, required this.path});
  final String path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.crop_rotate),
            iconSize: 27,
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.emoji_emotions_outlined),
            iconSize: 27,
          ),
          IconButton(onPressed: () {}, icon: Icon(Icons.title), iconSize: 27),
          IconButton(onPressed: () {}, icon: Icon(Icons.edit), iconSize: 27),
        ],
      ),
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: Stack(
          children: [
            SizedBox(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height - 150,
              child: Image.file(File(path), fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: TextFormField(
                  style: TextStyle(color: Colors.white, fontSize: 17),
                  minLines: 1,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: "Add caption...",
                    prefixIcon: Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                      size: 27,
                    ),
                    hintStyle: TextStyle(color: Colors.white, fontSize: 17),
                    suffixIcon: CircleAvatar(
                      radius: 27,
                      backgroundColor: Colors.tealAccent[700],
                      child: Icon(Icons.check, color: Colors.white, size: 27),
                    ),
                    border: InputBorder.none,
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

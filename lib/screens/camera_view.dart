import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatzapp/screens/camera_share_screen.dart';

class CameraView extends StatefulWidget {
  const CameraView({super.key, required this.path});

  final String path;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  final TextEditingController captionController = TextEditingController();

  @override
  void dispose() {
    captionController.dispose();
    super.dispose();
  }

  Future<void> _goToShareScreen() async {
    final result = await Navigator.push<Map<String, String>>(
      context,
      MaterialPageRoute(
        builder: (_) => CameraShareScreen(imagePath: widget.path),
      ),
    );

    if (!mounted || result == null) return;

    Navigator.pop(context, result);
  }

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
            icon: const Icon(Icons.crop_rotate),
            iconSize: 27,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.emoji_emotions_outlined),
            iconSize: 27,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.title),
            iconSize: 27,
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit),
            iconSize: 27,
          ),
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
              child: Image.file(File(widget.path), fit: BoxFit.cover),
            ),
            Positioned(
              bottom: 0,
              child: Container(
                color: Colors.black,
                width: MediaQuery.of(context).size.width,
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                child: TextFormField(
                  controller: captionController,
                  style: const TextStyle(color: Colors.white, fontSize: 17),
                  minLines: 1,
                  maxLines: 6,
                  decoration: InputDecoration(
                    hintText: "Add caption...",
                    prefixIcon: const Icon(
                      Icons.add_photo_alternate,
                      color: Colors.white,
                      size: 27,
                    ),
                    hintStyle: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                    ),
                    suffixIcon: GestureDetector(
                      onTap: _goToShareScreen,
                      child: CircleAvatar(
                        radius: 27,
                        backgroundColor: Colors.tealAccent[700],
                        child: const Icon(
                          Icons.arrow_forward,
                          color: Colors.white,
                          size: 27,
                        ),
                      ),
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
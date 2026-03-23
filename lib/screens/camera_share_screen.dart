import 'dart:io';
import 'package:flutter/material.dart';

class CameraShareScreen extends StatefulWidget {
  final String imagePath;

  const CameraShareScreen({super.key, required this.imagePath});

  @override
  State<CameraShareScreen> createState() => _CameraShareScreenState();
}

class _CameraShareScreenState extends State<CameraShareScreen> {
  final TextEditingController _captionCtrl = TextEditingController();

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  void _sendToChat() {
    Navigator.pop(context, {'action': 'send', 'path': widget.imagePath});
  }

  void _publishAsStatus() {
    Navigator.pop(context, {'action': 'status', 'path': widget.imagePath});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Send photo'),
        actions: [
          IconButton(onPressed: () {}, icon: const Icon(Icons.crop_rotate)),
          IconButton(
              onPressed: () {},
              icon: const Icon(Icons.emoji_emotions_outlined)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.title)),
          IconButton(onPressed: () {}, icon: const Icon(Icons.edit)),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.contain,
                ),
              ],
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: TextFormField(
              controller: _captionCtrl,
              style: const TextStyle(color: Colors.white, fontSize: 16),
              minLines: 1,
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add a caption...',
                hintStyle: TextStyle(color: Colors.white54, fontSize: 16),
                prefixIcon: Icon(Icons.add_photo_alternate,
                    color: Colors.white54, size: 26),
                border: InputBorder.none,
              ),
            ),
          ),
          Container(
            color: Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: const BorderSide(color: Colors.white38),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _publishAsStatus,
                    icon: const Icon(Icons.circle_outlined, size: 20),
                    label:
                        const Text('My Status', style: TextStyle(fontSize: 15)),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.greenAccent[700],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: _sendToChat,
                    icon: const Icon(Icons.send, color: Colors.white, size: 20),
                    label: const Text('Send',
                        style: TextStyle(color: Colors.white, fontSize: 15)),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

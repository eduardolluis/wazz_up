import 'package:emoji_picker_flutter/emoji_picker_flutter.dart';
import 'package:flutter/material.dart';

class EmojiSelect extends StatelessWidget {
  final TextEditingController controller;

  const EmojiSelect({super.key, required this.controller});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 300,
      child: EmojiPicker(
        onEmojiSelected: (category, emoji) {
          controller.text += emoji.emoji;
        },
      ),
    );
  }
}

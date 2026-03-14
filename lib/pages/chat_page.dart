import 'package:flutter/material.dart';
import 'package:wazz_up/customUI/custom_card.dart';
import 'package:wazz_up/model/chat_model.dart';
import 'package:wazz_up/screens/select_contact_screen.dart';
import 'package:wazz_up/data/contact_data.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key, required this.chatmodels});
  final List<ChatModel> chatmodels;

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (builder) => SelectContactPage()),
          );
        },
        child: Icon(Icons.chat),
      ),
      body: ListView.builder(
        itemCount: widget.chatmodels.length,
        itemBuilder: (context, index) {
          return CustomCard(chatModel: widget.chatmodels[index]);
        },
      ),
    );
  }
}

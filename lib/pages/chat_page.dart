import 'package:flutter/material.dart';
import 'package:wazz_up/customUI/custom_card.dart';
import 'package:wazz_up/model/chat_model.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  List<ChatModel> chats = [
    ChatModel(
      name: 'Eduardo',
      icon: 'person.svg',
      isGroup: false,
      time: '18:04',
      currentMessage: 'Hi there',
    ),
    ChatModel(
      name: 'Marcos',
      icon: 'person.svg',
      isGroup: false,
      time: '20:07',
      currentMessage: 'how you feeling?',
    ),
    ChatModel(
      name: 'David',
      icon: 'person.svg',
      isGroup: false,
      time: '14:13',
      currentMessage: 'how you feeling?',
    ),
    ChatModel(
      name: 'Elian',
      icon: 'groups.svg',
      isGroup: true,
      time: '15:16',
      currentMessage: 'hows everyone  feeling?',
    ),
    ChatModel(
      name: 'erik',
      icon: 'groups.svg',
      isGroup: true,
      time: '17:07',
      currentMessage: 'hey elian',
    ),
  ];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.chat),
      ),
      body: ListView.builder(
        itemCount: chats.length,
        itemBuilder: (context, index) {
          return CustomCard(chatModel: chats[index]);
        },
      ),
    );
  }
}

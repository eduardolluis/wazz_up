import 'package:flutter/material.dart';
import 'package:whatzapp/customUI/button_card.dart';
import 'package:whatzapp/model/chat_model.dart';
import 'package:whatzapp/screens/home_screen.dart';

class LoginScreenPage extends StatefulWidget {
  const LoginScreenPage({super.key});

  @override
  State<LoginScreenPage> createState() => _LoginScreenPageState();
}

class _LoginScreenPageState extends State<LoginScreenPage> {
  late ChatModel sourceChat;

  List<ChatModel> chatModels = [
    ChatModel(
      name: 'Eduardo',
      icon: 'person.svg',
      isGroup: false,
      time: '18:04',
      currentMessage: 'Hi there',
      status: 'A full stack developer',
      id: 1,
      uid: 'uid_1',
    ),
    ChatModel(
      name: 'Marcos',
      icon: 'person.svg',
      isGroup: false,
      time: '18:04',
      currentMessage: 'hellouuu there',
      status: 'x developer',
      id: 2,
      uid: 'uid_2',
    ),
    ChatModel(
      name: 'dadada',
      icon: 'person.svg',
      isGroup: false,
      time: '18:04',
      currentMessage: 'hellouuu there',
      status: 'junior',
      id: 3,
      uid: 'uid_3',
    ),
    ChatModel(
      name: 'malcom',
      icon: 'person.svg',
      isGroup: false,
      time: '18:04',
      currentMessage: 'klk cabeza',
      status: 'frontend',
      id: 4,
      uid: 'uid_4',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView.builder(
        itemCount: chatModels.length,
        itemBuilder: (BuildContext context, int index) => InkWell(
          onTap: () {
            sourceChat = chatModels.removeAt(index);

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (builder) => HomeScreen(
                  chatmodels: chatModels,
                  sourceChat: sourceChat,
                ),
              ),
            );
          },
          child: ButtonCard(
            name: chatModels[index].name,
            icon: Icons.person,
          ),
        ),
      ),
    );
  }
}

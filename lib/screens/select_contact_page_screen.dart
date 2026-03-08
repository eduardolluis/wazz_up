import 'package:flutter/material.dart';
import 'package:wazz_up/customUI/button_card.dart';
import 'package:wazz_up/customUI/contact_card.dart';
import 'package:wazz_up/model/chat_model.dart';

class SelectContactPage extends StatefulWidget {
  const SelectContactPage({super.key});

  @override
  State<SelectContactPage> createState() => _SelectContactPageState();
}

class _SelectContactPageState extends State<SelectContactPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    List<ChatModel> contacts = [
      ChatModel(
        name: 'Eduardo',
        icon: 'person.svg',
        isGroup: false,
        time: '18:04',
        currentMessage: 'Hi there',
        status: 'A full stack developer',
      ),
      ChatModel(
        name: 'Marcos',
        icon: 'person.svg',
        isGroup: false,
        time: '18:04',
        currentMessage: 'hellouuu there',
        status: ' x  developer',
      ),
      ChatModel(
        name: 'dadada',
        icon: 'person.svg',
        isGroup: false,
        time: '18:04',
        currentMessage: 'hellouuu there',
        status: ' junior  ',
      ),
      ChatModel(
        name: 'malcom',
        icon: 'person.svg',
        isGroup: false,
        time: '18:04',
        currentMessage: 'klk cabeza ',
        status: 'fronted  ',
      ),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select Contact",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Text("256 contacts", style: TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.search, size: 26)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              debugPrint(value);
            },
            itemBuilder: (context) {
              return [
                const PopupMenuItem(
                  value: "Invite a friend",
                  child: Text("Invite a friend"),
                ),
                const PopupMenuItem(value: "Contacts", child: Text("Contacts")),
                const PopupMenuItem(value: "Help", child: Text("Help")),
                const PopupMenuItem(value: "Refresh", child: Text("Refresh")),
              ];
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: contacts.length + 2,
        itemBuilder: (BuildContext context, index) {
          if (index == 0) {
            return ButtonCard(icon: Icons.group, name: "New Group");
          } else if (index == 1) {
            return ButtonCard(icon: Icons.person_add, name: "New Contact");
          } else {
            return ContactCard(contact: contacts[index - 2]);
          }
        },
      ),
    );
  }
}

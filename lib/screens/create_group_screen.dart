import 'package:flutter/material.dart';
import 'package:wazz_up/customUI/contact_card.dart';
import 'package:wazz_up/data/contact_data.dart';
import 'package:wazz_up/model/chat_model.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    List<ChatModel> group = [];
    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: const [
            Text(
              "New Group",
              style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
            ),
            Text("Add participants", style: TextStyle(fontSize: 13)),
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
        itemCount: contacts.length,
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              if (contacts[index].select == false) {
                setState(() {
                  contacts[index].select = true;
                  group.add(contacts[index]);
                });
              } else {
                setState(() {
                  contacts[index].select = false;
                  group.remove(contacts[index]);
                });
              }
            },
            child: ContactCard(contact: contacts[index]),
          );
        },
      ),
    );
  }
}

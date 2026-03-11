import 'package:flutter/material.dart';
import 'package:wazz_up/customUI/avatar_card.dart';
import 'package:wazz_up/customUI/contact_card.dart';
import 'package:wazz_up/data/contact_data.dart';
import 'package:wazz_up/model/chat_model.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  List<ChatModel> groupMember = [];

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

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
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, size: 26),
          ),
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
      body: Stack(
        children: [
          ListView.builder(
            itemCount: contacts.length + 1,
            itemBuilder: (BuildContext context, int index) {
              if (index == 0) {
                return Container(height: groupMember.isNotEmpty ? 90 : 10);
              }

              return InkWell(
                onTap: () {
                  setState(() {
                    if (contacts[index - 1].select == true) {
                      contacts[index - 1].select = false;
                      groupMember.remove(contacts[index - 1]);
                    } else {
                      contacts[index - 1].select = true;
                      groupMember.add(contacts[index - 1]);
                    }
                  });
                },
                child: ContactCard(contact: contacts[index - 1]),
              );
            },
          ),
          groupMember.isNotEmpty
              ? Column(
                  children: [
                    Container(
                      height: 75,
                      color: Colors.white,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: contacts.length,
                        itemBuilder: (BuildContext context, int index) {
                          if (contacts[index].select == true) {
                            return InkWell(
                              onTap: () {
                                setState(() {
                                  groupMember.remove(contacts[index]);
                                  contacts[index].select = false;
                                });
                              },
                              child: AvatarCard(contact: contacts[index]),
                            );
                          } else {
                            return Container();
                          }
                        },
                      ),
                    ),
                    const Divider(thickness: 1),
                  ],
                )
              : Container(),
        ],
      ),
    );
  }
}

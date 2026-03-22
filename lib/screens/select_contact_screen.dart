import 'package:flutter/material.dart';
import 'package:whatzapp/customUI/button_card.dart';
import 'package:whatzapp/customUI/contact_card.dart';
import 'package:whatzapp/screens/add_contact_screen.dart';
import 'package:whatzapp/screens/create_group_screen.dart';
import 'package:whatzapp/data/contact_data.dart';
import 'package:whatzapp/screens/individual_screen.dart';

class SelectContactPage extends StatefulWidget {
  const SelectContactPage({super.key});

  @override
  State<SelectContactPage> createState() => _SelectContactPageState();
}

class _SelectContactPageState extends State<SelectContactPage> {
  final String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final filtered = chatModels
        .where((c) =>
            c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Select Contact',
                style: TextStyle(
                    fontSize: 19, fontWeight: FontWeight.bold)),
            Text('${filtered.length} contactos',
                style: const TextStyle(fontSize: 13)),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ContactSearch(contacts: chatModels),
              );
            },
            icon: const Icon(Icons.search, size: 26),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              if (value == 'Invite a friend') {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Invitar amigo...')),
                );
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: "Invite a friend",
                  child: Text("Invite a friend")),
              PopupMenuItem(
                  value: "Contacts", child: Text("Contacts")),
              PopupMenuItem(value: "Help", child: Text("Help")),
              PopupMenuItem(value: "Refresh", child: Text("Refresh")),
            ],
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: filtered.length + 2,
        itemBuilder: (context, index) {
          if (index == 0) {
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const CreateGroupPage()),
                );
              },
              child:
                  const ButtonCard(icon: Icons.group, name: "New Group"),
            );
          } else if (index == 1) {
            return InkWell(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const AddContactPage()),
                );
                setState(() {}); // refresh after adding
              },
              child: const ButtonCard(
                  icon: Icons.person_add, name: "New Contact"),
            );
          } else {
            final contact = filtered[index - 2];
            return InkWell(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => IndividualPage(
                      chatModel: contact,
                      sourceChat: sourceChat,
                    ),
                  ),
                );
              },
              child: ContactCard(contact: contact),
            );
          }
        },
      ),
    );
  }
}

class _ContactSearch extends SearchDelegate {
  final List contacts;

  _ContactSearch({required this.contacts});

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
            onPressed: () => query = '',
            icon: const Icon(Icons.clear))
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        onPressed: () => close(context, null),
        icon: const Icon(Icons.arrow_back),
      );

  @override
  Widget buildResults(BuildContext context) => _list(context);

  @override
  Widget buildSuggestions(BuildContext context) => _list(context);

  Widget _list(BuildContext context) {
    final results = contacts
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => InkWell(
        onTap: () {
          close(context, null);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IndividualPage(
                chatModel: results[i],
                sourceChat: sourceChat,
              ),
            ),
          );
        },
        child: ContactCard(contact: results[i]),
      ),
    );
  }
}
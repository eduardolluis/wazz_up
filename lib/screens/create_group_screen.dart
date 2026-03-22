import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatzapp/customUI/avatar_card.dart';
import 'package:whatzapp/customUI/contact_card.dart';
import 'package:whatzapp/data/contact_data.dart';
import 'package:whatzapp/model/chat_model.dart';
import 'package:whatzapp/screens/home_screen.dart';

// ────────────────────────────────────────────────────────────────────────────
// Step 1: pick participants
// ────────────────────────────────────────────────────────────────────────────
class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  List<ChatModel> groupMember = [];
  final String _searchQuery = '';

  List<ChatModel> get _filtered => chatModels
      .where((c) =>
          c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: groupMember.isNotEmpty
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('New Group',
                      style: TextStyle(
                          fontSize: 19, fontWeight: FontWeight.bold)),
                  Text('${groupMember.length} of ${chatModels.length} selected',
                      style: const TextStyle(fontSize: 13)),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text('New Group',
                      style: TextStyle(
                          fontSize: 19, fontWeight: FontWeight.bold)),
                  Text('Add participants',
                      style: TextStyle(fontSize: 13)),
                ],
              ),
        actions: [
          IconButton(
            onPressed: () {
              showSearch(
                context: context,
                delegate: _ContactSearchDelegate(
                  contacts: chatModels,
                  selected: groupMember,
                  onToggle: (c) {
                    setState(() {
                      if (c.select) {
                        c.select = false;
                        groupMember.remove(c);
                      } else {
                        c.select = true;
                        groupMember.add(c);
                      }
                    });
                  },
                ),
              );
            },
            icon: const Icon(Icons.search, size: 26),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) => debugPrint(value),
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
      floatingActionButton: groupMember.isNotEmpty
          ? FloatingActionButton(
              backgroundColor: cs.secondary,
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        GroupNamePage(members: groupMember),
                  ),
                );
              },
              child: const Icon(Icons.arrow_forward,
                  color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(
                    height: groupMember.isNotEmpty ? 90 : 10);
              }
              return InkWell(
                onTap: () {
                  setState(() {
                    if (_filtered[index - 1].select) {
                      _filtered[index - 1].select = false;
                      groupMember.remove(_filtered[index - 1]);
                    } else {
                      _filtered[index - 1].select = true;
                      groupMember.add(_filtered[index - 1]);
                    }
                  });
                },
                child: ContactCard(contact: _filtered[index - 1]),
              );
            },
          ),
          if (groupMember.isNotEmpty)
            Column(
              children: [
                Container(
                  height: 75,
                  color: Colors.white,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: chatModels.length,
                    itemBuilder: (_, index) {
                      if (chatModels[index].select) {
                        return InkWell(
                          onTap: () {
                            setState(() {
                              groupMember.remove(chatModels[index]);
                              chatModels[index].select = false;
                            });
                          },
                          child: AvatarCard(
                              contact: chatModels[index]),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),
                ),
                const Divider(thickness: 1),
              ],
            ),
        ],
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Step 2: set group name + icon
// ────────────────────────────────────────────────────────────────────────────
class GroupNamePage extends StatefulWidget {
  final List<ChatModel> members;
  const GroupNamePage({super.key, required this.members});

  @override
  State<GroupNamePage> createState() => _GroupNamePageState();
}

class _GroupNamePageState extends State<GroupNamePage> {
  final TextEditingController _nameCtrl = TextEditingController();
  File? _groupImage;
  bool _isCreating = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final result =
        await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() => _groupImage = File(result.path));
    }
  }

  Future<void> _createGroup() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text("Por favor ingresa un nombre para el grupo")),
      );
      return;
    }

    setState(() => _isCreating = true);

    // Simulate creating and adding to chat list
    await Future.delayed(const Duration(milliseconds: 600));

    final newGroup = ChatModel(
      name: _nameCtrl.text.trim(),
      icon: 'groups.svg',
      isGroup: true,
      time: TimeOfDay.now().format(context),
      currentMessage: 'Grupo creado',
      status: '${widget.members.length} participantes',
      select: false,
      id: DateTime.now().millisecondsSinceEpoch,
    );

    chatModels.add(newGroup);

    // Reset all selections
    for (final m in widget.members) {
      m.select = false;
    }

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
          content: Text(
              'Grupo "${newGroup.name}" creado con ${widget.members.length} miembros')),
    );

    // Go back to home
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const HomeScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('New Group',
            style:
                TextStyle(fontSize: 19, fontWeight: FontWeight.bold)),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 20),
            GestureDetector(
              onTap: _pickImage,
              child: Stack(
                children: [
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.blueGrey[300],
                    backgroundImage: _groupImage != null
                        ? FileImage(_groupImage!)
                        : null,
                    child: _groupImage == null
                        ? const Icon(Icons.group,
                            size: 50, color: Colors.white)
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: cs.secondary,
                      child: const Icon(Icons.camera_alt,
                          size: 18, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _nameCtrl,
              autofocus: true,
              maxLength: 25,
              decoration: InputDecoration(
                hintText: 'Group name',
                enabledBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: cs.secondary, width: 1.8),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide:
                      BorderSide(color: cs.secondary, width: 2.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Members preview
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Participantes: ${widget.members.length}',
                style: TextStyle(
                    color: Colors.grey[700],
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              height: 70,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: widget.members.length,
                itemBuilder: (_, i) {
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueGrey[300],
                          child: Text(
                            widget.members[i].name[0].toUpperCase(),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.members[i].name.split(' ').first,
                          style: const TextStyle(fontSize: 11),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.secondary,
        onPressed: _isCreating ? null : _createGroup,
        child: _isCreating
            ? const CircularProgressIndicator(color: Colors.white)
            : const Icon(Icons.check, color: Colors.white),
      ),
    );
  }
}

// ────────────────────────────────────────────────────────────────────────────
// Search delegate for contacts
// ────────────────────────────────────────────────────────────────────────────
class _ContactSearchDelegate extends SearchDelegate<ChatModel?> {
  final List<ChatModel> contacts;
  final List<ChatModel> selected;
  final Function(ChatModel) onToggle;

  _ContactSearchDelegate({
    required this.contacts,
    required this.selected,
    required this.onToggle,
  });

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
  Widget buildResults(BuildContext context) => _buildList();

  @override
  Widget buildSuggestions(BuildContext context) => _buildList();

  Widget _buildList() {
    final results = contacts
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();
    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => CheckboxListTile(
        value: results[i].select,
        onChanged: (_) => onToggle(results[i]),
        title: Text(results[i].name),
        subtitle: Text(results[i].status),
        secondary: CircleAvatar(
          child: Text(results[i].name[0].toUpperCase()),
        ),
      ),
    );
  }
}
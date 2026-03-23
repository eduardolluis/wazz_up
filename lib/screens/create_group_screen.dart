import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatzapp/customUI/avatar_card.dart';
import 'package:whatzapp/customUI/contact_card.dart';
import 'package:whatzapp/data/contact_data.dart';
import 'package:whatzapp/model/chat_model.dart';
import 'package:whatzapp/screens/home_screen.dart';

class CreateGroupPage extends StatefulWidget {
  const CreateGroupPage({super.key});

  @override
  State<CreateGroupPage> createState() => _CreateGroupPageState();
}

class _CreateGroupPageState extends State<CreateGroupPage> {
  final List<ChatModel> groupMember = [];
  final String _searchQuery = '';

  List<ChatModel> get _filtered => chatModels
      .where((c) => c.name.toLowerCase().contains(_searchQuery.toLowerCase()))
      .toList();

  bool _isSelected(ChatModel chat) {
    return groupMember.any((m) => m.uid == chat.uid);
  }

  void _toggleMember(ChatModel chat) {
    setState(() {
      final index = groupMember.indexWhere((m) => m.uid == chat.uid);
      if (index >= 0) {
        groupMember.removeAt(index);
      } else {
        groupMember.add(chat);
      }
    });
  }

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
                  const Text(
                    'New Group',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    '${groupMember.length} of ${chatModels.length} selected',
                    style: const TextStyle(fontSize: 13),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'New Group',
                    style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
                  ),
                  Text(
                    'Add participants',
                    style: TextStyle(fontSize: 13),
                  ),
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
                  onToggle: (c) => _toggleMember(c),
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
                value: 'Invite a friend',
                child: Text('Invite a friend'),
              ),
              PopupMenuItem(
                value: 'Contacts',
                child: Text('Contacts'),
              ),
              PopupMenuItem(
                value: 'Help',
                child: Text('Help'),
              ),
              PopupMenuItem(
                value: 'Refresh',
                child: Text('Refresh'),
              ),
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
                    builder: (_) => GroupNamePage(members: groupMember),
                  ),
                );
              },
              child: const Icon(Icons.arrow_forward, color: Colors.white),
            )
          : null,
      body: Stack(
        children: [
          ListView.builder(
            itemCount: _filtered.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return Container(height: groupMember.isNotEmpty ? 90 : 10);
              }

              final contact = _filtered[index - 1];

              return InkWell(
                onTap: () => _toggleMember(contact),
                child: ContactCard(contact: contact),
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
                    itemCount: groupMember.length,
                    itemBuilder: (_, index) {
                      final member = groupMember[index];
                      return InkWell(
                        onTap: () => _toggleMember(member),
                        child: AvatarCard(contact: member),
                      );
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
    final result = await picker.pickImage(source: ImageSource.gallery);
    if (result != null) {
      setState(() => _groupImage = File(result.path));
    }
  }

  Future<void> _createGroup() async {
    final groupName = _nameCtrl.text.trim();

    if (groupName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for the group'),
        ),
      );
      return;
    }

    setState(() => _isCreating = true);

    try {
      await Future.delayed(const Duration(milliseconds: 600));

      final now = DateTime.now();
      final groupUid = 'group_${now.millisecondsSinceEpoch}';

      final newGroup = ChatModel(
        name: groupName,
        icon: 'groups.svg',
        isGroup: true,
        time: TimeOfDay.now().format(context),
        currentMessage: 'Group created',
        status: '${widget.members.length} participants',
        id: now.millisecondsSinceEpoch,
        uid: groupUid,
      );

      chatModels.add(newGroup);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Group "${newGroup.name}" created with ${widget.members.length} members',
          ),
        ),
      );

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const HomeScreen()),
        (route) => false,
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error creating group: $e')),
      );
    } finally {
      if (mounted) {
        setState(() => _isCreating = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text(
          'New Group',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold),
        ),
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
                    backgroundImage:
                        _groupImage != null ? FileImage(_groupImage!) : null,
                    child: _groupImage == null
                        ? const Icon(
                            Icons.group,
                            size: 50,
                            color: Colors.white,
                          )
                        : null,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: CircleAvatar(
                      radius: 17,
                      backgroundColor: cs.secondary,
                      child: const Icon(
                        Icons.camera_alt,
                        size: 18,
                        color: Colors.white,
                      ),
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
                  borderSide: BorderSide(color: cs.secondary, width: 1.8),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: cs.secondary, width: 2.5),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Participants: ${widget.members.length}',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.bold,
                ),
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
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: Column(
                      children: [
                        CircleAvatar(
                          backgroundColor: Colors.blueGrey[300],
                          child: Text(
                            widget.members[i].name[0].toUpperCase(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
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

class _ContactSearchDelegate extends SearchDelegate<ChatModel?> {
  final List<ChatModel> contacts;
  final List<ChatModel> selected;
  final Function(ChatModel) onToggle;

  _ContactSearchDelegate({
    required this.contacts,
    required this.selected,
    required this.onToggle,
  });

  bool _isSelected(ChatModel chat) {
    return selected.any((m) => m.uid == chat.uid);
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        IconButton(
          onPressed: () => query = '',
          icon: const Icon(Icons.clear),
        ),
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
        .where((c) => c.name.toLowerCase().contains(query.toLowerCase()))
        .toList();

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) => CheckboxListTile(
        value: _isSelected(results[i]),
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

import 'package:flutter/material.dart';
import 'package:wazz_up/model/chat_model.dart';
import 'package:wazz_up/pages/camera_page.dart';
import 'package:wazz_up/pages/chat_page.dart';
import 'package:wazz_up/pages/status_page.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.chatmodels, required this.sourceChat});
  final List<ChatModel> chatmodels;
  final ChatModel sourceChat;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this, initialIndex: 1);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'WhatsApp Clone',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              print(value);
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: "New group", child: Text("New group")),
                PopupMenuItem(
                  value: "New broadcast",
                  child: Text("New broadcast"),
                ),
                PopupMenuItem(
                  value: "Linked devices",
                  child: Text("Linked devices"),
                ),
                PopupMenuItem(
                  value: "Starred messages",
                  child: Text("Starred messages"),
                ),
                PopupMenuItem(value: "Settings", child: Text("Settings")),
              ];
            },
          ),
        ],
        bottom: TabBar(
          controller: _controller,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          indicatorColor: Colors.white,
          tabs: const [
            Tab(icon: Icon(Icons.camera_alt)),
            Tab(text: "Chats"),
            Tab(text: "Status"),
            Tab(text: "Calls"),
          ],
        ),
      ),
      body: TabBarView(
        controller: _controller,
        children: [
          Center(child: CameraPage()),
          Center(child: ChatPage(chatmodels: widget.chatmodels, sourceChat: widget.sourceChat,)),
          Center(child: StatusPage()),
          Center(child: Text("Calls")),
        ],
      ),
    );
  }
}

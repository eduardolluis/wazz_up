import 'package:flutter/material.dart';
import 'package:whatzapp/data/contact_data.dart';
import 'package:whatzapp/model/chat_model.dart';
import 'package:whatzapp/pages/camera_page.dart';
import 'package:whatzapp/pages/calls_page.dart';
import 'package:whatzapp/pages/chat_page.dart';
import 'package:whatzapp/pages/status_page.dart';
import 'package:whatzapp/screens/search_screen.dart';
import 'package:whatzapp/screens/settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, this.chatmodels, this.sourceChat});

  final List<ChatModel>? chatmodels;
  final ChatModel? sourceChat;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  List<ChatModel> get resolvedChats => widget.chatmodels ?? chatModels;
  ChatModel get resolvedSource => widget.sourceChat ?? sourceChat;

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

  void _showStarredMessages() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Mensajes destacados',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            Expanded(
              child: ListView(
                controller: ctrl,
                children: const [
                  ListTile(
                    leading: Icon(Icons.star, color: Colors.amber),
                    title: Text('No hay mensajes destacados'),
                    subtitle: Text(
                        'Mantén presionado un mensaje y toca la estrella para destacarlo'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLinkedDevices() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.55,
        expand: false,
        builder: (_, ctrl) => Column(
          children: [
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Dispositivos vinculados',
                style:
                    TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                'Vincula un dispositivo para usar WhatZapp en tu computadora o tablet sin necesidad de tu teléfono.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Theme.of(context).colorScheme.secondary,
              ),
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.qr_code, color: Colors.white),
              label: const Text(
                'Vincular un dispositivo',
                style: TextStyle(color: Colors.white),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView(
                controller: ctrl,
                children: const [
                  Center(
                    child: Padding(
                      padding: EdgeInsets.all(16),
                      child: Text(
                        'No hay dispositivos vinculados',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
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
            onPressed: () {
              showSearch(
                context: context,
                delegate: ChatSearchDelegate(
                  chats: resolvedChats,
                  sourceChat: resolvedSource,
                ),
              );
            },
            icon: const Icon(Icons.search, color: Colors.white),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              switch (value) {
                case 'New group':
                  // Handled in ChatPage FAB
                  break;
                case 'Linked devices':
                  _showLinkedDevices();
                  break;
                case 'Starred messages':
                  _showStarredMessages();
                  break;
                case 'Settings':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const SettingsPage()),
                  );
                  break;
                default:
                  debugPrint(value);
              }
            },
            itemBuilder: (context) => const [
              PopupMenuItem(
                  value: "New group", child: Text("New group")),
              PopupMenuItem(
                  value: "New broadcast",
                  child: Text("New broadcast")),
              PopupMenuItem(
                  value: "Linked devices",
                  child: Text("Linked devices")),
              PopupMenuItem(
                  value: "Starred messages",
                  child: Text("Starred messages")),
              PopupMenuItem(
                  value: "Settings", child: Text("Settings")),
            ],
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
          const CameraPage(),
          ChatPage(
              chatmodels: resolvedChats, sourceChat: resolvedSource),
          const StatusPage(),
          const CallsPage(),
        ],
      ),
    );
  }
}
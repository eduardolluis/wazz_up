import 'package:flutter/material.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TabController(length: 4, vsync: this, initialIndex: 0);
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
        actions: const [
          Icon(Icons.search),
          SizedBox(width: 8),
          Icon(Icons.more_vert),
          SizedBox(width: 8),
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
        children: const [
          Center(child: Text("Camera")),
          Center(child: Text("Chats")),
          Center(child: Text("Status")),
          Center(child: Text("Calls")),
        ],
      ),
    );
  }
}

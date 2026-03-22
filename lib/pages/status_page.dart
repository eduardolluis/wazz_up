import 'package:flutter/material.dart';
import 'package:whatzapp/customUI/StatusPage/head_own_status.dart';
import 'package:whatzapp/customUI/StatusPage/other_status.dart';
import 'package:whatzapp/screens/status_viewer._screen.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  void _openStatus({
    required String name,
    required String time,
    required String imageName,
    required bool isSeen,
    required int statusNum,
  }) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => StatusViewerPage(
          name: name,
          time: time,
          statusNum: statusNum,
        ),
      ),
    ).then((_) {
      // Mark as seen when returning
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          SizedBox(
            height: 48,
            child: FloatingActionButton(
              heroTag: 'edit_status',
              backgroundColor: Colors.blueGrey[100],
              elevation: 8,
              onPressed: () => _showAddStatusOptions(),
              child: Icon(Icons.edit, color: Colors.blueGrey[900]),
            ),
          ),
          const SizedBox(height: 13),
          FloatingActionButton(
            heroTag: 'camera_status',
            onPressed: () => _showAddStatusOptions(),
            backgroundColor: Colors.greenAccent[700],
            elevation: 5,
            child: const Icon(Icons.camera_alt),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            HeadOwnStatus(),
            label("Recent updates", context),
            GestureDetector(
              onTap: () => _openStatus(
                name: 'Bonilla Garcia',
                time: '04:23',
                imageName: '/assets/pfp-1.jpg',
                isSeen: false,
                statusNum: 1,
              ),
              child: const OtherStatus(
                name: 'Bonilla Garcia  ',
                time: '04:23',
                imageName: '/assets/pfp-1.jpg',
                isSeen: true,
                statusNum: 1,
              ),
            ),
            GestureDetector(
              onTap: () => _openStatus(
                name: 'Marcos Cruz',
                time: '07:23',
                imageName: '/assets/pfp-3.jpg',
                isSeen: false,
                statusNum: 2,
              ),
              child: const OtherStatus(
                name: 'Marcos  Cruz',
                time: '07:23',
                imageName: '/assets/pfp-3.jpg',
                isSeen: true,
                statusNum: 2,
              ),
            ),
            GestureDetector(
              onTap: () => _openStatus(
                name: 'De los Santos',
                time: '01:00',
                imageName: '/assets/pfp-3.jpg',
                isSeen: false,
                statusNum: 3,
              ),
              child: const OtherStatus(
                name: 'De los Santos  ',
                time: '01:00',
                imageName: '/assets/pfp-3.jpg',
                isSeen: true,
                statusNum: 3,
              ),
            ),
            const SizedBox(height: 10),
            label('Viewed updates', context),
            GestureDetector(
              onTap: () => _openStatus(
                name: 'Bonilla Garcia',
                time: '04:23',
                imageName: '/assets/pfp-1.jpg',
                isSeen: true,
                statusNum: 4,
              ),
              child: const OtherStatus(
                name: 'Bonilla Garcia  ',
                time: '04:23',
                imageName: '/assets/pfp-1.jpg',
                isSeen: false,
                statusNum: 4,
              ),
            ),
            GestureDetector(
              onTap: () => _openStatus(
                name: 'Marcos Cruz',
                time: '07:23',
                imageName: '/assets/pfp-3.jpg',
                isSeen: true,
                statusNum: 5,
              ),
              child: const OtherStatus(
                name: 'Marcos  Cruz',
                time: '07:23',
                imageName: '/assets/pfp-3.jpg',
                isSeen: false,
                statusNum: 20,
              ),
            ),
            const SizedBox(height: 100),
          ],
        ),
      ),
    );
  }

  void _showAddStatusOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt, color: Colors.teal),
              title: const Text('Foto o video'),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              leading: const Icon(Icons.text_fields, color: Colors.teal),
              title: const Text('Estado de texto'),
              onTap: () {
                Navigator.pop(context);
                _showTextStatusEditor();
              },
            ),
            ListTile(
              leading: const Icon(Icons.gif, color: Colors.teal),
              title: const Text('GIF'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _showTextStatusEditor() {
    final ctrl = TextEditingController();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.black,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: Container(
          height: 300,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const Text('Nuevo estado',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                autofocus: true,
                maxLength: 700,
                maxLines: 5,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: const InputDecoration(
                  hintText: '¿Qué quieres compartir?',
                  hintStyle: TextStyle(color: Colors.white38),
                  border: InputBorder.none,
                  counterStyle: TextStyle(color: Colors.white54),
                ),
              ),
              const Spacer(),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.greenAccent[700]),
                onPressed: () {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Estado publicado')),
                  );
                },
                child: const Text('Publicar',
                    style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

Widget label(String labelName, BuildContext context) {
  return Container(
    height: 33,
    width: MediaQuery.of(context).size.width,
    color: Colors.grey[300],
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      child: Text(
        labelName,
        style:
            const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    ),
  );
}
import 'package:flutter/material.dart';

class HeadOwnStatus extends StatefulWidget {
  const HeadOwnStatus({super.key});

  @override
  State<HeadOwnStatus> createState() => _HeadOwnStatusState();
}

class _HeadOwnStatusState extends State<HeadOwnStatus> {
  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: Colors.white,
            backgroundImage: AssetImage("assets/pfp-1.jpg"),
          ),
          Positioned(
            bottom: 0,
            right: 0,

            child: CircleAvatar(
              backgroundColor: Colors.greenAccent[700],
              radius: 10,
              child: Icon(Icons.add, size: 20, color: Colors.blueGrey[900]),
            ),
          ),
        ],
      ),
      title: Text(
        "My Status",
        style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
      ),
      subtitle: Text(
        "Tap to add status update",
        style: TextStyle(color: Colors.grey[900]),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:whatzapp/customUI/StatusPage/head_own_status.dart';
import 'package:whatzapp/customUI/StatusPage/other_status.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        children: [
          SizedBox(
            height: 48,
            child: FloatingActionButton(
              backgroundColor: Colors.blueGrey[100],
              elevation: 8,
              onPressed: () {},
              child: Icon(Icons.edit, color: Colors.blueGrey[900]),
            ),
          ),
          SizedBox(height: 13),
          FloatingActionButton(
            onPressed: () {},
            backgroundColor: Colors.greenAccent[700],
            elevation: 5,
            child: Icon(Icons.camera_alt),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // SizedBox(height: 10),
            HeadOwnStatus(),
            label("Recent updates", context),
            OtherStatus(
              name: 'Bonilla Garcia  ',
              time: '04:23',
              imageName: '/assets/pfp-1.jpg',
            ),
            OtherStatus(
              name: 'Marcos  Cruz',
              time: '07:23',
              imageName: '/assets/pfp-3.jpg',
            ),
            OtherStatus(
              name: 'De los Santos  ',
              time: '01:00',
              imageName: '/assets/pfp-3.jpg',
            ),
            SizedBox(height: 10),
            label('Viewed updates', context),
            OtherStatus(
              name: 'Bonilla Garcia  ',
              time: '04:23',
              imageName: '/assets/pfp-1.jpg',
            ),
            OtherStatus(
              name: 'Marcos  Cruz',
              time: '07:23',
              imageName: '/assets/pfp-3.jpg',
            ),
          ],
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
        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
      ),
    ),
  );
}

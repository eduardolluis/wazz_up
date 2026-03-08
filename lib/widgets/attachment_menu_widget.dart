import 'package:flutter/material.dart';

class AttachmentMenu extends StatelessWidget {
  const AttachmentMenu({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 280,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: GridView.count(
        crossAxisCount: 3,
        mainAxisSpacing: 20,
        crossAxisSpacing: 20,
        physics: const NeverScrollableScrollPhysics(),
        children: const [
          AttachmentItem(
            icon: Icons.insert_drive_file,
            color: Colors.indigo,
            label: 'Document',
          ),
          AttachmentItem(
            icon: Icons.camera_alt,
            color: Colors.pink,
            label: 'Camera',
          ),
          AttachmentItem(
            icon: Icons.image,
            color: Colors.purple,
            label: 'Gallery',
          ),
          AttachmentItem(
            icon: Icons.headphones,
            color: Colors.orange,
            label: 'Audio',
          ),
          AttachmentItem(
            icon: Icons.location_on,
            color: Colors.teal,
            label: 'Location',
          ),
          AttachmentItem(
            icon: Icons.person,
            color: Colors.blue,
            label: 'Contact',
          ),
        ],
      ),
    );
  }
}

class AttachmentItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;

  const AttachmentItem({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: color,
          child: Icon(icon, color: Colors.white, size: 28),
        ),
        const SizedBox(height: 8),
        Text(label, style: const TextStyle(fontSize: 13)),
      ],
    );
  }
}

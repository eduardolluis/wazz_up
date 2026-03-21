import 'package:flutter/material.dart';
import 'package:whatzapp/screens/camera_screen.dart';

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
        children: [
          const AttachmentItem(
            icon: Icons.insert_drive_file,
            color: Colors.indigo,
            label: 'Document',
          ),
          AttachmentItem(
            icon: Icons.camera_alt,
            color: Colors.pink,
            label: 'Camera',
            onTap: () {
              Navigator.pop(context); // cierra el bottom sheet
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );
            },
          ),
          const AttachmentItem(
            icon: Icons.image,
            color: Colors.purple,
            label: 'Gallery',
          ),
          const AttachmentItem(
            icon: Icons.headphones,
            color: Colors.orange,
            label: 'Audio',
          ),
          const AttachmentItem(
            icon: Icons.location_on,
            color: Colors.teal,
            label: 'Location',
          ),
          const AttachmentItem(
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
  final VoidCallback? onTap;

  const AttachmentItem({
    super.key,
    required this.icon,
    required this.color,
    required this.label,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
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
      ),
    );
  }
}

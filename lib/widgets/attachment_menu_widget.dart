import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_contacts/flutter_contacts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatzapp/screens/camera_screen.dart';

class AttachmentMenu extends StatelessWidget {
  final Function(String path, String type)? onAttachment;

  const AttachmentMenu({super.key, this.onAttachment});

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
          AttachmentItem(
            icon: Icons.insert_drive_file,
            color: Colors.indigo,
            label: 'Document',
            onTap: () async {
              Navigator.pop(context);

              final result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowedExtensions: ['pdf', 'doc', 'docx', 'txt', 'xls', 'xlsx'],
              );

              if (result != null && result.files.single.path != null) {
                final path = result.files.single.path!;
                final name = result.files.single.name;
                onAttachment?.call('📄 $name|$path', 'document');
              }
            },
          ),
          AttachmentItem(
            icon: Icons.camera_alt,
            color: Colors.pink,
            label: 'Camera',
            onTap: () async {
              Navigator.pop(context);

              final imagePath = await Navigator.push<String>(
                context,
                MaterialPageRoute(builder: (_) => const CameraScreen()),
              );

              if (imagePath != null && imagePath.isNotEmpty) {
                onAttachment?.call(imagePath, 'image');
              }
            },
          ),
          AttachmentItem(
            icon: Icons.image,
            color: Colors.purple,
            label: 'Gallery',
            onTap: () async {
              Navigator.pop(context);

              final picker = ImagePicker();
              final picked = await picker.pickImage(
                source: ImageSource.gallery,
              );

              if (picked != null) {
                onAttachment?.call(picked.path, 'image');
              }
            },
          ),
          AttachmentItem(
            icon: Icons.headphones,
            color: Colors.orange,
            label: 'Audio',
            onTap: () async {
              Navigator.pop(context);

              final result = await FilePicker.platform.pickFiles(
                type: FileType.audio,
              );

              if (result != null && result.files.single.path != null) {
                final path = result.files.single.path!;
                onAttachment?.call(path, 'audio');
              }
            },
          ),
          AttachmentItem(
            icon: Icons.location_on,
            color: Colors.teal,
            label: 'Location',
            onTap: () async {
              Navigator.pop(context);
              await _sendLocation(context, onAttachment);
            },
          ),
          AttachmentItem(
            icon: Icons.person,
            color: Colors.blue,
            label: 'Contact',
            onTap: () async {
              Navigator.pop(context);
              await _pickContact(context, onAttachment);
            },
          ),
        ],
      ),
    );
  }

  static Future<void> _sendLocation(
    BuildContext context,
    Function(String, String)? onAttachment,
  ) async {
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor activa el GPS')),
        );
      }
      return;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Permiso de ubicación denegado')),
          );
        }
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Activa el permiso de ubicación en ajustes'),
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Obteniendo ubicación...')),
      );
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final lat = position.latitude.toStringAsFixed(6);
      final lng = position.longitude.toStringAsFixed(6);

      onAttachment?.call('📍 Ubicación: $lat, $lng', 'location');
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error obteniendo ubicación: $e')),
        );
      }
    }
  }

  static Future<void> _pickContact(
    BuildContext context,
    Function(String, String)? onAttachment,
  ) async {
    final status = await FlutterContacts.permissions.request(
      PermissionType.read,
    );

    if (status != PermissionStatus.granted) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permiso de contactos denegado')),
        );
      }
      return;
    }

    final contacts = await FlutterContacts.getAll(
      properties: {ContactProperty.phone},
    );

    if (!context.mounted) return;

    if (contacts.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No hay contactos en el dispositivo')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => SizedBox(
        height: MediaQuery.of(context).size.height * 0.75,
        child: _ContactPickerSheet(
          contacts: contacts,
          onSelect: (contact) {
            final name = _contactName(contact);
            final phone = _contactPhone(contact);

            onAttachment?.call(
              '👤 ${name.isNotEmpty ? name : 'Sin nombre'}: $phone',
              'contact',
            );
          },
        ),
      ),
    );
  }
}

String _contactName(Contact contact) {
  final dynamic raw = contact.displayName;
  return (raw?.toString() ?? '').trim();
}

String _contactPhone(Contact contact) {
  if (contact.phones.isEmpty) return 'Sin número';

  final dynamic raw = contact.phones.first.number;
  final phone = raw?.toString().trim() ?? '';

  return phone.isNotEmpty ? phone : 'Sin número';
}

class _ContactPickerSheet extends StatefulWidget {
  final List<Contact> contacts;
  final Function(Contact) onSelect;

  const _ContactPickerSheet({
    required this.contacts,
    required this.onSelect,
  });

  @override
  State<_ContactPickerSheet> createState() => _ContactPickerSheetState();
}

class _ContactPickerSheetState extends State<_ContactPickerSheet> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final filtered = widget.contacts.where((c) {
      final name = _contactName(c).toLowerCase();
      return name.contains(query.toLowerCase());
    }).toList();

    return SafeArea(
      child: Column(
        children: [
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: TextField(
              autofocus: true,
              decoration: const InputDecoration(
                hintText: 'Buscar contacto...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => setState(() => query = value),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView.builder(
              itemCount: filtered.length,
              itemBuilder: (_, i) {
                final c = filtered[i];
                final name = _contactName(c);
                final phone = _contactPhone(c);
                final firstLetter =
                    name.isNotEmpty ? name[0].toUpperCase() : '?';

                return ListTile(
                  leading: CircleAvatar(
                    child: Text(firstLetter),
                  ),
                  title: Text(name.isNotEmpty ? name : 'Sin nombre'),
                  subtitle: Text(phone),
                  onTap: () {
                    Navigator.pop(context);
                    widget.onSelect(c);
                  },
                );
              },
            ),
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

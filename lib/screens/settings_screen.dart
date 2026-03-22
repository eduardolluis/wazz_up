import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  String _name = 'Yo';
  String _status = 'Hey there! I am using WhatZapp';
  File? _photo;
  bool _notificationsEnabled = true;
  bool _readReceipts = true;
  bool _lastSeen = true;

  Future<void> _pickPhoto() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked != null) setState(() => _photo = File(picked.path));
  }

  void _editName() {
    final ctrl = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar nombre'),
        content: TextField(
          controller: ctrl,
          maxLength: 25,
          decoration:
              const InputDecoration(hintText: 'Tu nombre'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal),
            onPressed: () {
              setState(() => _name = ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Guardar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _editStatus() {
    final ctrl = TextEditingController(text: _status);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Editar estado'),
        content: TextField(
          controller: ctrl,
          maxLength: 60,
          decoration:
              const InputDecoration(hintText: 'Tu estado'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.teal),
            onPressed: () {
              setState(() => _status = ctrl.text.trim());
              Navigator.pop(ctx);
            },
            child: const Text('Guardar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        title: const Text('Configuración',
            style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: ListView(
        children: [
          // Profile header
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                GestureDetector(
                  onTap: _pickPhoto,
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 34,
                        backgroundColor: Colors.blueGrey[300],
                        backgroundImage:
                            _photo != null ? FileImage(_photo!) : null,
                        child: _photo == null
                            ? const Icon(Icons.person,
                                size: 38, color: Colors.white)
                            : null,
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: cs.secondary,
                          child: const Icon(Icons.camera_alt,
                              size: 12, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(_name,
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 18)),
                          IconButton(
                            onPressed: _editName,
                            icon: const Icon(Icons.edit, size: 18),
                            padding: EdgeInsets.zero,
                          ),
                        ],
                      ),
                      GestureDetector(
                        onTap: _editStatus,
                        child: Row(
                          children: [
                            Expanded(
                              child: Text(
                                _status,
                                style: TextStyle(
                                    color: Colors.grey[600],
                                    fontSize: 13),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Icon(Icons.edit,
                                size: 14, color: Colors.grey[500]),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          _Section(
            title: 'Cuenta',
            children: [
              _SettingsTile(
                icon: Icons.lock_outline,
                color: Colors.blue,
                title: 'Privacidad',
                subtitle: 'Última vez, foto de perfil, estado',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.security,
                color: Colors.green,
                title: 'Seguridad',
                subtitle: 'Notificaciones de cambio de clave',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.devices,
                color: Colors.orange,
                title: 'Dispositivos vinculados',
                subtitle: 'Administra tus dispositivos',
                onTap: () {},
              ),
            ],
          ),

          _Section(
            title: 'Notificaciones',
            children: [
              SwitchListTile(
                secondary:
                    const CircleAvatar(
                      backgroundColor: Colors.purple,
                      radius: 20,
                      child: Icon(Icons.notifications_outlined,
                          color: Colors.white),
                    ),
                title: const Text('Notificaciones'),
                subtitle: const Text('Recibir notificaciones de mensajes'),
                value: _notificationsEnabled,
                onChanged: (v) =>
                    setState(() => _notificationsEnabled = v),
                activeThumbColor: cs.secondary,
              ),
            ],
          ),

          _Section(
            title: 'Privacidad',
            children: [
              SwitchListTile(
                secondary: const CircleAvatar(
                  backgroundColor: Colors.teal,
                  radius: 20,
                  child:
                      Icon(Icons.done_all, color: Colors.white),
                ),
                title: const Text('Confirmaciones de lectura'),
                subtitle: const Text(
                    'Si desactivas esto, no podrás ver las confirmaciones de lectura de otros'),
                value: _readReceipts,
                onChanged: (v) =>
                    setState(() => _readReceipts = v),
                activeThumbColor: cs.secondary,
              ),
              SwitchListTile(
                secondary: const CircleAvatar(
                  backgroundColor: Colors.blue,
                  radius: 20,
                  child: Icon(Icons.access_time,
                      color: Colors.white),
                ),
                title: const Text('Última vez'),
                subtitle: const Text(
                    'Controla quién puede ver tu última conexión'),
                value: _lastSeen,
                onChanged: (v) => setState(() => _lastSeen = v),
                activeThumbColor: cs.secondary,
              ),
            ],
          ),

          _Section(
            title: 'Chats',
            children: [
              _SettingsTile(
                icon: Icons.wallpaper,
                color: Colors.indigo,
                title: 'Fondo de pantalla',
                subtitle: 'Cambia el fondo del chat',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.storage,
                color: Colors.brown,
                title: 'Uso de datos y almacenamiento',
                subtitle: 'Administra el almacenamiento',
                onTap: () {},
              ),
            ],
          ),

          _Section(
            title: 'Ayuda',
            children: [
              _SettingsTile(
                icon: Icons.help_outline,
                color: Colors.teal,
                title: 'Ayuda',
                subtitle: 'FAQ, contáctanos, políticas de privacidad',
                onTap: () {},
              ),
              _SettingsTile(
                icon: Icons.info_outline,
                color: Colors.grey,
                title: 'Acerca de WhatZapp',
                subtitle: 'Versión 1.0.0',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Section extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _Section({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ),
        Container(
          color: Colors.white,
          child: Column(children: children),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 20,
        backgroundColor: color,
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      title: Text(title),
      subtitle: Text(subtitle,
          style: TextStyle(fontSize: 12, color: Colors.grey[600])),
      trailing: const Icon(Icons.arrow_forward_ios, size: 14),
      onTap: onTap,
    );
  }
}
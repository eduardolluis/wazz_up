import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:whatzapp/model/chat_model.dart';

class ViewContactPage extends StatelessWidget {
  final ChatModel contact;
  const ViewContactPage({super.key, required this.contact});

  Future<void> _launchCall(BuildContext context, String phone) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se puede realizar la llamada')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: cs.primary,
            foregroundColor: Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                color: cs.primary,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 60),
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: Colors.blueGrey[300],
                        child: SvgPicture.asset(
                          contact.isGroup
                              ? 'assets/groups.svg'
                              : 'assets/person.svg',
                          colorFilter: const ColorFilter.mode(
                              Colors.white, BlendMode.srcIn),
                          height: 56,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        contact.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        contact.status,
                        style: const TextStyle(
                            color: Colors.white70, fontSize: 13),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              PopupMenuButton<String>(
                icon: const Icon(Icons.more_vert),
                onSelected: (v) => debugPrint(v),
                itemBuilder: (_) => const [
                  PopupMenuItem(
                      value: 'edit', child: Text('Editar contacto')),
                  PopupMenuItem(
                      value: 'block', child: Text('Bloquear')),
                  PopupMenuItem(
                      value: 'report', child: Text('Reportar')),
                ],
              ),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Quick actions
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _QuickAction(
                        icon: Icons.message,
                        label: 'Mensaje',
                        onTap: () => Navigator.pop(context),
                      ),
                      _QuickAction(
                        icon: Icons.call,
                        label: 'Llamar',
                        onTap: () => _launchCall(context, contact.status),
                      ),
                      _QuickAction(
                        icon: Icons.videocam,
                        label: 'Video',
                        onTap: () {},
                      ),
                      _QuickAction(
                        icon: Icons.search,
                        label: 'Buscar',
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Info card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        _InfoRow(
                          icon: Icons.phone,
                          label: 'Teléfono',
                          value: '+1 (809) 000-0000',
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                onPressed: () =>
                                    _launchCall(context, '+18090000000'),
                                icon: const Icon(Icons.call,
                                    color: Colors.green),
                              ),
                              IconButton(
                                onPressed: () {},
                                icon: const Icon(Icons.videocam,
                                    color: Colors.green),
                              ),
                            ],
                          ),
                        ),
                        const Divider(height: 1, indent: 60),
                        _InfoRow(
                          icon: Icons.info_outline,
                          label: 'Estado',
                          value: contact.status,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Media / Docs card
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: ListTile(
                      leading: const Icon(Icons.photo_library_outlined,
                          color: Colors.teal),
                      title: const Text('Media, enlaces y docs'),
                      trailing: const Icon(Icons.arrow_forward_ios,
                          size: 16),
                      onTap: () {},
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Danger zone
                  Card(
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    child: Column(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.notifications_off,
                              color: Colors.grey),
                          title: const Text('Silenciar notificaciones'),
                          onTap: () {},
                        ),
                        const Divider(height: 1, indent: 60),
                        ListTile(
                          leading: const Icon(Icons.block,
                              color: Colors.red),
                          title: Text(
                            'Bloquear a ${contact.name}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          onTap: () => _confirmBlock(context),
                        ),
                        const Divider(height: 1, indent: 60),
                        ListTile(
                          leading: const Icon(Icons.thumb_down,
                              color: Colors.red),
                          title: Text(
                            'Reportar a ${contact.name}',
                            style: const TextStyle(color: Colors.red),
                          ),
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmBlock(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Bloquear a ${contact.name}'),
        content: Text(
            '¿Estás seguro que deseas bloquear a ${contact.name}? No podrán enviarte mensajes ni llamarte.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                    content: Text('${contact.name} bloqueado')),
              );
            },
            child: const Text('Bloquear',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor:
                Theme.of(context).colorScheme.secondary.withOpacity(0.15),
            child: Icon(icon,
                color: Theme.of(context).colorScheme.secondary),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Widget? trailing;

  const _InfoRow(
      {required this.icon,
      required this.label,
      required this.value,
      this.trailing});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon,
          color: Theme.of(context).colorScheme.secondary),
      title: Text(value),
      subtitle: Text(label,
          style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      trailing: trailing,
    );
  }
}
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CallModel {
  final String name;
  final String phone;
  final bool isIncoming;
  final bool isMissed;
  final bool isVideo;
  final String time;
  final String date;

  const CallModel({
    required this.name,
    required this.phone,
    required this.isIncoming,
    required this.isMissed,
    required this.isVideo,
    required this.time,
    required this.date,
  });
}

final List<CallModel> _demoCallLogs = [
  CallModel(
    name: 'Eduardo',
    phone: '+18091234567',
    isIncoming: false,
    isMissed: false,
    isVideo: false,
    time: '18:04',
    date: 'Today',
  ),
  CallModel(
    name: 'Marcos',
    phone: '+18097654321',
    isIncoming: true,
    isMissed: true,
    isVideo: false,
    time: '15:30',
    date: 'Today',
  ),
  CallModel(
    name: 'Dadada',
    phone: '+18091111222',
    isIncoming: true,
    isMissed: false,
    isVideo: true,
    time: '12:00',
    date: 'Yesterday',
  ),
  CallModel(
    name: 'Malcom',
    phone: '+18093334444',
    isIncoming: false,
    isMissed: false,
    isVideo: true,
    time: '09:45',
    date: 'Yesterday',
  ),
  CallModel(
    name: 'Eduardo',
    phone: '+18091234567',
    isIncoming: true,
    isMissed: false,
    isVideo: false,
    time: '20:10',
    date: 'Mon',
  ),
];

class CallsPage extends StatefulWidget {
  const CallsPage({super.key});

  @override
  State<CallsPage> createState() => _CallsPageState();
}

class _CallsPageState extends State<CallsPage> {
  Future<void> _launchCall(String phone, {bool isVideo = false}) async {
    final uri = Uri.parse('tel:$phone');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
              isVideo ? 'No se puede iniciar videollamada' : 'No se puede llamar a $phone'),
        ),
      );
    }
  }

  void _showCallDetails(CallModel call) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (_) => _CallDetailSheet(
        call: call,
        onVoiceCall: () {
          Navigator.pop(context);
          _launchCall(call.phone);
        },
        onVideoCall: () {
          Navigator.pop(context);
          _showVideoCallScreen(call);
        },
      ),
    );
  }

  void _showVideoCallScreen(CallModel call) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SimulatedCallScreen(contact: call, isVideo: true),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    // Group by date
    final grouped = <String, List<CallModel>>{};
    for (final call in _demoCallLogs) {
      grouped.putIfAbsent(call.date, () => []).add(call);
    }

    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: cs.secondary,
        onPressed: () {
          _showNewCallDialog();
        },
        child: const Icon(Icons.add_call, color: Colors.white),
      ),
      body: ListView(
        children: [
          for (final entry in grouped.entries) ...[
            _DateHeader(label: entry.key),
            for (final call in entry.value)
              _CallTile(
                call: call,
                onTap: () => _showCallDetails(call),
                onCallPressed: () => _launchCall(call.phone),
              ),
          ],
        ],
      ),
    );
  }

  void _showNewCallDialog() {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Nueva llamada'),
        content: TextField(
          controller: ctrl,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            hintText: 'Número de teléfono',
            prefixIcon: Icon(Icons.phone),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () {
              Navigator.pop(ctx);
              _launchCall(ctrl.text.trim());
            },
            child:
                const Text('Llamar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}

class _DateHeader extends StatelessWidget {
  final String label;
  const _DateHeader({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      color: Colors.grey[200],
      child: Text(
        label,
        style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 13,
            color: Colors.grey[700]),
      ),
    );
  }
}

class _CallTile extends StatelessWidget {
  final CallModel call;
  final VoidCallback onTap;
  final VoidCallback onCallPressed;

  const _CallTile(
      {required this.call,
      required this.onTap,
      required this.onCallPressed});

  Color get _iconColor {
    if (call.isMissed) return Colors.red;
    return call.isIncoming ? Colors.green : Colors.blue;
  }

  IconData get _directionIcon {
    if (call.isMissed) return Icons.call_missed;
    if (call.isIncoming) return Icons.call_received;
    return Icons.call_made;
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onTap,
      leading: CircleAvatar(
        backgroundColor: Colors.blueGrey[200],
        child: Text(
          call.name[0].toUpperCase(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text(
        call.name,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: call.isMissed ? Colors.red : Colors.black,
        ),
      ),
      subtitle: Row(
        children: [
          Icon(_directionIcon, size: 14, color: _iconColor),
          const SizedBox(width: 4),
          Text(
            call.isVideo ? 'Video · ${call.time}' : 'Voz · ${call.time}',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
      trailing: IconButton(
        onPressed: onCallPressed,
        icon: Icon(
          call.isVideo ? Icons.videocam : Icons.call,
          color: Colors.green,
        ),
      ),
    );
  }
}

class _CallDetailSheet extends StatelessWidget {
  final CallModel call;
  final VoidCallback onVoiceCall;
  final VoidCallback onVideoCall;

  const _CallDetailSheet({
    required this.call,
    required this.onVoiceCall,
    required this.onVideoCall,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: Colors.blueGrey,
            child: Text(
              call.name[0].toUpperCase(),
              style: const TextStyle(
                  fontSize: 28,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 12),
          Text(call.name,
              style: const TextStyle(
                  fontSize: 20, fontWeight: FontWeight.bold)),
          Text(call.phone,
              style: TextStyle(color: Colors.grey[600], fontSize: 14)),
          const SizedBox(height: 6),
          Text(
            call.isMissed
                ? 'Llamada perdida'
                : call.isIncoming
                    ? 'Llamada recibida'
                    : 'Llamada realizada',
            style: TextStyle(
              color: call.isMissed ? Colors.red : Colors.green,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _ActionBtn(
                icon: Icons.call,
                label: 'Llamada de voz',
                color: Colors.green,
                onTap: onVoiceCall,
              ),
              _ActionBtn(
                icon: Icons.videocam,
                label: 'Video llamada',
                color: Colors.blue,
                onTap: onVideoCall,
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}

class _ActionBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionBtn({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: color,
            child: Icon(icon, color: Colors.white, size: 28),
          ),
          const SizedBox(height: 6),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

// Simulated video call screen
class _SimulatedCallScreen extends StatefulWidget {
  final CallModel contact;
  final bool isVideo;

  const _SimulatedCallScreen(
      {required this.contact, required this.isVideo});

  @override
  State<_SimulatedCallScreen> createState() =>
      _SimulatedCallScreenState();
}

class _SimulatedCallScreenState extends State<_SimulatedCallScreen> {
  bool _muted = false;
  bool _speakerOn = false;
  bool _cameraOff = false;
  int _seconds = 0;
  late final Stream<int> _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Stream.periodic(
      const Duration(seconds: 1),
      (i) => i + 1,
    );
  }

  String _formatDuration(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: StreamBuilder<int>(
          stream: _ticker,
          builder: (context, snapshot) {
            _seconds = snapshot.data ?? 0;
            return Column(
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.blueGrey,
                  child: Text(
                    widget.contact.name[0].toUpperCase(),
                    style: const TextStyle(
                        fontSize: 40,
                        color: Colors.white,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.contact.name,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 26,
                      fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  _seconds == 0
                      ? (widget.isVideo ? 'Videollamada...' : 'Llamando...')
                      : _formatDuration(_seconds),
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
                const Spacer(),
                if (widget.isVideo)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _CallControl(
                          icon: _cameraOff
                              ? Icons.videocam_off
                              : Icons.videocam,
                          label: _cameraOff ? 'Cámara off' : 'Cámara',
                          onTap: () =>
                              setState(() => _cameraOff = !_cameraOff),
                        ),
                        _CallControl(
                          icon: _muted ? Icons.mic_off : Icons.mic,
                          label: _muted ? 'Silenciado' : 'Micrófono',
                          onTap: () => setState(() => _muted = !_muted),
                        ),
                        _CallControl(
                          icon: Icons.flip_camera_ios,
                          label: 'Voltear',
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _CallControl(
                      icon: _muted ? Icons.mic_off : Icons.mic,
                      label: _muted ? 'Activar' : 'Silenciar',
                      onTap: () => setState(() => _muted = !_muted),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: CircleAvatar(
                        radius: 32,
                        backgroundColor: Colors.red,
                        child: const Icon(Icons.call_end,
                            color: Colors.white, size: 32),
                      ),
                    ),
                    _CallControl(
                      icon: _speakerOn ? Icons.volume_up : Icons.volume_down,
                      label: 'Altavoz',
                      onTap: () =>
                          setState(() => _speakerOn = !_speakerOn),
                    ),
                  ],
                ),
                const SizedBox(height: 40),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _CallControl extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _CallControl(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: Colors.white24,
            child: Icon(icon, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label,
              style: const TextStyle(color: Colors.white70, fontSize: 11)),
        ],
      ),
    );
  }
}
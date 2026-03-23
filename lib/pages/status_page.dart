import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:whatzapp/customUI/StatusPage/head_own_status.dart';
import 'package:whatzapp/customUI/StatusPage/other_status.dart';
import 'package:whatzapp/services/status_service.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});
  @override
  State<StatusPage> createState() => _StatusPageState();
}

class _StatusPageState extends State<StatusPage> {
  bool _isPublishing = false;

  void _showAddStatusOptions() {
    showModalBottomSheet(
      context: context,
      builder: (_) => SafeArea(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          ListTile(
            leading: const Icon(Icons.photo_library, color: Colors.teal),
            title: const Text('Photo from gallery'),
            onTap: () {
              Navigator.pop(context);
              _pickImageStatus();
            },
          ),
          ListTile(
            leading: const Icon(Icons.text_fields, color: Colors.teal),
            title: const Text('Text status'),
            onTap: () {
              Navigator.pop(context);
              _showTextStatusEditor();
            },
          ),
        ]),
      ),
    );
  }

  Future<void> _pickImageStatus() async {
    final picked = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 80);
    if (picked == null || !mounted) return;
    _showImageCaptionDialog(File(picked.path));
  }

  void _showImageCaptionDialog(File imageFile) {
    final captionCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        contentPadding: EdgeInsets.zero,
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
            child: Image.file(imageFile,
                height: 200, width: double.infinity, fit: BoxFit.cover),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              controller: captionCtrl,
              decoration:
                  const InputDecoration(hintText: 'Image caption (optional)...'),
            ),
          ),
        ]),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: Colors.greenAccent[700]),
            onPressed: () async {
              Navigator.pop(ctx);
              setState(() => _isPublishing = true);
              try {
                await StatusService.publishImageStatus(
                  imageFile: imageFile,
                  caption: captionCtrl.text.trim(),
                );
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text('Status published'),
                        backgroundColor: Colors.green),
                  );
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red),
                  );
                }
              } finally {
                if (mounted) setState(() => _isPublishing = false);
              }
            },
            child:
                const Text('Publish', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTextStatusEditor() {
    final ctrl = TextEditingController();
    int selectedColor = 0xFF075E54;
    final colors = [
      0xFF075E54,
      0xFF1A1A2E,
      0xFF128C7E,
      0xFF7B1FA2,
      0xFFD32F2F,
      0xFFE65100,
      0xFF1565C0,
      0xFF4CAF50,
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModal) => Container(
          height: MediaQuery.of(context).size.height * 0.75,
          decoration: BoxDecoration(
            color: Color(selectedColor),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 16,
            top: 16,
            left: 20,
            right: 20,
          ),
          child: Column(children: [
            SizedBox(
              height: 44,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: colors.length,
                itemBuilder: (_, i) => GestureDetector(
                  onTap: () => setModal(() => selectedColor = colors[i]),
                  child: Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: Color(colors[i]),
                      shape: BoxShape.circle,
                      border: selectedColor == colors[i]
                          ? Border.all(color: Colors.white, width: 3)
                          : null,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: TextField(
                controller: ctrl,
                autofocus: true,
                maxLength: 700,
                maxLines: null,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 22),
                decoration: const InputDecoration(
                  hintText: 'What do you want to share?',
                  hintStyle: TextStyle(color: Colors.white54, fontSize: 22),
                  border: InputBorder.none,
                  counterStyle: TextStyle(color: Colors.white54),
                ),
              ),
            ),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () async {
                final text = ctrl.text.trim();
                if (text.isEmpty) return;
                Navigator.pop(ctx);
                setState(() => _isPublishing = true);
                try {
                  await StatusService.publishTextStatus(
                    text: text,
                    backgroundColor: selectedColor,
                  );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text('Status published'),
                          backgroundColor: Colors.green),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red),
                    );
                  }
                } finally {
                  if (mounted) setState(() => _isPublishing = false);
                }
              },
              icon: Icon(Icons.send, color: Color(selectedColor)),
              label: Text(
                'Publish',
                style: TextStyle(
                    color: Color(selectedColor), fontWeight: FontWeight.bold),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  void _openViewer(List<QueryDocumentSnapshot> userDocs, String name) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => FirestoreStatusViewer(statusDocs: userDocs, name: name),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: _isPublishing
          ? const FloatingActionButton(
              onPressed: null,
              child: CircularProgressIndicator(color: Colors.white),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                SizedBox(
                  height: 48,
                  child: FloatingActionButton(
                    heroTag: 'edit_status',
                    backgroundColor: Colors.blueGrey[100],
                    elevation: 8,
                    onPressed: _showTextStatusEditor,
                    child: Icon(Icons.edit, color: Colors.blueGrey[900]),
                  ),
                ),
                const SizedBox(height: 13),
                FloatingActionButton(
                  heroTag: 'camera_status',
                  onPressed: _showAddStatusOptions,
                  backgroundColor: Colors.greenAccent[700],
                  elevation: 5,
                  child: const Icon(Icons.camera_alt),
                ),
              ],
            ),
      body: StreamBuilder<QuerySnapshot>(
        stream: StatusService.statusesStream(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];
          final myUid = StatusService.myUid;
          final myDocs = docs.where((d) => d['uid'] == myUid).toList();
          final grouped = StatusService.groupByUser(
            docs.where((d) => d['uid'] != myUid).toList(),
          );

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: myDocs.isNotEmpty
                      ? () => _openViewer(myDocs, 'My Status')
                      : _showAddStatusOptions,
                  child: HeadOwnStatus(),
                ),
                if (myDocs.isNotEmpty) ...[
                  _sectionLabel('My Statuses', context),
                  GestureDetector(
                    onTap: () => _openViewer(myDocs, 'My Status'),
                    child: OtherStatus(
                      name: 'My Status (${myDocs.length})',
                      time: _docTime(myDocs.last, context),
                      imageName: '',
                      isSeen: true,
                      statusNum: myDocs.length,
                    ),
                  ),
                ],
                if (grouped.isNotEmpty) ...[
                  _sectionLabel('Recent Updates', context),
                  ...grouped.entries.map((entry) {
                    final userDocs = entry.value;
                    final data = userDocs.first.data() as Map<String, dynamic>;
                    final name = data['name'] as String? ?? 'User';
                    final viewers =
                        (data['viewers'] as List?)?.cast<String>() ?? [];
                    return GestureDetector(
                      onTap: () {
                        StatusService.markSeen(userDocs.first.id);
                        _openViewer(userDocs, name);
                      },
                      child: OtherStatus(
                        name: name,
                        time: _docTime(userDocs.last, context),
                        imageName: '',
                        isSeen: viewers.contains(myUid),
                        statusNum: userDocs.length,
                      ),
                    );
                  }),
                ],
                if (docs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 80),
                    child: Center(
                      child: Column(children: [
                        Icon(Icons.circle_outlined,
                            size: 70, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'No recent statuses',
                          style:
                              TextStyle(color: Colors.grey[500], fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 40),
                          child: Text(
                            'Tap the button to post your first status',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                          ),
                        ),
                      ]),
                    ),
                  ),
                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  String _docTime(QueryDocumentSnapshot doc, BuildContext context) {
    final data = doc.data() as Map<String, dynamic>;
    final ts = data['createdAt'] as Timestamp?;
    if (ts == null) return '';
    return TimeOfDay.fromDateTime(ts.toDate()).format(context);
  }

  Widget _sectionLabel(String text, BuildContext context) {
    return Container(
      height: 33,
      width: MediaQuery.of(context).size.width,
      color: Colors.grey[300],
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 7),
      child: Text(text,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
    );
  }
}

class FirestoreStatusViewer extends StatefulWidget {
  final List<QueryDocumentSnapshot> statusDocs;
  final String name;
  const FirestoreStatusViewer(
      {super.key, required this.statusDocs, required this.name});
  @override
  State<FirestoreStatusViewer> createState() => _FirestoreStatusViewerState();
}

class _FirestoreStatusViewerState extends State<FirestoreStatusViewer>
    with SingleTickerProviderStateMixin {
  int _idx = 0;
  late AnimationController _ctrl;
  Timer? _timer;
  static const _dur = Duration(seconds: 5);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _dur);
    _start();
  }

  void _start() {
    _ctrl.reset();
    _ctrl.forward();
    _timer?.cancel();
    _timer = Timer(_dur, _next);
  }

  void _next() {
    if (_idx < widget.statusDocs.length - 1) {
      setState(() => _idx++);
      _start();
    } else {
      if (mounted) Navigator.pop(context);
    }
  }

  void _prev() {
    if (_idx > 0) {
      setState(() => _idx--);
      _start();
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  String _timeAgo(DateTime? dt) {
    if (dt == null) return '';
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
    if (diff.inHours < 24) return '${diff.inHours} h ago';
    return '${diff.inDays} d ago';
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.statusDocs[_idx];
    final data = doc.data() as Map<String, dynamic>;
    final type = data['type'] as String? ?? 'text';
    final content = data['content'] as String? ?? '';
    final bgColor = Color((data['backgroundColor'] as int?) ?? 0xFF075E54);
    final caption = data['caption'] as String? ?? '';
    final ts = (data['createdAt'] as Timestamp?)?.toDate();

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTapUp: (details) {
          final half = MediaQuery.of(context).size.width / 2;
          if (details.globalPosition.dx < half) {
            _prev();
          } else {
            _next();
          }
        },
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (type == 'image')
              Image.network(
                content,
                fit: BoxFit.cover,
                loadingBuilder: (_, child, p) => p == null
                    ? child
                    : const Center(
                        child: CircularProgressIndicator(color: Colors.white)),
                errorBuilder: (_, __, ___) => Container(
                  color: Colors.black,
                  child: const Center(
                    child: Icon(Icons.broken_image, color: Colors.white, size: 60),
                  ),
                ),
              )
            else
              Container(
                color: bgColor,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 32),
                    child: Text(
                      content,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w600,
                        shadows: [
                          Shadow(
                            blurRadius: 8,
                            color: Colors.black38,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.center,
                  colors: [Colors.black54, Colors.transparent],
                ),
              ),
            ),

            SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 6),
                    child: Row(
                      children: List.generate(
                        widget.statusDocs.length,
                        (i) => Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 2),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: i < _idx
                                  ? Container(
                                      height: 3, color: Colors.white)
                                  : i == _idx
                                      ? AnimatedBuilder(
                                          animation: _ctrl,
                                          builder: (_, __) =>
                                              LinearProgressIndicator(
                                            value: _ctrl.value,
                                            minHeight: 3,
                                            backgroundColor: Colors.white38,
                                            valueColor:
                                                const AlwaysStoppedAnimation(
                                                    Colors.white),
                                          ),
                                        )
                                      : Container(
                                          height: 3,
                                          color: Colors.white38),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 4),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                          backgroundColor: Colors.blueGrey,
                          child: Text(
                            widget.name.isNotEmpty
                                ? widget.name[0].toUpperCase()
                                : '?',
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                              Text(
                                _timeAgo(ts),
                                style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            if (type == 'image' && caption.isNotEmpty)
              Positioned(
                bottom: 90,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    caption,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        color: Colors.white, fontSize: 15),
                  ),
                ),
              ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 10),
                  child: Row(children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 12),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.white54),
                          borderRadius: BorderRadius.circular(24),
                          color: Colors.black26,
                        ),
                        child: const Text(
                          'Reply...',
                          style: TextStyle(
                              color: Colors.white70, fontSize: 15),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: const Icon(Icons.emoji_emotions_outlined,
                          color: Colors.white),
                    ),
                    const SizedBox(width: 8),
                    CircleAvatar(
                      backgroundColor: Colors.white24,
                      child: const Icon(Icons.forward, color: Colors.white),
                    ),
                  ]),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
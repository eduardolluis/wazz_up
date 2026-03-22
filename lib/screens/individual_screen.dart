import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:url_launcher/url_launcher.dart';
import 'package:whatzapp/customUI/message_card.dart';
import 'package:whatzapp/customUI/reply_card.dart';
import 'package:whatzapp/model/chat_model.dart';
import 'package:whatzapp/model/message_model.dart';
import 'package:whatzapp/screens/camera_screen.dart';
import 'package:whatzapp/screens/view_contact_screen.dart';
import 'package:whatzapp/widgets/attachment_menu_widget.dart';
import 'package:whatzapp/widgets/emoji_picker_widget.dart';

class IndividualPage extends StatefulWidget {
  const IndividualPage({
    super.key,
    required this.chatModel,
    required this.sourceChat,
  });

  final ChatModel chatModel;
  final ChatModel sourceChat;

  @override
  State<IndividualPage> createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  bool show = false;
  bool sendButton = false;
  bool isRecordingAudio = false;
  bool isCancellingAudio = false;

  final focusNode = FocusNode();
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _audioRecorder = AudioRecorder();
  final _micButtonKey = GlobalKey();

  late io.Socket socket;
  final List<MessageModel> messages = [];

  Timer? _recordingTimer;
  int recordingSeconds = 0;
  String? _currentAudioPath;
  double _dragDx = 0;

  // search within chat
  bool _searchMode = false;
  String _searchQuery = '';
  final _searchCtrl = TextEditingController();

  static const double _cancelThreshold = -120;

  int get sourceId => widget.sourceChat.id;
  int get targetId => widget.chatModel.id;

  @override
  void initState() {
    super.initState();
    _connect();

    focusNode.addListener(() {
      if (focusNode.hasFocus && mounted) {
        setState(() => show = false);
      }
    });
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    focusNode.dispose();
    _controller.dispose();
    _scrollController.dispose();
    _searchCtrl.dispose();
    _audioRecorder.dispose();
    socket.disconnect();
    socket.dispose();
    super.dispose();
  }

  void _connect() {
    socket = io.io("http://10.0.2.2:5000", {
      "transports": ["websocket"],
      "autoConnect": false,
    });

    socket.onConnect((_) {
      debugPrint("connected");
      socket.emit("signin", sourceId);
    });

    _listenTextEvent("message", "message");
    _listenTextEvent("image_message", "image");

    socket.on("audio_message", (msg) {
      if (msg is Map) {
        final seconds = _toInt(msg["durationSeconds"]);
        _addMessage("destination", "🎤 Audio • ${_formatSeconds(seconds)}");
        _scrollToBottom();
      }
    });

    socket.connect();
  }

  void _listenTextEvent(String event, String field) {
    socket.on(event, (msg) {
      if (msg is Map && msg[field] != null) {
        _addMessage("destination", msg[field].toString());
        _scrollToBottom();
      }
    });
  }

  int _toInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    return int.tryParse(value?.toString() ?? "") ?? 0;
  }

  String _formatSeconds(int totalSeconds) {
    final m = (totalSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (totalSeconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  void _addMessage(String type, String message) {
    setState(() {
      messages.add(
        MessageModel(
          type: type,
          message: message,
          time: DateTime.now().toString().substring(10, 16),
        ),
      );
    });
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _send({
    required String event,
    required String localMessage,
    required Map<String, dynamic> data,
  }) {
    if (localMessage.trim().isEmpty) return;
    _addMessage("source", localMessage);
    socket.emit(event, data);
    _scrollToBottom();
  }

  void sendMessage(String text) {
    _send(
      event: "message",
      localMessage: text,
      data: {
        "message": text,
        "sourceId": sourceId,
        "targetId": targetId,
      },
    );
  }

  void sendImageMessage(String imagePath) {
    _send(
      event: "image_message",
      localMessage: imagePath,
      data: {
        "image": imagePath,
        "sourceId": sourceId,
        "targetId": targetId,
      },
    );
  }

  void sendAudioMessage(
    String audioPath, {
    required int durationSeconds,
    required String durationLabel,
  }) {
    _send(
      event: "audio_message",
      localMessage: "🎤 Audio • $durationLabel",
      data: {
        "audio": audioPath,
        "durationSeconds": durationSeconds,
        "sourceId": sourceId,
        "targetId": targetId,
      },
    );
  }

  // ────────────────────────────── calls ──────────────────────────────
  Future<void> _launchVoiceCall() async {
    final uri = Uri.parse('tel:+18090000000');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      if (!mounted) return;
      _showSimulatedCallScreen(isVideo: false);
    }
  }

  void _showSimulatedCallScreen({required bool isVideo}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SimulatedCallScreen(
          name: widget.chatModel.name,
          isVideo: isVideo,
        ),
      ),
    );
  }

  // ────────────────────────────── recording ──────────────────────────────
  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    recordingSeconds = 0;
    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted) return;
      setState(() => recordingSeconds++);
    });
  }

  void _stopRecordingTimer() {
    _recordingTimer?.cancel();
    _recordingTimer = null;
  }

  void _resetRecordingState() {
    setState(() {
      isRecordingAudio = false;
      isCancellingAudio = false;
      recordingSeconds = 0;
      _dragDx = 0;
    });
  }

  Future<void> startAudioRecording() async {
    if (isRecordingAudio) return;
    try {
      final hasPermission = await _audioRecorder.hasPermission();
      if (!hasPermission) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Activa el permiso del micrófono")),
        );
        return;
      }

      focusNode.unfocus();
      if (show && mounted) setState(() => show = false);

      final dir = await getTemporaryDirectory();
      final path =
          '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
      _currentAudioPath = path;

      await _audioRecorder.start(
        const RecordConfig(
          encoder: AudioEncoder.aacLc,
          bitRate: 128000,
          sampleRate: 44100,
        ),
        path: path,
      );

      _startRecordingTimer();
      if (!mounted) return;
      setState(() {
        isRecordingAudio = true;
        isCancellingAudio = false;
        _dragDx = 0;
      });
    } catch (e) {
      debugPrint("Error iniciando audio: $e");
    }
  }

  Future<void> cancelAudioRecording() async {
    _stopRecordingTimer();
    try {
      await _audioRecorder.cancel();
    } catch (e) {
      debugPrint("Error cancelando audio: $e");
    }
    if (!mounted) return;
    _resetRecordingState();
  }

  Future<void> stopAudioRecording() async {
    if (!isRecordingAudio) return;
    final durationSeconds = recordingSeconds;
    final durationLabel = _formatSeconds(durationSeconds);
    _stopRecordingTimer();

    String? recordedPath;
    try {
      recordedPath = await _audioRecorder.stop();
    } catch (e) {
      debugPrint("Error deteniendo audio: $e");
    }

    if (!mounted) return;
    _resetRecordingState();

    final finalPath = recordedPath ?? _currentAudioPath;
    if (finalPath == null || finalPath.isEmpty) return;
    final file = File(finalPath);
    if (await file.exists()) {
      sendAudioMessage(finalPath,
          durationSeconds: durationSeconds, durationLabel: durationLabel);
    }
  }

  void handleRecordingDrag(LongPressMoveUpdateDetails details) {
    if (!isRecordingAudio) return;
    final dx = details.offsetFromOrigin.dx;
    if (!mounted) return;
    setState(() {
      _dragDx = dx;
      isCancellingAudio = dx <= _cancelThreshold;
    });
  }

  Future<void> openCamera() async {
    final imagePath = await Navigator.push<String>(
      context,
      MaterialPageRoute(builder: (_) => const CameraScreen()),
    );
    if (imagePath != null && imagePath.isNotEmpty) {
      sendImageMessage(imagePath);
    }
  }

  void _toggleEmoji() {
    setState(() {
      if (show) {
        show = false;
        FocusScope.of(context).requestFocus(focusNode);
      } else {
        focusNode.unfocus();
        show = true;
      }
    });
  }

  List<MessageModel> get _filteredMessages {
    if (_searchQuery.isEmpty) return messages;
    return messages
        .where(
            (m) => m.message.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  // ────────────────────────────── build ──────────────────────────────
  Widget _buildMessageBubble(MessageModel msg) {
    return msg.type == "source"
        ? MessageCard(message: msg.message, time: msg.time)
        : ReplyCard(message: msg.message, time: msg.time);
  }

  Widget _buildRecordingInput() {
    final progress =
        (_dragDx.abs() / _cancelThreshold.abs()).clamp(0.0, 1.0).toDouble();

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 2, right: 2, bottom: 8),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
          color: isCancellingAudio ? Colors.red.shade700 : Colors.grey[900],
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Icon(
                  isCancellingAudio ? Icons.delete_outline : Icons.mic,
                  color: Colors.white,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Transform.translate(
                    offset: Offset(_dragDx < 0 ? _dragDx * 0.15 : 0, 0),
                    child: Text(
                      isCancellingAudio
                          ? "Suelta para borrar audio"
                          : "Grabando... desliza ← para borrar",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: Colors.white, fontSize: 15),
                    ),
                  ),
                ),
                if (!isCancellingAudio)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: Icon(
                      Icons.keyboard_double_arrow_left,
                      color: Colors.white.withOpacity(1 - (progress * 0.7)),
                    ),
                  ),
                Text(
                  _formatSeconds(recordingSeconds),
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 2, right: 2, bottom: 8),
        child: Card(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(23)),
          child: TextFormField(
            controller: _controller,
            focusNode: focusNode,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            minLines: 1,
            onChanged: (value) {
              setState(() => sendButton = value.trim().isNotEmpty);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: "Type a message",
              contentPadding: const EdgeInsets.all(5),
              prefixIcon: IconButton(
                icon: const Icon(Icons.emoji_emotions_outlined),
                onPressed: _toggleEmoji,
              ),
              suffixIcon: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (_) => AttachmentMenu(
                          onAttachment: (path, type) {
                            if (type == 'image') {
                              sendImageMessage(path);
                            } else {
                              sendMessage(path);
                            }
                          },
                        ),
                      );
                    },
                    icon: const Icon(Icons.attach_file),
                  ),
                  IconButton(
                    onPressed: openCamera,
                    icon: const Icon(Icons.camera_alt_rounded),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildActionButton(ColorScheme cs) {
    final button = sendButton
        ? CircleAvatar(
            radius: 24,
            backgroundColor: cs.secondary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () {
                sendMessage(_controller.text);
                _controller.clear();
                setState(() => sendButton = false);
              },
            ),
          )
        : GestureDetector(
            key: _micButtonKey,
            behavior: HitTestBehavior.opaque,
            onLongPressStart: (_) async => startAudioRecording(),
            onLongPressMoveUpdate: handleRecordingDrag,
            onLongPressEnd: (_) async {
              if (isCancellingAudio) {
                await cancelAudioRecording();
              } else {
                await stopAudioRecording();
              }
            },
            child: CircleAvatar(
              radius: isRecordingAudio ? 26 : 24,
              backgroundColor:
                  isRecordingAudio ? Colors.redAccent : cs.secondary,
              child: Icon(
                isRecordingAudio ? Icons.send_rounded : Icons.mic_none_rounded,
                color: Colors.white,
              ),
            ),
          );

    return Padding(
      padding: const EdgeInsets.only(bottom: 8, right: 5, left: 2),
      child: button,
    );
  }

  PreferredSizeWidget _buildAppBar(ColorScheme cs) {
    if (_searchMode) {
      return PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          backgroundColor: cs.primary,
          foregroundColor: Colors.white,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () {
              setState(() {
                _searchMode = false;
                _searchQuery = '';
                _searchCtrl.clear();
              });
            },
          ),
          title: TextField(
            controller: _searchCtrl,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: const InputDecoration(
              hintText: 'Buscar en el chat...',
              hintStyle: TextStyle(color: Colors.white70),
              border: InputBorder.none,
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          actions: [
            if (_searchCtrl.text.isNotEmpty)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  _searchCtrl.clear();
                  setState(() => _searchQuery = '');
                },
              ),
          ],
        ),
      );
    }

    return PreferredSize(
      preferredSize: const Size.fromHeight(60),
      child: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        leadingWidth: 70,
        titleSpacing: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.arrow_back, size: 24),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueGrey,
                child: SvgPicture.asset(
                  widget.chatModel.isGroup
                      ? "assets/groups.svg"
                      : "assets/person.svg",
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  height: 36,
                  width: 36,
                ),
              ),
            ],
          ),
        ),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ViewContactPage(contact: widget.chatModel),
              ),
            );
          },
          child: Container(
            margin: const EdgeInsets.all(6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatModel.name,
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  "last seen at ${widget.chatModel.time}",
                  style: const TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () => _showSimulatedCallScreen(isVideo: true),
            icon: const Icon(Icons.videocam),
          ),
          IconButton(
            onPressed: _launchVoiceCall,
            icon: const Icon(Icons.call),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              switch (value) {
                case 'View Contact':
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ViewContactPage(contact: widget.chatModel),
                    ),
                  );
                  break;
                case 'Search':
                  setState(() => _searchMode = true);
                  break;
                case 'Mute':
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Notificaciones silenciadas')),
                  );
                  break;
                case 'Clear chat':
                  _confirmClearChat();
                  break;
                default:
                  debugPrint(value);
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(value: "View Contact", child: Text("View Contact")),
              PopupMenuItem(
                  value: "Media", child: Text("Media, links and docs")),
              PopupMenuItem(value: "Search", child: Text("Search")),
              PopupMenuItem(value: "Mute", child: Text("Mute Notifications")),
              PopupMenuItem(value: "Clear chat", child: Text("Clear chat")),
              PopupMenuItem(value: "Wallpaper", child: Text("Wallpaper")),
            ],
          ),
        ],
      ),
    );
  }

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar chat'),
        content:
            const Text('¿Estás seguro que deseas borrar todos los mensajes?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              Navigator.pop(ctx);
              setState(() => messages.clear());
            },
            child: const Text('Borrar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    final displayMessages = _filteredMessages;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset("assets/chat_background.png", fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(cs),
          body: PopScope(
            canPop: !show,
            onPopInvokedWithResult: (didPop, result) {
              if (show) setState(() => show = false);
            },
            child: Column(
              children: [
                if (_searchMode && _searchQuery.isNotEmpty)
                  Container(
                    color: cs.primary.withOpacity(0.1),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    child: Text(
                      '${displayMessages.length} resultado(s)',
                      style: TextStyle(color: cs.secondary, fontSize: 13),
                    ),
                  ),
                Expanded(
                  child: ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.only(bottom: 12, top: 8),
                    itemCount: displayMessages.length,
                    itemBuilder: (_, index) =>
                        _buildMessageBubble(displayMessages[index]),
                  ),
                ),
                if (!_searchMode)
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      isRecordingAudio
                          ? _buildRecordingInput()
                          : _buildTextInput(),
                      _buildActionButton(cs),
                    ],
                  ),
                if (show && !isRecordingAudio && !_searchMode)
                  EmojiSelect(controller: _controller),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

// ────────────────────────────── Simulated call ──────────────────────────────
class _SimulatedCallScreen extends StatefulWidget {
  final String name;
  final bool isVideo;
  const _SimulatedCallScreen({required this.name, required this.isVideo});

  @override
  State<_SimulatedCallScreen> createState() => _SimulatedCallScreenState();
}

class _SimulatedCallScreenState extends State<_SimulatedCallScreen> {
  bool _muted = false;
  bool _speakerOn = false;
  bool _cameraOff = false;
  int _seconds = 0;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _seconds++);
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _fmt(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 40),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.blueGrey,
              child: Text(
                widget.name[0].toUpperCase(),
                style: const TextStyle(
                    fontSize: 40,
                    color: Colors.white,
                    fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            Text(widget.name,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(
              _seconds == 0
                  ? (widget.isVideo ? 'Videollamada...' : 'Llamando...')
                  : _fmt(_seconds),
              style: const TextStyle(color: Colors.white70, fontSize: 16),
            ),
            const Spacer(),
            if (widget.isVideo)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _Btn(
                      icon: _cameraOff ? Icons.videocam_off : Icons.videocam,
                      label: 'Cámara',
                      onTap: () => setState(() => _cameraOff = !_cameraOff),
                    ),
                    _Btn(
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
                _Btn(
                  icon: _muted ? Icons.mic_off : Icons.mic,
                  label: _muted ? 'Activar' : 'Silenciar',
                  onTap: () => setState(() => _muted = !_muted),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: const CircleAvatar(
                    radius: 32,
                    backgroundColor: Colors.red,
                    child: Icon(Icons.call_end, color: Colors.white, size: 32),
                  ),
                ),
                _Btn(
                  icon: _speakerOn ? Icons.volume_up : Icons.volume_down,
                  label: 'Altavoz',
                  onTap: () => setState(() => _speakerOn = !_speakerOn),
                ),
              ],
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }
}

class _Btn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _Btn({required this.icon, required this.label, required this.onTap});

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

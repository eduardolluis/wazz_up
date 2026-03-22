import 'dart:async';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:whatzapp/customUI/message_card.dart';
import 'package:whatzapp/customUI/reply_card.dart';
import 'package:whatzapp/model/chat_model.dart';
import 'package:whatzapp/screens/camera_screen.dart';
import 'package:whatzapp/screens/view_contact_screen.dart';
import 'package:whatzapp/services/message_service.dart';
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
  bool _searchMode = false;
  String _searchQuery = '';

  final focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchCtrl = TextEditingController();
  final AudioRecorder _audioRecorder = AudioRecorder();

  Timer? _recordingTimer;
  int recordingSeconds = 0;
  String? _currentAudioPath;
  double _dragDx = 0;

  static const double _cancelThreshold = -120;

  String? get _myUid => FirebaseAuth.instance.currentUser?.uid;

  String get _myName =>
      FirebaseAuth.instance.currentUser?.displayName?.trim().isNotEmpty == true
          ? FirebaseAuth.instance.currentUser!.displayName!.trim()
          : widget.sourceChat.name;

  /// IMPORTANTE:
  /// Esto asume que chatModel.id es el UID real de Firebase del otro usuario.
  /// Si no lo es, cámbialo por el campo correcto, por ejemplo: widget.chatModel.uid
  String get _otherUid => widget.chatModel.id.toString();

  late final String _conversationId;

  @override
  void initState() {
    super.initState();

    final myUid = _myUid;
    if (myUid == null || myUid.isEmpty) {
      _conversationId = '';
      debugPrint('❌ No hay usuario autenticado en FirebaseAuth');
    } else {
      _conversationId = MessageService.conversationId(myUid, _otherUid);
      debugPrint('✅ myUid: $myUid');
      debugPrint('✅ otherUid: $_otherUid');
      debugPrint('✅ conversationId: $_conversationId');
    }

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
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;

      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _sendText(String text) async {
    final myUid = _myUid;
    if (myUid == null || myUid.isEmpty) {
      _showSnack('No hay usuario autenticado');
      return;
    }

    if (text.trim().isEmpty) return;

    try {
      _controller.clear();
      setState(() => sendButton = false);

      await MessageService.sendText(
        conversationId: _conversationId,
        text: text.trim(),
        senderUid: myUid,
        senderName: _myName,
        receiverUid: _otherUid,
      );
    } catch (e) {
      _showSnack('Error enviando mensaje');
      debugPrint('❌ _sendText: $e');
    }
  }

  Future<void> _sendImage(String imagePath) async {
    final myUid = _myUid;
    if (myUid == null || myUid.isEmpty) {
      _showSnack('No hay usuario autenticado');
      return;
    }

    try {
      await MessageService.sendImage(
        conversationId: _conversationId,
        imagePath: imagePath,
        senderUid: myUid,
        senderName: _myName,
        receiverUid: _otherUid,
      );
    } catch (e) {
      _showSnack('Error enviando imagen');
      debugPrint('❌ _sendImage: $e');
    }
  }

  Future<void> _sendAudio(
    String audioPath, {
    required String durationLabel,
  }) async {
    final myUid = _myUid;
    if (myUid == null || myUid.isEmpty) {
      _showSnack('No hay usuario autenticado');
      return;
    }

    try {
      await MessageService.sendAudio(
        conversationId: _conversationId,
        audioPath: audioPath,
        durationLabel: durationLabel,
        senderUid: myUid,
        senderName: _myName,
        receiverUid: _otherUid,
      );
    } catch (e) {
      _showSnack('Error enviando audio');
      debugPrint('❌ _sendAudio: $e');
    }
  }

  Future<void> _sendAttachment(String content, String type) async {
    final myUid = _myUid;
    if (myUid == null || myUid.isEmpty) {
      _showSnack('No hay usuario autenticado');
      return;
    }

    try {
      await MessageService.sendAttachment(
        conversationId: _conversationId,
        content: content,
        type: type,
        senderUid: myUid,
        senderName: _myName,
        receiverUid: _otherUid,
      );
    } catch (e) {
      _showSnack('Error enviando archivo');
      debugPrint('❌ _sendAttachment: $e');
    }
  }

  void _showSnack(String text) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  String _formatSeconds(int s) {
    final m = (s ~/ 60).toString().padLeft(2, '0');
    final sec = (s % 60).toString().padLeft(2, '0');
    return '$m:$sec';
  }

  void _startRecordingTimer() {
    _recordingTimer?.cancel();
    recordingSeconds = 0;

    _recordingTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) {
        setState(() => recordingSeconds++);
      }
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

    final hasPermission = await _audioRecorder.hasPermission();
    if (!hasPermission) {
      _showSnack('Activa el permiso del micrófono');
      return;
    }

    focusNode.unfocus();
    if (show && mounted) {
      setState(() => show = false);
    }

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
  }

  Future<void> cancelAudioRecording() async {
    _stopRecordingTimer();

    try {
      await _audioRecorder.cancel();
    } catch (_) {}

    if (mounted) {
      _resetRecordingState();
    }
  }

  Future<void> stopAudioRecording() async {
    if (!isRecordingAudio) return;

    final dur = recordingSeconds;
    _stopRecordingTimer();

    String? path;
    try {
      path = await _audioRecorder.stop();
    } catch (_) {}

    if (!mounted) return;

    _resetRecordingState();

    final finalPath = path ?? _currentAudioPath;
    if (finalPath == null || finalPath.isEmpty) return;

    final exists = await File(finalPath).exists();
    if (exists) {
      await _sendAudio(
        finalPath,
        durationLabel: _formatSeconds(dur),
      );
    }
  }

  void handleRecordingDrag(LongPressMoveUpdateDetails d) {
    if (!isRecordingAudio || !mounted) return;

    setState(() {
      _dragDx = d.offsetFromOrigin.dx;
      isCancellingAudio = _dragDx <= _cancelThreshold;
    });
  }

  Future<void> openCamera() async {
    final p = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (_) => const CameraScreen(),
      ),
    );

    if (p != null && p.isNotEmpty) {
      await _sendImage(p);
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

  void _confirmClearChat() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Borrar chat'),
        content: const Text(
          '¿Borrar todos los mensajes? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(ctx);

              try {
                final batch = FirebaseFirestore.instance.batch();
                final snap = await FirebaseFirestore.instance
                    .collection('conversations')
                    .doc(_conversationId)
                    .collection('messages')
                    .get();

                for (final doc in snap.docs) {
                  batch.delete(doc.reference);
                }

                await batch.commit();
              } catch (e) {
                _showSnack('Error borrando chat');
                debugPrint('❌ clear chat: $e');
              }
            },
            child: const Text(
              'Borrar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessage(QueryDocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data();
    final isMe = data['senderUid'] == _myUid;
    final content = data['content'] as String? ?? '';
    final ts = data['timestamp'] as Timestamp?;
    final time =
        ts != null ? TimeOfDay.fromDateTime(ts.toDate()).format(context) : '';

    if (_searchQuery.isNotEmpty &&
        !content.toLowerCase().contains(_searchQuery.toLowerCase())) {
      return const SizedBox.shrink();
    }

    return isMe
        ? MessageCard(message: content, time: time)
        : ReplyCard(message: content, time: time);
  }

  Widget _buildRecordingInput() {
    final progress = (_dragDx.abs() / _cancelThreshold.abs()).clamp(0.0, 1.0);

    return Expanded(
      child: Container(
        margin: const EdgeInsets.only(left: 2, right: 2, bottom: 8),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
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
                          ? 'Suelta para borrar'
                          : 'Grabando... ← para borrar',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
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
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(23),
          ),
          child: TextFormField(
            controller: _controller,
            focusNode: focusNode,
            textAlignVertical: TextAlignVertical.center,
            keyboardType: TextInputType.multiline,
            maxLines: 5,
            minLines: 1,
            onChanged: (v) {
              setState(() => sendButton = v.trim().isNotEmpty);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              hintText: 'Type a message',
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
                            _sendAttachment(path, type);
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
    final btn = sendButton
        ? CircleAvatar(
            radius: 24,
            backgroundColor: cs.secondary,
            child: IconButton(
              icon: const Icon(Icons.send, color: Colors.white),
              onPressed: () => _sendText(_controller.text),
            ),
          )
        : GestureDetector(
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
      child: btn,
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
            onChanged: (v) {
              setState(() => _searchQuery = v);
            },
          ),
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
                      ? 'assets/groups.svg'
                      : 'assets/person.svg',
                  colorFilter: const ColorFilter.mode(
                    Colors.white,
                    BlendMode.srcIn,
                  ),
                  height: 36,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  'last seen at ${widget.chatModel.time}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.videocam),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.call),
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (v) {
              switch (v) {
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
                case 'Clear chat':
                  _confirmClearChat();
                  break;
                case 'Mute':
                  _showSnack('Notificaciones silenciadas');
                  break;
              }
            },
            itemBuilder: (_) => const [
              PopupMenuItem(
                value: 'View Contact',
                child: Text('View Contact'),
              ),
              PopupMenuItem(
                value: 'Media',
                child: Text('Media, links and docs'),
              ),
              PopupMenuItem(
                value: 'Search',
                child: Text('Search'),
              ),
              PopupMenuItem(
                value: 'Mute',
                child: Text('Mute Notifications'),
              ),
              PopupMenuItem(
                value: 'Clear chat',
                child: Text('Clear chat'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBody() {
    if (_myUid == null || _myUid!.isEmpty) {
      return const Center(
        child: Text('No hay usuario autenticado'),
      );
    }

    if (_conversationId.isEmpty) {
      return const Center(
        child: Text('No se pudo crear la conversación'),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: MessageService.messagesStream(_conversationId),
      builder: (context, snapshot) {
        debugPrint('STATE: ${snapshot.connectionState}');
        debugPrint('HAS ERROR: ${snapshot.hasError}');
        debugPrint('ERROR: ${snapshot.error}');
        debugPrint('HAS DATA: ${snapshot.hasData}');
        debugPrint('DOCS: ${snapshot.data?.docs.length}');

        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        final docs = snapshot.data?.docs ?? [];

        WidgetsBinding.instance.addPostFrameCallback((_) {
          _scrollToBottom();
        });

        if (docs.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.chat_bubble_outline,
                  size: 60,
                  color: Colors.grey[400],
                ),
                const SizedBox(height: 12),
                Text(
                  'Sé el primero en escribir!',
                  style: TextStyle(
                    color: Colors.grey[500],
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.only(bottom: 12, top: 8),
          itemCount: docs.length,
          itemBuilder: (_, i) => _buildMessage(docs[i]),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset(
            'assets/chat_background.png',
            fit: BoxFit.cover,
          ),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: _buildAppBar(cs),
          body: PopScope(
            canPop: !show,
            onPopInvokedWithResult: (didPop, _) {
              if (show) {
                setState(() => show = false);
              }
            },
            child: Column(
              children: [
                Expanded(child: _buildBody()),
                if (_searchMode && _searchQuery.isNotEmpty)
                  Container(
                    color: cs.primary.withOpacity(0.1),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 4,
                    ),
                    child: Text(
                      'Buscando: "$_searchQuery"',
                      style: TextStyle(
                        color: cs.secondary,
                        fontSize: 13,
                      ),
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

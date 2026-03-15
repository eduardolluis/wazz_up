import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:whatzapp/customUI/message_card.dart';
import 'package:whatzapp/customUI/reply_card.dart';
import 'package:whatzapp/model/chat_model.dart';
import 'package:whatzapp/model/message_model.dart';
import 'package:whatzapp/widgets/attachment_menu_widget.dart';
import 'package:whatzapp/widgets/emoji_picker_widget.dart';
import "package:socket_io_client/socket_io_client.dart" as io;

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
  final FocusNode focusNode = FocusNode();
  bool sendButton = false;
  List<MessageModel> messages = [];
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late io.Socket socket;

  @override
  void initState() {
    super.initState();
    connect();
    focusNode.addListener(() {
      if (focusNode.hasFocus) {
        setState(() {
          show = false;
        });
      }
    });
  }

  @override
  void dispose() {
    focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  void connect() {
    socket = io.io("http://10.0.2.2:5000", <String, dynamic>{
      "transports": ["websocket"],
      "autoConnect": false,
    });
    socket.connect();
    socket.emit("signin", widget.sourceChat.id);

    socket.onConnect((data) {
      print("connected");
      socket.on("message", (msg) {
        print(msg);
        sentMessage("destination", msg["message"]);
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      });
    });
    print(socket.connected);
  }

  void sendMessage(String message, int sourceId, int targetId) {
    sentMessage("source", message);
    if (message.trim().isEmpty) return;
    socket.emit("message", {
      "message": message,
      "sourceId": widget.sourceChat.id,
      "targetId": widget.chatModel.id,
    });
  }

  void sentMessage(String type, String message) {
    MessageModel messageModel = MessageModel(
      type: type,
      message: message,
      time: DateTime.now().toString().substring(10, 16),
    );
    setState(() {
      setState(() {
        messages.add(messageModel);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Stack(
      children: [
        Positioned.fill(
          child: Image.asset("assets/chat_background.png", fit: BoxFit.cover),
        ),
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: PreferredSize(
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
              title: InkWell(
                onTap: () {},
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
                        "last seen at ${widget.chatModel.time}",
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
                IconButton(onPressed: () {}, icon: const Icon(Icons.videocam)),
                IconButton(onPressed: () {}, icon: const Icon(Icons.call)),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_vert),
                  onSelected: (value) {
                    debugPrint(value);
                  },
                  itemBuilder: (context) {
                    return [
                      const PopupMenuItem(
                        value: "New group",
                        child: Text("New group"),
                      ),
                      const PopupMenuItem(
                        value: "View Contact",
                        child: Text("View Contact"),
                      ),
                      const PopupMenuItem(
                        value: "Media",
                        child: Text("Media, links and docs"),
                      ),
                      const PopupMenuItem(
                        value: "Search",
                        child: Text("Search"),
                      ),
                      const PopupMenuItem(
                        value: "Mute",
                        child: Text("Mute Notifications"),
                      ),
                      const PopupMenuItem(
                        value: "Wallpaper",
                        child: Text("Wallpaper"),
                      ),
                    ];
                  },
                ),
              ],
            ),
          ),
          body: PopScope(
            canPop: !show,
            onPopInvokedWithResult: (didPop, result) {
              if (show) {
                setState(() {
                  show = false;
                });
              }
            },
            child: Stack(
              children: [
                SizedBox(
                  height: MediaQuery.of(context).size.height - 150,
                  child: ListView.builder(
                    shrinkWrap: true,
                    controller: _scrollController,
                    itemCount: messages.length,
                    itemBuilder: (BuildContext context, int index) {
                      if (index == messages.length - 1) {
                        return Container(height: 70);
                      }
                      if (messages[index].type == "source") {
                        return MessageCard(
                          message: messages[index].message,
                          time: messages[index].time,
                        );
                      } else {
                        return ReplyCard(
                          message: messages[index].message,
                          time: messages[index].time,
                        );
                      }
                    },
                  ),
                ),
                Align(
                  alignment: Alignment.bottomCenter,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Row(
                        children: [
                          Container(
                            margin: const EdgeInsets.only(
                              left: 2,
                              right: 2,
                              bottom: 8,
                            ),
                            width: MediaQuery.of(context).size.width - 60,
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
                                onChanged: (value) {
                                  if (value.isNotEmpty) {
                                    setState(() {
                                      sendButton = true;
                                    });
                                  } else {
                                    setState(() {
                                      sendButton = false;
                                    });
                                  }
                                },
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  hintText: "Type a message",
                                  contentPadding: const EdgeInsets.all(5),
                                  prefixIcon: IconButton(
                                    icon: const Icon(
                                      Icons.emoji_emotions_outlined,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        if (show) {
                                          show = false;
                                          FocusScope.of(
                                            context,
                                          ).requestFocus(focusNode);
                                        } else {
                                          focusNode.unfocus();
                                          show = true;
                                        }
                                      });
                                    },
                                  ),
                                  suffixIcon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        onPressed: () {
                                          showModalBottomSheet(
                                            context: context,
                                            builder: (builder) =>
                                                AttachmentMenu(),
                                          );
                                        },
                                        icon: const Icon(Icons.attach_file),
                                      ),
                                      IconButton(
                                        onPressed: () {},
                                        icon: const Icon(
                                          Icons.camera_alt_rounded,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.only(
                              bottom: 8,
                              right: 5,
                              left: 2,
                            ),
                            child: CircleAvatar(
                              radius: 20,
                              backgroundColor: cs.secondary,
                              child: IconButton(
                                icon: Icon(
                                  sendButton ? Icons.send : Icons.mic,
                                  color: Colors.white,
                                ),
                                onPressed: () {
                                  if (sendButton) {
                                    _scrollController.animateTo(
                                      _scrollController
                                          .position
                                          .maxScrollExtent,
                                      duration: const Duration(
                                        milliseconds: 300,
                                      ),
                                      curve: Curves.easeOut,
                                    );
                                    sendMessage(
                                      _controller.text,
                                      widget.sourceChat.id,
                                      widget.chatModel.id,
                                    );
                                    _controller.clear();
                                    setState(() {
                                      sendButton = false;
                                    });
                                  }
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                      show ? EmojiSelect(controller: _controller) : Container(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

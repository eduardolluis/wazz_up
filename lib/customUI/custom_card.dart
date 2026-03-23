import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:whatzapp/model/chat_model.dart';
import 'package:whatzapp/screens/individual_screen.dart';

class CustomCard extends StatelessWidget {
  const CustomCard({
    super.key,
    required this.chatModel,
    required this.sourceChat,
  });
  final ChatModel chatModel;
  final ChatModel sourceChat;

  String get _subtitleText {
    final msg = chatModel.currentMessage.trim();
    if (msg.isNotEmpty) return msg;
    return chatModel.status.isNotEmpty ? chatModel.status : 'No messages yet';
  }

  bool get _hasMessage => chatModel.currentMessage.trim().isNotEmpty;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                IndividualPage(chatModel: chatModel, sourceChat: sourceChat),
          ),
        );
      },
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              radius: 30,
              backgroundColor: Colors.blueGrey,
              child: SvgPicture.asset(
                chatModel.isGroup ? "assets/groups.svg" : "assets/person.svg",
                colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                height: 37,
                width: 37,
              ),
            ),
            title: Text(
              chatModel.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Row(
              children: [
                if (_hasMessage) ...[
                  const Icon(Icons.done_all, size: 16, color: Colors.grey),
                  const SizedBox(width: 3),
                ],
                Expanded(
                  child: Text(
                    _subtitleText,
                    style: TextStyle(
                      fontSize: 13,
                      color: _hasMessage ? Colors.grey[700] : Colors.grey[500],
                      fontStyle: _hasMessage ? FontStyle.normal : FontStyle.italic,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            trailing: chatModel.time.isNotEmpty
                ? Text(
                    chatModel.time,
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  )
                : null,
          ),
          Padding(
            padding: const EdgeInsets.only(right: 20, left: 80),
            child: Divider(thickness: 1),
          ),
        ],
      ),
    );
  }
}
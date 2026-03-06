import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wazz_up/model/chat_model.dart';

class IndividualPage extends StatefulWidget {
  const IndividualPage({super.key, required this.chatModel});
  final ChatModel chatModel;

  @override
  State<IndividualPage> createState() => _IndividualPageState();
}

class _IndividualPageState extends State<IndividualPage> {
  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: cs.primary,
        foregroundColor: Colors.white,
        leadingWidth: 70,
        titleSpacing: 0,
        leading: InkWell(
          onTap: () => Navigator.pop(context),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.arrow_back, size: 24),
              CircleAvatar(
                radius: 20,
                backgroundColor: Colors.blueGrey,
                child: SvgPicture.asset(
                  widget.chatModel.isGroup
                      ? "assets/groups.svg"
                      : "assets/person.svg",
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
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
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chatModel.name,
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
                Text(
                  "last seen at ${widget.chatModel.time}",
                  style: TextStyle(fontSize: 13, color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
        actions: [
          IconButton(onPressed: () {}, icon: Icon(Icons.videocam)),
          IconButton(onPressed: () {}, icon: Icon(Icons.call)),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: Colors.white),
            onSelected: (value) {
              print(value);
            },
            itemBuilder: (context) {
              return [
                PopupMenuItem(value: "New group", child: Text("New group")),
                PopupMenuItem(
                  value: "View Contact",
                  child: Text("View Contact"),
                ),
                PopupMenuItem(
                  value: "Medias, links and docs",
                  child: Text("Media, links and docs"),
                ),
                PopupMenuItem(value: "Searchs", child: Text("Search")),
                PopupMenuItem(
                  value: "Mute Notifications",
                  child: Text("Mute Notifications"),
                ),
                PopupMenuItem(value: "Wallpaper", child: Text("Wallpaper")),
              ];
            },
          ),
        ],
      ),
    );
  }
}

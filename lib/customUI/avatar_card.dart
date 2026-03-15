import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:whatzapp/model/chat_model.dart';

class AvatarCard extends StatelessWidget {
  const AvatarCard({super.key, required this.contact});
  final ChatModel contact;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 2),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 23,
                backgroundColor: Colors.blueGrey[200],
                child: SvgPicture.asset(
                  "assets/person.svg",
                  colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
                  height: 30,
                  width: 30,
                ),
              ),
              Positioned(
                bottom: 0,
                right: 0,
                child: CircleAvatar(
                  backgroundColor: Colors.grey,
                  radius: 11,
                  child: Icon(Icons.clear, size: 13, color: Colors.white),
                ),
              ),
            ],
          ),
          SizedBox(height: 2),
          Text(contact.name, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

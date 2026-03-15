import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:whatzapp/model/chat_model.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact});
  final ChatModel contact;

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: SizedBox(
        height: 53,
        width: 50,
        child: Stack(
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
            contact.select
                ? Positioned(
                    bottom: 4,
                    right: 5,
                    child: CircleAvatar(
                      backgroundColor: Colors.teal,
                      radius: 11,
                      child: Icon(Icons.check, size: 18, color: Colors.white),
                    ),
                  )
                : Container(),
          ],
        ),
      ),
      title: Text(
        contact.name,
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
      subtitle: Text(contact.status, style: TextStyle(fontSize: 13)),
    );
  }
}

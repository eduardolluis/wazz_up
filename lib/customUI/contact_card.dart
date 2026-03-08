import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:wazz_up/model/chat_model.dart';

class ContactCard extends StatelessWidget {
  const ContactCard({super.key, required this.contact});
  final ChatModel contact;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {},
      child: ListTile(
        leading: CircleAvatar(
          radius: 23,
          backgroundColor: Colors.blueGrey[200],
          child: SvgPicture.asset(
            "assets/person.svg",
            colorFilter: ColorFilter.mode(Colors.white, BlendMode.srcIn),
            height: 30,
            width: 30,
          ),
        ),
        title: Text(
          contact.name,
          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
        ),
        subtitle: Text(contact.status, style: TextStyle(fontSize: 13)),
      ),
    );
  }
}

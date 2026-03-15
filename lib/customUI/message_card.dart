import 'package:flutter/material.dart';

class MessageCard extends StatelessWidget {
  const MessageCard({super.key, required this.message});
  final String message;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height - 45,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          color: Color(0xFFDCF8C6),
          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                  left: 10,
                  right: 60,
                  top: 5,
                  bottom: 20,
                ),
                child: Text(message, style: TextStyle(fontSize: 16)),
              ),
              Positioned(
                bottom: 4,
                right: 10,
                child: Row(
                  children: [
                    Text(
                      "13:14",
                      style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                    ),
                    SizedBox(width: 5),
                    Icon(Icons.done_all, size: 20),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

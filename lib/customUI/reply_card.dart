import 'dart:io';
import 'package:flutter/material.dart';
import 'package:whatzapp/customUI/full_screen_image.dart';

class ReplyCard extends StatelessWidget {
  const ReplyCard({super.key, required this.message, required this.time});

  final String message;
  final String time;

  bool get isImageMessage {
    final lower = message.toLowerCase();
    return lower.endsWith('.png') ||
        lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.webp');
  }

  @override
  Widget build(BuildContext context) {
    final heroTag = "reply_$message$time";

    return Align(
      alignment: Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        child: Card(
          elevation: 1,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
          child: isImageMessage
              ? Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => FullScreenImagePage(
                              imagePath: message,
                              tag: heroTag,
                            ),
                          ),
                        );
                      },
                      child: Hero(
                        tag: heroTag,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(message),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Padding(
                                padding: EdgeInsets.all(12),
                                child: Text(
                                  "No se pudo cargar la imagen",
                                  style: TextStyle(fontSize: 16),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 8,
                      right: 10,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.black54,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          time,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(
                        left: 10,
                        right: 60,
                        top: 8,
                        bottom: 20,
                      ),
                      child: Text(
                        message,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    Positioned(
                      bottom: 4,
                      right: 10,
                      child: Text(
                        time,
                        style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

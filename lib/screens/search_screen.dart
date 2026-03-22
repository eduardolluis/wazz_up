import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:whatzapp/model/chat_model.dart';
import 'package:whatzapp/screens/individual_screen.dart';

class ChatSearchDelegate extends SearchDelegate<ChatModel?> {
  final List<ChatModel> chats;
  final ChatModel sourceChat;

  ChatSearchDelegate({required this.chats, required this.sourceChat});

  @override
  String get searchFieldLabel => 'Buscar chats...';

  @override
  ThemeData appBarTheme(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Theme.of(context).copyWith(
      appBarTheme: AppBarTheme(backgroundColor: cs.primary),
      inputDecorationTheme: const InputDecorationTheme(
        hintStyle: TextStyle(color: Colors.white70),
        border: InputBorder.none,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(color: Colors.white, fontSize: 18),
      ),
    );
  }

  @override
  List<Widget> buildActions(BuildContext context) => [
        if (query.isNotEmpty)
          IconButton(
            icon: const Icon(Icons.clear, color: Colors.white),
            onPressed: () => query = '',
          ),
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.white),
        onPressed: () => close(context, null),
      );

  @override
  Widget buildResults(BuildContext context) => _buildList(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildList(context);

  Widget _buildList(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text('Escribe para buscar chats',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    final results = chats
        .where((c) =>
            c.name.toLowerCase().contains(query.toLowerCase()) ||
            c.currentMessage
                .toLowerCase()
                .contains(query.toLowerCase()))
        .toList();

    if (results.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey),
            SizedBox(height: 10),
            Text('No se encontraron resultados',
                style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: results.length,
      itemBuilder: (_, i) {
        final chat = results[i];
        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.blueGrey,
            child: SvgPicture.asset(
              chat.isGroup ? 'assets/groups.svg' : 'assets/person.svg',
              colorFilter: const ColorFilter.mode(
                  Colors.white, BlendMode.srcIn),
              height: 24,
            ),
          ),
          title: _highlightedText(chat.name, query),
          subtitle: _highlightedText(chat.currentMessage, query),
          trailing: Text(chat.time,
              style: TextStyle(
                  color: Colors.grey[600], fontSize: 12)),
          onTap: () {
            close(context, chat);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => IndividualPage(
                  chatModel: chat,
                  sourceChat: sourceChat,
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _highlightedText(String text, String query) {
    if (query.isEmpty) return Text(text);
    final lower = text.toLowerCase();
    final queryLower = query.toLowerCase();
    final idx = lower.indexOf(queryLower);
    if (idx < 0) return Text(text);

    return RichText(
      text: TextSpan(
        style: const TextStyle(color: Colors.black, fontSize: 14),
        children: [
          TextSpan(text: text.substring(0, idx)),
          TextSpan(
            text: text.substring(idx, idx + query.length),
            style: const TextStyle(
                backgroundColor: Color(0xFFFFEB3B),
                fontWeight: FontWeight.bold),
          ),
          TextSpan(text: text.substring(idx + query.length)),
        ],
      ),
    );
  }
}
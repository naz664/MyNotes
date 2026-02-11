import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import '../screens/add_note_page.dart';

class NoteSearchDelegate extends SearchDelegate {
  final Box box;
  NoteSearchDelegate(this.box);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = "",
      )
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    final entries = box.toMap().entries.toList();

    // 🔹 Reverse for recent first
    entries.sort((a, b) => b.key.compareTo(a.key));

    // 🔍 If query empty → show 3 recent
    if (query.isEmpty) {
      final recent = entries.take(3).toList();

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              "Recent Notes",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              children: recent.map((entry) {
                final key = entry.key;
                final note = Note.fromMap(
                    Map<String, dynamic>.from(entry.value));

                return ListTile(
                  title: Text(note.title),
                  subtitle: Text(
                    note.content,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () async {
                    close(context, null);
                    final updated = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            AddNotePage(existingNote: note),
                      ),
                    );

                    if (updated != null) {
                      box.put(key, updated.toMap());
                    }
                  },
                );
              }).toList(),
            ),
          ),
        ],
      );
    }

    // 🔎 Filtered results
    final results = entries.where((entry) {
      final note = Note.fromMap(
          Map<String, dynamic>.from(entry.value));
      return note.title
              .toLowerCase()
              .contains(query.toLowerCase()) ||
          note.content
              .toLowerCase()
              .contains(query.toLowerCase());
    }).toList();

    return ListView(
      children: results.map((entry) {
        final key = entry.key;
        final note = Note.fromMap(
            Map<String, dynamic>.from(entry.value));

        return ListTile(
          title: Text(note.title),
          subtitle: Text(
            note.content,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          onTap: () async {
            close(context, null);
            final updated = await Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    AddNotePage(existingNote: note),
              ),
            );

            if (updated != null) {
              box.put(key, updated.toMap());
            }
          },
        );
      }).toList(),
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return buildResults(context);
  }
}

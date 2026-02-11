import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note.dart';
import 'add_note_page.dart';
import '../search/note_search_delegate.dart';

class NotesHome extends StatefulWidget {
  final VoidCallback toggleTheme;
  const NotesHome({super.key, required this.toggleTheme});

  @override
  State<NotesHome> createState() => _NotesHomeState();
}

class _NotesHomeState extends State<NotesHome> {
  final box = Hive.box('notesBox');

  List<MapEntry<dynamic, Note>> get notes =>
      box.toMap().entries.map((entry) {
        return MapEntry(
          entry.key,
          Note.fromMap(Map<String, dynamic>.from(entry.value)),
        );
      }).toList();

  void saveNote(Note note) {
    box.add(note.toMap());
    setState(() {});
  }

  void updateNote(dynamic key, Note note) {
    box.put(key, note.toMap());
    setState(() {});
  }

  void togglePin(dynamic key, Note note) {
    final updated = Note(
      title: note.title,
      content: note.content,
      isPinned: !note.isPinned,
    );
    box.put(key, updated.toMap());
    setState(() {});
  }

  void deleteNote(dynamic key, Note note) {
    box.delete(key);
    setState(() {});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text("Note deleted"),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: "UNDO",
          onPressed: () {
            box.put(key, note.toMap());
            setState(() {});
          },
        ),
      ),
    );
  }

  Future<bool> confirmDelete(dynamic key, Note note) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Delete Note?"),
        content: const Text("Do you want to delete this note?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancel"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Delete"),
          ),
        ],
      ),
    );

    if (confirm == true) {
      deleteNote(key, note);
      return true;
    }
    return false;
  }

  @override
  Widget build(BuildContext context) {
    final pinned = notes.where((e) => e.value.isPinned).toList();
    final unpinned = notes.where((e) => !e.value.isPinned).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notes"),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: NoteSearchDelegate(box),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.brightness_6),
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            if (pinned.isNotEmpty)
              buildSection("📌 Pinned", pinned),
            if (unpinned.isNotEmpty)
              buildSection("📝 Others", unpinned),
          ],
        ),
      ),
      floatingActionButtonLocation:
          FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => const AddNotePage()),
          );
          if (result != null) saveNote(result);
        },
      ),
    );
  }

  Widget buildSection(
      String title, List<MapEntry<dynamic, Note>> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context)
              .textTheme
              .titleLarge!
              .copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: list.length,
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.95,
          ),
          itemBuilder: (context, i) {
            final key = list[i].key;
            final note = list[i].value;

            return Dismissible(
              key: ValueKey(key),
              direction: DismissDirection.endToStart,
              confirmDismiss: (_) =>
                  confirmDelete(key, note),
              background: Container(
                alignment: Alignment.centerRight,
                padding:
                    const EdgeInsets.only(right: 20),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                      BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.delete,
                  color: Colors.white,
                ),
              ),
              child: InkWell(
                borderRadius:
                    BorderRadius.circular(16),
                onTap: () async {
                  final updated =
                      await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddNotePage(
                              existingNote: note),
                    ),
                  );

                  if (updated != null) {
                    updateNote(key, updated);
                  }
                },
                child: Card(
                  shape: RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding:
                        const EdgeInsets.all(14),
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                note.title,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                                style:
                                    const TextStyle(
                                  fontWeight:
                                      FontWeight
                                          .bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: Icon(
                                note.isPinned
                                    ? Icons
                                        .push_pin
                                    : Icons
                                        .push_pin_outlined,
                              ),
                              onPressed: () =>
                                  togglePin(
                                      key, note),
                            )
                          ],
                        ),
                        const SizedBox(
                            height: 8),
                        Text(
                          note.content,
                          maxLines: 4,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                        ),
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

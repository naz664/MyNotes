import 'package:flutter/material.dart';
import '../models/note.dart';

class AddNotePage extends StatefulWidget {
  final Note? existingNote;
  const AddNotePage({super.key, this.existingNote});

  @override
  State<AddNotePage> createState() => _AddNotePageState();
}

class _AddNotePageState extends State<AddNotePage> {
  final titleController = TextEditingController();
  final contentController = TextEditingController();
  bool isPinned = false;

  @override
  void initState() {
    if (widget.existingNote != null) {
      titleController.text = widget.existingNote!.title;
      contentController.text = widget.existingNote!.content;
      isPinned = widget.existingNote!.isPinned;
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingNote == null
            ? "Add Note"
            : "Edit Note"),
        actions: [
          IconButton(
            icon: Icon(
              isPinned
                  ? Icons.push_pin
                  : Icons.push_pin_outlined,
            ),
            onPressed: () =>
                setState(() => isPinned = !isPinned),
          ),
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              Navigator.pop(
                context,
                Note(
                  title: titleController.text,
                  content: contentController.text,
                  isPinned: isPinned,
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 🔹 TITLE LABEL
            const Text(
              "Title",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: titleController,
              decoration: InputDecoration(
                hintText: "Enter title",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // 🔹 NOTE LABEL
            const Text(
              "Note",
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: contentController,
              maxLines: 10,
              decoration: InputDecoration(
                hintText: "Write your note here...",
                border: OutlineInputBorder(
                  borderRadius:
                      BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

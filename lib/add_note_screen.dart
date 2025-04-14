import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class AddNoteScreen extends StatefulWidget {
  const AddNoteScreen({super.key});

  @override
  State<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends State<AddNoteScreen> {
  final _log = Logger('AddNoteScreenState');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();

  @override
  void initState() {
    super.initState();
     _log.fine("initState called");
  }


  @override
  void dispose() {
    _log.fine("dispose called");
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _saveNote() {
     _log.info("Attempting to save note...");
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      _log.warning("Attempted to save an empty note.");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cannot save an empty note.')),
      );
      return;
    }

    final String uniqueId = DateTime.now().toIso8601String() + UniqueKey().toString();

    final noteData = {
      'id': uniqueId,
      'title': title.isEmpty ? 'Untitled Note' : title,
      'content': content,
    };

    _log.fine('Returning note data: $noteData');

    if (mounted) {
      Navigator.pop(context, noteData);
    } else {
       _log.warning("Tried to pop AddNoteScreen, but widget was unmounted.");
    }
  }

  @override
  Widget build(BuildContext context) {
     _log.finer("Building AddNoteScreen widget");
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
             _log.info("AddNoteScreen cancelled via back button.");
             Navigator.pop(context, null);
          },
          tooltip: 'Cancel',
        ),
        title: const Text('Add New Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _saveNote,
            tooltip: 'Save Note',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: <Widget>[
            // Title TextField
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Title',
                hintText: 'Enter note title',
                border: OutlineInputBorder(),
              ),
              style: Theme.of(context).textTheme.titleLarge,
              textCapitalization: TextCapitalization.sentences,
            ),
            const SizedBox(height: 16.0),
            // Content TextField
            TextField(
              controller: _contentController,
              decoration: const InputDecoration(
                labelText: 'Content',
                hintText: 'Enter your note details...',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
              maxLines: 8,
              minLines: 5,
              keyboardType: TextInputType.multiline,
              textCapitalization: TextCapitalization.sentences,
            ),
          ],
        ),
      ),
    );
  }
}
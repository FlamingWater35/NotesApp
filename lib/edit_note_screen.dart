import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class EditNoteScreen extends StatefulWidget {
  final Map<String, String> initialNoteData;
  final String heroTag;

  const EditNoteScreen({
    super.key,
    required this.initialNoteData,
    required this.heroTag,
  });

  @override
  State<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends State<EditNoteScreen> {
  final _log = Logger('EditNoteScreenState');
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late String _noteId; // Store the original ID

  @override
  void initState() {
    super.initState();
    _log.fine("initState called for editing note ID: ${widget.initialNoteData['id']}");
    _titleController = TextEditingController(text: widget.initialNoteData['title']);
    _contentController = TextEditingController(text: widget.initialNoteData['content']);
    _noteId = widget.initialNoteData['id']!; // Assume ID always exists here
  }

  @override
  void dispose() {
    _log.fine("dispose called");
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _updateNote() {
    _log.info("Attempting to update note ID: $_noteId");
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();

    // Prevent saving empty note if needed (or allow it)
    // if (title.isEmpty && content.isEmpty) { ... return; }

    final updatedNoteData = {
      'id': _noteId, // Keep original ID
      'title': title.isEmpty ? 'Untitled Note' : title,
      'content': content,
    };

    _log.fine('Returning updated note data: $updatedNoteData');

    if (mounted) {
      Navigator.pop(context, updatedNoteData);
    } else {
      _log.warning("Tried to pop EditNoteScreen after update, but widget was unmounted.");
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.finer("Building EditNoteScreen widget");
    return Scaffold(
      appBar: AppBar(
        // Back button pops with null
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context, null),
          tooltip: 'Cancel Edit',
        ),
        title: const Text('Edit Note'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _updateNote, 
            tooltip: 'Save Changes',
          ),
          const SizedBox(width: 8),
        ],
      ),

      body: Hero(
        tag: widget.heroTag, // Use the tag passed in constructor
        child: Material(
          type: MaterialType.transparency,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                elevation: 0,
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ListView(
                    children: <Widget>[
                      // Title TextField
                      TextField(
                        controller: _titleController,
                        decoration: const InputDecoration(
                          labelText: 'Title',
                          hintText: 'Enter note title',
                          border: InputBorder.none,
                          filled: false,
                        ),
                        style: Theme.of(context).textTheme.headlineSmall,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null,
                      ),
                      const SizedBox(height: 16.0),
                      // Content TextField
                      TextField(
                        controller: _contentController,
                        decoration: const InputDecoration(
                          labelText: 'Content',
                          hintText: 'Enter your note details...',
                          border: InputBorder.none,
                          filled: false,
                          alignLabelWithHint: true,
                        ),
                        maxLines: null,
                        minLines: 10,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        style: Theme.of(context).textTheme.bodyLarge,
                       ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
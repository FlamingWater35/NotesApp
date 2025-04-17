import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';

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

  late String _initialTitle;
  late String _initialContent;
  DateTime? _selectedDate;
  DateTime? _initialDate;
  late String _createdAtString;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _log.fine("initState called for editing note ID: ${widget.initialNoteData['id']}");
    _initialTitle = widget.initialNoteData['title'] ?? '';
    _initialContent = widget.initialNoteData['content'] ?? '';
    _noteId = widget.initialNoteData['id']!;

    try {
      final dateString = widget.initialNoteData['date'];
      if (dateString != null && dateString.isNotEmpty) {
        _initialDate = DateTime.tryParse(dateString);
      }
    } catch (e) {
      _log.warning("Could not parse initial date string: ${widget.initialNoteData['date']}", e);
    }
    _initialDate ??= DateTime.now();
    _selectedDate = _initialDate;
    _log.fine("Initial date set to: $_initialDate");
    _createdAtString = widget.initialNoteData['createdAt'] ?? DateTime.now().toIso8601String();

    _titleController = TextEditingController(text: widget.initialNoteData['title']);
    _contentController = TextEditingController(text: widget.initialNoteData['content']);
    _titleController.addListener(_checkIfDirty);
    _contentController.addListener(_checkIfDirty);
  }

  @override
  void dispose() {
    _log.fine("dispose called");
    _titleController.removeListener(_checkIfDirty);
    _contentController.removeListener(_checkIfDirty);
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _checkIfDirty() {
    final bool currentlyDirty = _titleController.text != _initialTitle || 
      _contentController.text != _initialContent || _selectedDate != _initialDate;

    if (currentlyDirty != _isDirty) {
      setState(() {
        _isDirty = currentlyDirty;
      });
       _log.finer("Edit screen dirty state changed to: $_isDirty");
    }
  }

  void _updateNote() {
    _log.info("Attempting to update note ID: $_noteId");
    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final String dateString = (_selectedDate ?? _initialDate ?? DateTime.now()).toIso8601String();
    final String modifiedString = DateTime.now().toIso8601String();

    // Prevent saving empty note if needed (or allow it)
    // if (title.isEmpty && content.isEmpty) { ... return; }

    final updatedNoteData = {
      'id': _noteId,
      'title': title.isEmpty ? 'Untitled Note' : title,
      'content': content,
      'date': dateString,
      'createdAt': _createdAtString,
      'lastModified': modifiedString,
    };

    _log.fine('Returning updated note data: $updatedNoteData');

    if (mounted) {
      Navigator.pop(context, updatedNoteData);
    } else {
      _log.warning("Tried to pop EditNoteScreen after update, but widget was unmounted.");
    }
  }

  Future<bool> _showDiscardDialog() async {
    final bool? shouldDiscard = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return AlertDialog(
          title: const Text('Discard changes?'),
          content: const Text('If you go back now, your changes will be lost.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(buildContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(buildContext).colorScheme.error,
              ),
              child: const Text('Discard'),
              onPressed: () => Navigator.of(buildContext).pop(true),
            ),
          ],
        );
      },
      transitionBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation, Widget child) {
        return ScaleTransition(
          scale: CurvedAnimation(
            parent: animation,
            curve: Curves.easeOutBack,
          ),
          child: child,
        );
      },
    );
    return shouldDiscard ?? false;
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
    );

    if (picked != null && picked != _selectedDate && mounted) {
      setState(() {
        _selectedDate = picked;
        _checkIfDirty();
      });
       _log.fine("Date selected: $_selectedDate");
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.finer("Building EditNoteScreen widget");
    final String displayDate = _selectedDate != null
      ? DateFormat.yMMMd().format(_selectedDate!)
      : 'Select Date';
      
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        _log.fine('Pop invoked on EditNoteScreen: didPop: $didPop, isDirty: $_isDirty, result: $result');
        if (didPop) return;

        // Keyboard focus check
        if (mounted && MediaQuery.viewInsetsOf(context).bottom > 0) {
          _log.fine("Keyboard is visible, unfocusing instead of showing discard dialog.");
          FocusScope.of(context).unfocus();
          return;
        }

        final navigator = mounted ? Navigator.of(context, rootNavigator: true) : null;
        final bool shouldDiscard = await _showDiscardDialog();

        if (shouldDiscard && mounted && navigator != null) {
          navigator.pop();
        }
      },

      child: Scaffold(
        appBar: AppBar(
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
          tag: widget.heroTag,
          child: Material(
            type: MaterialType.transparency,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Card(
                  elevation: 0,
                  margin: EdgeInsets.zero,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
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

                        Material(
                          color: Colors.transparent,
                          child: InkWell(
                            onTap: () => _selectDate(context),
                            borderRadius: BorderRadius.circular(8.0),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 12.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(Icons.calendar_today_outlined, size: 20),
                                      const SizedBox(width: 12),
                                      Text(
                                        displayDate,
                                        style: Theme.of(context).textTheme.titleMedium,
                                      ),
                                    ],
                                  ),
                                  const Icon(Icons.arrow_drop_down, color: Colors.grey),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const Divider(height: 1),
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
      ),
    );
  }
}
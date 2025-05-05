import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../models/note_model.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final _log = Logger('AddNoteScreenState');
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  DateTime _selectedDate = DateTime.now();
  late DateTime _initialDate;
  bool _isDirty = false;

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _initialDate = _selectedDate;
    _log.fine("Initial date set to: $_initialDate");

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
    final bool currentlyDirty = _titleController.text.isNotEmpty || _contentController.text.isNotEmpty || 
      _selectedDate != _initialDate;

    if (currentlyDirty != _isDirty) {
      setState(() {
        _isDirty = currentlyDirty;
      });
       _log.finer("Dirty state changed to: $_isDirty");
    }
  }

  void _saveNote() {
    _log.info("Attempting to save note...");
    final String title = _titleController.text.trim();

    if (title.isEmpty) {
      _log.warning("Attempted to save a note without title.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cannot save a note without a title.')),
        );
      }
      return;
    }

    final String content = _contentController.text.trim();
    final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString() + UniqueKey().toString();
    final DateTime now = DateTime.now();

    final newNote = Note(
      id: uniqueId,
      title: title.isEmpty ? 'Untitled Note' : title,
      content: content,
      date: _selectedDate,
      createdAt: now,
      lastModified: now,
    );

    _log.fine('Calling provider to add note data: $newNote');
    ref.read(notesProvider.notifier).addNote(newNote);

    if (mounted) {
      Navigator.pop(context);
    } else {
      _log.warning("Tried to pop AddNoteScreen, but widget was unmounted.");
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
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2200),
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
    _log.finer("Building AddNoteScreen widget");
    final String displayDate = DateFormat.yMMMd().format(_selectedDate);

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        _log.fine('Pop invoked on AddNoteScreen: didPop: $didPop, isDirty: $_isDirty, result: $result');
        if (didPop) return;

        // Keyboard focus check
        // if (mounted && MediaQuery.viewInsetsOf(context).bottom > 0) {
        //   _log.fine("Keyboard is visible, unfocusing instead of showing discard dialog.");
        //   FocusScope.of(context).unfocus();
        //   return;
        // }

        final navigator = mounted ? Navigator.of(context, rootNavigator: true) : null;
        final bool shouldDiscard = await _showDiscardDialog();

        if (shouldDiscard && mounted && navigator != null) {
          navigator.pop();
        }
      },

      child: Scaffold(
        appBar: AppBar(
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
        
        body: SafeArea(
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
                      style: Theme.of(context).textTheme.titleLarge,
                      textCapitalization: TextCapitalization.sentences,
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
                      minLines: 15,
                      keyboardType: TextInputType.multiline,
                      style: Theme.of(context).textTheme.bodyLarge,
                      textCapitalization: TextCapitalization.sentences,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
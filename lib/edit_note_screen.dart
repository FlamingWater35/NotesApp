import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../models/note_model.dart';

class EditNoteScreen extends ConsumerStatefulWidget {
  final String noteId;
  final String heroTag;

  const EditNoteScreen({
    super.key,
    required this.noteId,
    required this.heroTag,
  });

  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen> {
  final _log = Logger('EditNoteScreenState');
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  Note? _originalNote;
  DateTime? _selectedDate;
  bool _isDirty = false;
  bool _isLoading = true;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _log.fine("initState called for editing note ID: ${widget.noteId}");
    _titleController = TextEditingController();
    _contentController = TextEditingController();
    _loadNoteData();
  }

  Future<void> _loadNoteData() async {
    final note = ref.read(notesProvider.notifier).getNoteById(widget.noteId);

    if (note != null && mounted) {
      _originalNote = note;
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedDate = note.date;

      _titleController.addListener(_checkIfDirty);
      _contentController.addListener(_checkIfDirty);

      setState(() {
        _isLoading = false;
      });
      _log.fine("Successfully loaded data for note ID: ${widget.noteId}");
    } else {
      _log.severe("Could not find note with ID ${widget.noteId} to edit.");
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Could not load note data.'), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
    }
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
    if (_originalNote == null) return;

    final bool currentlyDirty = _titleController.text != _originalNote!.title ||
      _contentController.text != _originalNote!.content ||
      _selectedDate != _originalNote!.date;

    if (currentlyDirty != _isDirty) {
      setState(() {
        _isDirty = currentlyDirty;
      });
       _log.finer("Edit screen dirty state changed to: $_isDirty");
    }
  }

  void _updateNote() async {
    if (_originalNote == null || _isSaving) {
      _log.warning("Attempted to update note before it was loaded.");
      return;
    }
    _log.info("Attempting to update note ID: ${widget.noteId}");
    setState(() {
      _isSaving = true;
    });

    final String title = _titleController.text.trim();
    final String content = _contentController.text.trim();
    final DateTime newDate = _selectedDate ?? _originalNote!.date;
    final DateTime modifiedTime = DateTime.now();

    // Prevent saving empty note if needed (or allow it)
    // if (title.isEmpty && content.isEmpty) { ... return; }

    final updatedNote = _originalNote!.copyWith(
      title: title.isEmpty ? 'Untitled Note' : title,
      content: content,
      date: newDate,
      lastModified: modifiedTime,
      // createdAt and id remain the same
    );

    _log.fine('Calling provider to update note data: $updatedNote');
    try {
      await ref.read(notesProvider.notifier).updateNote(updatedNote);
      _log.fine('Provider update successful for ID ${widget.noteId}');

      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e, s) {
      _log.severe('Error saving note via provider', e, s);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error saving note: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
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
    if (_originalNote == null) return;

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

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Edit Note')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_originalNote == null && !_isLoading) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: const Center(child: Text('Failed to load note.')),
      );
    }

    final String displayDate = DateFormat.yMMMd().format(_selectedDate ?? _originalNote!.date);
      
    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        _log.fine('Pop invoked on EditNoteScreen: didPop: $didPop, isDirty: $_isDirty, result: $result');
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
          title: const Text('Edit Note'),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.0),
                  ),
                ),
              )
            else
              Padding(
                padding: EdgeInsets.only(right: 8.0),
                child: Center(
                  child: IconButton(
                    icon: const Icon(Icons.check),
                    onPressed: _isDirty ? _updateNote : null, 
                    tooltip: 'Save Changes',
                  ),
                ),
              ),
          ],
        ),

        body: IgnorePointer(
          ignoring: _isSaving,
          child: Opacity(
            opacity: _isSaving ? 0.5 : 1.0,
            child: Hero(
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
        ),
      ),
    );
  }
}
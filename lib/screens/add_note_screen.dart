import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';

import '../../models/note_model.dart';
import '../l10n/app_localizations.dart';
import '../providers/notes_provider.dart';
import '../widgets/note_editor_content.dart';
import '../widgets/note_editor_dialogs.dart';
import '../widgets/quill_toolbar_widget.dart';

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  late DateTime _initialDate;
  bool _isDirty = false;
  bool _isFullscreen = false;
  final _log = Logger('AddNoteScreenState');
  late QuillController _quillController;
  DateTime _selectedDate = DateTime.now();
  final TextEditingController _titleController = TextEditingController();

  @override
  void dispose() {
    _log.fine("dispose called");
    _titleController.removeListener(_checkIfDirty);
    _quillController.removeListener(_checkIfDirty);
    _titleController.dispose();
    _quillController.dispose();

    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _initialDate = _selectedDate;
    _log.fine("Initial date set to: $_initialDate");

    _quillController = QuillController.basic(
      config: QuillControllerConfig(
        clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
      ),
    );

    _titleController.addListener(_checkIfDirty);
    _quillController.addListener(_checkIfDirty);
  }

  void _checkIfDirty() {
    final bool quillContentChanged = !_quillController.document.isEmpty();
    final bool currentlyDirty =
        _titleController.text.isNotEmpty ||
        quillContentChanged ||
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
    final l10n = AppLocalizations.of(context);
    final String title = _titleController.text.trim();

    if (title.isEmpty) {
      _log.warning("Attempted to save a note without title.");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.cannotSaveNoteWithoutTitle)),
        );
      }
      return;
    }

    final String contentJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );
    final String uniqueId =
        DateTime.now().millisecondsSinceEpoch.toString() +
        UniqueKey().toString();
    final DateTime now = DateTime.now();

    final newNote = Note(
      id: uniqueId,
      title: title,
      content: contentJson,
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

  void _toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
    _log.info("Fullscreen mode toggled to: $_isFullscreen");
  }

  @override
  Widget build(BuildContext context) {
    _log.finer("Building AddNoteScreen widget");
    final l10n = AppLocalizations.of(context);

    final String displayDate = DateFormat.yMMMd().format(_selectedDate);

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (_isFullscreen) {
          _toggleFullscreen();
          return;
        }
        _log.fine(
          'Pop invoked on AddNoteScreen: didPop: $didPop, isDirty: $_isDirty, result: $result',
        );
        if (didPop) return;

        final navigator =
            mounted ? Navigator.of(context, rootNavigator: true) : null;
        final bool shouldDiscard = await showDiscardDialog(context);

        if (shouldDiscard && mounted && navigator != null) {
          navigator.pop();
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addNoteScreenTitle),
          actions: [
            IconButton(
              icon: Icon(
                _isFullscreen ? Icons.fullscreen_exit : Icons.fullscreen,
              ),
              onPressed: _toggleFullscreen,
              tooltip:
                  _isFullscreen
                      ? l10n.exitFullscreenTooltip
                      : l10n.enterFullscreenTooltip,
            ),
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
              tooltip: l10n.saveNoteTooltip,
            ),
            const SizedBox(width: 8),
          ],
        ),

        body: Column(
          children: [
            Expanded(
              child: NoteEditorContentWidget(
                titleController: _titleController,
                quillController: _quillController,
                editorFocusNode: _editorFocusNode,
                editorScrollController: _editorScrollController,
                displayDate: displayDate,
                onSelectDate: () => _selectDate(context),
                l10n: l10n,
                isEditable: true,
                isFullscreen: _isFullscreen,
              ),
            ),
            QuillToolbarWidget(
              controller: _quillController,
              editorFocusNode: _editorFocusNode,
            ),
          ],
        ),
      ),
    );
  }
}

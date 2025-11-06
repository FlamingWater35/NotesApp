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

class EditNoteScreen extends ConsumerStatefulWidget {
  const EditNoteScreen({
    super.key,
    required this.noteId,
    required this.heroTag,
    required this.document,
  });

  final Document document;
  final String heroTag;
  final String noteId;

  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen> {
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  bool _isDirty = false;
  bool _isFullscreen = false;
  bool _isSaving = false;
  bool _isSearchOpen = false;
  final _log = Logger('EditNoteScreenState');
  String _originalContentJson = '';
  Note? _originalNote;
  late QuillController _quillController;
  DateTime? _selectedDate;
  late TextEditingController _titleController;
  final GlobalKey<QuillToolbarWidgetState> _toolbarKey = GlobalKey();

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
    _log.fine("initState called for editing note ID: ${widget.noteId}");

    _originalNote = ref.read(notesProvider.notifier).getNoteById(widget.noteId);

    if (_originalNote != null) {
      _titleController = TextEditingController(text: _originalNote!.title);
      _selectedDate = _originalNote!.date;
      _originalContentJson = _originalNote!.content;

      final Document editorDocument = Document.fromJson(
        widget.document.toDelta().toJson(),
      );

      _quillController = QuillController(
        document: editorDocument,
        selection: const TextSelection.collapsed(offset: 0),
        config: QuillControllerConfig(
          clipboardConfig: QuillClipboardConfig(enableExternalRichPaste: true),
        ),
      );

      _titleController.addListener(_checkIfDirty);
      _quillController.addListener(_checkIfDirty);

      _log.fine("Successfully loaded data for note ID: ${widget.noteId}");
    } else {
      _log.severe("Could not find note with ID ${widget.noteId} to edit.");
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          final l10n = AppLocalizations.of(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(l10n.errorCouldNotLoadNoteData),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
          Navigator.of(context).pop();
        }
      });
    }
  }

  void _checkIfDirty() {
    if (_originalNote == null) return;

    final String currentContentJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );
    final bool contentChanged = currentContentJson != _originalContentJson;

    final bool currentlyDirty =
        _titleController.text != _originalNote!.title ||
        contentChanged ||
        _selectedDate != _originalNote!.date;

    if (currentlyDirty != _isDirty) {
      setState(() {
        _isDirty = currentlyDirty;
      });
      _log.finer("Edit screen dirty state changed to: $_isDirty");
    }
  }

  void _updateNote() async {
    _log.info("Attempting to update note ID: ${widget.noteId}");
    final l10n = AppLocalizations.of(context);
    if (_originalNote == null || _isSaving) {
      _log.warning(
        "Attempted to update note before it was loaded or while saving.",
      );
      return;
    }

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

    setState(() {
      _isSaving = true;
    });

    final String contentJson = jsonEncode(
      _quillController.document.toDelta().toJson(),
    );
    final DateTime newDate = _selectedDate ?? _originalNote!.date;
    final DateTime modifiedTime = DateTime.now();

    final updatedNote = _originalNote!.copyWith(
      title: title,
      content: contentJson,
      date: newDate,
      lastModified: modifiedTime,
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
            content: Text(l10n.errorSavingNote(e.toString())),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
        setState(() {
          _isSaving = false;
        });
      }
    } finally {
      if (mounted && _isSaving) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    if (_originalNote == null) return;

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
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
    _log.finer("Building EditNoteScreen widget");
    final l10n = AppLocalizations.of(context);

    if (_originalNote == null) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.errorAppBarTitle)),
        body: Center(child: Text(l10n.failedToLoadNote)),
      );
    }

    final displayDate = DateFormat.yMMMd().format(
      _selectedDate ?? _originalNote?.date ?? DateTime.now(),
    );

    return PopScope(
      canPop: !_isDirty || _isSaving,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        if (_isSearchOpen) {
          _toolbarKey.currentState?.closeSearchView();
          return;
        }
        if (_isFullscreen) {
          _toggleFullscreen();
          return;
        }
        _log.fine(
          'Pop invoked on EditNoteScreen: didPop: $didPop, isDirty: $_isDirty, result: $result',
        );
        if (didPop || _isSaving) return;

        final navigator =
            mounted ? Navigator.of(context, rootNavigator: true) : null;
        final bool shouldDiscard = await showDiscardDialog(context);

        if (shouldDiscard && mounted && navigator != null) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editNoteScreenTitle),
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
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: Colors.white,
                    ),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed:
                      (_isDirty && !_isSaving && !_isSearchOpen)
                          ? _updateNote
                          : null,
                  tooltip: l10n.saveChangesTooltip,
                ),
              ),
          ],
        ),
        body: IgnorePointer(
          ignoring: _isSaving,
          child: Opacity(
            opacity: _isSaving ? 0.5 : 1.0,
            child: Column(
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
                    isEditable: !_isSaving,
                    heroTag: widget.heroTag,
                    isFullscreen: _isFullscreen,
                  ),
                ),
                QuillToolbarWidget(
                  key: _toolbarKey,
                  controller: _quillController,
                  editorFocusNode: _editorFocusNode,
                  onSearchVisibilityChanged: (isOpen) {
                    if (mounted) {
                      setState(() => _isSearchOpen = isOpen);
                    }
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

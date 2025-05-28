import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../models/note_model.dart';
import 'package:notes_app/l10n/app_localizations.dart';

class EditNoteScreen extends ConsumerStatefulWidget {
  const EditNoteScreen({
    super.key,
    required this.noteId,
    required this.heroTag,
  });

  final String heroTag;
  final String noteId;

  @override
  ConsumerState<EditNoteScreen> createState() => _EditNoteScreenState();
}

class _EditNoteScreenState extends ConsumerState<EditNoteScreen> {
  final ScrollController _cardScrollController = ScrollController();
  final FocusNode _editorFocusNode = FocusNode();
  final ScrollController _editorScrollController = ScrollController();
  bool _isDirty = false;
  bool _isLoading = true;
  bool _isSaving = false;
  final _log = Logger('EditNoteScreenState');
  String _originalContentJson = '';
  Note? _originalNote;
  late QuillController _quillController;
  DateTime? _selectedDate;
  late TextEditingController _titleController;

  @override
  void dispose() {
    _log.fine("dispose called");
    _titleController.removeListener(_checkIfDirty);
    _quillController.removeListener(_checkIfDirty);
    _titleController.dispose();

    _quillController.dispose();
    _editorFocusNode.dispose();
    _editorScrollController.dispose();
    _cardScrollController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _log.fine("initState called for editing note ID: ${widget.noteId}");
    _titleController = TextEditingController();
    _quillController = QuillController.basic();
    _loadNoteData();
  }

  Future<void> _loadNoteData() async {
    final note = ref.read(notesProvider.notifier).getNoteById(widget.noteId);

    if (note != null && mounted) {
      _originalNote = note;
      _titleController.text = note.title;
      _selectedDate = note.date;
      _originalContentJson = note.content;

      final Document doc = note.contentDocument;
      _quillController = QuillController(
        document: doc,
        selection: const TextSelection.collapsed(offset: 0),
        config: QuillControllerConfig(
          clipboardConfig: QuillClipboardConfig(
            enableExternalRichPaste: true,
          ),
        ),
      );

      _titleController.addListener(_checkIfDirty);
      _quillController.addListener(_checkIfDirty);

      setState(() {
        _isLoading = false;
      });
      _log.fine("Successfully loaded data for note ID: ${widget.noteId}");
    } else {
      _log.severe("Could not find note with ID ${widget.noteId} to edit.");
      if (mounted) {
        final l10n = AppLocalizations.of(context);
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(l10n.errorCouldNotLoadNoteData), backgroundColor: Colors.red),
        );
        Navigator.of(context).pop();
      }
    }
  }

  void _checkIfDirty() {
    if (_originalNote == null) return;

    final String currentContentJson = jsonEncode(_quillController.document.toDelta().toJson());
    final bool contentChanged = currentContentJson != _originalContentJson;

    final bool currentlyDirty = _titleController.text != _originalNote!.title ||
      contentChanged || _selectedDate != _originalNote!.date;

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
      _log.warning("Attempted to update note before it was loaded or while saving.");
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

    final String contentJson = jsonEncode(_quillController.document.toDelta().toJson());
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

  Future<bool> _showDiscardDialog() async {
    final l10n = AppLocalizations.of(context);
    final bool? shouldDiscard = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return AlertDialog(
          title: Text(l10n.discardChangesDialogTitle),
          content: Text(l10n.discardChangesDialogContent),
          actions: <Widget>[
            TextButton(
              child: Text(l10n.cancelButtonLabel),
              onPressed: () => Navigator.of(buildContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(buildContext).colorScheme.error,
              ),
              child: Text(l10n.discardButtonLabel),
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
    _log.finer("Building EditNoteScreen widget");
    final l10n = AppLocalizations.of(context);

    if (_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.editNoteScreenTitle)),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    if (_originalNote == null && !_isLoading) {
      return Scaffold(
        appBar: AppBar(title: Text(l10n.errorAppBarTitle)),
        body: Center(child: Text(l10n.failedToLoadNote)),
      );
    }

    final displayDate = DateFormat.yMMMd().format(_selectedDate ?? _originalNote!.date);

    final quillEditor = QuillEditor(
      focusNode: _editorFocusNode,
      scrollController: _editorScrollController,
      controller: _quillController,
      config: QuillEditorConfig(
        placeholder: l10n.quillPlaceholder,
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        autoFocus: false,
        scrollable: false,
        expands: false,
        minHeight: MediaQuery.of(context).size.height * 0.2,
        // Custom styles
        // customStyles: DefaultStyles( ... ),
        onLaunchUrl: (url) async {
          // Handle URL launching
          _log.finer("Attempting to launch URL: $url");
        },
      ),
    );

    Widget noteEditorArea = Hero(
      tag: widget.heroTag,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: true,
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
            child: Card(
              elevation: 0,
              margin: EdgeInsets.zero,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: Scrollbar(
                  controller: _cardScrollController,
                  interactive: true,
                  thickness: 4.0,
                  radius: const Radius.circular(4.0),
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints viewportConstraints) {
                      return SingleChildScrollView(
                        controller: _cardScrollController,
                        child: ConstrainedBox(
                          constraints: BoxConstraints(
                            minHeight: viewportConstraints.maxHeight,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(16.0, 16.0, 16.0, 8.0),
                                child: TextField(
                                  controller: _titleController,
                                  enabled: !_isSaving,
                                  decoration: InputDecoration(
                                    hintText: l10n.titleHint,
                                    border: InputBorder.none,
                                  ),
                                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                                  textCapitalization: TextCapitalization.sentences,
                                  maxLines: null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: _isSaving ? null : () => _selectDate(context),
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(vertical: 12.0),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 6),
                                          const Icon(Icons.calendar_today_outlined, size: 20),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              displayDate,
                                              style: Theme.of(context).textTheme.titleMedium,
                                            ),
                                          ),
                                          Icon(Icons.arrow_drop_down, color: Colors.grey.withAlpha(_isSaving ? 128 : 255)),
                                          const SizedBox(width: 6),
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.0),
                                child: Divider(height: 1),
                              ),
                              const SizedBox(height: 16.0),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                child: Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Theme.of(context).colorScheme.primary.withAlpha(150)),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.fromLTRB(1.5, 3.0, 1.5, 3.0),
                                    child: quillEditor,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20.0),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    Widget quillToolbar = Material(
      elevation: 4.0,
      color: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 2.0), 
          child: QuillSimpleToolbar(
            controller: _quillController,
            config: QuillSimpleToolbarConfig(
              multiRowsDisplay: false,
              toolbarSize: 48.0,
              toolbarIconAlignment: WrapAlignment.spaceAround,
              showAlignmentButtons: true,
              showLink: false,
              showQuote: false,
              showStrikeThrough: false,
              showCodeBlock: false,
              showInlineCode: false,
              buttonOptions: QuillSimpleToolbarButtonOptions(
                base: QuillToolbarBaseButtonOptions(
                  iconSize: 22,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    return PopScope(
      canPop: !_isDirty || _isSaving,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        _log.fine('Pop invoked on EditNoteScreen: didPop: $didPop, isDirty: $_isDirty, result: $result');
        if (didPop || _isSaving) return;

        final navigator = mounted ? Navigator.of(context, rootNavigator: true) : null;
        final bool shouldDiscard = await _showDiscardDialog();

        if (shouldDiscard && mounted && navigator != null) {
          navigator.pop();
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.editNoteScreenTitle),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.only(right: 16.0),
                child: Center(
                  child: SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2.5, color: Colors.white),
                  ),
                ),
              )
            else
              Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: IconButton(
                  icon: const Icon(Icons.check),
                  onPressed: (_isDirty && !_isSaving) ? _updateNote : null,
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
                  child: noteEditorArea,
                ),
                if (!_isLoading && _originalNote != null)
                  quillToolbar,
              ],
            ),
          ),
        ),
      ),
    );
  }
}
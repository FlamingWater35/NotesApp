import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/providers.dart';
import '../models/note_model.dart';
import 'package:notes_app/l10n/app_localizations.dart';

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
        clipboardConfig: QuillClipboardConfig(
          enableExternalRichPaste: true,
          // onImagePaste: 
        ),
      ),
    );

    _titleController.addListener(_checkIfDirty);
    _quillController.addListener(_checkIfDirty);
  }

  void _checkIfDirty() {
    final bool quillContentChanged = !_quillController.document.isEmpty();
    final bool currentlyDirty = _titleController.text.isNotEmpty ||
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

    final String contentJson = jsonEncode(_quillController.document.toDelta().toJson());
    final String uniqueId = DateTime.now().millisecondsSinceEpoch.toString() + UniqueKey().toString();
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
    final l10n = AppLocalizations.of(context);
    final String displayDate = DateFormat.yMMMd().format(_selectedDate);

    final quillEditor = QuillEditor(
      focusNode: _editorFocusNode,
      scrollController: _editorScrollController,
      controller: _quillController,
      config: QuillEditorConfig(
        placeholder: l10n.quillPlaceholder,
        padding: const EdgeInsets.symmetric(vertical: 6),
        autoFocus: false,
        scrollable: true,
        minHeight: MediaQuery.of(context).size.height * 0.3,
        // Custom styles
        // customStyles: DefaultStyles( ... ),
        onLaunchUrl: (url) async {
          // Handle URL launching
          _log.finer("Attempting to launch URL: $url");
        },
      ),
    );


    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        _log.fine('Pop invoked on AddNoteScreen: didPop: $didPop, isDirty: $_isDirty, result: $result');
        if (didPop) return;

        final navigator = mounted ? Navigator.of(context, rootNavigator: true) : null;
        final bool shouldDiscard = await _showDiscardDialog();

        if (shouldDiscard && mounted && navigator != null) {
          navigator.pop();
        }
      },

      child: Scaffold(
        appBar: AppBar(
          title: Text(l10n.addNoteScreenTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveNote,
              tooltip: l10n.saveNoteTooltip,
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
                      decoration: InputDecoration(
                        // labelText: l10n.titleHint,
                        hintText: l10n.titleHint,
                        border: InputBorder.none,
                        filled: false,
                      ),
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                      textCapitalization: TextCapitalization.sentences,
                    ),
                    const SizedBox(height: 8.0),

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
                    const SizedBox(height: 8.0),

                    QuillSimpleToolbar(
                      controller: _quillController,
                      config: QuillSimpleToolbarConfig(
                        showAlignmentButtons: true,
                        showLink: false,
                        showQuote: false,
                        showStrikeThrough: false,
                        showCodeBlock: false,
                        showInlineCode: false,
                        // buttonOptions: QuillSimpleToolbarButtonOptions()
                      ),
                    ),
                    const Divider(height: 1),
                    const SizedBox(height: 12.0),

                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).colorScheme.primary),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(10.0, 3.0, 10.0, 3.0), 
                        child: quillEditor,
                      ),
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
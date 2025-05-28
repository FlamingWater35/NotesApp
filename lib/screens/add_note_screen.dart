import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/providers.dart';
import '../../models/note_model.dart';
import 'package:notes_app/l10n/app_localizations.dart';

import '../widgets/note_editor_utils.dart';

enum _ToolbarSection {
  none,
  textOptions,
  headerStyle,
  listStyle,
  alignment,
  indentation,
}

class AddNoteScreen extends ConsumerStatefulWidget {
  const AddNoteScreen({super.key});

  @override
  ConsumerState<AddNoteScreen> createState() => _AddNoteScreenState();
}

class _AddNoteScreenState extends ConsumerState<AddNoteScreen> {
  static final double _toolbarIconSize = 20;

  _ToolbarSection _activeToolbarSection = _ToolbarSection.none;
  final ScrollController _cardScrollController = ScrollController();
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
    _cardScrollController.dispose();
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

  void _toggleActiveToolbarSection(_ToolbarSection section) {
    setState(() {
      if (_activeToolbarSection == section) {
        _activeToolbarSection = _ToolbarSection.none;
      } else {
        _activeToolbarSection = section;
      }
    });
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

    Widget noteEditorArea = Material(
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
                                  onTap: () => _selectDate(context),
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
                                        Icon(Icons.arrow_drop_down, color: Colors.grey),
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
    );

    Widget buildExpandableSectionContainer(List<Widget> children) {
      return Container(
        color: Theme.of(context).canvasColor.withAlpha(64),
        padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: children.map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 2.0), child: e)).toList(),
        ),
      );
    }

    Widget buildTextOptionsToolbar() {
      return buildExpandableSectionContainer([
        QuillToolbarFontFamilyButton(
          controller: _quillController,
          options: QuillToolbarFontFamilyButtonOptions(
            attribute: Attribute.font,
            iconSize: _toolbarIconSize,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        QuillToolbarFontSizeButton(
          controller: _quillController,
          options: QuillToolbarFontSizeButtonOptions(
            iconSize: _toolbarIconSize,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        QuillToolbarColorButton(
          controller: _quillController,
          isBackground: false,
          options: QuillToolbarColorButtonOptions(
            iconSize: _toolbarIconSize,
          ),
        ),
        QuillToolbarColorButton(
          controller: _quillController,
          isBackground: true,
          options: QuillToolbarColorButtonOptions(
            iconSize: _toolbarIconSize,
          ),
        ),
      ]);
    }

    Widget buildHeaderStyleToolbar() {
      return buildExpandableSectionContainer([
        QuillToolbarSelectHeaderStyleDropdownButton(
          controller: _quillController,
          options: QuillToolbarSelectHeaderStyleDropdownButtonOptions(
            iconSize: _toolbarIconSize,
          ),
        ),
        QuillToolbarToggleStyleButton(
          controller: _quillController,
          attribute: Attribute.blockQuote,
          options: QuillToolbarToggleStyleButtonOptions(
            iconData: Icons.format_quote,
            iconSize: _toolbarIconSize,
          ),
        ),
        QuillToolbarToggleStyleButton(
          controller: _quillController,
          attribute: Attribute.codeBlock,
          options: QuillToolbarToggleStyleButtonOptions(
            iconData: Icons.code,
            iconSize: _toolbarIconSize,
          ),
        ),
      ]);
    }

    Widget buildListStyleToolbar() {
      return buildExpandableSectionContainer([
        QuillToolbarToggleStyleButton(
          controller: _quillController,
          attribute: Attribute.ul,
          options: QuillToolbarToggleStyleButtonOptions(
            iconData: Icons.format_list_bulleted,
            iconSize: _toolbarIconSize,
          ),
        ),
        QuillToolbarToggleStyleButton(
          controller: _quillController,
          attribute: Attribute.ol,
          options: QuillToolbarToggleStyleButtonOptions(
            iconData: Icons.format_list_numbered,
            iconSize: _toolbarIconSize,
          ),
        ),
        QuillToolbarToggleCheckListButton(
          controller: _quillController,
          options: QuillToolbarToggleCheckListButtonOptions(
            iconData: Icons.check_box,
            iconSize: _toolbarIconSize,
          ),
        ),
      ]);
    }

    Widget buildAlignmentToolbar() {
      return buildExpandableSectionContainer([
        QuillToolbarToggleStyleButton(
          controller: _quillController,
          attribute: Attribute.leftAlignment,
          options: QuillToolbarToggleStyleButtonOptions(
            iconSize: _toolbarIconSize,
          ),
        ),
        QuillToolbarToggleStyleButton(
          controller: _quillController,
          attribute: Attribute.centerAlignment,
          options: QuillToolbarToggleStyleButtonOptions(
            iconSize: _toolbarIconSize,
          ),
        ),
        QuillToolbarToggleStyleButton(
          controller: _quillController,
          attribute: Attribute.rightAlignment,
          options: QuillToolbarToggleStyleButtonOptions(
            iconSize: _toolbarIconSize,
          ),
        ),
        QuillToolbarToggleStyleButton(
          controller: _quillController,
          attribute: Attribute.justifyAlignment,
          options: QuillToolbarToggleStyleButtonOptions(
            iconSize: _toolbarIconSize,
          ),
        ),
      ]);
    }

    Widget buildIndentationToolbar() {
      return buildExpandableSectionContainer([
        QuillToolbarIndentButton(
          controller: _quillController,
          isIncrease: false,
          options: QuillToolbarIndentButtonOptions(
            iconData: Icons.format_indent_decrease,
            iconSize: _toolbarIconSize,
          ),
        ),
        QuillToolbarIndentButton(
          controller: _quillController,
          isIncrease: true,
          options: QuillToolbarIndentButtonOptions(
            iconData: Icons.format_indent_increase,
            iconSize: _toolbarIconSize,
          ),
        ),
      ]);
    }

    Widget buildMainToolbarToggleButton(_ToolbarSection section, IconData icon, IconData activeIcon) {
      bool isActive = _activeToolbarSection == section;
      return IconButton(
        icon: Icon(isActive ? activeIcon : icon, size: _toolbarIconSize),
        iconSize: _toolbarIconSize,
        color: isActive ? Theme.of(context).colorScheme.primary : null,
        onPressed: () => _toggleActiveToolbarSection(section),
      );
    }

    Widget currentExpandedToolbar;
      switch (_activeToolbarSection) {
        case _ToolbarSection.textOptions:
          currentExpandedToolbar = buildTextOptionsToolbar();
          break;
        case _ToolbarSection.headerStyle:
          currentExpandedToolbar = buildHeaderStyleToolbar();
          break;
        case _ToolbarSection.listStyle:
          currentExpandedToolbar = buildListStyleToolbar();
          break;
        case _ToolbarSection.alignment:
          currentExpandedToolbar = buildAlignmentToolbar();
          break;
        case _ToolbarSection.indentation:
          currentExpandedToolbar = buildIndentationToolbar();
          break;
        case _ToolbarSection.none:
          currentExpandedToolbar = const SizedBox.shrink();
      }

    Widget mainCompactToolbar = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Row(
        children: [
          QuillToolbarHistoryButton(controller: _quillController, isUndo: true, options: QuillToolbarHistoryButtonOptions(iconSize: _toolbarIconSize)),
          QuillToolbarHistoryButton(controller: _quillController, isUndo: false, options: QuillToolbarHistoryButtonOptions(iconSize: _toolbarIconSize)),
          const VerticalDivider(indent: 6, endIndent: 6),
          QuillToolbarToggleStyleButton(controller: _quillController, attribute: Attribute.bold, options: QuillToolbarToggleStyleButtonOptions(iconSize: _toolbarIconSize)),
          QuillToolbarToggleStyleButton(controller: _quillController, attribute: Attribute.italic, options: QuillToolbarToggleStyleButtonOptions(iconSize: _toolbarIconSize)),
          QuillToolbarToggleStyleButton(controller: _quillController, attribute: Attribute.underline, options: QuillToolbarToggleStyleButtonOptions(iconSize: _toolbarIconSize)),
          QuillToolbarToggleStyleButton(controller: _quillController, attribute: Attribute.strikeThrough, options: QuillToolbarToggleStyleButtonOptions(iconSize: _toolbarIconSize)),
          QuillToolbarClearFormatButton(controller: _quillController, options: QuillToolbarClearFormatButtonOptions(iconSize: _toolbarIconSize)),
          const VerticalDivider(indent: 6, endIndent: 6),
          buildMainToolbarToggleButton(_ToolbarSection.textOptions, Icons.font_download, Icons.font_download_off),
          buildMainToolbarToggleButton(_ToolbarSection.headerStyle, Icons.text_fields, Icons.text_format),
          buildMainToolbarToggleButton(_ToolbarSection.listStyle, Icons.list, Icons.format_list_bulleted_outlined),
          buildMainToolbarToggleButton(_ToolbarSection.alignment, Icons.format_align_center, Icons.format_clear),
          buildMainToolbarToggleButton(_ToolbarSection.indentation, Icons.format_indent_increase, Icons.wrap_text),
          const VerticalDivider(indent: 6, endIndent: 6),
          QuillToolbarLinkStyleButton(controller: _quillController, options: QuillToolbarLinkStyleButtonOptions(iconSize: _toolbarIconSize)),
          // QuillToolbarImageButton(controller: _quillController, iconSize: _toolbarIconSize, tooltip: l10n.insertImageTooltip),
          // QuillToolbarVideoButton(controller: _quillController, iconSize: _toolbarIconSize, tooltip: l10n.insertVideoTooltip),
        ].map((e) => Padding(padding: const EdgeInsets.symmetric(horizontal: 1.0), child: e)).toList(),
      ),
    );

    Widget quillToolbarWidget = Material(
      elevation: 4.0,
      color: Theme.of(context).bottomAppBarTheme.color ?? Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 200),
              transitionBuilder: (Widget child, Animation<double> animation) {
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: -1.0,
                  child: child,
                );
              },
              child: currentExpandedToolbar,
            ),
            mainCompactToolbar,
          ],
        ),
      ),
    );

    return PopScope(
      canPop: !_isDirty,
      onPopInvokedWithResult: (bool didPop, dynamic result) async {
        _log.fine('Pop invoked on AddNoteScreen: didPop: $didPop, isDirty: $_isDirty, result: $result');
        if (didPop) return;

        final navigator = mounted ? Navigator.of(context, rootNavigator: true) : null;
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
              child: noteEditorArea,
            ),
            quillToolbarWidget,
          ],
        ),
      ),
    );
  }
}
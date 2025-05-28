import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import '../l10n/app_localizations.dart';

class NoteEditorContentWidget extends StatelessWidget {
  const NoteEditorContentWidget({
    super.key,
    required this.titleController,
    required this.quillController,
    required this.editorFocusNode,
    required this.editorScrollController,
    required this.cardScrollController,
    required this.displayDate,
    required this.onSelectDate,
    required this.l10n,
    this.isEditable = true,
    this.heroTag,
  });

  final ScrollController cardScrollController;
  final String displayDate;
  final FocusNode editorFocusNode;
  final ScrollController editorScrollController;
  final String? heroTag;
  final bool isEditable;
  final AppLocalizations l10n;
  final VoidCallback onSelectDate;
  final QuillController quillController;
  final TextEditingController titleController;

  @override
  Widget build(BuildContext context) {
    final quillEditor = QuillEditor(
      focusNode: editorFocusNode,
      scrollController: editorScrollController,
      controller: quillController,
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
        },
      ),
    );

    Widget editorAreaContent = Material(
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
                controller: cardScrollController,
                interactive: true,
                thickness: 4.0,
                radius: const Radius.circular(4.0),
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints viewportConstraints) {
                    return SingleChildScrollView(
                      controller: cardScrollController,
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
                                controller: titleController,
                                enabled: isEditable,
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
                                  onTap: isEditable ? onSelectDate : null,
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
                                        Icon(Icons.arrow_drop_down, color: Colors.grey.withAlpha(isEditable ? 255 : 128)),
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
    
    if (heroTag != null) {
      return Hero(tag: heroTag!, child: editorAreaContent);
    }
    return editorAreaContent;
  }
}
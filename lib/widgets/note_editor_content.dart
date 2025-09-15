import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../l10n/app_localizations.dart';

class NoteEditorContentWidget extends StatelessWidget {
  const NoteEditorContentWidget({
    super.key,
    required this.titleController,
    this.quillController,
    required this.editorFocusNode,
    required this.editorScrollController,
    required this.displayDate,
    required this.onSelectDate,
    required this.l10n,
    this.isEditable = true,
    this.heroTag,
  });

  final String displayDate;
  final FocusNode editorFocusNode;
  final ScrollController editorScrollController;
  final String? heroTag;
  final bool isEditable;
  final AppLocalizations l10n;
  final VoidCallback onSelectDate;
  final QuillController? quillController;
  final TextEditingController titleController;

  @override
  Widget build(BuildContext context) {
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
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        constraints: BoxConstraints(
                          maxHeight: constraints.maxHeight * 0.4,
                        ),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  16.0,
                                  16.0,
                                  16.0,
                                  8.0,
                                ),
                                child: TextField(
                                  controller: titleController,
                                  enabled: isEditable,
                                  decoration: InputDecoration(
                                    hintText: l10n.titleHint,
                                    border: InputBorder.none,
                                  ),
                                  style: Theme.of(context)
                                      .textTheme
                                      .headlineSmall
                                      ?.copyWith(fontWeight: FontWeight.bold),
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  maxLines: null,
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0,
                                ),
                                child: Material(
                                  color: Colors.transparent,
                                  child: InkWell(
                                    onTap: isEditable ? onSelectDate : null,
                                    borderRadius: BorderRadius.circular(8.0),
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12.0,
                                      ),
                                      child: Row(
                                        children: [
                                          const SizedBox(width: 6),
                                          const Icon(
                                            Icons.calendar_today_outlined,
                                            size: 20,
                                          ),
                                          const SizedBox(width: 12),
                                          Expanded(
                                            child: Text(
                                              displayDate,
                                              style:
                                                  Theme.of(
                                                    context,
                                                  ).textTheme.titleMedium,
                                            ),
                                          ),
                                          Icon(
                                            Icons.arrow_drop_down,
                                            color: Colors.grey.withAlpha(
                                              isEditable ? 255 : 128,
                                            ),
                                          ),
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
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16.0),

                      Expanded(
                        child: Scrollbar(
                          controller: editorScrollController,
                          interactive: true,
                          thickness: 6.0,
                          radius: const Radius.circular(4.0),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              8.0,
                              0,
                              8.0,
                              8.0,
                            ),
                            child: Container(
                              decoration: BoxDecoration(
                                border: Border.all(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(100),
                                ),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.fromLTRB(
                                  1.5,
                                  3.0,
                                  1.5,
                                  3.0,
                                ),
                                child:
                                    (quillController == null)
                                        ? const Center(
                                          child: CircularProgressIndicator(),
                                        )
                                        : QuillEditor(
                                          focusNode: editorFocusNode,
                                          scrollController:
                                              editorScrollController,
                                          controller: quillController!,
                                          config: QuillEditorConfig(
                                            placeholder: l10n.quillPlaceholder,
                                            padding: const EdgeInsets.symmetric(
                                              vertical: 10,
                                              horizontal: 10,
                                            ),
                                            autoFocus: false,
                                            scrollable: true,
                                            expands: true,
                                            onLaunchUrl: (url) async {},
                                          ),
                                        ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                },
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

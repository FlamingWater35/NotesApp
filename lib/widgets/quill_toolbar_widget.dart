import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

import '../l10n/app_localizations.dart';
import 'custom_quill_buttons.dart';

enum ToolbarSection {
  none,
  commonOptions,
  textOptions,
  headerStyle,
  listStyle,
  alignment,
}

class QuillToolbarWidget extends StatefulWidget {
  const QuillToolbarWidget({
    super.key,
    required this.controller,
    this.editorFocusNode,
  });

  static const double defaultMainToolbarIconSize = 30.0;
  static const double defaultToolbarIconSize = 20.0;

  final QuillController controller;
  final FocusNode? editorFocusNode;

  @override
  State<QuillToolbarWidget> createState() => _QuillToolbarWidgetState();
}

class _QuillToolbarWidgetState extends State<QuillToolbarWidget> {
  static final _searchActiveHighlightAttribute = BackgroundAttribute('#ffcc80');
  static final _searchHighlightAttribute = BackgroundAttribute('#fff59d');

  ToolbarSection _activeToolbarSection = ToolbarSection.none;
  int _currentSearchMatchIndex = -1;
  bool _isReplaceVisible = false;
  bool _isSearchActive = false;
  bool _isSearchCaseSensitive = false;
  final _replaceController = TextEditingController();
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _searchMatches = <TextRange>[];

  @override
  void dispose() {
    _searchController.removeListener(_runSearch);
    _searchController.dispose();
    _replaceController.dispose();
    _searchFocusNode.dispose();
    _clearHighlights();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_runSearch);
  }

  void _toggleActiveToolbarSection(ToolbarSection section) {
    setState(() {
      if (_activeToolbarSection == section) {
        _activeToolbarSection = ToolbarSection.none;
      } else {
        _activeToolbarSection = section;
      }
    });
  }

  void _toggleSearchView() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _searchFocusNode.requestFocus();
      } else {
        widget.editorFocusNode?.requestFocus();
        _clearHighlights();
        _searchController.clear();
        _searchMatches.clear();
        _currentSearchMatchIndex = -1;
        _isReplaceVisible = false;
        _replaceController.clear();
      }
    });
  }

  void _toggleReplaceView() {
    setState(() {
      _isReplaceVisible = !_isReplaceVisible;
    });
  }

  void _runSearch() {
    if (!_isSearchActive) return;

    final isSearchFocused = _searchFocusNode.hasFocus;

    final query = _searchController.text;
    _clearHighlights();

    if (query.isEmpty) {
      setState(() {
        _searchMatches.clear();
        _currentSearchMatchIndex = -1;
      });
      return;
    }

    final documentText = widget.controller.document.toPlainText();
    final textToSearch =
        _isSearchCaseSensitive ? documentText : documentText.toLowerCase();
    final queryToSearch = _isSearchCaseSensitive ? query : query.toLowerCase();
    final newMatches = <TextRange>[];

    int startIndex = 0;
    while ((startIndex = textToSearch.indexOf(queryToSearch, startIndex)) !=
        -1) {
      newMatches.add(
        TextRange(start: startIndex, end: startIndex + query.length),
      );
      startIndex += query.length;
    }

    setState(() {
      _searchMatches.clear();
      _searchMatches.addAll(newMatches);
      _currentSearchMatchIndex = _searchMatches.isNotEmpty ? 0 : -1;
    });

    _applyHighlightsOnly();

    if (isSearchFocused) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && !_searchFocusNode.hasFocus) {
          _searchFocusNode.requestFocus();
        }
      });
    }
  }

  void _applyHighlightsOnly() {
    for (var i = 0; i < _searchMatches.length; i++) {
      final range = _searchMatches[i];
      final attribute =
          i == _currentSearchMatchIndex
              ? _searchActiveHighlightAttribute
              : _searchHighlightAttribute;
      widget.controller.formatText(
        range.start,
        range.end - range.start,
        attribute,
      );
    }
  }

  void _clearHighlights() {
    final matchesToClear = List<TextRange>.from(_searchMatches);
    for (final range in matchesToClear) {
      widget.controller.formatText(
        range.start,
        range.end - range.start,
        BackgroundAttribute(null),
      );
    }
  }

  void _navigateToMatch(int direction) {
    if (_searchMatches.isEmpty) return;

    final oldActiveRange = _searchMatches[_currentSearchMatchIndex];
    widget.controller.formatText(
      oldActiveRange.start,
      oldActiveRange.end - oldActiveRange.start,
      _searchHighlightAttribute,
    );

    final newIndex =
        (_currentSearchMatchIndex + direction + _searchMatches.length) %
        _searchMatches.length;

    final newActiveRange = _searchMatches[newIndex];
    widget.controller.formatText(
      newActiveRange.start,
      newActiveRange.end - newActiveRange.start,
      _searchActiveHighlightAttribute,
    );

    widget.controller.updateSelection(
      TextSelection(
        baseOffset: newActiveRange.start,
        extentOffset: newActiveRange.end,
      ),
      ChangeSource.local,
    );

    setState(() {
      _currentSearchMatchIndex = newIndex;
    });
  }

  void _replaceCurrentMatch() {
    if (_currentSearchMatchIndex < 0 ||
        _currentSearchMatchIndex >= _searchMatches.length) {
      return;
    }

    final match = _searchMatches[_currentSearchMatchIndex];
    final replacement = _replaceController.text;
    final length = match.end - match.start;

    widget.controller.replaceText(
      match.start,
      length,
      replacement,
      TextSelection.collapsed(offset: match.start + replacement.length),
    );

    _runSearch();
  }

  void _replaceAllMatches() {
    if (_searchMatches.isEmpty) return;

    final replacement = _replaceController.text;
    final matches = List<TextRange>.from(_searchMatches);

    for (var i = matches.length - 1; i >= 0; i--) {
      final match = matches[i];
      final length = match.end - match.start;
      widget.controller.replaceText(match.start, length, replacement, null);
    }

    _runSearch();
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasMatches = _searchMatches.isNotEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return SizeTransition(
          sizeFactor: CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          ),
          axisAlignment: -1.0,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child:
          !_isSearchActive
              ? const SizedBox.shrink()
              : Container(
                padding: const EdgeInsets.all(8.0),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surface,
                  border: Border(
                    top: BorderSide(color: theme.dividerColor, width: 0.8),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            decoration: InputDecoration(
                              hintText: l10n.toolbarSearchHint,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(30.0),
                                borderSide: BorderSide.none,
                              ),
                              isDense: true,
                              filled: true,
                              fillColor:
                                  theme.colorScheme.surfaceContainerHighest,
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 10,
                                horizontal: 16,
                              ),
                            ),
                            style: theme.textTheme.bodyMedium,
                          ),
                        ),
                        const SizedBox(width: 8),
                        if (_searchController.text.isNotEmpty)
                          Text(
                            hasMatches
                                ? l10n.toolbarSearchMatchOf(
                                  (_currentSearchMatchIndex + 1).toString(),
                                  _searchMatches.length.toString(),
                                )
                                : l10n.toolbarNoResults,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color:
                                  hasMatches
                                      ? theme.colorScheme.onSurfaceVariant
                                      : theme.colorScheme.error,
                            ),
                          ),
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          tooltip: l10n.toolbarPreviousMatch,
                          onPressed:
                              hasMatches ? () => _navigateToMatch(-1) : null,
                          iconSize: 22,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          tooltip: l10n.toolbarNextMatch,
                          onPressed:
                              hasMatches ? () => _navigateToMatch(1) : null,
                          iconSize: 22,
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        IconButton(
                          icon: Icon(
                            Icons.find_replace_outlined,
                            color:
                                _isReplaceVisible
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant,
                          ),
                          tooltip: l10n.toolbarShowReplaceTooltip,
                          onPressed: _toggleReplaceView,
                          iconSize: 24,
                        ),
                        Text(
                          l10n.toolbarCaseSensitive,
                          style: theme.textTheme.labelMedium,
                        ),
                        const SizedBox(width: 4),
                        Switch(
                          value: _isSearchCaseSensitive,
                          onChanged: (value) {
                            setState(() => _isSearchCaseSensitive = value);
                            _runSearch();
                          },
                          materialTapTargetSize:
                              MaterialTapTargetSize.shrinkWrap,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(Icons.close),
                          tooltip: l10n.toolbarCloseSearchTooltip,
                          onPressed: _toggleSearchView,
                          iconSize: 24,
                        ),
                      ],
                    ),

                    AnimatedSize(
                      duration: const Duration(milliseconds: 250),
                      curve: Curves.easeInOut,
                      child: Visibility(
                        visible: _isReplaceVisible,
                        child: Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextField(
                                  controller: _replaceController,
                                  decoration: InputDecoration(
                                    hintText: l10n.toolbarReplaceWithHint,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(30.0),
                                      borderSide: BorderSide.none,
                                    ),
                                    isDense: true,
                                    filled: true,
                                    fillColor:
                                        theme
                                            .colorScheme
                                            .surfaceContainerHighest,
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 16,
                                    ),
                                  ),
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              const SizedBox(width: 8),
                              TextButton(
                                onPressed:
                                    hasMatches ? _replaceCurrentMatch : null,
                                child: Text(l10n.toolbarReplaceButton),
                              ),
                              TextButton(
                                onPressed:
                                    hasMatches ? _replaceAllMatches : null,
                                child: Text(l10n.toolbarReplaceAllButton),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
    );
  }

  Widget _buildExpandableSectionContainer(
    BuildContext context,
    List<Widget> children,
  ) {
    const double outerHorizontalMargin = 8.0;
    const double innerHorizontalPaddingForContent = 12.0;
    const double innerVerticalPaddingForContent = 8.0;
    const double spaceBetweenButtons = 2.0;

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: outerHorizontalMargin,
        vertical: 4.0,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).secondaryHeaderColor.withAlpha(60),
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double viewportWidthForPaddedContent =
              constraints.maxWidth - (innerHorizontalPaddingForContent * 2);

          return SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(
              horizontal: innerHorizontalPaddingForContent,
              vertical: innerVerticalPaddingForContent,
            ),
            physics: const AlwaysScrollableScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minWidth:
                    viewportWidthForPaddedContent > 0
                        ? viewportWidthForPaddedContent
                        : 0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children:
                    children
                        .map(
                          (e) => Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: spaceBetweenButtons,
                            ),
                            child: e,
                          ),
                        )
                        .toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildCommonOptionsToolbar(BuildContext context) {
    return _buildExpandableSectionContainer(context, [
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.bold,
        options: QuillToolbarToggleStyleButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.italic,
        options: QuillToolbarToggleStyleButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.underline,
        options: QuillToolbarToggleStyleButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.strikeThrough,
        options: QuillToolbarToggleStyleButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarClearFormatButton(
        controller: widget.controller,
        options: QuillToolbarClearFormatButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
    ]);
  }

  Widget _buildTextOptionsToolbar(BuildContext context) {
    return _buildExpandableSectionContainer(context, [
      CustomQuillToolbarFontFamilyButton(
        controller: widget.controller,
        options: QuillToolbarFontFamilyButtonOptions(
          attribute: Attribute.font,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      CustomQuillToolbarFontSizeButton(
        controller: widget.controller,
        options: QuillToolbarFontSizeButtonOptions(
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      QuillToolbarColorButton(
        controller: widget.controller,
        isBackground: false,
        options: QuillToolbarColorButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarColorButton(
        controller: widget.controller,
        isBackground: true,
        options: QuillToolbarColorButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
    ]);
  }

  Widget _buildHeaderStyleToolbar(BuildContext context) {
    return _buildExpandableSectionContainer(context, [
      CustomQuillToolbarHeaderStyleButton(
        controller: widget.controller,
        options: QuillToolbarSelectHeaderStyleDropdownButtonOptions(
          textStyle: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.blockQuote,
        options: QuillToolbarToggleStyleButtonOptions(
          iconData: Icons.format_quote,
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.codeBlock,
        options: QuillToolbarToggleStyleButtonOptions(
          iconData: Icons.code,
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
    ]);
  }

  Widget _buildListStyleToolbar(BuildContext context) {
    return _buildExpandableSectionContainer(context, [
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.ul,
        options: QuillToolbarToggleStyleButtonOptions(
          iconData: Icons.format_list_bulleted,
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.ol,
        options: QuillToolbarToggleStyleButtonOptions(
          iconData: Icons.format_list_numbered,
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarToggleCheckListButton(
        controller: widget.controller,
        options: QuillToolbarToggleCheckListButtonOptions(
          iconData: Icons.check_box,
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarIndentButton(
        controller: widget.controller,
        isIncrease: false,
        options: QuillToolbarIndentButtonOptions(
          iconData: Icons.format_indent_decrease,
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarIndentButton(
        controller: widget.controller,
        isIncrease: true,
        options: QuillToolbarIndentButtonOptions(
          iconData: Icons.format_indent_increase,
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
    ]);
  }

  Widget _buildAlignmentToolbar(BuildContext context) {
    return _buildExpandableSectionContainer(context, [
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.leftAlignment,
        options: QuillToolbarToggleStyleButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.centerAlignment,
        options: QuillToolbarToggleStyleButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.rightAlignment,
        options: QuillToolbarToggleStyleButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
      QuillToolbarToggleStyleButton(
        controller: widget.controller,
        attribute: Attribute.justifyAlignment,
        options: QuillToolbarToggleStyleButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
        ),
      ),
    ]);
  }

  Widget _buildMainToolbarToggleButton(
    BuildContext context,
    ToolbarSection section,
    IconData icon,
    IconData activeIcon,
  ) {
    bool isActive = _activeToolbarSection == section;
    return IconButton(
      icon: Icon(
        isActive ? activeIcon : icon,
        size: QuillToolbarWidget.defaultMainToolbarIconSize,
      ),
      iconSize: QuillToolbarWidget.defaultMainToolbarIconSize,
      color: isActive ? Theme.of(context).colorScheme.primary : null,
      onPressed: () => _toggleActiveToolbarSection(section),
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget currentExpandedToolbar;
    switch (_activeToolbarSection) {
      case ToolbarSection.commonOptions:
        currentExpandedToolbar = _buildCommonOptionsToolbar(context);
        break;
      case ToolbarSection.textOptions:
        currentExpandedToolbar = _buildTextOptionsToolbar(context);
        break;
      case ToolbarSection.headerStyle:
        currentExpandedToolbar = _buildHeaderStyleToolbar(context);
        break;
      case ToolbarSection.listStyle:
        currentExpandedToolbar = _buildListStyleToolbar(context);
        break;
      case ToolbarSection.alignment:
        currentExpandedToolbar = _buildAlignmentToolbar(context);
        break;
      case ToolbarSection.none:
        currentExpandedToolbar = const SizedBox.shrink();
    }

    const IconData collapseIcon = Icons.expand_less;

    Widget mainCompactToolbar = SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.fromLTRB(8.0, 0, 8.0, 10.0),
      child: Row(
        children:
            <Widget>[
                  QuillToolbarHistoryButton(
                    controller: widget.controller,
                    isUndo: true,
                    options: QuillToolbarHistoryButtonOptions(
                      iconSize: QuillToolbarWidget.defaultToolbarIconSize,
                    ),
                  ),
                  QuillToolbarHistoryButton(
                    controller: widget.controller,
                    isUndo: false,
                    options: QuillToolbarHistoryButtonOptions(
                      iconSize: QuillToolbarWidget.defaultToolbarIconSize,
                    ),
                  ),
                  const VerticalDivider(width: 5),
                  _buildMainToolbarToggleButton(
                    context,
                    ToolbarSection.commonOptions,
                    Icons.style,
                    collapseIcon,
                  ),
                  _buildMainToolbarToggleButton(
                    context,
                    ToolbarSection.textOptions,
                    Icons.text_format,
                    collapseIcon,
                  ),
                  _buildMainToolbarToggleButton(
                    context,
                    ToolbarSection.headerStyle,
                    Icons.title,
                    collapseIcon,
                  ),
                  _buildMainToolbarToggleButton(
                    context,
                    ToolbarSection.listStyle,
                    Icons.format_list_bulleted,
                    collapseIcon,
                  ),
                  _buildMainToolbarToggleButton(
                    context,
                    ToolbarSection.alignment,
                    Icons.format_align_left,
                    collapseIcon,
                  ),
                  const VerticalDivider(width: 5),
                  IconButton(
                    icon: const Icon(Icons.search),
                    iconSize: QuillToolbarWidget.defaultMainToolbarIconSize,
                    onPressed: _toggleSearchView,
                  ),
                  QuillToolbarLinkStyleButton(
                    controller: widget.controller,
                    options: QuillToolbarLinkStyleButtonOptions(
                      iconSize: QuillToolbarWidget.defaultToolbarIconSize,
                    ),
                  ),
                ]
                .map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 1.0),
                    child: e,
                  ),
                )
                .toList(),
      ),
    );

    return Material(
      elevation: 4.0,
      color:
          Theme.of(context).bottomAppBarTheme.color ??
          Theme.of(context).colorScheme.surface,
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildSearchBar(context),
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
  }
}

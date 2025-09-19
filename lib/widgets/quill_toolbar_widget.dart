import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_quill/quill_delta.dart';

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

const int _kHighlightMatchLimit = 3000;

Map<String, dynamic> _findMatchesAndBuildDeltaOps(Map<String, dynamic> params) {
  final String text = params['text'];
  final String query = params['query'];
  final int queryOriginalLength = params['query_original_length'];
  final String activeColor = params['active_color'];
  final String inactiveColor = params['inactive_color'];

  final List<TextRange> matches = [];
  if (query.isEmpty || queryOriginalLength <= 0) {
    return {'matches': [], 'delta_ops': [], 'match_count': 0};
  }

  int matchCount = 0;
  int startIndex = 0;
  while ((startIndex = text.indexOf(query, startIndex)) != -1) {
    matchCount++;
    if (matchCount > _kHighlightMatchLimit) {
      return {'matches': [], 'delta_ops': [], 'match_count': matchCount};
    }
    final endIndex = startIndex + queryOriginalLength;
    matches.add(TextRange(start: startIndex, end: endIndex));
    startIndex = endIndex;
  }

  final List<Map<String, dynamic>> deltaOps = [];
  int currentIndex = 0;
  for (int i = 0; i < matches.length; i++) {
    final range = matches[i];
    final color = i == 0 ? activeColor : inactiveColor;

    if (range.start > currentIndex) {
      deltaOps.add({'retain': range.start - currentIndex});
    }
    deltaOps.add({
      'retain': range.end - range.start,
      'attributes': {'background': color},
    });
    currentIndex = range.end;
  }

  final List<Map<String, int>> serializedMatches =
      matches.map((m) => {'start': m.start, 'end': m.end}).toList();

  return {
    'matches': serializedMatches,
    'delta_ops': deltaOps,
    'match_count': matchCount,
  };
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
  bool _highlightsSkipped = false;
  bool _isReplaceVisible = false;
  bool _isSearchActive = false;
  bool _isSearchCaseSensitive = false;
  final _replaceController = TextEditingController();
  final _searchController = TextEditingController();
  Timer? _searchDebounce;
  final _searchFocusNode = FocusNode();
  final _searchMatches = <TextRange>[];
  int _totalMatchCount = 0;

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.removeListener(_onSearchTextChanged);
    _searchController.dispose();
    _replaceController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchTextChanged);
  }

  void _onSearchTextChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce!.cancel();
    _searchDebounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) {
        _performSearch();
      }
    });
  }

  void _toggleActiveToolbarSection(ToolbarSection section) {
    setState(() {
      _activeToolbarSection =
          (_activeToolbarSection == section) ? ToolbarSection.none : section;
    });
  }

  void _toggleSearchView() {
    setState(() {
      _isSearchActive = !_isSearchActive;
      if (_isSearchActive) {
        _searchFocusNode.requestFocus();
      } else {
        _clearHighlights();
        widget.editorFocusNode?.requestFocus();
        _searchController.clear();
        _searchMatches.clear();
        _currentSearchMatchIndex = -1;
        _totalMatchCount = 0;
        _isReplaceVisible = false;
        _replaceController.clear();
        _highlightsSkipped = false;
      }
    });
  }

  void _toggleReplaceView() {
    setState(() {
      _isReplaceVisible = !_isReplaceVisible;
    });
  }

  Future<void> _performSearch() async {
    if (!_isSearchActive) return;

    final query = _searchController.text;
    _clearHighlights();

    if (query.isEmpty) {
      setState(() {
        _searchMatches.clear();
        _currentSearchMatchIndex = -1;
        _totalMatchCount = 0;
        _highlightsSkipped = false;
      });
      return;
    }

    final documentText = widget.controller.document.toPlainText();
    final textToSearch =
        _isSearchCaseSensitive ? documentText : documentText.toLowerCase();
    final queryToSearch = _isSearchCaseSensitive ? query : query.toLowerCase();

    final result = await compute(_findMatchesAndBuildDeltaOps, {
      'text': textToSearch,
      'query': queryToSearch,
      'query_original_length': query.length,
      'active_color': _searchActiveHighlightAttribute.value,
      'inactive_color': _searchHighlightAttribute.value,
    });

    if (!mounted) return;

    final int matchCount = result['match_count'];
    final bool limitExceeded = matchCount > _kHighlightMatchLimit;

    if (limitExceeded) {
      setState(() {
        _totalMatchCount = matchCount;
        _searchMatches.clear();
        _currentSearchMatchIndex = -1;
        _highlightsSkipped = true;
      });
      return;
    }

    final List<dynamic> serializedMatches = result['matches'];
    final List<TextRange> newMatches =
        serializedMatches
            .map((m) => TextRange(start: m['start'], end: m['end']))
            .toList();
    final List<Map<String, dynamic>> deltaOps = List<Map<String, dynamic>>.from(
      result['delta_ops'],
    );

    setState(() {
      _searchMatches.clear();
      _searchMatches.addAll(newMatches);
      _totalMatchCount = matchCount;
      _currentSearchMatchIndex = newMatches.isNotEmpty ? 0 : -1;
      _highlightsSkipped = false;
    });

    if (deltaOps.isNotEmpty) {
      widget.controller.compose(
        Delta.fromJson(deltaOps),
        widget.controller.selection,
        ChangeSource.local,
      );
    }
  }

  void _clearHighlights() {
    if (_searchMatches.isEmpty) return;
    final delta = Delta();
    int currentIndex = 0;
    for (final match in _searchMatches) {
      delta.retain(match.start - currentIndex);
      delta.retain(match.end - match.start, {'background': null});
      currentIndex = match.end;
    }
    if (delta.isNotEmpty) {
      widget.controller.compose(
        delta,
        widget.controller.selection,
        ChangeSource.local,
      );
    }
  }

  void _navigateToMatch(int direction) {
    if (_searchMatches.isEmpty) return;

    final oldIndex = _currentSearchMatchIndex;
    final newIndex =
        (oldIndex + direction + _searchMatches.length) % _searchMatches.length;

    if (oldIndex == newIndex) return;

    final oldActiveRange = _searchMatches[oldIndex];
    final newActiveRange = _searchMatches[newIndex];

    final rangesToUpdate = [
      (range: oldActiveRange, attr: _searchHighlightAttribute),
      (range: newActiveRange, attr: _searchActiveHighlightAttribute),
    ]..sort((a, b) => a.range.start.compareTo(b.range.start));

    final delta = Delta();
    int currentIndex = 0;
    for (final item in rangesToUpdate) {
      delta.retain(item.range.start - currentIndex);
      delta.retain(item.range.end - item.range.start, item.attr.toJson());
      currentIndex = item.range.end;
    }

    widget.controller.compose(
      delta,
      widget.controller.selection,
      ChangeSource.local,
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
    if (_currentSearchMatchIndex < 0) return;
    final match = _searchMatches[_currentSearchMatchIndex];
    final replacement = _replaceController.text;
    widget.controller.replaceText(
      match.start,
      match.end - match.start,
      replacement,
      TextSelection.collapsed(offset: match.start + replacement.length),
    );
    _performSearch();
  }

  void _replaceAllMatches() {
    if (_searchMatches.isEmpty) return;
    final replacement = _replaceController.text;
    final matches = List<TextRange>.from(_searchMatches);
    for (var i = matches.length - 1; i >= 0; i--) {
      final match = matches[i];
      widget.controller.replaceText(
        match.start,
        match.end - match.start,
        replacement,
        null,
      );
    }
    _performSearch();
  }

  Widget _buildSearchBar(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);
    final hasMatchesToNavigate = _searchMatches.isNotEmpty;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder:
          (child, animation) => SizeTransition(
            sizeFactor: CurvedAnimation(
              parent: animation,
              curve: Curves.easeInOut,
            ),
            axisAlignment: -1.0,
            child: FadeTransition(opacity: animation, child: child),
          ),
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
                          _highlightsSkipped
                              ? Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.warning_amber_rounded,
                                    color: Colors.amber,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '$_kHighlightMatchLimit+ matches',
                                    style: theme.textTheme.bodySmall?.copyWith(
                                      color: theme.colorScheme.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              )
                              : Text(
                                (_totalMatchCount > 0)
                                    ? l10n.toolbarSearchMatchOf(
                                      (_currentSearchMatchIndex + 1).toString(),
                                      _totalMatchCount.toString(),
                                    )
                                    : l10n.toolbarNoResults,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color:
                                      (_totalMatchCount > 0)
                                          ? theme.colorScheme.onSurfaceVariant
                                          : theme.colorScheme.error,
                                ),
                                textAlign: TextAlign.end,
                              ),
                        IconButton(
                          icon: const Icon(Icons.arrow_upward),
                          tooltip: l10n.toolbarPreviousMatch,
                          onPressed:
                              hasMatchesToNavigate
                                  ? () => _navigateToMatch(-1)
                                  : null,
                          iconSize: 22,
                        ),
                        IconButton(
                          icon: const Icon(Icons.arrow_downward),
                          tooltip: l10n.toolbarNextMatch,
                          onPressed:
                              hasMatchesToNavigate
                                  ? () => _navigateToMatch(1)
                                  : null,
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
                            _performSearch();
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
                                    hasMatchesToNavigate
                                        ? _replaceCurrentMatch
                                        : null,
                                child: Text(l10n.toolbarReplaceButton),
                              ),
                              TextButton(
                                onPressed:
                                    hasMatchesToNavigate
                                        ? _replaceAllMatches
                                        : null,
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

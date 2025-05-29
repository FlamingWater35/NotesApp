import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';

enum ToolbarSection {
  none,
  commonOptions,
  textOptions,
  headerStyle,
  listStyle,
  alignment,
  indentation,
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
  ToolbarSection _activeToolbarSection = ToolbarSection.none;

  void _toggleActiveToolbarSection(ToolbarSection section) {
    setState(() {
      if (_activeToolbarSection == section) {
        _activeToolbarSection = ToolbarSection.none;
      } else {
        _activeToolbarSection = section;
      }
    });
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
      QuillToolbarFontFamilyButton(
        controller: widget.controller,
        options: QuillToolbarFontFamilyButtonOptions(
          attribute: Attribute.font,
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ),
      QuillToolbarFontSizeButton(
        controller: widget.controller,
        options: QuillToolbarFontSizeButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
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
      QuillToolbarSelectHeaderStyleDropdownButton(
        controller: widget.controller,
        options: QuillToolbarSelectHeaderStyleDropdownButtonOptions(
          iconSize: QuillToolbarWidget.defaultToolbarIconSize,
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

  Widget _buildIndentationToolbar(BuildContext context) {
    return _buildExpandableSectionContainer(context, [
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
      case ToolbarSection.indentation:
        currentExpandedToolbar = _buildIndentationToolbar(context);
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
                  const VerticalDivider(indent: 6, endIndent: 6),
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
                  _buildMainToolbarToggleButton(
                    context,
                    ToolbarSection.indentation,
                    Icons.format_indent_increase,
                    collapseIcon,
                  ),
                  const VerticalDivider(indent: 6, endIndent: 6),
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

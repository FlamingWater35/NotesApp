import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../../models/note_model.dart';
import '../l10n/app_localizations.dart';
import '../utils/note_utils.dart';
import '../widgets/notes_list.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key, required this.notes, required this.onNoteTap});

  final List<Note> notes;
  final void Function(Note note) onNoteTap;

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum SortProperty { date, title, lastModified, createdAt }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final Duration _animationDuration = const Duration(milliseconds: 300);
  List<Note> _displayedNotes = [];
  Timer? _emptyListTimer;
  final _log = Logger('HomeScreenState');
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _shouldShowEmptyMessage = false;
  bool _sortAscending = false;
  SortProperty _sortBy = SortProperty.lastModified;
  final Duration _timerBuffer = const Duration(milliseconds: 50);

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.notes, oldWidget.notes)) {
      _log.fine(
        "External notes list updated via didUpdateWidget, running filter and list update.",
      );
      _onSearchOrSortChanged();
    } else {
      _log.finer(
        "didUpdateWidget called, but notes list identity is the same.",
      );
    }
  }

  @override
  void dispose() {
    _log.fine("dispose called");
    _emptyListTimer?.cancel();
    _searchController.removeListener(_onSearchOrSortChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _updateDisplayedNotesAndEmptyMessage(widget.notes);
    _searchController.addListener(_onSearchOrSortChanged);
  }

  Row noteSortWidget(
    AppLocalizations l10n,
    ThemeData theme,
    BuildContext context,
  ) {
    return Row(
      children: [
        Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0)),
        Text(l10n.sortByLabel, style: theme.textTheme.bodyMedium),
        Padding(padding: const EdgeInsets.symmetric(horizontal: 3.0)),
        PopupMenuButton<SortProperty>(
          initialValue: _sortBy,
          onSelected: (SortProperty newSortBy) {
            if (_sortBy != newSortBy) {
              _log.fine("Sort property changed to: $newSortBy");
              setState(() {
                _sortBy = newSortBy;
              });
              _onSearchOrSortChanged();
            }
          },
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          position: PopupMenuPosition.under,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(4.0),
                child: Text(
                  getSortPropertyText(context, _sortBy),
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Icon(
                Icons.arrow_drop_down,
                size: 20.0,
                color: theme.colorScheme.primary,
              ),
            ],
          ),
          itemBuilder:
              (BuildContext context) => <PopupMenuEntry<SortProperty>>[
                PopupMenuItem<SortProperty>(
                  value: SortProperty.lastModified,
                  child: Text(l10n.sortPropertyLastModified),
                ),
                PopupMenuItem<SortProperty>(
                  value: SortProperty.createdAt,
                  child: Text(l10n.sortPropertyCreatedAt),
                ),
                PopupMenuItem<SortProperty>(
                  value: SortProperty.date,
                  child: Text(l10n.sortPropertyDate),
                ),
                PopupMenuItem<SortProperty>(
                  value: SortProperty.title,
                  child: Text(l10n.sortPropertyTitle),
                ),
              ],
        ),
        const Spacer(),
        IconButton(
          icon: Icon(
            _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
            size: 20.0,
            color: theme.colorScheme.primary,
          ),
          tooltip:
              _sortAscending
                  ? l10n.sortAscendingTooltip
                  : l10n.sortDescendingTooltip,
          visualDensity: VisualDensity.compact,
          padding: EdgeInsets.zero,
          onPressed: () {
            _log.fine("Sort direction toggled.");
            setState(() {
              _sortAscending = !_sortAscending;
            });
            _onSearchOrSortChanged();
          },
        ),
      ],
    );
  }

  void _updateDisplayedNotesAndEmptyMessage(List<Note> sourceNotes) {
    final newList = getFilteredAndSortedNotes(
      sourceNotes,
      _searchController,
      _sortBy,
      _sortAscending,
    );
    if (mounted) {
      setState(() {
        _displayedNotes = newList;
      });
      _handleEmptyMessage(newList, sourceNotes);
    }
  }

  void _onSearchOrSortChanged() {
    _updateDisplayedNotesAndEmptyMessage(widget.notes);
  }

  void _handleEmptyMessage(List<Note> filteredList, List<Note> sourceNotes) {
    _emptyListTimer?.cancel();
    final bool isEmptyResult = filteredList.isEmpty;
    final bool showBecauseSearchFailed =
        isEmptyResult && _searchController.text.isNotEmpty;
    final bool showBecauseInitiallyEmpty =
        isEmptyResult && _searchController.text.isEmpty && sourceNotes.isEmpty;
    final bool shouldShowNow =
        showBecauseSearchFailed ||
        (isEmptyResult && !showBecauseInitiallyEmpty && sourceNotes.isNotEmpty);

    if (shouldShowNow) {
      _emptyListTimer = Timer(_animationDuration + _timerBuffer, () {
        if (mounted) {
          setState(() {
            final currentFilteredList = getFilteredAndSortedNotes(
              widget.notes,
              _searchController,
              _sortBy,
              _sortAscending,
            );
            final currentSourceNotes = widget.notes;
            final currentIsEmptyResult = currentFilteredList.isEmpty;
            final currentShowBecauseSearchFailed =
                currentIsEmptyResult && _searchController.text.isNotEmpty;
            final currentShowBecauseInitiallyEmpty =
                currentIsEmptyResult &&
                _searchController.text.isEmpty &&
                currentSourceNotes.isEmpty;
            _shouldShowEmptyMessage =
                currentShowBecauseSearchFailed ||
                (currentIsEmptyResult &&
                    !currentShowBecauseInitiallyEmpty &&
                    currentSourceNotes.isNotEmpty);
          });
          _log.finer(
            "Empty message timer fired. shouldShowEmptyMessage: $_shouldShowEmptyMessage",
          );
        }
      });
    } else {
      if (mounted && _shouldShowEmptyMessage) {
        setState(() {
          _shouldShowEmptyMessage = false;
        });
        _log.finer("List not empty or initially empty, hiding empty message.");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.finer(
      "Building HomeScreen widget. Displayed notes count: ${_displayedNotes.length}",
    );
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);

    final bool showInitialEmptyMessage =
        widget.notes.isEmpty && _searchController.text.isEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(4.0, 12.0, 4.0, 4.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: l10n.searchNotesHint,
                  prefixIcon: const Icon(Icons.search, size: 22),
                  suffixIcon:
                      _searchController.text.isNotEmpty
                          ? IconButton(
                            icon: const Icon(Icons.clear, size: 20),
                            tooltip: l10n.clearSearchTooltip,
                            onPressed: () {
                              _log.fine("Clear search button pressed.");
                              if (_searchController.text.isNotEmpty) {
                                _searchController.clear();
                              }
                            },
                          )
                          : null,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: theme.colorScheme.surfaceContainerHighest
                      .withAlpha(140),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 20,
                  ),
                ),
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
        forceMaterialTransparency: true,
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16.0,
                  vertical: 4.0,
                ),
                child: noteSortWidget(l10n, theme, context),
              ),

              Expanded(
                child:
                    showInitialEmptyMessage
                        ? Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 40.0,
                            ),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  l10n.emptyNotesMessage,
                                  textStyle: Theme.of(
                                    context,
                                  ).textTheme.titleMedium?.copyWith(
                                    color:
                                        Theme.of(
                                          context,
                                        ).colorScheme.onSurfaceVariant,
                                  ),
                                  textAlign: TextAlign.center,
                                  speed: const Duration(milliseconds: 8),
                                ),
                              ],
                              isRepeatingAnimation: false,
                              displayFullTextOnTap: true,
                            ),
                          ),
                        )
                        : Stack(
                          children: [
                            animatedNoteList(
                              _displayedNotes,
                              _animationDuration,
                              widget,
                              ref,
                              _log,
                            ),
                            if (_shouldShowEmptyMessage)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40.0,
                                  ),
                                  child: AnimatedTextKit(
                                    animatedTexts: [
                                      TypewriterAnimatedText(
                                        l10n.noNotesFoundMessage,
                                        textStyle: Theme.of(
                                          context,
                                        ).textTheme.titleMedium?.copyWith(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.onSurfaceVariant,
                                        ),
                                        textAlign: TextAlign.center,
                                        speed: const Duration(milliseconds: 8),
                                      ),
                                    ],
                                    isRepeatingAnimation: false,
                                    displayFullTextOnTap: true,
                                  ),
                                ),
                              ),
                          ],
                        ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

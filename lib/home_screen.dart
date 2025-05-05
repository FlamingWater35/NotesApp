import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:animated_list_plus/animated_list_plus.dart';

import '../models/note_model.dart';
import '../providers/providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final List<Note> notes;
  final void Function(Note note) onNoteTap;

  const HomeScreen({
    super.key,
    required this.notes,
    required this.onNoteTap,
  });

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

enum SortProperty { date, title, lastModified, createdAt }

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final _log = Logger('HomeScreenState');
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  final Duration _animationDuration = const Duration(milliseconds: 300);

  List<Note> _displayedNotes = [];
  SortProperty _sortBy = SortProperty.lastModified;
  bool _sortAscending = false;

  bool _shouldShowEmptyMessage = false;
  Timer? _emptyListTimer;
  final Duration _timerBuffer = const Duration(milliseconds: 50);

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _updateDisplayedNotesAndEmptyMessage(widget.notes);
    _searchController.addListener(_onSearchOrSortChanged);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.notes, oldWidget.notes)) {
      _log.fine("External notes list updated via didUpdateWidget, running filter and list update.");
      _onSearchOrSortChanged();
    } else {
      _log.finer("didUpdateWidget called, but notes list identity is the same.");
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

  void _updateDisplayedNotesAndEmptyMessage(List<Note> sourceNotes) {
    final newList = _getFilteredAndSortedNotes(sourceNotes);
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
    final bool showBecauseSearchFailed = isEmptyResult && _searchController.text.isNotEmpty;
    final bool showBecauseInitiallyEmpty = isEmptyResult && _searchController.text.isEmpty && sourceNotes.isEmpty;
    final bool shouldShowNow = showBecauseSearchFailed || (isEmptyResult && !showBecauseInitiallyEmpty && sourceNotes.isNotEmpty);

    if (shouldShowNow) {
      _emptyListTimer = Timer(_animationDuration + _timerBuffer, () {
        if (mounted) {
          setState(() {
            final currentFilteredList = _getFilteredAndSortedNotes(widget.notes);
            final currentSourceNotes = widget.notes;
            final currentIsEmptyResult = currentFilteredList.isEmpty;
            final currentShowBecauseSearchFailed = currentIsEmptyResult && _searchController.text.isNotEmpty;
            final currentShowBecauseInitiallyEmpty = currentIsEmptyResult && _searchController.text.isEmpty && currentSourceNotes.isEmpty;
            _shouldShowEmptyMessage = currentShowBecauseSearchFailed || (currentIsEmptyResult && !currentShowBecauseInitiallyEmpty && currentSourceNotes.isNotEmpty);
          });
          _log.finer("Empty message timer fired. shouldShowEmptyMessage: $_shouldShowEmptyMessage");
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

  List<Note> _getFilteredAndSortedNotes(List<Note> currentNotes) {
    final query = _searchController.text.toLowerCase().trim();
    List<Note> filteredNotes;

    if (query.isEmpty) {
      filteredNotes = List.from(currentNotes);
    } else {
      filteredNotes = currentNotes.where((note) {
        final titleLower = note.title.toLowerCase();
        final contentLower = note.plainTextContent.toLowerCase();
        return titleLower.contains(query) || contentLower.contains(query);
      }).toList();
    }

    filteredNotes.sort((a, b) {
      int compareResult = 0;
      switch (_sortBy) {
        case SortProperty.date:
          compareResult = a.date.compareTo(b.date);
          break;
        case SortProperty.title:
          compareResult = a.title.toLowerCase().compareTo(b.title.toLowerCase());
          break;
        case SortProperty.lastModified:
          compareResult = a.lastModified.compareTo(b.lastModified);
          break;
        case SortProperty.createdAt:
          compareResult = a.createdAt.compareTo(b.createdAt);
          break;
      }
      return _sortAscending ? compareResult : -compareResult;
    });

    return filteredNotes;
  }

  Widget _buildAnimatedItem(BuildContext context, Note note, Animation<double> animation, {bool isRemoving = false}) {
    final String heroTag = note.heroTag;
    final String formattedDate = DateFormat.yMd().format(note.date);
    final theme = Theme.of(context);

    final slideTween = Tween<Offset>(
      begin: isRemoving ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
      end: Offset.zero,
    );
    final curvedAnimation = CurvedAnimation(parent: animation, curve: Curves.easeInOut);

    return SizeTransition(
      sizeFactor: curvedAnimation,
      child: FadeTransition(
        opacity: curvedAnimation,
        child: SlideTransition(
          position: animation.drive(slideTween.chain(CurveTween(curve: Curves.easeInOut))),
          child: _buildItemContent(context, note, theme, formattedDate, heroTag),
        ),
      ),
    );
  }

  Widget _buildItemContent(BuildContext context, Note note, ThemeData theme, String formattedDate, String heroTag){
    final String plainContent = note.plainTextContent;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Hero(
        tag: heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: Card(
            margin: EdgeInsets.zero,
            elevation: 0.5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            child: ListTile(
              title: Text(
                note.title.isEmpty ? 'Untitled Note' : note.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              subtitle: Text(
                '$formattedDate - $plainContent',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              trailing: IconButton(
                icon: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                tooltip: 'Delete Note',
                onPressed: () {
                  _log.fine("Delete button pressed for note ID: ${note.id}");
                  _showDeleteConfirmation(context, note);
                },
              ),
              onTap: () {
                FocusScope.of(context).unfocus();
                _log.info('Tapped on note ID: ${note.id}');
                widget.onNoteTap(note);
              },
              // visualDensity: VisualDensity.compact,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Note note) async {
    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return AlertDialog(
          title: const Text('Delete Note?'),
          content: Text('Are you sure you want to delete "${note.title.isEmpty ? 'Untitled Note' : note.title}"? This action cannot be undone.'),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () => Navigator.of(buildContext).pop(false),
            ),
            TextButton(
              style: TextButton.styleFrom(
                foregroundColor: Theme.of(buildContext).colorScheme.error,
              ),
              child: const Text('Delete'),
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

    if (confirmed == true) {
      _log.info("Deletion confirmed for note: ${note.title} (ID: ${note.id})");
      ref.read(notesProvider.notifier).deleteNote(note.id);

      if(context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Note "${note.title.isEmpty ? 'Untitled Note' : note.title}" deleted.'), duration: const Duration(seconds: 2)),
        );
      }
    } else {
      _log.info("Deletion cancelled for note: ${note.title}");
    }
  }

  String _getSortPropertyText(SortProperty property) {
    switch (property) {
      case SortProperty.date: return 'Date';
      case SortProperty.title: return 'Title';
      case SortProperty.lastModified: return 'Last Modified';
      case SortProperty.createdAt: return 'Created At';
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.finer("Building HomeScreen widget. Displayed notes count: ${_displayedNotes.length}");
    final theme = Theme.of(context);

    final bool showInitialEmptyMessage = widget.notes.isEmpty && _searchController.text.isEmpty;

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
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search, size: 22),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 20),
                        tooltip: 'Clear Search',
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
                  fillColor: theme.colorScheme.surfaceContainerHighest.withAlpha(140),
                  contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                ),
                style: theme.textTheme.bodyLarge,
              ),
            ),
          ],
        ),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 4.0),
                child: Row(
                  children: [
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 6.0)),
                    Text('Sort by: ', style: theme.textTheme.bodyMedium),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 3.0)),
                    PopupMenuButton<SortProperty>(
                      initialValue: _sortBy,
                      onSelected: (SortProperty newSortBy) {
                        if (_sortBy != newSortBy) {
                          _log.fine("Sort property changed to: $newSortBy");
                          setState(() { _sortBy = newSortBy; });
                          _onSearchOrSortChanged();
                        }
                      },
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      position: PopupMenuPosition.under,
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _getSortPropertyText(_sortBy),
                            style: theme.textTheme.titleSmall?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          Icon(
                            Icons.arrow_drop_down,
                            size: 20.0,
                            color: theme.colorScheme.primary,
                          ),
                        ],
                      ),
                      itemBuilder: (BuildContext context) => <PopupMenuEntry<SortProperty>>[
                        const PopupMenuItem<SortProperty>(value: SortProperty.lastModified, child: Text('Last Modified')),
                        const PopupMenuItem<SortProperty>(value: SortProperty.createdAt, child: Text('Created At')),
                        const PopupMenuItem<SortProperty>(value: SortProperty.date, child: Text('Date')),
                        const PopupMenuItem<SortProperty>(value: SortProperty.title, child: Text('Title')),
                      ],
                    ),
                    const Spacer(),
                    IconButton(
                      icon: Icon(
                        _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                        size: 20.0,
                        color: theme.colorScheme.primary,
                      ),
                      tooltip: _sortAscending ? 'Ascending (A-Z, Oldest first)' : 'Descending (Z-A, Newest first)',
                      visualDensity: VisualDensity.compact,
                      padding: EdgeInsets.zero,
                      onPressed: () {
                        _log.fine("Sort direction toggled.");
                        setState(() { _sortAscending = !_sortAscending; });
                        _onSearchOrSortChanged();
                      },
                    ),
                  ],
                ),
              ),

              Expanded(
                child: showInitialEmptyMessage
                  ? Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 40.0),
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'No notes yet.\nTap the + button to add one!',
                            textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant
                            ),
                            textAlign: TextAlign.center,
                            speed: const Duration(milliseconds: 8)
                          ),
                        ],
                        isRepeatingAnimation: false,
                        displayFullTextOnTap: true,
                      ),
                    ),
                  )
                  : Stack(
                    children: [
                      ImplicitlyAnimatedList<Note>(
                        items: _displayedNotes,
                        padding: const EdgeInsets.only(bottom: 80.0),
                        itemBuilder: (context, animation, note, index) {
                          return _buildAnimatedItem(context, note, animation);
                        },
                        removeItemBuilder: (context, animation, note) {
                          return _buildAnimatedItem(context, note, animation, isRemoving: true);
                        },
                        insertDuration: _animationDuration,
                        removeDuration: _animationDuration,
                        areItemsTheSame: (a, b) => a.id == b.id,
                      ),
                      if (_shouldShowEmptyMessage)
                        Center(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 40.0),
                            child: AnimatedTextKit(
                              animatedTexts: [
                                TypewriterAnimatedText(
                                  'No notes found matching your search.',
                                  textStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context).colorScheme.onSurfaceVariant
                                  ),
                                  textAlign: TextAlign.center,
                                  speed: const Duration(milliseconds: 8)
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
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/foundation.dart' show listEquals;
import 'package:animated_text_kit/animated_text_kit.dart';

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

  final GlobalKey<AnimatedListState> _listKey = GlobalKey<AnimatedListState>();
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
    _displayedNotes = _getFilteredAndSortedNotes(widget.notes);
    _shouldShowEmptyMessage = _displayedNotes.isEmpty &&
                              (_searchController.text.isNotEmpty || widget.notes.isNotEmpty) &&
                              !(widget.notes.isEmpty && _searchController.text.isEmpty);
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

  void _onSearchOrSortChanged() {
    _log.finer("Search or sort parameters potentially changed. Recomputing list.");
    setState(() {});
    _updateAnimatedList(widget.notes);
  }

  List<Note> _getFilteredAndSortedNotes(List<Note> currentNotes) {
    final query = _searchController.text.toLowerCase();
    List<Note> filteredNotes;
    if (query.isEmpty) {
      filteredNotes = List.from(currentNotes);
    } else {
      filteredNotes = currentNotes.where((note) {
        final titleLower = note.title.toLowerCase();
        final contentLower = note.content.toLowerCase();
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

  void _updateAnimatedList(List<Note> sourceNotes) {
    final List<Note> oldList = List.from(_displayedNotes);
    final List<Note> newList = _getFilteredAndSortedNotes(sourceNotes);

    _log.finer("Updating animated list. Old count: ${oldList.length}, New count: ${newList.length}");

    _emptyListTimer?.cancel();

    if (newList.isEmpty) {
      if (oldList.isNotEmpty) {
        _log.finest("Transitioning to empty list. Starting timer.");
        _shouldShowEmptyMessage = false;
        _emptyListTimer = Timer(_animationDuration + _timerBuffer, () {
          _log.finest("Empty list timer fired.");
          if (mounted && _displayedNotes.isEmpty) {
            _log.fine("List still empty after timer, showing empty message.");
            setState(() {
              _shouldShowEmptyMessage = true;
            });
          } else {
            _log.finer("List not empty or widget unmounted when timer fired. Not showing empty message.");
          }
        });
      } else {
        _log.finest("List remains empty. Setting message visibility directly.");
        _shouldShowEmptyMessage = (_searchController.text.isNotEmpty || widget.notes.isNotEmpty) &&
                                !(widget.notes.isEmpty && _searchController.text.isEmpty);
      }
    } else {
      _log.finest("List is not empty. Hiding empty message.");
      _shouldShowEmptyMessage = false;
    }

    final Map<String, Note> newNotesMap = { for (var note in newList) note.id : note };

    for (int i = oldList.length - 1; i >= 0; i--) {
      final note = oldList[i];
      if (!newNotesMap.containsKey(note.id)) {
        _log.finest("Removing item at index $i (ID: ${note.id})");
        final Note noteToRemove = oldList[i];
        _listKey.currentState?.removeItem(
          i,
          (context, animation) => _buildAnimatedItem(context, noteToRemove, animation, isRemoving: true),
          duration: _animationDuration,
        );
      }
    }

    for (int newIndex = 0; newIndex < newList.length; newIndex++) {
      final note = newList[newIndex];
      final oldIndex = oldList.indexWhere((n) => n.id == note.id);

      if (oldIndex == -1) {
        _log.finest("Inserting item at index $newIndex (ID: ${note.id})");
        _listKey.currentState?.insertItem(newIndex, duration: _animationDuration);
      } else if (oldIndex != newIndex) {
        _log.finest("Item ${note.id} moved from $oldIndex to $newIndex");
        final Note movedNote = oldList[oldIndex];
        
        _displayedNotes.removeAt(oldIndex);
        _listKey.currentState?.removeItem(
          oldIndex,
          (context, animation) => const SizedBox.shrink(),
          duration: Duration.zero,
        );

        final int adjustedNewIndex = (newIndex > oldIndex) ? newIndex - 1 : newIndex;

        _displayedNotes.insert(adjustedNewIndex, movedNote);
        _listKey.currentState?.insertItem(adjustedNewIndex, duration: _animationDuration);
      }
    }

    _displayedNotes = List.from(newList);

    if (_listKey.currentState == null && _displayedNotes.isNotEmpty) {
      _log.warning("List has items, but AnimatedList state is null. A rebuild should occur.");
    } else if (listEquals(oldList.map((e) => e.id).toList(), newList.map((e) => e.id).toList()) && !listEquals(oldList, newList)) {
      _log.finer("Lists contain same items but order changed. Rebuild triggered by setState.");
    } else if (oldList.isEmpty && newList.isEmpty) {
      _log.finer("List remains empty. Rebuild triggered by setState.");
    }
  }

  Widget _buildAnimatedItem(BuildContext context, Note note, Animation<double> animation, {bool isRemoving = false}) {
    final String heroTag = note.heroTag;
    final String formattedDate = DateFormat.yMd().format(note.date);
    final theme = Theme.of(context);

    final slideTween = Tween<Offset>(
      begin: const Offset(-1.0, 0.0),
      end: Offset.zero,
    );

    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
      child: FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeIn),
        child: SlideTransition(
          position: animation.drive(slideTween.chain(CurveTween(curve: Curves.easeInOut))),
          child: _buildItemContent(context, note, theme, formattedDate, heroTag),
        )
      ),
    );
  }

  Widget _buildItemContent(BuildContext context, Note note, ThemeData theme, String formattedDate, String heroTag){
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
      child: Hero(
        tag: heroTag,
        child: Material(
          type: MaterialType.transparency,
          child: Card(
            margin: EdgeInsets.zero,
            child: ListTile(
              title: Text(
                note.title.isEmpty ? 'Untitled Note' : note.title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              subtitle: Text(
                '$formattedDate - ${note.content}',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
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
          content: Text('Are you sure you want to delete "${note.title}"? This action cannot be undone.'),
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
          SnackBar(content: Text('Note "${note.title}" deleted.'), duration: const Duration(seconds: 2)),
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
              padding: const EdgeInsets.fromLTRB(0.0, 12.0, 0.0, 4.0),
              child: TextField(
                controller: _searchController,
                focusNode: _searchFocusNode,
                decoration: InputDecoration(
                  hintText: 'Search notes...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
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
                  fillColor: Theme.of(context).colorScheme.primaryContainer.withAlpha(128),
                  contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 20),
                ),
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
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  children: [
                    Text(
                      'Sort by: ',
                      style: theme.textTheme.bodyMedium,
                    ),
                    Padding(padding: const EdgeInsets.symmetric(horizontal: 3.0),),
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
                      child: AnimatedTextKit(
                        animatedTexts: [
                          TypewriterAnimatedText(
                            'No notes yet. Tap + to add one!',
                            textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: Theme.of(context).colorScheme.onSurfaceVariant
                            ),
                            textAlign: TextAlign.center,
                            speed: const Duration(milliseconds: 8)
                          ),
                        ],
                        isRepeatingAnimation: false,
                      ),
                    )
                  : Stack(
                      children: [
                        AnimatedList(
                          key: _listKey,
                          initialItemCount: _displayedNotes.length,
                          padding: EdgeInsets.zero,
                          itemBuilder: (context, index, animation) {
                            if (index >= _displayedNotes.length) {
                              return Container();
                            }
                            final note = _displayedNotes[index];
                            return _buildAnimatedItem(context, note, animation);
                          },
                        ),
                        if (_shouldShowEmptyMessage)
                          Center(
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: AnimatedTextKit(
                                animatedTexts: [
                                  TypewriterAnimatedText(
                                    'No notes found matching your search.',
                                    textStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                      color: Theme.of(context).colorScheme.onSurfaceVariant
                                    ),
                                    textAlign: TextAlign.center,
                                    speed: const Duration(milliseconds: 8)
                                  ),
                                ],
                                isRepeatingAnimation: false,
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
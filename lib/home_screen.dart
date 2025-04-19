import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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

  List<Note> _displayedNotes = [];
  SortProperty _sortBy = SortProperty.lastModified;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _updateDisplayedNotes(widget.notes);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.notes, oldWidget.notes)) {
      _log.fine("Notes list updated externally, running filter and forcing rebuild.");
      _updateDisplayedNotes(widget.notes);
    }
  }

  @override
  void dispose() {
    _log.fine("dispose called");
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _log.finer("Search text changed: ${_searchController.text}");
    _updateDisplayedNotes(widget.notes);
  }

  void _updateDisplayedNotes(List<Note> currentNotes) {
    final query = _searchController.text.toLowerCase();
    _log.finer("Updating displayed notes. Query: '$query', SortBy: $_sortBy, Asc: $_sortAscending");

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
    _log.finer("Filtering complete. ${filteredNotes.length} notes match query.");

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
    _log.finer("Sorting complete.");

    if (mounted) {
      setState(() {
        _displayedNotes = filteredNotes;
      });
    }
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Note note) async {
    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel, // Accessibility label
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
            parent: animation, // The animation controlled by showGeneralDialog
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
    _log.finer("Building HomeScreen widget");
    final theme = Theme.of(context);

    return SafeArea(
      child: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.fromLTRB(12.0, 12.0, 12.0, 4.0),
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
                        _searchController.clear();
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
                      _updateDisplayedNotes(widget.notes);
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
                    const PopupMenuItem<SortProperty>(
                      value: SortProperty.lastModified,
                      child: Text('Last Modified'),
                    ),
                     const PopupMenuItem<SortProperty>(
                      value: SortProperty.createdAt,
                      child: Text('Created At'),
                    ),
                     const PopupMenuItem<SortProperty>(
                      value: SortProperty.date,
                      child: Text('Date'),
                    ),
                    const PopupMenuItem<SortProperty>(
                      value: SortProperty.title,
                      child: Text('Title'),
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
                  tooltip: _sortAscending ? 'Ascending (A-Z, Oldest first)' : 'Descending (Z-A, Newest first)',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _log.fine("Sort direction toggled.");
                    setState(() { _sortAscending = !_sortAscending; });
                    _updateDisplayedNotes(widget.notes);
                  },
                ),
              ],
            ),
          ),

          Expanded(
            child: _displayedNotes.isEmpty
              ? Center(
                child: Text(
                  _searchController.text.isEmpty && widget.notes.isEmpty
                    ? 'No notes yet. Tap + to add one!'
                    : _searchController.text.isNotEmpty
                      ? 'No notes found matching your search.'
                      : 'No notes found.', // Should be empty if notes exist but filter doesn't match
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant
                  ),
                  textAlign: TextAlign.center,
                ),
              )
              : ListView.builder(
                keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                itemCount: _displayedNotes.length,
                itemBuilder: (context, index) {
                  final note = _displayedNotes[index];
                  final String heroTag = note.heroTag;
                  final String formattedDate = DateFormat.yMd().format(note.date);

                  return Hero(
                    tag: heroTag,
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
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
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
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
                  );
                },
              ),
          ),
        ],
      ),
    );
  }
}
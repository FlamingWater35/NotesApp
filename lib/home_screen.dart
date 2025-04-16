import 'package:flutter/material.dart';
import 'package:logging/logging.dart';
import 'package:intl/intl.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, String>> notes;
  final void Function(Map<String, String> note) onDeleteNote;
  final void Function(Map<String, String> note, String heroTag) onNoteTap;

  const HomeScreen({
    super.key,
    required this.notes,
    required this.onDeleteNote,
    required this.onNoteTap,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

enum SortProperty { date, title }

class _HomeScreenState extends State<HomeScreen> {
  final _log = Logger('HomeScreenState');
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();

  List<Map<String, String>> _displayedNotes = [];
  SortProperty _sortBy = SortProperty.date;
  bool _sortAscending = false;

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _updateDisplayedNotes();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notes != oldWidget.notes) {
      _log.fine("Notes list updated externally, running filter and forcing rebuild.");
      _updateDisplayedNotes();
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
    _updateDisplayedNotes();
  }

  void _updateDisplayedNotes() {
    final query = _searchController.text.toLowerCase();
    _log.finer("Updating displayed notes. Query: '$query', SortBy: $_sortBy, Asc: $_sortAscending");

    List<Map<String, String>> filteredNotes;
    if (query.isEmpty) {
      filteredNotes = List.from(widget.notes);
    } else {
      filteredNotes = widget.notes.where((note) {
        final titleLower = note['title']?.toLowerCase() ?? '';
        final contentLower = note['content']?.toLowerCase() ?? '';
        return titleLower.contains(query) || contentLower.contains(query);
      }).toList();
    }
    _log.finer("Filtering complete. ${filteredNotes.length} notes match query.");

    filteredNotes.sort((a, b) {
      int compareResult = 0;
      switch (_sortBy) {
        case SortProperty.date:
          try {
            final dateA = DateTime.tryParse(a['date'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
            final dateB = DateTime.tryParse(b['date'] ?? '') ?? DateTime.fromMillisecondsSinceEpoch(0);
            compareResult = dateA.compareTo(dateB);
          } catch (e) {
            _log.warning("Error parsing dates during sort: $e");
            compareResult = 0;
          }
          break;
        case SortProperty.title:
          final titleA = a['title']?.toLowerCase() ?? '';
          final titleB = b['title']?.toLowerCase() ?? '';
          compareResult = titleA.compareTo(titleB);
          break;
      }
      return _sortAscending ? compareResult : -compareResult;
    });
     _log.finer("Sorting complete.");

    // Only call setState if the list content or order might have changed
    // Called on every update, could optimize with list comparison
    setState(() {
      _displayedNotes = filteredNotes;
    });
  }

  Future<void> _showDeleteConfirmation(BuildContext context, Map<String, String> note) async {
    final bool? confirmed = await showGeneralDialog<bool>(
      context: context,
      barrierDismissible: true,
      barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel, // Accessibility label
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 300),
      pageBuilder: (BuildContext buildContext, Animation<double> animation, Animation<double> secondaryAnimation) {
        return AlertDialog(
          title: const Text('Delete Note?'),
          content: Text('Are you sure you want to delete "${note['title'] ?? 'this note'}"? This action cannot be undone.'),
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
      _log.info("Deletion confirmed for note: ${note['title']}");
      widget.onDeleteNote(note);
    } else {
      _log.info("Deletion cancelled for note: ${note['title']}");
    }
  }


  @override
  Widget build(BuildContext context) {
    _log.finer("Building HomeScreen widget");
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
            padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Wrap(
                  spacing: 8.0,
                  children: [
                    ChoiceChip(
                      label: const Text('Date'),
                      selected: _sortBy == SortProperty.date,
                      onSelected: (selected) {
                        if (selected) {
                          _log.fine("Sort by Date selected.");
                          setState(() { _sortBy = SortProperty.date; });
                          _updateDisplayedNotes();
                        }
                      },
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    ),
                    ChoiceChip(
                      label: const Text('Title'),
                      selected: _sortBy == SortProperty.title,
                      onSelected: (selected) {
                        if (selected) {
                          _log.fine("Sort by Title selected.");
                          setState(() { _sortBy = SortProperty.title; });
                          _updateDisplayedNotes();
                        }
                      },
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(horizontal: 6.0, vertical: 2.0),
                    ),
                  ],
                ),

                IconButton(
                  icon: Icon(
                    _sortAscending ? Icons.arrow_upward : Icons.arrow_downward,
                    size: 20.0,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  tooltip: _sortAscending ? 'Sort Ascending' : 'Sort Descending',
                  visualDensity: VisualDensity.compact,
                  padding: EdgeInsets.zero,
                  onPressed: () {
                    _log.fine("Sort direction toggled.");
                    setState(() { _sortAscending = !_sortAscending; });
                    _updateDisplayedNotes();
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
                      : '', // Should be empty if notes exist but filter doesn't match
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
                  final String heroTag = note['id'] ?? Object.hash(note['title'], note['content']).toString();
                  String formattedDate = '';
                  try {
                    final dateString = note['date'];
                    if (dateString != null && dateString.isNotEmpty) {
                      final dateTime = DateTime.parse(dateString);
                      formattedDate = DateFormat.yMd().format(dateTime);
                    }
                  } catch (e) {
                    _log.warning("Could not parse date for note ID ${note['id']}: ${note['date']}", e);
                    // formattedDate remains empty
                  }

                  return Hero(
                    tag: heroTag,
                    child: Card(
                      margin: const EdgeInsets.symmetric(vertical: 4.0),
                      child: ListTile(
                        title: Text(
                          note['title'] ?? 'Error: Missing Title',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                        subtitle: Text(
                          '${formattedDate.isNotEmpty ? "$formattedDate - " : ""}${note['content'] ?? ''}',
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                          tooltip: 'Delete Note',
                          onPressed: () {
                            _log.fine("Delete button pressed for note ID: ${note['id']}");
                            _showDeleteConfirmation(context, note);
                          },
                        ),

                        onTap: () {
                          FocusScope.of(context).unfocus();
                          _log.info('Tapped on note ID: ${note['id']}');
                          widget.onNoteTap(note, heroTag);
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
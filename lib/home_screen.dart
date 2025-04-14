import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

class HomeScreen extends StatefulWidget {
  final List<Map<String, String>> notes;
  final void Function(Map<String, String> note) onDeleteNote;

  const HomeScreen({
    super.key,
    required this.notes,
    required this.onDeleteNote,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _log = Logger('HomeScreenState');
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _filteredNotes = [];
  final FocusNode _searchFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _filterNotes(runSetState: false);
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void didUpdateWidget(covariant HomeScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.notes != oldWidget.notes) {
      _log.fine("Notes list updated externally, running filter and forcing rebuild.");
      _filterNotes(runSetState: true); // Force rebuild
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
    _filterNotes(runSetState: true);
  }

  void _filterNotes({required bool runSetState}) {
    final query = _searchController.text.toLowerCase();
    _log.finer("Filtering notes with query: '$query'");
    List<Map<String, String>> newFilteredList;
    if (query.isEmpty) {
      newFilteredList = List.from(widget.notes);
    } else {
      newFilteredList = widget.notes.where((note) {
        final titleLower = note['title']?.toLowerCase() ?? '';
        final contentLower = note['content']?.toLowerCase() ?? '';
        return titleLower.contains(query) || contentLower.contains(query);
      }).toList();
    }
    _log.finer("Filtering complete. ${newFilteredList.length} notes match.");

    if (runSetState) {
      setState(() {
        _filteredNotes = newFilteredList;
      });
    } else {
      _filteredNotes = newFilteredList;
    }
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
            padding: const EdgeInsets.all(12.0),
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
          // Notes List
          Expanded(
            child: _filteredNotes.isEmpty
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
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    itemCount: _filteredNotes.length,
                    itemBuilder: (context, index) {
                      final note = _filteredNotes[index];
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 4.0),
                        child: ListTile(
                          title: Text(
                            note['title'] ?? 'Error: Missing Title',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                          subtitle: Text(
                            note['content'] ?? '',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: IconButton(
                            icon: Icon(Icons.delete_outline, color: Theme.of(context).colorScheme.error),
                            tooltip: 'Delete Note',
                            onPressed: () {
                              _log.fine("Delete button pressed for note: ${note['title']}");
                              _showDeleteConfirmation(context, note);
                            },
                          ),
                          onTap: () {
                            FocusScope.of(context).unfocus();
                            _log.info('Tapped on note: ${note['title']}');
                            // TODO: Navigate to a Note Detail/Edit screen
                          },
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
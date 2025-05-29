import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../models/note_model.dart';
import '../screens/home_screen.dart';

String getSortPropertyText(BuildContext context, SortProperty property) {
  final l10n = AppLocalizations.of(context);
  switch (property) {
    case SortProperty.date:
      return l10n.sortPropertyDate;
    case SortProperty.title:
      return l10n.sortPropertyTitle;
    case SortProperty.lastModified:
      return l10n.sortPropertyLastModified;
    case SortProperty.createdAt:
      return l10n.sortPropertyCreatedAt;
  }
}

List<Note> getFilteredAndSortedNotes(
  List<Note> currentNotes,
  TextEditingController searchController,
  SortProperty sortBy,
  bool sortAscending,
) {
  final query = searchController.text.toLowerCase().trim();
  List<Note> filteredNotes;

  if (query.isEmpty) {
    filteredNotes = List.from(currentNotes);
  } else {
    filteredNotes =
        currentNotes.where((note) {
          final titleLower = note.title.toLowerCase();
          final contentLower = note.plainTextContent.toLowerCase();
          return titleLower.contains(query) || contentLower.contains(query);
        }).toList();
  }

  filteredNotes.sort((a, b) {
    int compareResult = 0;
    switch (sortBy) {
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
    return sortAscending ? compareResult : -compareResult;
  });

  return filteredNotes;
}

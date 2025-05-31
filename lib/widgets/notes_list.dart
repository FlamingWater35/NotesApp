import 'package:animated_list_plus/animated_list_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:logging/logging.dart';
import 'package:notes_app/screens/home_screen.dart';

import '../l10n/app_localizations.dart';
import '../models/note_model.dart';
import '../providers/notes_provider.dart';

ImplicitlyAnimatedList<Note> animatedNoteList(
  List<Note> displayedNotes,
  Duration animationDuration,
  HomeScreen widget,
  WidgetRef ref,
  Logger log,
) {
  return ImplicitlyAnimatedList<Note>(
    items: displayedNotes,
    padding: const EdgeInsets.only(bottom: 80.0),
    itemBuilder: (context, animation, note, index) {
      return buildAnimatedItem(
        context,
        note,
        animation,
        widget: widget,
        ref: ref,
        log: log,
      );
    },
    removeItemBuilder: (context, animation, note) {
      return buildAnimatedItem(
        context,
        note,
        animation,
        isRemoving: true,
        widget: widget,
        ref: ref,
        log: log,
      );
    },
    insertDuration: animationDuration,
    removeDuration: animationDuration,
    areItemsTheSame: (a, b) => a.id == b.id,
  );
}

Widget buildAnimatedItem(
  BuildContext context,
  Note note,
  Animation<double> animation, {
  bool isRemoving = false,
  required HomeScreen widget,
  required WidgetRef ref,
  required Logger log,
}) {
  final l10n = AppLocalizations.of(context);
  final String heroTag = note.heroTag;
  final String formattedDate = DateFormat.yMd().format(note.date);
  final theme = Theme.of(context);

  final slideTween = Tween<Offset>(
    begin: isRemoving ? const Offset(1.0, 0.0) : const Offset(-1.0, 0.0),
    end: Offset.zero,
  );
  final curvedAnimation = CurvedAnimation(
    parent: animation,
    curve: Curves.easeInOut,
  );

  return SizeTransition(
    sizeFactor: curvedAnimation,
    child: FadeTransition(
      opacity: curvedAnimation,
      child: SlideTransition(
        position: animation.drive(
          slideTween.chain(CurveTween(curve: Curves.easeInOut)),
        ),
        child: _buildItemContent(
          context,
          l10n,
          note,
          theme,
          formattedDate,
          heroTag,
          widget,
          ref,
          log,
        ),
      ),
    ),
  );
}

Widget _buildItemContent(
  BuildContext context,
  AppLocalizations l10n,
  Note note,
  ThemeData theme,
  String formattedDate,
  String heroTag,
  HomeScreen widget,
  WidgetRef ref,
  Logger log,
) {
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: ListTile(
            title: Text(
              note.title.isEmpty ? l10n.untitledNote : note.title,
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
              tooltip: l10n.deleteNoteTooltip,
              onPressed: () {
                log.fine("Delete button pressed for note ID: ${note.id}");
                _showDeleteConfirmation(context, note, ref, log);
              },
            ),
            onTap: () {
              FocusScope.of(context).unfocus();
              log.info('Tapped on note ID: ${note.id}');
              widget.onNoteTap(note);
            },
            // visualDensity: VisualDensity.compact,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      ),
    ),
  );
}

Future<void> _showDeleteConfirmation(
  BuildContext context,
  Note note,
  WidgetRef ref,
  Logger log,
) async {
  final l10n = AppLocalizations.of(context);
  final String displayTitle =
      note.title.isEmpty ? l10n.untitledNote : note.title;

  final bool? confirmed = await showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: MaterialLocalizations.of(context).modalBarrierDismissLabel,
    barrierColor: Colors.black54,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (
      BuildContext buildContext,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
    ) {
      return AlertDialog(
        title: Text(l10n.deleteNoteDialogTitle),
        content: Text(l10n.deleteNoteDialogContent(displayTitle)),
        actions: <Widget>[
          TextButton(
            child: Text(l10n.cancelButtonLabel),
            onPressed: () => Navigator.of(buildContext).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(buildContext).colorScheme.error,
            ),
            child: Text(l10n.deleteButtonLabel),
            onPressed: () => Navigator.of(buildContext).pop(true),
          ),
        ],
      );
    },
    transitionBuilder: (
      BuildContext buildContext,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return ScaleTransition(
        scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
        child: child,
      );
    },
  );

  if (confirmed == true) {
    log.info("Deletion confirmed for note: ${note.title} (ID: ${note.id})");
    ref.read(notesProvider.notifier).deleteNote(note.id);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.noteDeletedSnackbar(displayTitle)),
          duration: const Duration(seconds: 2),
        ),
      );
    }
  } else {
    log.info("Deletion cancelled for note: ${note.title}");
  }
}

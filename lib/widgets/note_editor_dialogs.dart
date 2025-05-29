import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';

Future<bool> showDiscardDialog(BuildContext context) async {
  final l10n = AppLocalizations.of(context);
  final bool? shouldDiscard = await showGeneralDialog<bool>(
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
        title: Text(l10n.discardChangesDialogTitle),
        content: Text(l10n.discardChangesDialogContent),
        actions: <Widget>[
          TextButton(
            child: Text(l10n.cancelButtonLabel),
            onPressed: () => Navigator.of(buildContext).pop(false),
          ),
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(buildContext).colorScheme.error,
            ),
            child: Text(l10n.discardButtonLabel),
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
  return shouldDiscard ?? false;
}

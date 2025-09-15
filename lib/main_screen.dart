import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_quill/flutter_quill.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:logging/logging.dart';

import '../l10n/app_localizations.dart';
import 'models/note_model.dart';
import 'providers/notes_provider.dart';
import 'screens/add_note_screen.dart';
import 'screens/edit_note_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  static const Duration _kTransitionDuration = Duration(milliseconds: 400);

  bool _isNavBarVisible = true;
  final _log = Logger('MainScreenState');
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _log.fine("Navigation item tapped: index $index");
      FocusScope.of(context).unfocus();
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _navigateToAddNote() async {
    _log.info("Navigating to Add Note screen");
    FocusScope.of(context).unfocus();

    if (mounted) {
      setState(() => _isNavBarVisible = false);
    }

    await Navigator.push<void>(
      context,
      PageRouteBuilder(
        pageBuilder:
            (context, animation, secondaryAnimation) => const AddNoteScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const Offset begin = Offset(1.0, 0.0);
          const Offset end = Offset.zero;
          const Curve curve = Curves.easeInOut;
          var tween = Tween(
            begin: begin,
            end: end,
          ).chain(CurveTween(curve: curve));
          var offsetAnimation = animation.drive(tween);
          return SlideTransition(position: offsetAnimation, child: child);
        },
        transitionDuration: _kTransitionDuration,
      ),
    );

    if (mounted) {
      setState(() => _isNavBarVisible = true);
    }
  }

  Future<void> _navigateToEditNote(Note noteToEdit) async {
    _log.info("Navigating to Edit Note screen for ID: ${noteToEdit.id}");
    FocusScope.of(context).unfocus();

    final Document document = await compute(
      parseQuillContent,
      noteToEdit.content,
    );

    if (!mounted) return;
    setState(() => _isNavBarVisible = false);

    await Navigator.push<void>(
      context,
      MaterialPageRoute(
        builder:
            (context) => EditNoteScreen(
              noteId: noteToEdit.id,
              heroTag: noteToEdit.heroTag,
              document: document,
            ),
      ),
    );

    if (mounted) {
      setState(() => _isNavBarVisible = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.finer("Building MainScreen widget");
    final l10n = AppLocalizations.of(context);
    final navBarOffset =
        _isNavBarVisible ? Offset.zero : const Offset(0.0, 1.1);
    final notesAsync = ref.watch(notesProvider);

    return Scaffold(
      body: notesAsync.when(
        data: (notes) {
          _log.finer("Notes data received: ${notes.length} notes.");
          final List<Widget> widgetOptions = <Widget>[
            HomeScreen(notes: notes, onNoteTap: _navigateToEditNote),
            const SettingsScreen(),
          ];
          return PageTransitionSwitcher(
            duration: _kTransitionDuration,
            transitionBuilder: (
              Widget child,
              Animation<double> animation,
              Animation<double> secondaryAnimation,
            ) {
              return FadeThroughTransition(
                animation: animation,
                secondaryAnimation: secondaryAnimation,
                child: child,
              );
            },
            child: widgetOptions[_selectedIndex],
          );
        },
        loading: () {
          _log.finer("Displaying loading indicator.");
          return const Center(child: CircularProgressIndicator());
        },
        error: (error, stackTrace) {
          _log.severe("Error loading notes", error, stackTrace);
          return Center(
            child: Text(
              l10n.errorLoadingNotes(error.toString()),
              textAlign: TextAlign.center,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          );
        },
      ),
      floatingActionButton:
          _selectedIndex == 0
              ? FloatingActionButton(
                onPressed: _navigateToAddNote,
                tooltip: l10n.addNoteFabTooltip,
                child: const Icon(Icons.add),
              )
              : null,
      bottomNavigationBar: AnimatedSlide(
        duration: _kTransitionDuration,
        offset: navBarOffset,
        curve: Curves.easeInOut,
        child: NavigationBar(
          destinations: <NavigationDestination>[
            NavigationDestination(
              selectedIcon: Icon(Icons.home),
              icon: Icon(Icons.home_outlined),
              label: l10n.homeNavigationLabel,
            ),
            NavigationDestination(
              selectedIcon: Icon(Icons.settings),
              icon: Icon(Icons.settings_outlined),
              label: l10n.settingsNavigationLabel,
            ),
          ],
          selectedIndex: _selectedIndex,
          onDestinationSelected: _onItemTapped,
          labelBehavior: NavigationDestinationLabelBehavior.onlyShowSelected,
        ),
      ),
    );
  }
}

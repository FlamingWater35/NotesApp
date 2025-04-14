import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:logging/logging.dart';

import 'add_note_screen.dart';
import 'home_screen.dart';
import 'settings_screen.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final _log = Logger('MainScreenState');
  int _selectedIndex = 0;
  List<Map<String, String>> _notes = [];
  late List<Widget> _widgetOptions;
  bool _isLoading = true;

  static const String _notesKey = 'notes_data';

  @override
  void initState() {
    super.initState();
    _log.fine("initState called");
    _widgetOptions = _buildWidgetOptions();
    _loadNotes();
  }

  List<Widget> _buildWidgetOptions() {
    _log.finer("Building widget options");
    return <Widget>[
      HomeScreen(
        notes: _notes,
        onDeleteNote: _deleteNote,
      ),
      const SettingsScreen(),
    ];
  }

  Future<void> _loadNotes() async {
    _log.info("Loading notes...");
    final prefs = await SharedPreferences.getInstance();
    final String? notesString = prefs.getString(_notesKey);
    List<Map<String, String>> loadedNotes = [];

    if (notesString != null && notesString.isNotEmpty) {
      try {
        final List<dynamic> decodedList = jsonDecode(notesString);
        loadedNotes = decodedList
            .map((item) => Map<String, String>.from(item as Map))
            .toList();
        _log.info("Successfully loaded ${loadedNotes.length} notes.");
      } catch (e, stackTrace) {
        _log.severe("Error decoding notes from SharedPreferences", e, stackTrace);
        await prefs.remove(_notesKey);
      }
    } else {
       _log.info("No saved notes found or notes string was empty.");
    }

    if (mounted) {
      setState(() {
        _notes = loadedNotes;
        _widgetOptions = _buildWidgetOptions();
        _isLoading = false;
      });
       _log.fine("State updated after loading notes.");
    } else {
       _log.warning("Tried to update state after loading notes, but widget was unmounted.");
    }
  }

  Future<void> _saveNotes() async {
    _log.info("Saving ${_notes.length} notes...");
    final prefs = await SharedPreferences.getInstance();
    try {
      final String notesString = jsonEncode(_notes);
      await prefs.setString(_notesKey, notesString);
       _log.info("Notes saved successfully.");
    } catch (e, stackTrace) {
       _log.severe("Error encoding notes for SharedPreferences", e, stackTrace);
    }
  }

  Future<void> _deleteNote(Map<String, String> noteToDelete) async {
    _log.info("Attempting to delete note: ${noteToDelete['title']}");
    final newList = _notes.where((note) => note != noteToDelete).toList();

    if (newList.length < _notes.length) {
      if (mounted) {
        setState(() {
          _notes = newList;
          _widgetOptions = _buildWidgetOptions();
          _log.fine("Note removed from state list by creating a new list.");
        });
        await _saveNotes();
      } else {
         _log.warning("Tried to update state after deleting note, but widget was unmounted.");
      }
    } else {
       _log.warning("Note to delete was not found in the current notes list, or list length did not change.");
    }
  }

  void _onItemTapped(int index) {
    if (_selectedIndex != index) {
      _log.fine("Navigation item tapped: index $index");
      setState(() {
        FocusScope.of(context).unfocus();
        _selectedIndex = index;
        _widgetOptions = _buildWidgetOptions();
      });
    }
  }

  void _navigateToAddNote() async {
    _log.info("Navigating to Add Note screen");
    FocusScope.of(context).unfocus();
    final result = await Navigator.push<Map<String, String>>(
      context,
      PageRouteBuilder(
        pageBuilder: (context, animation, secondaryAnimation) => const AddNoteScreen(),
        transitionsBuilder: (context, animation, secondaryAnimation, child) {
          const Offset begin = Offset(1.0, 0.0); // Start position (off-screen right)
          const Offset end = Offset.zero; // End position (on-screen)
          const Curve curve = Curves.easeInOut; // Animation curve

          var tween = Tween(begin: begin, end: end).chain(CurveTween(curve: curve));

          var offsetAnimation = animation.drive(tween);

          return SlideTransition(
            position: offsetAnimation,
            child: child,
          );
        },
        transitionDuration: const Duration(milliseconds: 400),
      ),
    );

    if (result != null && mounted) {
      _log.info("Received new note data from AddNoteScreen.");
      setState(() {
        _notes = [result, ..._notes];
        _widgetOptions = _buildWidgetOptions();
        _log.fine("State updated with new note.");
      });
      await _saveNotes();
    } else if (result == null) {
      _log.info("AddNoteScreen was closed without saving.");
    } else {
       _log.warning("Tried to update state after adding note, but widget was unmounted.");
    }
  }

  @override
  Widget build(BuildContext context) {
    _log.finer("Building MainScreen widget");
    return Scaffold(
      resizeToAvoidBottomInset: false, // Prevent resize on keyboard
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : IndexedStack(
              index: _selectedIndex,
              children: _widgetOptions,
            ),
      floatingActionButton: _selectedIndex == 0
          ? FloatingActionButton(
              onPressed: _navigateToAddNote,
              tooltip: 'Add Note',
              child: const Icon(Icons.add),
            )
          : null,
      bottomNavigationBar: NavigationBar(
        destinations: const <NavigationDestination>[
          NavigationDestination(
            selectedIcon: Icon(Icons.home),
            icon: Icon(Icons.home_outlined),
            label: 'Home',
          ),
          NavigationDestination(
            selectedIcon: Icon(Icons.settings),
            icon: Icon(Icons.settings_outlined),
            label: 'Settings',
          ),
        ],
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onItemTapped,
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
    );
  }
}
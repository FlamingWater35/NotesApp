import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_quill/flutter_quill.dart';

Document parseQuillContent(String contentJson) {
  if (contentJson.isEmpty) {
    return Document();
  }
  try {
    final List<dynamic> deltaJson = jsonDecode(contentJson);
    return Document.fromJson(deltaJson);
  } catch (e) {
    debugPrint("Error parsing quill content: $e");
    return Document()..insert(0, 'Error: Could not load content.');
  }
}

class Note {
  Note({
    required this.id,
    required this.title,
    required this.content,
    required this.date,
    required this.createdAt,
    required this.lastModified,
  });

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      id: map['id'] as String,
      title: map['title'] as String? ?? '',
      content: map['content'] as String? ?? '',
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      createdAt:
          DateTime.tryParse(map['createdAt'] as String? ?? '') ??
          DateTime.now(),
      lastModified:
          DateTime.tryParse(map['lastModified'] as String? ?? '') ??
          DateTime.now(),
    );
  }

  final String content;
  final DateTime createdAt;
  final DateTime date;
  final String id;
  final DateTime lastModified;
  final String title;

  Document? _document;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Note && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  Document get contentDocument {
    if (_document != null) return _document!;

    if (content.isEmpty) {
      return _document = Document();
    }
    try {
      final List<dynamic> deltaJson = jsonDecode(content);
      return _document = Document.fromJson(deltaJson);
    } catch (e, stackTrace) {
      debugPrint(
        'Error decoding Quill JSON content for note ID $id: $e\n$stackTrace',
      );
      final doc = Document()..insert(0, 'Error: Could not load content.');
      return _document = doc;
    }
  }

  String get plainTextContent {
    final doc = contentDocument;
    return doc.toPlainText().trim();
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'lastModified': lastModified.toIso8601String(),
    };
  }

  Note copyWith({
    String? id,
    String? title,
    String? content,
    DateTime? date,
    DateTime? createdAt,
    DateTime? lastModified,
  }) {
    final newNote = Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );

    if (content == this.content || content == null) {
      newNote._document = _document;
    }

    return newNote;
  }

  String get heroTag => 'noteHero_$id';
}

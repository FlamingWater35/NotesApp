class Note {
  final String id;
  final String title;
  final String content;
  final DateTime date;
  final DateTime createdAt;
  final DateTime lastModified;

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
      title: map['title'] as String,
      content: map['content'] as String,
      date: DateTime.tryParse(map['date'] as String? ?? '') ?? DateTime.now(),
      createdAt: DateTime.tryParse(map['createdAt'] as String? ?? '') ?? DateTime.now(),
      lastModified: DateTime.tryParse(map['lastModified'] as String? ?? '') ?? DateTime.now(),
    );
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
    return Note(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      date: date ?? this.date,
      createdAt: createdAt ?? this.createdAt,
      lastModified: lastModified ?? this.lastModified,
    );
  }

  String get heroTag => 'noteHero_$id';

  @override
  bool operator ==(Object other) =>
    identical(this, other) ||
    other is Note &&
      runtimeType == other.runtimeType &&
      id == other.id;

  @override
  int get hashCode => id.hashCode;
}
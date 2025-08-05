import 'package:uuid/uuid.dart';

class Note {
  Note({
    String? noteId,
    DateTime? noteTime,
    this.noteTitle = '',
    this.note = '',
    this.description = '',
  })  : noteId = noteId ?? const Uuid().v4(),
        noteTime = noteTime ?? DateTime.now();

  String noteId;
  DateTime noteTime;
  String noteTitle;
  String note;
  String description;

  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'noteTime': noteTime.toIso8601String(),
      'noteTitle': noteTitle,
      'note': note,
      'description': description,
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      noteId: map['noteId'],
      noteTime: DateTime.parse(map['noteTime']),
      noteTitle: map['noteTitle'],
      note: map['note'],
      description: map['description'],
    );
  }
}

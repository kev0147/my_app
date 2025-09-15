import 'package:my_app/model/project.dart';
import 'package:uuid/uuid.dart';

class Note {
  Note({
    String? noteId,
    DateTime? noteTime,
    this.noteTitle = '',
    this.note = '',
    this.description = '',
    String? projectId,
  })  : noteId = noteId ?? const Uuid().v4(),
        noteTime = noteTime ?? DateTime.now(),
        projectId = projectId ?? "default";

  String noteId;
  DateTime noteTime;
  String noteTitle;
  String note;
  String description;
    Project? project;
  String? projectId;

  Map<String, dynamic> toMap() {
    return {
      'noteId': noteId,
      'noteTime': noteTime.toIso8601String(),
      'noteTitle': noteTitle,
      'note': note,
      'description': description,
      'projectId': project?.projectId,
      
    };
  }

  factory Note.fromMap(Map<String, dynamic> map) {
    return Note(
      noteId: map['noteId'],
      noteTime: DateTime.parse(map['noteTime']),
      noteTitle: map['noteTitle'],
      note: map['note'],
      description: map['description'],
      projectId: map['projectId'],
    );
  }
}

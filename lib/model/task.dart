import 'package:my_app/model/project.dart';
import 'package:uuid/uuid.dart';

class Task {
  Task({
    String? taskId,
    this.taskName = '',
    DateTime? startTime,
    DateTime? endTime,
    DateTime? reminder,
    this.status = 0,
    String? projectId,
  })  : taskId = taskId ?? const Uuid().v4(),
        startTime = startTime ?? DateTime.now(),
        endTime = endTime ?? DateTime.now(),
        reminder = reminder ?? DateTime.now(),
        projectId = projectId ?? "default";

  String taskId;
  String taskName;
  DateTime startTime;
  DateTime endTime;
  DateTime reminder;
  int status;
  Project? project;
  String? projectId;

  Map<String, dynamic> toMap() {
    return {
      'taskId': taskId,
      'taskName': taskName,
      'startTime': startTime.toIso8601String(),
      'endTime': endTime.toIso8601String(),
      'reminder': reminder.toIso8601String(),
      'status': status,
      'projectId': project?.projectId,
    };
  }

  factory Task.fromMap(Map<String, dynamic> map) {
    return Task(
      taskId: map['taskId'],
      taskName: map['taskName'],
      startTime: DateTime.parse(map['startTime']),
      endTime: DateTime.parse(map['endTime']),
      reminder: DateTime.parse(map['reminder']),
      status: map['status'],
      projectId: map['projectId'],
    );
  }
}

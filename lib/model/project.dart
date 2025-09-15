import 'package:uuid/uuid.dart';

class Project {
  Project({
    String? projectId,
    String? projectName,
    this.status,
  }) : projectId = projectId ?? const Uuid().v4(), projectName = projectName ?? "default";

  String projectId;
  String projectName;
  int? status = 0;

  // Convert Project instance to Map (for SQLite or JSON)
  Map<String, dynamic> toMap() {
    return {
      'projectId': projectId,
      'projectName': projectName,
      'status': status,
    };
  }

  // Create Project instance from Map
  factory Project.fromMap(Map<String, dynamic> map) {
    return Project(
      projectId: map['projectId'],
      projectName: map['projectName'],
      status: map['status'],
    );
  }
}

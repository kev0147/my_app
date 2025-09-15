import 'package:flutter/material.dart';
import 'package:my_app/model/project.dart';
import 'package:my_app/screens/projects_screen.dart';

class ProjectForm extends StatefulWidget {
  final Function(Project) function;
  const ProjectForm({super.key, required this.function});

  @override
  State<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends State<ProjectForm> {
  final TextEditingController _projectNameController = TextEditingController();

  addProject() {
    if (_projectNameController.text.trim().isEmpty) return;
    final project = Project(projectName: _projectNameController.text.trim());
    widget.function(project);
    _projectNameController.clear();

    Navigator.pop(
      context,
      MaterialPageRoute(
        builder: (_) => const ProjectScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Category'),
      ),
      body: Expanded(
        child: TextField(
          controller: _projectNameController,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
      ),
      floatingActionButton: ElevatedButton(
        onPressed: addProject,
        child: const Text('Add'),
      ),
    );
  }
}

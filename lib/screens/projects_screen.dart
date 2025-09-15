import 'package:flutter/material.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/project.dart';
import 'package:my_app/screens/daily_screen.dart';
import 'package:my_app/screens/day_screen.dart';
import 'package:my_app/screens/project_form_screen.dart';

class ProjectScreen extends StatefulWidget {
  const ProjectScreen({super.key});

  @override
  State<ProjectScreen> createState() => _ProjectScreenState();
}

class _ProjectScreenState extends State<ProjectScreen> {
  final dbHelper = DatabaseHelper();
  List<Project> _projects = [];
  final TextEditingController _projectNameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadProjects();
  }

  Future<void> _loadProjects() async {
    final projects = await dbHelper.getAllProjects();
    setState(() => _projects = projects);
  }

  void addProject(Project project) {
    dbHelper.insertProject(project);
    _loadProjects();
  }

  void updateProject(Project project) {
    dbHelper.updateProject(project);
    _loadProjects();
  }

  Future<void> _deleteProject(String id) async {
    await dbHelper.deleteProject(id);
    await _loadProjects();
  }

  void projectFormPage(BuildContext context, Function(Project) function) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ProjectForm(
          function: function,
        ),
      ),
    );
    _loadProjects();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Projects'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => DailyScreen(
                    date: DateTime.now(),
                  ),
                ));
          },
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
            Expanded(
              child: TextField(
                controller: _projectNameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                if (_projectNameController.text.trim().isEmpty) return;
                final project = Project(
                    projectName: _projectNameController.text.trim());
                addProject(project);
                _projectNameController.clear();
              },
              child: const Text('Add'),
            ),],),
          const SizedBox(height: 20),
          _projects.isEmpty
              ? const Center(child: Text('No project yet.'))
              : ListView.builder(
                  shrinkWrap: true,
                  itemCount: _projects.length,
                  itemBuilder: (_, index) {
                    final project = _projects[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      title: Text(
                        project.projectName,
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteProject(
                            project.projectId), // Replace with your function
                      ),
                      onTap: () {},
                    );
                  },
                )
        ],
      ),
    );
  }
}

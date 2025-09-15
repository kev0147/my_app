import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/project.dart';
import 'package:my_app/model/task.dart';
import 'package:my_app/screens/day_screen_bar.dart';
import 'package:my_app/screens/month_screen.dart';
import 'package:my_app/screens/projects_screen.dart';
import 'package:my_app/screens/task_form_screen.dart';
import 'package:my_app/screens/tasks_screen.dart';
import 'package:my_app/screens/transactions_screen.dart';
import 'package:my_app/screens/notes_screen.dart';

class DayScreen extends StatefulWidget {
  const DayScreen({super.key, required this.date});

  final DateTime date;

  @override
  State<DayScreen> createState() => _DayScreenState();
}

class _DayScreenState extends State<DayScreen> {
  final dbHelper = DatabaseHelper();
  List<Task> _tasks = [];
  List<Project> _projects = [];
  final DateFormat _hm = DateFormat.Hm();

  @override
  void initState() {
    super.initState();
    _loadTasks();
    _loadProjects;
  }

  Future<void> _loadTasks() async {
    final tasks = await dbHelper.getTasksOfTheDay(widget.date);
    setState(() => _tasks = tasks);
  }

  Future<void> _loadProjects() async {
    final projects = await dbHelper.getAllProjects();
    setState(() => _projects = projects);
  }

  Future<void> addTask(Task task) async {
    await dbHelper.insertTask(task);
    await _loadTasks();
  }

  Future<void> _deleteTask(String id) async {
    await dbHelper.deleteTask(id);
    await _loadTasks();
  }

  void taskForm() {
    showDialog(
      context: context,
      builder: (_) => TaskForm(
        function: addTask,
        date: widget.date,
        projects: _projects,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          appBar: dayScreenBar(context),
          body: Column(
            children: [
              // 🔘 Row with 3 buttons at the top
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: taskForm,
                      child: const Text('Add task'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Add money flow'),
                    ),
                    ElevatedButton(
                      onPressed: () {},
                      child: const Text('Add note'),
                    ),
                  ],
                ),
              ),
              const Divider(),

              // 📜 ListTiles below
              Expanded(
                child: _tasks.isEmpty
                    ? const Center(child: Text('No task yet.'))
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _tasks.length,
                        itemBuilder: (_, index) {
                          final task = _tasks[index];
                          return ListTile(
                            onTap: () => {},
                            title: Text(task.taskName),
                            subtitle: Row(
                              children: [
                                Text(
                                    'from ${_hm.format(task.startTime)} to ${_hm.format(task.endTime)}'),
                              ],
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () => _deleteTask(task.taskId),
                            ),
                          );
                        },
                      ),
              ),
            ],
          )),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/task.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  final dbHelper = DatabaseHelper();
  List<Task> _tasks = [];

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    final tasks = await dbHelper.getAllTasks();
    setState(() => _tasks = tasks);
  }

  Future<void> _deleteTask(String id) async {
    await dbHelper.deleteTask(id);
    await _loadTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tasks')),
      body: _tasks.isEmpty
          ? const Center(child: Text('No task yet.'))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _tasks.length,
              itemBuilder: (_, index) {
                final task = _tasks[index];
                return ListTile(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  /*leading: Icon(
                    task.status == 1
                        ? Icons.check_circle
                        : Icons.radio_button_unchecked,
                    color: task.status == 1 ? Colors.green : Colors.grey,
                  ),*/
                  leading: Checkbox(
                    tristate: true,
                    value: task.status == 1
                        ? true
                        : task.status == 0
                            ? false
                            : null,
                    onChanged: (bool? value) {
                      setState(() {
                        task.status = value == true
                            ? 1
                            : value == false
                                ? 0
                                : 2;
                        dbHelper.updateTask(task);
                      });
                    },
                  ),
                  title: Text(
                    task.taskName,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'date: ${DateFormat.yMMMMd().format(task.startTime)}'),
                      Text(
                          'Start:    ${DateFormat.Hm().format(task.startTime)}'),
                      Text('End:      ${DateFormat.Hm().format(task.endTime)}'),
                      Text(
                          'Reminder: ${DateFormat.Hm().format(task.reminder)}'),
                    ],
                  ),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () =>
                        _deleteTask(task.taskId), // Replace with your function
                  ),
                  onTap: () {
                    // Optionally open task detail or toggle status
                  },
                );
              },
            ),
    );
  }
}

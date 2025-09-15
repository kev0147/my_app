import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/model/project.dart';
import 'package:my_app/model/task.dart';
import 'package:my_app/screens/day_screen.dart';

class TaskForm extends StatefulWidget {
  final Function(Task) function;
  final DateTime date;
  final List<Project> projects;
  const TaskForm(
      {super.key,
      required this.function,
      required this.date,
      required this.projects});

  @override
  State<TaskForm> createState() => _TaskFormState();
}

class _TaskFormState extends State<TaskForm> {
  final TextEditingController _controller = TextEditingController();

  late DateTime _startTime;
  late DateTime _endTime;
  late DateTime _reminderTime;
  late int status;

  final DateFormat _timeFormat = DateFormat('hh:mm a');

  String? selectedValue;
  List<String> options = [];

  @override
  void initState() {
    super.initState();

    _startTime = DateTime(widget.date.year, widget.date.month, widget.date.day,
            DateTime.now().hour)
        .add(const Duration(hours: 2));
    _endTime = DateTime(widget.date.year, widget.date.month, widget.date.day,
            DateTime.now().hour)
        .add(const Duration(hours: 3));
    _reminderTime = DateTime(widget.date.year, widget.date.month,
            widget.date.day, DateTime.now().hour)
        .add(const Duration(hours: 1));

    for (var project in widget.projects) {
      options.add(project.projectName);
    }
  }

  Future<void> _pickDateTime({
    required DateTime initial,
    required void Function(DateTime) onPicked,
  }) async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(initial),
    );

    if (pickedTime != null) {
      final fullDateTime = DateTime(
        widget.date.year,
        widget.date.month,
        widget.date.day,
        pickedTime.hour,
        pickedTime.minute,
      );

      onPicked(fullDateTime);
    }
  }

  addTask() {
    if (_controller.text.trim().isEmpty) return;
    Project selectedProject = Project(projectId: "default");
    for (var option in options) {
      if (selectedValue == option) {
        selectedProject = widget.projects[options.indexOf(option)];
      }
    }
    final task = Task(
        taskName: _controller.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        reminder: _reminderTime,
        projectId: selectedProject.projectId);
    widget.function(task);
    _controller.clear();

    Navigator.pop(
      context,
      MaterialPageRoute(
        builder: (_) => DayScreen(date: widget.date),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(labelText: 'Task Name'),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.play_arrow),
              title: const Text('Start Time'),
              subtitle: Text(_timeFormat.format(_startTime)),
              onTap: () => _pickDateTime(
                initial: _startTime,
                onPicked: (dateTime) => setState(() => _startTime = dateTime),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.stop),
              title: const Text('End Time'),
              subtitle: Text(_timeFormat.format(_endTime)),
              onTap: () => _pickDateTime(
                initial: _endTime,
                onPicked: (dateTime) => setState(() => _endTime = dateTime),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: ListTile(
              leading: const Icon(Icons.alarm),
              title: const Text('Reminder'),
              subtitle: Text(_timeFormat.format(_reminderTime)),
              onTap: () => _pickDateTime(
                initial: _reminderTime,
                onPicked: (dateTime) =>
                    setState(() => _reminderTime = dateTime),
              ),
            ),
          ),
          DropdownButton<String>(
            hint: const Text('Choisissez une option'),
            value: selectedValue,
            onChanged: (newValue) {
              setState(() {
                selectedValue = newValue;
              });
            },
            items: options.map((option) {
              return DropdownMenuItem<String>(
                value: option,
                child: Text(option),
              );
            }).toList(),
          ),
          ElevatedButton(
            onPressed: addTask,
            child: const Text('Add Task'),
          )
        ],
      ),
    );
  }
}

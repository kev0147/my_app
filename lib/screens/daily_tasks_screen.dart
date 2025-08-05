import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/task.dart';
import 'package:my_app/screens/daily_screen.dart';

class TaskScreen extends StatefulWidget {
  const TaskScreen({super.key, required this.date});

  final DateTime date;

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
    final tasks = await dbHelper.getTasksOfTheDay(widget.date);
    setState(() => _tasks = tasks);
  }

  void addTask(Task task) {
    dbHelper.insertTask(task);
  }

  void updateTask(Task task) {
    dbHelper.updateTask(task);
  }

  Future<void> _deleteTask(String id) async {
    await dbHelper.deleteTask(id);
    await _loadTasks();
  }

  void taskFormPage(
      BuildContext context, Function(Task) function, bool adding) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => TaskForm(
          dbHelper: dbHelper,
          function: function,
          date: widget.date,
          adding: adding,
        ),
      ),
    );
    _loadTasks();
  }

  final DateFormat _hm = DateFormat.Hm();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _tasks.isEmpty
          ? const Center(child: Text('No task yet.'))
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _tasks.length,
              itemBuilder: (_, index) {
                final task = _tasks[index];
                return ListTile(
                  onTap: () => taskFormPage(context, updateTask, false),
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
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => taskFormPage(context, addTask, true),
      ),
    );
  }
}

class TaskForm extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Function(Task) function;
  final Task task;
  final DateTime date;
  final bool adding;
  TaskForm(
      {super.key,
      required this.dbHelper,
      required this.function,
      required this.date,
      required this.adding,
      Task? task})
      : task = task ?? Task();

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

  @override
  void initState() {
    super.initState();

    if (widget.adding) {
      _controller.text = widget.task.taskName;
      _startTime = DateTime(widget.date.year, widget.date.month,
              widget.date.day, DateTime.now().hour)
          .add(const Duration(hours: 2));
      _endTime = DateTime(widget.date.year, widget.date.month, widget.date.day,
              DateTime.now().hour)
          .add(const Duration(hours: 3));
      _reminderTime = DateTime(widget.date.year, widget.date.month,
              widget.date.day, DateTime.now().hour)
          .add(const Duration(hours: 1));
      status = 0;
    } else {
      _startTime = widget.task.startTime;
      _endTime = widget.task.endTime;
      _reminderTime = widget.task.reminder;
      status = widget.task.status;
    }
  }

  updateStatus(double value) {
    setState(() => status = value.toInt());
  }

  statusSlider(double value) {
    return Slider(
      value: value,
      onChanged: updateStatus(value),
      min: 0,
      max: 1,
      divisions: 100,
      label: '${(value * 100).round()}%',
    );
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
    final task = Task(
        taskName: _controller.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        reminder: _reminderTime);
    widget.function(task);
    _controller.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyScreen(
          date: widget.date, initialTabIndex: 0
        ),
      ),
    );
  }

  updateTask() {
    final task = Task(
        taskName: _controller.text.trim(),
        startTime: _startTime,
        endTime: _endTime,
        reminder: _reminderTime,
        status: status);
    widget.function(task);
    _controller.clear();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyScreen(
          date: widget.date, initialTabIndex: 0,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          BackButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => TaskScreen(date: widget.date),
                ),
              );
            },
          ),
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
          widget.adding
              ? ElevatedButton(
                  onPressed: addTask,
                  child: const Text('Add Task'),
                )
              : Column(
                  children: [
                    statusSlider(status.toDouble()),
                    ElevatedButton(
                      onPressed: updateTask,
                      child: const Text('update Task'),
                    )
                  ],
                )
        ],
      ),
    );
  }
}


//how to choose date and time
  /*Future<void> _pickDateTime({required DateTime initial, required void Function(DateTime) onPicked,}) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initial,
      firstDate: DateTime(1999),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(initial),
      );

      if (pickedTime != null) {
        final fullDateTime = DateTime(
          pickedDate.year,
          pickedDate.month,
          pickedDate.day,
          pickedTime.hour,
          pickedTime.minute,
        );

        onPicked(fullDateTime);
      }
    }
  }*/
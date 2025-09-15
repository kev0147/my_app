import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/note.dart';
import 'package:my_app/model/project.dart';
import 'package:my_app/screens/daily_screen.dart';

class NoteScreen extends StatefulWidget {
  NoteScreen({super.key, required this.date});

  DateTime date;

  @override
  State<NoteScreen> createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final dbHelper = DatabaseHelper();


  List<Note> _notes = [];
  List<Project> _projects = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
    _loadProjects();
  }

    Future<void> _loadProjects() async {
    final projects = await dbHelper.getAllProjects();
    setState(() => _projects = projects);
  }

  Future<void> _loadNotes() async {
    final notes = await dbHelper.getNotesOfTheDay(widget.date);
    setState(() {
      _notes = notes;
    });
  }

  _addNote(Note note) {
    dbHelper.insertNote(note);
    _loadNotes();
  }

  _updateNote(Note note){
    dbHelper.updateNote(note);
    _loadNotes();
  }

  Future<void> _deleteNote(String id) async {
    await dbHelper.deleteNote(id);
    await _loadNotes();
  }

  void noteFormPage(
      BuildContext context, Function(Note) function, bool adding) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => NoteForm(
          dbHelper: dbHelper,
          function: function,
          date: widget.date,
          adding: adding,
          projects: _projects,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Notes')),
      body: Column(
        children: [
          Expanded(
              child: _notes.isEmpty
                  ? const Center(child: Text('No notes yet.'))
                  : GridView.count(
                      crossAxisCount: 2,
                      children: List.generate(_notes.length, (index) {
                        return Column(children: [
                          Text(_notes[index].noteTitle),
                          Text(DateFormat.Hm().format(_notes[index].noteTime)),
                          
                          Card(
                            child: Text(_notes[index].note),
                          ),
                          FloatingActionButton(
                            onPressed: () => _deleteNote(_notes[index].noteId),
                          ),
                          FloatingActionButton(
                            child: const Icon(Icons.update),
                            onPressed: () { noteFormPage(context, _updateNote, false); },
                          )
                        ]);
                      }),
                    )),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: const Icon(Icons.add),
        onPressed: () => noteFormPage(context, _addNote, true),
      ),
    );
  }
}

class NoteForm extends StatefulWidget {
  final DatabaseHelper dbHelper;
  final Function(Note) function;
  final Note note;
  final DateTime date;
  final bool adding;
  final List<Project> projects;

  NoteForm(
      {super.key,
      required this.dbHelper,
      required this.function,
      required this.date,
      required this.adding,
      required this.projects,
      Note? note})
      : note = note ?? Note();

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

    String? selectedValue;
  List<String> options = [];

  @override
  void initState() {
    super.initState();
     for (var project in widget.projects) {
      options.add(project.projectName);
    }
    if(!widget.adding){
      _titleController.text = widget.note.noteTitle;
      _descriptionController.text = widget.note.description;
      _noteController.text = widget.note.note;
      for (var project in widget.projects) {
      if(widget.note.projectId == project.projectId){
        selectedValue = project.projectName;
      }
    }
    }

  }

  _addNote() {
    final title = _titleController.text.trim();
    final noteText = _noteController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty && noteText.isEmpty && desc.isEmpty) return;

            Project selectedProject = Project(projectId: "default");
    for (var option in options) {
      if (selectedValue == option) {
        selectedProject = widget.projects[options.indexOf(option)];
      }
    }

    final note = Note(noteTitle: title, note: noteText, description: desc, projectId: selectedProject.projectId );
    widget.function(note);

    _titleController.clear();
    _noteController.clear();
    _descriptionController.clear();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyScreen(date: widget.date, ),
      ),
    );
  }

    _updateNote() {
    final title = _titleController.text.trim();
    final noteText = _noteController.text.trim();
    final desc = _descriptionController.text.trim();

        Project selectedProject = Project(projectId: "default");
    for (var option in options) {
      if (selectedValue == option) {
        selectedProject = widget.projects[options.indexOf(option)];
      }
    }

    final note = Note(noteId: widget.note.noteId, noteTitle: title, note: noteText, description: desc, projectId: selectedProject.projectId);
    widget.function(note);

    _titleController.clear();
    _noteController.clear();
    _descriptionController.clear();
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DailyScreen(date: widget.date, ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => DailyScreen(date: widget.date),
              ),
            );
          },
        ),
      ),
      body: Column(
        children: [
          TextField(
              controller: _titleController,
              decoration: const InputDecoration(labelText: 'title'),
            ),
          TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(labelText: 'description'),
            ),
          TextField(
              controller: _noteController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'note',
                border: OutlineInputBorder(),
                alignLabelWithHint: true,
              ),
            ),
                    DropdownButton<String>(
          hint: const Text('Choose'),
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
        ],
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: widget.adding ? () => _addNote(): () => _updateNote(),
        child:  Icon(widget.adding ? Icons.add: Icons.update),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/note.dart';
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

  @override
  void initState() {
    super.initState();
    _loadNotes();
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
                          ),FloatingActionButton(child: const Icon(Icons.update),onPressed: () { noteFormPage(context, _updateNote, false); },)
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

  NoteForm(
      {super.key,
      required this.dbHelper,
      required this.function,
      required this.date,
      required this.adding,
      Note? note})
      : note = note ?? Note();

  @override
  State<NoteForm> createState() => _NoteFormState();
}

class _NoteFormState extends State<NoteForm> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if(widget.adding){
      _titleController.text = widget.note.noteTitle;
      _descriptionController.text = widget.note.description;
      _noteController.text = widget.note.note;
    }
  }

  _addNote() {
    final title = _titleController.text.trim();
    final noteText = _noteController.text.trim();
    final desc = _descriptionController.text.trim();

    if (title.isEmpty && noteText.isEmpty && desc.isEmpty) return;

    final note = Note(noteTitle: title, note: noteText, description: desc);
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

    final note = Note(noteId: widget.note.noteId, noteTitle: title, note: noteText, description: desc);
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

        ],
      ),
       floatingActionButton: FloatingActionButton(
        onPressed: widget.adding ? () => _addNote(): () => _updateNote(),
        child:  Icon(widget.adding ? Icons.add: Icons.update),
      ),
    );
  }
}

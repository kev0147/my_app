import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:my_app/database/database.dart';
import 'package:my_app/model/note.dart';

class NoteScreen extends StatefulWidget {
  NoteScreen({super.key});

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
    final notes = await dbHelper.getAllNotes();
    setState(() {
      _notes = notes;
    });
  }

  Future<void> _deleteNote(String id) async {
    await dbHelper.deleteNote(id);
    await _loadNotes();
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
                        return ListTile(
                          title: Text(_notes[index].noteTitle),
                          subtitle: Card(
                            child: Text(_notes[index].note),
                          ),
                        );
                      }),
                    )),
        ],
      ),
    );
  }
}
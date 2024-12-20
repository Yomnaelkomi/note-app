import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

void main() => runApp(NotesApp());

class NotesApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Notes App',
      home: NotesListScreen(),
    );
  }
}

class NotesListScreen extends StatefulWidget {
  @override
  _NotesListScreenState createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  List notes = [];

  @override
  void initState() {
    super.initState();
    fetchNotes();
  }

  Future<void> fetchNotes() async {
    final response =
        await http.get(Uri.parse('http://localhost:3000/api/note'));
    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      setState(() {
        notes = responseData['data'];
      });
    }
  }

  Future<void> addNote(String title, String description) async {
    final response = await http.post(
      Uri.parse('http://localhost:3000/api/note'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({'title': title, 'description': description}),
    );

    if (response.statusCode == 201) {
      fetchNotes();
    } else {
      print('Failed to add note: ${response.body}');
    }
  }

  Future<void> deleteNote(String id) async {
    await http.delete(Uri.parse('http://localhost:3000/api/note/$id'));
    fetchNotes();
  }

  void showAddNoteDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descriptionController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add Note'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: InputDecoration(hintText: 'Title'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(hintText: 'Description'),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                addNote(
                  titleController.text,
                  descriptionController.text,
                );
                Navigator.of(context).pop();
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Notes')),
      body: ListView.builder(
        itemCount: notes.length,
        itemBuilder: (context, index) {
          final note = notes[index];
          return ListTile(
            title: Text(note['title']),
            subtitle: Text(note['description']),
            trailing: IconButton(
              icon: Icon(Icons.delete),
              onPressed: () => deleteNote(note['_id']),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: showAddNoteDialog,
        child: Icon(Icons.add),
      ),
    );
  }
}

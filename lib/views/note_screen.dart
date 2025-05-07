import 'package:day5/controllers/hive_controller.dart';
import 'package:day5/controllers/sqlite_controller.dart';
import 'package:day5/models/note.dart';
import 'package:flutter/material.dart';

class NotesScreen extends StatefulWidget {
  const NotesScreen({super.key});

  @override
  State<NotesScreen> createState() => _NotesScreenState();
}

enum StorageType { hive, sqlite }

class _NotesScreenState extends State<NotesScreen> {
  final SqliteController sqliteController = SqliteController();
  final HiveController hiveController = HiveController();

  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  List<Note> _notes = [];
  StorageType selectedStorage = StorageType.hive;

  void _initHive() async {
    hiveController.init();
  }

  void _loadNotes() async {
    if (selectedStorage == StorageType.sqlite) {
      final notes = await sqliteController.getNotes();
      setState(() {
        _notes = notes;
      });
    } else if (selectedStorage == StorageType.hive) {
      final notes = await hiveController.getNotes();
      setState(() {
        _notes = notes;
      });
    }
  }

  void _addNote() async {
    if (_titleController.text.isEmpty || _descriptionController.text.isEmpty)
      return;

    final note = Note(
      title: _titleController.text,
      description: _descriptionController.text,
    );

    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.insert(note);
    } else if (selectedStorage == StorageType.hive) {
      hiveController.add(note);
    }

    _titleController.clear();
    _descriptionController.clear();

    _loadNotes();
  }

  void deleteNote(int? id) async {
    if (selectedStorage == StorageType.sqlite) {
      await sqliteController.delete(id);
    } else {
      hiveController.delete(id);
    }
    _loadNotes();
  }

  @override
  void initState() {
    super.initState();
    _initHive();
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFF3F4F6), 
      appBar: AppBar(
        title: Text('Notes'),
        titleTextStyle: TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
        backgroundColor: Color(0xFF006D77),
        centerTitle: true,
        elevation: 5,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(18), 
              ),
              elevation: 10,
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Create a Note",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF004D40), // Dark greenish teal
                      ),
                    ),
                    SizedBox(height: 18),
                    TextField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        labelText: 'Title',
                        labelStyle: TextStyle(color: Color(0xFF00796B)),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        labelText: 'Description',
                        labelStyle: TextStyle(color: Color(0xFF00796B)),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    SizedBox(height: 18),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: _addNote,
                            icon: Icon(Icons.add, color: Colors.white),
                            label: Text(
                              "Add Note",
                              style: TextStyle(color: Colors.white),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor:Color(0xFF006D77), 
                              padding: EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(width: 15),
                        DropdownButton<StorageType>(
                          value: selectedStorage,
                          items: [
                            DropdownMenuItem(
                              value: StorageType.sqlite,
                              child: Text('SQLite'),
                            ),
                            DropdownMenuItem(
                              value: StorageType.hive,
                              child: Text('Hive'),
                            ),
                          ],
                          onChanged: (value) {
                            setState(() {
                              selectedStorage = value!;
                            });
                            _loadNotes();
                          },
                        ),
                      ],
                    ),
                    SizedBox(height: 15),
                    ElevatedButton(
                      onPressed: () async {
                        hiveController.clear();
                        _loadNotes();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("All Hive notes cleared")),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color.fromARGB(255, 171, 182, 188), 
                        textStyle: TextStyle(color: Colors.white),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                      child: Text("Clear Hive Notes"),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _notes.isEmpty
                ? Center(
                    child: Text("No notes available", style: TextStyle(color: Color(0xFF004D40))))
                : ListView.builder(
                    itemCount: _notes.length,
                    itemBuilder: (context, index) {
                      final note = _notes[index];
                      return Card(
                        margin: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                        elevation: 8,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20), // Softer card edges
                        ),
                        child: ListTile(
                          title: Text(
                            note.title,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Color(0xFF004D40)), // Deep teal
                          ),
                          subtitle: Text(note.description),
                          trailing: IconButton(
                            color: Colors.red,
                            icon: Icon(Icons.delete),
                            onPressed: () {
                              if (selectedStorage == StorageType.hive) {
                                deleteNote(index);
                              } else {
                                deleteNote(note.id);
                              }
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

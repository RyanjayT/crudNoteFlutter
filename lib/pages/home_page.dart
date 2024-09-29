import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crud/services/firestore.dart';
import 'package:flutter/material.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // firestore
  final FirestoreService firestoreService = FirestoreService();

  // text controller
  final TextEditingController textController = TextEditingController();

  // open a dialog box
  void openNoteBox({String? docID}) {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              content: TextField(
                controller: textController,
              ),
              actions: [
                //button to save
                ElevatedButton(
                    onPressed: () => {
                          // add new Note
                          if (docID == null)
                            {firestoreService.addNote(textController.text)}
                          // else update an existing note
                          else
                            {
                              firestoreService.updateNote(
                                  docID, textController.text)
                            },
                          textController.clear(),
                          Navigator.pop(context)
                        },
                    child: Text("Add")),
              ],
            ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Center(
            child: Text(
              "Notes App",
              style: TextStyle(color: Colors.white),
            ),
          ),
          backgroundColor: const Color.fromARGB(255, 51, 51, 51),
          elevation: 50,
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: const Color.fromARGB(255, 66, 66, 66),
          onPressed: openNoteBox,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(50),
            ),
            child: Icon(
              Icons.add,
              color: Colors.white,
            ),
          ),
        ),
        body: StreamBuilder<QuerySnapshot>(
          stream: firestoreService.getNotesSteam(),
          builder: (context, snapshot) {
            // if we have data, get all the docs
            if (snapshot.hasData) {
              List notesList = snapshot.data!.docs;
              //display as a list view
              return ListView.builder(
                itemCount: notesList.length,
                itemBuilder: (context, index) {
                  // get the individual document
                  DocumentSnapshot document = notesList[index];
                  String docID = document.id;
                  // get note from each document
                  Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                  String noteText = data['note'];
                  // display as a list tile
                  return ListTile(
                      title: Text(noteText),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // update button
                          IconButton(
                            onPressed: () => openNoteBox(docID: docID),
                            icon: Icon(Icons.settings),
                          ),
                          IconButton(
                            onPressed: () => firestoreService.deleteNote(docID),
                            icon: Icon(Icons.delete),
                          ),
                        ],
                      ));
                },
              );
            }
            // if no data just return no notes
            else {
              return const Text("No Notes...");
            }
          },
        ));
  }
}

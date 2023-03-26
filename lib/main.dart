import 'dart:ffi';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:confess/chatscreen.dart';
import 'package:confess/writeconf.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Confess',

      //home: const MyHomePage(title: 'Flutter Demo Home Page'),
      home: ChatRoomScreen(),
    );
  }
}

class ChatRoomScreen extends StatefulWidget {
  @override
  _ChatRoomScreenState createState() => _ChatRoomScreenState();
}

class _ChatRoomScreenState extends State<ChatRoomScreen> {
  TextEditingController _roomIdController = TextEditingController();
  TextEditingController _chatRoomNameController = TextEditingController();

  List<String> _myList = [];

  @override
  void initState() {
    super.initState();
    _loadList();
  }

  Future<void> _loadList() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _myList = prefs.getStringList('myList') ?? [];
    });
  }

  Future<void> _addToList(String value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      _myList.add(value);
      prefs.setStringList('myList', _myList);
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight =
        screenHeight * 0.1; // set container height to 50% of screen height
    double screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.deepPurpleAccent,
        title: Text(
          'Confess Room',
          style: TextStyle(fontSize: 25),
        ),
        actions: [
          IconButton(
            icon: Icon(
              size: 30,
              Icons.add_circle_outline_outlined,
              color: Colors.white,
            ),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text('Join or create Chat room'),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            // logic for creating a chat room
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Create Chat Room'),
                                  content: TextField(
                                    controller: _chatRoomNameController,
                                    decoration: InputDecoration(
                                        hintText: 'Enter Chat Room Name'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () async {
                                        //creation of the new subcollectiion
                                        String value =
                                            _chatRoomNameController.text;
                                        print(
                                            "-------------------------------------------------------------------------------------------");
                                        createDocument('newcon', value);
                                        _addToList(value);
                                        Navigator.of(context).pop();
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Create'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Create Chat Room'),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  title: Text('Join Chat Room'),
                                  content: TextField(
                                    controller: _roomIdController,
                                    decoration: InputDecoration(
                                        hintText: 'Enter Room ID'),
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Cancel'),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        String roomId = _roomIdController.text;
                                        // logic for joining a chat room using the roomId
                                        String subcoll = '${roomId}_sub';
                                        // checkDocumentId('newcon', roomId);
                                        joinSubcollection(
                                            'newcon', roomId, subcoll);
                                        _addToList(roomId);
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Join'),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          child: Text('Join Chat Room'),
                        ),
                      ],
                    ),
                  );
                },
              );
              // do something
            },
          ),
          PopupMenuButton(
            onSelected: (value) async {
              if (value == 'delete') {
                SharedPreferences prefs = await SharedPreferences.getInstance();
                prefs.clear();
                // reload your widget or update the UI to reflect the changes
              }
            },
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  padding: EdgeInsets.fromLTRB(25, 2, 5, 2),
                  height: 40,
                  value: 'delete',
                  child: Text(
                    'Delete Room',
                    textAlign: TextAlign.end,
                    style: TextStyle(
                        fontSize: 20,
                        color: Colors.purple,
                        fontWeight: FontWeight.w500),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
      body: Container(
        constraints: BoxConstraints.expand(),
        decoration: BoxDecoration(
            image: DecorationImage(
                //color: const Color.fromARGB(255, 234, 229, 229),
                opacity: 0.35,
                image: AssetImage("background_chatscreen.jpg"),
                fit: BoxFit.cover)),
        child: Column(
          children: [
            SizedBox(
              height: 20,
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
                child: ListView.builder(
                  itemCount: _myList.length,
                  itemBuilder: (BuildContext context, int index) {
                    return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: GestureDetector(
                            onTap: () {
                              String message = _myList[
                                  index]; // Replace with the message you want to pass
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        ChatScreen(message: message)),
                              );
                            },
                            child: Center(
                              child: Container(
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        10.0), // set border radius as per your requirement
                                    color: Color.fromARGB(255, 125, 82,
                                        242) // set the background color of the container
                                    ),
                                padding: EdgeInsets.all(8),
                                height: containerHeight * 0.9,
                                width: screenWidth,
                                //color: Colors.purple,
                                child: Center(
                                  child: Text(
                                    _myList[index],
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 24.0,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    softWrap: true,
                                  ),
                                ),
                              ),
                            )));
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void createDocument(String collectionName, String docname) {
  // Get the Firestore instance
  print(
      "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++");
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  print(docname);
  // Create a new document reference in the specified collection
  DocumentReference documentReference =
      firestore.collection(collectionName).doc(docname);

  // Set the data for the new document

  //documentReference.set(data);
  String sub = '${docname}_sub';
  createSubcollection(collectionName, docname, sub);
}

void createSubcollection(
    String collectionName, String documentId, String subcollectionName) async {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  CollectionReference subcollectionReference = firestore
      .collection(collectionName)
      .doc(documentId)
      .collection(subcollectionName);
  await subcollectionReference.add({'message': 'hellooooo bro'});
}

void joinSubcollection(
    String collectionName, String documentId, String subcollectionName) {
  CollectionReference mySubcollectionRef = FirebaseFirestore.instance
      .collection(collectionName)
      .doc(documentId)
      .collection(subcollectionName);
}

Future<bool> checkDocumentId(String collectionName, String documentId) async {
  DocumentSnapshot snapshot = await FirebaseFirestore.instance
      .collection(collectionName)
      .doc(documentId)
      .get();
  return snapshot.exists;
}

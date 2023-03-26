import 'dart:convert';

import 'package:confess/writeconf.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class ChatScreen extends StatefulWidget {
  final String message;
  const ChatScreen({Key? key, required this.message}) : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  Future<void> _showMessageNotification(String title, String body) async {
    const AndroidNotificationChannel channel = AndroidNotificationChannel(
      'message_notification_channel', // Channel ID
      'New Message', // Channel name
      //'Notification for a new message', // Channel description
      importance: Importance.high,
    );
    final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
        FlutterLocalNotificationsPlugin();
    await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(channel);

    final AndroidNotificationDetails notificationDetails =
        AndroidNotificationDetails(
      channel.id, // Channel ID
      channel.name, // Channel name
      //channel.description, // Channel description
      importance: channel.importance,
    );
    final NotificationDetails platformChannelSpecifics =
        NotificationDetails(android: notificationDetails);

    await flutterLocalNotificationsPlugin.show(
      0, // Notification ID
      title, // Notification title
      body, // Notification body
      platformChannelSpecifics,
    );
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double containerHeight =
        screenHeight * 0.075; // set container height to 50% of screen height
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.83;
    final TextEditingController _messageController = TextEditingController();
    final CollectionReference _messagesCollection =
        FirebaseFirestore.instance.collection(widget.message);
    String mssg = widget.message;
    String _message = '';
    return Container(
      constraints: BoxConstraints.expand(),
      decoration: BoxDecoration(
          image: DecorationImage(
              image: AssetImage("background_chatscreen.jpg"),
              fit: BoxFit.cover)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.deepPurpleAccent,
          toolbarHeight: 70,
          title: const Text('Just Confess',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 23.0,
                  fontWeight: FontWeight.bold)),
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
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Container(
                  padding: const EdgeInsets.fromLTRB(4, 12, 4, 6),
                  //height: 300,
                  child: StreamBuilder<QuerySnapshot>(
                    stream:
                        _messagesCollection.orderBy('timestamp').snapshots(),
                    builder: (BuildContext context,
                        AsyncSnapshot<QuerySnapshot> snapshot) {
                      if (snapshot.hasError) {
                        return Text("Error: ${snapshot.error}");
                      }
                      if (snapshot.hasData && snapshot.data != null) {
                        return ListView(
                          //physics: const AlwaysScrollableScrollPhysics(),
                          shrinkWrap: true,
                          //reverse: true,
                          children: snapshot.data!.docs
                              .map((DocumentSnapshot document) {
                            Map<String, dynamic> data =
                                document.data() as Map<String, dynamic>;
                            _showMessageNotification(
                                widget.message, data['text']);
                            return Padding(
                              padding: const EdgeInsets.all(2.0),
                              child: Center(
                                  child: Flexible(
                                child: SizedBox(
                                  child: Card(
                                    surfaceTintColor: Colors.deepPurpleAccent,
                                    shadowColor: Colors.deepPurpleAccent,
                                    borderOnForeground: true,
                                    color: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(7.0),
                                    ),
                                    elevation: 4.0,
                                    child: ListTile(
                                      title: Padding(
                                        padding: const EdgeInsets.fromLTRB(
                                            2, 8, 2, 8),
                                        child: Flexible(
                                          child: Text(
                                            data['text'],
                                            style: const TextStyle(
                                                fontSize: 17.0,
                                                color: Colors.deepPurpleAccent,
                                                fontWeight: FontWeight.bold),
                                          ),
                                        ),
                                      ),
                                      // subtitle: Text(data['timestamp'].toString()),
                                    ),
                                  ),
                                ),
                              )),
                            );
                          }).toList(),
                        );
                      } else
                        return Center(
                            child: Image(
                          image: AssetImage("loading.gif"),
                          width: 50,
                          height: 50,
                        ));
                    },
                  ),
                ),
              ),

              //color: Color.fromARGB(255, 245, 225, 248),
              Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(8, 4, 3, 4),
                    child: Container(
                      width: containerWidth,
                      height: containerHeight,
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(6.0),
                        child: TextField(
                          //autofocus: true,
                          cursorHeight: 28,
                          cursorColor: Colors.white,
                          //expands: false,
                          enableInteractiveSelection: true,
                          maxLines: 1,
                          controller: _messageController,
                          decoration: InputDecoration(
                            hintText: ' Type your message',
                            hintStyle:
                                TextStyle(color: Colors.white.withOpacity(0.8)),
                            border: InputBorder.none,
                          ),
                          style: const TextStyle(
                              color: Colors.white, fontSize: 20),
                          onChanged: (value) {
                            _message = value;
                          },
                        ),
                      ),
                    ),
                  ),
                  InkWell(
                    onTap: () async {
                      if (_message.isNotEmpty) {
                        await _messagesCollection.add({
                          'text': _message,
                          'timestamp': FieldValue.serverTimestamp(),
                        });
                        setState(() {
                          _messageController.clear();
                          _message = '';
                        });
                      }
                    },
                    child: Container(
                      width: containerHeight * 0.85,
                      height: containerHeight,
                      decoration: BoxDecoration(
                        color: Colors.deepPurpleAccent,
                        borderRadius: BorderRadius.circular(11.0),
                        shape: BoxShape.rectangle,
                      ),
                      child: const Icon(
                        Icons.send,
                        color: Colors.white,
                        size: 35.0,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

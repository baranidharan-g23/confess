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
    final TextEditingController _messageController = TextEditingController();
    final CollectionReference _messagesCollection =
    FirebaseFirestore.instance.collection(widget.message);
    String mssg = widget.message;
    String _message = '';
    return Scaffold(
      appBar: AppBar(
        toolbarHeight: 70,
        title: Text('Just Confess',style: TextStyle(color: Colors.white,fontSize: 23.0,fontWeight: FontWeight.bold)),
        backgroundColor: Colors.deepOrangeAccent,
      ),

      body:
      Container(
        color: Colors.grey,
        child: Column(
          children: [
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _messagesCollection.orderBy('timestamp').snapshots(),
                builder:
                    (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.hasError) {
                    return Text("Error: ${snapshot.error}");
                  }

                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Text("Loading...");
                  }

                  return ListView(
                    children: snapshot.data!.docs.map((DocumentSnapshot document) {
                      Map<String, dynamic> data =
                      document.data() as Map<String, dynamic>;
                      _showMessageNotification(widget.message,data['text']);
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Center(
                            child:
                            Card(
                              color: Colors.white70,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),),
                              elevation: 3.0,
                              child: Column(
                                children: [
                                  ListTile(
                                    title: Text(data['text'],style: TextStyle(fontSize: 15.0,fontWeight: FontWeight.bold),),
                                    // subtitle: Text(data['timestamp'].toString()),
                                  ),
                                  // ListTile(
                                  //   subtitle: Text(data['timestamp'].toString()),
                                  // ),
                                ],
                              ),
                            )
                        ),
                      );
                    }).toList(),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: SizedBox(
                height: 50.0,
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.deepPurple,
                  ),
                  child: const Text('Write Confession',style: TextStyle(fontSize: 22.0),),
                  onPressed: () {
                    // Navigate to second route when tapped.
                    String newmsg = widget.message;
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => writeText(message: newmsg)),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}



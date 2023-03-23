import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

// class WriteConf extends StatefulWidget {
//   const WriteConf({Key? key, required String message}) : super(key: key);
//
//   @override
//   State<WriteConf> createState() => _WriteConfState();
// }
//
// class _WriteConfState extends State<WriteConf> {
//
//
//   @override
//   Widget build(BuildContext context) {
//     return writeText(mesg:mes);
//
//   }
// }

class writeText extends StatefulWidget {
  final String message;
  const writeText({Key? key, required this.message}) : super(key: key);



  @override
  State<writeText> createState() => _writeTextState();
}

class _writeTextState extends State<writeText> {
 

  @override


    // print('My message is: ${widget.message}');
    // // Add your logic here




  Widget build(BuildContext context) {
    final TextEditingController _messageController = TextEditingController();
    final CollectionReference _messagesCollection =
    FirebaseFirestore.instance.collection(widget.message);

    String _message = '';
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18.0, 150.0, 18.0, 130.0),
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.0),
                child: Card(
                  child: TextField(
                    maxLines: 15,
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message',
                    ),
                    onChanged: (value) {
                      _message = value;
                    },
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 150
            ),
            SizedBox(
              width: 125.0,
              height: 50.0,
              child: ElevatedButton(
                child: Text("Send"),
                onPressed: () async {
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}


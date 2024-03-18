import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({Key? key}) : super(key: key);

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  String? userid;
  @override
  Widget build(BuildContext context) {
    var stream = FirebaseFirestore.instance
        .collection('history')
        .doc(userid!)
        .collection('text_of_first_prompt_asked')
        .doc('hello')
        .collection('bot_responses')
        .snapshots();

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(30.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            StreamBuilder(
              stream: stream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot<Map<String, dynamic>>> snapshot) {
                if (snapshot.hasError) {
                  print('Error: ${snapshot.error}');
                  return Text('Error: ${snapshot.error}A');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator();
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return Text('No data available');
                }

                // Now you can use the data from the snapshot
                // For example, printing the data from each document in the subcollection
                var documents = snapshot.data!.docs;
                for (var document in documents) {
                  var documentData = document.data();
                  print(documentData);
                }

                return Text("Snapshot has data");
              },
            ),
          ],
        ),
      ),
    );
  }
}

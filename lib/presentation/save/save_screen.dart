import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../home_answer_generated_screen/home_answer_generated_screen.dart';

class SaveScreen extends StatefulWidget {
  SaveScreen({Key? key}) : super(key: key);

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  List<Message> messages = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ScrollController _scrollController = ScrollController();
  bool isSendingMessage = false;
  User? currentUser;
  String? userId;

  Future<List<Message>> loadMessages() async {
    try {
      List<Message> userMessages = await getUserMessages();
      List<Message> botResponses = await getBotResponses();

      // Sort user messages and bot responses by timestamp
      userMessages.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      botResponses.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      List<Message> combinedMessages = [];

      int userIndex = 0, botIndex = 0;

      while (
          userIndex < userMessages.length || botIndex < botResponses.length) {
        if (userIndex < userMessages.length) {
          combinedMessages.add(userMessages[userIndex]);
          userIndex++;
        }

        if (botIndex < botResponses.length) {
          combinedMessages.add(botResponses[botIndex]);
          botIndex++;
        }
      }

      return combinedMessages;
    } catch (e) {
      print('Error loading messages: $e');
      return [];
    }
  }

  @override
  void initState() {
    currentUser = _auth.currentUser;
    userId = currentUser?.email;
    loadMessages().then((loadedMessages) {
      setState(() {
        messages = loadedMessages;
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'User Message History:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () => clearHistory(),
                    child: Text("Clear History"),
                  ),
                ],
              ),
              SizedBox(height: 10),
              SizedBox(height: 10),
              Expanded(
                child: messages.isEmpty
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : ListView.builder(
                        itemCount: messages.length,
                        itemBuilder: (context, index) {
                          Message message = messages[index];
                          return ListTile(
                            title: Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10),
                                    color: Colors.white),
                                child: Text(message.text)),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<Message>> getUserMessages() async {
    try {
      if (userId != null) {
        // Retrieve user messages and bot responses
        QuerySnapshot<Map<String, dynamic>> documentsSnapshot =
            await FirebaseFirestore.instance
                .collection('messages')
                .doc(userId)
                .collection('user_responses')
                .get();

        List<Message> messages = [];

        for (QueryDocumentSnapshot<Map<String, dynamic>> document
            in documentsSnapshot.docs) {
          List<dynamic> messagesData = document.data()!['messages'];

          // Map messagesData to Message objects
          List<Message> documentMessages = messagesData
              .map((data) => Message(
                    text: data['text'],
                    sender: data['sender'],
                    timestamp: data['timestamp'],
                  ))
              .toList();

          // Add the messages to the overall list
          messages.addAll(documentMessages);
        }

        // Sort messages by timestamp
        messages.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return messages;
      } else {
        print('User ID is null');
        return [];
      }
    } catch (e) {
      print('Error getting user messages: $e');
      return [];
    }
  }

  Future<List<Message>> getBotResponses() async {
    try {
      if (userId != null) {
        // Retrieve bot responses
        CollectionReference<Map<String, dynamic>> botResponsesCollectionRef =
            FirebaseFirestore.instance
                .collection('messages')
                .doc(userId)
                .collection('bot_responses');

        QuerySnapshot<Map<String, dynamic>> botResponsesSnapshot =
            await botResponsesCollectionRef.get();

        List<Message> botResponses = [];

        // Add bot responses to the list
        botResponsesSnapshot.docs.forEach((botResponseDoc) {
          List<dynamic> messagesData = botResponseDoc.data()!['messages'];

          // Map messagesData to Message objects
          List<Message> documentMessages = messagesData
              .map((data) => Message(
                    text: data['text'],
                    sender: data['sender'],
                    timestamp: data['timestamp'],
                  ))
              .toList();

          // Add the messages to the overall list
          botResponses.addAll(documentMessages);
        });

        // Sort messages by timestamp
        botResponses.sort((a, b) => a.timestamp.compareTo(b.timestamp));

        return botResponses;
      } else {
        print('User ID is null');
        return [];
      }
    } catch (e) {
      print('Error getting bot responses: $e');
      return [];
    }
  }

  // Function to clear message history
  void clearHistory() async {
    try {
      if (userId != null) {
        // Clear user messages
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(userId)
            .collection('user_responses')
            .get()
            .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        });

        // Clear bot responses
        await FirebaseFirestore.instance
            .collection('messages')
            .doc(userId)
            .collection('bot_responses')
            .get()
            .then((snapshot) {
          for (DocumentSnapshot ds in snapshot.docs) {
            ds.reference.delete();
          }
        });

        // Reload messages after clearing
        loadMessages().then((loadedMessages) {
          setState(() {
            messages = loadedMessages;
          });
        });
      }
    } catch (e) {
      print('Error clearing history: $e');
    }
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class SaveScreen extends StatefulWidget {
  const SaveScreen({Key? key}) : super(key: key);

  @override
  State<SaveScreen> createState() => _SaveScreenState();
}

class _SaveScreenState extends State<SaveScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Chat History"),
      ),
      body: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('histroy')
            .doc('hafeezullah7008@gmail.com') // Replace with actual user ID
            .collection('text_of_first_prompt_asked')
            .snapshots(),
        builder: (BuildContext context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildShimmerEffect(); // Show shimmer effect while loading
          }
          if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Text('No chat history found.'),
            );
          }

          // Convert Firestore documents to list of maps
          List<Map<String, String>> chatHistory =
              snapshot.data!.docs.map<Map<String, String>>((doc) {
            final dynamic messages = doc['messages'];
            final String text = messages.isNotEmpty ? messages[0]['text'] : '';
            final Timestamp timestamp = messages.isNotEmpty
                ? messages[0]['timestamp']
                : Timestamp.now();
            return {
              "sender": "User", // Assuming prompt is from user
              "message": text, // Get first message
              "timestamp": _formatDate(timestamp),
              "docID": doc.id, // Add document ID for deletion
            };
          }).toList();

          // Group chat history by date
          Map<String, List<Map<String, String>>> groupedHistory =
              _groupChatHistoryByDate(chatHistory);

          return ListView.builder(
            itemCount: groupedHistory.length,
            itemBuilder: (BuildContext context, int index) {
              String date = groupedHistory.keys.elementAt(index);
              List<Map<String, String>> messages = groupedHistory[date]!;
              return _buildExpansionTile(date, messages);
            },
          );
        },
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5, // Adjust the number of shimmer items as needed
      itemBuilder: (context, index) {
        return Shimmer.fromColors(
          baseColor: Colors.grey[300]!,
          highlightColor: Colors.grey[100]!,
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: Colors.grey[300],
              radius: 25.0,
            ),
            title: Container(
              height: 16.0,
              color: Colors.grey[300],
            ),
            subtitle: Container(
              height: 16.0,
              color: Colors.grey[300],
            ),
          ),
        );
      },
    );
  }

  Widget _buildExpansionTile(String date, List<Map<String, String>> messages) {
    return ExpansionTile(
      title: Text(
        _formatDateHeader(date),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 18.0,
        ),
      ),
      children: messages.map((message) {
        return Dismissible(
          key: Key(message["timestamp"]!),
          direction: DismissDirection.endToStart,
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerRight,
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
          onDismissed: (direction) async {
            // Delete the item from Firestore
            await FirebaseFirestore.instance
                .collection('histroy')
                .doc('hafeezullah7008@gmail.com')
                .collection('text_of_first_prompt_asked')
                .doc(message["docID"])
                .delete();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Chat history deleted")),
            );
          },
          child: _buildChatItem(message),
        );
      }).toList(),
    );
  }

  Widget _buildChatItem(Map<String, String> message) {
    final bool isUser = message["sender"] == "User";

    return Container(
      margin: EdgeInsets.symmetric(vertical: 8.0),
      padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        decoration: BoxDecoration(
          color: isUser ? Colors.grey.withOpacity(0.5) : Colors.grey[200],
          borderRadius: BorderRadius.circular(16.0),
        ),
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment:
              isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  message["timestamp"]!,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                    color: Colors.grey,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    // Implement action on icon press
                  },
                  icon: Icon(
                    Icons.favorite_border,
                  ),
                ),
              ],
            ),
            SizedBox(height: 4.0),
            Text(
              message["message"]!,
              style: TextStyle(
                fontSize: 16.0,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Group chat history by date
  Map<String, List<Map<String, String>>> _groupChatHistoryByDate(
      List<Map<String, String>> chatHistory) {
    Map<String, List<Map<String, String>>> groupedHistory = {};
    chatHistory.forEach((message) {
      DateTime dateTime = DateTime.parse(message["timestamp"]!);
      String date = "${dateTime.year}-${dateTime.month}-${dateTime.day}";
      if (!groupedHistory.containsKey(date)) {
        groupedHistory[date] = [];
      }
      groupedHistory[date]!.add(message);
    });
    return groupedHistory;
  }

  // Format date for display
  String _formatDate(Timestamp timestamp) {
    // Convert Firestore Timestamp to DateTime
    DateTime dateTime = timestamp.toDate();

    // Convert DateTime to a string representation
    return dateTime.toString();
  }

  // Format date header for display
  String _formatDateHeader(String date) {
    List<String> parts = date.split('-');
    if (parts.length == 3) {
      // Ensure leading zero for month and day if needed
      String month = parts[1].padLeft(2, '0');
      String day = parts[2].padLeft(2, '0');
      DateTime dateTime =
          DateTime(int.parse(parts[0]), int.parse(month), int.parse(day));
      return DateFormat.yMMMd().format(dateTime);
    }
    // Return original date if not properly formatted
    return date;
  }
}

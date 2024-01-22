import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:talk_ai/core/app_export.dart';
import 'package:talk_ai/widgets/app_bar/appbar_leading_image.dart';
import 'package:talk_ai/widgets/app_bar/appbar_trailing_image.dart';
import 'package:talk_ai/widgets/app_bar/custom_app_bar.dart';
import 'package:talk_ai/widgets/custom_icon_button.dart';
import 'package:talk_ai/widgets/custom_text_form_field.dart';

class Message {
  String text;
  String sender; // 'user' or 'bot'
  Timestamp timestamp;

  Message({
    required this.text,
    required this.sender,
    required this.timestamp,
  });

  // New method to convert Message to a Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'text': text,
      'sender': sender,
      'timestamp': timestamp,
    };
  }

  // New constructor to create a Message from Firestore document
  factory Message.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    Map<String, dynamic> data = doc.data()!;
    Timestamp? timestamp = data['timestamp'] as Timestamp?;
    return Message(
      text: data['text'],
      sender: data['sender'],
      timestamp: timestamp ?? Timestamp.now(),
    );
  }
}

class HomeAnswerGeneratedScreen extends StatefulWidget {
  HomeAnswerGeneratedScreen({Key? key}) : super(key: key);

  @override
  _HomeAnswerGeneratedScreenState createState() =>
      _HomeAnswerGeneratedScreenState();
}

class _HomeAnswerGeneratedScreenState extends State<HomeAnswerGeneratedScreen> {
  TextEditingController askMeAnythingController = TextEditingController();
  List<Message> messages = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;
  ScrollController _scrollController = ScrollController();
  bool isSendingMessage = false;
  User? currentUser;
  String? userId;

  @override
  @override
  void initState() {
    currentUser = _auth.currentUser;
    userId = currentUser?.email;
    _scrollController = ScrollController();
    // Load user messages and bot responses together

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        // appBar: _buildAppBar(context),
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(
            horizontal: 20.h,
            vertical: 16.v,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildChatBubbleReceived(context),
              SizedBox(
                height: 20,
              ),
              _buildButton(context),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 52.h,
      leading: AppbarLeadingImage(
        imagePath: ImageConstant.imgMegaphone,
        margin: EdgeInsets.only(
          left: 20.h,
          top: 8.v,
          bottom: 8.v,
        ),
      ),
      actions: [
        AppbarTrailingImage(
          imagePath: ImageConstant.imgHugeIconUser,
          margin: EdgeInsets.symmetric(
            horizontal: 20.h,
            vertical: 8.v,
          ),
        ),
      ],
    );
  }

  Widget _buildChatBubbleReceived(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        controller: _scrollController,
        shrinkWrap: true,
        itemCount: messages.length,
        itemBuilder: (context, index) {
          Message message = messages[index];
          if (message.sender == 'bot') {
            return _buildBotMessageBubble(message.text);
          } else {
            return _buildUserMessageBubble(message.text);
          }
        },
      ),
    );
  }

  Widget _buildBotMessageBubble(String text) {
    return Column(
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.symmetric(
            horizontal: 4.h,
            vertical: 11.v,
          ),
          decoration: AppDecoration.fillOnPrimaryContainer.copyWith(
            borderRadius: BorderRadiusStyle.customBorderTL12,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 309.h,
                margin: EdgeInsets.only(
                  left: 8.h,
                  right: 9.h,
                ),
                child: Text(
                  text,
                  maxLines: 7,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: theme.colorScheme.onPrimary,
                    fontSize: 17.fSize,
                    fontFamily: 'Rubik',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              SizedBox(height: 13.v),
              Divider(
                indent: 8.h,
              ),
              SizedBox(height: 16.v),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.h),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CustomImageView(
                      imagePath: ImageConstant.imgIconOutlineLike,
                      height: 24.adaptSize,
                      width: 24.adaptSize,
                    ),
                    CustomImageView(
                      imagePath: ImageConstant.imgIconOutlineDislike,
                      height: 24.adaptSize,
                      width: 24.adaptSize,
                      margin: EdgeInsets.only(left: 12.h),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => _copyToClipboard(text),
                      child: Row(
                        children: [
                          CustomImageView(
                            imagePath: ImageConstant.imgThumbsUp,
                            height: 20.adaptSize,
                            width: 20.adaptSize,
                            margin: EdgeInsets.only(bottom: 2.v),
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              left: 5.h,
                              top: 3.v,
                            ),
                            child: Text(
                              "Copy",
                              style: TextStyle(
                                color: theme.colorScheme.primary,
                                fontSize: 17.fSize,
                                fontFamily: 'Rubik',
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUserMessageBubble(String text) {
    return user_message(text);
  }

  Widget user_message(String text) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
        ),
        Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
              color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Text(text),
        ),
      ],
    );
  }

  Widget _buildButton(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: CustomTextFormField(
            controller: askMeAnythingController,
            hintText: "Ask me anything...",
            textInputAction: TextInputAction.done,
            enabled: !isSendingMessage,
            suffix: GestureDetector(
              onTap: () {
                if (!isSendingMessage) {
                  _sendMessageToRasa();
                }
              },
              child: Container(
                margin: EdgeInsets.fromLTRB(30.h, 14.v, 16.h, 14.v),
                child: isSendingMessage
                    ? CircularProgressIndicator() // Show loading indicator
                    : CustomImageView(
                        imagePath: ImageConstant.imgIconFillMessagesend,
                        height: 32.adaptSize,
                        width: 32.adaptSize,
                      ),
              ),
            ),
            suffixConstraints: BoxConstraints(
              maxHeight: 60.v,
            ),
            contentPadding: EdgeInsets.only(
              left: 16.h,
              top: 19.v,
              bottom: 19.v,
            ),
          ),
        ),
        Padding(
          padding: EdgeInsets.only(left: 8.h),
          child: CustomIconButton(
            onTap: () => _reloadResponse(),
            decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white)),
            height: 60.adaptSize,
            width: 60.adaptSize,
            padding: EdgeInsets.all(12.h),
            child: CustomImageView(
              imagePath: ImageConstant.imgIconFillReload,
            ),
          ),
        ),
      ],
    );
  }

  void _sendMessageToRasa({String? message}) async {
    // Replace this with the actual URL of your Rasa API.
    String rasaApiUrl = 'http://192.168.100.13:5005/webhooks/rest/webhook';

    // Get the message from the text field
    String userMessage = message ?? askMeAnythingController.text;

    Message content = Message(
      text: userMessage,
      sender: 'user',
      timestamp: Timestamp.now(),
    );
    // Add user's message to the messages list
    messages.add(content);

    await storeUserMessage(content, userId!);
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );

    // Prepare the data to be sent to Rasa
    Map<String, dynamic> requestData = {
      "sender": "user",
      "message": userMessage,
    };

    try {
      // Send a POST request to the Rasa API.
      http.Response response = await http.post(
        Uri.parse(rasaApiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      // Check if the request was successful (status code 200).
      if (response.statusCode == 200) {
        // Parse the JSON response.
        List<dynamic> jsonResponse = jsonDecode(response.body);

        // Map each JSON object to a Message object and add it to the messages list.
        List<Message> botResponses = jsonResponse
            .map((json) => Message(
                  text: json['text'],
                  sender: 'bot',
                  timestamp: Timestamp.now(),
                ))
            .toList();

        // Add bot responses to the messages list
        messages.addAll(botResponses);
        await storeBotResponses(botResponses, userId!);
        // Clear the text field after sending the message.
        askMeAnythingController.clear();

        // Force a rebuild of the UI to reflect the updated messages list.
        setState(() {});
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  void _reloadResponse() {
    // Find the last user message in the messages list
    Message lastUserMessage = messages.lastWhere(
      (message) => message.sender == 'user',
      orElse: () => Message(
        text: "",
        sender: 'user',
        timestamp: Timestamp.now(),
      ),
    );

    // Get the text of the last user message
    String userMessage = lastUserMessage.text;

    // Resend the last user message to the Rasa API
    if (userMessage.isNotEmpty) {
      _sendMessageToRasa(message: userMessage);
    }
  }

  Future<void> storeUserMessage(Message message, String userId) async {
    try {
      if (userId != null) {
        // Check if a document with the title already exists in bot_responses
        CollectionReference<Map<String, dynamic>> collectionRef =
            FirebaseFirestore.instance
                .collection('messages')
                .doc(userId)
                .collection('user_responses');
        DocumentReference<Map<String, dynamic>> documentRef =
            collectionRef.doc(message.text);

        // Get the document snapshot
        DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
            await documentRef.get();

        if (documentSnapshot.exists) {
          // If the document exists, update the list of messages
          await documentRef.update({
            'messages': FieldValue.arrayUnion([message.toMap()])
          });
        } else {
          // If the document doesn't exist, create a new one with the title and the first message
          await documentRef.set({
            'title': message.text,
            'messages': [message.toMap()],
          });
        }
      } else {
        print('User ID is null');
      }
    } catch (e) {
      print('Error storing user message: $e');
    }
  }

  Future<void> storeBotResponses(List<Message> messages, String userId) async {
    try {
      if (userId != null) {
        // Loop through each bot response and store it individually
        for (Message message in messages) {
          // Check if a document with the title already exists in bot_responses
          CollectionReference<Map<String, dynamic>> collectionRef =
              FirebaseFirestore.instance
                  .collection('messages')
                  .doc(userId)
                  .collection(
                      'bot_responses'); // Use 'bot_responses' for bot messages
          DocumentReference<Map<String, dynamic>> documentRef =
              collectionRef.doc(message.text);

          // Get the document snapshot
          DocumentSnapshot<Map<String, dynamic>> documentSnapshot =
              await documentRef.get();

          if (documentSnapshot.exists) {
            // If the document exists, update the list of messages
            await documentRef.update({
              'messages': FieldValue.arrayUnion([message.toMap()])
            });
          } else {
            // If the document doesn't exist, create a new one with the title and the first message
            await documentRef.set({
              'title': message.text,
              'messages': [message.toMap()],
            });
          }
        }
      } else {
        print('User ID is null');
      }
    } catch (e) {
      print('Error storing bot responses: $e');
    }
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }
}

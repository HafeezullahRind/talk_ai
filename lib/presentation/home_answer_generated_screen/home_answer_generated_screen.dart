import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:talk_ai/core/app_export.dart';
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
  String _currentPromptText = ''; // Added to store the current prompt text
  FlutterTts flutterTts = FlutterTts();
  stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _speechEnabled = false;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    userId = currentUser?.email;
    _scrollController = ScrollController();
    _getStoredFirstPrompt();
    _initSpeech();
  }

  void _initSpeech() async {
    _speechEnabled = await _speech.initialize();
    setState(() {});
  }

  void _getStoredFirstPrompt() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? storedPrompt = prefs.getString('firstPrompt');

    if (storedPrompt != null && storedPrompt.isNotEmpty) {
      setState(() {
        _currentPromptText = storedPrompt;
      });
    } else {
      _currentPromptText = "Default Prompt";
      _saveFirstPrompt(_currentPromptText);
    }
  }

  void _saveFirstPrompt(String prompt) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('firstPrompt', prompt);
  }

  void _listen() async {
    if (!_isListening) {
      // Check if the speech recognition engine is already initialized
      if (!_speech.isAvailable) {
        // Initialize the speech recognition engine if it's not available
        bool available = await _speech.initialize(
          onStatus: (val) => setState(() => _isListening = val == 'listening'),
          onError: (val) => print('onError: $val'),
        );

        if (!available) {
          // Handle case where initialization failed
          print('Speech recognition initialization failed');
          return;
        }
      }

      // Set _isListening to true to indicate that the engine is listening
      setState(() => _isListening = true);

      // Start listening for speech input
      _speech.listen(
        onResult: (val) => setState(() {
          askMeAnythingController.text = val.recognizedWords;
          if (val.finalResult) {
            _sendMessageToRasa();
          }
        }),
      );
    } else {
      // If the engine is already listening, stop it
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _speak(String text) async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.setPitch(1.0);
    await flutterTts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset:
            true, // Set to true to avoid keyboard covering the text field
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
              Row(
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
                  SizedBox(
                    width: 12.h,
                  ), // Add space between copy button and listen button
                  GestureDetector(
                    onTap: () {
                      _speak(
                          text); // Speak bot response when Listen button is tapped
                    },
                    child: Row(
                      children: [
                        Icon(
                          Icons.volume_up,
                          color: theme.colorScheme.primary,
                          size: 24,
                        ),
                        SizedBox(
                          width: 10,
                        )
                      ],
                    ),
                  ),
                ],
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
                  _getStoredFirstPrompt();
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
            onTap: () => _listen(), // Add listen functionality
            decoration: BoxDecoration(
                color: Colors.white10,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white)),
            height: 60.adaptSize,
            width: 60.adaptSize,
            padding: EdgeInsets.all(12.h),
            child: _isListening
                ? CircularProgressIndicator() // Show recording indicator
                : Icon(Icons.mic),
          ),
        ),
      ],
    );
  }

  void _sendMessageToRasa({String? message}) async {
    String userMessage = message ?? askMeAnythingController.text.trim();
    String apiUrl = 'http://192.168.100.2:5000/predict';

    if (userMessage.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please enter a message')),
      );
      return;
    }

    Message userMessageObject = Message(
      text: userMessage,
      sender: 'user',
      timestamp: Timestamp.now(),
    );

    messages.add(userMessageObject);
    setState(() {});

    Map<String, dynamic> requestData = {
      "message": userMessage,
    };

    try {
      http.Response response = await http.post(
        Uri.parse(apiUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(requestData),
      );

      if (response.statusCode == 200) {
        String botResponse = response.body;

        Message botMessage = Message(
          text: botResponse,
          sender: 'bot',
          timestamp: Timestamp.now(),
        );

        messages.add(botMessage);

        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );

        askMeAnythingController.clear();
        setState(() {});

        await storeUserMessage(userMessageObject, userId!);
        await storeBotResponses([botMessage], userId!);
      } else {
        print('Error: ${response.statusCode}');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  Future<void> storeUserMessage(Message message, String userId) async {
    try {
      if (userId != null) {
        CollectionReference<Map<String, dynamic>> messagesCollection =
            FirebaseFirestore.instance.collection('history');

        DocumentReference<Map<String, dynamic>> userDocumentRef =
            messagesCollection.doc(userId);

        CollectionReference<Map<String, dynamic>> firstPromptCollection =
            userDocumentRef.collection('text_of_first_prompt_asked');

        await firstPromptCollection.add({
          'messages': FieldValue.arrayUnion([message.toMap()])
        });
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
        CollectionReference<Map<String, dynamic>> messagesCollection =
            FirebaseFirestore.instance.collection('history');

        DocumentReference<Map<String, dynamic>> userDocumentRef =
            messagesCollection.doc(userId);

        CollectionReference<Map<String, dynamic>> firstPromptCollection =
            userDocumentRef.collection('text_of_first_prompt_asked');

        for (Message message in messages) {
          await firstPromptCollection.add({
            'messages': FieldValue.arrayUnion([message.toMap()])
          });
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

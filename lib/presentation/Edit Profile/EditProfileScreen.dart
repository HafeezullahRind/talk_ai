import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'package:talk_ai/core/app_export.dart';
import 'package:talk_ai/widgets/custom_outlined_button.dart';

import '../../Provider/user_provider.dart';
import '../../widgets/custom_text_form_field.dart';

class EditProfileScreen extends StatefulWidget {
  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  TextEditingController usernameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  ImagePicker _imagePicker = ImagePicker();
  File? _selected_image;
  Uint8List? image;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _storage = FirebaseStorage.instance;
  late UserProvider userProvider;
  User? currentUser;
  String? userId;

  @override
  void initState() {
    super.initState();
    currentUser = _auth.currentUser;
    userId = currentUser?.email;
    userProvider = Provider.of<UserProvider>(context, listen: false);
    getUserData();
  }

  String downloadURL = '';

  bool isUserDataFetched = false;

  @override
  Widget build(BuildContext context) {
    print(isUserDataFetched);
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Edit Profile',
            style: TextStyle(
              color: theme.colorScheme.onPrimary,
              fontSize: 20.0,
              fontWeight: FontWeight.w600,
            ),
          ),
          backgroundColor: appTheme.lightGreen50,
          elevation: 0,
          iconTheme: IconThemeData(color: theme.colorScheme.onPrimary),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: () {
                    _pickImage();
                  },
                  child: userProvider.imageUrl == null
                      ? _buildShimmerAvatar()
                      : CircleAvatar(
                          radius: 64.0,
                          backgroundImage: NetworkImage(
                              userProvider.imageUrl!), // Use Image.network
                        ),
                ),
                Column(
                  children: [
                    SizedBox(height: 20.0),
                    CustomTextFormField(
                      controller: nameController,
                      hintText: 'Name',
                      textInputType: TextInputType.text,
                    ),
                    SizedBox(height: 15.0),
                    CustomTextFormField(
                      controller: emailController,
                      hintText: 'Email',
                      textInputType: TextInputType.text,
                      enabled: false,
                    ),
                    SizedBox(height: 15.0),
                    CustomTextFormField(
                      controller: usernameController,
                      hintText: 'Username',
                      textInputType: TextInputType.text,
                    ),
                    SizedBox(height: 20.0),
                    CustomOutlinedButton(
                      onPressed: () async {
                        showDialog(
                          context: context,
                          barrierDismissible:
                              false, // Prevents the user from dismissing the dialog
                          builder: (BuildContext context) {
                            return AlertDialog(
                              content: Container(
                                  height: 100.0,
                                  child: Center(
                                      child: CircularProgressIndicator())),
                            );
                          },
                        );
                        await _uploadDataToFirestore();
                        Navigator.pushNamed(context, AppRoutes.mainscreen);
                      },
                      text: "Submit",
                      margin: EdgeInsets.symmetric(horizontal: 20.h),
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShimmerAvatar() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: CircleAvatar(
        radius: 64.0,
        backgroundColor: Colors.white,
      ),
    );
  }

  Future<void> _pickImage() async {
    final return_image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
    );

    if (return_image == null) return;

    setState(() {
      _selected_image = File(return_image.path);
      image = File(return_image.path).readAsBytesSync();
    });
  }

  Future<void> _uploadDataToFirestore() async {
    try {
      User? currentUser = _auth.currentUser;

      if (currentUser != null) {
        // Use the ID of the current user
        String? userId = currentUser.email;

        print(currentUser.email);

        // Upload the image to Firebase Storage
        String imageUrl = await _uploadImageToStorage(userId!);

        final DocumentReference userDocument =
            FirebaseFirestore.instance.collection('newuser').doc(userId);

        await userDocument.set({
          'name': nameController.text,
          'email': currentUser.email,
          'username': usernameController.text,
          'imageUrl': imageUrl,
          // Add other fields as needed
        });

        UserProvider().setUser(
            name: nameController.text,
            email: emailController.text,
            username: usernameController.text,
            imageUrl: downloadURL);

        print('User data updated successfully!');
      } else {
        print('No user is currently signed in.');
        // Handle the case where no user is signed in
      }
    } catch (e) {
      print('Error updating user data: $e');
      // Handle the error appropriately
    }
  }

  Future<String> _uploadImageToStorage(String userId) async {
    try {
      if (currentUser != null && _selected_image != null) {
        String imageName = 'profile_image_$userId.jpg';

        final storageRef = _storage.ref().child(userId).child(imageName);

        // Upload the image
        await storageRef.putFile(_selected_image!);

        // Get the download URL
        String downloadURL = await storageRef.getDownloadURL();
        return downloadURL;
      }

      return ''; // Return an empty string if no image or user is available
    } catch (e) {
      print('Error uploading image: $e');
      return '';
    }
  }

  void getUserData() async {
    if (!isUserDataFetched) {
      nameController.text = userProvider.name ?? '';
      emailController.text = userProvider.email ?? '';
      usernameController.text = userProvider.username ?? '';

      _displayProfilePicture(userId!);
      userProvider.notifyListeners();
      setState(() {
        isUserDataFetched = true;
      });
      // Set the flag to true after fetching data
    }
  }

  void _displayProfilePicture(String userId) async {
    try {
      String imageName = 'profile_image_hafeezullah7000@gmail.com.jpg';

      // Get the download URL from Firebase Storage
      downloadURL = await FirebaseStorage.instance
          .ref(userId)
          .child(imageName)
          .getDownloadURL();

      setState(() {
        _selected_image = File(downloadURL);
        print('img url us here');
        print(userProvider.imageUrl);
      });
    } catch (e) {
      print('Error fetching profile picture: $e');
    }
  }
}

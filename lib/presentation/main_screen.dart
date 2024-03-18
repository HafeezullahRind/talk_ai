import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_ai/core/app_export.dart';
import 'package:talk_ai/core/utils/userPrompt_pref.dart';
import 'package:talk_ai/presentation/home_screen/home_screen.dart';
import 'package:talk_ai/presentation/profile_screen/profile_screen.dart';
import 'package:talk_ai/presentation/save/save_screen.dart';
import 'package:talk_ai/widgets/app_bar/appbar_trailing_image.dart';

import '../Provider/user_provider.dart';
import '../widgets/app_bar/appbar_leading_image.dart';
import '../widgets/app_bar/custom_app_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({Key? key}) : super(key: key);

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late PageController _pageController;
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  late UserProvider userProvider;
  String downloadURL = '';

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
    userProvider = Provider.of<UserProvider>(context, listen: false);
    getUserData();
    // Clear the user prompt when MainScreen is initialized
    UserPromptPre.clearPrompt();
  }

  bool isUserDataFetched = false;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // appBar: AppBar(
      //   title: Text('TALK AI'),
      // ),
      //_buildAppBar(context),
      body: PageView(
        controller: _pageController,
        onPageChanged: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        children: [
          HomeScreen(),
          SaveScreen(),
          ProfileScreen(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            _pageController.animateToPage(
              index,
              duration: Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          });
        },
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        items: [
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 0 ? Colors.white : Colors.black),
              child: Icon(Icons.home,
                  color: _selectedIndex == 0 ? Colors.black : Colors.white),
            ),
            label: 'Chat',
          ),
          BottomNavigationBarItem(
            icon: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _selectedIndex == 1 ? Colors.white : Colors.black),
              child: Icon(Icons.history,
                  color: _selectedIndex == 1 ? Colors.black : Colors.white),
            ),
            label: 'Save',
          ),
          BottomNavigationBarItem(
            backgroundColor: appTheme.lightGreen50,
            icon: Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _selectedIndex == 2 ? Colors.white : Colors.black,
              ),
              child: Icon(Icons.account_circle,
                  color: _selectedIndex == 2 ? Colors.black : Colors.white),
            ),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return CustomAppBar(
      leadingWidth: 52.h,
      leading: AppbarLeadingImage(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.profileScreen);
        },
        imagePath: ImageConstant.imgMegaphone,
        margin: EdgeInsets.only(
          left: 20.h,
          top: 8.v,
          bottom: 8.v,
        ),
      ),
      actions: [
        AppbarTrailingImage(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.profileScreen);
          },
          imagePath: ImageConstant.imgHugeIconUser,
          margin: EdgeInsets.symmetric(
            horizontal: 20.h,
            vertical: 8.v,
          ),
        ),
      ],
    );
  }

  void getUserData() async {
    try {
      if (!isUserDataFetched) {
        User? currentUser = _auth.currentUser;
        String? userId = currentUser?.email;

        DocumentSnapshot userSnapshot =
            await _firestore.collection('newuser').doc(userId).get();

        if (userSnapshot.exists) {
          Map<String, dynamic> userData =
              userSnapshot.data() as Map<String, dynamic>;

          userProvider.setUser(
            name: userData['name'] ?? '',
            email: userData['email'] ?? '',
            username: userData['username'] ?? '',
            imageUrl: userData['imageUrl'] ?? '',
          );

          _displayProfilePicture(userId!);

          print(userProvider.name);
          print("username is" + userProvider.username);

          userProvider.notifyListeners();
          isUserDataFetched = true; // Set the flag to true after fetching data
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
    }
  }

  Future<void> _displayProfilePicture(String userId) async {
    try {
      String imageName = 'profile_image_hafeezullah7000@gmail.com.jpg';

      // Get the download URL from Firebase Storage
      downloadURL = await FirebaseStorage.instance
          .ref(userId)
          .child(imageName)
          .getDownloadURL();

      setState(() {
        print("downlaod url is" + downloadURL);
        userProvider.imageUrl = downloadURL;
        userProvider.notifyListeners();
      });
    } catch (e) {
      print('Error fetching profile picture: $e');
    }
  }
}

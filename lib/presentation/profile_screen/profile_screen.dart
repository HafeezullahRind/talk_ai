import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_ai/core/app_export.dart';
import 'package:talk_ai/presentation/terms_of_service/TermsOfServiceScreen.dart';
import 'package:talk_ai/widgets/custom_switch.dart';

import '../../Provider/user_provider.dart';
import '../../core/utils/snackbar.dart';
import '../privacy_policy_Screen/PrivacyPolicyScreen.dart';

// ignore_for_file: must_be_immutable
class ProfileScreen extends StatelessWidget {
  ProfileScreen({Key? key}) : super(key: key);

  bool isSelectedSwitch = false;
  String downloadURL = '';

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                  width: double.maxFinite,
                  padding: EdgeInsets.symmetric(vertical: 23.v),
                  child: Consumer<UserProvider>(
                    builder:
                        (BuildContext context, userProvider, Widget? child) {
                      print('Name: ${userProvider.name}');
                      print('Username: ${userProvider.username}');
                      return Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              radius: 50.0,
                              backgroundImage: NetworkImage(
                                userProvider.imageUrl! ??
                                    '', // Use the user's image URL
                              ),
                            ),
                            SizedBox(height: 12.v),
                            Text(userProvider.name,
                                style: TextStyle(
                                    color: appTheme.gray900,
                                    fontSize: 28.fSize,
                                    fontFamily: 'Rubik',
                                    fontWeight: FontWeight.w500)),
                            SizedBox(height: 8.v),
                            Text("@${userProvider.username ?? ''}",
                                style: TextStyle(
                                    color: theme.colorScheme.onPrimary,
                                    fontSize: 20.fSize,
                                    fontFamily: 'Rubik',
                                    fontWeight: FontWeight.w400)),
                            SizedBox(height: 15.v),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushNamed(
                                    context, AppRoutes.edit_profile);
                              },
                              child: _buildLanguagesList(context,
                                  globe: ImageConstant.imgLock,
                                  editProfile: "Edit Profile"),
                            ),
                            _buildNotificationsList(context),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        TermsOfServiceScreen()),
                              ),
                              child: _buildLanguagesList(context,
                                  globe: ImageConstant.imgFile,
                                  editProfile: "Terms of service"),
                            ),
                            GestureDetector(
                              onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        PrivacyPolicyScreen()),
                              ),
                              child: _buildLanguagesList(context,
                                  globe: ImageConstant.imgFile,
                                  editProfile: "Privacy Policy"),
                            )
                          ]);
                    },
                  )),
            ),
            bottomNavigationBar: _buildLogOutList(context)));
  }

  /// Section Widget
  Widget _buildNotificationsList(BuildContext context) {
    return Container(
        width: double.maxFinite,
        padding: EdgeInsets.fromLTRB(24.h, 24.v, 24.h, 23.v),
        decoration: AppDecoration.outlineSecondaryContainer,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CustomImageView(
              imagePath: ImageConstant.imgIconOutlineBell,
              height: 24.adaptSize,
              width: 24.adaptSize),
          Padding(
              padding: EdgeInsets.only(left: 12.h),
              child: Text("Notifications",
                  style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 17.fSize,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w400))),
          Spacer(),
          CustomSwitch(
              value: isSelectedSwitch,
              onChange: (value) {
                isSelectedSwitch = value;
              })
        ]));
  }

  /// Section Widget
  Widget _buildLogOutList(BuildContext context) {
    return Container(
        margin: EdgeInsets.only(left: 24.h, right: 24.h, bottom: 61.v),
        decoration: AppDecoration.outlineSecondaryContainer1,
        child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              CustomImageView(
                  imagePath: ImageConstant.imgThumbsUpPrimary,
                  height: 24.adaptSize,
                  width: 24.adaptSize),
              GestureDetector(
                onTap: () async {
                  try {
                    showCustomMaterialBanner(
                      context: context,
                      title: 'Logout!!',
                      body: 'Login Again to Access!',
                      contentType: ContentType.success,
                    );
                    await FirebaseAuth.instance.signOut();
                    // After signing out, navigate to the login screen or any other screen you desire.
                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      AppRoutes.sigin_in,
                      (Route<dynamic> route) => false,
                    );
                  } catch (e) {
                    print('Error signing out: $e');
                    // Handle error if needed
                  }
                },
                child: Padding(
                    padding: EdgeInsets.only(left: 12.h, top: 3.v),
                    child: Text("Log out",
                        style: TextStyle(
                            color: theme.colorScheme.onPrimary,
                            fontSize: 17.fSize,
                            fontFamily: 'Rubik',
                            fontWeight: FontWeight.w400))),
              ),
              Spacer(),
              CustomImageView(
                  imagePath: ImageConstant.imgArrowRight,
                  height: 24.adaptSize,
                  width: 24.adaptSize)
            ]));
  }

  /// Common widget
  Widget _buildLanguagesList(
    BuildContext context, {
    required String globe,
    required String editProfile,
  }) {
    return Container(
        width: double.maxFinite,
        padding: EdgeInsets.fromLTRB(24.h, 23.v, 24.h, 22.v),
        decoration: AppDecoration.outlineSecondaryContainer,
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          CustomImageView(
              imagePath: globe, height: 24.adaptSize, width: 24.adaptSize),
          Padding(
              padding: EdgeInsets.only(left: 12.h, top: 3.v),
              child: Text(editProfile,
                  style: TextStyle(
                      color: theme.colorScheme.onPrimary,
                      fontSize: 17.fSize,
                      fontFamily: 'Rubik',
                      fontWeight: FontWeight.w400))),
          Spacer(),
          CustomImageView(
              imagePath: ImageConstant.imgArrowRight,
              height: 24.adaptSize,
              width: 24.adaptSize)
        ]));
  }

  /// Navigates back to the previous screen.
  onTapArrowLeft(BuildContext context) {
    Navigator.pop(context);
  }
}

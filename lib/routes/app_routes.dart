import 'package:flutter/material.dart';
import 'package:talk_ai/presentation/Edit%20Profile/EditProfileScreen.dart';
import 'package:talk_ai/presentation/app_navigation_screen/app_navigation_screen.dart';
import 'package:talk_ai/presentation/home_answer_generated_screen/home_answer_generated_screen.dart';
import 'package:talk_ai/presentation/home_screen/home_screen.dart';
import 'package:talk_ai/presentation/main_screen.dart';
import 'package:talk_ai/presentation/profile_screen/profile_screen.dart';
import 'package:talk_ai/presentation/sign_up_screen/sign_up_screen.dart';
import 'package:talk_ai/presentation/verify_email/verify_email.dart';
import 'package:talk_ai/presentation/save/save_screen.dart';

import '../presentation/sign_in/sign_in.dart';

class AppRoutes {
  static const String signUpScreen = '/sign_up_screen';
  static const String add_user = '/sign_up_screen';
  static const String homeScreen = '/add_users';

  static const String homeAnswerGeneratedScreen =
      '/home_answer_generated_screen';

  static const String mainscreen = '/mainscreen';

  static const String profileScreen = '/profile_screen';

  static const String save_screen = '/save_screen';

  static const String sigin_in = '/sigin_in';
  static const String edit_profile = '/edit_profile';

  static const String appNavigationScreen = '/app_navigation_screen';
  static const String verify_email = '/verify_email_screen';
  static Map<String, WidgetBuilder> routes = {
    signUpScreen: (context) => SignUpScreen(),
    homeScreen: (context) => HomeScreen(),
    homeAnswerGeneratedScreen: (context) => HomeAnswerGeneratedScreen(),
    profileScreen: (context) => ProfileScreen(),
    appNavigationScreen: (context) => AppNavigationScreen(),
    mainscreen: ((context) => MainScreen()),
    // add_user: ((context) => AddUser("Hafeez", "Cs", 33)),
    sigin_in: ((context) => LoginScreen()),
    save_screen: ((context) => SaveScreen()),
    edit_profile: ((context) => EditProfileScreen()),
    verify_email: ((context) => EmailVerificationScreen())
  };
}

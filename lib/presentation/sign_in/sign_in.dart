import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_ai/core/app_export.dart';
import 'package:talk_ai/core/utils/snackbar.dart';
import 'package:talk_ai/widgets/custom_outlined_button.dart';
import 'package:talk_ai/widgets/custom_text_form_field.dart';

class LoginScreen extends StatelessWidget {
  LoginScreen({Key? key}) : super(key: key);

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final signin_service _authService = signin_service();

    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: SizedBox(
          width: SizeUtils.width,
          child: SingleChildScrollView(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              child: SizedBox(
                width: double.maxFinite,
                child: Column(
                  children: [
                    Container(
                      height: 1.v,
                      width: double.maxFinite,
                      decoration: BoxDecoration(
                        color: appTheme.lightGreen50,
                      ),
                    ),
                    SizedBox(height: 8.v),
                    CustomImageView(
                      imagePath: ImageConstant.imgLogoImage,
                      height: 32.adaptSize,
                      width: 32.adaptSize,
                    ),
                    SizedBox(height: 46.v),
                    CustomImageView(
                      imagePath: ImageConstant.imgGroup,
                      height: 152.v,
                      width: 186.h,
                    ),
                    SizedBox(height: 41.v),
                    Text(
                      "Welcome back to Talk AI",
                      style: TextStyle(
                        color: appTheme.black900,
                        fontSize: 20.fSize,
                        fontFamily: 'Rubik',
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    SizedBox(height: 7.v),
                    Container(
                      width: 285.h,
                      margin: EdgeInsets.symmetric(horizontal: 44.h),
                      child: Text(
                        "Log in to your Talk AI account",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: appTheme.black900,
                          fontSize: 17.fSize,
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    SizedBox(height: 32.v),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.h),
                      child: CustomTextFormField(
                        controller: emailController,
                        hintText: "Email Address",
                        textInputType: TextInputType.emailAddress,
                      ),
                    ),
                    SizedBox(height: 15.v),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 20.h),
                      child: CustomTextFormField(
                        controller: passwordController,
                        hintText: "Password",
                        textInputAction: TextInputAction.done,
                        textInputType: TextInputType.visiblePassword,
                        obscureText: true,
                      ),
                    ),
                    SizedBox(height: 81.v),
                    SizedBox(height: 10.v),
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
                        // Call the signup function from AuthService
                        String? errorMessage =
                            await _authService.signinWithEmailAndPassword(
                                emailController.text, passwordController.text);

                        if (errorMessage == null) {
                          // Signup successful, navigate to the main screen
                          showCustomMaterialBanner(
                            context: context,
                            title: 'Successfully login!!',
                            body: 'Welcome to Talk AI!',
                            contentType: ContentType.success,
                          );
                          Navigator.pushNamed(context, AppRoutes.mainscreen);
                        } else {
                          showCustomMaterialBanner(
                            context: context,
                            title: 'Auths Failed!!',
                            body: 'Failed to login your Account!',
                            contentType: ContentType.failure,
                          );
                          Navigator.pop(context);
                        }
                      },
                      text: "Login",
                      margin: EdgeInsets.symmetric(horizontal: 20.h),
                    ),
                    SizedBox(height: 26.v),
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, AppRoutes.signUpScreen);
                      },
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Don't have an account? ",
                              style: CustomTextStyles.bodyLargeff2c2b26,
                            ),
                            TextSpan(
                              text: "Sign Up",
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 10.v),
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (BuildContext context) {
                            return AlertDialog(
                              title: Text("Forgot Password"),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Enter your email to receive a password reset link.",
                                  ),
                                  SizedBox(height: 10),
                                  CustomTextFormField(
                                    controller: emailController,
                                    hintText: "Email Address",
                                    textInputType: TextInputType.emailAddress,
                                  ),
                                  SizedBox(height: 10),
                                  CustomOutlinedButton(
                                    onPressed: () async {
                                      // Handle the password reset logic
                                      try {
                                        await FirebaseAuth.instance
                                            .sendPasswordResetEmail(
                                          email: emailController.text,
                                        );
                                        Navigator.pop(context);
                                        showCustomMaterialBanner(
                                          context: context,
                                          title: 'Password Reset Email Sent',
                                          body:
                                              'Please check your email for instructions.',
                                          contentType: ContentType.success,
                                        );
                                      } catch (e) {
                                        print("Error: $e");
                                        showCustomMaterialBanner(
                                          context: context,
                                          title: 'Password Reset Failed',
                                          body: 'Failed to send reset email.',
                                          contentType: ContentType.failure,
                                        );
                                      }
                                    },
                                    text: "Reset Password",
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                      child: Text(
                        "Forgot Password?",
                        style: TextStyle(
                          fontSize: 14.fSize,
                          fontFamily: 'Rubik',
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class signin_service {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signinWithEmailAndPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Check if the user is verified
      if (!userCredential.user!.emailVerified) {
        // User is not verified, sign out and return an error message
        await _auth.signOut();
        return 'Please verify your email before logging in.';
      }

      return null; // Return null if login is successful
    } catch (e) {
      return e.toString(); // Return error message if login fails
    }
  }
}

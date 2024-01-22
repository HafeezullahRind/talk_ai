import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:talk_ai/core/app_export.dart';
import 'package:talk_ai/core/utils/snackbar.dart';
import 'package:talk_ai/widgets/custom_outlined_button.dart';
import 'package:talk_ai/widgets/custom_text_form_field.dart';

class SignUpScreen extends StatelessWidget {
  SignUpScreen({Key? key})
      : super(
          key: key,
        );

  TextEditingController emailController = TextEditingController();

  TextEditingController passwordController = TextEditingController();

  GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final AuthService _authService = AuthService();

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
                      "Welcome to Talk AI",
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
                        "Create a free Talk AI account\nand ignite your curiosity!",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
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
                    CustomOutlinedButton(
                      onPressed: () async {
                        // Call the signup function from AuthService
                        String? errorMessage =
                            await _authService.signUpWithEmailAndPassword(
                                emailController.text, passwordController.text);

                        if (errorMessage == null) {
                          // Signup successful, navigate to the main screen
                          showCustomMaterialBanner(
                            context: context,
                            title: 'Verification Email sent!!',
                            body: 'Please Confirm email!',
                            contentType: ContentType.success,
                          );

                          Navigator.pushNamed(context, AppRoutes.verify_email);
                        } else {
                          showCustomMaterialBanner(
                            context: context,
                            title: 'Auths Faild!!',
                            body: 'Failed to create your Account!',
                            contentType: ContentType.failure,
                          );
                        }
                      },
                      text: "Create FREE account",
                      margin: EdgeInsets.symmetric(horizontal: 20.h),
                    ),
                    SizedBox(height: 26.v),
                    GestureDetector(
                      onTap: () =>
                          Navigator.pushNamed(context, AppRoutes.sigin_in),
                      child: RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: "Already have an account? ",
                              style: CustomTextStyles.bodyLargeff2c2b26,
                            ),
                            TextSpan(
                              text: "Log in",
                              style: theme.textTheme.titleMedium,
                            ),
                          ],
                        ),
                        textAlign: TextAlign.left,
                      ),
                    ),
                    SizedBox(height: 5.v),
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

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String?> signUpWithEmailAndPassword(
      String email, String password) async {
    try {
      await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      return null; // Return null if signup is successful
    } catch (e) {
      return e.toString(); // Return error message if signup fails
    }
  }
}

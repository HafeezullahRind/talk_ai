import 'package:flutter/material.dart';
import 'package:talk_ai/core/app_export.dart';
import 'package:talk_ai/widgets/custom_text_form_field.dart';

class HomeScreen extends StatelessWidget {
  HomeScreen({Key? key})
      : super(
          key: key,
        );

  TextEditingController descriptionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        body: Container(
          width: double.maxFinite,
          padding: EdgeInsets.symmetric(
            horizontal: 20.h,
            vertical: 64.v,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Spacer(
                flex: 40,
              ),
              CustomImageView(
                imagePath: ImageConstant.imgLogoImage,
                height: 32.adaptSize,
                width: 32.adaptSize,
              ),
              SizedBox(height: 18.v),
              Text(
                "Talk AI",
                style: TextStyle(
                  color: appTheme.black900,
                  fontSize: 34.fSize,
                  fontFamily: 'Rubik',
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: 22.v),
              Container(
                width: 312.h,
                margin: EdgeInsets.symmetric(horizontal: 11.h),
                child: Text(
                  "I'm here to help you with whatever you need, from answering questions to providing recommendations. Let's chat!",
                  maxLines: 4,
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
              SizedBox(height: 21.v),
              SizedBox(
                width: 230.h,
                child: Text(
                  "Example: What can you do",
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
              Spacer(
                flex: 59,
              ),
              CustomTextFormField(
                controller: descriptionController,
                hintText: "Ask me anything...",
                textInputAction: TextInputAction.done,
                suffix: Container(
                  margin: EdgeInsets.fromLTRB(30.h, 14.v, 16.h, 14.v),
                  child: CustomImageView(
                    onTap: () => Navigator.pushNamed(
                        context, AppRoutes.homeAnswerGeneratedScreen),
                    imagePath: ImageConstant.imgIconFillMessagesend,
                    height: 32.adaptSize,
                    width: 32.adaptSize,
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
            ],
          ),
        ),
      ),
    );
  }

  /// Section Widget
}

import 'package:flutter/material.dart';
import 'package:talk_ai/core/app_export.dart';

class AppDecoration {
  // Fill decorations
  static BoxDecoration get fillLightGreen => BoxDecoration(
        color: appTheme.lightGreen50,
      );
  static BoxDecoration get fillOnPrimaryContainer => BoxDecoration(
        color: theme.colorScheme.onPrimaryContainer,
      );

  // Outline decorations
  static BoxDecoration get outlineSecondaryContainer => BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.secondaryContainer,
            width: 1.h,
          ),
        ),
      );
  static BoxDecoration get outlineSecondaryContainer1 => BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.secondaryContainer,
            width: 1.h,
          ),
        ),
      );
}

class BorderRadiusStyle {
  // Custom borders
  static BorderRadius get customBorderTL12 => BorderRadius.only(
        topLeft: Radius.circular(12.h),
        topRight: Radius.circular(12.h),
        bottomLeft: Radius.circular(4.h),
        bottomRight: Radius.circular(12.h),
      );
}

// Comment/Uncomment the below code based on your Flutter SDK version.

// For Flutter SDK Version 3.7.2 or greater.

double get strokeAlignInside => BorderSide.strokeAlignInside;

double get strokeAlignCenter => BorderSide.strokeAlignCenter;

double get strokeAlignOutside => BorderSide.strokeAlignOutside;

// For Flutter SDK Version 3.7.1 or less.

// StrokeAlign get strokeAlignInside => StrokeAlign.inside;
//
// StrokeAlign get strokeAlignCenter => StrokeAlign.center;
//
// StrokeAlign get strokeAlignOutside => StrokeAlign.outside;

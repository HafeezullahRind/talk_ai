import 'dart:async';

import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';
import 'package:flutter/material.dart';

void showCustomMaterialBanner({
  required BuildContext context,
  required String title,
  required String body,
  required ContentType contentType,
}) {
  final materialBanner = SnackBar(
    duration: Duration(seconds: 1),

    /// need to set following properties for best effect of awesome_snackbar_content
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    backgroundColor: Colors.transparent,
    content: AwesomeSnackbarContent(
      title: title,
      message: body,
      contentType: contentType,
      inMaterialBanner: true,
    ),
    // actions: const [SizedBox.shrink()],
  );

  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(materialBanner);

  // Use a Timer to hide the MaterialBanner after the specified duration
}

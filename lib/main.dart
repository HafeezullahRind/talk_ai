import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:talk_ai/Provider/user_provider.dart';
import 'package:talk_ai/firebase_options.dart';

import 'core/app_export.dart';

var globalMessengerKey = GlobalKey<ScaffoldMessengerState>();

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  ThemeHelper().changeTheme('primary');
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, desviceType) {
        return MaterialApp(
          theme: theme,
          title: 'Talk AI',
          debugShowCheckedModeBanner: false,
          initialRoute: AppRoutes.sigin_in,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}

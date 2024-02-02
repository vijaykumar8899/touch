import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_navigation/src/root/get_material_app.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch/Screens/LoginScreens/LoginScreen.dart';
import 'package:touch/Screens/LoginScreens/user_check.dart';
import 'package:touch/Screens/TabScreens/RecordsScreen.dart';
import 'package:touch/Screens/TabScreens/TabsScreen.dart';
import 'package:touch/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  SharedPreferences prefs = await SharedPreferences.getInstance();
  final String? userPhoneNumber = prefs.getString('userPhoneNumber');
  final String? userName = prefs.getString('userName');

  print("main shred pref : userPHone: $userPhoneNumber , userName=$userName");

  final AuthService authService = AuthService();
  bool userLoggedIn = false;
  if (userPhoneNumber != null) {
    userLoggedIn = await authService.doesUserPhoneNumberExist(userPhoneNumber);

    if (!userLoggedIn) {
      // Clear userPhoneNumber from SharedPreferences
      await prefs.remove('userPhoneNumber');
    }
  }

  runApp(MyApp(
    userLoggedIn: userLoggedIn,
  ));
}

class MyApp extends StatelessWidget {
  bool userLoggedIn;

  MyApp({required this.userLoggedIn});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Touch App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: userLoggedIn ? TabsScreen() : LoginScreen(),
    );
  }
}

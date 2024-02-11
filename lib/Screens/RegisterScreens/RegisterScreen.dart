import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch/HelperFunctions/Toast.dart';
import 'package:touch/Screens/LoginScreens/LoginScreen.dart';
import 'package:touch/Screens/TabScreens/HomeScreen.dart';
import 'package:touch/Screens/TabScreens/TabsScreen.dart';

class RegisterScreen extends StatefulWidget {
  String userPhoneNumber_;

  RegisterScreen({required this.userPhoneNumber_});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController _userNameCtrl = TextEditingController();
  TextEditingController _userEmailCtrl = TextEditingController();
  TextEditingController _userCityCtrl = TextEditingController();
  bool isLoading = false;
  String tempName = '';
  bool isCity = false;
  bool isfullName = false;
  var color2 = Colors.white.withOpacity(0.5);

  Future<void> saveUserDataToFirestoreAndSharedPreferences() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      // String? pushNotificationToken =
      //     await FirebaseMessaging.instance.getToken();
      // print(pushNotificationToken);

      await firestore.collection('users').add({
        'userPhoneNumber': widget.userPhoneNumber_,
        'userName': _userNameCtrl.text,
        'userEmail': _userEmailCtrl.text,
        'userCity': _userCityCtrl.text,
        'Admin': '',
        // 'notificationtoken': pushNotificationToken,
        'TimeStamp': Timestamp.now(),
      });

      // Save user data to SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // await prefs.setString('userPhoneNumber', _userPhoneCtrl.text);
      await prefs.setString('userName', _userNameCtrl.text);
      await prefs.setString('userEmail', _userEmailCtrl.text);
      await prefs.setString('userCity', _userCityCtrl.text);
      await prefs.setString('userPhoneNumber', widget.userPhoneNumber_);

      print('User data saved to Firestore and SharedPreferences');
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print('Error saving user data: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Register Page",
          style: GoogleFonts.oswald(
            // Use your desired Google Font, e.g., 'lobster'
            textStyle: const TextStyle(
              color: Colors.black,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Container(
            // decoration: const BoxDecoration(
            //   gradient: LinearGradient(
            //     begin: Alignment.topCenter,
            //     end: Alignment.bottomCenter,
            //     colors: [
            //       Color.fromARGB(255, 178, 212, 240),
            //       // Color.fromARGB(255, 129, 192, 245),
            //       // Color.fromARGB(255, 2, 69, 124),
            //       Color.fromARGB(255, 248, 187, 208),
            //     ],
            //     stops: [0.3, 1.0], // Adjust the stops as needed
            //   ),
            // ),
            color: const Color.fromARGB(
              255,
              178,
              212,
              240,
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InputClass(
                    exText: "Ex: Testing Center",
                    text: 'Name',
                    name_: TextInputType.name,
                    clr: color2,
                    controller_: _userNameCtrl,
                  ),
                  InputClass(
                    exText: "Ex: email8899@gmail.com",
                    text: 'Email',
                    name_: TextInputType.emailAddress,
                    clr: color2,
                    controller_: _userEmailCtrl,
                  ),
                  InputClass(
                    exText: "Ex: Jaggayyapeta",
                    text: 'City',
                    name_: TextInputType.name,
                    clr: color2,
                    controller_: _userCityCtrl,
                  ),
                  Center(
                    child: TextButtonTheme(
                      data: TextButtonThemeData(
                        style: ButtonStyle(
                          foregroundColor:
                              MaterialStateProperty.all<Color>(Colors.white),
                          backgroundColor: MaterialStateProperty.all<Color>(
                              const Color.fromARGB(255, 2, 69, 124)),
                          padding: MaterialStateProperty.all<EdgeInsets>(
                            const EdgeInsets.symmetric(
                                horizontal: 16.0, vertical: 8.0),
                          ),
                          shape:
                              MaterialStateProperty.all<RoundedRectangleBorder>(
                            RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16.0),
                            ),
                          ),
                        ),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          setState(() {
                            isLoading = true; // Set loading to true
                          });
                          if (_userNameCtrl.text.isNotEmpty &&
                              _userCityCtrl.text.isNotEmpty) {
                            await saveUserDataToFirestoreAndSharedPreferences();
                            // Get.offAll(TabsScreen());
                            Get.offAll(TabsScreen());
                          } else if (_userNameCtrl.text.isNotEmpty &&
                              _userCityCtrl.text.isEmpty) {
                            setState(() {
                              isLoading = false;
                            });

                            ToastMessage.toast_("Please enter City name!");
                          } else if (_userNameCtrl.text.isEmpty &&
                              _userCityCtrl.text.isNotEmpty) {
                            setState(() {
                              isLoading = false;
                            });

                            ToastMessage.toast_("Please enter Full Name!");
                          } else if (_userNameCtrl.text.isEmpty &&
                              _userCityCtrl.text.isEmpty) {
                            setState(() {
                              isLoading = false;
                            });

                            ToastMessage.toast_(
                                "Please enter Full name and City name!");
                          }
                        },
                        child: const Text('Submit'),
                      ),
                    ),
                  ),
                ]),
          ),
          Visibility(visible: isLoading, child: LoadingClass()),
        ],
      ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch/HelperFunctions/Toast.dart';
import 'package:touch/Screens/RegisterScreens/RegisterScreen.dart';
import 'package:touch/Screens/TabScreens/HomeScreen.dart';
import 'package:touch/Screens/TabScreens/TabsScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  TextEditingController _phoneNumberCtrl = TextEditingController();
  TextEditingController otpController_ = TextEditingController();

  bool showOTPField = false; // Initially hide OTP field
  String _verificationId = '';
  bool isLoading = false;
  bool otpSent = false;
  var color1 = Color.fromARGB(255, 248, 187, 208);
  var color2 = Colors.white.withOpacity(0.5);

  void colorChange() {
    color2 = Color.fromARGB(255, 248, 187, 208);
    color1 = Colors.white.withOpacity(0.5);
  }

  Future<void> checkUserExistOrNot(String _userPhoneNumber) async {
    print('phoneNumber inside existing user check $_userPhoneNumber');
    try {
      final CollectionReference usersCollection =
          FirebaseFirestore.instance.collection('users');

      // Query the 'users' collection for the provided phone number
      QuerySnapshot querySnapshot = await usersCollection
          .where('userPhoneNumber', isEqualTo: _userPhoneNumber)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // If a document with the provided phone number exists, fetch its data
        DocumentSnapshot document = querySnapshot.docs.first;
        print('Document data: ${document.data()}');

        String userPhoneNumber = document['userPhoneNumber'];
        String userName = document['userName'];
        String userCity = document['userCity'];
        String userEmail = document['userEmail'];
        String Admin = document['Admin'];

        // Save user data to SharedPreferences
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setString('userPhoneNumber', userPhoneNumber);
        await prefs.setString('userEmail', userEmail);
        await prefs.setString('userName', userName);
        await prefs.setString('userCity', userCity);
        await prefs.setString('Admin', Admin);

        print('User data saved to SharedPreferences');
        Get.offAll(TabsScreen());
        setState(() {
          isLoading = false;
        });
      } else {
        // If the phone number does not exist in the 'users' collection, return null
        print('User not found in Firestore');
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => RegisterScreen(
              userPhoneNumber_: _userPhoneNumber,
            ),
          ),
        );
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error fetching user data: $e');
      ToastMessage.toast_("Error : ${e.toString()}");
    }
  }

  Future<void> loginWithPhone() async {
    String PhoneNumber = formatPhoneNumber(_phoneNumberCtrl.text);
    print(PhoneNumber);
    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: PhoneNumber,
        timeout: Duration(seconds: 60),
        verificationCompleted: (PhoneAuthCredential phoneAuthCredential) {
          // This callback will be called when the verification is completed automatically
          // using the auto-retrieval method.
        },
        verificationFailed: (FirebaseAuthException authException) {
          setState(() {
            isLoading = false;
          });
          print('Phone verification failed. Code: ${authException.code}');
          // Handle the error, e.g., show an error message to the user.
          ToastMessage.toast_(
              "Phone verification failed. Code: ${authException.code}");
        },
        codeSent: (String verificationId, [int? forceResendingToken]) {
          // verifyOTP(verificationId);
          _verificationId = verificationId;
          if (_verificationId.isNotEmpty) {
            setState(() {
              otpSent = true;
              isLoading = false;
            });
          }
          print('verificationId : $verificationId');
          print('_verificationId : $_verificationId');
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          // Auto retrieval timeout, handle the situation here
        },
      );
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      print('Error sending OTP: $e');
      ToastMessage.toast_(e.toString());
    }
  }

  Future<void> verifyOTP(String otp) async {
    String PhoneNumber = formatPhoneNumber(_phoneNumberCtrl.text);

    try {
      if (_verificationId.isNotEmpty) {
        PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: _verificationId,
          smsCode: otp,
        );

        UserCredential userCredential =
            await FirebaseAuth.instance.signInWithCredential(credential);

        if (userCredential.user != null) {
          // If OTP is verified successfully, navigate to the next screen
          // ignore: use_build_context_synchronously
          await checkUserExistOrNot(PhoneNumber);
        } else {
          setState(() {
            isLoading = false;
          });
          print('Error verifying OTP');
          ToastMessage.toast_("InCorrect OTP!");
        }
      } else {
        setState(() {
          isLoading = false;
        });
        print("Sending OTP failed");
        ToastMessage.toast_(
            "Oops!. Sending the OTP failed. Please try after some time.");
      }
    } catch (e) {
      print('Error verifying OTP: $e');
      ToastMessage.toast_("Error verifying OTP: ${e.toString()}");
      setState(() {
        isLoading = false;
      });
    }
  }

  String formatPhoneNumber(String phoneNumber) {
    // Remove any non-numeric characters
    phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (!phoneNumber.startsWith('91')) {
      phoneNumber = '91$phoneNumber';
    }

    if (phoneNumber.length == 10 && phoneNumber.startsWith('91')) {
      phoneNumber = '91$phoneNumber';
    }

    // Check if the number starts with a leading plus (+)
    if (!phoneNumber.startsWith('+')) {
      // Add the leading plus for international format
      phoneNumber = '+$phoneNumber';
    }
    print('phoneNumber : $phoneNumber');
    return phoneNumber;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "Login or Signup Page",
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
            decoration: const BoxDecoration(
              color: Color.fromARGB(
                255,
                178,
                212,
                240,
              ),
            ),
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
            //     stops: [0.3, 1.0],
            //   ),
            // ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InputClass(
                  exText: "Ex: 9123456789",
                  text: 'Number',
                  name_: TextInputType.number,
                  clr: color1,
                  controller_: _phoneNumberCtrl,
                ),
                if (otpSent) ...[
                  InputClass(
                    exText: "Ex: 123456",
                    text: 'OTP',
                    name_: TextInputType.number,
                    clr: color2,
                    controller_: otpController_,
                  ),
                ],
                if (otpSent) ...[
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
                        onPressed: () {
                          if (otpController_.text.length == 6) {
                            setState(() {
                              isLoading = true; // Set loading to true
                            });
                            verifyOTP(otpController_.text);
                            FocusScope.of(context).unfocus();
                          } else {
                            ToastMessage.toast_(
                                "You entered ${otpController_.text.length} digits of OTP only; please enter 6 digits of OTP.");
                          }
                        },
                        child: const Text('Verify OTP'),
                      ),
                    ),
                  ),
                ] else ...[
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
                        onPressed: () {
                          setState(() {
                            isLoading = true; // Set loading to true
                            colorChange();
                          });
                          loginWithPhone();
                          setState(() {
                            showOTPField = true;
                          });
                        },
                        child: const Text('Send OTP'),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Visibility(
            visible: isLoading,
            child: LoadingClass(),
          ),
        ],
      ),
    );
  }
}

class InputClass extends StatelessWidget {
  String text;
  TextInputType name_;
  String exText;
  var clr;
  TextEditingController controller_;

  InputClass(
      {required this.text,
      required this.name_,
      required this.exText,
      required this.clr,
      required this.controller_});

  @override
  Widget build(BuildContext context) {
    // controller_.addListener(() {
    //   if (onTextChanges != null) {
    //     onTextChanges(controller_.text);
    //   }
    // });
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          decoration: InputDecoration(
            hintText: text,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
            hintStyle: const TextStyle(
              color: Colors.black87,
              fontStyle: FontStyle.italic,
            ),
            filled: true,
            fillColor: clr, // Transparent with white
            enabledBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white70, width: 2.0),
              borderRadius: BorderRadius.circular(20),
            ),
            focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.white70, width: 2.0),
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          keyboardType: name_,
          controller: controller_,
        ),
        const SizedBox(
          height: 5,
        ),
        Padding(
          padding: EdgeInsets.only(left: 10.0),
          child: Text(
            exText,
            style: TextStyle(color: Colors.black87, fontSize: 16),
          ),
        ),
        const SizedBox(
          height: 10,
        ),
      ],
    );
  }
}

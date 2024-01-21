import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:touch/HelperFunctions/Toast.dart';
import 'package:touch/Screens/RegisterScreens/RegisterScreen.dart';
import 'package:touch/Screens/TabsScreen.dart';

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

        // Save user data to SharedPreferences
        // SharedPreferences prefs = await SharedPreferences.getInstance();
        // await prefs.setString('userPhoneNumber', userPhoneNumber);
        // await prefs.setString('userEmail', userEmail);
        // await prefs.setString('userName', userName);
        // await prefs.setString('userCity', userCity);
        // await prefs.setString('Admin', Admin);

        print('User data saved to SharedPreferences');
        // Get.offAll(TabsScreen());
        setState(() {
          isLoading = false;
        });
      } else {
        // If the phone number does not exist in the 'users' collection, return null
        print('User not found in Firestore');
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => userDetailsScreen(
        //       userPhoneNumber_: _userPhoneNumber,
        //     ),
        //   ),
        // );
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
          style: GoogleFonts.italiana(
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
      body: Container(
        // decoration: const BoxDecoration(
        //   color: Color.fromARGB(
        //     255,
        //     178,
        //     212,
        //     240,
        //   ),
        // ),
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 178, 212, 240), Colors.white],
            stops: [0.3, 1.0],
          ),
        ),
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
              controller_: _phoneNumberCtrl,
            ),
            InputClass(
              exText: "Ex: 123456",
              text: 'OTP',
              name_: TextInputType.number,
              controller_: otpController_,
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
                    shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                      RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(4.0),
                      ),
                    ),
                  ),
                ),
                child: TextButton(
                  onPressed: () {
                    Get.to(RegisterScreen());
                    // ToastMessage.toast_(nameController_.text);
                  },
                  child: const Text('Login/ Signup'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class InputClass extends StatelessWidget {
  String text;
  TextInputType name_;
  String exText;
  TextEditingController controller_;

  InputClass(
      {required this.text,
      required this.name_,
      required this.exText,
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
            fillColor: Colors.white.withOpacity(0.5), // Transparent with white
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

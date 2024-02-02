import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:touch/HelperFunctions/Toast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:touch/Screens/TabScreens/ProfileScreen.dart';

class HomeScreen extends StatefulWidget {
  @override
  State<HomeScreen> createState() => _HomeScreenState();

  static String? userPhoneNumber;
  static String? userName;
}

class _HomeScreenState extends State<HomeScreen> {
  TextEditingController weightConrl_ = TextEditingController();
  TextEditingController perConrl_ = TextEditingController();
  TextEditingController lessConrl_ = TextEditingController();
  TextEditingController customerNameConrl_ = TextEditingController();
  bool isLoading = false;

  double result = 0;
  double weight = 0.0;
  double less = 0.0;
  double percentage = 0.0;
  String weight_temp = '';
  String imagePath = '';
  String mainFolder = 'touchCollection';
  String imageUrl = '';
  bool isImageUploaded = false;
  String formattedDate = '';
  double totalWeight = 0.0;
  int totalCount = 0;
  double perResult = 0.0;
  String custmerName = '';

  getUserDetailsFromSharedPref() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      HomeScreen.userPhoneNumber = prefs.getString('userPhoneNumber');
      HomeScreen.userName = prefs.getString('userName');
      // print(
      //     "getUseDetails : userPHone_: $userPhoneNumber , userName_=$userName");
    });
  }

  Future<void> timeAndDate() async {
    String currentDate = DateTime.now()
        .toString()
        .split(' ')[0]; // Get today's date in format 'yyyy-mm-dd'

    List<String> parts = currentDate.split('-');
    formattedDate =
        '${parts[2]}-${parts[1]}-${parts[0]}'; // Reversing the date format to 'dd-mm-yyyy'

    // ToastMessage.toast_(
    //     formattedDate); // This will output the date in 'dd-mm-yyyy' format
  }

  Future<void> getTotalWeightAndCount() async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      DocumentSnapshot<Map<String, dynamic>> docSnapshot = await firestore
          .collection(mainFolder)
          .doc(HomeScreen.userPhoneNumber)
          .collection('allRecordCalculation')
          .doc(formattedDate)
          .get();

      if (docSnapshot.exists) {
        // Access the totalWeight and totalCount fields from the document
        print(' data from fire : ${docSnapshot.data().toString()}');
        print(
            ' data from str : ${docSnapshot.data()?['totalWeight'].toString()}');

        String totalWeight_ = docSnapshot.data()!['totalWeight'];
        String totalCount_ = docSnapshot.data()!['totalCount'];
        // ToastMessage.toast_('2');

        totalWeight = double.tryParse(totalWeight_) ?? 0.0;
        totalCount = int.tryParse(totalCount_) ?? 0;

        // double totalWeight =
        //     (docSnapshot.data()?['totalWeight'] as double?) ?? 0.0;
        // int totalCount = (docSnapshot.data()?['totalCount'] as int?) ?? 0;

        // totalWeight = docSnapshot.get('totalWeight') as double? ?? 0.0;
        // totalCount = docSnapshot.get('totalCount') as int? ?? 0;
        print('totalCount in fire : $totalCount');
        // ToastMessage.toast_(
        //     'weight : ${totalWeight.toStringAsFixed(3)} count : $totalCount');

        // return [totalWeight.toString(), totalCount.toString()];
      } else {
        await firestore
            .collection(mainFolder)
            .doc('vijay')
            .collection('allRecordCalculation')
            .doc(formattedDate)
            .set({
          'totalWeight': '0.0',
          'totalCount': '0',
          'timeStamp': Timestamp.now(),
        }); //.then((value) => ToastMessage.toast_('set was successfull'));

        // return ['0.0', '0'];
      }
    } catch (e) {
      print('Error in the first method : $e');
      return null;
    }
  }

  void saveData() async {
    try {
      FirebaseFirestore firebase = FirebaseFirestore.instance;
      // ToastMessage.toast_(isImageUploaded.toString());
      await getTotalWeightAndCount();
      print('totalCount in saveFire : $totalCount');

      // int count = int.parse(data![1]); // totalCount
      // double totalWeight = double.parse(data[0]); // totalWeight
      totalCount += 1;
      print('totalCount in saveFire2 : $totalCount');

      totalWeight += result;

      if (isImageUploaded) {
        // ToastMessage.toast_('inside imageUPload');
        FirebaseStorage storage = FirebaseStorage.instance;

        final storageRef = storage
            .ref()
            .child('$mainFolder/${HomeScreen.userPhoneNumber}/$totalCount');

        final uploadTask = storageRef.putFile(File(imagePath));
        var snapshot = await uploadTask;
        // .whenComplete(() => ToastMessage.toast_('Uploaded image'));

        imageUrl = await snapshot.ref.getDownloadURL();
      }

      // ToastMessage.toast_('weight : $totalWeight , count: $totalCount');

      await firebase
          .collection(mainFolder)
          .doc(HomeScreen.userPhoneNumber)
          .collection(formattedDate)
          .add({
        'order': totalCount,
        'weight': weight.toStringAsFixed(3),
        'less': less.toStringAsFixed(2),
        'percentage': percentage.toStringAsFixed(2),
        'result': result.toStringAsFixed(3),
        'name': custmerName,
        'image': imageUrl,
        'timeStamp': Timestamp.now(),
      }).then((value) => ToastMessage.toast_('Data Saved Successfully'));

      await firebase
          .collection(mainFolder)
          .doc(HomeScreen.userPhoneNumber)
          .collection('allRecordCalculation')
          .doc(formattedDate)
          .set({
        'totalWeight': totalWeight.toStringAsFixed(3),
        'totalCount': totalCount.toString(),
      }); //.then((value) => ToastMessage.toast_('set was successfull'));

      setState(() {
        totalWeight = 0.0;
        isImageUploaded = false;
        imagePath = '';
        isLoading = false;
      });
    } catch (e) {
      ToastMessage.toast_('error : ${e.toString()}');
    }
  }

  lessControllerInitialize() {
    weight = double.tryParse(weightConrl_.text) ?? 0.00;

    lessConrl_.text = weight >= 5.0 ? '00.20' : '00.25';
  }

  //card output alert start
  Future<void> showOutputtDialog(BuildContext context) async {
    File? selectedImage;
    await showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            contentPadding: EdgeInsets.zero,
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            backgroundColor: const Color.fromARGB(255, 178, 212, 240),
            // title: Center(
            //   child: Text(
            //     'Shop Name',
            //     style: GoogleFonts.italiana(
            //       // Use your desired Google Font, e.g., 'lobster'
            //       textStyle: const TextStyle(
            //         color: Colors.black,
            //         fontSize: 20,
            //         fontWeight: FontWeight.bold,
            //       ),
            //     ),
            //   ),
            // ),
            content: Container(
              height: 370,
              width: 500,
              child: Card(
                elevation: 4.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                  side: const BorderSide(width: 2.0, color: Colors.white),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          TextBoxBold(
                            text: 'Date    :',
                          ),
                          SpaceBox(
                            size: 10,
                          ),
                          TextBoxNormal(
                            text: formattedDate,
                          ),
                          SpaceBox(
                            size: 10,
                          ),
                          TextBoxNormal(
                              text:
                                  "${DateFormat('h:mm a').format(DateTime.now())}."),
                        ],
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextBoxBold(text: 'Name  :  '),
                          TextBoxNormal(text: custmerName),
                        ],
                      ),
                      Row(
                        // mainAxisAlignment: MainAxisAlignment.center,
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          TextBoxBold(text: "Sno     : "),
                          TextBoxNormal(text: (totalCount + 1).toString()),
                        ],
                      ),
                      SpaceBoxHeight(size: 10),
                      Row(
                        children: [
                          ColumnBox(
                            weight: weight,
                            text: "Kacha.Wt",
                            num: 3,
                          ),
                          SpaceBox(size: 07),
                          ColumnBox(
                            weight: percentage,
                            text: "Touch%",
                            num: 2,
                          ),
                          SpaceBox(size: 01),
                          ColumnBox(
                            weight: less,
                            text: "Less.",
                            num: 2,
                          ),
                          SpaceBox(size: 01),
                          ColumnBox(
                            weight: result,
                            text: "Fine.Wt",
                            num: 3,
                          ),
                          SpaceBox(size: 01),
                        ],
                      ),
                      SpaceBoxHeight(size: 20),
                      Row(
                        children: [
                          TextBoxBold(text: "KACHA Wt :"),
                          SpaceBox(size: 20),
                          TextBoxNormal(text: weight.toStringAsFixed(3)),
                        ],
                      ),
                      Row(
                        children: [
                          TextBoxBold(text: "Fine Wt :  "),
                          SpaceBox(size: 20),
                          TextBoxNormal(text: result.toStringAsFixed(3)),
                        ],
                      ),

                      //extra added : takephoto and cancel , submit button :
                      SpaceBoxHeight(size: 10),
                      Row(
                        children: [
                          ElevatedButton(
                            onPressed: () async {
                              final picker = ImagePicker();
                              final pickedImage = await picker.pickImage(
                                source: ImageSource.camera,
                              );
                              if (pickedImage != null) {
                                setState(() {
                                  selectedImage = File(pickedImage.path);
                                  imagePath = pickedImage.path;
                                  isImageUploaded = true;
                                });
                              } else {}
                            },
                            child: const Text('Take Photo'),
                          ),
                          const SizedBox(width: 16),
                          isImageUploaded
                              ? selectedImage != null
                                  ? SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Image.file(selectedImage!),
                                    )
                                  : const SizedBox(
                                      width: 100,
                                      height: 100,
                                      child: Text('reTake'),
                                    )
                              : const SizedBox(),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  saveData();
                  setState(() {
                    isLoading = true;
                  });
                  Navigator.pop(context);
                },
                child: const Text('Submit'),
              ),
            ],
          );
        });
  }
  //card alert end

  @override
  void initState() {
    timeAndDate();
    getUserDetailsFromSharedPref().then((_) {
      print(
          "initstate : userPHone: ${HomeScreen.userPhoneNumber} , userName=${HomeScreen.userName}");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          HomeScreen.userName ?? '',
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
        actions: [
          IconButton(
              onPressed: () {
                const ProfileScreen();
              },
              icon: const Icon(FontAwesomeIcons.user))
        ],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Color.fromARGB(255, 178, 212, 240), Colors.white],
                stops: [0.3, 1.0], // Adjust the stops as needed
              ),
            ),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                TextField(
                  decoration: InputDecoration(
                    hintText: "Weight",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    hintStyle: const TextStyle(
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                    filled: true,
                    fillColor:
                        Colors.white.withOpacity(0.5), // Transparent with white
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 2.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 2.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: weightConrl_,
                  onChanged: (_) {
                    lessControllerInitialize();
                  },
                ),

                SpaceBoxHeight(size: 10),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Percentage",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    hintStyle: const TextStyle(
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                    filled: true,
                    fillColor: const Color.fromARGB(
                        100, 178, 212, 240), // Light blue color
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 2.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 2.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: perConrl_,
                ),

                SpaceBoxHeight(size: 10),

                TextField(
                  decoration: InputDecoration(
                    hintText: "Less",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    hintStyle: const TextStyle(
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                    filled: true,
                    fillColor: Colors.pink[100], // Pink color
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 2.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 2.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  controller: lessConrl_,
                ),
                SpaceBoxHeight(size: 10),
                //end
                TextField(
                  decoration: InputDecoration(
                    hintText: "Name of the Customer",
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 20, horizontal: 20),
                    hintStyle: const TextStyle(
                      color: Colors.black87,
                      fontStyle: FontStyle.italic,
                    ),
                    filled: true,
                    fillColor:
                        Colors.white.withOpacity(0.5), // Transparent with white
                    enabledBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 2.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide:
                          const BorderSide(color: Colors.white70, width: 2.0),
                      borderRadius: BorderRadius.circular(40),
                    ),
                  ),
                  keyboardType: TextInputType.name,
                  controller: customerNameConrl_,
                ),
                const SizedBox(height: 30),
                //start

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
                          // weight = double.tryParse(weightConrl_.text) ?? 0.00;
                          percentage = double.tryParse(perConrl_.text) ?? 0.00;
                          less = double.tryParse(lessConrl_.text) ?? 0.00;
                          custmerName = customerNameConrl_.text;
                          if (less > 1) {
                            less = less / 100;
                          }
                          perResult = percentage - (less);
                          result = weight * (perResult) / 100;
                          // Navigator.push(
                          //   context,
                          //   MaterialPageRoute(
                          //     builder: (context) => SearchBarScreen(
                          //     //  weight_: weight,
                          //     //  percentage_: percentage,
                          //     //  result: result,
                          //     ),
                          //   ),
                          // );

                          showOutputtDialog(context);

                          weightConrl_.clear();
                          perConrl_.clear();
                          lessConrl_.clear();
                          customerNameConrl_.clear();
                        });
                      },
                      child: const Text('Calculate'),
                    ),
                  ),
                ),

                const SizedBox(
                  width: 10,
                ),
                //backup button

                //pasinting
                const SizedBox(height: 10),

                // //card start
                // Container(
                //   height: 270,
                //   width: 500,
                //   child: Card(
                //     elevation: 4.0,
                //     shape: RoundedRectangleBorder(
                //       borderRadius: BorderRadius.circular(10.0),
                //       side: const BorderSide(width: 2.0, color: Colors.white),
                //     ),
                //     child: Padding(
                //       padding: const EdgeInsets.all(8.0),
                //       child: Column(
                //         crossAxisAlignment: CrossAxisAlignment.start,
                //         children: [
                //           Row(
                //             children: [
                //               TextBoxBold(
                //                 text: 'Date   :',
                //               ),
                //               SpaceBox(
                //                 size: 10,
                //               ),
                //               TextBoxNormal(
                //                 text: formattedDate,
                //               ),
                //               SpaceBox(
                //                 size: 10,
                //               ),
                //               TextBoxNormal(
                //                   text:
                //                       "${DateFormat('h:mm a').format(DateTime.now())}."),
                //             ],
                //           ),
                //           Row(
                //             // mainAxisAlignment: MainAxisAlignment.center,
                //             // crossAxisAlignment: CrossAxisAlignment.center,
                //             children: [
                //               TextBoxBold(text: 'Name  :  '),
                //               TextBoxNormal(text: "Name"),
                //             ],
                //           ),
                //           Row(
                //             // mainAxisAlignment: MainAxisAlignment.center,
                //             // crossAxisAlignment: CrossAxisAlignment.center,
                //             children: [
                //               TextBoxBold(text: "Sno    : "),
                //               TextBoxNormal(text: "Sno"),
                //             ],
                //           ),
                //           SpaceBoxHeight(size: 10),
                //           Row(
                //             children: [
                //               ColumnBox(
                //                 weight: weight,
                //                 text: "Kacha.Wt",
                //                 num: 3,
                //               ),
                //               SpaceBox(size: 07),
                //               ColumnBox(
                //                 weight: percentage,
                //                 text: "Touch%",
                //                 num: 2,
                //               ),
                //               SpaceBox(size: 01),
                //               ColumnBox(
                //                 weight: less,
                //                 text: "Less.",
                //                 num: 2,
                //               ),
                //               SpaceBox(size: 01),
                //               ColumnBox(
                //                 weight: result,
                //                 text: "Fine.Wt",
                //                 num: 3,
                //               ),
                //               SpaceBox(size: 01),
                //             ],
                //           ),
                //           SpaceBoxHeight(size: 20),
                //           Row(
                //             children: [
                //               TextBoxBold(text: "KACHA Wt :"),
                //               SpaceBox(size: 20),
                //               TextBoxNormal(text: weight.toStringAsFixed(3)),
                //             ],
                //           ),
                //           Row(
                //             children: [
                //               TextBoxBold(text: "Fine Wt :  "),
                //               SpaceBox(size: 20),
                //               TextBoxNormal(text: result.toStringAsFixed(3)),
                //             ],
                //           ),
                //         ],
                //       ),
                //     ),
                //   ),
                // ),
                // //card end
              ],
            ),
          ),
          Visibility(
            visible: isLoading,
            child: const SpinKitThreeInOut(
              size: 50,
              color: Color.fromARGB(
                255,
                178,
                212,
                240,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ColumnBox extends StatelessWidget {
  String text; // Use camelCase for variable names
  int num;
  double weight;
  ColumnBox({required this.text, required this.num, required this.weight});

  @override
  Widget build(BuildContext context) {
    return Column(
      // mainAxisAlignment: MainAxisAlignment.center,
      // crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        TextBoxBold(text: text),
        const Text("__________"),
        TextBoxNormal(text: weight.toStringAsFixed(num)),
      ],
    );
  }
}

class TextBoxBold extends StatelessWidget {
  String text; // Use camelCase for variable names

  TextBoxBold({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text, // Use the 'text' parameter here
      style: const TextStyle(
        fontWeight: FontWeight.bold,
        fontSize: 18.0,
        color: Colors.black,
      ),
    );
  }
}

class TextBoxNormal extends StatelessWidget {
  String text; // Use camelCase for variable names

  TextBoxNormal({required this.text});

  @override
  Widget build(BuildContext context) {
    return Text(
      text, // Use the 'text' parameter here
      style: const TextStyle(
        fontWeight: FontWeight.normal,
        fontSize: 18.0,
        color: Colors.black,
      ),
    );
  }
}

class SpaceBox extends StatelessWidget {
  double size;

  SpaceBox({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
    );
  }
}

class SpaceBoxHeight extends StatelessWidget {
  double size;

  SpaceBoxHeight({super.key, required this.size});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: size,
    );
  }
}

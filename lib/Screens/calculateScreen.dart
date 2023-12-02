import 'package:flutter/material.dart';
// import 'package:touch/Screens/PrintPage.dart';
import 'dart:ui';

class calculate extends StatefulWidget {
  @override
  calculateState createState() => calculateState();
}

class calculateState extends State<calculate> {
  @override
  TextEditingController WeightConrl_ = TextEditingController();
  TextEditingController perConrl_ = TextEditingController();
  TextEditingController Less_ = TextEditingController();
  double UserName = 0;
  var _user = '';

  Widget build(BuildContext context) => Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
              image: AssetImage("Images/1touch.jpg"), fit: BoxFit.cover),
        ),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.center,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black12,
                Colors.red,
              ],
            ),
          ),
          child: Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              title: const Text(
                "MAHADEV GOLD CHECK",
                style: TextStyle(
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.bold,
                  fontSize: 24.0,
                  color: Color.fromARGB(255, 0, 0, 0),
                ),
              ),
              backgroundColor: Color.fromARGB(255, 253, 3, 3),
              centerTitle: true,
            ),
            body: Container(
              alignment: Alignment.center,
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter the Weight",
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      hintStyle: TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: Colors.white70,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white70, width: 2.0),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white70, width: 2.0),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.number,
                    controller: WeightConrl_,
                  ),
                  SizedBox(height: 10),
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter percentage",
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      hintStyle: TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: Colors.white70,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white70, width: 2.0),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white70, width: 2.0),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.number,
                    controller: perConrl_,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  //taking input how much to subtract
                  TextField(
                    decoration: InputDecoration(
                      hintText: "Enter Less",
                      contentPadding:
                          EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                      hintStyle: TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                      ),
                      filled: true,
                      fillColor: Colors.white70,
                      enabledBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white70, width: 2.0),
                          borderRadius: BorderRadius.circular(10)),
                      focusedBorder: OutlineInputBorder(
                          borderSide:
                              BorderSide(color: Colors.white70, width: 2.0),
                          borderRadius: BorderRadius.circular(10)),
                    ),
                    keyboardType: TextInputType.number,
                    controller: Less_,
                  ),
                  //end
                  SizedBox(
                    height: 20,
                  ),
                  TextButtonTheme(
                    data: TextButtonThemeData(
                      style: ButtonStyle(
                        foregroundColor:
                            MaterialStateProperty.all<Color>(Colors.white),
                        backgroundColor:
                            MaterialStateProperty.all<Color>(Colors.red),
                        padding: MaterialStateProperty.all<EdgeInsets>(
                          EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                        ),
                        shape:
                            MaterialStateProperty.all<RoundedRectangleBorder>(
                          RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(4.0),
                          ),
                        ),
                      ),
                    ),
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          double weight =
                              double.tryParse(WeightConrl_.text) ?? 0.00;
                          double percentage =
                              double.tryParse(perConrl_.text) ?? 0.00;
                          double Less = double.tryParse(Less_.text) ?? 0.00;
                          double result =
                              weight * (percentage - (Less / 100)) / 100;
                          UserName = result;
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

                          WeightConrl_.clear();
                          perConrl_.clear();
                          Less_.clear();
                        });
                      },
                      child: Text('Calculate'),
                    ),
                  ),
                  //pasinting
                  SizedBox(height: 10),
                  Card(
                    elevation: 4.0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                      side: BorderSide(width: 2.0, color: Colors.white),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Text(
                        UserName.toStringAsFixed(3),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                          color: Colors.black,
                        ),
                      ),
                    ),
                  ),

                  //
                ],
              ),
            ),
          ),
        ),
      );
}

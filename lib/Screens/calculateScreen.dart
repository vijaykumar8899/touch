import 'package:flutter/material.dart';

class calculateScreen extends StatefulWidget {
  const calculateScreen({super.key});

  @override
  State<calculateScreen> createState() => _calculateScreenState();
}

class _calculateScreenState extends State<calculateScreen> {
  TextEditingController weightConrl_ = TextEditingController();
  TextEditingController perConrl_ = TextEditingController();
  TextEditingController lessConrl_ = TextEditingController();
  double result = 0;
  double weight = 0.0;
  double less = 0.0;
  double percentage = 0.0;
  String weight_temp = '';

  lessControllerInitialize() {
    weight = double.tryParse(weightConrl_.text) ?? 0.00;

    lessConrl_.text = weight >= 5.0 ? '20.000' : '25.000';
    print(lessConrl_.text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "MAHADEV GOLD CHECK",
          style: TextStyle(
            fontStyle: FontStyle.italic,
            fontWeight: FontWeight.bold,
            fontSize: 24.0,
            color: Colors.black,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: Container(
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
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
                filled: true,
                fillColor:
                    Colors.white.withOpacity(0.5), // Transparent with white
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                  borderRadius: BorderRadius.circular(40),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              keyboardType: TextInputType.number,
              controller: weightConrl_,
              onChanged: (_) {
                lessControllerInitialize();
              },
            ),

            const SizedBox(height: 10),

            TextField(
              decoration: InputDecoration(
                hintText: "Percentage",
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                hintStyle: const TextStyle(
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
                filled: true,
                fillColor:
                    Color.fromARGB(100, 178, 212, 240), // Light blue color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                  borderRadius: BorderRadius.circular(40),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              keyboardType: TextInputType.number,
              controller: perConrl_,
            ),

            const SizedBox(
              height: 10,
            ),
            TextField(
              decoration: InputDecoration(
                hintText: "Less",
                contentPadding:
                    EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                hintStyle: TextStyle(
                  color: Colors.black87,
                  fontStyle: FontStyle.italic,
                ),
                filled: true,
                fillColor: Colors.pink[100], // Pink color
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                  borderRadius: BorderRadius.circular(40),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.white70, width: 2.0),
                  borderRadius: BorderRadius.circular(40),
                ),
              ),
              keyboardType: TextInputType.number,
              controller: lessConrl_,
            ),

            //end

            //start
            const SizedBox(
              height: 20,
            ),
            TextButtonTheme(
              data: TextButtonThemeData(
                style: ButtonStyle(
                  foregroundColor:
                      MaterialStateProperty.all<Color>(Colors.white),
                  backgroundColor: MaterialStateProperty.all<Color>(
                      const Color.fromARGB(255, 2, 69, 124)),
                  padding: MaterialStateProperty.all<EdgeInsets>(
                    EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
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
                  setState(() {
                    // weight = double.tryParse(weightConrl_.text) ?? 0.00;
                    percentage = double.tryParse(perConrl_.text) ?? 0.00;
                    less = double.tryParse(lessConrl_.text) ?? 0.00;
                    result = weight * (percentage - (less / 100)) / 100;
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

                    weightConrl_.clear();
                    perConrl_.clear();
                    lessConrl_.clear();
                  });
                },
                child: const Text('Calculate'),
              ),
            ),
            //pasinting
            const SizedBox(height: 10),
            Card(
              elevation: 4.0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
                side: BorderSide(width: 2.0, color: Colors.white),
              ),
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    Text(weight.toStringAsFixed(3)),
                    Text(percentage.toStringAsFixed(3)),
                    Text(less.toStringAsFixed(3)),
                    Text(
                      result.toStringAsFixed(3),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18.0,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            //
          ],
        ),
      ),
    );
  }
}
import 'package:flutter/material.dart';

class DevelopersSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Container(
          height: 400,
          width: 400,
          margin: EdgeInsets.all(16.0),
          padding: EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            // color: Colors.orangeAccent,
            border: Border.all(
              color: Colors.black,
              width: 2.0,
            ),
            borderRadius: BorderRadius.circular(10.0),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Center vertically
              crossAxisAlignment:
                  CrossAxisAlignment.center, // Center horizontally
              children: [
                DeveloperInfo(
                  name: 'Vijay Kumar Vellanki',
                  email: 'thvtechnosolutions@gmail.com',
                  phone: '9150987651',
                ),
                SizedBox(height: 16.0),
                DeveloperInfo(
                  name: 'Tharun Rachabanti',
                  email: 'thvtechnosolutions@gmail.com',
                  phone: '9347644178',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class DeveloperInfo extends StatelessWidget {
  final String name;
  final String email;
  final String phone;

  DeveloperInfo({
    required this.name,
    required this.email,
    required this.phone,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.black,
          width: 1.0,
        ),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center, // Center vertically
          crossAxisAlignment: CrossAxisAlignment.center, // Center horizontally
          children: [
            Text(
              'Name: $name',
              style: TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            Text('Email: $email'),
            Text('Phone: $phone'),
          ],
        ),
      ),
    );
  }
}

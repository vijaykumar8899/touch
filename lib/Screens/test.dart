import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class DisplayDataList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('touchCollection')
          .doc('vijay')
          .snapshots(),
      builder: (BuildContext context,
          AsyncSnapshot<DocumentSnapshot<Map<String, dynamic>>> snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Text('Error: ${snapshot.error}'),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(
            child: Text('No Data Available'),
          );
        }

        Map<String, dynamic>? data = snapshot.data!.data();
        if (data == null || data.isEmpty) {
          return Center(
            child: Text('No Data Available'),
          );
        }

        List<Widget> children = [];

        data.keys.forEach((key) {
          FirebaseFirestore.instance
              .collection('touchCollection')
              .doc('vijay')
              .collection(key)
              .get()
              .then((QuerySnapshot querySnapshot) {
            querySnapshot.docs.forEach((doc) {
              Map<String, dynamic> docData = doc.data() as Map<String, dynamic>;
              // Extract fields and display accordingly
              String name = docData['name'] ?? '';
              int age = docData['age'] ?? 0;
              double weight = docData['weight'] ?? 0.0;

              children.add(
                ListTile(
                  title: Text(
                    'Name: $name',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Age: $age'),
                      Text('Weight: $weight'),
                      // Add more fields as needed
                    ],
                  ),
                  // Customize the appearance here as needed
                  tileColor: Colors.white,
                  onTap: () {
                    // Implement onTap if needed
                  },
                ),
              );
            });
          });
        });

        return ListView(
          children: children.isNotEmpty
              ? children
              : [
                  Center(
                    child: Text('No Data Available'),
                  ),
                ],
        );
      },
    );
  }
}

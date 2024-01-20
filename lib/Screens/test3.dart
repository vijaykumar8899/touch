import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DisplayDataFromFirebase extends StatelessWidget {
  var stream_ = FirebaseFirestore.instance
      .collection('touchCollection')
      .doc('vijay')
      .collection('09-12-2023') // Replace with your date
      .snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Display Data'),
      ),
      body: StreamBuilder(
        stream: stream_,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No data available'));
          }

          return ListView.builder(
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (BuildContext context, int index) {
              var doc = snapshot.data!.docs[index];
              Timestamp timeStamp = doc['timeStamp'] as Timestamp;
              // Access fields from the document and display them in ListTile
              return ListTile(
                title: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Weight: ${doc['weight']}'),
                    Text('Less: ${doc['less']}'),
                    Text('Percentage: ${doc['percentage']}'),
                    Text('Result: ${doc['result']}'),
                    Text('Name: ${doc['name']}'),
                    Text('Image URL: ${doc['image']}'),
                    Text('Timestamp: ${doc['timeStamp']}'),
                    // Add more fields as needed
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

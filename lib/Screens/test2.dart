import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';
import 'package:touch/HelperFunctions/Toast.dart';
import 'package:touch/Screens/test.dart';
 
class DataEntryScreen extends StatelessWidget {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController weightController = TextEditingController();

  int num = 1;

  void saveData() async {
    ToastMessage.toast_('inside');
    String currentDate = DateTime.now()
        .toString()
        .split(' ')[0]; // Get today's date in format 'yyyy-mm-dd'
    ToastMessage.toast_(currentDate);

    try {
      FirebaseFirestore firebase = FirebaseFirestore.instance;

      await firebase
          .collection('touchCollection')
          .doc('vijay')
          .collection(currentDate)
          .add({
        'name': nameController.text,
        'age': ageController.text,
        'weight': weightController.text,
        'TimeStamp': Timestamp.now(),
      }).then((value) => ToastMessage.toast_('sucesss'));
    } catch (e) {
      ToastMessage.toast_(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Data Entry'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: ageController,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: weightController,
              decoration: InputDecoration(labelText: 'Weight'),
            ),
            ElevatedButton(
              onPressed: () {
                saveData();
                // Clear text fields after saving data
                nameController.clear();
                ageController.clear();
                weightController.clear();

                Get.to(DisplayDataList());
              },
              child: Text('Save'),
            ),
          ],
        ),
      ),
    );
  }
}

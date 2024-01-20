import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class RecordsScreen extends StatefulWidget {
  @override
  State<RecordsScreen> createState() => _RecordsScreenState();
}

class _RecordsScreenState extends State<RecordsScreen> {
  late List<bool> isArrowPressedList;
  int numberOfArrowIcons = 10;

  @override
  void initState() {
    super.initState();
    isArrowPressedList = List.filled(numberOfArrowIcons, false);
  }

  Future<QuerySnapshot<Map<String, dynamic>>> fetchAllDocuments() async {
    return await FirebaseFirestore.instance
        .collection('touchCollection')
        .doc('vijay')
        .collection('allRecordCalculation')
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text(
          "All Records",
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
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 178, 212, 240), Colors.white],
            stops: [0.3, 1.0],
          ),
        ),
        child: FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
          future: fetchAllDocuments(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator(),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text('Error: ${snapshot.error}'),
              );
            } else if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
              return Center(
                child: Text('No documents found'),
              );
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  final document = snapshot.data!.docs[index];
                  final documentID = document.id;
                  final documentData = document.data() as Map<String, dynamic>;

                  numberOfArrowIcons = snapshot.data!.docs.length;
                  // print(numberOfArrowIcons);
                  String totalWeight = documentData['totalWeight'];
                  // print('document : $document');

                  // Display the document ID and its data
                  return Column(
                    children: [
                      DayDisplayContainer(
                        date: documentID,
                        totalWeight: totalWeight,
                        isArrowPressed: isArrowPressedList[index],
                        onArrowPressed: () {
                          setState(() {
                            isArrowPressedList[index] =
                                !isArrowPressedList[index];
                          });
                        },
                      ),
                      if (isArrowPressedList[index])
                        SizedBox(
                          height: 500, // Set the height
                          width: double.infinity,
                          child: DisplayDataFromFirebase(
                              collectionPath: documentID),
                        ), // Show when arrow is pressed
                    ],
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class DayDisplayContainer extends StatefulWidget {
  final String date;
  final String totalWeight;
  final bool isArrowPressed;
  final VoidCallback onArrowPressed;

  const DayDisplayContainer({
    required this.date,
    required this.totalWeight,
    required this.isArrowPressed,
    required this.onArrowPressed,
    Key? key,
  }) : super(key: key);

  @override
  State<DayDisplayContainer> createState() => _DayDisplayContainerState();
}

class _DayDisplayContainerState extends State<DayDisplayContainer> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 50,
          width: 350,
          margin: EdgeInsets.all(8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.all(Radius.circular(5)),
            color: Colors.pink[100],
            border: Border.all(
              color: Colors.white70,
              width: 1.5,
            ),
          ),
          padding: const EdgeInsets.all(5),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                widget.date,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              Text(
                widget.totalWeight,
                style: const TextStyle(
                  fontWeight: FontWeight.normal,
                  fontSize: 20,
                ),
              ),
              IconButton(
                onPressed: widget.onArrowPressed,
                icon: Icon(
                  widget.isArrowPressed
                      ? Icons.arrow_upward_sharp
                      : Icons.arrow_downward_sharp,
                  size: 30,
                  color: widget.isArrowPressed
                      ? Colors.grey
                      : const Color.fromARGB(255, 2, 69, 124),
                  //arrow color here
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class DisplayDataFromFirebase extends StatelessWidget {
  var collectionPath;

  DisplayDataFromFirebase({super.key, required this.collectionPath});

  @override
  Widget build(BuildContext context) {
    var stream_ = FirebaseFirestore.instance
        .collection('touchCollection')
        .doc('vijay')
        .collection(collectionPath) // Replace with your date
        .orderBy('timeStamp', descending: true)
        .snapshots();
    // print('collectionPath : $collectionPath');

    void _showImagePopup(BuildContext context, String imageUrl) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 400,
              height: 400, // Specify the height here
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Expanded(
                child: PhotoView(
                  imageProvider: CachedNetworkImageProvider(imageUrl), 
                  backgroundDecoration: const BoxDecoration(
                    color: Colors.transparent,
                  ),
                  minScale: PhotoViewComputedScale.contained,
                  maxScale: PhotoViewComputedScale.covered * 2,
                ),
              ),
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color.fromARGB(255, 178, 212, 240), Colors.white],
            stops: [0.3, 1.0],
          ),
        ),
        child: StreamBuilder(
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
                // Convert Firestore Timestamp to DateTime
                DateTime dateTime = timeStamp.toDate();

// Format DateTime object to a string in your desired format
                String formattedDateTime =
                    DateFormat('d MMMM y').add_jms().format(dateTime);
                String url = doc['image'];

                // Access fields from the document and display them in ListTile
                return ListTile(
                  title: Row(
                    children: [
                      Text(
                        '${doc['order']}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        width: 15,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Name: ${doc['name']}'),
                          Text('Weight: ${doc['weight']}'),
                          Text('Percentage: ${doc['percentage']}'),
                          Text('Less: ${doc['less']}'),
                          Text('Result: ${doc['result']}'),
                          Text(formattedDateTime),
                        ],
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      if (doc['image'].toString().isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _showImagePopup(context, url);
                          },
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: Image.network(
                              doc['image'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                    ],
                  ),
                  subtitle: const SizedBox(
                    height: 20,
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

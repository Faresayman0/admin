import 'dart:async';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutterfirebase/view/veiw_line.dart';
import 'package:flutterfirebase/services/station/add_station.dart';
import 'package:flutterfirebase/view/view_complaint.dart';

class StationName extends StatefulWidget {
  const StationName({Key? key}) : super(key: key);

  @override
  State<StationName> createState() => _StationNameState();
}

class _StationNameState extends State<StationName> {
  DocumentSnapshot? stationDocument;
  bool isLoading = true;
  int totalComplaints = 0;
  late StreamSubscription<QuerySnapshot<Map<String, dynamic>>>
      complaintsSubscription;
  bool newComplaint = false;

  @override
  void initState() {
    super.initState();
    _getStationName();
    _getTotalComplaints();
    _listenForComplaints();
    print(FirebaseAuth.instance.currentUser!.uid);
  }

  @override
  void dispose() {
    complaintsSubscription.cancel();
    super.dispose();
  }

  Future<void> _getStationName() async {
    try {
      final querySnapshot = await FirebaseFirestore.instance
          .collection("المواقف")
          .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        stationDocument = querySnapshot.docs.first;
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching station name: $e");
    }
  }

  Future<void> _getTotalComplaints() async {
    try {
      final complaintSnapshot = await FirebaseFirestore.instance
          .collection('messages')
          .where('stationId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
          .get();

      setState(() {
        totalComplaints = complaintSnapshot.docs.length;
      });
    } catch (e) {
      print("Error fetching complaints count: $e");
    }
  }

  void _listenForComplaints() {
    complaintsSubscription = FirebaseFirestore.instance
        .collection('messages')
        .where('userId', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .snapshots()
        .listen((QuerySnapshot<Map<String, dynamic>> snapshot) {
      setState(() {
        totalComplaints = snapshot.docs.length;
        newComplaint = snapshot.docChanges.isNotEmpty;
      });
    });
  }

  void _navigateToAddStation() async {
    setState(() {
      isLoading = true;
    });

    await Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return const AddStation();
    }));

    setState(() {
      isLoading = false;
    });
  }

  void _navigateToViewComplaint() {
    setState(() {
      newComplaint = false;
    });

    Navigator.of(context).push(MaterialPageRoute(builder: (context) {
      return ViewComplaint();
    }));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          if (stationDocument == null)
            FloatingActionButton.extended(
              backgroundColor: Colors.blue,
              onPressed: _navigateToAddStation,
              label: const Text('اضافة موقفك'),
              icon: const Icon(Icons.add),
            ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'viewComplaints',
            backgroundColor: Colors.blue,
            onPressed: _navigateToViewComplaint,
            label: Text(
              'رؤية الشكاوي ',
              style: TextStyle(
                color: Colors.white,
              ),
            ),
            icon: Icon(
              newComplaint ? Icons.notifications_active : Icons.notifications,
              color: Colors.white,
            ),
          ),
        ],
      ),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("اسم الموقف: ${stationDocument?["name"] ?? ""}"),
        actions: [
          IconButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.of(context)
                  .pushNamedAndRemoveUntil("login", (route) => false);
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: isLoading
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.blue,
                  ),
                  SizedBox(
                    height: 5,
                  ),
                  Text(" جاري التحميل "),
                ],
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 500,
              ),
              itemCount: stationDocument != null ? 1 : 0,
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () {
                    Navigator.of(context)
                        .push(MaterialPageRoute(builder: (context) {
                      return ViewLine(
                        docId: stationDocument?.id ?? "",
                      );
                    }));
                  },
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        height: 60,
                      ),
                      Card(
                        elevation: 20,
                        child: Column(children: [
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (context) {
                                  return ViewLine(
                                    docId: stationDocument?.id ?? "",
                                  );
                                }),
                              );
                            },
                            child: const Text(
                              "رؤية الخطوط التي توجد في",
                              style: TextStyle(
                                fontSize: 24,
                                color: Colors.blue,
                              ),
                            ),
                          ),
                          Text(
                            "${stationDocument?["name"] ?? ""}",
                            style: const TextStyle(fontSize: 34),
                          ),
                        ]),
                      ),
                    ],
                  ),
                );
              },
            ),
    );
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/view/veiw_line.dart';
import 'package:flutterfirebase/services/station/add_station.dart';
import 'package:flutterfirebase/view/view_complaint.dart';

class StationName extends StatefulWidget {
  const StationName({super.key});

  @override
  State<StationName> createState() => _StationNameState();
}

class _StationNameState extends State<StationName> {
  DocumentSnapshot? stationDocument;
  bool isLoading = true;

  getStationName() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("المواقف")
        .where("id", isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      stationDocument = querySnapshot.docs.first;
    }

    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getStationName();
    super.initState();
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
              onPressed: () async {
                setState(() {
                  isLoading = true;
                });
                await Navigator.of(context)
                    .push(MaterialPageRoute(builder: (context) {
                  return const AddStation();
                }));
                setState(() {
                  isLoading = false;
                });
              },
              label: const Text('اضافة موقفك'),
              icon: const Icon(Icons.add),
            ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'addStation',
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.of(context).push(MaterialPageRoute(builder: (context) {
                return const ViewComplaint();
              }));
            },
            label: const Text('رؤية الشكاوي'),
            icon: const Icon(Icons.notifications),
          )
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
      body: isLoading == true
          ? const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(
                    height: 5,
                  ),
                  Text("is loading....."),
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
                              "رؤية الخطوط التي توجد في ",
                              style: TextStyle(fontSize: 30),
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

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/services/cars/add_cars.dart';
import 'package:flutterfirebase/services/cars/edit_cars.dart';
import 'package:flutterfirebase/view/view_complaint.dart';

class ViewCars extends StatefulWidget {
  const ViewCars({super.key, required this.lineId, required this.stationId});

  final String lineId;
  final String stationId;

  @override
  State<ViewCars> createState() => _ViewCarsState();
}

class _ViewCarsState extends State<ViewCars> {
  List<QueryDocumentSnapshot> carsAvailable = [];
  int totalNumberOfCars = 0;
  bool isLoading = true;

  Future<void> getData() async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("المواقف")
        .doc(widget.stationId)
        .collection("line")
        .doc(widget.lineId)
        .collection("car")
        .orderBy("timestamp", descending: false)
        .get();

    carsAvailable = querySnapshot.docs;
    totalNumberOfCars = carsAvailable.length;
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton.extended(
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.of(context).pushReplacement(MaterialPageRoute(
                builder: (context) {
                  return AddCar(
                    lineId: widget.lineId,
                    stationId: widget.stationId,
                  );
                },
              ));
            },
            label: const Text('اضافة سيارة'),
            icon: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton.extended(
            heroTag: 'addCar',
            backgroundColor: Colors.blue,
            onPressed: () {
              Navigator.of(context)
                  .pushReplacement(MaterialPageRoute(builder: (context) {
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
        title: Text("العربيات المتاحة: $totalNumberOfCars"),
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
                  Text("يتم التحميل....."),
                ],
              ),
            )
          : GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 1,
                mainAxisExtent: 100,
              ),
              itemCount: carsAvailable.length,
              itemBuilder: (context, i) {
                return InkWell(
                  onTap: () {},
                  child: Card(
                    child: Column(children: [
                      Text(
                        "${carsAvailable[i]["numberOfCar"]}",
                        style: const TextStyle(fontSize: 20),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          IconButton(
                            onPressed: () {
                              AwesomeDialog(
                                btnCancelText: "حذف",
                                context: context,
                                dialogType: DialogType.warning,
                                animType: AnimType.rightSlide,
                                desc:
                                    'هل تريد حذف ${carsAvailable[i]["numberOfCar"]}',
                                btnCancelOnPress: () async {
                                  await FirebaseFirestore.instance
                                      .collection("المواقف")
                                      .doc(widget.stationId)
                                      .collection("line")
                                      .doc(widget.lineId)
                                      .collection("car")
                                      .doc(carsAvailable[i].id)
                                      .delete();
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) {
                                      return ViewCars(
                                        lineId: widget.lineId,
                                        stationId: widget.stationId,
                                      );
                                    }),
                                  );
                                },
                              ).show();
                            },
                            icon: const Icon(Icons.delete),
                          ),
                          IconButton(
                            onPressed: () {
                              AwesomeDialog(
                                context: context,
                                dialogType: DialogType.warning,
                                animType: AnimType.rightSlide,
                                desc:
                                    'هل تريد التعديل على ${carsAvailable[i]["numberOfCar"]}',
                                btnOkText: "تعديل",
                                btnOkOnPress: () {
                                  Navigator.of(context).pushReplacement(
                                    MaterialPageRoute(builder: (context) {
                                      return EditCar(
                                        lineId: widget.lineId,
                                        stationId: widget.stationId,
                                        oldNumberOfCar: carsAvailable[i]
                                            ["numberOfCar"],
                                        carDocId: carsAvailable[i].id,
                                      );
                                    }),
                                  );
                                },
                              ).show();
                            },
                            icon: const Icon(Icons.edit),
                          ),
                        ],
                      ),
                    ]),
                  ),
                );
              },
            ),
    );
  }
}

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutterfirebase/services/lines/add_line.dart';
import 'package:flutterfirebase/services/lines/edit_line.dart';
import 'package:flutterfirebase/view/view_cars.dart';
import 'package:flutterfirebase/view/view_complaint.dart';

class ViewLine extends StatefulWidget {
  const ViewLine({Key? key, required this.docId}) : super(key: key);

  final String docId;

  @override
  State<ViewLine> createState() => _ViewLineState();
}

class _ViewLineState extends State<ViewLine> {
  late Future<List<QueryDocumentSnapshot>> linesFuture;
  late String stationId;
  final ScrollController _scrollController = ScrollController();
  bool _showFloatingButtons = true;

  @override
  void initState() {
    super.initState();
    linesFuture = getData();

    _scrollController.addListener(() {
      if (_scrollController.position.userScrollDirection ==
          ScrollDirection.forward) {
        setState(() {
          _showFloatingButtons = true;
        });
      } else if (_scrollController.position.userScrollDirection ==
          ScrollDirection.reverse) {
        setState(() {
          _showFloatingButtons = false;
        });
      }
    });
  }

  Future<List<QueryDocumentSnapshot>> getData() async {
    DocumentSnapshot stationSnapshot = await FirebaseFirestore.instance
        .collection("المواقف")
        .doc(widget.docId)
        .get();

    stationId = widget.docId;

    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("المواقف")
        .doc(widget.docId)
        .collection("line")
        .get();

    return querySnapshot.docs.toList();
  }

  Widget buildGridItem(QueryDocumentSnapshot line) {
    return InkWell(
      onTap: () => navigateToViewCars(line.id),
      child: Card(
        elevation: 3,
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              child: Image.asset(
                "asset/images/micrbus.png",
                height: 120,
                fit: BoxFit.contain,
              ),
            ),
            Text(
              "${line["nameLine"]}",
              style: const TextStyle(fontSize: 20),
            ),
            Text(
              "${line["priceLine"]}ج",
              style: const TextStyle(fontSize: 20),
            ),
            buildActionButtons(line),
          ],
        ),
      ),
    );
  }

  Widget buildActionButtons(QueryDocumentSnapshot line) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        buildActionButton(
          onPressed: () => showDeleteDialog(line),
          icon: Icons.delete,
        ),
        buildActionButton(
          onPressed: () => showEditDialog(line),
          icon: Icons.edit,
        ),
      ],
    );
  }

  Widget buildActionButton({VoidCallback? onPressed, IconData? icon}) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(icon),
    );
  }

  Future<void> showDeleteDialog(QueryDocumentSnapshot line) async {
    await AwesomeDialog(
      btnCancelText: "حذف",
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      desc: 'هل تريد حذف ${line["nameLine"]}',
      btnCancelOnPress: () async {
        await deleteLine(line.id);
        setState(() {
          linesFuture = getData();
        });
      },
    ).show();
  }

  Future<void> showEditDialog(QueryDocumentSnapshot line) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.warning,
      animType: AnimType.rightSlide,
      desc: 'هل تريد التعديل على ${line["nameLine"]}',
      btnOkText: "تعديل",
      btnOkOnPress: () {
        navigateToEditLine(line.id, line["nameLine"], line["priceLine"]);
      },
    ).show();
  }

  Future<void> deleteLine(String lineId) async {
    await FirebaseFirestore.instance
        .collection("المواقف")
        .doc(widget.docId)
        .collection("line")
        .doc(lineId)
        .delete();
  }

  void navigateToViewCars(String lineId) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return ViewCars(lineId: lineId, stationId: stationId);
        },
      ),
    );
  }

  void navigateToEditLine(String lineId, String oldName, String oldPrice) {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return EditLine(
            stationId: lineId,
            docId: widget.docId,
            oldName: oldName,
            oldPrice: oldPrice,
          );
        },
      ),
    );
  }

  void navigateToAddLine() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (context) {
          return AddLine(docId: widget.docId);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return [
            SliverAppBar(
              expandedHeight: 0.0,
              floating: false,
              pinned: true,
              title: Container(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: FutureBuilder<List<QueryDocumentSnapshot>>(
                  future: linesFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator(
                        color: Colors.blue,
                      );
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else {
                      return Text(
                        "الخطوط المتاحة: ${snapshot.data!.length}",
                      );
                    }
                  },
                ),
              ),
            ),
          ];
        },
        body: FutureBuilder<List<QueryDocumentSnapshot>>(
          future: linesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              );
            } else if (snapshot.hasError) {
              return Center(
                child: Text("Error: ${snapshot.error}"),
              );
            } else {
              return GridView.builder(
                physics: BouncingScrollPhysics(),
                padding: EdgeInsets.only(top: 6),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisExtent: 260,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, i) {
                  return buildGridItem(snapshot.data![i]);
                },
              );
            }
          },
        ),
      ),
      floatingActionButton: AnimatedOpacity(
        opacity: _showFloatingButtons ? 1.0 : 0.0,
        duration: Duration(milliseconds: 500),
        child: _showFloatingButtons ? FloatingButton() : SizedBox(),
      ),
    );
  }

  Column FloatingButton() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton.extended(
          backgroundColor: Colors.blue,
          onPressed: navigateToAddLine,
          label: const Text(
            'اضافة خط جديد',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 16),
        FloatingActionButton.extended(
          heroTag: 'addLine',
          backgroundColor: Colors.blue,
          onPressed: () {
            Navigator.of(context)
                .pushReplacement(MaterialPageRoute(builder: (context) {
              return ViewComplaint();
            }));
          },
          label: const Text(
            'رؤية الشكاوي',
            style: TextStyle(color: Colors.white),
          ),
          icon: const Icon(
            Icons.notifications,
            color: Colors.white,
          ),
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterfirebase/components/custom_button_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutterfirebase/view/view_cars.dart';

class CarNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final String hintText;
  final int maxLength;
  final TextInputType keyboardtype;
  final FocusNode? nextFocusNode;

  const CarNumberInput({
    super.key,
    required this.controller,
    required this.labelText,
    required this.hintText,
    required this.maxLength,
    this.nextFocusNode,
    required this.keyboardtype,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: controller,
        maxLength: maxLength,
        textAlign: TextAlign.center, // Center the text
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
        ),
        keyboardType: keyboardtype,
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'الرجاء إدخال $labelText';
          }
          return null;
        },
        onChanged: (value) {
          // You can add additional logic here if needed
        },
        onEditingComplete: () {
          if (nextFocusNode != null) {
            FocusScope.of(context).requestFocus(nextFocusNode);
          }
        },
        textInputAction:
            nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
      ),
    );
  }
}

class AddCar extends StatefulWidget {
  const AddCar({
    super.key,
    required this.stationId,
    required this.lineId,
  });

  final String stationId;
  final String lineId;

  @override
  State<AddCar> createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  TextEditingController firstController = TextEditingController();
  TextEditingController secondController = TextEditingController();
  TextEditingController thirdController = TextEditingController();
  TextEditingController digitController = TextEditingController();

  FocusNode secondFocusNode = FocusNode();
  FocusNode thirdFocusNode = FocusNode();
  FocusNode digitFocusNode = FocusNode();

  GlobalKey<FormState> formstate = GlobalKey();

  bool isLoading = false;

  Future<void> addCar() async {
    CollectionReference carsCollection = FirebaseFirestore.instance
        .collection('المواقف')
        .doc(widget.stationId)
        .collection('line')
        .doc(widget.lineId)
        .collection('car');

    CollectionReference allCarsCollection =
        FirebaseFirestore.instance.collection('AllCars');

    if (formstate.currentState!.validate()) {
      try {
        String carNumber =
            '${firstController.text.trim()}${secondController.text.trim()}${thirdController.text.trim()}${digitController.text.trim()}';

        QuerySnapshot existingAllCars = await allCarsCollection
            .where('numberOfCar', isEqualTo: carNumber)
            .get();

        QuerySnapshot existingCars = await carsCollection
            .where('numberOfCar', isEqualTo: carNumber)
            .get();

        if (existingAllCars.docs.isNotEmpty) {
          if (existingCars.docs.isEmpty) {
            await carsCollection.add({
              'numberOfCar': carNumber,
              'timestamp': FieldValue.serverTimestamp(),
            });

            showSuccessDialog('تمت إضافة السيارة بنجاح في المواقف');
          } else {
            showErrorDialog('السيارة موجودة بالفعل في المواقف');
          }
        } else {
          await carsCollection.add({
            'numberOfCar': carNumber,
            'timestamp': FieldValue.serverTimestamp(),
          });

          await allCarsCollection.add({
            'numberOfCar': carNumber,
            'timestamp': FieldValue.serverTimestamp(),
          });

          showSuccessDialog('تمت إضافة السيارة بنجاح في المواقف و AllCars');
        }

        Navigator.pop(context);

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) {
              return ViewCars(
                lineId: widget.lineId,
                stationId: widget.stationId,
              );
            },
          ),
        );
      } catch (e) {
        showErrorDialog('حدثت مشكلة أثناء إضافة السيارة');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  void showErrorDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      desc: message,
      btnCancelOnPress: () {},
    ).show();
  }

  void showSuccessDialog(String message) {
    AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      desc: message,
      btnOkOnPress: () {},
    ).show();
  }

  @override
  void dispose() {
    firstController.dispose();
    secondController.dispose();
    thirdController.dispose();
    digitController.dispose();
    secondFocusNode.dispose();
    thirdFocusNode.dispose();
    digitFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.blue,
          title: const Text("تسجيل دخول لسيارة"),
        ),
        body: Form(
          key: formstate,
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      child: Row(
                        children: [
                          CarNumberInput(
                            controller: firstController,
                            labelText: 'الحرف الأول',
                            hintText: 'أ',
                            maxLength: 1,
                            nextFocusNode: secondFocusNode,
                            keyboardtype: TextInputType.text,
                          ),
                          const SizedBox(width: 8),
                          CarNumberInput(
                            controller: secondController,
                            labelText: 'الحرف الثاني',
                            hintText: 'ب',
                            maxLength: 1,
                            nextFocusNode: thirdFocusNode,
                            keyboardtype: TextInputType.text,
                          ),
                          const SizedBox(width: 8),
                          CarNumberInput(
                            controller: thirdController,
                            labelText: 'الحرف الثالث',
                            hintText: 'ت',
                            maxLength: 1,
                            nextFocusNode: digitFocusNode,
                            keyboardtype: TextInputType.text,
                          ),
                          const SizedBox(width: 8),
                          CarNumberInput(
                            keyboardtype: TextInputType.number,
                            controller: digitController,
                            labelText: 'الأرقام',
                            hintText: '123',
                            maxLength: 3,
                            nextFocusNode: null,
                          ),
                        ],
                      ),
                    ),
                    CustomButtonAuth(
                      child: "إضافة",
                      onPressed: addCar,
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

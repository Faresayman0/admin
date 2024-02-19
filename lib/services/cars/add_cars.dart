import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutterfirebase/components/custom_button_auth.dart';
import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:flutterfirebase/view/view_cars.dart';

class CarNumberInput extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final int maxLength;
  final TextInputType keyboardType;
  final FocusNode? nextFocusNode;
  final bool autofocus;

  const CarNumberInput({
    Key? key,
    required this.controller,
    required this.labelText,
    required this.maxLength,
    this.nextFocusNode,
    required this.keyboardType,
    this.autofocus = false,
  });

  void _moveToNextField(FocusNode? focusNode, BuildContext context) {
    if (focusNode != null) {
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        autofocus: autofocus,
        controller: controller,
        maxLength: maxLength,
        textAlign: TextAlign.center,
        decoration: InputDecoration(
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
          labelText: labelText,
          labelStyle: TextStyle(
            color: Colors.blue,
            fontSize: 10,
          ),
        ),
        cursorColor: Colors.blue,
        keyboardType: keyboardType,
        validator: (val) {
          if (val == null || val.trim().isEmpty) {
            return 'الرجاء ادخال $labelText';
          }
          return null;
        },
        onChanged: (value) {
          if (value.length == maxLength && nextFocusNode != null) {
            _moveToNextField(nextFocusNode, context);
          }
        },
        onEditingComplete: () {
          if (nextFocusNode != null) {
            _moveToNextField(nextFocusNode, context);
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
    Key? key,
    required this.stationId,
    required this.lineId,
  });

  final String stationId;
  final String lineId;

  @override
  State<AddCar> createState() => _AddCarState();
}

class _AddCarState extends State<AddCar> {
  late TextEditingController firstController;
  late TextEditingController secondController;
  late TextEditingController thirdController;
  late TextEditingController digitController;

  late FocusNode firstFocusNode;
  late FocusNode secondFocusNode;
  late FocusNode thirdFocusNode;
  late FocusNode digitFocusNode;

  GlobalKey<FormState> formState = GlobalKey();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();

    firstController = TextEditingController();
    secondController = TextEditingController();
    thirdController = TextEditingController();
    digitController = TextEditingController();

    firstFocusNode = FocusNode();
    secondFocusNode = FocusNode();
    thirdFocusNode = FocusNode();
    digitFocusNode = FocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (mounted && !firstFocusNode.hasFocus) {
      FocusScope.of(context).requestFocus(firstFocusNode);
    }
  }

  @override
  void dispose() {
    firstController.dispose();
    secondController.dispose();
    thirdController.dispose();
    digitController.dispose();
    firstFocusNode.dispose();
    secondFocusNode.dispose();
    thirdFocusNode.dispose();
    digitFocusNode.dispose();
    super.dispose();
  }

  Future<void> addCar() async {
    CollectionReference carsCollection = FirebaseFirestore.instance
        .collection('المواقف')
        .doc(widget.stationId)
        .collection('line')
        .doc(widget.lineId)
        .collection('car');

    CollectionReference allCarsCollection =
        FirebaseFirestore.instance.collection('AllCars');

    if (formState.currentState!.validate()) {
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

            await showSuccessDialog('تمت السيارة بنجاح');
          } else {
            await showErrorDialog('السيارة موجودة بالفعل');
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

          await showSuccessDialog('تمت اضافة السيارة بنجاح');
        }
      } catch (e) {
        await showErrorDialog('حدثت مشكلة اثناء اضافة السيارة');
      } finally {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  Future<void> showErrorDialog(String message) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.error,
      animType: AnimType.rightSlide,
      desc: message,
      btnCancelOnPress: () {},
    ).show();
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
  }

  Future<void> showSuccessDialog(String message) async {
    await AwesomeDialog(
      context: context,
      dialogType: DialogType.success,
      animType: AnimType.rightSlide,
      desc: message,
      btnOkOnPress: () {},
    ).show();
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
  }

  Widget _buildTextField(String labelText, TextEditingController controller,
      FocusNode focusNode, int maxLength, TextInputType keyboardType,
      {FocusNode? nextFocusNode}) {
    return Expanded(
      child: TextFormField(
        cursorColor: Colors.blue,
        controller: controller,
        textAlign: TextAlign.center,
        focusNode: focusNode,
        onChanged: (value) {
          if (value.length == maxLength && nextFocusNode != null) {
            _moveToNextField(nextFocusNode);
          }
        },
        decoration: InputDecoration(
          labelText: labelText,
          labelStyle: const TextStyle(color: Colors.blue, fontSize: 10),
          counterText: '',
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          focusedBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.blue),
          ),
        ),
        keyboardType: keyboardType,
        maxLength: maxLength,
        onEditingComplete: () {
          if (nextFocusNode != null) {
            _moveToNextField(nextFocusNode);
          }
        },
        textInputAction:
            nextFocusNode != null ? TextInputAction.next : TextInputAction.done,
      ),
    );
  }

  void _moveToNextField(FocusNode? focusNode) {
    if (focusNode != null) {
      FocusScope.of(context).requestFocus(focusNode);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: const Text("اضافة سيارة"),
      ),
      body: Form(
        key: formState,
        child: isLoading
            ? const Center(
                child: CircularProgressIndicator(
                  color: Colors.blue,
                ),
              )
            : Column(
                children: [
                  Container(
                    padding: const EdgeInsets.all(20),
                    child: Row(
                      children: [
                        _buildTextField(
                          'الحرف الاول',
                          firstController,
                          firstFocusNode,
                          1,
                          TextInputType.text,
                          nextFocusNode: secondFocusNode,
                        ),
                        _buildTextField(
                          "الحرف الثاني",
                          secondController,
                          secondFocusNode,
                          1,
                          TextInputType.text,
                          nextFocusNode: thirdFocusNode,
                        ),
                        _buildTextField(
                          "الحرف الثالث",
                          thirdController,
                          thirdFocusNode,
                          1,
                          TextInputType.text,
                          nextFocusNode: digitFocusNode,
                        ),
                        const SizedBox(width: 8),
                        _buildTextField(
                          "الارقام",
                          digitController,
                          digitFocusNode,
                          3,
                          TextInputType.number,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ),
                  CustomButtonAuth(
                    child: "اضافة السيارة ",
                    onPressed: addCar,
                  ),
                ],
              ),
      ),
    );
  }
}

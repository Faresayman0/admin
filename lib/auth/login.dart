// ignore_for_file: use_build_context_synchronously

import 'package:awesome_dialog/awesome_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutterfirebase/components/constant_widget.dart';
import 'package:flutterfirebase/components/custom_button_auth.dart';

import 'package:flutterfirebase/components/text_form.dart';
import 'package:flutterfirebase/view/veiw_line.dart';
import 'package:flutterfirebase/view/veiw_statioon.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool passwordVisable = false;
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  GlobalKey<FormState> formState = GlobalKey<FormState>();
  bool isLoading = false;

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: Colors.blue,
              ),
            )
          : Container(
              padding: const EdgeInsets.all(20),
              child: ListView(
                physics: const BouncingScrollPhysics(),
                children: [
                  Form(
                    key: formState,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 20,
                        ),
                        const ConstantWidget(),
                        const SizedBox(
                          height: 30,
                        ),
                        Center(
                          child: const Text(
                            "تسجيل الدخول ",
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomTextForm(
                          prefixIcon: Icons.person,
                          keyboardType: TextInputType.emailAddress,
                          hintText: " ادخل الحساب ",
                          myController: emailController,
                          validator: (val) {
                            if (val == "") {
                              return "لا يمكن ان تكون الخانه فارغة";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(
                          height: 16,
                        ),
                        TextFormField(
                          validator: (val) {
                            if (val == "") {
                              return "لا يمكن ان تكون الخانه فارغة";
                            }
                            return null;
                          },
                          controller: passwordController,
                          obscureText: !passwordVisable,
                          keyboardType: TextInputType.emailAddress,
                          cursorColor: Colors.blue,
                          decoration: InputDecoration(
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.blue),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: const BorderSide(
                                  color: Color(0xFFBDBDBD),
                                ),
                                borderRadius: BorderRadius.circular(70),
                              ),
                              fillColor: Colors.grey[100],
                              filled: true,
                              suffixIcon: IconButton(
                                  onPressed: () {
                                    setState(() {
                                      passwordVisable = !passwordVisable;
                                    });
                                  },
                                  icon: Icon(
                                    passwordVisable
                                        ? Icons.visibility_off
                                        : Icons.visibility,
                                  )),
                              prefixIcon: Icon(
                                Icons.lock,
                                color: Colors.blue,
                              ),
                              border: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                      color: Colors.grey, width: 5),
                                  borderRadius: BorderRadius.circular(70)),
                              hintText: " ادخل الرقم السري "),
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                        CustomButtonAuth(
                            child: "تسجيل الدخول ",
                            onPressed: () async {
                              if ((formState.currentState!.validate())) {
                                try {
                                  isLoading = true;
                                  setState(() {});
                                  final credential = await FirebaseAuth.instance
                                      .signInWithEmailAndPassword(
                                          email: emailController.text,
                                          password: passwordController.text);
                                  Navigator.of(context).pushReplacement(
                                      MaterialPageRoute(builder: (context) {
                                    return const StationName();
                                  }));
                                  setState(() {
                                    isLoading = false;
                                  });
                                } on FirebaseAuthException catch (e) {
                                  isLoading = false;
                                  setState(() {});

                                  if (e.code == 'network-request-failed') {
                                    AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      desc: ' خطأ في الاتصال ',
                                    ).show();
                                  } else if (e.code == 'user-not-found') {
                                    return AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      desc:
                                          ' لم يتم العثور على مستخدم بهذا البريد الإلكتروني ',
                                    ).show();
                                  } else if (e.code == 'wrong-password') {
                                    return AwesomeDialog(
                                      context: context,
                                      dialogType: DialogType.error,
                                      animType: AnimType.rightSlide,
                                      desc: ' كلمة مرور خاطئة لهذا المستخدم ',
                                    ).show();
                                  }
                                }
                              }
                            }),
                        const SizedBox(
                          height: 10,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
    );
  }
}

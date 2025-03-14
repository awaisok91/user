import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:user/Global/global.dart';
import 'package:user/Screens/login_screeen.dart';
import 'package:user/Screens/main_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final nametexteditingcontroller = TextEditingController();
  final emailtexteditingcontroller = TextEditingController();
  final phonetexteditingcontroller = TextEditingController();
  final addresstexteditingcontroller = TextEditingController();
  final passwordtexteditingcontroller = TextEditingController();
  final confirmpasswordtexteditingcontroller = TextEditingController();
  bool _passwordVisible = false;
  //declare global key
  final _formKey = GlobalKey<FormState>();
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth
          .createUserWithEmailAndPassword(
        email: emailtexteditingcontroller.text,
        password: passwordtexteditingcontroller.text.trim(),
      )
          .then((auth) async {
        currentUser = auth.user;
        if (currentUser != null) {
          Map userMap = {
            "id": currentUser!.uid,
            "name": nametexteditingcontroller.text.trim(),
            "email": emailtexteditingcontroller.text.trim(),
            "phone": phonetexteditingcontroller.text.trim(),
            "address": addresstexteditingcontroller.text.trim(),
            "password": passwordtexteditingcontroller.text.trim(),
          };
          DatabaseReference userRef =
              FirebaseDatabase.instance.ref().child("users");
          userRef.child(currentUser!.uid).set(userMap);
        }
        await Fluttertoast.showToast(msg: "Successfully Registered");
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const MainScreen()));
      }).catchError((e) {
        Fluttertoast.showToast(msg: "Erorr occured: \n $e");
      });
    } else {
      Fluttertoast.showToast(msg: "Not all field are valid");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        body: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            Column(
              children: [
                Image.asset(
                    darkTheme ? "images/city2.jpg" : "images/city1.jpg"),
                const SizedBox(height: 20),
                Text(
                  "Register",
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.amberAccent : Colors.blue,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(15, 20, 15, 50),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Form(
                        key: _formKey,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Name",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                fillColor: darkTheme
                                    ? Colors.black45
                                    : Colors.grey[200],
                                filled: true,
                                prefixIcon: const Icon(Icons.person),
                                // border: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Name is required";
                                }
                                if (text.length < 3) {
                                  return "Name must be at least 3 characters";
                                }
                                if (text.length > 50) {
                                  return "Name must be less than 50 characters";
                                }
                                return null;
                              },
                              onChanged: (value) => setState(
                                () {
                                  nametexteditingcontroller.text = value;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Email",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                fillColor: darkTheme
                                    ? Colors.black45
                                    : Colors.grey[200],
                                filled: true,
                                prefixIcon: const Icon(Icons.person),
                                // border: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Email is required";
                                }
                                if (EmailValidator.validate(text) == true) {
                                  return null;
                                }
                                if (text.length < 3) {
                                  return "Email must be at least 3 characters";
                                }
                                if (text.length > 50) {
                                  return "Email must be less than 50 characters";
                                }
                                return null;
                              },
                              onChanged: (text) => setState(
                                () {
                                  emailtexteditingcontroller.text = text;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            IntlPhoneField(
                              decoration: InputDecoration(
                                hintText: "Phone Number",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                fillColor: darkTheme
                                    ? Colors.black45
                                    : Colors.grey[200],
                                filled: true,
                                prefixIcon: const Icon(Icons.phone),
                                // border: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              initialCountryCode: 'Pak',
                              onChanged: (text) {
                                setState(
                                  () {
                                    phonetexteditingcontroller.text =
                                        text.completeNumber;
                                  },
                                );
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Address",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                fillColor: darkTheme
                                    ? Colors.black45
                                    : Colors.grey[200],
                                filled: true,
                                prefixIcon: const Icon(Icons.person),
                                // border: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Address is required";
                                }

                                if (text.length < 3) {
                                  return "Address must be at least 3 characters";
                                }
                                if (text.length > 50) {
                                  return "Address must be less than 50 characters";
                                }
                                return null;
                              },
                              onChanged: (text) => setState(
                                () {
                                  addresstexteditingcontroller.text = text;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              obscureText: !_passwordVisible,
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Password",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                fillColor: darkTheme
                                    ? Colors.black45
                                    : Colors.grey[200],
                                filled: true,
                                prefixIcon: const Icon(Icons.lock),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () {
                                        _passwordVisible = !_passwordVisible;
                                      },
                                    );
                                  },
                                ),
                                // border: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Password is required";
                                }

                                if (text.length < 6) {
                                  return "Password must be at least 6 characters";
                                }
                                if (text.length > 50) {
                                  return "Password must be less than 50 characters";
                                }
                                return null;
                              },
                              onChanged: (text) => setState(
                                () {
                                  passwordtexteditingcontroller.text = text;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextFormField(
                              inputFormatters: [
                                LengthLimitingTextInputFormatter(50),
                              ],
                              decoration: InputDecoration(
                                hintText: "Confirm Password",
                                hintStyle: const TextStyle(
                                  color: Colors.grey,
                                ),
                                fillColor: darkTheme
                                    ? Colors.black45
                                    : Colors.grey[200],
                                filled: true,
                                prefixIcon: const Icon(Icons.person),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _passwordVisible
                                        ? Icons.visibility
                                        : Icons.visibility_off,
                                  ),
                                  onPressed: () {
                                    setState(
                                      () {
                                        _passwordVisible = !_passwordVisible;
                                      },
                                    );
                                  },
                                ),
                                // border: OutlineInputBorder(
                                //   borderRadius: BorderRadius.circular(10),
                                // ),
                              ),
                              autovalidateMode:
                                  AutovalidateMode.onUserInteraction,
                              validator: (text) {
                                if (text == null || text.isEmpty) {
                                  return "Cofirm password is required";
                                }
                                if (text !=
                                    passwordtexteditingcontroller.text) {
                                  return "Password does not match";
                                }
                                if (text.length < 6) {
                                  return "Confirm Password must be at least 3 characters";
                                }
                                if (text.length > 50) {
                                  return "Confirm Password must be less than 50 characters";
                                }
                                return null;
                              },
                              onChanged: (text) => setState(
                                () {
                                  confirmpasswordtexteditingcontroller.text =
                                      text;
                                },
                              ),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: darkTheme
                                    ? Colors.amberAccent
                                    : Colors.blue,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                minimumSize: const Size(double.infinity, 50),
                              ),
                              onPressed: () {
                                _submit();
                              },
                              child: const Text(
                                "Register",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Forgot Password?",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkTheme
                                      ? Colors.amberAccent
                                      : Colors.blue,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) => const LoginScreeen()));
                              },
                              child: Text(
                                "Already have an account? Sign In",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  color: darkTheme
                                      ? Colors.amberAccent
                                      : Colors.blue,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}

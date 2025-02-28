import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user/Global/global.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final emaitextController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  void _submit() {
    firebaseAuth
        .sendPasswordResetEmail(email: emaitextController.text.trim())
        .then((value) {
      Fluttertoast.showToast(
          msg:
              "We have send you an email to recover password.please check youe email");
    }).catchError((error) {
      Fluttertoast.showToast(msg: "Error occured: ${error.toString()}");
    });
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
                  "Reset your Password",
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
                                  emaitextController.text = text;
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
                                "Reset Password",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            // SizedBox(height: 20),
                            // GestureDetector(
                            //   onTap: () {},
                            //   child: Text(
                            //     "Forgot Password?",
                            //     style: TextStyle(
                            //       fontSize: 16,
                            //       fontWeight: FontWeight.bold,
                            //       color: darkTheme
                            //           ? Colors.amberAccent
                            //           : Colors.blue,
                            //     ),
                            //   ),
                            // ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {},
                              child: Text(
                                "Doesn't have an account? Register",
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

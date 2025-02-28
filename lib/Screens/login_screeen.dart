import 'package:email_validator/email_validator.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user/Global/global.dart';
import 'package:user/Screens/forgot_password_screen.dart';
import 'package:user/Screens/main_screen.dart';
import 'package:user/Screens/register_screen.dart';
import 'package:user/SplashScreen/Splash_Screen.dart';

class LoginScreeen extends StatefulWidget {
  const LoginScreeen({super.key});

  @override
  State<LoginScreeen> createState() => _LoginScreeenState();
}

class _LoginScreeenState extends State<LoginScreeen> {
  final emaitextController = TextEditingController();
  final passwordtextController = TextEditingController();
  bool _passwordVisible = false;
  final _formKey = GlobalKey<FormState>();
  void _submit() async {
    if (_formKey.currentState!.validate()) {
      await firebaseAuth
          .signInWithEmailAndPassword(
        email: emaitextController.text,
        password: passwordtextController.text.trim(),
      )
          .then((auth) async {
        DatabaseReference userRef =
            FirebaseDatabase.instance.ref().child("users");
        userRef.child(firebaseAuth.currentUser!.uid).once().then((value) async {
          final snap = value.snapshot;
          if (snap.value != null) {
            currentUser = auth.user;
            await Fluttertoast.showToast(msg: "Successfully logged in");
            Navigator.push(
                context, MaterialPageRoute(builder: (c) => const MainScreen()));
          } else {
            await Fluttertoast.showToast(
                msg: "No record exist with this email");
            firebaseAuth.signOut();
            Navigator.push(context,
                MaterialPageRoute(builder: (c) => const SplashScreen()));
          }
        });
        // currentUser = auth.user;

        // await Fluttertoast.showToast(msg: "Successfully logged in");
        // Navigator.push(
        //     context, MaterialPageRoute(builder: (c) => const MainScreen()));
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
                  "Login",
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
                                  passwordtextController.text = text;
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
                                "Login",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (c) =>
                                            const ForgotPasswordScreen()));
                              },
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
                                        builder: (c) => const RegisterScreen()));
                              },
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

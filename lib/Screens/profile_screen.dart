import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:user/Global/global.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final nametexteditingcontroller = TextEditingController();
  final phonetexteditingcontroller = TextEditingController();
  final addresstexteditingcontroller = TextEditingController();
  DatabaseReference userRef = FirebaseDatabase.instance.ref().child("users");
  Future<void> showUserNameDialogAlert(BuildContext context, String name) {
    nametexteditingcontroller.text = name;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: nametexteditingcontroller,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "name": nametexteditingcontroller.text,
                }).then((value) {
                  nametexteditingcontroller.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Update succesfully.\n restart the app to see the changes");
                }).onError((error, stackTrace) {
                  Fluttertoast.showToast(
                      msg: "Error occurred. Try again\n $error");
                });
              },
              child: const Text(
                "Ok",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showUserPhoneDialogAlert(BuildContext context, String phone) {
    phonetexteditingcontroller.text = phone;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: phonetexteditingcontroller,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "phone": phonetexteditingcontroller.text,
                }).then((value) {
                  phonetexteditingcontroller.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Update succesfully.\n restart the app to see the changes");
                }).onError((error, stackTrace) {
                  Fluttertoast.showToast(
                      msg: "Error occurred. Try again\n $error");
                });
              },
              child: const Text(
                "Ok",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> showUserAddressDialogAlert(
      BuildContext context, String address) {
    addresstexteditingcontroller.text = address;
    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Update"),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: addresstexteditingcontroller,
                )
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red),
              ),
            ),
            TextButton(
              onPressed: () {
                userRef.child(firebaseAuth.currentUser!.uid).update({
                  "address": addresstexteditingcontroller.text,
                }).then((value) {
                  addresstexteditingcontroller.clear();
                  Fluttertoast.showToast(
                      msg:
                          "Update succesfully.\n restart the app to see the changes");
                }).onError((error, stackTrace) {
                  Fluttertoast.showToast(
                      msg: "Error occurred. Try again\n $error");
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Ok",
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        resizeToAvoidBottomInset: false,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.black,
            ),
          ),
          title: const Text(
            "Profile Screen",
            style: TextStyle(
              color: Colors.black,
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
          elevation: 0,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 50),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(50),
                  decoration: const BoxDecoration(
                    color: Colors.lightBlue,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.person,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 30),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      UserModelCurrentInfo!.name!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showUserNameDialogAlert(
                            context, UserModelCurrentInfo!.name!);
                      },
                      icon: const Icon(
                        Icons.edit,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      UserModelCurrentInfo!.phone!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showUserPhoneDialogAlert(
                            context, UserModelCurrentInfo!.phone!);
                      },
                      icon: const Icon(
                        Icons.edit,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      UserModelCurrentInfo!.address!,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        showUserAddressDialogAlert(
                            context, UserModelCurrentInfo!.address!);
                      },
                      icon: const Icon(
                        Icons.edit,
                      ),
                    ),
                  ],
                ),
                const Divider(
                  thickness: 1,
                ),
                Text(
                  UserModelCurrentInfo!.email!,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}


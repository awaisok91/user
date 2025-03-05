import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:smooth_star_rating_nsafe/smooth_star_rating.dart';
import 'package:user/Global/global.dart';
import 'package:user/SplashScreen/Splash_Screen.dart';

class RateDriverScreen extends StatefulWidget {
  String? assignedDriverId;
  RateDriverScreen({super.key, this.assignedDriverId});

  @override
  State<RateDriverScreen> createState() => _RateDriverScreenState();
}

class _RateDriverScreenState extends State<RateDriverScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.all(8),
        width: double.infinity,
        decoration: BoxDecoration(
          color: darkTheme ? Colors.black : Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 22),
            Text(
              "Rate Trips Experience",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: 2,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            Divider(
              height: 2,
              thickness: 2,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
            const SizedBox(height: 20),
            SmoothStarRating(
              rating: countRatingStars,
              allowHalfRating: false,
              starCount: 5,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              borderColor: darkTheme ? Colors.amber.shade400 : Colors.grey,
              size: 46,
              onRatingChanged: (valueOfStarsChoosed) {
                countRatingStars = valueOfStarsChoosed;
                if (countRatingStars == 1) {
                  setState(() {
                    titleStartRating = "Very Bad";
                  });
                }
                if (countRatingStars == 2) {
                  setState(() {
                    titleStartRating = "Bad";
                  });
                }
                if (countRatingStars == 3) {
                  setState(() {
                    titleStartRating = "Good";
                  });
                }
                if (countRatingStars == 4) {
                  setState(() {
                    titleStartRating = "Very Good";
                  });
                }
                if (countRatingStars == 5) {
                  setState(() {
                    titleStartRating = "Excellent";
                  });
                }
              },
            ),
            const SizedBox(height: 10),
            Text(
              titleStartRating,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 30,
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    darkTheme ? Colors.amber.shade400 : Colors.blue,
                padding: const EdgeInsets.symmetric(horizontal: 70),
              ),
              onPressed: () {
                DatabaseReference rateDriverRef = FirebaseDatabase.instance
                    .ref()
                    .child("drivers")
                    .child(widget.assignedDriverId!)
                    .child("ratings");
                rateDriverRef.once().then((snap) {
                  if (snap.snapshot.value == null) {
                    rateDriverRef.set(countRatingStars.toString());
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => const SplashScreen()));
                  } else {
                    double pastRating =
                        double.parse(snap.snapshot.value.toString());
                    double newAverageRatings =
                        (pastRating + countRatingStars) / 2;
                    rateDriverRef.set(newAverageRatings.toString());
                    Navigator.pop(context);
                    Navigator.push(context,
                        MaterialPageRoute(builder: (c) => const SplashScreen()));
                  }
                  Fluttertoast.showToast(msg: "Restarting the App Know");
                });
              },
              child: Text(
                "Submit",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: darkTheme ? Colors.black : Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

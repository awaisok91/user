import 'package:flutter/material.dart';
import 'package:user/SplashScreen/Splash_Screen.dart';

class PayFarAmountDialog extends StatefulWidget {
  double? fareAmount;
  PayFarAmountDialog({super.key, this.fareAmount});

  @override
  State<PayFarAmountDialog> createState() => _PayFarAmountDialogState();
}

class _PayFarAmountDialogState extends State<PayFarAmountDialog> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme = Theme.of(context).brightness == Brightness.dark;
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      elevation: 0,
      backgroundColor: Colors.transparent,
      child: Container(
        constraints: BoxConstraints(
          maxHeight:
              MediaQuery.of(context).size.height * 0.5, // Adaptive height
        ),
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.only(top: 20),
            width: double.infinity,
            decoration: BoxDecoration(
              color: darkTheme ? Colors.black : Colors.blue,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min, // Prevent overflow
              children: [
                Text(
                  'Fare Amount'.toUpperCase(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.amber.shade400 : Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Divider(
                  color: darkTheme ? Colors.amber.shade400 : Colors.white,
                  thickness: 1,
                ),
                const SizedBox(height: 10),
                Text(
                  'PKR ${widget.fareAmount.toString()}',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: darkTheme ? Colors.amber.shade400 : Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    "This is the total fare amount. Please pay the amount to the driver.",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: darkTheme ? Colors.amber.shade400 : Colors.white,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          darkTheme ? Colors.amber.shade400 : Colors.white,
                    ),
                    onPressed: () {
                      Future.delayed(const Duration(milliseconds: 10000), () {
                        Navigator.pop(context, "cash paid");
                        Navigator.push(context,
                            MaterialPageRoute(builder: (c) => const SplashScreen()));
                      });
                    },
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment.center, // Centers content
                      children: [
                        Text(
                          "Pay Cash ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkTheme ? Colors.black : Colors.blue,
                          ),
                        ),
                        Text(
                          "PKR ${widget.fareAmount.toString()}",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: darkTheme ? Colors.black : Colors.blue,
                          ),
                        ),
                      ],
                    ),
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

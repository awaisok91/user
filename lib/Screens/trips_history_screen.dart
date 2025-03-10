import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/InfoHandler/app_info.dart';
import 'package:user/Models/trips_history_model.dart';
import 'package:user/widgets/history_design_ui.dart';


class TripsHistoryScreen extends StatefulWidget {
  const TripsHistoryScreen({super.key});

  @override
  State<TripsHistoryScreen> createState() => _TripsHistoryScreenState();
}

class _TripsHistoryScreenState extends State<TripsHistoryScreen> {
  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      backgroundColor: darkTheme ? Colors.black : Colors.grey[100],
      appBar: AppBar(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        title: Text(
          "Trips History",
          style: TextStyle(
            color: darkTheme ? Colors.amber.shade400 : Colors.black,
          ),
        ),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.close,
            color: darkTheme ? Colors.amber.shade400 : Colors.black,
          ),
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: ListView.separated(
          itemBuilder: (context,i){
            return Card(
              color: Colors.grey[100],
              shadowColor: Colors.transparent,
              child: HistoryDesignUi(
                tripsHistoryModel: Provider.of<AppInfo>(context, listen: false).allTripsHistoryInformationList[i],
              ),
            );
          },
          separatorBuilder: (context, i) => const SizedBox(height: 30),
          itemCount: Provider.of<AppInfo>(context, listen: false)
              .allTripsHistoryInformationList
              .length,
              physics: const ClampingScrollPhysics(),
              shrinkWrap: true,
        ),
      ),
    );
  }
}

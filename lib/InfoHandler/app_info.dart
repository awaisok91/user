import 'package:flutter/material.dart';
import 'package:user/Models/direction.dart';

class AppInfo extends ChangeNotifier {
  Directions? UserPickUpLocation, UserDropOffLocation;
  int countTotalTrips = 0;
  // List<String> historyTripsKeysList = [];
  // List<TripsHistoryModel> allTripsHistoryInformationList = [];

  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    UserPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    UserDropOffLocation = dropOffAddress;
    notifyListeners();
  }
}

import 'package:flutter/material.dart';
import 'package:user/Models/direction.dart';
import 'package:user/Models/trips_history_model.dart';

class AppInfo extends ChangeNotifier {
  Directions? UserPickUpLocation, UserDropOffLocation;
  int countTotalTrips = 0;
  List<String> historyTripsKeysList = [];
  List<TripsHistoryModel> allTripsHistoryInformationList = [];

  void updatePickUpLocationAddress(Directions userPickUpAddress) {
    UserPickUpLocation = userPickUpAddress;
    notifyListeners();
  }

  void updateDropOffLocationAddress(Directions dropOffAddress) {
    UserDropOffLocation = dropOffAddress;
    notifyListeners();
  }

  updateOverAlltripsCounter(int overAllTripsCounter) {
    countTotalTrips = overAllTripsCounter;
    notifyListeners();
  }

  updateOverAllTripsKeys(List<String> tripsKeyList) {
    historyTripsKeysList = tripsKeyList;
    notifyListeners();
  }

  updateOverAllTripsHistoryInformation(TripsHistoryModel eachTripsHistory) {
    allTripsHistoryInformationList.add(eachTripsHistory);
    notifyListeners();
  }
}

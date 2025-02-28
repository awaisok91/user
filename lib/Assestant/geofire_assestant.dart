// import 'package:user/Models/active_nearby_available_drivers.dart';

// class GeofireAssestant {
//   static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList =
//       [];
//   static void deletOfflineDriversFromList(String driverId) {
//     int indexNumber = activeNearbyAvailableDriversList
//         .indexWhere((element) => element.driverId == driverId);
//     activeNearbyAvailableDriversList.removeAt(indexNumber);
//   }

//   static void UpdateActiveNearbyAvailableDriverLoction(
//       ActiveNearbyAvailableDrivers driverWhoMove) {
//     int indexNumber = activeNearbyAvailableDriversList
//         .indexWhere((element) => element.driverId == driverWhoMove.driverId);
//     activeNearbyAvailableDriversList[indexNumber].locationLatitude =
//         driverWhoMove.locationLatitude;
//     activeNearbyAvailableDriversList[indexNumber].locationLongitude =
//         driverWhoMove.locationLongitude;
//   }
// }
//start
import 'package:user/Models/active_nearby_available_drivers.dart';

class GeofireAssestant {
  static List<ActiveNearbyAvailableDrivers> activeNearbyAvailableDriversList =
      [];

  // ✅ Fix: Check if driver exists before removing
  static void deletOfflineDriversFromList(String driverId) {
    int indexNumber = activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverId == driverId);

    if (indexNumber != -1) {
      activeNearbyAvailableDriversList.removeAt(indexNumber);
    }
  }

  // ✅ Fix: Check if driver exists before updating location
  static void UpdateActiveNearbyAvailableDriverLoction(
      ActiveNearbyAvailableDrivers driverWhoMove) {
    int indexNumber = activeNearbyAvailableDriversList
        .indexWhere((element) => element.driverId == driverWhoMove.driverId);

    if (indexNumber != -1) {
      activeNearbyAvailableDriversList[indexNumber].locationLatitude =
          driverWhoMove.locationLatitude;
      activeNearbyAvailableDriversList[indexNumber].locationLongitude =
          driverWhoMove.locationLongitude;
    }
  }
}

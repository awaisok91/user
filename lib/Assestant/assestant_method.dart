import 'dart:convert';

import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:user/Assestant/request_assistant.dart';
import 'package:user/Global/global.dart';
import 'package:user/Global/map_key.dart';
import 'package:user/InfoHandler/app_info.dart';
import 'package:provider/provider.dart';
import 'package:user/Models/direction.dart';
import 'package:user/Models/direction_detail_info.dart';
import 'package:user/Models/user_model.dart';
import 'package:http/http.dart' as http;

class AssestantMethod {
  static void redCurrentOnlineUser() async {
    currentUser = firebaseAuth.currentUser;
    DatabaseReference userRef =
        FirebaseDatabase.instance.ref().child('users').child(currentUser!.uid);
    userRef.once().then((snap) {
      if (snap.snapshot.value != null) {
        UserModelCurrentInfo = UserModel.fromsnapshot(snap.snapshot);
      }
    });
  }

  static Future<String> searchAddressForGeographicCordinates(
      Position position, context) async {
    String apiURL =
        "https://maps.gomaps.pro/maps/api/geocode/json?latlng=${position.latitude},${position.longitude}&key=$mapKey";
    String humanReadableAddress = "";
    var requestResponse = await RequestAssistant.recieveRequest(apiURL);
    if (requestResponse != "failed") {
      humanReadableAddress = requestResponse["results"][0]["formatted_address"];
      Directions userPickUpAddress = Directions();
      userPickUpAddress.locationlatitude = position.latitude;
      userPickUpAddress.locationlongitude = position.longitude;
      userPickUpAddress.locationName = humanReadableAddress;
      Provider.of<AppInfo>(context, listen: false)
          .updatePickUpLocationAddress(userPickUpAddress);
    }
    return humanReadableAddress;
  }

  static Future<DirectionDetailInfo> obtainOriginToDestinationDirectionDetails(
      LatLng originPosition, LatLng destinationPosition) async {
    String urlOriginToDestinationDirectionDetails =
        "https://maps.gomaps.pro/maps/api/directions/json?origin=${originPosition.latitude},${originPosition.longitude}&destination=${destinationPosition.latitude},${destinationPosition.longitude}&key=$mapKey";
    var responseDirectionApi = await RequestAssistant.recieveRequest(
        urlOriginToDestinationDirectionDetails);
    if (responseDirectionApi == "failed") {
      return Future.error("Failed to get directions");
    }
    DirectionDetailInfo directionDetailInfo = DirectionDetailInfo();
    directionDetailInfo.e_point =
        responseDirectionApi["routes"][0]["overview_polyline"]["points"];
    directionDetailInfo.distance_text =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["text"];
    directionDetailInfo.distance_value =
        responseDirectionApi["routes"][0]["legs"][0]["distance"]["value"];
    directionDetailInfo.duration_text =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["text"];
    directionDetailInfo.duration_value =
        responseDirectionApi["routes"][0]["legs"][0]["duration"]["value"];
    return directionDetailInfo;
  }

  static double calculateFareAmountFromOriginToDestination(
      DirectionDetailInfo directionDetailInfo) {
    double timeTraveledFareAmountPerMinute =
        (directionDetailInfo.distance_value! / 60) * 0.1;
    double distanceTraveledFareAmountPerKilometer =
        (directionDetailInfo.distance_value! / 1000) * 0.1;
    //USD
    double totalFareAmount = timeTraveledFareAmountPerMinute +
        distanceTraveledFareAmountPerKilometer;

    return double.parse(totalFareAmount.toStringAsFixed(2));
  }

  static sendNotificationToDriversNow(
      String deviceRegistrationToken, String userRiderequestId, context) async {
    String destinationAddress = userDropOffAdress;
    Map<String, String> headerNotification = {
      "Content-Type": "appliction/json",
      //token or key is not avaliable if i get it from firebase then we continue
      "Authorization": cloudMessagingServerToken,
    };
    Map bodyNotification = {
      
      "notification": {
        "title": "New Trip Request",
        "body": "Destination Address: $destinationAddress",
        "sound": "default",
      }
    };
    Map dataMap = {
      "click_action": "FLUTTER_NOTIFICATION_CLICK",
      "id": "1",
      "status": "done",
      "userRideRequestId": userRiderequestId,
    };
    Map officialNotificationFormate = {
      "notification": bodyNotification,
      "data": dataMap,
      "priority": "high",
      "to": deviceRegistrationToken,
    };
    var responseNotification = http.post(
      Uri.parse("https://fcm.googleapis.com/fcm/send"),
      headers: headerNotification,
      body: jsonEncode(officialNotificationFormate),
    );
  }
}

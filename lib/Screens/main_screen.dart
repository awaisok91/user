import 'dart:async';

import 'package:firebase_database/firebase_database.dart';

import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;
import 'package:provider/provider.dart';
import 'package:user/Assestant/assestant_method.dart';
import 'package:user/Assestant/geofire_assestant.dart';
import 'package:user/Global/global.dart';
import 'package:user/InfoHandler/app_info.dart';
import 'package:user/Models/active_nearby_available_drivers.dart';
import 'package:user/Screens/drawer_screen.dart';
import 'package:user/Screens/precies_picup_screen.dart';
import 'package:user/Screens/rate_driver_screen.dart';
import 'package:user/Screens/search_places_screen.dart';
import 'package:user/SplashScreen/Splash_Screen.dart';
import 'package:user/widgets/pay_far_amount_dialog.dart';
import 'package:user/widgets/progres_dialog.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  LatLng? picKLocation;
  loc.Location location = loc.Location();
  String? _address;
  final Completer<GoogleMapController> _controllerGooglrMap = Completer();
  GoogleMapController? newGoogleMapController;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  double searchLocationContainerHeight = 220;
  double waittingContainerHeight = 0;
  double assignDriverContainerHeight = 0;
  double suggestedRiderContainerHeight = 0;
  double searchingForDriverContainerHeight = 0;
  Position? userCurrentPosition;
  var geoLocator = Geolocator();
  LocationPermission? _locationPermission;
  double bottomPaddingOfMap = 0;
  List<LatLng> pLineCoordinates = [];
  Set<Polyline> polyLineSet = {};
  Set<Marker> markerSet = {};
  Set<Circle> circleSet = {};
  String userName = "";
  String userEmail = "";
  bool openNavigationDrawer = true;
  bool activeNearbyDriverKeysLoaded = false;
  BitmapDescriptor? activeNearbyIcon;
  DatabaseReference? referenceRideRequest;
  String selectedVehicalType = "";
  String driverRidestatus = "Driver is coming";
  StreamSubscription<DatabaseEvent>? tripRidesRequestInfoStreamSubcription;
  List<ActiveNearbyAvailableDrivers> onlineNearByAvailableDriversList = [];
  String userRiderequestStatus = "";
  bool requestPositionInfo = true;

  // @override
  // void initState() {
  //   super.initState();
  //   checkIfLocationpermissionAllowed();
  // }
  //class 13
  void showSearchingForDriversContainer() {
    setState(() {
      searchingForDriverContainerHeight = 200;
    });
  }

  checkIfLocationpermissionAllowed() async {
    _locationPermission = await Geolocator.requestPermission();
    if (_locationPermission == LocationPermission.denied) {
      _locationPermission = await Geolocator.requestPermission();
    } else {
      locatUserPosition();
    }
  }

  saveRideRequestInformation(String selectedVehicalType) {
    //save the ride request information
    referenceRideRequest =
        FirebaseDatabase.instance.ref().child("All Ride requests").push();
    var originLocation =
        Provider.of<AppInfo>(context, listen: false).UserPickUpLocation;
    var destinationLocation =
        Provider.of<AppInfo>(context, listen: false).UserDropOffLocation;
    Map originLocationMap = {
      //keys and value
      "latitude": originLocation!.locationlatitude.toString(),
      "longitude": originLocation.locationlongitude.toString(),
    };
    Map destinationLocationMap = {
      //keys and value
      "latitude": destinationLocation!.locationlatitude.toString(),
      "longitude": destinationLocation.locationlongitude.toString(),
    };

    Map userInformationMap = {
      "origin": originLocationMap,
      "destination": destinationLocationMap,
      "time": DateTime.now().toString(),
      "userName": UserModelCurrentInfo!.name,
      "userPhone": UserModelCurrentInfo!.phone,
      "originAddress": originLocation.locationName,
      "destinationAddress": destinationLocation.locationName,
      "driverId": "waiting",
    };
    referenceRideRequest!.set(userInformationMap);
    tripRidesRequestInfoStreamSubcription =
        referenceRideRequest!.onValue.listen((eventsnap) async {
      if (eventsnap.snapshot.value == null) {
        return;
      }
      if ((eventsnap.snapshot.value as Map)["car_details"] != null) {
        setState(() {
          driverCarDetails =
              (eventsnap.snapshot.value as Map)["car_details"].toString();
        });
      }
      if ((eventsnap.snapshot.value as Map)["driverPhone"] != null) {
        setState(() {
          driverPhone =
              (eventsnap.snapshot.value as Map)["driverPhone"].toString();
        });
      }
      if ((eventsnap.snapshot.value as Map)["driverName"] != null) {
        setState(() {
          driverName =
              (eventsnap.snapshot.value as Map)["driverName"].toString();
        });
      }
      if ((eventsnap.snapshot.value as Map)["ratings"] != null) {
        setState(() {
          driverRatings =
              (eventsnap.snapshot.value as Map)["ratings"].toString();
        });
      }
      if ((eventsnap.snapshot.value as Map)["status"] != null) {
        setState(() {
          userRiderequestStatus =
              (eventsnap.snapshot.value as Map)["status"].toString();
        });
      }
      if ((eventsnap.snapshot.value as Map)["driverlocation"] != null) {
        double driverCurrentPositionLat = double.parse(
            (eventsnap.snapshot.value as Map)["driverLocation"]["latitude"]
                .toString());
        double driverCurrentPositionLng = double.parse(
            (eventsnap.snapshot.value as Map)["driverLocation"]["longitude"]
                .toString());
        LatLng driverCurrentPositionLatLng =
            LatLng(driverCurrentPositionLat, driverCurrentPositionLng);
        //status =accepted
        if (userRiderequestStatus == "accepted") {
          updateArrivaltimeToUserPickUpLocation(driverCurrentPositionLatLng);
        }
        //status=arrive
        if (userRiderequestStatus == "arrived") {
          setState(() {
            driverRidestatus = "Driver has arrived";
          });
        }
        //status =ontrip
        if (userRiderequestStatus == "ontrip") {
          updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng);
        }
        if (userRiderequestStatus == "ended") {
          if ((eventsnap.snapshot.value as Map)["fareAmount"] != null) {
            double fareAmount = double.parse(
                (eventsnap.snapshot.value as Map)["fareAmount"].toString());
            var response = await showDialog(
                context: context,
                builder: (BuildContext context) => PayFarAmountDialog(
                      fareAmount: fareAmount,
                    ));
            if (response == "Cash Paid") {
              if ((eventsnap.snapshot.value as Map)["driverId"] != null) {
                String assignedDriverId =
                    (eventsnap.snapshot.value as Map)["driverId"].toString();
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (c) => RateDriverScreen(
                              assignedDriverId: assignedDriverId,
                            )));
                referenceRideRequest!.onDisconnect();
                tripRidesRequestInfoStreamSubcription!.cancel();
              }
            }
          }
        }
      }
    });
    onlineNearByAvailableDriversList =
        GeofireAssestant.activeNearbyAvailableDriversList;
    searchNearestOnlineDriver(selectedVehicalType);
  }

  searchNearestOnlineDriver(String selectedVehicalType) async {
    if (onlineNearByAvailableDriversList.isEmpty) {
      //cancel or deleat the ride request info
      referenceRideRequest!.remove();
      setState(() {
        polyLineSet.clear();
        markerSet.clear();
        circleSet.clear();
        pLineCoordinates.clear();
      });
      Fluttertoast.showToast(msg: "No Online nearest Drivers Available");
      Fluttertoast.showToast(msg: "Search Again.\n Restarting App");
      Future.delayed(const Duration(milliseconds: 4000), () {
        referenceRideRequest!.remove();
        Navigator.push(
            context, MaterialPageRoute(builder: (c) => const SplashScreen()));
      });
      return;
    }
    await retrieveOnlineDriversInformation(onlineNearByAvailableDriversList);
    print("Driver List :$driversList");
    for (int i = 0; i < driversList.length; i++) {
      if (driversList[i]["car_details"]["type"] == selectedVehicalType) {
        AssestantMethod.sendNotificationToDriversNow(
            driversList[i]["token"], referenceRideRequest!.key!, context);
      }
    }
    Fluttertoast.showToast(msg: "Notification sent Successfully");
    showSearchingForDriversContainer();
    FirebaseDatabase.instance
        .ref()
        .child("All Ride Requests")
        .child(referenceRideRequest!.key!)
        .child("driverId")
        .onValue
        .listen((eventRideRequestSnapShot) {
      print("EventSnapshot: ${eventRideRequestSnapShot.snapshot.value}");
      if (eventRideRequestSnapShot.snapshot.value != null) {
        if (eventRideRequestSnapShot.snapshot.value != "waiting") {
          showUiForAssignedDriverInfo();
        }
      }
    });
  }

  updateArrivaltimeToUserPickUpLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;
      LatLng userPicUpPosition =
          LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
      var directionDetailInfo =
          await AssestantMethod.obtainOriginToDestinationDirectionDetails(
              driverCurrentPositionLatLng, userPicUpPosition);
      setState(() {
        driverRidestatus =
            "Driver is coming:${directionDetailInfo.duration_text}";
      });
      requestPositionInfo = true;
    }
  }

  updateReachingTimeToUserDropOffLocation(driverCurrentPositionLatLng) async {
    if (requestPositionInfo == true) {
      requestPositionInfo = false;
      var dropOffLocation =
          Provider.of<AppInfo>(context, listen: false).UserDropOffLocation;
      LatLng userDestinationPosition = LatLng(
          dropOffLocation!.locationlatitude!,
          dropOffLocation.locationlongitude!);
      var directionDetailsInfo =
          await AssestantMethod.obtainOriginToDestinationDirectionDetails(
              driverCurrentPositionLatLng, userDestinationPosition);
      setState(() {
        driverRidestatus =
            "Going towards Destination:${directionDetailsInfo.duration_text}";
      });
      requestPositionInfo = true;
    }
  }

  showUiForAssignedDriverInfo() {
    setState(() {
      waittingContainerHeight = 0;
      searchLocationContainerHeight = 0;
      assignDriverContainerHeight = 200;
      suggestedRiderContainerHeight = 0;
      bottomPaddingOfMap = 200;
    });
  }

  retrieveOnlineDriversInformation(List onlineNearestDriverList) async {
    driversList.clear();
    DatabaseReference ref = FirebaseDatabase.instance.ref().child("drivers");
    for (int i = 0; i < onlineNearestDriverList.length; i++) {
      await ref
          .child(onlineNearestDriverList[i].driverId.toString())
          .once()
          .then((dataSnapshot) {
        var driverKeyInfo = dataSnapshot.snapshot.value;
        driversList.add(driverKeyInfo);
        print('driver Key Information=$driversList');
      });
    }
  }

  @override
  void initState() {
    super.initState();
    checkIfLocationpermissionAllowed();
  }

// if void is nedded then put it here
  locatUserPosition() async {
    Position cPosition = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    userCurrentPosition = cPosition;
    LatLng latLangPosition =
        LatLng(userCurrentPosition!.latitude, userCurrentPosition!.longitude);
    CameraPosition cameraPosition =
        CameraPosition(target: latLangPosition, zoom: 15);
    newGoogleMapController!
        .animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
    String humanReadableAddress =
        await AssestantMethod.searchAddressForGeographicCordinates(
            userCurrentPosition!, context);
    print("This is your address::$humanReadableAddress");
    userName = UserModelCurrentInfo!.name!;
    userEmail = UserModelCurrentInfo!.email!;

    initializeGeoFireListener();
    AssestantMethod.readTripsKeyForOnlineUser(context);
  }

  initializeGeoFireListener() {
    Geofire.initialize("activeDrivers");
    Geofire.queryAtLocation(
            userCurrentPosition!.latitude, userCurrentPosition!.longitude, 10)!
        .listen((map) {
      print("this is map $map");
      if (map != null) {
        var callBack = map["callBack"];
        switch (callBack) {
          case Geofire.onKeyEntered:
          //new if show error remove it
            GeofireAssestant.activeNearbyAvailableDriversList.clear();
            ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDrivers.locationLatitude = map["latitude"];
            activeNearbyAvailableDrivers.locationLongitude = map["longitude"];
            activeNearbyAvailableDrivers.driverId = map["key"];
            GeofireAssestant.activeNearbyAvailableDriversList
                .add(activeNearbyAvailableDrivers);
            if (activeNearbyDriverKeysLoaded == true) {
              displayActiverDriversOnUserMap();
            }

            break;
          //whenever driver become non active or online
          case Geofire.onKeyExited:
            GeofireAssestant.deletOfflineDriversFromList(map["key"]);
            displayActiverDriversOnUserMap();
            break;
          //whenever driver moves update driver location
          case Geofire.onKeyMoved:
            ActiveNearbyAvailableDrivers activeNearbyAvailableDrivers =
                ActiveNearbyAvailableDrivers();
            activeNearbyAvailableDrivers.locationLatitude = map["latitude"];
            activeNearbyAvailableDrivers.locationLongitude = map["longitude"];
            activeNearbyAvailableDrivers.driverId = map["key"];
            GeofireAssestant.UpdateActiveNearbyAvailableDriverLoction(
                activeNearbyAvailableDrivers);
            displayActiverDriversOnUserMap();
            break;
          //display thos online active driver users map
          case Geofire.onGeoQueryReady:
            activeNearbyDriverKeysLoaded = true;
            displayActiverDriversOnUserMap();
            break;
        }
      }
      setState(() {});
    });
  }

  displayActiverDriversOnUserMap() {
    setState(() {
      markerSet.clear();
      circleSet.clear();
      Set<Marker> driversMarkerSet = <Marker>{};
      for (ActiveNearbyAvailableDrivers eachDriver
          in GeofireAssestant.activeNearbyAvailableDriversList) {
        LatLng eachDriverActivePosition =
            LatLng(eachDriver.locationLatitude!, eachDriver.locationLongitude!);
        Marker marker = Marker(
          markerId: MarkerId(eachDriver.driverId!),
          position: eachDriverActivePosition,
          icon: activeNearbyIcon!,
          rotation: 360,
          //new
          // anchor: Offset(0.5, 0.5),
        );
        driversMarkerSet.add(marker);
      }
      setState(() {
        markerSet = driversMarkerSet;
      });
    });
  }

  creatActiveNearByDriverIconMarker() {
    if (activeNearbyIcon == null) {
      ImageConfiguration imageConfiguration =
          createLocalImageConfiguration(context, size: const Size(0.2, 0.2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car.png")
          .then((value) {
        activeNearbyIcon = value;
      });
    }
  }
  // creatActiveNearByDriverIconMarker() async {
  //   if (activeNearbyIcon == null) {
  //     activeNearbyIcon = await BitmapDescriptor.fromAssetImage(
  //       const ImageConfiguration(size: Size(20, 20)), // ✅ Reduce size
  //       "images/car3.png",
  //     );
  //   }
  // }

  //new

//new end

  Future<void> drawPolyLineFromOriginToDestination(bool darkTheme) async {
    var originPosition =
        Provider.of<AppInfo>(context, listen: false).UserPickUpLocation;
    var destinationPosition =
        Provider.of<AppInfo>(context, listen: false).UserDropOffLocation;
    var originLatLing = LatLng(
        originPosition!.locationlatitude!, originPosition.locationlongitude!);
    var destinationLatLing = LatLng(destinationPosition!.locationlatitude!,
        destinationPosition.locationlongitude!);

    showDialog(
      context: context,
      builder: (BuildContext context) => ProgresDialog(
        message: "Please wait....",
      ),
    );
    var directionDetailInfo =
        await AssestantMethod.obtainOriginToDestinationDirectionDetails(
            originLatLing, destinationLatLing);
    setState(() {
      tripDirectionDetailInfo = directionDetailInfo;
    });
    Navigator.pop(context);
    PolylinePoints pPoints = PolylinePoints();

    List<PointLatLng> decodePolyLinePointsResultList =
        pPoints.decodePolyline(directionDetailInfo.e_point!);
    pLineCoordinates.clear(); //focus
    if (decodePolyLinePointsResultList.isNotEmpty) {
      for (var pointLatLng in decodePolyLinePointsResultList) {
        pLineCoordinates
            .add(LatLng(pointLatLng.latitude, pointLatLng.longitude));
      }
    }
    polyLineSet.clear();
    setState(() {
      Polyline polyline = Polyline(
        polylineId: const PolylineId("PolyLineID"),
        color: darkTheme ? Colors.amber : Colors.blue,
        points: pLineCoordinates,
        jointType: JointType.round,
        startCap: Cap.roundCap,
        endCap: Cap.roundCap,
        geodesic: true,
        width: 5,
      );
      polyLineSet.add(polyline);
    });
    LatLngBounds boundsLatLng;
    if (originLatLing.latitude > destinationLatLing.latitude &&
        originLatLing.longitude > destinationLatLing.longitude) {
      boundsLatLng =
          LatLngBounds(southwest: destinationLatLing, northeast: originLatLing);
    } else if (originLatLing.longitude > destinationLatLing.longitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(originLatLing.latitude, destinationLatLing.longitude),
        northeast: LatLng(destinationLatLing.latitude, originLatLing.longitude),
      );
    } else if (originLatLing.latitude > destinationLatLing.latitude) {
      boundsLatLng = LatLngBounds(
        southwest: LatLng(destinationLatLing.latitude, originLatLing.longitude),
        northeast: LatLng(originLatLing.latitude, destinationLatLing.longitude),
      );
    } else {
      boundsLatLng =
          LatLngBounds(southwest: originLatLing, northeast: destinationLatLing);
    }
    newGoogleMapController!
        .animateCamera(CameraUpdate.newLatLngBounds(boundsLatLng, 65));
    Marker originMarker = Marker(
      markerId: const MarkerId("originID"),
      infoWindow: InfoWindow(
          title: destinationPosition.locationName, snippet: "Origin"),
      position: originLatLing,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    );
    Marker destinationMarker = Marker(
      markerId: const MarkerId("destinationID"),
      infoWindow: InfoWindow(
          title: originPosition.locationName, snippet: "Destination"),
      position: destinationLatLing,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    );
    setState(() {
      markerSet.add(originMarker);
      markerSet.add(destinationMarker);
    });
    Circle originCircle = Circle(
      circleId: const CircleId("originID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: originLatLing,
    );
    Circle destinationCircle = Circle(
      circleId: const CircleId("destinationID"),
      fillColor: Colors.green,
      radius: 12,
      strokeWidth: 3,
      strokeColor: Colors.white,
      center: destinationLatLing,
    );
    setState(() {
      circleSet.add(originCircle);
      circleSet.add(destinationCircle);
    });
  }

  void showSuggestedriderContainer() {
    setState(() {
      suggestedRiderContainerHeight = 400;
      bottomPaddingOfMap = 400;
    });
  }

  // getAddressFromLatLang() async {
  //   try {
  //     GeoData data = await Geocoder2.getDataFromCoordinates(
  //         latitude: picKLocation!.latitude,
  //         longitude: picKLocation!.longitude,
  //         googleMapApiKey: mapKey);
  //     setState(() {
  //       Directions userPickUpAddress = Directions();
  //       userPickUpAddress.locationlatitude = picKLocation!.latitude;
  //       userPickUpAddress.locationlongitude = picKLocation!.longitude;
  //       userPickUpAddress.locationName = data.address;
  //       Provider.of<AppInfo>(context, listen: false)
  //           .updatePickUpLocationAddress(userPickUpAddress);

  //       // _address = data.address;
  //     });
  //   } catch (e) {
  //     print(e.toString());
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    creatActiveNearByDriverIconMarker();

    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        key: scaffoldState,
        drawer: const DrawerScreen(),
        body: Stack(
          children: [
            GoogleMap(
              mapType: MapType.normal,
              myLocationEnabled: true,
              zoomGesturesEnabled: true,
              zoomControlsEnabled: true,
              initialCameraPosition: _kGooglePlex,
              polylines: polyLineSet,
              markers: markerSet,
              circles: circleSet,
              onMapCreated: (GoogleMapController controller) {
                _controllerGooglrMap.complete(controller);
                newGoogleMapController = controller;
                setState(() {});
                locatUserPosition();
              },
              // onCameraMove: (CameraPosition? position) {
              //   if (picKLocation != position!.target) {
              //     picKLocation = position.target;
              //   }
              // },
              // onCameraIdle: () {
              //   getAddressFromLatLang();
              // },
            ),
            // Align(
            //   alignment: Alignment.center,
            //   child: Padding(
            //     padding: EdgeInsets.only(bottom: 40),
            //     child: Image.asset(
            //       "images/intial.jpg",
            //       height: 30,
            //       width: 30,
            //     ),
            //   ),
            // ),
            //custom hamburger button for drawer
            Positioned(
              top: 50,
              left: 20,
              child: Container(
                child: GestureDetector(
                  onTap: () {
                    scaffoldState.currentState!.openDrawer();
                  },
                  child: CircleAvatar(
                    backgroundColor:
                        darkTheme ? Colors.amber.shade400 : Colors.white,
                    child: Icon(
                      Icons.menu,
                      color: darkTheme ? Colors.black : Colors.lightBlue,
                    ),
                  ),
                ),
              ),
            ),

            //ui for serching location
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(10, 50, 10, 10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: darkTheme ? Colors.black : Colors.white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: darkTheme
                                  ? Colors.grey.shade900
                                  : Colors.grey.shade100,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Column(
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.location_on_outlined,
                                        color: darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue,
                                      ),
                                      const SizedBox(width: 10),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            "From",
                                            style: TextStyle(
                                              color: darkTheme
                                                  ? Colors.amber.shade400
                                                  : Colors.blue,
                                              fontSize: 12,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          Text(
                                            Provider.of<AppInfo>(context)
                                                        .UserPickUpLocation !=
                                                    null
                                                ? Provider.of<AppInfo>(context)
                                                            .UserPickUpLocation!
                                                            .locationName!
                                                            .length >
                                                        24
                                                    ? "${Provider.of<AppInfo>(context).UserPickUpLocation!.locationName!.substring(0, 24)}..."
                                                    : Provider.of<AppInfo>(
                                                            context)
                                                        .UserPickUpLocation!
                                                        .locationName!
                                                : "Not Getting Address",
                                            style: const TextStyle(
                                              color: Colors.grey,
                                              fontSize: 14,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 5),
                                Divider(
                                  height: 1,
                                  thickness: 2,
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.blue,
                                ),
                                const SizedBox(height: 5),
                                Padding(
                                  padding: const EdgeInsets.all(5),
                                  child: GestureDetector(
                                    onTap: () async {
                                      //go to search places screen
                                      var responseFromSearchScreen =
                                          await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (c) =>
                                                      const SearchPlacesScreen()));
                                      if (responseFromSearchScreen ==
                                          "obtainDropOff") {
                                        setState(() {
                                          openNavigationDrawer = false;
                                        });
                                      }
                                      await drawPolyLineFromOriginToDestination(
                                          darkTheme);
                                    },
                                    child: Row(
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: darkTheme
                                              ? Colors.amber.shade400
                                              : Colors.blue,
                                        ),
                                        const SizedBox(width: 10),
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "To",
                                              style: TextStyle(
                                                color: darkTheme
                                                    ? Colors.amber.shade400
                                                    : Colors.blue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                            Text(
                                              Provider.of<AppInfo>(context)
                                                          .UserDropOffLocation !=
                                                      null
                                                  ? Provider.of<AppInfo>(
                                                                  context)
                                                              .UserDropOffLocation!
                                                              .locationName!
                                                              .length >
                                                          24
                                                      ? "${Provider.of<AppInfo>(context).UserDropOffLocation!.locationName!.substring(0, 24)}..."
                                                      : Provider.of<AppInfo>(
                                                              context)
                                                          .UserDropOffLocation!
                                                          .locationName!
                                                  : "Where to?",
                                              style: const TextStyle(
                                                color: Colors.grey,
                                                fontSize: 14,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                          const SizedBox(height: 5),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                            builder: (c) =>
                                                const PreciesPicupScreen()));
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.blue,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  child: Text(
                                    "Change Pick Up Location",
                                    style: TextStyle(
                                      color: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    if (Provider.of<AppInfo>(context,
                                                listen: false)
                                            .UserDropOffLocation !=
                                        null) {
                                      showSuggestedriderContainer();
                                    } else {
                                      Fluttertoast.showToast(
                                          msg: "Please select destination");
                                    }
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: darkTheme
                                        ? Colors.amber.shade400
                                        : Colors.blue,
                                    textStyle: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  child: Text(
                                    "Shair fare",
                                    style: TextStyle(
                                      color: darkTheme
                                          ? Colors.black
                                          : Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            //ui for suggested rider
            // Positioned(
            //   left: 0,
            //   right: 0,
            //   bottom: 0,
            //   child: Container(
            //     height: suggestedRiderContainerHeight,
            //     decoration: BoxDecoration(
            //       color: darkTheme ? Colors.black : Colors.white,
            //       borderRadius: const BorderRadius.only(
            //         topLeft: Radius.circular(20),
            //         topRight: Radius.circular(20),
            //       ),
            //     ),
            //     child: Padding(
            //       padding: EdgeInsets.all(20),
            //       child: Column(
            //         crossAxisAlignment: CrossAxisAlignment.start,
            //         children: [
            //           Row(
            //             children: [
            //               Container(
            //                 padding: EdgeInsets.all(2),
            //                 decoration: BoxDecoration(
            //                   color: darkTheme
            //                       ? Colors.amber.shade400
            //                       : Colors.blue,
            //                   borderRadius: BorderRadius.circular(2),
            //                 ),
            //                 child: Icon(
            //                   Icons.star,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //               SizedBox(width: 15),
            //               Text(
            //                 //notice this point
            //                 Provider.of<AppInfo>(context).UserPickUpLocation !=
            //                         null
            //                     ? Provider.of<AppInfo>(context)
            //                                 .UserPickUpLocation!
            //                                 .locationName!
            //                                 .length >
            //                             24
            //                         ? "${Provider.of<AppInfo>(context).UserPickUpLocation!.locationName!.substring(0, 24)}..."
            //                         : Provider.of<AppInfo>(context)
            //                             .UserPickUpLocation!
            //                             .locationName!
            //                     : "Not Getting Address",
            //                 style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 18,
            //                 ),
            //               ),
            //             ],
            //           ),
            //           SizedBox(height: 20),
            //           Row(
            //             children: [
            //               Container(
            //                 padding: EdgeInsets.all(2),
            //                 decoration: BoxDecoration(
            //                   color: Colors.grey,
            //                   borderRadius: BorderRadius.circular(2),
            //                 ),
            //                 child: Icon(
            //                   Icons.star,
            //                   color: Colors.white,
            //                 ),
            //               ),
            //               SizedBox(width: 15),
            //               Text(
            //                 //notice this point
            //                 Provider.of<AppInfo>(context).UserDropOffLocation !=
            //                         null
            //                     ? Provider.of<AppInfo>(context)
            //                                 .UserDropOffLocation!
            //                                 .locationName!
            //                                 .length >
            //                             24
            //                         ? "${Provider.of<AppInfo>(context).UserDropOffLocation!.locationName!.substring(0, 24)}..."
            //                         : Provider.of<AppInfo>(context)
            //                             .UserDropOffLocation!
            //                             .locationName!
            //                     : "Where to?",

            //                 style: TextStyle(
            //                   fontWeight: FontWeight.bold,
            //                   fontSize: 18,
            //                 ),
            //               ),
            //             ],
            //           ),
            //           SizedBox(height: 20),
            //           Text(
            //             "SUGGESTED RIDEDS",
            //             style: TextStyle(
            //               fontWeight: FontWeight.bold,
            //             ),
            //           ),
            //           SizedBox(height: 20),
            //           Row(
            //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //             children: [
            //               GestureDetector(
            //                 onTap: () {
            //                   setState(() {
            //                     selectedVehicalType = "Car";
            //                   });
            //                 },
            //                 child: Container(
            //                   decoration: BoxDecoration(
            //                     color: selectedVehicalType == "Car"
            //                         ? (darkTheme
            //                             ? Colors.amber.shade400
            //                             : Colors.blue)
            //                         : (darkTheme
            //                             ? Colors.black54
            //                             : Colors.grey.shade100),
            //                     borderRadius: BorderRadius.circular(12),
            //                   ),
            //                   child: Padding(
            //                     padding: EdgeInsets.all(20),
            //                     child: Column(
            //                       children: [
            //                         Image.asset(
            //                           "images/car1.png",
            //                           fit: BoxFit.contain,
            //                           scale: 2,
            //                         ),
            //                         SizedBox(height: 8),
            //                         Text(
            //                           "Car",
            //                           style: TextStyle(
            //                             fontWeight: FontWeight.bold,
            //                             color: selectedVehicalType == "Car"
            //                                 ? (darkTheme
            //                                     ? Colors.black
            //                                     : Colors.white)
            //                                 : (darkTheme
            //                                     ? Colors.white
            //                                     : Colors.black),
            //                           ),
            //                         ),
            //                         SizedBox(height: 2),
            //                         Text(
            //                           tripDirectionDetailInfo != null
            //                               ? "PKR ${((AssestantMethod.calculateFareAmountFromOriginToDestination(tripDirectionDetailInfo!) * 2) * 107).toStringAsFixed(2)}"
            //                               : "null",
            //                           style: TextStyle(
            //                             color: Colors.grey,
            //                           ),
            //                         ),
            //                       ],
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             ],
            //           ),
            //           SizedBox(height: 20),
            //           Expanded(
            //             child: GestureDetector(
            //               onTap: () {},
            //               child: Container(
            //                 padding: EdgeInsets.all(12),
            //                 decoration: BoxDecoration(
            //                   color: darkTheme
            //                       ? Colors.amber.shade400
            //                       : Colors.blue,
            //                   borderRadius: BorderRadius.circular(10),
            //                 ),
            //                 child: Center(
            //                   child: Text(
            //                     "Request a Ride",
            //                     style: TextStyle(
            //                       color:
            //                           darkTheme ? Colors.black : Colors.white,
            //                       fontWeight: FontWeight.bold,
            //                       fontSize: 20,
            //                     ),
            //                   ),
            //                 ),
            //               ),
            //             ),
            //           ),
            //           //start

            //           //end
            //         ],
            //       ),
            //     ),
            //   ),
            // )
            //satart
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                height: suggestedRiderContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: SingleChildScrollView(
                    // ✅ Allows scrolling if needed
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min, // ✅ Prevents extra height usage
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.amber),
                            const SizedBox(width: 15),
                            Expanded(
                              // ✅ Prevents text overflow
                              child: Text(
                                Provider.of<AppInfo>(context)
                                            .UserPickUpLocation !=
                                        null
                                    ? Provider.of<AppInfo>(context)
                                                .UserPickUpLocation!
                                                .locationName!
                                                .length >
                                            24
                                        ? "${Provider.of<AppInfo>(context).UserPickUpLocation!.locationName!.substring(0, 24)}..."
                                        : Provider.of<AppInfo>(context)
                                            .UserPickUpLocation!
                                            .locationName!
                                    : "Not Getting Address",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Icon(Icons.star, color: Colors.grey),
                            const SizedBox(width: 15),
                            Expanded(
                              // ✅ Prevents text overflow
                              child: Text(
                                Provider.of<AppInfo>(context)
                                            .UserDropOffLocation !=
                                        null
                                    ? Provider.of<AppInfo>(context)
                                                .UserDropOffLocation!
                                                .locationName!
                                                .length >
                                            24
                                        ? "${Provider.of<AppInfo>(context).UserDropOffLocation!.locationName!.substring(0, 24)}..."
                                        : Provider.of<AppInfo>(context)
                                            .UserDropOffLocation!
                                            .locationName!
                                    : "Where to?",
                                style: const TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 18),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "SUGGESTED RIDES",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 20),

                        // Scrollable Row for vehicle types
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedVehicalType = "Car";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedVehicalType == "Car"
                                        ? (darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue)
                                        : (darkTheme
                                            ? Colors.black54
                                            : Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // ✅ Avoid extra height
                                      children: [
                                        Image.asset(
                                          "images/car1.png",
                                          fit: BoxFit.contain,
                                          width: 80, // ✅ Prevents overflow
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Car",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: selectedVehicalType == "Car"
                                                ? (darkTheme
                                                    ? Colors.black
                                                    : Colors.white)
                                                : (darkTheme
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tripDirectionDetailInfo != null
                                              ? "PKR ${((AssestantMethod.calculateFareAmountFromOriginToDestination(tripDirectionDetailInfo!) * 2) * 107).toStringAsFixed(2)}"
                                              : "null",
                                          style: const TextStyle(
                                              color: Colors.grey),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedVehicalType = "CNG";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedVehicalType == "CNG"
                                        ? (darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue)
                                        : (darkTheme
                                            ? Colors.black54
                                            : Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // ✅ Avoid extra height
                                      children: [
                                        Image.asset(
                                          "images/cng.png",
                                          fit: BoxFit.contain,
                                          width: 80, // ✅ Prevents overflow
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "CNG",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: selectedVehicalType == "CNG"
                                                ? (darkTheme
                                                    ? Colors.black
                                                    : Colors.white)
                                                : (darkTheme
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tripDirectionDetailInfo != null
                                              ? "PKR ${((AssestantMethod.calculateFareAmountFromOriginToDestination(tripDirectionDetailInfo!) * 1.5) * 107).toStringAsFixed(2)}"
                                              : "null",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              GestureDetector(
                                onTap: () {
                                  setState(() {
                                    selectedVehicalType = "Bike";
                                  });
                                },
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: selectedVehicalType == "Bike"
                                        ? (darkTheme
                                            ? Colors.amber.shade400
                                            : Colors.blue)
                                        : (darkTheme
                                            ? Colors.black54
                                            : Colors.grey.shade100),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(20),
                                    child: Column(
                                      mainAxisSize: MainAxisSize
                                          .min, // ✅ Avoid extra height
                                      children: [
                                        Image.asset(
                                          "images/bike.png",
                                          fit: BoxFit.contain,
                                          width: 80, // ✅ Prevents overflow
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          "Bike",
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: selectedVehicalType == "Bike"
                                                ? (darkTheme
                                                    ? Colors.black
                                                    : Colors.white)
                                                : (darkTheme
                                                    ? Colors.white
                                                    : Colors.black),
                                          ),
                                        ),
                                        const SizedBox(height: 2),
                                        Text(
                                          tripDirectionDetailInfo != null
                                              ? "PKR ${((AssestantMethod.calculateFareAmountFromOriginToDestination(tripDirectionDetailInfo!) * 0.8) * 107).toStringAsFixed(2)}"
                                              : "null",
                                          style: const TextStyle(
                                            color: Colors.grey,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        GestureDetector(
                          onTap: () {
                            //fuction for ride
                            if (selectedVehicalType != "") {
                              saveRideRequestInformation(selectedVehicalType);
                            } else {
                              Fluttertoast.showToast(
                                  msg:
                                      "Please select a vehical from suggested riders.");
                            }
                          },
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: darkTheme
                                  ? Colors.amber.shade400
                                  : Colors.blue,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Center(
                              child: Text(
                                "Request a Ride",
                                style: TextStyle(
                                  color:
                                      darkTheme ? Colors.black : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 20,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            //requesting ride container
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                //comment it if needed
                height: searchingForDriverContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                    topRight: Radius.circular(15),
                  ),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      LinearProgressIndicator(
                        color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                      ),
                      const SizedBox(height: 10),
                      const Center(
                        child: Text(
                          "Searching for Driver...",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () {
                          referenceRideRequest!.remove();
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (c) => const SplashScreen()));
                          setState(() {
                            searchLocationContainerHeight = 0;
                            suggestedRiderContainerHeight = 0;
                            // bottomPaddingOfMap = 300;
                          });
                        },
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: darkTheme ? Colors.black : Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            border: Border.all(
                              width: 1,
                              color: Colors.grey,
                            ),
                          ),
                          child: const Icon(
                            Icons.close,
                            size: 25,
                          ),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const SizedBox(
                        width: double.infinity,
                        child: Text(
                          "Cancel",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
            //ui for displayin asign driver information
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: assignDriverContainerHeight,
                decoration: BoxDecoration(
                  color: darkTheme ? Colors.black : Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Text(
                        driverRidestatus,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Divider(
                        thickness: 1,
                        color: darkTheme ? Colors.grey : Colors.grey[300],
                      ),
                      const SizedBox(height: 5),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  color: darkTheme
                                      ? Colors.amber.shade400
                                      : Colors.lightBlue,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(
                                  Icons.person,
                                  color:
                                      darkTheme ? Colors.black : Colors.white,
                                ),
                              ),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    driverName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      // color: Colors.black,
                                    ),
                                  ),
                                  const Row(
                                    children: [
                                      Icon(
                                        Icons.star,
                                        color: Colors.orange,
                                      ),
                                      SizedBox(width: 5),
                                      Text(
                                        //"double.parse(driverRatings).toStringAsFixed(2),"
                                        "4.4",
                                        style: TextStyle(
                                          color: Colors.grey,
                                        ),
                                      )
                                    ],
                                  )
                                ],
                              )
                            ],
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              // Image.asset("")
                              Text(
                                driverCarDetails,
                                style: const TextStyle(
                                  fontSize: 12,
                                ),
                              )
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Divider(
                        thickness: 1,
                        color: darkTheme ? Colors.grey : Colors.grey[300],
                      ),
                      ElevatedButton.icon(
                        onPressed: () {
                          // _makePhoneCall("tel:${driverPhone}");
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              darkTheme ? Colors.amber.shade400 : Colors.blue,
                        ),
                        icon: const Icon(Icons.phone),
                        label: const Text("Call Driver"),
                      ),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

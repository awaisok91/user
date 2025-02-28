import 'dart:async';

import 'package:flutter/material.dart';
import 'package:geocoder2/geocoder2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart' as loc;

import 'package:provider/provider.dart';
import 'package:user/Assestant/assestant_method.dart';
import 'package:user/Global/map_key.dart';
import 'package:user/InfoHandler/app_info.dart';
import 'package:user/Models/direction.dart';

class PreciesPicupScreen extends StatefulWidget {
  const PreciesPicupScreen({super.key});

  @override
  State<PreciesPicupScreen> createState() => _PreciesPicupScreenState();
}

class _PreciesPicupScreenState extends State<PreciesPicupScreen> {
  LatLng? picKLocation;
  loc.Location location = loc.Location();
  String? _address;
  final Completer<GoogleMapController> _controllerGooglrMap = Completer();
  GoogleMapController? newGoogleMapController;
  Position? userCurrentPosition;
  double bottomPaddingOfMap = 0;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.42796133580664, -122.085749655962),
    zoom: 14.4746,
  );
  GlobalKey<ScaffoldState> scaffoldState = GlobalKey<ScaffoldState>();
  //if void need put it
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
  }

  getAddressFromLatLang() async {
    try {
      GeoData data = await Geocoder2.getDataFromCoordinates(
          latitude: picKLocation!.latitude,
          longitude: picKLocation!.longitude,
          googleMapApiKey: mapKey);
      setState(() {
        Directions userPickUpAddress = Directions();
        userPickUpAddress.locationlatitude = picKLocation!.latitude;
        userPickUpAddress.locationlongitude = picKLocation!.longitude;
        userPickUpAddress.locationName = data.address;
        Provider.of<AppInfo>(context, listen: false)
            .updatePickUpLocationAddress(userPickUpAddress);

        // _address = data.address;
      });
    } catch (e) {
      print(e.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(top: 100, bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationEnabled: true,
            zoomGesturesEnabled: true,
            zoomControlsEnabled: true,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGooglrMap.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 50;
              });
              locatUserPosition();
            },
            onCameraMove: (CameraPosition? position) {
              if (picKLocation != position!.target) {
                setState(() {
                  picKLocation = position.target;
                });
              }
            },
            onCameraIdle: () {
              getAddressFromLatLang();
            },
          ),
          Align(
            alignment: Alignment.center,
            child: Padding(
              padding: EdgeInsets.only(top: 60, bottom: bottomPaddingOfMap),
              child: Image.asset(
                "images/intial.jpg",
                height: 30,
                width: 30,
              ),
            ),
          ),
          Positioned(
            top: 40,
            right: 20,
            left: 20,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                color: Colors.white,
              ),
              padding: const EdgeInsets.all(20),
              child: Text(
                Provider.of<AppInfo>(context).UserPickUpLocation != null
                    ? "${(Provider.of<AppInfo>(context)
                                .UserPickUpLocation!
                                .locationName!)
                            .substring(0, 24)}..."
                    : "Not Geeting Address",
                overflow: TextOverflow.visible,
                softWrap: true,
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      darkTheme ? Colors.amber.shade400 : Colors.blue,
                  textStyle: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                child: const Text("Set Current location"),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

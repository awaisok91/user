import 'dart:math';

import 'package:flutter/material.dart';
import 'package:user/Assestant/request_assistant.dart';
import 'package:user/Global/map_key.dart';
import 'package:user/Models/predicated_places.dart';
import 'package:user/widgets/place_prediction_tile.dart';

class SearchPlacesScreen extends StatefulWidget {
  const SearchPlacesScreen({super.key});

  @override
  State<SearchPlacesScreen> createState() => _SearchPlacesScreenState();
}

class _SearchPlacesScreenState extends State<SearchPlacesScreen> {
  List<PredicatedPlaces> placePredictedList = [];
  findPlcaeAuthoCompleatSearch(String inputtext) async {
    if (inputtext.length > 1) {
      String urlAutoCompleteSearch =
          "https://maps.gomaps.pro/maps/api/place/autocomplete/json?input=$inputtext&key=$mapKey&components=country:PK";
      var responseAutoComplete =
          await RequestAssistant.recieveRequest(urlAutoCompleteSearch);
      if (responseAutoComplete == "failed") {
        return;
      }
      if (responseAutoComplete["status"] == "OK") {
        var placePreddiction = responseAutoComplete["predictions"];
        var placePredictionList = (placePreddiction as List)
            .map((jsonData) => PredicatedPlaces.fromJson(jsonData))
            .toList();
        setState(() {
          placePredictedList = placePredictionList;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
        appBar: AppBar(
          backgroundColor: darkTheme ? Colors.amber.shade400 : Colors.blue,
          leading: GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Icon(
              Icons.arrow_back,
              color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          title: Text(
            "Search & Set dropoff location",
            style: TextStyle(
              color: darkTheme ? Colors.black : Colors.white,
            ),
          ),
          elevation: 0,
        ),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                boxShadow: const [
                  BoxShadow(
                    color: Colors.white54,
                    spreadRadius: 5,
                    blurRadius: 7,
                    offset: Offset(
                      0.7,
                      0.7,
                    ),
                  ),
                ],
                // borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.adjust_sharp,
                          color: darkTheme ? Colors.black : Colors.white,
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: TextField(
                              onChanged: (value) {
                                findPlcaeAuthoCompleatSearch(value);
                              },
                              decoration: InputDecoration(
                                hintText: "Search Location here...",
                                fillColor:
                                    darkTheme ? Colors.black : Colors.white,
                                filled: true,
                                border: InputBorder.none,
                                contentPadding: const EdgeInsets.only(
                                  left: 11,
                                  top: 8,
                                  bottom: 8,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
            ),
            //display the list of places
            (placePredictedList.isNotEmpty)
                ? Expanded(
                    child: ListView.separated(
                      itemCount: placePredictedList.length,
                      physics: const ClampingScrollPhysics(),
                      itemBuilder: (context, index) {
                        return PlacePredictionTile(
                          predicatedPlaces: placePredictedList[index],
                        );
                      },
                      separatorBuilder: (BuildContext context, int index) {
                        return Divider(
                          height: 0,
                          color:
                              darkTheme ? Colors.amber.shade400 : Colors.blue,
                          thickness: 0,
                        );
                      },
                    ),
                  )
                : Container(),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:user/Assestant/request_assistant.dart';
import 'package:user/Global/global.dart';
import 'package:user/Global/map_key.dart';
import 'package:user/InfoHandler/app_info.dart';
import 'package:user/Models/direction.dart';
import 'package:user/Models/predicated_places.dart';
import 'package:user/widgets/progres_dialog.dart';

class PlacePredictionTile extends StatefulWidget {
  final PredicatedPlaces? predicatedPlaces;
  const PlacePredictionTile({super.key, this.predicatedPlaces});

  @override
  State<PlacePredictionTile> createState() => _PlacePredictionTileState();
}

class _PlacePredictionTileState extends State<PlacePredictionTile> {
  getPlaceDirectionDetails(String placeId, context) async {
    showDialog(
      context: context,
      builder: (BuildContext context) => ProgresDialog(
        message: "Setting up Drop-off. Please wait....",
      ),
    );
    String placeDirectionDetailUrl =
        "https://maps.gomaps.pro/maps/api/place/details/json?place_id=$placeId&key=$mapKey";
    var responseApi =
        await RequestAssistant.recieveRequest(placeDirectionDetailUrl);
    Navigator.pop(context);
    if (responseApi == "failed") {
      return;
    }
    if (responseApi["status"] == "OK") {
      Directions directions = Directions();
      directions.locationName = responseApi["result"]["name"];
      directions.locationId = placeId;
      directions.locationlatitude =
          responseApi["result"]["geometry"]["location"]["lat"];
      directions.locationlongitude =
          responseApi["result"]["geometry"]["location"]["lng"];
      Provider.of<AppInfo>(context, listen: false)
          .updateDropOffLocationAddress(directions);
      setState(() {
        userDropOffAdress = directions.locationName!;
      });
      Navigator.pop(context, "obtainDropOff");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool darkTheme =
        MediaQuery.of(context).platformBrightness == Brightness.dark;
    return ElevatedButton(
      onPressed: () {
        if (widget.predicatedPlaces?.place_id != null) {
          getPlaceDirectionDetails(widget.predicatedPlaces!.place_id!, context);
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: darkTheme ? Colors.black : Colors.white,
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            Icon(
              Icons.add_location,
              color: darkTheme ? Colors.amber.shade400 : Colors.blue,
            ),
            const SizedBox(width: 10),
            Expanded(
                child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.predicatedPlaces!.main_text!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                  ),
                ),
                Text(
                  widget.predicatedPlaces!.secondary_text!,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 16,
                    color: darkTheme ? Colors.amber.shade400 : Colors.blue,
                  ),
                ),
              ],
            ))
          ],
        ),
      ),
    );
  }
}

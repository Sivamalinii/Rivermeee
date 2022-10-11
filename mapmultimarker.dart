import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:maps_launcher/maps_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:river_mee/model/get_pollution.dart';

class MapMultiMarker extends StatefulWidget {
  const MapMultiMarker({Key? key}) : super(key: key);

  @override
  State<MapMultiMarker> createState() => _MapMultiMarkerState();
}

class _MapMultiMarkerState extends State<MapMultiMarker> {
  List<getPollution>? apiPollution;
  bool hasPollution = false;

  final Completer<GoogleMapController> _controller = Completer();

  Future<void> fetchPollution() async {
    try {
      String url =
          "https://api-account.000webhostapp.com/river_api/getPollution.php";
      var response = await http.get(Uri.parse(url));
      apiPollution = jsonDecode(response.body)
          .map((item) => getPollution.fromJson(item))
          .toList()
          .cast<getPollution>();
      _markers.clear;

      setState(() {
        // hasPollution = true;
        for (int i = 0; i < apiPollution!.length; i++) {
          print("For Loop");
          print(apiPollution!.length);
          final marker = Marker(
            markerId: MarkerId(apiPollution![i].id.toString()),
            position: LatLng(double.parse(apiPollution![i].lat.toString()),
                double.parse(apiPollution![i].lng.toString())),
            infoWindow: InfoWindow(
                title: apiPollution![i].name.toString(),
                snippet: apiPollution![i].pollution.toString(),
                onTap: () {
                  try {
                    print("${apiPollution![i].lat}, ${apiPollution![i].lng}");
                    launchMap(double.parse(apiPollution![i].lat.toString()),
                        double.parse(apiPollution![i].lng.toString()));
                  } catch (e) {
                    print(e);
                  }
                }),
            onTap: () {
              hasPollution = true;
              print(hasPollution);
            },
          );
          print("${apiPollution![i].lat}, ${apiPollution![i].lng}");
          _markers[apiPollution![i].name.toString()] = marker;
        }
      });
    } catch (e) {
      hasPollution = false;
      _markers.clear;
      print(e);
    }
  }

  final Map<String, Marker> _markers = {};

  launchMap(lat, long) {
    MapsLauncher.launchCoordinates(lat, long);
  }

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPollution();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: IconButton(
                icon: Icon(Icons.refresh),
                onPressed: () {
                  fetchPollution();
                },
              ),
            )
          ],
          title: Text("Rivermeee"),
        ),
        body: Stack(
          children: [
            GoogleMap(
              initialCameraPosition: CameraPosition(
                target: LatLng(11.496778, 77.276376),
                zoom: 4.8,
              ),
              markers: _markers.values.toSet(),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:admin_app/api/api.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'location_tab_variables.dart';

MarkerId mId = MarkerId("currentLocation");
Marker marker = Marker(markerId: MarkerId("Current"));
double _rotation = 0.00;
String currentAddress1 = "";
String currentAddress2 = "";
var vehName;
var currentSpeed = "--";
var currentaddressdata = " ";
var isError;
var nodata;
var errormessage;
var dio = Dio();
var address;

class CurrentLocationMap extends StatefulWidget {
  const CurrentLocationMap({Key? key}) : super(key: key);
  @override
  State<CurrentLocationMap> createState() => CurrentLocationMapState();
}

class CurrentLocationMapState extends State<CurrentLocationMap> {
  final Completer<GoogleMapController> _controller = Completer();

  var currentaddressdata;
  var isError;
  var nodata;
  var errormessage;
  var dio = Dio();
  var address;
  LatLng newLocation = LatLng(0, 0);
  LatLng currentLocation = LatLng(0, 0);
  Future getCurrentLocation() async {
    ByteData byteDatacurrent = await DefaultAssetBundle.of(context)
        .load("images/navigation-marker.png");
    urlList2 = byteDatacurrent.buffer.asUint8List();
    urlList2 != null ? print("urlList2 not null") : print("urlList2 is null");
    var vehData;
    try {
      print("Device ID: ${deviceID}");
      var locationUrl =
          "${baseUrl}location/getVehicleCurrentLocation/${deviceID}";
      final response = await dio.get(locationUrl);
      vehData = response.data;
      vehName = vehData["vehicleName"];
      _rotation = vehData["heading"].toDouble();
      print("vehData: ${vehData}");
      currentSpeed = vehData["speed"].toStringAsFixed(0) ?? "--";
      print("Current Data: ${currentSpeed}");
      newLocation = LatLng(vehData["lattitude"], vehData["longitude"]);
    } on SocketException {
      setState(() {
        errormessage = 'No Internet connection';
        isError = true;
        nodata = false;
      });
    }
    bool isReceived =
        await getAddress(newLocation.latitude, newLocation.longitude);
    GoogleMapController googleMapController = await _controller.future;
    if (newLocation != currentLocation) {
      currentLocation = newLocation;
      googleMapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            zoom: 18,
            target: newLocation,
          ),
        ),
      );
      setState(() {});
    }
    return vehData;
  }

  Stream getLocationStream(Duration refreshTime) async* {
    while (true) {
      await Future.delayed(refreshTime);
      yield await getCurrentLocation();
    }
  }

  Future<bool> getAddress(double Latitude, double Longitude) async {
    final apilink =
        "http://13.234.100.167/nominatim/reverse?format=json&lat=${Latitude}&lon=${Longitude}&zoom=18&addressdetails=1";

    try {
      final response = await Dio().get(apilink);
      if (response.statusCode == 200) {
        currentaddressdata = response.data['display_name'] ?? "Not available";

        print("currentaddressdata: ${currentaddressdata}");
        List<String> strarray = currentaddressdata.split(",");
        print("addressArray: ${strarray}");
        print("strarray length: ${strarray.length}");
        currentAddress1 = "";
        currentAddress2 = "";
        // if (strarray.length <= 6) {
        //   print("inside <= 6");
        //   currentAddress1 = strarray[0];
        //   currentAddress2 = "";
        //   for (var i = 0; i < strarray.length; i++) {
        //     if (i < 2) {
        //       currentAddress1 = currentAddress1 + strarray[i] + ",";
        //     } else if (i < strarray.length - 1) {
        //       currentAddress2 = currentAddress2 + strarray[i] + ",";
        //     } else {
        //       currentAddress2 = currentAddress2 + strarray[i] + ".";
        //     }
        //   }
        // } else {
        //   print("inside > 6");
        //
        //   currentAddress2 = "";
        //   currentAddress1 = strarray[0] + ",";
        //   currentAddress1 = currentAddress1 + strarray[1] + ",";
        //   currentAddress2 =
        //       currentAddress2 + strarray[strarray.length - 5] + ",";
        //   currentAddress2 =
        //       currentAddress2 + strarray[strarray.length - 4] + ",";
        //   currentAddress2 =
        //       currentAddress2 + strarray[strarray.length - 3] + ",";
        //   currentAddress2 =
        //       currentAddress2 + strarray[strarray.length - 2] + ",";
        // }
        return true;
      } else {
        currentaddressdata = "Unknown Location";
        return false;
      }
    } catch (err) {
      print(err);

      return false;
    }
  }

  @override
  void initState() {
    // getPolyPoints();
    getCurrentLocation();

    // setCustomMarkerIcon();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(45.0),
          child: AppBar(
            leading: CircleAvatar(
              backgroundColor: Colors.white,
              child: BackButton(
                color: Colors.black,
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            title: Center(child: Text("Location - Single vehicle")),
          )),
      body: Stack(
        children: [
          StreamBuilder(
              stream: getLocationStream(const Duration(seconds: 2)),
              builder: (context, snapshot) {
                print("Snapshot: " + snapshot.toString());
                print("mId = $mId");
                print("mId runtimeType = ${mId.runtimeType}");
                // vehSpeed = snapshot.data["speed"] != null
                //     ? snapshot.data["speed"]
                //     : 0.00;
                return GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: LatLng(
                        SelectedVehCoords["lat"], SelectedVehCoords["lng"]),
                    zoom: 18,
                  ),
                  markers: {
                    Marker(
                        rotation: _rotation,
                        markerId: mId,
                        icon: BitmapDescriptor.fromBytes(urlList2),
                        position: currentLocation,
                        infoWindow: InfoWindow(
                            title: "Speed: " + currentSpeed, snippet: vehName)),
                  },
                  onMapCreated: (mapController) {
                     mapController
                        .showMarkerInfoWindow(MarkerId(mId.toString()));
                    _controller.complete(mapController);

                    // WidgetsBinding.instance.addPostFrameCallback((_) async {
                    //   await Future.delayed(
                    //     const Duration(milliseconds: 1000),
                    //   );

                    //   try {
                    //     mapController.showMarkerInfoWindow(mId);
                    //   } catch (e) {
                    //     print(e);
                    //   }
                    // });
                  },
                );
              }),
          Positioned(
              top: MediaQuery.of(context).size.height * 0.7,
              left: 5.0,
              child: Column(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height * 0.05,
                    width: 440,
                    child: Row(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 100,
                          width: 150,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    backgroundColor: Colors.blue),
                                "Speed:${currentSpeed} "),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 100,
                          width: 250,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                              " ${vehName}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 3,
                  ),
                  Container(
                    height: MediaQuery.of(context).size.height * 0.11,
                    width: 440,
                    child: Row(
                      children: [
                        Container(
                          height: MediaQuery.of(context).size.height * 98,
                          width: MediaQuery.of(context).size.width * .18,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                    backgroundColor: Colors.blue),
                                "Address: "),
                          ),
                        ),
                        Container(
                          height: MediaQuery.of(context).size.height * 100,
                          width: MediaQuery.of(context).size.width * .79,
                          decoration: BoxDecoration(
                            color: Colors.blue,
                          ),
                          child: Center(
                            child: Text(
                              "${currentaddressdata ?? "Not Available"}",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              )),
        ],
      ),
    );
  }
}

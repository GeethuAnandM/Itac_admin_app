import 'dart:async';
import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:admin_app/api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wakelock/wakelock.dart';

class LiveTrackScreen extends StatefulWidget {
  Map<dynamic, dynamic> trackdata;
  LiveTrackScreen({super.key, required this.trackdata});

  @override
  _LiveTrackScreenState createState() => _LiveTrackScreenState();
}

String startdate = "Not Available";
String enddate = "Not Available";
var pickedDate;
var pickedTime;
int difference = 0;
String lastreport = "Not Available";
DateTime? tripEnddate;
DateTime? tripStartdate;
DateTime? lastreportedtime;
double? _initallatitude;
double? _initiallongitude;
bool isError = false;
bool nodata = false;
bool isLoading = false;
var errormessage = "No Internet Connection";
double? _destinationlatitude;
double? _destinationlongitude;
int normalspeed = 1000;
int fasterspeed = 700;
int slowerspeed = 5000;
int tooslowerspeed = 7000;
String CurrentLocationaddress = "Not Available";
var dateFormat1 = DateFormat("dd-MM-yyyy hh:mm:ss a");
int currentspeed = normalspeed;
Map<MarkerId, Marker> markers = {};

PolylinePoints polylinePoints = PolylinePoints();
Map<PolylineId, Polyline> polylines = {};
List<LatLng> polylineCoordinates = [];
List<LatLng> newpolylineCoordinates = [];
StreamSubscription? _sub;

class _LiveTrackScreenState extends State<LiveTrackScreen> {
  // Google Maps controller
  StreamController _streamcontroller = StreamController();
  Completer<GoogleMapController> _controller = Completer();
  final _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> tripdetails = {};
  Timer? timer;
  // Configure map position and zoom
  CameraPosition? _kGooglePlex;
  double zoomlevel = 19;
  String currentSpeed = "0";

  Future<bool> gettripdetails() async {
    var startlocation;
    var endlocation;
    var tripId = widget.trackdata["tripId"];

    if (tripId != null) {
      print("Trip Id: ${tripId}");
      try {
        final url = "${baseUrl}trips/detail/$tripId";
        final res = await Dio().get(url);
        if (res.statusCode == 200 || res.statusCode == 201) {
          final tripData = res.data;
          print("tripData---: ${tripData}");
          if (tripData["baseStartLat"] != null &&
              tripData["baseStartLong"] != null &&
              tripData["baseEndLat"] != null &&
              tripData["baseEndLong"] != null) {
            final startlocurl =
                "http://13.234.100.167/nominatim/reverse?format=json&lat=${tripData["baseStartLat"]}&lon=${tripData["baseStartLong"]}&zoom=18&addressdetails=1";
            final endlocurl =
                "http://13.234.100.167/nominatim/reverse?format=json&lat=${tripData["baseEndLat"]}&lon=${tripData["baseEndLong"]}&zoom=18&addressdetails=1";
            final startres = await Dio().get(startlocurl);
            final endres = await Dio().get(endlocurl);
            if (startres.statusCode == 200 && endres.statusCode == 200) {
              var startaddressdata =
                  startres.data['display_name'].toString().split(",");
              var endaddressdata =
                  endres.data['display_name'].toString().split(",");
              startlocation =
                  "${startaddressdata[0]},${startaddressdata[1]},${startaddressdata[2]}";
              endlocation =
                  "${endaddressdata[0]},${endaddressdata[1]},${endaddressdata[2]}";
            }
          }
          var vehicleId = widget.trackdata["vehicleId"];
          print("vehicleId: ${vehicleId}");
          const currentlocurl = "${baseUrl}location/vehicle-location";
          if (vehicleId != null) {
            final currentVehLocSnapshot =
                await Dio().post(currentlocurl, data: {
              "vehicleIds": [vehicleId]
            });
            if (currentVehLocSnapshot.statusCode == 200) {
              // print(currentVehLocSnapshot.data[0]["latitude"]);
              var currentlocationaddress;
              if (currentVehLocSnapshot.data[0]["latitude"] != null &&
                  currentVehLocSnapshot.data[0]["longitude"] != null) {
                final currentlocation =
                    "http://13.234.100.167/nominatim/reverse?format=json&lat=${currentVehLocSnapshot.data[0]["latitude"]}&lon=${currentVehLocSnapshot.data[0]["longitude"]}&zoom=14&addressdetails=1";
                final currentVehLocAddressSnapshot =
                    await Dio().get(currentlocation);

                // print(currentVehLocAddressSnapshot.data);

                if (currentVehLocAddressSnapshot.statusCode == 200) {
                  var currentaddressdata = currentVehLocAddressSnapshot
                      .data['display_name']
                      .toString()
                      .split(",");
                  currentlocationaddress =
                      "${currentaddressdata[0]},${currentaddressdata[2]}";
                }
              }
              DateTime starttripdate;

              if (tripData["onwardActualStartTime"] != null) {
                starttripdate = DateFormat("yyyy-MM-dd HH:mm:ss")
                    .parse(tripData["onwardActualStartTime"])
                    .add(const Duration(hours: 5, minutes: 30));
                startdate = dateFormat1.format(starttripdate);
              }
              DateTime endtripdate;
              if (tripData["onwardActualEndTime"] != null) {
                endtripdate = DateFormat("yyyy-MM-dd HH:mm:ss")
                    .parse(tripData["onwardActualEndTime"])
                    .add(const Duration(hours: 5, minutes: 30));
                enddate = dateFormat1.format(endtripdate);
              }
              print("enddate:-- : ${enddate}");

              DateTime lastrepo;

              if (currentVehLocSnapshot.data[0]["packetTime"] != null) {
                // print(
                //     "packet Time actual: ${currentVehLocSnapshot.data[0]["packetTime"]}");
                lastrepo = DateFormat("yyyy-MM-dd HH:mm:ss")
                    .parse(currentVehLocSnapshot.data[0]["packetTime"])
                    .add(const Duration(hours: 0, minutes: 0));
                // print("lastrepo: ${lastrepo}");
                lastreport = dateFormat1.format(lastrepo);
                // print("packet time converted: ${lastreport}");
              }
              tripdetails = {
                "tripId": tripData["tripId"] ?? "Not Available",
                "uuid": tripData["uuid"] ?? "Not Available",
                "tripName": tripData["tripName"] ?? "Not Available",
                "licensePlate": tripData["licensePlate"] ?? "Not Available",
                "category": tripData["category"] ?? "Not Available",
                "status": tripData["status"] ?? "Not Available",
                "noofstops": tripData["geofenceCount"] ?? "Not Available",
                "onwardActualStartTime":
                    tripData["onwardActualStartTime"] ?? "Not Available",
                "onwardActualEndTime":
                    tripData["onwardActualEndTime"] ?? "Not Available",
                "totalDistance": tripData["totalDistance"] != null
                    ? tripData["travelDistance"].toStringAsFixed(2)
                    : "Not Available",
                "vehicleName": tripData["vehicleName"] ?? "Not Available",
                "driverName": widget.trackdata["driverName"] ?? "Not Available",
                "startlocation": startlocation ?? "Not Available",
                "endlocation": endlocation ?? "Not Available",
                "vehicleModel": tripData["vehicleModel"] ?? "Not Available",
                "speed":
                    currentVehLocSnapshot.data[0]["speed"] ?? "Not Available",
                "last_reported_time": lastreport,
                "eventName": currentVehLocSnapshot.data[0]["eventName"] ??
                    "Not Available",
                "currentlocation": currentlocationaddress ?? "Not Available",
                "deviceId": currentVehLocSnapshot.data[0]["deviceId"],
                "vehicleId": vehicleId,
              };
              // print("tripdetails data $tripdetails");
              return true;
            }
          }
        }
      } catch (e) {
        // print("Exception caught: ${e}");
        nodata = true;
        errormessage = "No trips Found";
      }
    }
    return false;
  }

  Stream getNumbers(Duration refreshTime) async* {
    while (true) {
      await Future.delayed(refreshTime);
      yield await getLiveTrack();
    }
  }

  var vehTrackData;
  List<dynamic> heading = [];
  Future getTrack() async {
    try {
      polylineCoordinates.clear();
      const trackurl = "${baseUrl}tracking/vehicle-track";
      // var resdata = {
      //   "id": 87,
      //   "fromTime": "2023-08-01 08:30:00",
      //   "toTime": "2023-08-02 10:11:35",
      //   "tripId": 24182
      // };

      var resdata = {
        "id": widget.trackdata["vehicleId"],
        "fromTime": widget.trackdata["expectedStartTime"],
        "toTime": dateFormat.format(DateTime.now().add(Duration(hours: 24))),
        "tripId": widget.trackdata["tripId"]
      };
      print(resdata.toString() + "resdata initilal");
      // print("data for calling vehicle track: ${resdata}");
      final response = await Dio().post(trackurl, data: resdata);
      if (response.statusCode == 200 || response.statusCode == 201) {
        vehTrackData = response.data['list'];
        for (var i = 0; i < vehTrackData.length; i++) {
          polylineCoordinates.add(LatLng(
              vehTrackData[i]["lattitude"]!, vehTrackData[i]["longitude"]!));
          heading.add(vehTrackData[i]["heading"]);
        }
        _initallatitude = vehTrackData[0]["lattitude"];
        _initiallongitude = vehTrackData[0]["longitude"];
        _destinationlatitude =
            vehTrackData[vehTrackData.length - 1]["lattitude"];
        _destinationlongitude =
            vehTrackData[vehTrackData.length - 1]["longitude"];
        _kGooglePlex = CameraPosition(
          target: LatLng(_destinationlatitude!, _destinationlongitude!),
          zoom: zoomlevel,
        );
        _addPolyLine(polylineCoordinates);
        setState(() {
          isError = false;
          nodata = false;
          isLoading = false;
          polylineCoordinates = polylineCoordinates;
        });
      }
    } on SocketException {
      setState(() {
        errormessage = 'No Internet connection';
        isError = true;
        nodata = false;
      });
    } catch (e) {
      // print("error from getdata: $e");
      setState(() {
        isError = false;
        isLoading = false;
        nodata = true;
      });
    }
  }

  DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm:ss");
  int livecounter = 0;
  Future getLiveTrack() async {
    // print("Widget track data: ${widget.trackdata}");
    GoogleMapController googleMapController2 = await _controller.future;
    try {
      const trackurl = "${baseUrl}tracking/vehicle-track";
      var resdata = {
        "id": widget.trackdata["vehicleId"],
        "fromTime": widget.trackdata["expectedStartTime"],
        "toTime": dateFormat.format(DateTime.now().add(Duration(hours: 24))),
        "tripId": widget.trackdata["tripId"]
      };
      // var resdata = {"id":63,"fromTime":"2023-01-02 00:00:00","toTime":"2023-01-02 23:59:59","tripId":21767};
      // print("res data extracted from Widget data: ${resdata}");
      final response = await Dio().post(trackurl, data: resdata);
      vehTrackData = response.data['list'];
      // print("Live track data: ${vehTrackData}");
      if (vehTrackData[vehTrackData.length - 1]["lattitude"] ==
              polylineCoordinates.last.latitude &&
          vehTrackData[vehTrackData.length - 1]["longitude"] ==
              polylineCoordinates.last.longitude) {
        // print("same");
        // livecounter++;
        // print(livecounter);
        // if (livecounter == 15 ||livecounter == 100) {
        //   //checks if the vehicle is having the same lat and long same for contionous 5 times
        //   // if yes then checks if the trip status is completed or not
        //   var status = await checkistripcompleted();
        //   if (status == true) {
        //     //break the stream
        //     _sub?.cancel();
        //     _streamcontroller.close();
        //     livecounter = 0;
        //     print("ending stream");
        //   }
        // }
      } else {
        polylineCoordinates.clear();
        heading.clear();
        for (var i = 0; i < vehTrackData.length; i++) {
          polylineCoordinates.add(LatLng(
              vehTrackData[i]["lattitude"]!, vehTrackData[i]["longitude"]!));
          heading.add(vehTrackData[i]["heading"]);
          var lastrepo = DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(vehTrackData[i]["time"])
              .add(const Duration(hours: 0, minutes: 0));

          lastreport = dateFormat1.format(lastrepo);
          // print("last_repo from live track: ${lastreport}");
        }
      }

      _kGooglePlex = CameraPosition(
        tilt: heading.last.toDouble(),
        target: LatLng(polylineCoordinates.last.latitude,
            polylineCoordinates.last.longitude),
        zoom: zoomlevel,
      );
      _addPolyLine(polylineCoordinates);
      setState(() {
        // isError = false;
        // nodata = false;
        // isLoading = false;
        polylineCoordinates = polylineCoordinates;
      });

      MarkerId markerId = const MarkerId("currentLocation");
      // print("inside live polyline coordinates");
      markers[markerId] = markers[markerId]!.copyWith(
          rotationParam: heading.last.toDouble(),
          positionParam: polylineCoordinates.last,
          infoWindowParam: InfoWindow(
              title: "${widget.trackdata["vehicleName"]}", snippet: " "));
      currentSpeed =
          vehTrackData[vehTrackData.length - 1]["speed"].toStringAsFixed(2);
      // print("speed current $currentSpeed");
      googleMapController2.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            // tilt: 70,
            // bearing: 150,
            zoom: 19,
            target: LatLng(
              polylineCoordinates.last.latitude,
              polylineCoordinates.last.longitude,
            ),
          ),
        ),
      );
      final address = await getLiveCurrentLocation(
          polylineCoordinates.last.latitude,
          polylineCoordinates.last.longitude);
      if (address == false) {
        setState(() {
          CurrentLocationaddress = "Not Available";
        });
      }
      setState(() {
        currentSpeed = currentSpeed;
      });
    } on SocketException {
      setState(() {
        errormessage = 'No Internet connection';
        isError = true;
        nodata = false;
      });
    } on DioError catch (e) {
      // print("error from getdata: $e");
      if (e.type == DioErrorType.connectTimeout) {
        setState(() {
          errormessage =
              'No Internet connection or Check if Internet is Stable';
          isError = true;
          nodata = false;
        });
      }
      if (e.response!.statusCode == 400 || e.response!.statusCode == 404) {
        setState(() {
          isError = false;
          isLoading = false;
          nodata = true;
        });
      } else {
        setState(() {
          errormessage =
              'No Internet connection or Check if Internet is Stable';
          isError = true;
          nodata = false;
        });
      }
    }
  }

  Future<bool> getLiveCurrentLocation(double Latitude, double Longitude) async {
    final apilink =
        "http://13.234.100.167/nominatim/reverse?format=json&lat=${Latitude}&lon=${Longitude}&zoom=18&addressdetails=1";
    try {
      final response = await Dio().get(apilink);
      if (response.statusCode == 200) {
        var currentaddressdata =
            response.data['display_name'].toString().split(",");
        CurrentLocationaddress = currentaddressdata.join(',');
        // CurrentLocationaddress =
        //     "${currentaddressdata[0]},${currentaddressdata[1]},${currentaddressdata[2]}";
        setState(() {
          CurrentLocationaddress = CurrentLocationaddress;
          // print("CurrentLocationaddress: ${CurrentLocationaddress}");
        });
        return true;
      } else {
        return false;
      }
    } catch (e) {
      CurrentLocationaddress = "Not Available";
      return false;
    }
  }

  Future<bool?> checkistripcompleted() async {
    var tripId = widget.trackdata["tripId"];
    final url = "${baseUrl}trips/detail/$tripId";
    try {
      final res = await Dio().get(url);
      final data = res.data;
      if (res.statusCode == 200 || res.statusCode == 201) {
        if (data["status"].toString().toLowerCase() == "completed") {
          return true;
        } else {
          return false;
        }
      }
    } on DioError catch (e) {
      if (e.response!.statusCode == 400 || e.response!.statusCode == 404) {
        return false;
      }
    }
    return null;
  }

  String? formatteddateandtime;

  final shareDuration = TextEditingController();
  final shareStart = TextEditingController();
  final PhoneNumbers = TextEditingController();
  final emailId = TextEditingController();
  final sharePurpose = TextEditingController();
  Future<void> sharetriplocation(BuildContext ctx) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var Id = int.parse(userId!);
    const sharelocationurl = "${baseUrl}info/share-location";
    formatteddateandtime = DateFormat("yyyy-MM-dd HH:mm:ss")
        .parse(formatteddateandtime!)
        .subtract(Duration(minutes: 329))
        .toString();
    print("share Start: ${formatteddateandtime}");
    var data = {
      "deviceId": tripdetails["deviceId"],
      "vehicleId": tripdetails["vehicleId"],
      "tripId": tripdetails["tripId"],
      "sharePurpose": sharePurpose.text == "" ? null : sharePurpose.text,
      "shareDuration": shareDuration.text == "" ? null : shareDuration.text,
      "shareCreatedBy": Id,
      "shareStart": formatteddateandtime == "" ? null : formatteddateandtime,
      "PhoneNos": PhoneNumbers.text == "" ? null : PhoneNumbers.text,
      "emailIds": emailId.text == "" ? null : emailId.text
    };
    print("Share data: ${data}");
    try {
      // print(data);
      final shareresult = await Dio().post(sharelocationurl, data: data);
      // print(shareresult.statusCode);
      if (shareresult.statusCode == 200) {
        Navigator.pop(ctx);
        final snackBar = SnackBar(
          content: Text(
            "Shared successfully",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      } else {
        final snackBar = SnackBar(
          content: const Text(
            'Sharing failed - check connection or data',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          backgroundColor: Colors.teal,
          behavior: SnackBarBehavior.floating,
          action: SnackBarAction(
            label: 'Dismiss',
            disabledTextColor: Colors.white,
            textColor: Colors.yellow,
            onPressed: () {
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
            },
          ),
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    } on DioError catch (e) {
      // print(e.message);
      final snackBar = SnackBar(
        content: const Text(
          'Sharing failed - check connection or data',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'Dismiss',
          disabledTextColor: Colors.white,
          textColor: Colors.yellow,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    }
  }

  // bool isloading = false;
  // bool error = false;
  @override
  void initState() {
    () async {
      setState(() {
        isLoading = true;
      });
      await gettripdetails();
      await getTrack();
      ByteData byteDatastartandend =
          await DefaultAssetBundle.of(context).load("images/location_map.png");
      Uint8List urlList = byteDatastartandend.buffer.asUint8List();
      ByteData byteDatacurrent = await DefaultAssetBundle.of(context)
          .load("images/navigation-marker.png");
      Uint8List urlList2 = byteDatacurrent.buffer.asUint8List();

      /// add origin marker origin marker
      await _addMarker(
          position: LatLng(_initallatitude!, _initiallongitude!),
          id: "origin",
          descriptor: BitmapDescriptor.fromBytes(urlList),
          title: "Source");
      // print("destination marker $_destinationlatitude$_destinationlongitude");
      // Add destination marker
      // await _addMarker(
      //     position: LatLng(_destinationlatitude!, _destinationlongitude!),
      //     id: "destination",
      //     descriptor: BitmapDescriptor.fromBytes(urlList),
      //     title: "Destination");
      await _addMarker(
          position: LatLng(polylineCoordinates.last.latitude,
              polylineCoordinates.last.longitude),
          id: "currentLocation",
          descriptor: BitmapDescriptor.fromBytes(urlList2),
          title: "${widget.trackdata["vehicleName"]}",
          rotation: heading.last.toDouble());
      await Wakelock.enable();
      setState(() {});
    }();
    super.initState();
    // _getPolyline();
  }

  @override
  void dispose() async {
    // print("dispose");
    await Wakelock.disable();
    super.dispose();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    // print(tripdetails);
    return Scaffold(
      body: isError == true
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  lottie.LottieBuilder.asset(
                    "images/82529-no-network.json",
                  ),
                  Text(
                    errormessage,
                    overflow: TextOverflow.clip,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isError = false;
                        });
                      },
                      child: Text("Refresh"))
                ],
              ),
            )
          : isLoading == true
              ? const Center(child: CircularProgressIndicator())
              : nodata == true
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          lottie.LottieBuilder.asset(
                              "images/no-data-found.json"),
                          const Text("No Routes available"),
                          const SizedBox(
                            height: 20,
                          ),
                          ElevatedButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              child: Text("Go back"))
                        ],
                      ),
                    )
                  : Stack(
                      children: [
                        Positioned.fill(
                          bottom: MediaQuery.of(context).size.height * 0.394,
                          child: StreamBuilder(
                              stream: getNumbers(const Duration(seconds: 10)),
                              initialData: polylineCoordinates.last,
                              builder: (context, snapshot) {
                                return GoogleMap(
                                  mapType: MapType.normal,
                                  rotateGesturesEnabled: true,
                                  initialCameraPosition: _kGooglePlex!,
                                  // myLocationEnabled: true,
                                  tiltGesturesEnabled: true,
                                  compassEnabled: true,
                                  scrollGesturesEnabled: true,
                                  zoomGesturesEnabled: true,
                                  polylines: Set<Polyline>.of(polylines.values),
                                  markers: Set<Marker>.of(markers.values),
                                  onMapCreated:
                                      (GoogleMapController controller) {
                                    _controller.complete(controller);
                                  },
                                );
                              }),
                        ),
                        Positioned(
                            left: 20,
                            top: 20,
                            child: CircleAvatar(
                              backgroundColor: Colors.white,
                              child: BackButton(
                                color: Colors.black,
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                              ),
                            )),
                        Positioned.fill(
                            child: DraggableScrollableSheet(
                          maxChildSize: 0.5,
                          minChildSize: 0.4,
                          initialChildSize: 0.4,
                          builder: (_, scrollController) {
                            if (tripdetails["onwardActualStartTime"] !=
                                "Not Available") {
                              tripStartdate = DateFormat("yyyy-MM-dd hh:mm:ss")
                                  .parse(tripdetails["onwardActualStartTime"])
                                  .add(Duration(hours: 5, minutes: 30));
                            }
                            if (tripdetails["onwardActualEndTime"] !=
                                "Not Available") {
                              tripEnddate = DateFormat("yyyy-MM-dd hh:mm:ss")
                                  .parse(tripdetails["onwardActualEndTime"])
                                  .add(Duration(hours: 5, minutes: 30));
                            }
                            // print(
                            //     'last reported:${tripdetails["last_reported_time"]}');

                            if (tripdetails["last_reported_time"] != null) {
                              lastreportedtime =
                                  DateFormat("yyyy-MM-dd hh:mm:ss")
                                      .parse(tripdetails["last_reported_time"]);
                            }
                            // print('last:${lastreportedtime}');

                            return SingleChildScrollView(
                              controller: scrollController,
                              child: Material(
                                elevation: 0,
                                borderRadius: const BorderRadius.vertical(
                                    top: Radius.circular(20)),
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),

                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Column(
                                          children: [
                                            TripDetailsCard(
                                                context,
                                                "images/tripid.png",
                                                tripdetails["tripName"],
                                                tripdetails["uuid"].toString(),
                                                "Trip ID & Name"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TripDetailsCard(
                                                context,
                                                "images/vehiclemodel.png",
                                                tripdetails["vehicleName"],
                                                tripdetails["vehicleModel"],
                                                "Vehicle Name & Model"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TripDetailsCardSingle(
                                                context,
                                                "images/drivername.png",
                                                tripdetails["driverName"],
                                                "Driver Name"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                Container(
                                                    width:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .width *
                                                            0.9,
                                                    height:
                                                        MediaQuery.of(context)
                                                                .size
                                                                .height *
                                                            0.12,
                                                    child: Card(
                                                      elevation: 2,
                                                      child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceEvenly,
                                                          children: [
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                // Container(
                                                                //   width: 60,
                                                                //   child: Image(
                                                                //     image: AssetImage(
                                                                //         "images/triptype.png"),
                                                                //     width: 40,
                                                                //     height: 40,
                                                                //   ),
                                                                // ),
                                                                // SizedBox(
                                                                //   height: 8,
                                                                // ),
                                                                Text(widget
                                                                    .trackdata[
                                                                        "plannedorunplanned"]
                                                                    .toString()
                                                                    .toUpperCase()),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              width: 4,
                                                            ),
                                                            Container(
                                                              color: Colors
                                                                  .black45,
                                                              height: 40,
                                                              width: 2,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text(tripdetails[
                                                                    "category"]),
                                                              ],
                                                            ),
                                                            SizedBox(
                                                              width: 2,
                                                            ),
                                                            Container(
                                                              color: Colors
                                                                  .black45,
                                                              height: 40,
                                                              width: 2,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Column(
                                                                  mainAxisAlignment:
                                                                      MainAxisAlignment
                                                                          .start,
                                                                  children: [
                                                                    Text(
                                                                      tripdetails[
                                                                          "status"],
                                                                    ),
                                                                  ],
                                                                )
                                                              ],
                                                            ),
                                                            Container(
                                                              color: Colors
                                                                  .black45,
                                                              height: 40,
                                                              width: 2,
                                                            ),
                                                            Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .center,
                                                              children: [
                                                                Text("Stops :"),
                                                                SizedBox(
                                                                  height: 8,
                                                                ),
                                                                Text(tripdetails[
                                                                        "noofstops"]
                                                                    .toString()),
                                                              ],
                                                            ),
                                                          ]),
                                                    ))
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TripDetailsCardSingle(
                                                context,
                                                "images/currentlocation.png",
                                                CurrentLocationaddress,
                                                "Start and End Location"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TripDetailsCard(
                                                context,
                                                "images/datendtime.png",
                                                "Start : " + startdate,
                                                "End : " + enddate,
                                                "Start and End Date"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TripDetailsCardSingle(
                                                context,
                                                "images/currentspeed.png",
                                                currentSpeed.toString(),
                                                "Speed"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TripDetailsCardSingle(
                                                context,
                                                "images/totaldistance.png",
                                                tripdetails["totalDistance"]
                                                        .toString() +
                                                    " kms",
                                                "Distance"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            TripDetailsCardSingle(
                                                context,
                                                "images/lastreportedtime.png",
                                                lastreport,
                                                "Last Reported Time"),
                                            // const SizedBox(
                                            //   height: 10,
                                            // ),
                                            // TripDetailsCardSingle(
                                            //     context,
                                            //     "images/event.png",
                                            //     tripdetails["eventName"]
                                            //         .toString(),
                                            //     "Event Name"),
                                          ],
                                        ),
                                      )
                                      // Expanded(
                                      //   child: ListView.builder(
                                      //     controller: scrollController,
                                      //     itemCount: 20,
                                      //     itemBuilder: (context, index) {
                                      //       return Container(
                                      //         child: Text("hello"),
                                      //       );
                                      //     },
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ))
                      ],
                    ),
    );
  }

  Row TripDetailsCardSingle(BuildContext context, String imagePath,
      String title1, String tooltipmessage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.12,
          child: Card(
            elevation: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Tooltip(
                  message: tooltipmessage,
                  child: Container(
                    width: 100,
                    child: Image(
                      image: AssetImage(imagePath),
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black45,
                  height: 50,
                  width: 2,
                ),
                Container(
                  height: 50,
                  width: 5,
                ),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 245,
                      child: AutoSizeText(
                        maxFontSize: 17.0,
                        maxLines: 3,
                        title1,
                        textAlign: TextAlign.start,
                        overflow: TextOverflow.clip,
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  Row TripDetailsCard(BuildContext context, String imagePath, String title1,
      String title2, String tooltipmessage) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: MediaQuery.of(context).size.width * 0.9,
          // height: MediaQuery.of(context).size.height * 0.100,
          child: Card(
            elevation: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Tooltip(
                  message: tooltipmessage,
                  textAlign: TextAlign.left,
                  child: Container(
                    width: 100,
                    child: Image(
                      image: AssetImage(imagePath),
                      width: 40,
                      height: 40,
                    ),
                  ),
                ),
                Container(
                  color: Colors.black45,
                  height: 40,
                  width: 2,
                ),
                Container(
                  height: 40,
                  width: 5,
                ),
                Container(
                  padding: const EdgeInsets.all(5.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 5,
                      ),
                      Text(
                        title1,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.clip,
                      ),
                      // AutoSizeText(maxFontSize:20.0,maxLines: 2, title1,overflow: TextOverflow.clip,),
                      SizedBox(
                        height: 5,
                      ),

                      Text(
                        title2,
                        textAlign: TextAlign.left,
                        overflow: TextOverflow.clip,
                      ),
                      SizedBox(
                        height: 5,
                      ),
                      // AutoSizeText(maxFontSize:20.0,maxLines: 2, title2,overflow: TextOverflow.clip,),
                    ],
                  ),
                )
              ],
            ),
          ),
        )
      ],
    );
  }

  // This method will add markers to the map based on the LatLng position
  _addMarker(
      {required LatLng position,
      required String id,
      required BitmapDescriptor descriptor,
      required String title,
      double? rotation = null}) {
    MarkerId markerId = MarkerId(id);
    if (rotation == null) {
      Marker marker = Marker(
          markerId: markerId,
          icon: descriptor,
          position: position,
          infoWindow: InfoWindow(title: title));
      markers[markerId] = marker;
    } else {
      Marker marker = Marker(
          markerId: markerId,
          rotation: rotation,
          icon: descriptor,
          position: position,
          infoWindow: InfoWindow(title: title));
      markers[markerId] = marker;
    }

    setState(() {});
  }

  _addPolyLine(List<LatLng> polylineCoordinates) {
    PolylineId id = const PolylineId("route");

    Polyline polyline = Polyline(
      polylineId: id,
      color: const Color(0xFF7B61FF),
      jointType: JointType.bevel,
      points: polylineCoordinates,
      width: 6,
    );
    polylines[id] = polyline;
    setState(() {});
  }
}

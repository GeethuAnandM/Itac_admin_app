// import 'dart:async';
// import 'dart:io';
// import 'package:admin_app/api/api.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart' as lottie;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
//
// class TripTrackLiveTrackScreen extends StatefulWidget {
//   Map<dynamic, dynamic> trackdata;
//   TripTrackLiveTrackScreen({super.key, required this.trackdata});
//
//   @override
//   _TripTrackLiveTrackScreenState createState() =>
//       _TripTrackLiveTrackScreenState();
// }
//
// String? fromTime;
// String? totime;
// double? _initallatitude;
// double? _initiallongitude;
// bool isError = false;
// bool nodata = false;
// bool isLoading = false;
// var errormessage = "No Internet Connection";
// double? _destinationlatitude;
// double? _destinationlongitude;
// int normalspeed = 1000;
// int fasterspeed = 700;
// int slowerspeed = 5000;
// int tooslowerspeed = 7000;
// String CurrentLocationaddress = "Not Available";
//
// int currentspeed = normalspeed;
// Map<MarkerId, Marker> markers = {};
//
// PolylinePoints polylinePoints = PolylinePoints();
// Map<PolylineId, Polyline> polylines = {};
// List<LatLng> polylineCoordinates = [];
// List<LatLng> newpolylineCoordinates = [];
// StreamSubscription? _sub;
//
// class _TripTrackLiveTrackScreenState extends State<TripTrackLiveTrackScreen> {
//   // Google Maps controller
//   StreamController _streamcontroller = StreamController();
//   Completer<GoogleMapController> _controller = Completer();
//   final _formKey = GlobalKey<FormState>();
//   Map<dynamic, dynamic> tripdetails = {};
//   Timer? timer;
//   // Configure map position and zoom
//   CameraPosition? _kGooglePlex;
//   double zoomlevel = 19;
//   String currentSpeed = "0";
//
//   Future<bool> gettripdetails() async {
//     var startlocation;
//     var endlocation;
//     print("widget data from gettripdetails: ${widget.trackdata}");
//     var tripId = widget.trackdata["tripId"];
//     if (tripId != null) {
//       try {
//         final url = "$baseUrl:11014/trips/detail/$tripId";
//         final res = await Dio().get(url);
//         final data = res.data;
//         if (res.statusCode == 200 || res.statusCode == 201) {
//           if (data["baseStartLat"] != null &&
//               data["baseStartLong"] != null &&
//               data["baseEndLat"] != null &&
//               data["baseEndLong"] != null) {
//             final startlocurl =
//                 "http://13.234.100.167/nominatim/reverse?format=json&lat=${data["baseStartLat"]}&lon=${data["baseStartLong"]}&zoom=18&addressdetails=1";
//             final endlocurl =
//                 "http://13.234.100.167/nominatim/reverse?format=json&lat=${data["baseEndLat"]}&lon=${data["baseEndLong"]}&zoom=18&addressdetails=1";
//             final startres = await Dio().get(startlocurl);
//             final endres = await Dio().get(endlocurl);
//             if (startres.statusCode == 200 && endres.statusCode == 200) {
//               var startaddressdata =
//                   startres.data['display_name'].toString().split(",");
//               var endaddressdata =
//                   endres.data['display_name'].toString().split(",");
//               startlocation =
//                   "${startaddressdata[0]},${startaddressdata[1]},${startaddressdata[2]}";
//               endlocation =
//                   "${endaddressdata[0]},${endaddressdata[1]},${endaddressdata[2]}";
//             }
//           }
//           var vehicleId = widget.trackdata["vehicleId"];
//           const currentlocurl = "$baseUrl:11019/location/vehicle-location";
//           if (vehicleId != null) {
//             final currentdatares = await Dio().post(currentlocurl, data: {
//               "vehicleIds": [vehicleId]
//             });
//             if (currentdatares.statusCode == 200) {
//               // print(currentdatares.data[0]["latitude"]);
//               var currentlocationaddress;
//               if (currentdatares.data[0]["latitude"] != null &&
//                   currentdatares.data[0]["longitude"] != null) {
//                 final currentlocation =
//                     "http://13.234.100.167/nominatim/reverse?format=json&lat=${currentdatares.data[0]["latitude"]}&lon=${currentdatares.data[0]["longitude"]}&zoom=14&addressdetails=1";
//                 final currentlocres = await Dio().get(currentlocation);
//
//                 // print(currentlocres.data);
//
//                 if (currentlocres.statusCode == 200) {
//                   var currentaddressdata =
//                       currentlocres.data['display_name'].toString().split(",");
//                   currentlocationaddress =
//                       "${currentaddressdata[0]},${currentaddressdata[2]}";
//                 }
//               }
//               DateTime starttripdate;
//               String startdate = "Not Available";
//               if (data["expectedStartTime"] != null) {
//                 starttripdate = DateFormat("yyyy-MM-dd HH:mm:ss")
//                     .parse(data["expectedStartTime"])
//                     .add(const Duration(hours: 5, minutes: 30));
//                 startdate = dateFormat.format(starttripdate);
//               }
//               // DateTime endtripdate;
//               // String enddate = "Not Available";
//               // if(data["onwardStartTime"] !=null) {
//               //   endtripdate = DateFormat("yyyy-MM-dd HH:mm:ss").parse(
//               //       data["onwardStartTime"]).add(
//               //       const Duration(hours: 5, minutes: 30));
//               //   enddate= dateFormat.format(endtripdate);
//               // }
//               DateTime lastrepo;
//               String lastreport = "Not Available";
//               if (currentdatares.data[0]["packetTime"] != null) {
//                 lastrepo = DateFormat("yyyy-MM-dd HH:mm:ss")
//                     .parse(currentdatares.data[0]["packetTime"])
//                     .add(const Duration(hours: 5, minutes: 30));
//                 lastreport = dateFormat.format(lastrepo);
//               }
//               tripdetails = {
//                 "tripId": data["tripId"],
//                 "uuid": data["uuid"],
//                 "tripName": data["tripName"],
//                 "licensePlate": data["licensePlate"],
//                 "category": data["category"],
//                 "status": data["status"],
//                 "noofstops": data["geofenceCount"] ?? "Not Available",
//                 "expectedStartTime": data["expectedStartTime"],
//                 "expectedEndTime": data["expectedEndTime"],
//                 "totalDistance": data["totalDistance"] != null
//                     ? data["totalDistance"].toStringAsFixed(2)
//                     : "Not Available",
//                 "vehicleName": data["vehicleName"] ?? "Not Available",
//                 "driverName": widget.trackdata["driverName"],
//                 "startlocation": startlocation ?? "Not Available",
//                 "endlocation": endlocation ?? "Not Available",
//                 "vehicleModel": data["vehicleModel"] ?? "Not Available",
//                 "speed": currentdatares.data[0]["speed"] ?? "Not Available",
//                 "last_reported_time": lastreport,
//                 "eventName":
//                     currentdatares.data[0]["eventName"] ?? "Not Available",
//                 "currentlocation": currentlocationaddress ?? "Not Available",
//                 "deviceId": currentdatares.data[0]["driverId"],
//                 "vehicleId": vehicleId,
//               };
//               // print("tripdetails data $tripdetails");
//
//               return true;
//             }
//           }
//         }
//       } catch (e) {
//         // print("Exception caught: ${e}");
//         nodata = true;
//         errormessage = "No trips Found";
//       }
//     }
//     return false;
//   }
//
//   Stream getNumbers(Duration refreshTime) async* {
//     while (true) {
//       await Future.delayed(refreshTime);
//
//       yield await getLiveTrack();
//     }
//   }
//
//   var data;
//   List<dynamic> heading = [];
//   Future getTrack() async {
//     try {
//       polylineCoordinates.clear();
//       const trackurl = "$baseUrl:11013/tracking/vehicle-track";
//       var resdata = {
//         "id": widget.trackdata["vehicleId"],
//         "fromTime": fromTime,
//         "toTime":
//             dateFormat.format(DateTime.now().add(const Duration(hours: 24))),
//         "tripId": widget.trackdata["tripId"]
//       };
//       // var resdata ={"id":63,"fromTime":"2023-01-02 00:00:00","toTime":"2023-01-02 23:59:59","tripId":21767};
//       // print(resdata.toString() + "resdata initilal");
//       final response = await Dio().post(trackurl, data: resdata);
//       if (response.statusCode == 200 || response.statusCode == 201) {
//         data = response.data['list'];
//         for (var i = 0; i < data.length; i++) {
//           polylineCoordinates
//               .add(LatLng(data[i]["lattitude"]!, data[i]["longitude"]!));
//           heading.add(data[i]["heading"]);
//         }
//         _initallatitude = data[0]["lattitude"];
//         _initiallongitude = data[0]["longitude"];
//         _destinationlatitude = data[data.length - 1]["lattitude"];
//         _destinationlongitude = data[data.length - 1]["longitude"];
//         _kGooglePlex = CameraPosition(
//           target: LatLng(_destinationlatitude!, _destinationlongitude!),
//           zoom: zoomlevel,
//         );
//         _addPolyLine(polylineCoordinates);
//         setState(() {
//           isError = false;
//           nodata = false;
//           isLoading = false;
//           polylineCoordinates = polylineCoordinates;
//         });
//       }
//     } on SocketException {
//       setState(() {
//         errormessage = 'No Internet connection';
//         isError = true;
//         nodata = false;
//       });
//     } catch (e) {
//       // print("error from getdata: $e");
//       setState(() {
//         isError = false;
//         isLoading = false;
//         nodata = true;
//       });
//     }
//   }
//
//   DateFormat dateFormat = DateFormat("yyyy-MM-dd hh:mm:ss");
//   int livecounter = 0;
//   Future getLiveTrack() async {
//     GoogleMapController googleMapController2 = await _controller.future;
//     try {
//       const trackurl = "$baseUrl:11013/tracking/vehicle-track";
//       var resdata = {
//         "id": widget.trackdata["vehicleId"],
//         "fromTime": fromTime,
//         "toTime": dateFormat.format(DateTime.now().add(Duration(hours: 24))),
//         "tripId": widget.trackdata["tripId"]
//       };
//       // var resdata = {"id":63,"fromTime":"2023-01-02 00:00:00","toTime":"2023-01-02 23:59:59","tripId":21767};
//       // print(resdata);
//       final response = await Dio().post(trackurl, data: resdata);
//       data = response.data['list'];
//       if (data[data.length - 1]["lattitude"] ==
//               polylineCoordinates.last.latitude &&
//           data[data.length - 1]["longitude"] ==
//               polylineCoordinates.last.longitude) {
//         // print("same");
//         // livecounter++;
//         // print(livecounter);
//         // if (livecounter == 15 ||livecounter == 100) {
//         //   //checks if the vehicle is having the same lat and long same for contionous 5 times
//         //   // if yes then checks if the trip status is completed or not
//         //   var status = await checkistripcompleted();
//         //   if (status == true) {
//         //     //break the stream
//         //     _sub?.cancel();
//         //     _streamcontroller.close();
//         //     livecounter = 0;
//         //     print("ending stream");
//         //   }
//         // }
//       } else {
//         polylineCoordinates.clear();
//         heading.clear();
//         for (var i = 0; i < data.length; i++) {
//           polylineCoordinates
//               .add(LatLng(data[i]["lattitude"]!, data[i]["longitude"]!));
//           heading.add(data[i]["heading"]);
//         }
//       }
//
//       _kGooglePlex = CameraPosition(
//         tilt: heading.last,
//         target: LatLng(polylineCoordinates.last.latitude,
//             polylineCoordinates.last.longitude),
//         zoom: zoomlevel,
//       );
//       _addPolyLine(polylineCoordinates);
//       setState(() {
//         // isError = false;
//         // nodata = false;
//         // isLoading = false;
//         polylineCoordinates = polylineCoordinates;
//       });
//
//       MarkerId markerId = const MarkerId("currentLocation");
//       // print("inside live polyline coordinates");
//       markers[markerId] = markers[markerId]!.copyWith(
//           rotationParam: heading.last,
//           positionParam: polylineCoordinates.last,
//           infoWindowParam: InfoWindow(
//               title: "Current position",
//               snippet: "speed: ${data[data.length - 1]["speed"]}"));
//       currentSpeed = data[data.length - 1]["speed"].toStringAsFixed(2);
//       // print("speed current $currentSpeed");
//       googleMapController2.animateCamera(
//         CameraUpdate.newCameraPosition(
//           CameraPosition(
//             // tilt: 70,
//             // bearing: 150,
//             zoom: 19,
//             target: LatLng(
//               polylineCoordinates.last.latitude,
//               polylineCoordinates.last.longitude,
//             ),
//           ),
//         ),
//       );
//       final address = await getLiveCurrentLocation(
//           polylineCoordinates.last.latitude,
//           polylineCoordinates.last.longitude);
//       if (address == false) {
//         setState(() {
//           CurrentLocationaddress = "Not Available";
//         });
//       }
//       setState(() {
//         currentSpeed = currentSpeed;
//       });
//     } on SocketException {
//       setState(() {
//         errormessage = 'No Internet connection';
//         isError = true;
//         nodata = false;
//       });
//     } on DioError catch (e) {
//       print("error from getdata: $e");
//       if (e.type == DioErrorType.connectTimeout) {
//         setState(() {
//           errormessage =
//               'No Internet connection or Check if Internet is Stable';
//           isError = true;
//           nodata = false;
//         });
//       }
//       if (e.response!.statusCode == 400 || e.response!.statusCode == 404) {
//         setState(() {
//           isError = false;
//           isLoading = false;
//           nodata = true;
//         });
//       } else {
//         setState(() {
//           errormessage =
//               'No Internet connection or Check if Internet is Stable';
//           isError = true;
//           nodata = false;
//         });
//       }
//     }
//   }
//
//   Future<bool> getLiveCurrentLocation(double Latitude, double Longitude) async {
//     final apilink =
//         "http://13.234.100.167/nominatim/reverse?format=json&lat=${Latitude}&lon=${Longitude}&zoom=18&addressdetails=1";
//     try {
//       final response = await Dio().get(apilink);
//       if (response.statusCode == 200) {
//         var currentaddressdata =
//             response.data['display_name'].toString().split(",");
//         CurrentLocationaddress =
//             "${currentaddressdata[0]},${currentaddressdata[1]},${currentaddressdata[2]}";
//         setState(() {
//           CurrentLocationaddress = CurrentLocationaddress;
//         });
//         return true;
//       } else {
//         return false;
//       }
//     } catch (e) {
//       CurrentLocationaddress = "Not Available";
//       return false;
//     }
//   }
//
//   Future<bool?> checkistripcompleted() async {
//     var tripId = widget.trackdata["tripId"];
//     final url = "$baseUrl:11014/trips/detail/$tripId";
//     try {
//       final res = await Dio().get(url);
//       final data = res.data;
//       if (res.statusCode == 200 || res.statusCode == 201) {
//         if (data["status"].toString().toLowerCase() == "completed") {
//           return true;
//         } else {
//           return false;
//         }
//       }
//     } on DioError catch (e) {
//       if (e.response!.statusCode == 400 || e.response!.statusCode == 404) {
//         return false;
//       }
//     }
//     return null;
//   }
//
//   String? formatteddateandtime;
//
//   final shareDuration = TextEditingController();
//   final shareStart = TextEditingController();
//   final PhoneNumbers = TextEditingController();
//   final emailId = TextEditingController();
//   final sharePurpose = TextEditingController();
//   Future<void> sharetriplocation(BuildContext ctx) async {
//     final prefs = await SharedPreferences.getInstance();
//     var userId = prefs.getString("user_id");
//     var Id = int.parse(userId!);
//     const sharelocationurl = "$baseUrl:11013/info/share-location";
//     var data = {
//       "deviceId": tripdetails["deviceId"],
//       "vehicleId": tripdetails["vehicleId"],
//       "tripId": tripdetails["tripId"],
//       "sharePurpose": sharePurpose.text == "" ? null : sharePurpose.text,
//       "shareDuration": shareDuration.text == "" ? null : shareDuration.text,
//       "shareCreatedBy": Id,
//       "shareStart": formatteddateandtime == "" ? null : formatteddateandtime,
//       "PhoneNos": PhoneNumbers.text == "" ? null : PhoneNumbers.text,
//       "emailIds": emailId.text == "" ? null : emailId.text
//     };
//     try {
//       // print(data);
//       final shareresult = await Dio().post(sharelocationurl, data: data);
//       print(shareresult.statusCode);
//       if (shareresult.statusCode == 200) {
//         Navigator.pop(ctx);
//         final snackBar = SnackBar(
//           content: const Text('Shared Successfully'),
//           backgroundColor: Colors.teal,
//           behavior: SnackBarBehavior.floating,
//           action: SnackBarAction(
//             label: 'Dismiss',
//             disabledTextColor: Colors.white,
//             textColor: Colors.yellow,
//             onPressed: () {
//               ScaffoldMessenger.of(context).hideCurrentSnackBar();
//             },
//           ),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       } else {
//         final snackBar = SnackBar(
//           content: const Text('Something went Wrong'),
//           backgroundColor: Colors.red,
//           behavior: SnackBarBehavior.floating,
//           action: SnackBarAction(
//             label: 'Dismiss',
//             disabledTextColor: Colors.white,
//             textColor: Colors.yellow,
//             onPressed: () {
//               ScaffoldMessenger.of(context).hideCurrentSnackBar();
//             },
//           ),
//         );
//         ScaffoldMessenger.of(context).showSnackBar(snackBar);
//       }
//     } on DioError catch (e) {
//       print(e.message);
//       final snackBar = SnackBar(
//         content: const Text('Something went Wrong'),
//         backgroundColor: Colors.red,
//         behavior: SnackBarBehavior.floating,
//         action: SnackBarAction(
//           label: 'Dismiss',
//           disabledTextColor: Colors.white,
//           textColor: Colors.yellow,
//           onPressed: () {
//             ScaffoldMessenger.of(context).hideCurrentSnackBar();
//           },
//         ),
//       );
//       ScaffoldMessenger.of(context).showSnackBar(snackBar);
//     }
//   }
//
//   // bool isloading = false;
//   // bool error = false;
//   @override
//   void initState() {
//     () async {
//       DateTime startdate = DateFormat("dd-MM-yyyy h:mm")
//           .parse(widget.trackdata["expectedStartTime"])
//           .subtract(Duration(hours: 5, minutes: 30))
//           .toLocal();
//       // print("onward start ${startdate}");
//       DateTime enddate = DateFormat("yyyy-MM-dd h:mm")
//           .parse(widget.trackdata["expectedEndTime"])
//           .subtract(Duration(hours: 5, minutes: 30))
//           .toLocal();
//       var dateFormat1 = DateFormat("yyyy-MM-dd hh:mm");
//       fromTime = "${dateFormat1.format(startdate)}:00";
//       totime = dateFormat1.format(enddate);
//       setState(() {
//         isLoading = true;
//       });
//       await gettripdetails();
//       await getTrack();
//       ByteData byteDatastartandend =
//           await DefaultAssetBundle.of(context).load("images/location_map.png");
//       Uint8List urlList = byteDatastartandend.buffer.asUint8List();
//       ByteData byteDatacurrent = await DefaultAssetBundle.of(context)
//           .load("images/navigation-marker.png");
//       Uint8List urlList2 = byteDatacurrent.buffer.asUint8List();
//
//       /// add origin marker origin marker
//       await _addMarker(
//           position: LatLng(_initallatitude!, _initiallongitude!),
//           id: "origin",
//           descriptor: BitmapDescriptor.fromBytes(urlList),
//           title: "Source");
//       // print("destination marker $_destinationlatitude$_destinationlongitude");
//       // Add destination marker
//       // await _addMarker(
//       //     position: LatLng(_destinationlatitude!, _destinationlongitude!),
//       //     id: "destination",
//       //     descriptor: BitmapDescriptor.fromBytes(urlList),
//       //     title: "Destination");
//       await _addMarker(
//           position: LatLng(polylineCoordinates.last.latitude,
//               polylineCoordinates.last.longitude),
//           id: "currentLocation",
//           descriptor: BitmapDescriptor.fromBytes(urlList2),
//           title: "currentLocation",
//           rotation: heading.last);
//       await WakelockPlus.enable();
//       setState(() {});
//     }();
//     super.initState();
//
//     // _getPolyline();
//   }
//
//   @override
//   void dispose() async {
//     // print("dispose");
//     await WakelockPlus.disable();
//     super.dispose();
//   }
//
//   @override
//   void setState(fn) {
//     if (mounted) {
//       super.setState(fn);
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     // print(tripdetails);
//     return Scaffold(
//       body: isError == true
//           ? Center(
//               child: Column(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//                   lottie.LottieBuilder.asset(
//                     "images/82529-no-network.json",
//                   ),
//                   Text(
//                     errormessage,
//                     overflow: TextOverflow.clip,
//                   ),
//                   ElevatedButton(
//                       onPressed: () {
//                         setState(() {
//                           isError = false;
//                         });
//                       },
//                       child: Text("Refresh"))
//                 ],
//               ),
//             )
//           : isLoading == true
//               ? const Center(child: CircularProgressIndicator())
//               : nodata == true
//                   ? Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         crossAxisAlignment: CrossAxisAlignment.center,
//                         children: [
//                           lottie.LottieBuilder.asset(
//                               "images/no-data-found.json"),
//                           const Text("No Routes available"),
//                           const SizedBox(
//                             height: 20,
//                           ),
//                           ElevatedButton(
//                               onPressed: () {
//                                 Navigator.pop(context);
//                               },
//                               child: Text("Go back"))
//                         ],
//                       ),
//                     )
//                   : Stack(
//                       children: [
//                         Positioned.fill(
//                           bottom: MediaQuery.of(context).size.height * 0.394,
//                           child: StreamBuilder(
//                               stream: getNumbers(const Duration(seconds: 10)),
//                               initialData: polylineCoordinates.last,
//                               builder: (context, snapshot) {
//                                 return GoogleMap(
//                                   mapType: MapType.normal,
//                                   rotateGesturesEnabled: true,
//                                   initialCameraPosition: _kGooglePlex!,
//                                   // myLocationEnabled: true,
//                                   tiltGesturesEnabled: true,
//                                   compassEnabled: true,
//                                   scrollGesturesEnabled: true,
//                                   zoomGesturesEnabled: true,
//                                   polylines: Set<Polyline>.of(polylines.values),
//                                   markers: Set<Marker>.of(markers.values),
//                                   onMapCreated:
//                                       (GoogleMapController controller) {
//                                     _controller.complete(controller);
//                                   },
//                                 );
//                               }),
//                         ),
//                         Positioned(
//                             left: 20,
//                             top: 20,
//                             child: CircleAvatar(
//                               backgroundColor: Colors.white,
//                               child: BackButton(
//                                 color: Colors.black,
//                                 onPressed: () {
//                                   Navigator.pop(context);
//                                 },
//                               ),
//                             )),
//                         Positioned.fill(
//                             child: DraggableScrollableSheet(
//                           maxChildSize: 0.7,
//                           minChildSize: 0.4,
//                           initialChildSize: 0.4,
//                           builder: (_, scrollController) {
//                             DateTime startdate = DateFormat("yyyy-MM-dd hh:mm")
//                                 .parse(tripdetails["expectedStartTime"])
//                                 .add(Duration(hours: 5, minutes: 30));
//                             DateTime enddate = DateFormat("yyyy-MM-dd hh:mm")
//                                 .parse(tripdetails["expectedEndTime"])
//                                 .add(Duration(hours: 5, minutes: 30));
//                             // print('last:${tripdetails["last_reported_time"]}');
//                             DateTime lastreportedtime =
//                                 DateFormat("yyyy-MM-dd hh:mm:ss")
//                                     .parse(tripdetails["last_reported_time"]);
//                             // print('last:${lastreportedtime}');
//                             var dateFormat1 = DateFormat("dd-MM-yyyy hh:mm a");
//                             return SingleChildScrollView(
//                               controller: scrollController,
//                               child: Material(
//                                 elevation: 0,
//                                 borderRadius: const BorderRadius.vertical(
//                                     top: Radius.circular(20)),
//                                 child: Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     crossAxisAlignment:
//                                         CrossAxisAlignment.start,
//                                     children: [
//                                       const SizedBox(
//                                         height: 20,
//                                       ),
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.end,
//                                         children: [
//                                           IconButton(
//                                               onPressed: () async {
//                                                 showDialog(
//                                                     context: context,
//                                                     builder:
//                                                         (BuildContext ctx) {
//                                                       return Form(
//                                                         key: _formKey,
//                                                         child: AlertDialog(
//                                                           scrollable: true,
//                                                           title: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceBetween,
//                                                             children: [
//                                                               const Text(
//                                                                   'Share Location'),
//                                                               IconButton(
//                                                                 onPressed: () {
//                                                                   Navigator.pop(
//                                                                       ctx);
//                                                                 },
//                                                                 icon: const Icon(
//                                                                     Icons
//                                                                         .close_outlined),
//                                                                 color:
//                                                                     Colors.red,
//                                                               )
//                                                             ],
//                                                           ),
//                                                           content: Padding(
//                                                             padding:
//                                                                 const EdgeInsets
//                                                                     .all(8.0),
//                                                             child: Column(
//                                                               children: <
//                                                                   Widget>[
//                                                                 TextFormField(
//                                                                   validator:
//                                                                       (value) {
//                                                                     if (value ==
//                                                                         null) {
//                                                                       return "Share Purpose is required";
//                                                                     }
//                                                                     return null;
//                                                                   },
//                                                                   controller:
//                                                                       sharePurpose,
//                                                                   decoration:
//                                                                       InputDecoration(
//                                                                     label: Row(
//                                                                       children: [
//                                                                         const Text(
//                                                                             '*',
//                                                                             style:
//                                                                                 TextStyle(color: Colors.red)),
//                                                                         Padding(
//                                                                           padding:
//                                                                               EdgeInsets.all(3.0),
//                                                                         ),
//                                                                         Text(
//                                                                             "Share Purpose")
//                                                                       ],
//                                                                     ),
//                                                                     icon: Icon(Icons
//                                                                         .share_location_rounded),
//                                                                   ),
//                                                                 ),
//                                                                 TextFormField(
//                                                                   validator:
//                                                                       (value) {
//                                                                     if (value ==
//                                                                         null) {
//                                                                       return "Share Duration is required";
//                                                                     }
//                                                                     return null;
//                                                                   },
//                                                                   controller:
//                                                                       shareDuration,
//                                                                   keyboardType:
//                                                                       TextInputType
//                                                                           .number,
//                                                                   decoration:
//                                                                       InputDecoration(
//                                                                     label: Row(
//                                                                       children: [
//                                                                         const Text(
//                                                                             '*',
//                                                                             style:
//                                                                                 TextStyle(color: Colors.red)),
//                                                                         Padding(
//                                                                           padding:
//                                                                               EdgeInsets.all(3.0),
//                                                                         ),
//                                                                         Text(
//                                                                             "Share Duration")
//                                                                       ],
//                                                                     ),
//                                                                     icon: Icon(Icons
//                                                                         .timelapse_outlined),
//                                                                   ),
//                                                                 ),
//                                                                 TextFormField(
//                                                                   validator:
//                                                                       (value) {
//                                                                     if (value ==
//                                                                         null) {
//                                                                       return "Phone Nos is required";
//                                                                     }
//                                                                     return null;
//                                                                   },
//                                                                   controller:
//                                                                       PhoneNumbers,
//                                                                   decoration:
//                                                                       InputDecoration(
//                                                                     label: Row(
//                                                                       children: [
//                                                                         const Text(
//                                                                             '*',
//                                                                             style:
//                                                                                 TextStyle(color: Colors.red)),
//                                                                         Padding(
//                                                                           padding:
//                                                                               EdgeInsets.all(3.0),
//                                                                         ),
//                                                                         Text(
//                                                                             "Phone Numbers")
//                                                                       ],
//                                                                     ),
//                                                                     icon: Icon(Icons
//                                                                         .phone),
//                                                                   ),
//                                                                 ),
//                                                                 TextFormField(
//                                                                   autovalidateMode:
//                                                                       AutovalidateMode
//                                                                           .onUserInteraction,
//                                                                   validator:
//                                                                       (value) {
//                                                                     if (value ==
//                                                                         null) {
//                                                                       return "Email Ids is required";
//                                                                     }
//                                                                     return null;
//                                                                   },
//                                                                   controller:
//                                                                       emailId,
//                                                                   decoration:
//                                                                       InputDecoration(
//                                                                     label: Row(
//                                                                       children: [
//                                                                         const Text(
//                                                                             '*',
//                                                                             style:
//                                                                                 TextStyle(color: Colors.red)),
//                                                                         Padding(
//                                                                           padding:
//                                                                               EdgeInsets.all(3.0),
//                                                                         ),
//                                                                         Text(
//                                                                             "Email Addresses")
//                                                                       ],
//                                                                     ),
//                                                                     icon: Icon(Icons
//                                                                         .email_outlined),
//                                                                   ),
//                                                                 ),
//                                                                 TextFormField(
//                                                                   validator:
//                                                                       (value) {
//                                                                     if (value ==
//                                                                         null) {
//                                                                       return "Sharing date is required";
//                                                                     }
//                                                                     return null;
//                                                                   },
//                                                                   controller:
//                                                                       shareStart,
//                                                                   // initialValue:
//                                                                   //     formatteddateandtime ??
//                                                                   //         "",
//                                                                   keyboardType:
//                                                                       TextInputType
//                                                                           .none,
//                                                                   onTap:
//                                                                       () async {
//                                                                     String
//                                                                         formattedDate;
//                                                                     String
//                                                                         formattedTime;
//                                                                     DateTime?
//                                                                         pickedDate =
//                                                                         await showDatePicker(
//                                                                       context:
//                                                                           context,
//                                                                       initialDate:
//                                                                           DateTime.now()
//                                                                               .toLocal(),
//                                                                       firstDate:
//                                                                           DateTime.now()
//                                                                               .toLocal(),
//                                                                       lastDate: DateTime
//                                                                               .now()
//                                                                           .toLocal()
//                                                                           .add(const Duration(
//                                                                               days: 900)),
//                                                                     );
//                                                                     if (pickedDate !=
//                                                                         null) {
//                                                                       print(
//                                                                           pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
//
//                                                                       formattedDate = DateFormat(
//                                                                               'yyyy-MM-dd')
//                                                                           .format(
//                                                                               pickedDate);
//                                                                       print(
//                                                                           formattedDate);
//                                                                       final selected =
//                                                                           await showTimePicker(
//                                                                         context:
//                                                                             context,
//                                                                         initialTime:
//                                                                             TimeOfDay.now(),
//                                                                       );
//                                                                       if (selected !=
//                                                                           null) {
//                                                                         formattedTime = selected.hour.toString() +
//                                                                             ":" +
//                                                                             selected.minute.toString() +
//                                                                             ":"
//                                                                                 "00";
//                                                                         // setState(() {
//                                                                         //   selectedTime =
//                                                                         //       selected;
//                                                                         // });
//                                                                         print(
//                                                                             formattedTime);
//                                                                         formatteddateandtime = formattedDate +
//                                                                             " " +
//                                                                             formattedTime;
//                                                                         setState(
//                                                                             () {
//                                                                           shareStart.text =
//                                                                               formatteddateandtime ?? "";
//                                                                         });
//                                                                       }
//                                                                       // setState(() {
//                                                                       //   onwardStartDateController.text =
//                                                                       //       formattedDate.toString();
//                                                                       // });
//                                                                     } else {
//                                                                       return;
//                                                                     }
//                                                                   },
//                                                                   decoration:
//                                                                       InputDecoration(
//                                                                     label: Row(
//                                                                       children: [
//                                                                         const Text(
//                                                                             '*',
//                                                                             style:
//                                                                                 TextStyle(color: Colors.red)),
//                                                                         Padding(
//                                                                           padding:
//                                                                               EdgeInsets.all(3.0),
//                                                                         ),
//                                                                         Text(
//                                                                             "Start Sharing From")
//                                                                       ],
//                                                                     ),
//                                                                     icon: Icon(Icons
//                                                                         .date_range_outlined),
//                                                                   ),
//                                                                 )
//                                                               ],
//                                                             ),
//                                                           ),
//                                                           actions: [
//                                                             ElevatedButton(
//                                                                 child: const Text(
//                                                                     "Submit"),
//                                                                 onPressed:
//                                                                     () async {
//                                                                   _formKey
//                                                                       .currentState!
//                                                                       .validate();
//                                                                   await sharetriplocation(
//                                                                       ctx);
//                                                                 })
//                                                           ],
//                                                         ),
//                                                       );
//                                                     });
//                                               },
//                                               icon: const Image(
//                                                 image: AssetImage(
//                                                     "images/share.png"),
//                                               ))
//                                         ],
//                                       ),
//
//                                       const SizedBox(
//                                         height: 20,
//                                       ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(top: 10),
//                                         child: Column(
//                                           children: [
//                                             TripDetailsCard(
//                                                 context,
//                                                 "images/tripid.png",
//                                                 tripdetails["tripName"],
//                                                 tripdetails["uuid"].toString(),
//                                                 "uuid Id & Name"),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             TripDetailsCard(
//                                                 context,
//                                                 "images/vehiclemodel.png",
//                                                 tripdetails["vehicleName"],
//                                                 tripdetails["vehicleModel"],
//                                                 "Vehicle Name & Model"),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             TripDetailsCardSingle(
//                                                 context,
//                                                 "images/drivername.png",
//                                                 tripdetails["driverName"],
//                                                 "Driver Name"),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Container(
//                                                     width:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .width *
//                                                             0.9,
//                                                     height:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .height *
//                                                             0.12,
//                                                     child: Card(
//                                                       elevation: 2,
//                                                       child: Row(
//                                                           mainAxisAlignment:
//                                                               MainAxisAlignment
//                                                                   .spaceEvenly,
//                                                           children: [
//                                                             Column(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .center,
//                                                               children: [
//                                                                 // Container(
//                                                                 //   width: 60,
//                                                                 //   child: Image(
//                                                                 //     image: AssetImage(
//                                                                 //         "images/triptype.png"),
//                                                                 //     width: 40,
//                                                                 //     height: 40,
//                                                                 //   ),
//                                                                 // ),
//                                                                 // SizedBox(
//                                                                 //   height: 8,
//                                                                 // ),
//                                                                 Text(widget
//                                                                     .trackdata[
//                                                                         "plannedorunplanned"]
//                                                                     .toString()
//                                                                     .toUpperCase()),
//                                                               ],
//                                                             ),
//                                                             SizedBox(
//                                                               width: 8,
//                                                             ),
//                                                             Container(
//                                                               color: Colors
//                                                                   .black45,
//                                                               height: 40,
//                                                               width: 2,
//                                                             ),
//                                                             Column(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .center,
//                                                               children: [
//                                                                 // Container(
//                                                                 //   width: 60,
//                                                                 //   child: Image(
//                                                                 //     image: AssetImage(
//                                                                 //         "images/tripcategory.png"),
//                                                                 //     width: 40,
//                                                                 //     height: 40,
//                                                                 //   ),
//                                                                 // ),
//                                                                 // SizedBox(
//                                                                 //   height: 8,
//                                                                 // ),
//                                                                 Text(tripdetails[
//                                                                     "category"]),
//                                                               ],
//                                                             ),
//                                                             SizedBox(
//                                                               width: 5,
//                                                             ),
//                                                             Container(
//                                                               color: Colors
//                                                                   .black45,
//                                                               height: 40,
//                                                               width: 2,
//                                                             ),
//                                                             Column(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .center,
//                                                               children: [
//                                                                 // Container(
//                                                                 //   width: 60,
//                                                                 //   child: Image(
//                                                                 //     image: AssetImage(
//                                                                 //         "images/tripstatus.png"),
//                                                                 //     width: 40,
//                                                                 //     height: 40,
//                                                                 //   ),
//                                                                 // ),
//                                                                 // SizedBox(
//                                                                 //   height: 5,
//                                                                 // ),
//                                                                 Column(
//                                                                   mainAxisAlignment:
//                                                                       MainAxisAlignment
//                                                                           .start,
//                                                                   children: [
//                                                                     Text(
//                                                                       tripdetails[
//                                                                           "status"],
//                                                                     ),
//                                                                   ],
//                                                                 )
//                                                               ],
//                                                             ),
//                                                             Container(
//                                                               color: Colors
//                                                                   .black45,
//                                                               height: 40,
//                                                               width: 2,
//                                                             ),
//                                                             Column(
//                                                               mainAxisAlignment:
//                                                                   MainAxisAlignment
//                                                                       .center,
//                                                               children: [
//                                                                 Text("Stops :"),
//                                                                 SizedBox(
//                                                                   height: 8,
//                                                                 ),
//                                                                 Text(tripdetails[
//                                                                         "noofstops"]
//                                                                     .toString()),
//                                                               ],
//                                                             ),
//                                                           ]),
//                                                     ))
//                                               ],
//                                             ),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             TripDetailsCardSingle(
//                                                 context,
//                                                 "images/currentlocation.png",
//                                                 CurrentLocationaddress,
//                                                 "Start and End Location"),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             TripDetailsCard(
//                                                 context,
//                                                 "images/datendtime.png",
//                                                 "Start : " +
//                                                     dateFormat1
//                                                         .format(startdate),
//                                                 "End : " +
//                                                     dateFormat1
//                                                         .format(enddate)
//                                                         .toString(),
//                                                 "Start and End Date"),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             Row(
//                                               mainAxisAlignment:
//                                                   MainAxisAlignment.center,
//                                               children: [
//                                                 Container(
//                                                     width:
//                                                         MediaQuery.of(context)
//                                                                 .size
//                                                                 .width *
//                                                             0.9,
//                                                     // height:
//                                                     //     MediaQuery.of(context)
//                                                     //             .size
//                                                     //             .height *
//                                                     //         0.23,
//                                                     child: Card(
//                                                       elevation: 2,
//                                                       child: Padding(
//                                                         padding:
//                                                             EdgeInsets.all(10),
//                                                         child: Row(
//                                                             mainAxisAlignment:
//                                                                 MainAxisAlignment
//                                                                     .spaceEvenly,
//                                                             children: [
//                                                               Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 children: [
//                                                                   Container(
//                                                                     width: 60,
//                                                                     child:
//                                                                         const Image(
//                                                                       image: AssetImage(
//                                                                           "images/currentspeed.png"),
//                                                                       width: 40,
//                                                                       height:
//                                                                           40,
//                                                                     ),
//                                                                   ),
//                                                                   const SizedBox(
//                                                                     height: 8,
//                                                                   ),
//                                                                   Text(
//                                                                       " $currentSpeed"),
//                                                                 ],
//                                                               ),
//                                                               SizedBox(
//                                                                 height: 5,
//                                                               ),
//                                                               Container(
//                                                                 color: Colors
//                                                                     .black45,
//                                                                 height: 40,
//                                                                 width: 2,
//                                                               ),
//                                                               Column(
//                                                                 mainAxisAlignment:
//                                                                     MainAxisAlignment
//                                                                         .center,
//                                                                 children: [
//                                                                   Container(
//                                                                     width: 60,
//                                                                     child:
//                                                                         Image(
//                                                                       image: AssetImage(
//                                                                           "images/currentlocation.png"),
//                                                                       width: 40,
//                                                                       height:
//                                                                           40,
//                                                                     ),
//                                                                   ),
//                                                                   SizedBox(
//                                                                     height: 8,
//                                                                   ),
//                                                                   Container(
//                                                                     width: 150,
//                                                                     // height: 100,
//                                                                     child: Text(
//                                                                       "current: " +
//                                                                           tripdetails[
//                                                                               "currentlocation"],
//                                                                       overflow:
//                                                                           TextOverflow
//                                                                               .clip,
//                                                                     ),
//                                                                   ),
//                                                                 ],
//                                                               ),
//                                                               // SizedBox(width: 5,),
//                                                             ]),
//                                                       ),
//                                                     ))
//                                               ],
//                                             ),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             TripDetailsCardSingle(
//                                                 context,
//                                                 "images/totaldistance.png",
//                                                 tripdetails["totalDistance"]
//                                                     .toString(),
//                                                 "Total Distance"),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             TripDetailsCardSingle(
//                                                 context,
//                                                 "images/lastreportedtime.png",
//                                                 dateFormat1
//                                                     .format(lastreportedtime)
//                                                     .toString(),
//                                                 "Last Reported Time"),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             TripDetailsCardSingle(
//                                                 context,
//                                                 "images/event.png",
//                                                 tripdetails["eventName"]
//                                                     .toString(),
//                                                 "Event Name"),
//                                           ],
//                                         ),
//                                       )
//                                       // Expanded(
//                                       //   child: ListView.builder(
//                                       //     controller: scrollController,
//                                       //     itemCount: 20,
//                                       //     itemBuilder: (context, index) {
//                                       //       return Container(
//                                       //         child: Text("hello"),
//                                       //       );
//                                       //     },
//                                       //   ),
//                                       // ),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ))
//                       ],
//                     ),
//     );
//   }
//
//   Row TripDetailsCardSingle(BuildContext context, String imagePath,
//       String title1, String tooltipmessage) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           height: MediaQuery.of(context).size.height * 0.085,
//           child: Card(
//             elevation: 2,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Tooltip(
//                   message: tooltipmessage,
//                   child: Container(
//                     width: 100,
//                     child: Image(
//                       image: AssetImage(imagePath),
//                       width: 40,
//                       height: 40,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   color: Colors.black45,
//                   height: 40,
//                   width: 2,
//                 ),
//                 Expanded(
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Text(
//                         title1,
//                         overflow: TextOverflow.clip,
//                       ),
//                     ],
//                   ),
//                 )
//               ],
//             ),
//           ),
//         )
//       ],
//     );
//   }
//
//   Row TripDetailsCard(BuildContext context, String imagePath, String title1,
//       String title2, String tooltipmessage) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           height: MediaQuery.of(context).size.height * 0.100,
//           child: Card(
//             elevation: 2,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceAround,
//               children: [
//                 Tooltip(
//                   message: tooltipmessage,
//                   child: Container(
//                     width: 100,
//                     child: Image(
//                       image: AssetImage(imagePath),
//                       width: 40,
//                       height: 40,
//                     ),
//                   ),
//                 ),
//                 Container(
//                   color: Colors.black45,
//                   height: 40,
//                   width: 2,
//                 ),
//                 Expanded(
//                     child: Padding(
//                   padding: EdgeInsets.all(15),
//                   child: Column(
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       Expanded(
//                           child: Text(
//                         title1,
//                         overflow: TextOverflow.clip,
//                       )),
//                       SizedBox(
//                         height: 10,
//                       ),
//                       Text(
//                         title2,
//                         overflow: TextOverflow.ellipsis,
//                       )
//                     ],
//                   ),
//                 ))
//               ],
//             ),
//           ),
//         )
//       ],
//     );
//   }
//
//   // This method will add markers to the map based on the LatLng position
//   _addMarker(
//       {required LatLng position,
//       required String id,
//       required BitmapDescriptor descriptor,
//       required String title,
//       double? rotation = null}) {
//     MarkerId markerId = MarkerId(id);
//     if (rotation == null) {
//       Marker marker = Marker(
//           markerId: markerId,
//           icon: descriptor,
//           position: position,
//           infoWindow: InfoWindow(title: title));
//       markers[markerId] = marker;
//     } else {
//       Marker marker = Marker(
//           markerId: markerId,
//           rotation: rotation,
//           icon: descriptor,
//           position: position,
//           infoWindow: InfoWindow(title: title));
//       markers[markerId] = marker;
//     }
//
//     setState(() {});
//   }
//
//   _addPolyLine(List<LatLng> polylineCoordinates) {
//     PolylineId id = const PolylineId("route");
//
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: const Color(0xFF7B61FF),
//       jointType: JointType.bevel,
//       points: polylineCoordinates,
//       width: 6,
//     );
//     polylines[id] = polyline;
//     setState(() {});
//   }
// }

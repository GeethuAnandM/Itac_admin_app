// import 'dart:async';
// import 'dart:io';
// import 'package:admin_app/api/api.dart';
// import 'package:auto_size_text/auto_size_text.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:intl/intl.dart';
// import 'package:location/location.dart';
// import 'package:lottie/lottie.dart' as lottie;
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:wakelock_plus/wakelock_plus.dart';
//
// class TripVehicleTrack extends StatefulWidget {
//   Map<dynamic, dynamic> trackdata;
//   TripVehicleTrack({super.key, required this.trackdata});
//
//   @override
//   _TripVehicleTrackState createState() => _TripVehicleTrackState();
// }
//
// var isRun = false;
// int normalspeed = 1000;
// int fasterspeed = 700;
// int slowerspeed = 5000;
// int tooslowerspeed = 7000;
//
// class _TripVehicleTrackState extends State<TripVehicleTrack> {
//   double? _initallatitude;
//   double? _initiallongitude;
//   bool isError = false;
//   bool nodata = false;
//   bool isLoading = false;
//   var errormessage = "No Internet Connection";
//   double? _destinationlatitude;
//   double? _destinationlongitude;
//   List<dynamic> heading = [];
//   var packetTime = "Not Available";
//   int currentspeed = normalspeed;
//   Map<MarkerId, Marker> markers = {};
//
//   PolylinePoints polylinePoints = PolylinePoints();
//   Map<PolylineId, Polyline> polylines = {};
//   List<LatLng> polylineCoordinates = [];
//   // Google Maps controller
//   Completer<GoogleMapController> _controller = Completer();
//   final _formKey = GlobalKey<FormState>();
//   Map<dynamic, dynamic> tripdetails = {};
//   Timer? timer;
//   // Configure map position and zoom
//   CameraPosition? _kGooglePlex;
//   double zoomlevel = 7.5;
//
//   Future<bool> gettripdetails() async {
//     var startlocation;
//     var endlocation;
//
//     var tripId = widget.trackdata["tripId"];
//     print("widget.trackdata: ${widget.trackdata}");
//     if (tripId != null) {
//       try {
//         final url = "$baseUrl:11014/trips/detail/${tripId.toString()}";
//         final res = await Dio().get(url);
//         final data = res.data;
//         var deviceId = widget.trackdata["deviceId"];
//         // print("data is ${data}");
//         // print(res.statusCode);
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
//           // print("iam here ${vehicleId}");
//           final currentlocurl = "$baseUrl:11019/location/vehicle-location";
//           var speed = "Not Available";
//           var eventname = "Not Available";
//           if (vehicleId != null) {
//             final currentdatares = await Dio().post(currentlocurl, data: {
//               "vehicleIds": [vehicleId]
//             });
//             // print(currentdatares.statusCode);
//             if (currentdatares.statusCode == 200) {
//               // print(currentdatares.data[0]["latitude"]);
//               var currentlocationaddress;
//               if (currentdatares.data[0]["latitude"] != null &&
//                   currentdatares.data[0]["longitude"] != null) {
//                 final currentlocation =
//                     "http://13.234.100.167/nominatim/reverse?format=json&lat=${currentdatares.data[0]["latitude"]}&lon=${currentdatares.data[0]["longitude"]}&zoom=14&addressdetails=1";
//                 final currentlocres = await Dio().get(currentlocation);
//                 // print(currentlocres.data);
//                 if (currentlocres.statusCode == 200) {
//                   var Currentaddressdata =
//                       currentlocres.data['display_name'].toString().split(",");
//                   currentlocationaddress =
//                       "${Currentaddressdata[0]},${Currentaddressdata[1]},${Currentaddressdata[2]}";
//                 }
//               }
//               tripdetails = {
//                 "uuid": data['uuid'],
//                 "tripId": data["tripId"],
//                 "tripName": data["tripName"] ?? "---",
//                 "licensePlate": data["licensePlate"] ?? "---",
//                 "category": data["category"] ?? "---",
//                 "status": data["status"] ?? "---",
//                 "noofstops": data["geofenceCount"] ?? "Not Available",
//                 "onwardActualStartTime": data["onwardActualStartTime"],
//                 "onwardActualEndTime": data["onwardActualEndTime"],
//                 "onwardStartTime": data['onwardStartTime'],
//                 "onwardEndTime": data['onwardEndTime'],
//                 "totalDistance": data["travelDistance"] != null
//                     ? data["travelDistance"].toStringAsFixed(2)
//                     : "Not Available",
//                 "vehicleName": data["vehicleName"] ?? "Not Available",
//                 "driverName": widget.trackdata["driverName"],
//                 "startlocationActual": data["startLocation"] ?? "Not Available",
//                 "endlocationActual": data["endLocation"] ?? "Not Available",
//                 "startlocation": data["startBasePoint"] ?? "Not Available",
//                 "endlocation": data["endBasePoint"] ?? "Not Available",
//                 "vehicleModel": data["vehicleModel"] ?? "Not Available",
//                 "speed": speed,
//                 "last_reported_time": packetTime,
//                 "eventName": eventname,
//                 "currentlocation": currentlocationaddress ?? "Not Available",
//                 "deviceId": deviceId,
//                 "vehicleId": vehicleId,
//               };
//               // print("tripdetails data $tripdetails");
//
//               return true;
//             }
//           }
//         }
//       } on SocketException {
//         setState(() {
//           errormessage = 'No Internet connection';
//           isError = true;
//           isLoading = false;
//           nodata = false;
//         });
//       } on DioError catch (e) {
//         if (e.type == DioErrorType.connectTimeout) {
//           setState(() {
//             errormessage = 'Something went Wrong';
//             isError = true;
//             isLoading = false;
//             nodata = false;
//           });
//         }
//       }
//     }
//     return false;
//   }
//
//   var data;
//   Future<void> getTrack() async {
//     try {
//       DateTime startdate =
//           DateFormat("yyyy-MM-dd").parse(tripdetails["onwardStartTime"]);
//       DateTime enddate =
//           DateFormat("yyyy-MM-dd").parse(tripdetails["onwardEndTime"]);
//       // print("returnend:${tripdetails["returnEndTime"]}");
//       // print("returnendtime:${tripdetails["onwardStartTime"]}");
//       var dateFormat1 = DateFormat("yyyy-MM-dd");
//       polylineCoordinates.clear();
//       const trackurl = "$baseUrl:11013/tracking/vehicle-track";
//       var resdata = {
//         "id": tripdetails["vehicleId"],
//         "fromTime": dateFormat1.format(startdate) + " 00:00:00",
//         "toTime": dateFormat1.format(enddate) + " 23:59:00",
//         "tripId": tripdetails["tripId"]
//       };
//       // print(resdata);
//       final response = await Dio().post(trackurl, data: resdata);
//       data = response.data['list'];
//       for (var i = 0; i < data.length; i++) {
//         polylineCoordinates
//             .add(LatLng(data[i]["lattitude"]!, data[i]["longitude"]!));
//         heading.add(data[i]["heading"]);
//       }
//
//       _initallatitude = data[0]["lattitude"];
//       _initiallongitude = data[0]["longitude"];
//       _destinationlatitude = data[data.length - 1]["lattitude"];
//       _destinationlongitude = data[data.length - 1]["longitude"];
//       _kGooglePlex = CameraPosition(
//         target: LatLng(_initallatitude!, _initiallongitude!),
//         zoom: zoomlevel,
//       );
//       _addPolyLine(polylineCoordinates);
//       setState(() {
//         isError = false;
//         nodata = false;
//         isLoading = false;
//         polylineCoordinates = polylineCoordinates;
//       });
//     } on SocketException {
//       setState(() {
//         errormessage = 'No Internet connection';
//         isError = true;
//         isLoading = false;
//         nodata = false;
//       });
//     } on DioError catch (e) {
//       if (e.type == DioErrorType.connectTimeout) {
//         setState(() {
//           errormessage = 'Something went Wrong';
//           isError = true;
//           isLoading = false;
//           nodata = false;
//         });
//       }
//     } catch (e) {
//       print("error from getdata: $e");
//       setState(() {
//         isError = false;
//         isLoading = false;
//         nodata = true;
//       });
//     }
//   }
//
//   LocationData? currentLocation;
//   int counter = 0;
//   bool isPause = false;
//   String? formatteddateandtime;
//   void locationanimation() async {
//     var j = 0;
//     GoogleMapController googleMapController = await _controller.future;
//     MarkerId markerId = const MarkerId("currentLocation");
//     // print(markers[markerId]);
//     // print(polylineCoordinates.length);
//     if (isPause) {
//       if (counter != 0) {
//         j = counter;
//       }
//     }
//     timer = Timer.periodic(Duration(milliseconds: currentspeed), (_) {
//       // print("inside timer periodic");
//
//       if (j < polylineCoordinates.length) {
//         counter = j;
//         // print("inside polyline coordinates");
//         markers[markerId] = markers[markerId]!.copyWith(
//             positionParam: polylineCoordinates[j],
//             rotationParam: heading[j],
//             infoWindowParam: InfoWindow(
//                 title: "Current position",
//                 snippet: "speed: ${data[j]["speed"]}"));
//         googleMapController.animateCamera(
//           CameraUpdate.newCameraPosition(
//             CameraPosition(
//               // tilt: 70,
//               // bearing: 150,
//               zoom: 15,
//               target: LatLng(
//                 polylineCoordinates[j].latitude,
//                 polylineCoordinates[j].longitude,
//               ),
//             ),
//           ),
//         );
//         // print(j);
//         j++;
//         // counter++;
//         setState(() {});
//       } else {
//         counter = 0;
//         // print("timer cancel");
//         timer!.cancel();
//         j = 0;
//       }
//       // }
//     });
//   }
//
//   void pausetrack() {
//     timer!.cancel();
//   }
//
//   void resettoorigin() async {
//     timer!.cancel();
//     GoogleMapController googleMapController = await _controller.future;
//     MarkerId markerId = const MarkerId("currentLocation");
//     markers[markerId] = markers[markerId]!.copyWith(
//         positionParam: LatLng(_initallatitude!, _initiallongitude!),
//         rotationParam: heading[0]);
//     googleMapController.animateCamera(
//       CameraUpdate.newCameraPosition(
//         CameraPosition(
//           zoom: zoomlevel,
//           target: LatLng(
//             _initallatitude!,
//             _initiallongitude!,
//           ),
//         ),
//       ),
//     );
//     setState(() {});
//   }
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
//       // print(shareresult.statusCode);
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
//       setState(() {
//         isLoading = true;
//       });
//       await gettripdetails();
//
//       await getTrack();
//       // print(_initiallongitude);
//       if (_initiallongitude != null &&
//           _initallatitude != null &&
//           _destinationlongitude != null &&
//           _destinationlatitude != null) {
//         ByteData byteDatastartandend = await DefaultAssetBundle.of(context)
//             .load("images/location_map.png");
//         Uint8List urlList = byteDatastartandend.buffer.asUint8List();
//         ByteData byteDatacurrent = await DefaultAssetBundle.of(context)
//             .load("images/navigation-marker.png");
//         Uint8List urlList2 = byteDatacurrent.buffer.asUint8List();
//
//         /// add origin marker origin marker
//         await _addMarker(
//             position: LatLng(_initallatitude!, _initiallongitude!),
//             id: "origin",
//             descriptor: BitmapDescriptor.fromBytes(urlList),
//             title: "Source");
//         // print("destination marker $_destinationlatitude$_destinationlongitude");
//         // Add destination marker
//         await _addMarker(
//             position: LatLng(_destinationlatitude!, _destinationlongitude!),
//             id: "destination",
//             descriptor: BitmapDescriptor.fromBytes(urlList),
//             title: "Destination");
//         await _addMarker(
//             position: LatLng(_initallatitude!, _initiallongitude!),
//             id: "currentLocation",
//             descriptor: BitmapDescriptor.fromBytes(urlList2),
//             title: "currentLocation",
//             rotation: heading[0]);
//         setState(() {});
//       } else {
//         setState(() {
//           nodata = true;
//           isLoading = false;
//           isError = false;
//         });
//       }
//     }();
//     super.initState();
//
//     // _getPolyline();
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
//   void dispose() {
//     // print("dispose");
//     super.dispose();
//   }
//
//   List<String> speedModes = <String>[
//     "Faster Speed",
//     "Normal Speed",
//     "Slower Speed",
//     "Too Slow"
//   ];
//   String? dropDownselectedmode = "Normal Speed";
//   DateTime? lastreportedtime;
//
//   @override
//   Widget build(BuildContext context) {
//     final isRunning = timer == null ? false : timer!.isActive;
//     isRun = isRunning;
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
//                   Text(errormessage),
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
//                           child: GoogleMap(
//                             mapType: MapType.normal,
//                             rotateGesturesEnabled: true,
//                             initialCameraPosition: _kGooglePlex!,
//                             // myLocationEnabled: true,
//                             tiltGesturesEnabled: true,
//                             compassEnabled: true,
//                             scrollGesturesEnabled: true,
//                             zoomGesturesEnabled: true,
//
//                             polylines: Set<Polyline>.of(polylines.values),
//                             markers: Set<Marker>.of(markers.values),
//                             onMapCreated: (GoogleMapController controller) {
//                               _controller.complete(controller);
//                             },
//                           ),
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
//
//                         Positioned.fill(
//                             child: DraggableScrollableSheet(
//                           maxChildSize: 0.7,
//                           minChildSize: 0.4,
//                           initialChildSize: 0.4,
//                           builder: (_, scrollController) {
//                             // print(
//                             //     "is UTC ${DateFormat("yyyy-MM-dd hh:mm").parse(tripdetails["onwardStartTime"]).add(Duration(hours: 5, minutes: 30))}");
//                             DateTime startdate = DateFormat("yyyy-MM-dd hh:mm")
//                                 .parse(tripdetails["onwardStartTime"])
//                                 .add(const Duration(hours: 5, minutes: 30));
//                             DateTime enddate = DateFormat("yyyy-MM-dd hh:mm")
//                                 .parse(tripdetails["onwardEndTime"])
//                                 .add(const Duration(hours: 5, minutes: 30));
//                             if (tripdetails["last_reported_time"] != "--") {
//                               // print("jsdijsidj");
//                               if (tripdetails["last_reported_time"] !=
//                                   "Not Available") {
//                                 lastreportedtime =
//                                     DateFormat("yyyy-MM-dd hh:mm").parse(
//                                         tripdetails["last_reported_time"]);
//                               }
//                             }
//                             // print(
//                             //     "last reported time after 5hrs added $lastreportedtime");
//                             var dateFormat1 = DateFormat("dd-MM-yyyy hh:mm");
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
//                                             MainAxisAlignment.spaceEvenly,
//                                         children: [
//                                           isRun == false
//                                               ? IconButton(
//                                                   onPressed: () async {
//                                                     await WakelockPlus.enable();
//                                                     locationanimation();
//                                                   },
//                                                   icon: Image(
//                                                     image: AssetImage(
//                                                         "images/play.png"),
//                                                   ),
//                                                 )
//                                               : IconButton(
//                                                   onPressed: () async {
//                                                     await WakelockPlus.disable();
//                                                     pausetrack();
//                                                     setState(() {
//                                                       isPause = true;
//                                                     });
//                                                   },
//                                                   icon: Image(
//                                                     image: AssetImage(
//                                                         "images/pause.png"),
//                                                   ),
//                                                 ),
//                                           const SizedBox(
//                                             width: 10,
//                                           ),
//                                           IconButton(
//                                             onPressed: () async {
//                                               await WakelockPlus.disable();
//                                               resettoorigin();
//                                               setState(() {
//                                                 isPause = false;
//                                               });
//                                             },
//                                             icon: Image(
//                                               image: AssetImage(
//                                                   "images/restart.png"),
//                                             ),
//                                           ),
//                                           const SizedBox(
//                                             width: 10,
//                                           ),
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
//                                                                       // print(pickedDate
//                                                                       //     .toUtc()); //pickedDate output format => 2021-03-10 00:00:00.000
//
//                                                                       formattedDate = DateFormat(
//                                                                               'yyyy-MM-dd')
//                                                                           .format(
//                                                                               pickedDate.toUtc());
//                                                                       // print(
//                                                                       //     formattedDate);
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
//                                                                         // print(
//                                                                         //     formattedTime);
//                                                                         // DateTime formate = DateFormat("yyyy-MM-dd HH:mm:ss").parse("$formattedDate $formattedTime");
//                                                                         // String formatteddateandtime = DateFormat("yyyy-MM-dd HH:mm:ss",Intl.systemLocale).format(formate);
//                                                                         formatteddateandtime =
//                                                                             "$formattedDate $formattedTime";
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
//                                       Row(
//                                         mainAxisAlignment:
//                                             MainAxisAlignment.center,
//                                         children: [
//                                           DropdownButton<String>(
//                                               hint: const Text(
//                                                   "Select a speedMode"),
//                                               value: dropDownselectedmode,
//                                               icon: const Image(
//                                                 image: AssetImage(
//                                                     "images/deadline.png"),
//                                                 width: 40,
//                                               ),
//                                               items: speedModes.map<
//                                                       DropdownMenuItem<String>>(
//                                                   (String value) {
//                                                 return DropdownMenuItem<String>(
//                                                   value: value,
//                                                   child: Text(value),
//                                                 );
//                                               }).toList(),
//                                               onChanged: (String? value) async {
//                                                 if (value != null) {
//                                                   setState(() {
//                                                     dropDownselectedmode =
//                                                         value;
//                                                   });
//                                                   await onspeedmodechange(
//                                                       value, isRun);
//                                                 }
//                                               }),
//                                         ],
//                                       ),
//                                       const SizedBox(
//                                         height: 20,
//                                       ),
//                                       // const Center(
//                                       //   child: Text(
//                                       //     "Trip Details",
//                                       //     style: TextStyle(
//                                       //         color: Colors.transparent,
//                                       //         shadows: [
//                                       //           Shadow(
//                                       //               offset: Offset(0, -10),
//                                       //               color: Colors.black)
//                                       //         ],
//                                       //         decoration:
//                                       //             TextDecoration.underline,
//                                       //         decorationThickness: 3,
//                                       //         decorationColor: Colors.black,
//                                       //         fontWeight: FontWeight.bold,
//                                       //         fontSize: 20),
//                                       //   ),
//                                       // ),
//                                       Padding(
//                                         padding: const EdgeInsets.only(top: 10),
//                                         child: Column(
//                                           children: [
//                                             TripDetailsCard(
//                                                 context,
//                                                 "images/tripid.png",
//                                                 tripdetails["tripName"],
//                                                 tripdetails["uuid"].toString(),
//                                                 "Trip ID & Name"),
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
//                                                                 SizedBox(
//                                                                   height: 8,
//                                                                 ),
//                                                                 Text(
//                                                                     widget
//                                                                         .trackdata[
//                                                                             "plannedorunplanned"]
//                                                                         .toString()
//                                                                         .toUpperCase(),
//                                                                     textAlign:
//                                                                         TextAlign
//                                                                             .center),
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
//                                                                 SizedBox(
//                                                                   height: 8,
//                                                                 ),
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
//                                                                 SizedBox(
//                                                                   height: 5,
//                                                                 ),
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
//                                                                 Container(
//                                                                   width: 60,
//                                                                   child: Image(
//                                                                     image: AssetImage(
//                                                                         "images/stopsblack.png"),
//                                                                     width: 40,
//                                                                     height: 40,
//                                                                   ),
//                                                                 ),
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
//                                             TripDetailsCarddouble(
//                                                 context,
//                                                 "images/currentlocation.png",
//                                                 "Start base: " +
//                                                     tripdetails[
//                                                         "startlocation"],
//                                                 "End base: " +
//                                                     tripdetails["endlocation"]
//                                                         .toString(),
//                                                 "Base Start & Base End Location"),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             TripDetailsCarddouble(
//                                                 context,
//                                                 "images/currentlocation.png",
//                                                 "Start Actual: " +
//                                                     tripdetails[
//                                                         "startlocationActual"],
//                                                 "End Actual: " +
//                                                     tripdetails[
//                                                             "endlocationActual"]
//                                                         .toString(),
//                                                 "Start & End Location"),
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
//                                                     dateFormat1.format(enddate),
//                                                 "Start and End Time"),
//                                             // const SizedBox(
//                                             //   height: 10,
//                                             // ),
//                                             // Row(
//                                             //   mainAxisAlignment:
//                                             //   MainAxisAlignment.center,
//                                             //   children: [
//                                             //     Container(
//                                             //         width:
//                                             //         MediaQuery.of(context)
//                                             //             .size
//                                             //             .width *
//                                             //             0.9,
//                                             //         // height:
//                                             //         //     MediaQuery.of(context)
//                                             //         //             .size
//                                             //         //             .height *
//                                             //         //         0.18,
//                                             //         child: Card(
//                                             //           elevation: 2,
//                                             //           child: Row(
//                                             //               mainAxisAlignment:
//                                             //               MainAxisAlignment
//                                             //                   .spaceEvenly,
//                                             //               children: [
//                                             //                 Column(
//                                             //                   mainAxisAlignment:
//                                             //                   MainAxisAlignment
//                                             //                       .center,
//                                             //                   children: [
//                                             //                     Container(
//                                             //                       width: 60,
//                                             //                       child: Image(
//                                             //                         image: AssetImage(
//                                             //                             "images/currentlocation.png"),
//                                             //                         width: 40,
//                                             //                         height: 40,
//                                             //                       ),
//                                             //                     ),
//                                             //                     SizedBox(
//                                             //                       height: 8,
//                                             //                     ),
//                                             //                     SizedBox(
//                                             //                       width: 200,
//                                             //                       child: Text(
//                                             //                         "current: " +
//                                             //                             tripdetails[
//                                             //                             "currentlocation"],
//                                             //                         overflow:
//                                             //                         TextOverflow
//                                             //                             .clip,
//                                             //                       ),
//                                             //                     ),
//                                             //                   ],
//                                             //                 ),
//                                             //                 // SizedBox(width: 5,),
//                                             //                 Container(
//                                             //                   color: Colors
//                                             //                       .black45,
//                                             //                   height: 40,
//                                             //                   width: 2,
//                                             //                 ),
//                                             //                 // SizedBox(width: 5,),
//                                             //                 Column(
//                                             //                   mainAxisAlignment:
//                                             //                   MainAxisAlignment
//                                             //                       .center,
//                                             //                   children: [
//                                             //                     Container(
//                                             //                       width: 60,
//                                             //                       child: Image(
//                                             //                         image: AssetImage(
//                                             //                             "images/currentspeed.png"),
//                                             //                         width: 40,
//                                             //                         height: 40,
//                                             //                       ),
//                                             //                     ),
//                                             //                     SizedBox(
//                                             //                       height: 8,
//                                             //                     ),
//                                             //                     Text(
//                                             //                         "current: ${tripdetails["speed"]}"),
//                                             //                   ],
//                                             //                 ),
//                                             //               ]),
//                                             //         ))
//                                             //   ],
//                                             // ),
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
//                                                 tripdetails["last_reported_time"] !=
//                                                         "Not Available"
//                                                     ? lastreportedtime != null
//                                                         ? dateFormat1.format(
//                                                             lastreportedtime!)
//                                                         : "Not Available"
//                                                     : "Not Available",
//                                                 "Last Reported Time"),
//                                             const SizedBox(
//                                               height: 10,
//                                             ),
//                                             // TripDetailsCardSingle(
//                                             //     context,
//                                             //     "images/event.png",
//                                             //     tripdetails["eventName"]
//                                             //         .toString(),
//                                             //     "Events"),
//                                           ],
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                             );
//                           },
//                         ))
//                         // Expanded(
//                         //   child: Container(
//                         //     decoration: BoxDecoration(
//                         //       color: Colors.black.withOpacity(0.3),
//                         //       borderRadius: BorderRadius.only(
//                         //         topLeft: Radius.circular(20),
//                         //         topRight: Radius.circular(20),
//                         //       ),
//                         //     ),
//                         //     // color: Colors.black,
//                         //     child: Row(
//                         //       children: [
//                         //         ElevatedButton(
//                         //             onPressed: () {
//                         //               locationanimation();
//                         //             },
//                         //             child: Text("Button")),
//                         //         ElevatedButton(
//                         //             onPressed: () {
//                         //               resettoorigin();
//                         //             },
//                         //             child: Text("Replay")),
//                         //       ],
//                         //     ),
//                         //   ),
//                         // )
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
//                     mainAxisSize: MainAxisSize.min,
//                     mainAxisAlignment: MainAxisAlignment.center,
//                     children: [
//                       AutoSizeText(
//                         maxFontSize: 17.0,
//                         maxLines: 2,
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
//           // height: MediaQuery.of(context).size.height * 0.100,
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
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         SizedBox(
//                           height: 10,
//                         ),
//                         AutoSizeText(
//                           title1,
//                           overflow: TextOverflow.clip,
//                         ),
//                         // AutoSizeText(maxFontSize:20.0,maxLines: 2, title1,overflow: TextOverflow.clip,),
//                         SizedBox(
//                           height: 10,
//                         ),
//
//                         AutoSizeText(
//                           title2,
//                           overflow: TextOverflow.clip,
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         // AutoSizeText(maxFontSize:20.0,maxLines: 2, title2,overflow: TextOverflow.clip,),
//                       ],
//                     ),
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
//   Row TripDetailsCarddouble(BuildContext context, String imagePath,
//       String title1, String title2, String tooltipmessage) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.center,
//       children: [
//         Container(
//           width: MediaQuery.of(context).size.width * 0.9,
//           // height: MediaQuery.of(context).size.height * 0.100,
//           child: Card(
//             elevation: 2,
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.start,
//               children: [
//                 Tooltip(
//                   message: tooltipmessage,
//                   textAlign: TextAlign.left,
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
//                   child: Padding(
//                     padding: const EdgeInsets.all(10.0),
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       children: [
//                         SizedBox(
//                           height: 10,
//                         ),
//                         Text(
//                           title1,
//                           textAlign: TextAlign.left,
//                           // overflow: TextOverflow.clip,
//                         ),
//                         // AutoSizeText(maxFontSize:20.0,maxLines: 2, title1,overflow: TextOverflow.clip,),
//                         SizedBox(
//                           height: 10,
//                         ),
//
//                         Text(
//                           title2,
//                           textAlign: TextAlign.left,
//                           overflow: TextOverflow.clip,
//                         ),
//                         SizedBox(
//                           height: 10,
//                         ),
//                         // AutoSizeText(maxFontSize:20.0,maxLines: 2, title2,overflow: TextOverflow.clip,),
//                       ],
//                     ),
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
//
//   Future<void> onspeedmodechange(String value, bool isRunning) async {
//     // print(value);
//     switch (value) {
//       case "Faster Speed":
//         currentspeed = fasterspeed;
//         break;
//       case "Slower Speed":
//         currentspeed = slowerspeed;
//         break;
//       case "Too Slow":
//         currentspeed = tooslowerspeed;
//         break;
//       default:
//         currentspeed = normalspeed;
//         break;
//     }
//     if (isRunning == true) {
//       showSnackBar(context);
//     }
//     setState(() {});
//   }
//
//   void showSnackBar(BuildContext context) {
//     final snackBar = SnackBar(
//       content: const Text(
//           'Please reset and play the trip route again to see the change'),
//       backgroundColor: Colors.teal,
//       behavior: SnackBarBehavior.floating,
//       action: SnackBarAction(
//         label: 'Dismiss',
//         disabledTextColor: Colors.white,
//         textColor: Colors.yellow,
//         onPressed: () {
//           ScaffoldMessenger.of(context).hideCurrentSnackBar();
//         },
//       ),
//     );
//     ScaffoldMessenger.of(context).showSnackBar(snackBar);
//   }
// }

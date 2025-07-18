// import 'dart:io';
//
// import 'package:admin_app/screens/constants.dart';
// // import 'package:admin_app/screens/piechart.dart';
// import 'package:admin_app/screens/sidebar.dart';
// import 'package:admin_app/screens/themes.dart';
// import 'package:dio/dio.dart';
//
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart';
//
// class VehicletrackView extends StatefulWidget {
//   const VehicletrackView({super.key});
//
//   @override
//   State<VehicletrackView> createState() => _VehicletrackViewState();
// }
//
// class _VehicletrackViewState extends State<VehicletrackView> {
//   List<Map<dynamic, dynamic>> _data = [];
//
//   var dio = Dio();
//   Future<List<dynamic>> getVehicleCurrentLocation(int vehicleId) async {
//     print("vehicleid $vehicleId");
//     String? subLocality, subAdministrativeArea;
//     String? speed, licensePlateNumber;
//     try {
//       final response = await dio.get(
//           "http://13.233.175.113:11019/location/getVehicleCurrentLocation/$vehicleId");
//       if (response.statusCode == 200) {
//         if (response.data.length > 0) {
//           print(response.data['lattitude']);
//           if (response.data['lattitude'] != null &&
//               response.data['longitude'] != null) {
//             List<Placemark> placemarks = await placemarkFromCoordinates(
//                 response.data['lattitude'], response.data['longitude']);
//             print(placemarks.first.subAdministrativeArea);
//             subLocality = placemarks.first.subLocality == ""
//                 ? ""
//                 : placemarks.first.subLocality.toString();
//             subAdministrativeArea = placemarks.first.subAdministrativeArea == ""
//                 ? ""
//                 : placemarks.first.subAdministrativeArea.toString();
//           } else {
//             subLocality = "";
//             subAdministrativeArea = "";
//           }
//           if (response.data['speed'] != null) {
//             speed = response.data['speed'].toString();
//           } else {
//             speed = "";
//           }
//           if (response.data['licensePlate'] != null) {
//             licensePlateNumber = response.data['licensePlate'].toString();
//           } else {
//             licensePlateNumber = "";
//           }
//
//           if (subLocality == "" && subAdministrativeArea == "") {
//             return ["", speed, licensePlateNumber];
//           } else {
//             return [
//               subLocality + " " + subAdministrativeArea,
//               speed,
//               licensePlateNumber
//             ];
//           }
//         } else {
//           return ["", "", ""];
//         }
//       } else {
//         return ["", "", ""];
//       }
//     } catch (e) {
//       print("error getting vehicle current location $e");
//       return ["", "", ""];
//     }
//   }
//
//   Future<void> _getData() async {
//     final String user_id = "185873";
//
//     var startsubLocality, startsubAdministrativeArea;
//     var endsubLocality, endsubAdministrativeArea;
//     var currentvehlocation;
//     try {
//       final response = await dio
//           .get("http://13.233.175.113:11014/trips/list-trips/$user_id");
//       _data.clear();
//       for (var i = 0; i < response.data['list'].length; i++) {
//         if (response.data['list'][i]['totalDistance'] != null) {
//           print(response.data['list'][i]['totalDistance'].toStringAsFixed(2));
//         }
//
//         // if (response.data['list'][i]['baseStartLat'] != null &&
//         //     response.data['list'][i]['baseStartLong'] != null) {
//         //   List<Placemark> placemarks = await placemarkFromCoordinates(
//         //       response.data['list'][i]['baseStartLat'],
//         //       response.data['list'][i]['baseStartLong']);
//         //   startsubLocality = placemarks.first.subLocality ?? "";
//         //   startsubAdministrativeArea =
//         //       placemarks.first.subAdministrativeArea ?? "";
//         // }
//         // if (response.data['list'][i]['baseEndLat'] != null &&
//         //     response.data['list'][i]['baseEndLong'] != null) {
//         //   List<Placemark> placemarks = await placemarkFromCoordinates(
//         //       response.data['list'][i]['baseStartLat'],
//         //       response.data['list'][i]['baseStartLong']);
//         //   endsubLocality = placemarks.first.subLocality ?? "";
//         //   endsubAdministrativeArea =
//         //       placemarks.first.subAdministrativeArea ?? "";
//         // }
//         // currentvehlocation = "";
//         // if (response.data['list'][i]['vehicleId'] != null) {
//         //   currentvehlocation = await getVehicleCurrentLocation(
//         //       response.data['list'][i]['vehicleId']);
//         // }
//
//         var fullname;
//         response.data['list'][i]['driverFirstName'] == null
//             ? fullname = ""
//             : fullname = response.data['list'][i]['driverFirstName'];
//         response.data['list'][i]['driverMiddleName'] == null
//             ? fullname = fullname + ""
//             : fullname =
//                 fullname + " " + response.data['list'][i]['driverMiddleName'];
//         response.data['list'][i]['driverLastName'] == null
//             ? fullname = fullname + ""
//             : fullname =
//                 fullname + " " + response.data['list'][i]['driverLastName'];
//
//         _data.add({
//           "tripid": response.data['list'][i]['tripId'],
//           "tripName": response.data['list'][i]['tripName'] == null
//               ? ""
//               : response.data['list'][i]['tripName'],
//           "vehicleName": response.data['list'][i]['vehicleName'] == null
//               ? ""
//               : response.data['list'][i]['vehicleName'],
//           "driverName": fullname,
//           "plannedorunplanned":
//               response.data['list'][i]['status'].toString().toLowerCase() !=
//                       "unplanned"
//                   ? "unplanned"
//                   : "planned",
//           "tripStatus": response.data['list'][i]['status'] == null
//               ? ""
//               : response.data['list'][i]['status'],
//           "tripType": response.data['list'][i]['category'] == null
//               ? ""
//               : response.data['list'][i]['category'],
//           // "startlocation": '${startsubLocality} ${startsubAdministrativeArea}',
//           "TotalDistance": response.data['list'][i]['totalDistance'] == null
//               ? 0
//               : response.data['list'][i]['totalDistance'].toStringAsFixed(2),
//           // "Currentlocation": currentvehlocation.isEmpty
//           //     ? ""
//           //     : currentvehlocation[0] == ""
//           //         ? ""
//           //         : currentvehlocation[0],
//           // "speed": currentvehlocation.isEmpty
//           //     ? ""
//           //     : currentvehlocation[1] == ""
//           //         ? ""
//           //         : currentvehlocation[1],
//           // "licensePlate": currentvehlocation.isEmpty
//           //     ? ""
//           //     : currentvehlocation[2] == ""
//           //         ? ""
//           //         : currentvehlocation[2]
//         });
//       }
//
//       print(_data);
//       setState(() {
//         _data = _data;
//       });
//     } catch (e) {
//       print("error from getdata: $e");
//     }
//   }
//
//   // Future<void> gettrackavailableid(String user_id, String trip_id) async {
//   //   var data = {
//   //     "id": user_id,
//   //     "fromTime": "2022-11-07 00:00:00",
//   //     "toTime": "2022-11-07 23:59:00",
//   //     "tripId": trip_id
//   //   };
//   //   try {
//   //     final Response result =
//   //         await dio.post("$baseurl/tracking/getTrack", data: data);
//   //     print(result.data["list"]);
//   //     if (result.statusCode == 200 ||
//   //         result.statusCode == 201 ||
//   //         result.data["success"] == true) {
//   //       final listResult = result.data["list"];
//   //     }
//   //   } catch (e) {
//   //     print("error from gettrackavailableid $e");
//   //   }
//   // }
//
//   // getAddressFromLatLng(context, double lat, double lng) async {
//   //   String _host = 'https://maps.google.com/maps/api/geocode/json';
//   //   final url = '$_host?key=$google_api_key&language=en&latlng=$lat,$lng';
//   //   if (lat != null && lng != null) {
//   //     var response = await dio.get(url);
//   //     print(response);
//   //     if (response.statusCode == 200) {
//   //       Map data = response.data;
//   //       String _formattedAddress = data["results"][0]["formatted_address"];
//   //       print("response ==== $_formattedAddress");
//   //       return _formattedAddress;
//   //     } else
//   //       return null;
//   //   } else
//   //     return null;
//   // }
//
//   @override
//   void initState() {
//     () async {
//       await _getData();
//     }();
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return _data.isEmpty
//         ? const Center(child: CircularProgressIndicator())
//         : Padding(
//             padding: const EdgeInsets.only(top: 30, left: 8.0, right: 8.0),
//             child: SizedBox(
//                 // height: 600,
//                 child: ListView.separated(
//                     itemBuilder: ((context, index) {
//                       return Card(
//                         color: Colors.white,
//                         shape: const RoundedRectangleBorder(
//                             borderRadius:
//                                 BorderRadius.all(Radius.circular(15.0))),
//                         child: Padding(
//                             padding: const EdgeInsets.all(0.0),
//                             child: ExpansionTile(
//                               childrenPadding:
//                                   const EdgeInsets.fromLTRB(0, 0, 30, 0),
//                               trailing: const SizedBox(),
//                               title: Column(children: [
//                                 Text(
//                                   _data[index]["tripName"],
//                                   style: TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       fontSize: 20),
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 const Divider(
//                                   thickness: 2,
//                                   height: 5,
//                                   color: Colors.black,
//                                 ),
//                                 const SizedBox(
//                                   height: 20,
//                                 ),
//                                 _vehdesc(
//                                     title: "Trip Id",
//                                     description:
//                                         _data[index]["tripid"].toString()),
//                                 const Divider(),
//                                 _vehdesc(
//                                     title: "Vehicle Name",
//                                     description: _data[index]["vehicleName"]),
//                                 const Divider(),
//                                 _vehdesc(
//                                     title: "Vehicle License Number:",
//                                     description: "KL 02 CC 2222"),
//                                 const Divider(),
//                                 _vehdesc(
//                                     title: "Vehicle Modal:",
//                                     description: "Suv"),
//                                 const Divider(),
//                                 _vehdesc(
//                                     title: "Driver Name:",
//                                     description: _data[index]["driverName"]),
//                                 const Divider(),
//                               ]),
//                               children: [
//                                 Padding(
//                                   padding: const EdgeInsets.all(8.0),
//                                   child: Column(
//                                     children: [
//                                       _vehdesc(
//                                           title: "Current Location:",
//                                           description: "Chennai"),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "Last Reported Time:",
//                                           description: "12:21:22 PM"),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "Start Location:",
//                                           description: "Trivandrum"),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "End Location:",
//                                           description: "Chennai"),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "Start Date and Time:",
//                                           description: "2022-12-12 00:00:00"),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "End Date and Time:",
//                                           description: "2022-12-15 00:00:00"),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "Total Distance:",
//                                           description: _data[index]
//                                                   ["TotalDistance"]
//                                               .toString()),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "Speed",
//                                           description: "120 KM/H"),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "Trip Status",
//                                           description: _data[index]
//                                               ["plannedorunplanned"],
//                                           haveBadge: true),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "",
//                                           description: _data[index]
//                                               ["tripStatus"],
//                                           haveBadge: true),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "Trip Type",
//                                           description: _data[index]
//                                               ["tripType"]),
//                                       const Divider(),
//                                       _vehdesc(
//                                           title: "No of Stops",
//                                           description: "1"),
//                                       const Divider(),
//                                       Container(
//                                         width: 150,
//                                         decoration: BoxDecoration(
//                                             color: Colors.amberAccent,
//                                             borderRadius:
//                                                 BorderRadius.circular(10)),
//                                         child: Column(
//                                           children: [
//                                             IconButton(
//                                                 onPressed: () {},
//                                                 icon: const Icon(
//                                                     Icons.navigation_rounded)),
//                                             const Text("Track History"),
//                                             const SizedBox(
//                                               height: 5,
//                                             )
//                                           ],
//                                         ),
//                                       )
//                                     ],
//                                   ),
//                                 )
//                               ],
//                             )),
//                       );
//                     }),
//                     separatorBuilder: (context, index) {
//                       return SizedBox(
//                         height: 40,
//                       );
//                     },
//                     itemCount: 10)),
//           );
//   }
//
//   _vehdesc({
//     required String title,
//     required String description,
//     bool haveBadge = false,
//   }) {
//     Color color = greenColor;
//
//     if (haveBadge == true) {
//       if (description.replaceAll(" ", '').toLowerCase() == "unplanned") {
//         color = Colors.lightBlue;
//       } else if (description.replaceAll(" ", '').toLowerCase() ==
//           "inprogress") {
//         color = Colors.grey;
//       } else if (description.replaceAll(" ", '').toLowerCase() == "cancelled") {
//         color = Colors.red;
//       } else if (description.replaceAll(" ", '').toLowerCase() ==
//           "notstarted") {
//         color = Colors.black26;
//       } else {
//         color = greenColor;
//       }
//     }
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(
//           title,
//         ),
//         haveBadge == true
//             ? Container(
//                 decoration: BoxDecoration(
//                     color: color, borderRadius: BorderRadius.circular(6)),
//                 margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
//                 padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
//                 child: Text(
//                   description,
//                   style: vehiclePageCardTextNormalWhiteStyle,
//                 ),
//               )
//             : Text(description)
//       ],
//     );
//   }
// }

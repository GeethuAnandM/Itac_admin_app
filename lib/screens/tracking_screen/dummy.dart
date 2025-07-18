// import 'dart:async';
// import 'dart:io';
// import 'dart:ui';
// import 'package:admin_app/api/api.dart';
// import 'package:admin_app/screens/tracking_screen/location_tab_variables.dart';
// import 'package:admin_app/screens/tracking_screen/track_trip_screen.dart';
// import 'package:dio/dio.dart';
// import 'package:flutter/cupertino.dart';
// import 'package:flutter/material.dart';
// import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/services.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import 'package:lottie/lottie.dart' as lottie;
// import '../../languges/language_constants.dart';
// import '../sidebar.dart';
// import 'singleVehLocation.dart';
//
// // var dateFormat = DateFormat("dd-MM-yyyy");
// var errormessage;
// var sList;
// var latlng = [];
// LatLng camPosition = LatLng(0, 0);
// List<Map<String, dynamic>> clusterData = [];
// var currentaddressdata;
// var dio = Dio();
// var listOfVehicles = [];
// var vehicleList = [];
// var loader = true;
// var listOfDeviceLocation = [];
// List<Place> items = [];
// String _searchResult = '';
// var searchController = TextEditingController();
// Future getCurrentLocation() async {
//   // GoogleMapController googleMapController2 = await _controller.future;
//   try {
//     // print("Device Id: " + id.toString());
//     var id = deviceID;
//     var locationUrl = "$baseUrl:11019/location/getVehicleCurrentLocation/${id}";
//     final response = await dio.get(locationUrl);
//     var vehData = response.data;
//     print("vehicleData: ${vehData}");
//     final address = await getLiveCurrentLocation(
//         vehData["lattitude"], vehData["longitude"]);
//     if (address == false) {}
//   } on SocketException {
//     errormessage = 'No Internet connection';
//     // isError = true;
//     // nodata = false;
//   }
// }
//
// Future<bool> getLiveCurrentLocation(double Latitude, double Longitude) async {
//   final apilink =
//       "http://13.234.100.167/nominatim/reverse?format=json&lat=${Latitude}&lon=${Longitude}&zoom=18&addressdetails=1";
//
//   try {
//     final response = await Dio().get(apilink);
//     if (response.statusCode == 200) {
//       currentaddressdata = response.data['display_name'].toString();
//       return true;
//     } else {
//       return false;
//     }
//   } catch (err) {
//     print(err);
//     return false;
//     currentaddressdata = "Unknown Location";
//   }
// }
//
// // void main() => runApp(VehicleLocationMap());
//
// // Clustering maps
// class VehicleLocationMap extends StatefulWidget {
//   const VehicleLocationMap({super.key});
//
//   @override
//   State<VehicleLocationMap> createState() => VehicleLocationMapState();
// }
//
// class VehicleLocationMapState extends State<VehicleLocationMap> {
//   // Completer<GoogleMapController> _controller = Completer();
//   final GlobalKey<ScaffoldState> _key = GlobalKey();
//   //
//   // sortVehicleList(vList) {
//   //   vList.sort((b, a) => (a["packetTime"]).compareTo(b["packetTime"]));
//   //   return vList;
//   // }
//
//   Stream getStream(Duration refreshTime) async* {
//     while (true) {
//       await Future.delayed(refreshTime);
//       yield await getAllvehiclesLocation();
//       // await getAllvehiclesLocation();
//     }
//   }
//
//   Future<List<dynamic>> getAllvehiclesLocation() async {
//     var dev_Ids = await getAllDeviceIds();
//     for (var i in dev_Ids) {
//       print("Device_id: " + i.toString());
//     }
//     vehicleList = [];
//     var deviceIDs = {"deviceIds": dev_Ids};
//     final url = "$baseUrl:11019/location/getDeviceCurrentLocation";
//     var response = await dio.post(url, data: deviceIDs);
//     if (response != null) {
//       // vehicleList = response.data;
//       listOfDeviceLocation = response.data;
//       sList = response.data;
//       var vList = [];
//       for (var i in sList) {
//         print(i['packetTime']);
//         if (i['packetTime'] != null) {
//           vList.add(i);
//         }
//       }
//       for (var i in vList) {
//         print("vlist packet : ${i['packetTime']}");
//       }
//       print("sList unsorted ${sList}"); // for data display
//       vList.sort((b, a) => (a["packetTime"]).compareTo(b["packetTime"]));
//       print("vList sorted ${vList}");
//       print(vehicleList.runtimeType);
//       vehicleList = vList;
//       print("VehicleList length: ${vehicleList.length}");
//       print("VehicleList: ${vehicleList}");
//       //for vehicle list to have all records
//       for (var i in sList) {
//         if (i['packetTime'] == null) {
//           print("null packettime: ${i['packetTime']}");
//           vehicleList.add(i);
//         }
//       }
//     }
//     print("VehicleList length: ${vehicleList.length}");
//     for (var i in vehicleList) {
//       print("pkttime from vehlist: ${i['packetTime']}");
//     }
//     var allCoordinates = getLocCoordinateList(vehicleList);
//     return allCoordinates;
//   }
//
//   Future<List<dynamic>> getAllDeviceIds() async {
//     ByteData byteDatacurrent = await DefaultAssetBundle.of(context)
//         .load("images/navigation-marker.png");
//     urlList2 = byteDatacurrent.buffer.asUint8List();
//     final prefs = await SharedPreferences.getInstance();
//     var userId = prefs.getString("user_id");
//     // var userId = 185939;
//     final url = "$baseUrl:11018/api/list-vehicles/$userId";
//     final response = await dio.get(url);
//     var allVehicles = response.data;
//     listOfVehicles = response.data; //for data display
//     var allDeviceIds = [];
//     for (var i in allVehicles) {
//       if (i['deviceId'] != null && i['deviceId'] != "") {
//         allDeviceIds.add(i['deviceId']);
//       } else {
//         // print("null devices ids: ${i}");
//       }
//     }
//     print('length of total vehicle list: ${allVehicles.length}');
//     print("All Vehicles: ${allVehicles}");
//     print("All Vehicles Type: ${allVehicles.runtimeType} ");
//     return allDeviceIds;
//   }
//
//   List<dynamic> getLocCoordinateList(vehicleList) {
//     var validCoordinates = 0;
//     clusterData = [];
//     print("function getting coordinates: vehiclelist length: ${vehicleList}");
//     for (var i in vehicleList) {
//       if (i["latitude"] != null) {
//         if (i["longitude"] != null) {
//           var data = {"lat": i["latitude"], "lng": i["longitude"]};
//           latlng.add(data);
//           clusterData.add(i);
//           validCoordinates++;
//         }
//       } else {
//         print(
//             "null lat lng from veh list, pkt time val is: ${i["packetTime"]}");
//       }
//     }
//     print("clusterData.runtimeType: ${clusterData.runtimeType}");
//     print("clusterData: ${clusterData}");
//
//     print("First coordinate: ${latlng[0].toString()}");
//     print("Cluster data: ${clusterData}");
//     print("Co-ordinates received : ${validCoordinates}");
//     // getTrips();
//     return clusterData;
//   }
//
//   Widget _icon(IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: const BoxDecoration(
//         borderRadius: BorderRadius.all(Radius.circular(13)),
//         // color: commonTextStyle,
//       ),
//       child: InkWell(
//         onTap: () {
//           _key.currentState?.openDrawer();
//         },
//         child: Icon(
//           icon,
//           size: 30,
//         ),
//       ),
//     );
//   }
//
//   Widget _appBar() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: <Widget>[
//         RotatedBox(
//           quarterTurns: 4,
//           child: _icon(
//             Icons.menu,
//             // color: blueColor,
//           ),
//         ),
//       ],
//     );
//   }
//
//   var vehicleFiltered = [];
//   void _searchFun(String enteredKeyword) {
//     var results = [];
//
//     if (enteredKeyword.isEmpty) {
//       // if the search field is empty or only contains white-space, we'll display all data
//       results = vehicleList.cast<Map<String, dynamic>>();
//       ;
//     } else {
//       results = vehicleFiltered
//           .where((person) =>
//       person["driverName"]
//           .toString()
//           .toLowerCase()
//           .replaceAll(" ", "")
//           .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
//           person["vehicleName"]
//               .toString()
//               .toLowerCase()
//               .replaceAll(" ", "")
//               .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
//           person["packetTime"]
//               .toString()
//               .toLowerCase()
//               .replaceAll(" ", "")
//               .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
//           person["licensePlate"]
//               .toString()
//               .toLowerCase()
//               .replaceAll(" ", "")
//               .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
//           person["deviceName"]
//               .toString()
//               .toLowerCase()
//               .replaceAll(" ", "")
//               .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
//           person["speed"]
//               .toString()
//               .toLowerCase()
//               .replaceAll(" ", "")
//               .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")))
//           .cast<Map<String, dynamic>>()
//           .toList();
//       if (results.isEmpty) {
//         setState(() {
//           loader = true;
//         });
//       } else {
//         setState(() {
//           loader = false;
//         });
//       }
//     }
//     // Refresh the UI
//     setState(() {
//       vehicleList = results;
//     });
//   }
//
//   @override
//   void initState() {
//     setState(() {
//       vehicleFiltered = vehicleList;
//     });
//     super.initState();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         key: _key,
//         drawer: const NavBar(),
//         appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(60.0),
//             child: AppBar(
//               centerTitle: true,
//               leading: Padding(
//                   padding: const EdgeInsets.only(top: 15),
//                   child: BackButton(
//                     color: Colors.white,
//                     onPressed: () {
//                       Navigator.pop(context);
//                     },
//                   )),
//               title: Padding(
//                   padding: EdgeInsets.only(top: 20, left: 0),
//                   child: Text(translation(context).location)),
//               elevation: 0,
//             )),
//         resizeToAvoidBottomInset: true,
//         body: StreamBuilder(
//             stream: getStream(const Duration(seconds: 15)),
//             builder: (context, snapshot) {
//               print("Snapshot: ${clusterData}");
//               if (clusterData.isEmpty) {
//                 return const Center(child: CircularProgressIndicator());
//               }
//               return Container(
//                 child: Stack(
//                   children: [
//                     Positioned.fill(
//                         bottom: MediaQuery.of(context).size.height * 0.10,
//                         child: CreateClusterMap(clusterData)),
//                     Positioned.fill(
//                         child: DraggableScrollableSheet(
//                           maxChildSize: 0.99,
//                           minChildSize: 0.2,
//                           initialChildSize: 0.4,
//                           builder: (_, scrollController) {
//                             return Material(
//                               elevation: 0,
//                               borderRadius: const BorderRadius.vertical(
//                                   top: Radius.circular(20)),
//                               child: SingleChildScrollView(
//                                   controller: scrollController,
//                                   child: Column(children: [
//                                     Container(
//                                       child: TextField(
//                                         controller: searchController,
//                                         decoration: InputDecoration(
//                                             prefixIcon: Icon(Icons.search),
//                                             suffixIcon: GestureDetector(
//                                                 onTap: () {
//                                                   searchController.clear();
//                                                   setState(() {
//                                                     _searchResult = '';
//                                                     vehicleList = vehicleFiltered;
//                                                   });
//                                                 },
//                                                 child: Icon(Icons.cancel)),
//                                             hintText: 'Search',
//                                             border: InputBorder.none),
//                                         onChanged: (value) async =>
//                                             _searchFun(value),
//                                       ),
//                                       height: 40,
//                                       width: 360,
//                                     ),
//                                     SizedBox(
//                                         height: 500.0,
//                                         child: ListView.builder(
//                                             itemCount: vehicleList.length,
//                                             itemBuilder: (context, index) {
//                                               var lastReportedDateTime =
//                                               dateFormatter(vehicleList[index]
//                                               ["packetTime"]);
//                                               print(
//                                                   "last reported: ${lastReportedDateTime}");
//                                               return Container(
//                                                 decoration: BoxDecoration(
//                                                     border: Border.all(
//                                                         color:
//                                                         Colors.blue.shade100)),
//                                                 child: ExpansionTile(
//                                                   backgroundColor: Colors.white,
//                                                   collapsedBackgroundColor:
//                                                   Colors.white,
//                                                   collapsedTextColor: Colors.black,
//                                                   textColor: Colors.black,
//                                                   title: Column(
//                                                     children: [
//                                                       Row(
//                                                         children: [
//                                                           Container(
//                                                             width: 160.0,
//                                                             child: Text(
//                                                               vehicleList[index][
//                                                               "vehicleName"] ??
//                                                                   "-",
//                                                               style: TextStyle(
//                                                                 fontSize: 12.0,
//                                                                 fontWeight:
//                                                                 FontWeight.bold,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                           SizedBox(width: 10),
//                                                           Text(
//                                                               "Driver: " +
//                                                                   (vehicleList[
//                                                                   index]
//                                                                   [
//                                                                   "driverName"] ??
//                                                                       "-"),
//                                                               style: TextStyle(
//                                                                 fontSize: 12.0,
//                                                                 fontWeight:
//                                                                 FontWeight.bold,
//                                                               )),
//                                                         ],
//                                                       ),
//                                                       SizedBox(
//                                                         height: 5.0,
//                                                       ),
//                                                       Row(
//                                                         children: [
//                                                           Container(
//                                                             width: 250.00,
//                                                             child: Text(
//                                                               "Last Reported: " +
//                                                                   lastReportedDateTime
//                                                                       .toString() ??
//                                                                   "-",
//                                                               style: TextStyle(
//                                                                 fontSize: 12.0,
//                                                                 fontWeight:
//                                                                 FontWeight.bold,
//                                                               ),
//                                                             ),
//                                                           ),
//                                                         ],
//                                                       ),
//                                                       SizedBox(
//                                                         height: 10,
//                                                       ),
//                                                     ],
//                                                   ),
//                                                   subtitle: Text(
//                                                     "Speed: " +
//                                                         vehicleList[index]
//                                                         ["speed"]
//                                                             .toString() ??
//                                                         "-",
//                                                     style: TextStyle(
//                                                       fontSize: 12.0,
//                                                       fontWeight: FontWeight.bold,
//                                                     ),
//                                                   ),
//                                                   children: <Widget>[
//                                                     Column(
//                                                       children:
//                                                       _buildExpandableContent(
//                                                           vehicleList[index],
//                                                           context),
//                                                     ),
//                                                   ],
//                                                 ),
//                                               );
//                                             }))
//                                   ])),
//                             );
//                           },
//                         )),
//                   ],
//                 ),
//               );
//             }));
//   }
// }
//
// // Clustering maps
// class CreateClusterMap extends StatefulWidget {
//   CreateClusterMap(this.vehicles);
//   List<dynamic> vehicles;
//
//   @override
//   State<CreateClusterMap> createState() => CreateClusterMapState();
// }
//
// class CreateClusterMapState extends State<CreateClusterMap> {
//   late dynamic _manager;
//   Completer<GoogleMapController> _controller = Completer();
//   Set<Marker> markers = Set();
//
//   createPlaces() {
//     camPosition = LatLng(11.342423, 77.728165);
//     print("Initial cam position : ${camPosition.toString()}");
//     items = [
//       for (var i in widget.vehicles)
//         Place(
//             name: i["vehicleName"],
//             latLng: LatLng(i["latitude"], i["longitude"])),
//     ];
//     // for (var i in items) {
//     //   print("Items: ${i.name}");
//     // }
//   }
//
//   @override
//   void initState() {
//     createPlaces();
//     print("length of items: ${items.length}");
//
//     _manager = _initClusterManager();
//     super.initState();
//   }
//
//   ClusterManager<Place> _initClusterManager() {
//     return ClusterManager<Place>(items, _updateMarkers,
//         markerBuilder: _markerBuilder);
//   }
//
//   void _updateMarkers(Set<Marker> markers) {
//     print('Updated ${markers.length} markers');
//     setState(() {
//       this.markers = markers;
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: GoogleMap(
//           mapType: MapType.normal,
//           rotateGesturesEnabled: true,
//           // myLocationEnabled: true,
//           tiltGesturesEnabled: true,
//           compassEnabled: true,
//           scrollGesturesEnabled: true,
//           zoomGesturesEnabled: true,
//           initialCameraPosition: CameraPosition(
//             target: camPosition,
//             zoom: 6.5,
//           ),
//           markers: markers,
//           onMapCreated: (GoogleMapController controller) {
//             _controller.complete(controller);
//             _manager.setMapId(controller.mapId);
//           },
//           onCameraMove: _manager.onCameraMove,
//           onCameraIdle: _manager.updateMap),
//     );
//   }
//
//   Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
//           (cluster) async {
//         return Marker(
//           markerId: MarkerId(cluster.getId()),
//           infoWindow: InfoWindow(title: "${cluster.items.first.name}"),
//           position: cluster.location,
//           onTap: () {
//             print('---- $cluster');
//             cluster.items.forEach((p) => print(p.name));
//           },
//           icon: cluster.isMultiple
//               ? await _getMarkerBitmap(cluster.isMultiple ? 125 : 80,
//               text: cluster.isMultiple ? cluster.count.toString() : null)
//               : await BitmapDescriptor.fromBytes(urlList2),
//         );
//       };
//
//   Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
//     if (kIsWeb) size = (size / 2).floor();
//
//     final PictureRecorder pictureRecorder = PictureRecorder();
//     final Canvas canvas = Canvas(pictureRecorder);
//     final Paint paint1 = Paint()..color = Colors.orange;
//     final Paint paint2 = Paint()..color = Colors.white;
//
//     canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
//     canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint2);
//     canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
//
//     if (text != null) {
//       TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
//       painter.text = TextSpan(
//         text: text,
//         style: TextStyle(
//             fontSize: size / 3,
//             color: Colors.white,
//             fontWeight: FontWeight.normal),
//       );
//       painter.layout();
//       painter.paint(
//         canvas,
//         Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
//       );
//     }
//
//     final img = await pictureRecorder.endRecording().toImage(size, size);
//     final data = await img.toByteData(format: ImageByteFormat.png) as ByteData;
//     return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
//   }
// }
//
// class Place with ClusterItem {
//   Place({required this.name, required this.latLng});
//   final String name;
//   final LatLng latLng;
//   @override
//   LatLng get location => latLng;
// }
//
// class LocationDataScreen extends StatelessWidget {
//   const LocationDataScreen({Key? key}) : super(key: key);
//
//   @override
//   Widget build(BuildContext context) {
//     return Container();
//   }
// }
//
// _buildExpandableContent(vehicle, BuildContext context) {
//   List<Widget> columnContent = [];
//   columnContent.add(
//     Column(
//       children: <Widget>[
//         Container(
//           decoration: BoxDecoration(
//               color: Colors.grey.shade100,
//               border: Border.all(
//                 width: 2.0,
//                 color: Colors.blue.shade100,
//               )),
//           child: Column(
//             children: [
//               SizedBox(width: 5),
//               Row(
//                 children: [
//                   Text(
//                     "Trip Name: " + vehicle["tripName"],
//                     style: TextStyle(
//                       fontSize: 12.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 5),
//               Row(
//                 children: [
//                   SizedBox(
//                     width: 5,
//                   ),
//                   // Text(
//                   //   "Event: " + vehicle["eventName"],
//                   //   style: TextStyle(
//                   //     fontSize: 13.0,
//                   //     fontWeight: FontWeight.bold,
//                   //   ),
//                   // ),
//                   SizedBox(width: 120.00),
//                   Text(
//                     " ",
//                     style: TextStyle(
//                       fontSize: 13.0,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   TextButton(
//                     style: ButtonStyle(
//                       backgroundColor:
//                       MaterialStateProperty.all(Colors.blue.shade100),
//                     ),
//                     onPressed: () {
//                       // singleOrCluster = "single";
//                       deviceID = vehicle["id"];
//                       getCurrentLocation();
//                       vehicleName = vehicle["vehicleName"];
//                       var data = {
//                         "lat": vehicle["latitude"],
//                         "lng": vehicle["longitude"]
//                       };
//                       SelectedVehCoords = data;
//                       print("SelectedVehicleCoordinates" +
//                           SelectedVehCoords.toString());
//                       Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                             builder: (context) => CurrentLocationMap()),
//                       );
//                     },
//                     child: Text(
//                       "Show Location",
//                       style: TextStyle(color: Colors.black),
//                     ),
//                   ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ],
//     ),
//   );
//   return columnContent;
// }

import 'dart:async';
import 'dart:developer';
import 'dart:io';
import 'dart:ui';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/tracking_screen/location_tab_variables.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'
    hide Cluster, ClusterManager;
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
//import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart' as lottie;
import '../../languges/language_constants.dart';
import '../sidebar.dart';
import 'singleVehLocation.dart';
import 'package:intl/src/intl/date_format.dart';

var pickedTime = null;
var pickedDate = null;
String? formatteddateandtime;
int difference = 0;
// var dateFormat = DateFormat("dd-MM-yyyy");
var errormessage;
var sList;
var latlng = [];
LatLng camPosition = LatLng(0, 0);
List<Map<String, dynamic>> clusterData = [];
var currentaddressdata;
var dio = Dio();
var listOfVehicles = [];
var vehicleList = [];
var loader = true;
var listOfDeviceLocation = [];
List<Place> items = [];
String _searchResult = '';
double currentZoom = 6.5;

var searchController = TextEditingController();
String snackBarMessage = "Sharing failed - check connection or data";
Future getCurrentLocation() async {
  // GoogleMapController googleMapController2 = await _controller.future;
  try {
    // print("Device Id: " + id.toString());
    var id = deviceID;
    var locationUrl = "${baseUrl}location/getVehicleCurrentLocation/${id}";
    final response = await dio.get(locationUrl);
    var vehData = response.data;
    print("vehicleData: ${vehData}");
    final address = await getLiveCurrentLocation(
        vehData["lattitude"], vehData["longitude"]);
    if (address == false) {}
  } on SocketException {
    errormessage = 'No Internet connection';
    // isError = true;
    // nodata = false;
  }
}

Future<bool> getLiveCurrentLocation(double Latitude, double Longitude) async {
  final apilink =
      "http://13.234.100.167/nominatim/reverse?format=json&lat=${Latitude}&lon=${Longitude}&zoom=18&addressdetails=1";

  try {
    final response = await Dio().get(apilink);
    if (response.statusCode == 200) {
      currentaddressdata = response.data['display_name'].toString();
      return true;
    } else {
      return false;
    }
  } catch (err) {
    print(err);
    return false;
    currentaddressdata = "Unknown Location";
  }
}

// void main() => runApp(VehicleLocationMap());

// Clustering maps
class VehicleLocationMap extends StatefulWidget {
  const VehicleLocationMap({super.key, this.showScaffold = true});

  final bool showScaffold;

  @override
  State<VehicleLocationMap> createState() => VehicleLocationMapState();
}

class VehicleLocationMapState extends State<VehicleLocationMap> {
  // Completer<GoogleMapController> _controller = Completer();
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  //
  // sortVehicleList(vList) {
  //   vList.sort((b, a) => (a["packetTime"]).compareTo(b["packetTime"]));
  //   return vList;
  // }

  Future<List<dynamic>> getAllvehiclesLocation() async {
    var dev_Ids = await getAllDeviceIds();
    for (var i in dev_Ids) {
      print("Device_id: " + i.toString());
    }
    vehicleList = [];
    var deviceIDs = {"deviceIds": dev_Ids};
    final url = "${baseUrl}location/getDeviceCurrentLocation";
    var response = await dio.post(url, data: deviceIDs);
    if (response != null) {
      // vehicleList = response.data;
      listOfDeviceLocation = response.data;
      sList = response.data;
      var vList = [];
      for (var i in sList) {
        print(i['packetTime']);
        if (i['packetTime'] != null) {
          vList.add(i);
        }
      }
      for (var i in vList) {
        print("vlist packet : ${i['packetTime']}");
      }
      print("sList unsorted ${sList}"); // for data display
      vList.sort(
          (b, a) => (a["packetTime"] ?? "").compareTo(b["packetTime"] ?? ""));
      print("vList sorted ${vList}");
      print(vehicleList.runtimeType);
      vehicleList = vList;
      print(
          "VehicleList length in getAllvehiclesLocation1: ${vehicleList.length}");
      print("VehicleList: ${vehicleList}");
      //for vehicle list to have all records
      for (var i in sList) {
        if (i['packetTime'] == null) {
          print("null packettime: ${i['packetTime']}");
          vehicleList.add(i);
        }
      }
    }
    print(
        "VehicleList length in getAllvehiclesLocation2: ${vehicleList.length}");
    for (var i in vehicleList) {
      print("pkttime from vehlist: ${i['packetTime']}");
    }
    var allCoordinates = getLocCoordinateList(vehicleList);
    return allCoordinates;
  }

  Future<List<dynamic>> getAllDeviceIds() async {
    ByteData byteDatacurrent = await DefaultAssetBundle.of(context)
        .load("images/navigation-marker.png");
    urlList2 = byteDatacurrent.buffer.asUint8List();
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    // var userId = 185939;
    // final url = "${baseUrl}api/list-vehicles/$userId";
    final url = "${baseUrl}vehicle/vehicles/$userId";
    final response = await dio.get(url);
    var allVehicles = response.data;
    listOfVehicles = response.data; //for data display
    var allDeviceIds = [];
    for (var i in allVehicles) {
      if (i['deviceId'] != null && i['deviceId'] != "") {
        allDeviceIds.add(i['deviceId']);
      } else {
        // print("null devices ids: ${i}");
      }
    }
    print('length of total vehicle list: ${allVehicles.length}');
    print("All Vehicles: ${allVehicles}");
    print("All Vehicles Type: ${allVehicles.runtimeType} ");
    return allDeviceIds;
  }

  List<dynamic> getLocCoordinateList(vehicleList) {
    var validCoordinates = 0;
    clusterData = [];
    latlng.clear();
    clusterData.clear();
    print("function getting coordinates: vehiclelist length: ${vehicleList}");
    for (var i in vehicleList) {
      if (i["latitude"] != null) {
        if (i["longitude"] != null) {
          var data = {"lat": i["latitude"], "lng": i["longitude"]};
          latlng.add(data);
          clusterData.add(i);
          validCoordinates++;
        }
      } else {
        print(
            "null lat lng from veh list, pkt time val is: ${i["packetTime"]}");
      }
    }
    // print("clusterData.runtimeType: ${clusterData.runtimeType}");
    // print("clusterData: ${clusterData}");
    // print("First coordinate: ${latlng[0].toString()}");
    // print("Cluster data: ${clusterData}");
    // print("Co-ordinates received : ${validCoordinates}");
    // getTrips();
    return clusterData;
  }

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(13)),
        // color: commonTextStyle,
      ),
      child: InkWell(
        onTap: () {
          _key.currentState?.openDrawer();
        },
        child: Icon(
          icon,
          size: 30,
        ),
      ),
    );
  }

  Widget _appBar() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        RotatedBox(
          quarterTurns: 4,
          child: _icon(
            Icons.menu,
            // color: blueColor,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final content = FutureBuilder(
      future: getAllvehiclesLocation(),
      builder: (ctx, snapshot) {
        // Checking if future is resolved or not
        if (snapshot.connectionState == ConnectionState.done) {
          // If we got an error
          if (snapshot.hasError) {
            errormessage = "No Data";
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  lottie.LottieBuilder.asset(
                    "images/no-data-found.json",
                  ),
                  Text(
                    errormessage,
                    overflow: TextOverflow.clip,
                  ),
                  ElevatedButton(
                      onPressed: () {
                        setState(() {
                          // isError = false;
                        });
                      },
                      child: Text("Refresh"))
                ],
              ),
            );

            // if we got our data
          } else if (snapshot.hasData) {
            // createPlaces();
            print("length of items in build: ${items.length}");
            // manager = initClusterManager();
            return CreateMap(vehicles: clusterData);
          }
        }
        // Displaying LoadingSpinner to indicate waiting state
        return Center(
          child: CircularProgressIndicator(),
        );
      },
    );

    if (!widget.showScaffold) {
      return content;
    }

    return Scaffold(
      key: _key,
      drawer: const NavBar(),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            centerTitle: true,
            leading: Padding(
                padding: const EdgeInsets.only(top: 15),
                child: BackButton(
                  color: Colors.white,
                  onPressed: () {
                    Navigator.pop(context);
                  },
                )),
            title: Padding(
                padding: EdgeInsets.only(top: 20, left: 0),
                child: Text(translation(context).location)),
            elevation: 0,
            actions: [
              ElevatedButton(
                style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.blue)),
                onPressed: () {
                  setState(() {
                    () async {
                      // await getEmployeeLogData();
                      setState(() {
                        searchController.clear();
                        getAllvehiclesLocation();
                      });
                    }();
                    super.initState();
                    print("reload pressed");
                  });
                },
                child: Text(
                  "Refresh".toUpperCase(),
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )),
      resizeToAvoidBottomInset: true,
      body: content,
    );
  }
}

class CreateMap extends StatefulWidget {
  CreateMap({super.key, required this.vehicles});
  List<dynamic> vehicles;

  @override
  State<CreateMap> createState() => _CreateMapState();
}

class _CreateMapState extends State<CreateMap> {
  var vehicleFiltered = [];
  void _searchFun(String enteredKeyword) {
    var results = [];

    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all data
      results = vehicleList.cast<Map<String, dynamic>>();
      ;
    } else {
      results = vehicleFiltered
          .where((person) =>
              person["driverName"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["vehicleName"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["packetTime"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["licensePlate"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["deviceName"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              (person["speed"] ?? "")
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")))
          .cast<Map<String, dynamic>>()
          .toList();
      if (results.isEmpty) {
        setState(() {
          loader = true;
        });
      } else {
        setState(() {
          loader = false;
        });
      }
    }
    // Refresh the UI
    setState(() {
      vehicleList = results;
    });
  }

  @override
  void initState() {
    setState(() {
      vehicleList = widget.vehicles;
      vehicleFiltered = vehicleList;
    });
    super.initState();
  }

  final _formKey = GlobalKey<FormState>();
  var shareDuration = TextEditingController();
  var shareStart = TextEditingController();
  var PhoneNumbers = TextEditingController();
  var emailId = TextEditingController();
  var sharePurpose = TextEditingController();

  Future<void> shareVehiclelocation(BuildContext context, vehicleId) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var Id = int.parse(userId!);
    const sharelocationurl = "${baseUrl}info/share-location";

    var data = {
      "tripId": null,
      "sharePurpose": sharePurpose.text == "" ? null : sharePurpose.text,
      "shareDuration": shareDuration.text == "" ? null : shareDuration.text,
      "shareCreatedBy": Id,
      "shareStart": shareStart.text == ""
          ? null
          : DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(shareStart.text)
              .subtract(Duration(hours: 5, minutes: 30))
              .toString(),
      "PhoneNos": PhoneNumbers.text == "" ? null : PhoneNumbers.text,
      "emailIds": emailId.text == "" ? null : emailId.text,
      "vehicleId": vehicleId
    };
    try {
      // print("Sharing data : ${data}");
      final shareresult = await Dio().post(sharelocationurl, data: data);
      // print(shareresult.statusCode);
      if (shareresult.statusCode == 200) {
        Navigator.pop(context);
        final snackBar = SnackBar(
          content: const Text(
            'Shared Successfully',
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
          content: Text(
            snackBarMessage,
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
    } on DioError catch (e) {
      // print(e.message);
      final snackBar = SnackBar(
        content: Text(
          snackBarMessage,
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

  _buildExpandableContent(vehicle, BuildContext context) {
    List<Widget> columnContent = [];
    columnContent.add(
      Column(
        children: <Widget>[
          Container(
            decoration: BoxDecoration(
                color: Colors.grey.shade100,
                border: Border.all(
                  width: 2.0,
                  color: Colors.blue.shade100,
                )),
            child: Column(
              children: [
                SizedBox(width: 5),
                Row(
                  children: [
                    SizedBox(
                      width: 14,
                    ),
                    Text(
                      "Trip Name: " + (vehicle["tripName"] ?? "--"),
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 5),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(
                      width: 5,
                    ),
                    // Text(
                    //   "Event: " + vehicle["eventName"],
                    //   style: TextStyle(
                    //     fontSize: 13.0,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                    SizedBox(width: 120.00),
                    Text(
                      " ",
                      style: TextStyle(
                        fontSize: 13.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    TextButton(
                      style: ButtonStyle(
                        backgroundColor:
                            MaterialStateProperty.all(Colors.blue.shade100),
                      ),
                      onPressed: () {
                        // singleOrCluster = "single";
                        deviceID = vehicle["id"];
                        getCurrentLocation();
                        vehicleName = vehicle["vehicleName"];
                        var data = {
                          "lat": vehicle["latitude"],
                          "lng": vehicle["longitude"]
                        };
                        SelectedVehCoords = data;
                        print("SelectedVehicleCoordinates" +
                            SelectedVehCoords.toString());
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => CurrentLocationMap()),
                        );
                      },
                      child: Text(
                        "Show Location",
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                    IconButton(
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue.shade100),
                        ),
                        onPressed: () {
                          _formKey.currentState?.reset();
                          pickedDate = null;
                          pickedTime = null;
                          sharePurpose.text = "";
                          shareDuration.text = "";
                          PhoneNumbers.text = "";
                          emailId.text = "";
                          shareStart.clear();
                          showDialog(
                              context: context,
                              builder: (BuildContext ctx) {
                                return Form(
                                  key: _formKey,
                                  child: AlertDialog(
                                    scrollable: true,
                                    title: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        const Text('Share Location'),
                                        IconButton(
                                          onPressed: () {
                                            Navigator.pop(ctx);
                                          },
                                          icon:
                                              const Icon(Icons.close_outlined),
                                          color: Colors.red,
                                        )
                                      ],
                                    ),
                                    content: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Column(
                                        children: <Widget>[
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value == '') {
                                                return "Share Purpose is required";
                                              }
                                              return null;
                                            },
                                            controller: sharePurpose,
                                            decoration: InputDecoration(
                                              label: Row(
                                                children: [
                                                  const Text('*',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(3.0),
                                                  ),
                                                  Text("Share Purpose")
                                                ],
                                              ),
                                              icon: Icon(
                                                  Icons.share_location_rounded),
                                            ),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value == '') {
                                                return "Share Duration is required";
                                              }
                                              return null;
                                            },
                                            controller: shareDuration,
                                            keyboardType: TextInputType.number,
                                            decoration: InputDecoration(
                                              label: Row(
                                                children: [
                                                  const Text('*',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(3.0),
                                                  ),
                                                  Text("Share Duration")
                                                ],
                                              ),
                                              icon: Icon(
                                                  Icons.timelapse_outlined),
                                            ),
                                          ),
                                          // TextFormField(
                                          //   validator: (value) {
                                          //     if (value == null ||
                                          //         value == '') {
                                          //       return "Phone Nos is required";
                                          //     }
                                          //     return null;
                                          //   },
                                          //   controller: PhoneNumbers,
                                          //   decoration: InputDecoration(
                                          //     label: Row(
                                          //       children: [
                                          //         const Text('*',
                                          //             style: TextStyle(
                                          //                 color: Colors.red)),
                                          //         Padding(
                                          //           padding:
                                          //               EdgeInsets.all(3.0),
                                          //         ),
                                          //         Text("Phone Numbers")
                                          //       ],
                                          //     ),
                                          //     icon: Icon(Icons.phone),
                                          //   ),
                                          // ),
                                          TextFormField(
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            validator: (value) {
                                              if (value == null ||
                                                  value == '') {
                                                return "Atleast one Email Id is required";
                                              }
                                              return null;
                                            },
                                            controller: emailId,
                                            decoration: InputDecoration(
                                              label: Row(
                                                children: [
                                                  const Text('*',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(3.0),
                                                  ),
                                                  Text("Email Addresses")
                                                ],
                                              ),
                                              icon: Icon(Icons.email_outlined),
                                            ),
                                          ),
                                          TextFormField(
                                            validator: (value) {
                                              if (value == null ||
                                                  value == '') {
                                                return "Sharing date is required";
                                              }
                                              return null;
                                            },
                                            controller: shareStart,
                                            keyboardType: TextInputType.none,
                                            onTap: () async {
                                              String? formattedDate;
                                              String? formattedTime;
                                              pickedDate = await showDatePicker(
                                                context: context,
                                                initialDate:
                                                    DateTime.now().toLocal(),
                                                firstDate:
                                                    DateTime.now().toLocal(),
                                                lastDate: DateTime.now()
                                                    .toLocal()
                                                    .add(const Duration(
                                                        days: 900)),
                                              );
                                              if (pickedDate != null) {
                                                formattedDate =
                                                    DateFormat('yyyy-MM-dd')
                                                        .format(pickedDate);
                                                pickedTime =
                                                    await showTimePicker(
                                                        context: context,
                                                        initialTime: TimeOfDay
                                                            .fromDateTime(
                                                                DateTime
                                                                    .now()));
                                                // print(
                                                //     "selected date: ${pickedDate.toString()}");

                                                if (pickedTime != null) {
                                                  formattedTime = pickedTime
                                                          .hour
                                                          .toString() +
                                                      ":" +
                                                      pickedTime.minute
                                                          .toString() +
                                                      ":" +
                                                      "59";
                                                  // print("formattedTime: ${formattedTime}");
                                                  formatteddateandtime =
                                                      "$formattedDate $formattedTime";
                                                  // print("formatteddateandtime: ${formatteddateandtime}");
                                                  DateTime a = DateFormat(
                                                          "yyyy-MM-dd HH:mm:ss")
                                                      .parse(
                                                          formatteddateandtime!);
                                                  // print("a date: ${a.toString()}");
                                                  DateTime b = DateTime.now();
                                                  // DateTime.now().add(Duration(minutes: 330));
                                                  // print("b datetime now: ${b.toString()}");
                                                  difference = 0;
                                                  difference =
                                                      b.difference(a).inMinutes;
                                                  // print("difference: ${difference}");
                                                  setState(() {
                                                    shareStart.text =
                                                        formatteddateandtime!;
                                                  });
                                                }
                                              } else {
                                                return null;
                                              }
                                            },
                                            decoration: InputDecoration(
                                              label: Row(
                                                children: [
                                                  const Text('*',
                                                      style: TextStyle(
                                                          color: Colors.red)),
                                                  Padding(
                                                    padding:
                                                        EdgeInsets.all(3.0),
                                                  ),
                                                  Text("Start Sharing From")
                                                ],
                                              ),
                                              icon: Icon(
                                                  Icons.date_range_outlined),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                                    actions: [
                                      ElevatedButton(
                                          child: const Text("Submit"),
                                          onPressed: () async {
                                            if (_formKey.currentState!
                                                .validate()) {
                                              print('Form is valid');
                                            } else {
                                              return;
                                            }
                                            if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
                                                    .hasMatch(emailId.text) &&
                                                PhoneNumbers.text.length < 10) {
                                              // print(
                                              //     "email or  phone required");
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor:
                                                      Colors.redAccent,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                    'Email Id is Mandatory',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              );
                                            } else {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  backgroundColor: Colors.teal,
                                                  behavior:
                                                      SnackBarBehavior.floating,
                                                  content: Text(
                                                    'Sharing in progress, please wait...',
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold),
                                                  ),
                                                ),
                                              );

                                              _formKey.currentState!.validate();
                                              await shareVehiclelocation(
                                                  ctx, vehicle["vehicleId"]);
                                              _formKey.currentState?.reset();
                                            }
                                          })
                                    ],
                                  ),
                                );
                              });
                        },
                        icon: const Image(
                          width: 30,
                          height: 30,
                          image: AssetImage("images/share.png"),
                        ))
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
    return columnContent;
  }

  @override
  Widget build(BuildContext context) {
    print(vehicleList);

    return Container(
      child: Stack(
        children: [
          Positioned.fill(
              bottom: MediaQuery.of(context).size.height * 0.15,
              child: CreateClusterMap(clusterData)),
          Positioned.fill(
              child: DraggableScrollableSheet(
            maxChildSize: 0.99,
            minChildSize: 0.2,
            initialChildSize: 0.4,
            builder: (_, scrollController) {
              return Material(
                elevation: 0,
                borderRadius:
                    const BorderRadius.vertical(top: Radius.circular(20)),
                child: SingleChildScrollView(
                    controller: scrollController,
                    child: Column(children: [
                      Container(
                        child: TextField(
                          controller: searchController,
                          decoration: InputDecoration(
                              prefixIcon: Icon(Icons.search),
                              suffixIcon: GestureDetector(
                                  onTap: () {
                                    searchController.clear();
                                    setState(() {
                                      _searchResult = '';
                                      vehicleList = vehicleFiltered;
                                    });
                                  },
                                  child: Icon(Icons.cancel)),
                              hintText: 'Search',
                              border: InputBorder.none),
                          onChanged: (value) async => _searchFun(value),
                        ),
                        height: 40,
                        width: 360,
                      ),
                      SizedBox(
                          height: 500.0,
                          child: ListView.builder(
                              itemCount: vehicleList.length,
                              itemBuilder: (context, index) {
                                var lastReportedDateTime = dateFormatter(
                                    vehicleList[index]["packetTime"]);
                                print(
                                    "last reported1: ${lastReportedDateTime}");
                                return Container(
                                  decoration: BoxDecoration(
                                      border: Border.all(
                                          color: Colors.blue.shade100)),
                                  child: ExpansionTile(
                                    backgroundColor: Colors.white,
                                    collapsedBackgroundColor: Colors.white,
                                    collapsedTextColor: Colors.black,
                                    textColor: Colors.black,
                                    title: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Container(
                                              width: 160.0,
                                              child: Text(
                                                vehicleList[index]
                                                        ["vehicleName"] ??
                                                    "-",
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                            SizedBox(width: 10),
                                            Text(
                                                "Driver: " +
                                                    (vehicleList[index]
                                                            ["driverName"] ??
                                                        "-"),
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold,
                                                )),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 5.0,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              width: 250.00,
                                              child: Text(
                                                "Last Reported2: " +
                                                        lastReportedDateTime
                                                            .toString() ??
                                                    "-",
                                                style: TextStyle(
                                                  fontSize: 12.0,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    ),
                                    subtitle: Text(
                                      "Speed: ${(vehicleList[index]["speed"] ?? 0).toStringAsFixed(0)} km/h",
                                      //"Speed: ", // need to fix
                                      //"Speed: " +
                                      //     vehicleList[index]["speed"]
                                      //         .toStringAsFixed(0) ??
                                      // "-",
                                      style: TextStyle(
                                        fontSize: 12.0,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    children: <Widget>[
                                      Column(
                                        children: _buildExpandableContent(
                                            vehicleList[index], context),
                                      ),
                                    ],
                                  ),
                                );
                              }))
                    ])),
              );
            },
          )),
        ],
      ),
    );
  }
}

// Clustering maps
class CreateClusterMap extends StatefulWidget {
  CreateClusterMap(this.vehicles);
  List<dynamic> vehicles;

  @override
  State<CreateClusterMap> createState() => CreateClusterMapState();
}

class CreateClusterMapState extends State<CreateClusterMap> {
  late dynamic _manager;
  Completer<GoogleMapController> _controller = Completer();
  Set<Marker> markers = Set();

  createPlaces() {
    camPosition = LatLng(11.342423, 77.728165);
    print("Initial cam position : ${camPosition.toString()}");
    items = [
      for (var i in widget.vehicles)
        if (i["latitude"] != null && i["longitude"] != null) // ← guard here
          Place(
              name: i["vehicleName"] ?? "Unknown",
              latLng: LatLng(i["latitude"], i["longitude"]))
    ];
    // for (var i in items) {
    //   print("Items: ${i.name}");
    // }
  }

  @override
  void initState() {
    print("CreateClusterMap initState START");

    createPlaces();

    print("CreateClusterMap createPlaces DONE");

    _manager = _initClusterManager();

    print("CreateClusterMap manager DONE");

    super.initState();

    print("CreateClusterMap initState END");
  }

  ClusterManager<Place> _initClusterManager() {
    return ClusterManager<Place>(items, _updateMarkers,
        markerBuilder: _markerBuilder);
  }

  void _updateMarkers(Set<Marker> markers) {
    print('Updated ${markers.length} markers');
    setState(() {
      this.markers = markers;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(children: [
        GoogleMap(
            mapType: MapType.normal,
            rotateGesturesEnabled: true,
            // myLocationEnabled: true,
            myLocationButtonEnabled: false,
            tiltGesturesEnabled: true,
            compassEnabled: true,
            scrollGesturesEnabled: true,
            zoomGesturesEnabled: true,
            initialCameraPosition: CameraPosition(
              target: camPosition,
              zoom: 6.5,
            ),
            markers: markers,
            onMapCreated: (GoogleMapController controller) {
              print("MAP CREATED");
              _controller.complete(controller);
              print("MAP CONTROLLER COMPLETE");
              _manager.setMapId(controller.mapId);
              print("MAP ID SET");
            },
            onCameraMove: (CameraPosition position) {
              currentZoom = position.zoom;
              _manager.onCameraMove(position);
            },
            onCameraIdle: _manager.updateMap),
        Positioned(
          right: 16,
          bottom: 20,
          child: Column(children: [
            Container(
              height: 30,
              width: 30,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.add,
                  size: 28,
                  color: Colors.grey,
                ),
                onPressed: () async {
                  final controller = await _controller.future;
                  currentZoom++;
                  controller.animateCamera(
                    CameraUpdate.zoomTo(currentZoom),
                  );
                },
              ),
            ),
            const SizedBox(height: 8), // ← spacer
            Container(
              height: 30,
              width: 30,
              child: FloatingActionButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                backgroundColor: Colors.white,
                child: const Icon(
                  Icons.remove,
                  size: 28,
                  color: Colors.grey,
                ),
                onPressed: () async {
                  final controller = await _controller.future;
                  currentZoom--;
                  controller.animateCamera(
                    CameraUpdate.zoomTo(currentZoom),
                  );
                },
              ),
            ),
          ]),
        ),
      ]),
    );
  }

  // Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
  //     (cluster) async {
  //       return Marker(
  //         markerId: MarkerId(cluster.getId()),
  //         position: cluster.location,
  //         icon: BitmapDescriptor.defaultMarker,
  //       );
  //     };

  Future<Marker> Function(Cluster<Place>) get _markerBuilder =>
      (cluster) async {
        try {
          return Marker(
            markerId: MarkerId(cluster.getId()),
            infoWindow: InfoWindow(title: "${cluster.items.first.name}"),
            position: cluster.location,
            onTap: () {
              print('---- $cluster');
              cluster.items.forEach((p) => print(p.name));
            },
            icon: cluster.isMultiple
                ? await _getMarkerBitmap(125, text: cluster.count.toString())
                : urlList2 != null // ← null guard
                    ? await BitmapDescriptor.fromBytes(urlList2)
                    : BitmapDescriptor.defaultMarker, // ← safe fallback
          );
        } catch (e) {
          print("Marker builder error: $e");
          return Marker(
            markerId: MarkerId(cluster.getId()),
            position: cluster.location,
            icon: BitmapDescriptor.defaultMarker, // ← crash fallback
          );
        }
      };

  Future<BitmapDescriptor> _getMarkerBitmap(int size, {String? text}) async {
    try {
      if (kIsWeb) size = (size / 2).floor();

      final PictureRecorder pictureRecorder = PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint1 = Paint()..color = Colors.orange;
      final Paint paint2 = Paint()..color = Colors.white;

      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint2);
      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);

      if (text != null) {
        TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
        painter.text = TextSpan(
          text: text,
          style: TextStyle(
            fontSize: size / 3,
            color: Colors.white,
            fontWeight: FontWeight.normal,
          ),
        );
        painter.layout();
        painter.paint(
          canvas,
          Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
        );
      }

      final img = await pictureRecorder.endRecording().toImage(size, size);
      final data =
          await img.toByteData(format: ImageByteFormat.png) as ByteData;
      return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    } catch (e) {
      print("_getMarkerBitmap error: $e");
      return BitmapDescriptor.defaultMarker;
    }
  }
}

class Place with ClusterItem {
  Place({required this.name, required this.latLng});
  final String name;
  final LatLng latLng;
  @override
  LatLng get location => latLng;
}

class LocationDataScreen extends StatelessWidget {
  const LocationDataScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}

import 'package:admin_app/api/api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../languges/language_constants.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'package:admin_app/screens/sidebar.dart';
import 'package:dio/dio.dart';

import 'dashboardScreen.dart';

Future<bool> _onwillscope(BuildContext context) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext ctx) {
    return Dashboard();
  }));
  return true;
}

class ScreenEvents extends StatefulWidget {
  // ScreenEvents(
  //     {required this.vehicleList, required this.deviceLocationList});
  List<dynamic> vehicleList = [];
  var deviceLocationList = [];
  @override
  State<ScreenEvents> createState() => _ScreenEventsState();
}

class _ScreenEventsState extends State<ScreenEvents> {
  bool isHomePageSelected = true;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  List<Map<dynamic, dynamic>> EventData = [];

  Widget _icon(IconData icon) {
    return WillPopScope(
        onWillPop: () => _onwillscope(context),
        child: Container(
          padding: EdgeInsets.all(10),
          decoration: BoxDecoration(
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
        ));
  }

  Widget _appBar() {
    return Container(
      child: Row(
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
      ),
    );
  }

  var searchController = TextEditingController();
  String _searchResult = '';
  List<Map<dynamic, dynamic>> usersFiltered = [];

  Future<List<dynamic>> getEvents() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    final url = "${baseUrl}dashboard/event?userId=$userId";
    var dio = Dio();
    final response = await dio.get(url);
    EventData.clear();
    print("res${response.data}");
    for (var i = 0; i < response.data.length; i++) {
      EventData.add(response.data[i]);
    }
    print(" data is here ${EventData[0]['eventName']}");
    print('length:${EventData.length}');
    print(EventData.runtimeType);
    return EventData;
  }

  Future<List<dynamic>> getdatas() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");

    final url = "${baseUrl}api/list-vehicles/$userId";
    var dio = Dio();
    final response2 = await dio.get(url);
    List<dynamic> newList = response2.data;
    // print(" data is here $newList");
    print(newList.runtimeType);
    return newList;
  }

  var getVehicleTypes = [];
  List<dynamic> getVehicleTypeNames = [];

  Future<List<dynamic>> getVehicleTypeList() async {
    final url = "${baseUrl}api/vehicle-types";
    var dio = Dio();
    final response2 = await dio.get(url);
    getVehicleTypes = response2.data;
    print("reponse data are:${response2.data}");
    print("reponse data are:${getVehicleTypes}");
    print("reponse data are:${getVehicleTypes.runtimeType}");

    for (var i in getVehicleTypes) {
      print(i['name']);
      getVehicleTypeNames.add(i['name']);
      print("KKKKKKKKKK");
      print(getVehicleTypeNames);
    }
    print(getVehicleTypeNames);

    // print(newList[0]['name']);

    print(" data is here $getVehicleTypeNames");
    print(getVehicleTypeNames.runtimeType);
    return getVehicleTypes;
  }

  var getDeviceDetails = [];
  List<dynamic> getDevice = [];

  final List<Map<String, dynamic>> demolist = [
    {"id": 1, "name": "Jishnu", "age": 45},
  ];
  List<Map<dynamic, dynamic>> ListVehicles = [];
  List Listids = [];

  List<Widget> Addvehicles() {
    print("length of the list is:${vehLocationList.length}");
    // print(widget.deviceLocationList);
    for (var i = 0; i < vehLocationList.length; i++) {
      var x = 0;
      // for (var j=0;j<totalTrip.length;j++){
      if (vehLocationList[i]["eventCode"] != null) {
        // if(totalTrip[j]['tripId']==vehLocationList[i]['tripId']){
        ListVehicles.add({
          "eventName": vehLocationList[i]['eventName'],
          "vehicleName": vehLocationList[i]['vehicleName'],
          "eventCode": vehLocationList[i]['eventCode'],
          "driverName": vehLocationList[i]['driverName'],
          "licensePlate": vehLocationList[i]['licensePlate'],
          "tripName": vehLocationList[i]['tripName'],
          "tripId": vehLocationList[i]['tripId'],
        });
      }
    }

    print(" length${ListVehicles.length}");

    setState(() {
      ListVehicles = ListVehicles;
    });

    List<Widget> Demo = [];
    return Demo;
  }

  var totVehicleList = [];
  var deleteconfirmed = false;
  var deleted = false;
  var success;
  var clickeddeleteButton = false;
  var erroroccured = false;
  var deleteStatusCode;
  Future<List<dynamic>> deleteVehicle(var vehicleId) async {
    setState(() {
      // deletion= true;
      print("try 1 st deletion${deleteconfirmed}");
    });
    final url = "${baseUrl}api/delete-vehicle/$vehicleId";
    var dio = Dio();
    try {
      final response = await dio.delete(url);
      print(response.data);

      print(response.statusCode);
      setState(() {
        deleteStatusCode = response.statusCode;
        deleteconfirmed = true;
      });
      route() {
        // Navigator.pop(context);
        setState(() {
          clickeddeleteButton = false;
          deleteconfirmed = false;

          print("this line will execute after 4 seconds");
        });
      }

      startTimer() async {
        var duration = Duration(seconds: 5);
        return Timer(duration, route);
      }

      await startTimer();
    } catch (e) {
      print(e);
      setState(() {
        var erroroccured = true;
        deleteconfirmed = true;
        deleteStatusCode = 400;
        print("catch deletion${deleteconfirmed}");
      });
    }
    return totVehicleList;
  }

  var vehLocationList = [];
  List<dynamic> allids = [];
  var dio = Dio();
  var offlineVehicles = 0;
  var onlineVehicles = 0;
  var loader = false;
  Future<List<dynamic>> getVehiclesDetails() async {
    setState(() {
      loader = true;
    });
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    final url = "${baseUrl}api/list-vehicles/$userId";
    var dio = Dio();
    try {
      final response = await dio.get(url);
      totVehicleList = response.data;
      allids = [];
      for (var i in totVehicleList) {
        if (i['deviceId'] != null && i['deviceId'] != "") {
          allids.add(i['deviceId']);
        }
      }
      print("all id for the location is:${allids}");
    } catch (e) {
      print(e);
      print("Some error occured");
    }
    print('length of total vehicle list: ${totVehicleList.length}');
    print("inside getvehiclesdetails: ${totVehicleList} ");
    return totVehicleList;
  }

  var totalTrip;

  Future getTripDetails() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    print("user is strored is $userId");
    final url = "${baseUrl}trips/list-trips/$userId";
    //show error message try catch
    var dio = Dio();
    try {
      final response = await dio.get(url);
      print(response.data['list'][0].runtimeType);
      totalTrip = response.data['list'];
      print("total trip is:${totalTrip}");
    } catch (e) {
      print(e);
      print("Some error occured");
    }
    print('length of total trip is: ${totalTrip.length}');
    print("inside total trip:${totalTrip} ");
    return totalTrip;
    // newList = [response.data, newList2];
  }

  Future<List<dynamic>> getDeviceCurrentLocation() async {
    var data = {"deviceIds": allids};
    final url2 = "${baseUrl}location/getDeviceCurrentLocation";
    try {
      final response = await dio.post(url2, data: data);
      vehLocationList = await response.data;
      print("vehicles location list: ${vehLocationList}");

      print("in get for events");
      setState(() {
        loader = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loader = false;
      });
      print("Some error occured");
    }
    print("online count: ${onlineVehicles}");
    return vehLocationList;
  }

  //funtion to  search

  void _runFilter(dynamic enteredKeyword) {
    List<Map<dynamic, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      setState(() {
        results = ListVehicles;
        // usersFiltered = results;
      });
    } else {
      results = ListVehicles.where((person) =>
              person["VehicleName"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase()) ||
              person["VehicleType"]
                  .toLowerCase()
                  .contains(enteredKeyword.toLowerCase())
          // ||
          // person["manufacturer"].toLowerCase().contains(enteredKeyword.toLowerCase())
          // ||
          // person["VehicleModel"].toLowerCase().contains(enteredKeyword.toLowerCase())
          ).toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    // // Refresh the UI
    setState(() {
      usersFiltered = results;
    });
  }

  List<Map<dynamic, dynamic>> getDeviceNames = [];
  List<Map<dynamic, dynamic>> excludedDeviceNames = [];

  Future<List<dynamic>> getDeviceLists() async {
    final prefs = await SharedPreferences.getInstance();

    var userId = prefs.getString("user_id");
    print("user is strored is $userId");
    final url = "${baseUrl}device/getDevices/$userId";
    var dio = Dio();
    final response = await dio.get(url);
    print(response.data['list']);
    setState(() {
      getDeviceDetails = response.data['list'];
    });
    print("device data are:${response.data}");
    print("device data are:${getDeviceDetails}");
    print("reponse data are:${getDeviceDetails.length}");
    getDeviceNames = [];
    excludedDeviceNames = [];

    for (var j = 0; j < getDeviceDetails.length; j++) {
      var x = 0;

      for (var i = 0; i < widget.vehicleList.length; i++) {
        if (widget.vehicleList[i]['deviceId'] ==
            getDeviceDetails[j]['deviceId']) {
          getDeviceNames.add({
            "id": getDeviceDetails[j]['deviceId'],
            "name": getDeviceDetails[j]['deviceName'],
          });
          x = 1;
          break;
        }
      }
      if (x == 0) {
        excludedDeviceNames.add({
          "id": getDeviceDetails[j]['deviceId'],
          "name": getDeviceDetails[j]['deviceName'],
        });
      }
    }

    print(getDeviceNames);
    print(" devices names is here $getDeviceNames");
    print(" existing devices names is here $excludedDeviceNames");
    print(" devices names is here ${getDeviceNames.length}");
    print(" existing devices names is here ${excludedDeviceNames.length}");
    print(getDeviceNames.runtimeType);
    return getDeviceNames;
  }

  @override
  void initState() {
    () async {
      await getVehiclesDetails();
      await getDeviceCurrentLocation();
      await getTripDetails();
      await Addvehicles();
      await getEvents();
      setState(() {
        EventData = EventData;
        ListVehicles = [];
        usersFiltered = ListVehicles;
      });
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        key: _key,
        drawer: NavBar(),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: AppBar(
              centerTitle: true,
              leading:
                  Padding(padding: EdgeInsets.only(top: 15), child: _appBar()),
              title: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(translation(context).events)),
              elevation: 0,
            )),
        body: EventData.length != 0
            ? Column(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                      // height: MediaQuery.of(context).size.height * .7,
                      child: ListView.builder(
                          itemCount: EventData.length,
                          itemBuilder: (context, index) {
                            return SingleChildScrollView(
                              scrollDirection: Axis.vertical,
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                                  // width: 85.w,
                                  // height: 47.h,
                                  decoration: BoxDecoration(
                                    color: Color(0xFFFFFFFF),
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10)),
                                    border: Border.all(
                                      width: 1,
                                      color: Color(0xFF000000).withOpacity(0.3),
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 1),
                                        blurRadius: 5,
                                        color: Colors.black.withOpacity(0.2),
                                      ),
                                    ],
                                  ),
                                  child: Container(
                                    padding:
                                        EdgeInsets.fromLTRB(12, 20, 10, 15),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          EventData[index]['eventName']
                                              .toString(),
                                          style: eventsPageCardHeadTextStyle,
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .03,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  child: EventData[index]
                                                              ['priority'] ==
                                                          "HIGH"
                                                      ? highPriorityIcon
                                                      : EventData[index][
                                                                  'priority'] ==
                                                              "CRITICAL"
                                                          ? criticalPriorityIcon
                                                          : EventData[index][
                                                                      'priority'] ==
                                                                  "MEDIUM"
                                                              ? mediumPriorityIcon
                                                              : lowPriorityIcon,
                                                  height: 25,
                                                  width: 25,
                                                  decoration: BoxDecoration(
                                                      color: iconColourRed,
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              50)),
                                                ),
                                                SizedBox(
                                                  width: MediaQuery.of(context)
                                                          .size
                                                          .width *
                                                      .025,
                                                ),
                                                Text(
                                                  EventData[index]['priority']
                                                      .toString(),
                                                  style:
                                                      eventsPageCardTextNormalTextStyle,
                                                ),
                                              ],
                                            ),
                                            Text(
                                              'Date time',
                                              style:
                                                  eventsPageCardTextNormalTextStyle,
                                            ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .width *
                                              .01,
                                        ),
                                        IntrinsicWidth(
                                          child: Column(
                                            children: [
                                              Divider(
                                                color: Colors.black,
                                                thickness: 1,
                                              ),
                                              Container(
                                                width: MediaQuery.of(context)
                                                    .size
                                                    .width,
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .01,
                                        ),
                                        Row(
                                          children: [
                                            // Text(
                                            // ListVehicles[index]['tripName'],
                                            // style:
                                            // vehiclePageCardTextSubHeadStyle,
                                            // ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .025,
                                            ),
                                            // Text(
                                            //   "(${ListVehicles[index]['tripId'].toString()})",
                                            //   style:
                                            //   vehiclePageCardTextSubHeadStyle,
                                            // ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .01,
                                        ),
                                        Row(
                                          children: [
                                            // Text(
                                            //   'Status:',
                                            //   style:
                                            //   vehiclePageCardTextSubHeadStyle,
                                            // ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .025,
                                            ),
                                            // Text(
                                            //   ListVehicles[index]['status'].toString(),
                                            //   style:
                                            //   // vehiclePageCardTextSubHeadRedStyle
                                            //   vehiclePageCardTextSubHeadOrangeStyle,
                                            // ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .02,
                                        ),
                                        Row(
                                          children: [
                                            Container(
                                              height: 30,
                                              width: 30,
                                              child: Image.asset(
                                                'images/cariconred2.png',
                                                width: 40,
                                                height: 40,
                                                fit: BoxFit.fill,
                                              ),
                                              decoration: BoxDecoration(
                                                  color: offlineColor,
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(30))),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .025,
                                            ),
                                            // Expanded(
                                            //   child: Text(
                                            //     "${ListVehicles[index]['vehicleName'].toString()}    ${ListVehicles[index]['licensePlate'].toString()}",
                                            //     style:
                                            //     vehiclePageCardTextSubHeadStyle,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        SizedBox(
                                          height: MediaQuery.of(context)
                                                  .size
                                                  .height *
                                              .025,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.spaceBetween,
                                          children: [
                                            Container(
                                              padding: EdgeInsets.fromLTRB(
                                                  0, 3, 0, 5),
                                              child: locationIconRed,
                                              height: 30,
                                              width: 30,
                                              decoration: BoxDecoration(
                                                  color: iconColourRed,
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          40)),
                                            ),
                                            SizedBox(
                                              width: MediaQuery.of(context)
                                                      .size
                                                      .width *
                                                  .025,
                                            ),
                                            // Expanded(
                                            //   child: Text(
                                            //     'Location',
                                            //     style:
                                            //     vehiclePageCardTextSubHeadStyle,
                                            //   ),
                                            // ),
                                            // Expanded(
                                            //   child: Text(
                                            //     'DateTime',
                                            //     style:
                                            //     vehiclePageCardTextSubHeadStyle,
                                            //   ),
                                            // ),
                                          ],
                                        ),
                                        Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 15, 0, 0),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(30)),
                                            // color: Color(0xFFFFFFFF),
                                            // borderRadius:
                                            // BorderRadius.all(Radius.circular(10)),
                                            border: Border.all(
                                              width: 1,
                                              color: Color(0xFF000000)
                                                  .withOpacity(0.1),
                                            ),
                                            boxShadow: [
                                              BoxShadow(
                                                offset: Offset(0, 1),
                                                blurRadius: 2,
                                                color: Colors.black
                                                    .withOpacity(0.1),
                                              ),
                                            ],
                                          ),
                                          child: Row(
                                            children: [
                                              Container(
                                                width: 55,
                                                height: 55,
                                                // decoration: BoxDecoration(
                                                //     image: ListVehicles[index]['driverImage'] == '' ?
                                                //
                                                //     DecorationImage(
                                                //         fit: BoxFit.cover,
                                                //         image: AssetImage("images/profile.jpg")
                                                //     ):  DecorationImage(
                                                //         fit: BoxFit.cover,
                                                //         image: NetworkImage(ListVehicles[index]['driverImage'].toString())
                                                //     ),
                                                //     color: offlineColor,
                                                //     borderRadius: BorderRadius.all(Radius.circular(30)),
                                                //   border: Border.all(
                                                //     width: 1,
                                                //     color: Color(0xFF000000).withOpacity(0.3),
                                                //   ),
                                                //   boxShadow: [
                                                //     BoxShadow(
                                                //       offset: Offset(0, 1),
                                                //       blurRadius: 5,
                                                //       color: Colors.black.withOpacity(0.2),
                                                //     ),
                                                //   ],
                                                // ),
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .035,
                                              ),
                                              // Expanded(
                                              //   child: Text(
                                              //     '${ListVehicles[index]['driverName'].toString()}\n#mobilenumber',
                                              //     style: vehiclePageCardTextSubHeadStyle,
                                              //   ),
                                              // ),
                                              Icon(
                                                Icons.phone_enabled_rounded,
                                                size: 25,
                                                color: offlineColor,
                                              ),
                                              SizedBox(
                                                width: MediaQuery.of(context)
                                                        .size
                                                        .width *
                                                    .025,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  )),
                            );
                          }),
                    ),
                  ),
                ],
              )
            : Center(
                child: CircularProgressIndicator(),
              ));
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
}

import 'dart:typed_data';
import 'package:admin_app/screens/sidebar.dart';
import 'package:admin_app/screens/themes.dart';
import 'package:admin_app/screens/tracking_screen/location_tab_variables.dart';
import 'package:admin_app/screens/tracking_screen/singleVehLocation.dart';
import 'package:admin_app/screens/tracking_screen/vehicle_live_location.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sizer/sizer.dart';
import '../languges/language_constants.dart';
import 'dashboardScreen.dart';
import 'package:auto_size_text/auto_size_text.dart';

// List<Vehicles> totalVehicle = [];

class VehicleScreen extends StatefulWidget {
  VehicleScreen(
      {required this.status,
      required this.deviceLocationList,
      required this.vehicleList,
      required this.Lists});
  String status;
  var Lists = [];
  List<dynamic> vehicleList = [];
  var deviceLocationList = [];

  @override
  State<VehicleScreen> createState() => _VehicleScreenState();
}

Future<bool> _onwillscope(BuildContext context) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext ctx) {
    return Dashboard();
  }));
  return true;
}

class _VehicleScreenState extends State<VehicleScreen> {
  var dateFormat1 = DateFormat("dd-MM-yyyy hh:mm");
  GlobalKey<ScaffoldState> _key = GlobalKey();
  bool isHomePageSelected = true;
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

  List<Map<dynamic, dynamic>> totalVehicle = [];
  var FormattedDate;
  List<Widget> Addvehicles() {
    print(
        "Total length of total vehicle is that: ${widget.vehicleList.length}");
    var dIds = [];
    var vDids = [];
    for (var i in widget.deviceLocationList) {
      dIds.add(i["id"]);
    }
    print("inside addvehicles, device list :${dIds}");
    for (var i in widget.vehicleList) {
      vDids.add(i['deviceId']);
    }
    print("inside addvehicles, vehicles list${vDids}");
    for (var i = 0; i < widget.vehicleList.length; i++) {
      for (var j = 0; j < widget.deviceLocationList.length; j++) {
        if (widget.deviceLocationList[j]["id"] ==
            widget.vehicleList[i]["deviceId"]) {
          if (widget.deviceLocationList[j]['deviceStatus'] == widget.status) {
            print(
                "vehicle status v name  is:${widget.vehicleList[i]['vehicleName']}");
            print(
                "packet 2 time is ${widget.deviceLocationList[j]['packetTime']}");
            print(
                "packet time is ${widget.deviceLocationList[j]['deviceName']}");
            if (widget.deviceLocationList[j]['packetTime'] != null) {
              DateTime date = DateFormat("yyyy-MM-dd hh:mm").parse(widget
                  .deviceLocationList[j]['packetTime']
                  .toString()
                  .replaceAll('T', ' '));
              FormattedDate = DateFormat("dd-MM-yyyy hh:mm a").format(date);
              // FormattedDate=widget.deviceLocationList[j]['packetTime'];
            } else {
              FormattedDate = "--";
            }
            print("device loc list: ${widget.deviceLocationList[j]}");
            totalVehicle.add({
              "DeviceId": widget.vehicleList[i]["deviceId"],
              "Lati": widget.deviceLocationList[j]["latitude"],
              "Long": widget.deviceLocationList[j]["longitude"],
              "VehicleStatus": widget.deviceLocationList[j]['vehicleStatus'],
              "VehicleModel": widget.vehicleList[i]['model'] != null
                  ? widget.vehicleList[i]['model']
                  : "--",
              "LastReportedTime":
                  // widget.deviceLocationList[j]['packetTime'] != null ?
                  // widget.deviceLocationList[j]['packetTime'] : "--",
                  FormattedDate,
              "VehicleName": widget.vehicleList[i]['vehicleName'],
              "VehicleType": widget.vehicleList[i]['vehicleTypeName'],
              "TrackingDevice": widget.vehicleList[i]['deviceName'],
              "VehicleSubType":
                  widget.vehicleList[i]['vehicleSubtypeName'] != null
                      ? widget.vehicleList[i]['vehicleSubtypeName']
                      : "--",
              "VehicleLicensePlate": widget.vehicleList[i]['licensePlate'],
              "VehicleId": widget.deviceLocationList[j]['vehicleId'],
              "DeviceStatus": widget.deviceLocationList[j]['deviceStatus'],
              "MovingStatus": widget.deviceLocationList[j]['speed'],
            });
            print("Tot Vehicles: ${totalVehicle[totalVehicle.length - 1]}");
          }
        }
      }
      // }
    }
    setState(() {
      totalVehicle = totalVehicle;
    });

    List<Widget> Demo = [];
    return Demo;
  }

  var searchController = TextEditingController();
  String _searchResult = '';
  List<Map<dynamic, dynamic>> filteredVehicles = [];
  void _runFilter(dynamic enteredKeyword) {
    List<Map<dynamic, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      setState(() {
        results = totalVehicle;
        // usersFiltered = results;
      });
    } else {
      results = totalVehicle
          .where((person) =>
                  person["VehicleName"]
                      .toLowerCase()
                      .contains(enteredKeyword.toLowerCase()) ||
                  person["VehicleLicensePlate"]
                      .toLowerCase()
                      .contains(enteredKeyword.toLowerCase()) ||
                  // person["VehicleModel"]
                  //     .toLowerCase()
                  //     .contains(enteredKeyword.toLowerCase())
                  // ||
                  person["VehicleType"].toLowerCase().contains(
                      enteredKeyword.toLowerCase().replaceAll(" ", ""))
              // ||
              // person["VehicleSubType"]
              //     .toLowerCase()
              //     .contains(enteredKeyword.toLowerCase())
              // ||
              // person["deviceName"]
              //     .toLowerCase()
              //     .contains(enteredKeyword.toLowerCase())
              // ||
              // person["insuranceNumber"]
              //     .toLowerCase()
              //     .contains(enteredKeyword.toLowerCase())
              // ||
              // person["deviceName"]
              //     .toLowerCase()
              //     .contains(enteredKeyword.toLowerCase())
              // ||
              // person["manufacturer"].toLowerCase().contains(enteredKeyword.toLowerCase())
              // ||
              // person["VehicleModel"].toLowerCase().contains(enteredKeyword.toLowerCase())
              )
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    // Refresh the UI
    setState(() {
      filteredVehicles = results;
    });
  }

  @override
  void initState() {
    () async {
      // totalVehicle = [];
      print("get vehicles called");
      await Addvehicles();
      setState(() {
        filteredVehicles = totalVehicle;
      });
      print("totalvehicle length:${totalVehicle.length}");
    }();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    var offline = 0;
    for (var i in widget.deviceLocationList) {
      if (i['deviceStatus'].toString() == "Offline") {
        offline++;
      }
    }
    var onlinevehicles = 0;
    for (var i in widget.deviceLocationList) {
      if (i['deviceStatus'] == "Online") {
        onlinevehicles++;
      }
    }
    var movingvehicles = 0;
    var stoppedvehicles = 0;
    for (var i in widget.deviceLocationList) {
      if (onlinevehicles != 0 &&
          i['speed'] != 0.0 &&
          i['speed'].toString() != "null") {
        movingvehicles++;
      }
    }
    DateTime Today = DateTime.now();

    return Scaffold(
        key: _key,
        drawer: NavBar(),
        appBar: AppBar(
          toolbarHeight: 90,
          leading: Padding(padding: EdgeInsets.only(top: 25), child: _appBar()),
          title: Padding(
              padding: EdgeInsets.only(top: 35, left: 25),
              child: Column(children: [
                Text(translation(context).vehicleStatus),
                Text(DateFormat.yMMMEd().format(DateTime.now())),
              ])),
        ),
        body: totalVehicle.length != 0
            ? Column(
                children: [
                  Container(
                    color: Color(0xFFEAEAEA),
                    child: Column(
                      children: [
                        Container(
                            padding: EdgeInsets.fromLTRB(1.5.w, .5.h, 0, 0),
                            // height: widget.status!= 'Online'  ? 13.8.h : 20.h,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xFF6197CA).withOpacity(0.3),
                            ),
                            child: totalVehicle.length != 0
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    // crossAxisAlignment:  CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        padding: EdgeInsets.only(left: 35),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Container(
                                                  child: Center(
                                                      child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    children: [
                                                      Container(
                                                        // color: Color(0xFF6197CA).withOpacity(0.3),
                                                        child: CircleAvatar(
                                                          backgroundColor:
                                                              Colors
                                                                  .transparent,
                                                          radius: 15,
                                                          child: Image.asset(
                                                              'images/caricongreen.png'),
                                                        ),
                                                        // height: 20,
                                                        // width: 20,
                                                        // decoration: BoxDecoration(
                                                        //   color: Color(0xFF539ADB),
                                                        //   borderRadius: BorderRadius.circular(5),
                                                        //   boxShadow: [
                                                        //     BoxShadow(
                                                        //       offset: Offset(0, 1),
                                                        //       blurRadius: 4,
                                                        //       color: Colors.black.withOpacity(0.1),
                                                        //     ),
                                                        //   ],
                                                        // ),
                                                      ),
                                                      SizedBox(
                                                        width: 3.w,
                                                      ),
                                                      AutoSizeText(
                                                        "Total",
                                                        minFontSize: 15,
                                                        maxFontSize: 22,
                                                        style: whiteTextStyle,
                                                      ),
                                                      SizedBox(
                                                        width: 2.w,
                                                      ),
                                                      Container(
                                                        child: Center(
                                                          child: AutoSizeText(
                                                            '${widget.Lists.first.OnlineCount + widget.Lists.first.OfflineCount}',
                                                            minFontSize: 13,
                                                            maxFontSize: 16,
                                                            style:
                                                                vehiclePageCardTextStyle,
                                                          ),
                                                        ),
                                                        height: 30,
                                                        width: 30,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(30),
                                                          color: Colors.white,
                                                          boxShadow: [
                                                            BoxShadow(
                                                              offset:
                                                                  Offset(0, 1),
                                                              blurRadius: 4,
                                                              color: Colors
                                                                  .black
                                                                  .withOpacity(
                                                                      0.1),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )),
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 2.h, 0, 0),
                                                  padding: EdgeInsets.fromLTRB(
                                                      1.5.w, 0, .2.w, 0),
                                                ),
                                                widget.status == 'Online'
                                                    ? Container(
                                                        child: Center(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                radius: 15,
                                                                child: Image.asset(
                                                                    'images/new-car-icon-green.png'),
                                                              ),
                                                              // height: 20,
                                                              // width: 20,
                                                              // decoration:
                                                              //     BoxDecoration(
                                                              //   color:
                                                              //       onlineColor,
                                                              //   borderRadius:
                                                              //       BorderRadius
                                                              //           .circular(
                                                              //               5),
                                                              //   boxShadow: [
                                                              //     BoxShadow(
                                                              //       offset:
                                                              //           Offset(
                                                              //               0,
                                                              //               1),
                                                              //       blurRadius:
                                                              //           4,
                                                              //       color: Colors
                                                              //           .black
                                                              //           .withOpacity(
                                                              //               0.1),
                                                              //     ),
                                                              //   ],
                                                              // ),
                                                            ),
                                                            SizedBox(
                                                              width: 3.w,
                                                            ),
                                                            AutoSizeText(
                                                              "Online",
                                                              minFontSize: 15,
                                                              maxFontSize: 22,
                                                              style:
                                                                  whiteTextStyle,
                                                            ),
                                                            SizedBox(
                                                              width: 2.w,
                                                            ),
                                                            Container(
                                                              child: Center(
                                                                child:
                                                                    AutoSizeText(
                                                                  '${widget.Lists.first.OnlineCount}',
                                                                  minFontSize:
                                                                      13,
                                                                  maxFontSize:
                                                                      16,
                                                                  style:
                                                                      vehiclePageCardTextStyle,
                                                                ),
                                                              ),
                                                              height: 30,
                                                              width: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            1),
                                                                    blurRadius:
                                                                        4,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.1),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                4.w, 2.h, 0, 0),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                1.5.w,
                                                                0,
                                                                .2.w,
                                                                0),
                                                      )
                                                    : Container(
                                                        child: Center(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                radius: 15,
                                                                child: Image.asset(
                                                                    'images/new-car-icon-red.png'),
                                                              ),
                                                              // height: 20,
                                                              // width: 20,
                                                              // decoration: BoxDecoration(
                                                              //   color: offlineColor,
                                                              //   borderRadius: BorderRadius.circular(5),
                                                              //   boxShadow: [
                                                              //     BoxShadow(
                                                              //       offset: Offset(0, 1),
                                                              //       blurRadius: 4,
                                                              //       color: Colors.black.withOpacity(0.1),
                                                              //     ),
                                                              //   ],
                                                              // ),
                                                            ),
                                                            SizedBox(
                                                              width: 3.w,
                                                            ),
                                                            AutoSizeText(
                                                              "Offline",
                                                              minFontSize: 15,
                                                              maxFontSize: 22,
                                                              style:
                                                                  whiteTextStyle,
                                                            ),
                                                            SizedBox(
                                                              width: 2.w,
                                                            ),
                                                            Container(
                                                              child: Center(
                                                                child:
                                                                    AutoSizeText(
                                                                  '${widget.Lists.first.OfflineCount}',
                                                                  minFontSize:
                                                                      13,
                                                                  maxFontSize:
                                                                      16,
                                                                  style:
                                                                      vehiclePageCardTextStyle,
                                                                ),
                                                              ),
                                                              height: 30,
                                                              width: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            1),
                                                                    blurRadius:
                                                                        4,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.1),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                4.w, 2.h, 0, 0),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                1.5.w,
                                                                0,
                                                                .2.w,
                                                                0),
                                                      ),
                                              ],
                                            ),
                                            widget.status == 'Online'
                                                ? Row(
                                                    children: [
                                                      Container(
                                                        child: Center(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              // height: 20,
                                                              // width: 20,
                                                              // decoration: BoxDecoration(
                                                              //   color: offlineOrangeColor,
                                                              //   borderRadius: BorderRadius.circular(5),
                                                              //   boxShadow: [
                                                              //     BoxShadow(
                                                              //       offset: Offset(0, 1),
                                                              //       blurRadius: 4,
                                                              //       color: Colors.black.withOpacity(0.1),
                                                              //     ),
                                                              //   ],
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                radius: 15,
                                                                child: Image.asset(
                                                                    'images/car-icon-blue-green.png'),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 3.w,
                                                            ),
                                                            AutoSizeText(
                                                              "Moving",
                                                              minFontSize: 15,
                                                              maxFontSize: 22,
                                                              style:
                                                                  whiteTextStyle,
                                                            ),
                                                            SizedBox(
                                                              width: 2.w,
                                                            ),
                                                            Container(
                                                              child: Center(
                                                                child:
                                                                    AutoSizeText(
                                                                  '${widget.Lists.first.MovingCount}',
                                                                  minFontSize:
                                                                      13,
                                                                  maxFontSize:
                                                                      16,
                                                                  style:
                                                                      vehiclePageCardTextStyle,
                                                                ),
                                                              ),
                                                              height: 30,
                                                              width: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            1),
                                                                    blurRadius:
                                                                        4,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.1),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                0, 1.h, 0, 0),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                1.5.w,
                                                                0,
                                                                .2.w,
                                                                0),
                                                      ),
                                                      Container(
                                                        child: Center(
                                                            child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Container(
                                                              // height: 20,
                                                              // width: 20,
                                                              // decoration:
                                                              //     BoxDecoration(
                                                              //   color:
                                                              //       OfflineColor,
                                                              //   borderRadius:
                                                              //       BorderRadius
                                                              //           .circular(
                                                              //               5),
                                                              //   boxShadow: [
                                                              //     BoxShadow(
                                                              //       offset:
                                                              //           Offset(
                                                              //               0,
                                                              //               1),
                                                              //       blurRadius:
                                                              //           4,
                                                              //       color: Colors
                                                              //           .black
                                                              //           .withOpacity(
                                                              //               0.1),
                                                              //     ),
                                                              //   ],
                                                              // ),
                                                              child:
                                                                  CircleAvatar(
                                                                backgroundColor:
                                                                    Colors
                                                                        .transparent,
                                                                radius: 15,
                                                                child: Image.asset(
                                                                    'images/car-icon-blue-dark-green.png'),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: 3.w,
                                                            ),
                                                            AutoSizeText(
                                                              "Stopped",
                                                              minFontSize: 15,
                                                              maxFontSize: 22,
                                                              style:
                                                                  whiteTextStyle,
                                                            ),
                                                            SizedBox(
                                                              width: 2.w,
                                                            ),
                                                            Container(
                                                              child: Center(
                                                                child:
                                                                    AutoSizeText(
                                                                  '${widget.Lists.first.StoppedCount}',
                                                                  minFontSize:
                                                                      13,
                                                                  maxFontSize:
                                                                      16,
                                                                  style:
                                                                      vehiclePageCardTextStyle,
                                                                ),
                                                              ),
                                                              height: 30,
                                                              width: 30,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            30),
                                                                color: Colors
                                                                    .white,
                                                                boxShadow: [
                                                                  BoxShadow(
                                                                    offset:
                                                                        Offset(
                                                                            0,
                                                                            1),
                                                                    blurRadius:
                                                                        4,
                                                                    color: Colors
                                                                        .black
                                                                        .withOpacity(
                                                                            0.1),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )),
                                                        margin:
                                                            EdgeInsets.fromLTRB(
                                                                4.w, 1.h, 0, 0),
                                                        padding:
                                                            EdgeInsets.fromLTRB(
                                                                1.5.w,
                                                                0,
                                                                .2.w,
                                                                0),
                                                      ),
                                                    ],
                                                  )
                                                : Container(),
                                            SizedBox(
                                              height: 2.5.h,
                                            )
                                          ],
                                        ),
                                      ),
                                      //
                                      // SingleChildScrollView(
                                      //   reverse: true,
                                      //   scrollDirection: Axis.horizontal,
                                      //   child: Row(
                                      //     // mainAxisAlignment: MainAxisAlignment.start,
                                      //     // crossAxisAlignment: CrossAxisAlignment.center,
                                      //     children: [
                                      //       Container(
                                      //         child: Center(
                                      //             child: Row(
                                      //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //               children: [
                                      //                 AutoSizeText(
                                      //                   "Total",
                                      //                   minFontSize: 15,
                                      //                   maxFontSize: 22,
                                      //                   style: whiteTextStyle,
                                      //                 ),
                                      //                 Container(
                                      //                   child: Center(
                                      //                     child: AutoSizeText(
                                      //                       '${widget.deviceLocationList.length}',
                                      //                       minFontSize: 13,
                                      //                       maxFontSize: 16,
                                      //                       style: vehiclePageCardTextStyle,
                                      //                     ),
                                      //                   ),
                                      //                   height: 4.4.h,
                                      //                   width: 10.w,
                                      //                   decoration: BoxDecoration(
                                      //                     borderRadius: BorderRadius.circular(50),
                                      //                     color: Colors.white,
                                      //                     boxShadow: [
                                      //                       BoxShadow(
                                      //                         offset: Offset(0, 1),
                                      //                         blurRadius: 4,
                                      //                         color: Colors.black.withOpacity(0.1),
                                      //                       ),
                                      //                     ],
                                      //                   ),
                                      //                 ),
                                      //               ],
                                      //             )),
                                      //         margin: EdgeInsets.fromLTRB(1.5.w, 1.h, 1.5.w, 1.h),
                                      //         padding:  EdgeInsets.fromLTRB(1.5.w, 0, .2.w, 0),
                                      //         height: 6.h,
                                      //         width: 16.3.h,
                                      //         decoration: BoxDecoration(
                                      //           borderRadius: BorderRadius.circular(60),
                                      //           color: Color(0xFF539ADB),
                                      //           boxShadow: [
                                      //             BoxShadow(
                                      //               offset: Offset(0, 1),
                                      //               blurRadius: 4,
                                      //               color: Colors.black.withOpacity(0.3),
                                      //             ),
                                      //           ],
                                      //         ), // child: ,
                                      //       ),
                                      //       widget.status== 'Online'?
                                      //       Container(
                                      //         child: Center(
                                      //             child: Row(
                                      //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //               children: [
                                      //                 AutoSizeText(
                                      //                   "Online",
                                      //                   minFontSize: 15,
                                      //                   maxFontSize: 22,
                                      //                   style: whiteTextStyle,
                                      //                 ),
                                      //                 Container(
                                      //                   child: Center(
                                      //                     child: AutoSizeText(
                                      //                       '${onlinevehicles}',
                                      //                       minFontSize: 13,
                                      //                       maxFontSize: 16,
                                      //                       style: vehiclePageCardTextStyle,
                                      //                     ),
                                      //                   ),
                                      //                   height: 4.4.h,
                                      //                   width: 10.w,
                                      //                   decoration: BoxDecoration(
                                      //                     borderRadius: BorderRadius.circular(60),
                                      //                     color: Colors.white,
                                      //                     boxShadow: [
                                      //                       BoxShadow(
                                      //                         offset: Offset(0, 1),
                                      //                         blurRadius: 4,
                                      //                         color: Colors.black.withOpacity(0.1),
                                      //                       ),
                                      //                     ],
                                      //                   ),
                                      //                 ),
                                      //               ],
                                      //             )),
                                      //         margin: EdgeInsets.fromLTRB(1.5.w, 1.h, 1.5.w, 1.h),
                                      //         padding:  EdgeInsets.fromLTRB(1.5.w, 0, .2.w, 0),
                                      //         height: 6.h,
                                      //         width: 16.3.h,
                                      //         decoration: BoxDecoration(
                                      //           borderRadius: BorderRadius.circular(60),
                                      //           color: onlineColor,
                                      //           boxShadow: [
                                      //             BoxShadow(
                                      //               offset: Offset(0, 1),
                                      //               blurRadius: 4,
                                      //               color: Colors.black.withOpacity(0.3),
                                      //             ),
                                      //           ],
                                      //         ), // child: ,
                                      //       ) : Container(),
                                      //       widget.status!= 'Online'?
                                      //       Container(
                                      //         child: Center(
                                      //             child: Row(
                                      //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //               children: [
                                      //                 AutoSizeText(
                                      //                   "Offline",
                                      //                   minFontSize: 15,
                                      //                   maxFontSize: 22,
                                      //                   style: whiteTextStyle,
                                      //                 ),
                                      //                 Container(
                                      //                   child: Center(
                                      //                     child: AutoSizeText(
                                      //                       '${offline}',
                                      //                       minFontSize: 13,
                                      //                       maxFontSize: 16,
                                      //                       style: vehiclePageCardTextStyle,
                                      //                     ),
                                      //                   ),
                                      //                   height: 4.4.h,
                                      //                   width: 10.w,
                                      //                   decoration: BoxDecoration(
                                      //                     borderRadius: BorderRadius.circular(60),
                                      //                     color: Colors.white,
                                      //                     boxShadow: [
                                      //                       BoxShadow(
                                      //                         offset: Offset(0, 1),
                                      //                         blurRadius: 4,
                                      //                         color: Colors.black.withOpacity(0.1),
                                      //                       ),
                                      //                     ],
                                      //                   ),
                                      //                 ),
                                      //               ],
                                      //             )),
                                      //         margin: EdgeInsets.fromLTRB(0, 1.h, 1.w, 1.h),
                                      //         padding:  EdgeInsets.fromLTRB(1.5.w, 0, .2.w, 0),
                                      //         height: 6.h,
                                      //         width: 16.3.h,
                                      //         decoration: BoxDecoration(
                                      //           borderRadius: BorderRadius.circular(60),
                                      //           color: offlineColor,
                                      //           boxShadow: [
                                      //             BoxShadow(
                                      //               offset: Offset(0, 1),
                                      //               blurRadius: 4,
                                      //               color: Colors.black.withOpacity(0.3),
                                      //             ),
                                      //           ],
                                      //         ), // child: ,
                                      //       ) : Container(),
                                      //     ],
                                      //   ),
                                      // ),
                                      // widget.status== 'Online' ?
                                      // SingleChildScrollView(
                                      //   scrollDirection: Axis.horizontal,
                                      //   child: Row(
                                      //     // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //     children: [
                                      //       Container(
                                      //         child: Center(
                                      //             child: Row(
                                      //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //
                                      //               children: [
                                      //                 AutoSizeText(
                                      //                   "Moving",
                                      //                   minFontSize: 15,
                                      //                   maxFontSize: 22,
                                      //                   style: whiteTextStyle,
                                      //                 ),
                                      //                 Container(
                                      //                   child: Center(
                                      //                     child: AutoSizeText(
                                      //                       "${movingvehicles}",
                                      //                       minFontSize: 13,
                                      //                       maxFontSize: 16,
                                      //                       style: vehiclePageCardTextStyle,
                                      //                     ),
                                      //                   ),
                                      //                   height: 4.4.h,
                                      //                   width: 10.w,
                                      //                   decoration: BoxDecoration(
                                      //                     borderRadius: BorderRadius.circular(50),
                                      //                     color: Colors.white,
                                      //                     boxShadow: [
                                      //                       BoxShadow(
                                      //                         offset: Offset(0, 1),
                                      //                         blurRadius: 4,
                                      //                         color: Colors.black.withOpacity(0.1),
                                      //                       ),
                                      //                     ],
                                      //                   ),
                                      //                 ),
                                      //               ],
                                      //             )),
                                      //         margin: EdgeInsets.fromLTRB(0, 1.h, 2.w, 1.h),
                                      //         padding:  EdgeInsets.fromLTRB(1.5.w, 0, .2.w, 0),
                                      //         height: 6.h,
                                      //         width: 16.3.h,
                                      //         decoration: BoxDecoration(
                                      //           borderRadius: BorderRadius.circular(60),
                                      //           color: OfflineColor,
                                      //           boxShadow: [
                                      //             BoxShadow(
                                      //               offset: Offset(0, 1),
                                      //               blurRadius: 4,
                                      //               color: Colors.black.withOpacity(0.3),
                                      //             ),
                                      //           ],
                                      //         ), // child: ,
                                      //       ),
                                      //       Container(
                                      //         child: Center(
                                      //             child: Row(
                                      //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      //               children: [
                                      //                 AutoSizeText(
                                      //                   "Stopped",
                                      //                   minFontSize: 15,
                                      //                   maxFontSize: 22,
                                      //                   style: whiteTextStyle,
                                      //                 ),
                                      //                 Container(
                                      //                   child: Center(
                                      //                     child: AutoSizeText(
                                      //                       '${onlinevehicles- movingvehicles}',
                                      //                       minFontSize: 13,
                                      //                       maxFontSize: 16,
                                      //                       style: vehiclePageCardTextStyle,
                                      //                     ),
                                      //                   ),
                                      //                   height: 4.4.h,
                                      //                   width: 10.w,
                                      //                   decoration: BoxDecoration(
                                      //                     borderRadius: BorderRadius.circular(50),
                                      //                     color: Colors.white,
                                      //                     boxShadow: [
                                      //                       BoxShadow(
                                      //                         offset: Offset(0, 1),
                                      //                         blurRadius: 4,
                                      //                         color: Colors.black.withOpacity(0.1),
                                      //                       ),
                                      //                     ],
                                      //                   ),
                                      //                 ),
                                      //               ],
                                      //             )),
                                      //         margin: EdgeInsets.fromLTRB(1.5.w, 1.h, 1.5.w, 1.h),
                                      //         padding:  EdgeInsets.fromLTRB(1.5.w, 0, .2.w, 0),
                                      //         height: 6.h,
                                      //         width: 16.3.h,
                                      //         decoration: BoxDecoration(
                                      //           borderRadius: BorderRadius.circular(60),
                                      //           color: OfflineColor,
                                      //           boxShadow: [
                                      //             BoxShadow(
                                      //               offset: Offset(0, 1),
                                      //               blurRadius: 4,
                                      //               color: Colors.black.withOpacity(0.3),
                                      //             ),
                                      //           ],
                                      //         ), // child: ,
                                      //       ),
                                      //     ],
                                      //   ),
                                      // ) : Text("")
                                    ],
                                  )
                                : Container()),
                        // SizedBox(height: 16),

                        // SizedBox(child: Text(data[0])),
                      ],
                    ),
                  ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          height: MediaQuery.of(context).size.height * .06,
                          // width: 95.w,
                          // padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                          decoration: BoxDecoration(
                            color: searchBoxColorWhite,
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: TextField(
                            controller: searchController,
                            decoration: InputDecoration(
                                prefixIcon:
                                    Icon(Icons.search, color: Colors.black),
                                suffixIcon: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        searchController.clear();
                                        _searchResult = '';
                                        filteredVehicles = totalVehicle;
                                      });
                                    },
                                    child: Icon(Icons.cancel,
                                        color: Colors.black)),
                                hintText: 'Search',
                                hintStyle: TextStyle(color: Colors.black),
                                border: InputBorder.none),
                            onChanged: (value) async => _runFilter(value),
                          ),
                        ),
                      ),
                      // Container(
                      //   padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                      //   width: 25.w,
                      //   child: Row(
                      //     children: [
                      //       Text("Filter"),
                      //       Icon(Icons.arrow_downward_rounded),
                      //     ],
                      //   ),
                      // )
                    ],
                  ),
                  Expanded(
                    child: Container(
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                        // height: widget.status== 'Online' ? 70.h : 76.h,
                        // MediaQuery.of(context).size.height * .79 :
                        // MediaQuery.of(context).size.height * .71,
                        child:
                            // totalVehicle.length != 0
                            //     ?

                            ListView.builder(
                                itemCount: filteredVehicles.length,
                                itemBuilder: (context, index) {
                                  return SingleChildScrollView(
                                    scrollDirection: Axis.vertical,
                                    child: Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 0, 13),
                                      width: MediaQuery.of(context).size.width *
                                          .93,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFFFFF),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black38,
                                                  width: 2.0,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(12)),
                                            child: Column(
                                              children: [
                                                SizedBox(
                                                  height: 10,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'Vehicle Name'),
                                                      ),
                                                    ),
                                                    Container(
                                                      width:
                                                          MediaQuery.of(context)
                                                                  .size
                                                                  .width *
                                                              .45,
                                                      child: Row(
                                                        children: [
                                                          Padding(
                                                            padding: EdgeInsets
                                                                .fromLTRB(
                                                                    5, 0, 5, 0),
                                                            child: Container(
                                                              child:
                                                                  Image.asset(
                                                                filteredVehicles[index]["DeviceStatus"] ==
                                                                            "Offline" &&
                                                                        filteredVehicles[index]["VehicleType"] ==
                                                                            "Car"
                                                                    ? 'images/new-car-icon-red.png'
                                                                    : filteredVehicles[index]["DeviceStatus"] ==
                                                                                "Offline" &&
                                                                            filteredVehicles[index]["VehicleType"] ==
                                                                                "Bus"
                                                                        ? 'images/bus-red.png'
                                                                        : filteredVehicles[index]["DeviceStatus"] == "Offline" &&
                                                                                filteredVehicles[index]["VehicleType"] == "Truck"
                                                                            ? "images/truckred.png"
                                                                            : filteredVehicles[index]["DeviceStatus"] == "Offline" && filteredVehicles[index]["VehicleType"] == "Special"
                                                                                ? "images/special-red.png"
                                                                                : filteredVehicles[index]["VehicleStatus"].toString() == "Moving" && filteredVehicles[index]["VehicleType"] == "Car"
                                                                                    ? 'images/car-icon-blue-green.png'
                                                                                    : filteredVehicles[index]["VehicleStatus"].toString() == "Stop" && filteredVehicles[index]["VehicleType"] == "Car"
                                                                                        ? 'images/car-icon-blue-dark-green.png'
                                                                                        : filteredVehicles[index]["VehicleStatus"].toString() == "Moving" && filteredVehicles[index]["VehicleType"] == "Bus"
                                                                                            ? 'images/bus-blue-gree.png'
                                                                                            : filteredVehicles[index]["VehicleStatus"].toString() == "Stop" && filteredVehicles[index]["VehicleType"] == "Bus"
                                                                                                ? 'images/bus-dark-blue-green.png'
                                                                                                : filteredVehicles[index]["VehicleStatus"].toString() == "Moving" && filteredVehicles[index]["VehicleType"] == "Truck"
                                                                                                    ? 'images/truck-blue-green.png'
                                                                                                    : filteredVehicles[index]["VehicleStatus"].toString() == "Stop" && filteredVehicles[index]["VehicleType"] == "Truck"
                                                                                                        ? 'images/truck-darkblue-green.png'
                                                                                                        : filteredVehicles[index]["VehicleStatus"].toString() == "Moving" && filteredVehicles[index]["VehicleType"] == "Special"
                                                                                                            ? 'images/common-icon-green-blue.png'
                                                                                                            : 'images/common-icon-green-dark.png',
                                                                width: 35,
                                                                height: 35,
                                                                fit:
                                                                    BoxFit.fill,
                                                              ),
                                                            ),
                                                          ),
                                                          Container(
                                                            width: MediaQuery.of(
                                                                        context)
                                                                    .size
                                                                    .width *
                                                                .32,
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                filteredVehicles[index]
                                                                            [
                                                                            "VehicleName"] !=
                                                                        null
                                                                    ? filteredVehicles[index]
                                                                            [
                                                                            "VehicleName"]
                                                                        .toString()
                                                                    : "--",
                                                                style:
                                                                    vehiclePageCardTextSubHeadStyle,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  thickness: 2.0,
                                                  color: Colors.black12,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'Vehicle Type'),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "VehicleType"] !=
                                                                  null
                                                              ? filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "VehicleType"]
                                                                  .toString()
                                                              : "--",
                                                          style:
                                                              vehiclePageCardTextSubHeadStyle,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  thickness: 2.0,
                                                  color: Colors.black12,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'Vehicle Model'),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "VehicleModel"] !=
                                                                  null
                                                              ? filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "VehicleModel"]
                                                                  .toString()
                                                              : "--",
                                                          style:
                                                              vehiclePageCardTextSubHeadStyle,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  thickness: 2.0,
                                                  color: Colors.black12,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'Vehicle License Plate'),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "VehicleLicensePlate"] !=
                                                                  null
                                                              ? filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "VehicleLicensePlate"]
                                                                  .toString()
                                                              : "--",
                                                          style:
                                                              vehiclePageCardTextSubHeadStyle,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  thickness: 2.0,
                                                  color: Colors.black12,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'Device Status'),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "DeviceStatus"] !=
                                                                  null
                                                              ? filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "DeviceStatus"]
                                                                  .toString()
                                                              : "--",
                                                          style:
                                                              vehiclePageCardTextSubHeadStyle,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  thickness: 2.0,
                                                  color: Colors.black12,
                                                ),
                                                Row(
                                                  // crossAxisAlignment: CrossAxisAlignment.center,
                                                  // mainAxisAlignment: MainAxisAlignment.start,
                                                  children: [
                                                    Container(
                                                      width: 46.w,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'Vehicle Moving Status'),
                                                      ),
                                                    ),
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Container(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "VehicleStatus"] !=
                                                                  null
                                                              ? filteredVehicles[index]
                                                                              [
                                                                              "VehicleStatus"]
                                                                          .toString() ==
                                                                      "Moving"
                                                                  ? "Moving"
                                                                  : "Stop"
                                                              : "Offline",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color:
                                                                  Colors.white,
                                                              height: 1),
                                                        ),
                                                        decoration:
                                                            BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            15),
                                                                color: filteredVehicles[index]
                                                                            [
                                                                            "VehicleStatus"] !=
                                                                        null
                                                                    ? filteredVehicles[index]["VehicleStatus"].toString() ==
                                                                            "Moving"
                                                                        ? buttonColourBlue
                                                                        : stoppedColor
                                                                    : offlineColor),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Divider(
                                                  thickness: 2.0,
                                                  color: Colors.black12,
                                                ),
                                                Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                            'Last Reported Time'),
                                                      ),
                                                    ),
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "LastReportedTime"] !=
                                                                  null
                                                              ? filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "LastReportedTime"]
                                                                  .toString()
                                                              : "--",
                                                          style:
                                                              vehiclePageCardTextSubHeadStyle,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                widget.status == 'Online'
                                                    ? Divider(
                                                        thickness: 2.0,
                                                        color: Colors.black12,
                                                      )
                                                    : Container(),
                                                widget.status == 'Online'
                                                    ? GestureDetector(
                                                        onTap: () async {
                                                          ByteData
                                                              byteDatacurrent =
                                                              await DefaultAssetBundle
                                                                      .of(
                                                                          context)
                                                                  .load(
                                                                      "images/navigation-marker.png");
                                                          urlList2 =
                                                              byteDatacurrent
                                                                  .buffer
                                                                  .asUint8List();
                                                          print(
                                                              "Selected Vehicle details: ${filteredVehicles[index]}");
                                                          deviceID =
                                                              filteredVehicles[
                                                                      index]
                                                                  ["DeviceId"];
                                                          vehicleName =
                                                              filteredVehicles[
                                                                      index][
                                                                  "VehicleName"];
                                                          if (filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "Lati"] !=
                                                                  null &&
                                                              filteredVehicles[
                                                                          index]
                                                                      [
                                                                      "Long"] !=
                                                                  null) {
                                                            var data = {
                                                              "lat":
                                                                  filteredVehicles[
                                                                          index]
                                                                      ["Lati"],
                                                              "lng":
                                                                  filteredVehicles[
                                                                          index]
                                                                      ["Long"]
                                                            };
                                                            SelectedVehCoords =
                                                                data;
                                                            getCurrentLocation();
                                                            print("SelectedVehicleCoordinates" +
                                                                SelectedVehCoords
                                                                    .toString());
                                                            Navigator.push(
                                                              context,
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) =>
                                                                          CurrentLocationMap()),
                                                            );
                                                          } else {
                                                            print(
                                                                "Coordinates null");
                                                          }
                                                        },
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child: Text(
                                                                    'Track Vehicle'),
                                                              ),
                                                            ),
                                                            Expanded(
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets
                                                                        .all(
                                                                            8.0),
                                                                child: Icon(
                                                                  Icons
                                                                      .trending_up,
                                                                  color:
                                                                      blackColor,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      )
                                                    : Container(),
                                                SizedBox(
                                                  height: 15,
                                                )
                                                // Add more rows as needed
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                })
                        // : Center(child: Text("No data to show"))
                        ),
                  ),
                ],
              )
            : Center(child: Text("No data to show")));
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
}

class Vehicles {
  var VehicleName;
  var VehicleType;
  var VehicleSubType;
  var VehicleModel;
  var VehicleLicensePlate;
  var VehicleStatus;
  var TrackingDevice;
  var LastReportedTime;
  var VehicleId;
  var MovingStatus;
  var DeviceStatus;

  Vehicles(
      {required this.VehicleStatus,
      required this.VehicleModel,
      required this.LastReportedTime,
      required this.VehicleName,
      required this.VehicleType,
      required this.TrackingDevice,
      required this.VehicleSubType,
      required this.VehicleLicensePlate,
      required this.VehicleId,
      required this.DeviceStatus,
      required this.MovingStatus});
}

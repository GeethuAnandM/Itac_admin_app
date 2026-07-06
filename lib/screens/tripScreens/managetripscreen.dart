import 'dart:async';
import 'dart:io';
import 'package:admin_app/screens/sidebar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../api/api.dart';
import '../../languges/language_constants.dart';
import '../tracking_screen/live_track.dart';
import '../tracking_screen/vehicletracking.dart';
import 'TripTrackHistoryScreen.dart';
import 'TripTrackLiveScreen.dart';
import 'addTripscreen.dart';
import 'editTripScreen.dart';
import '../themes.dart';
import 'switchVehicleScreen.dart';

Color? color;

class manageTripScreen extends StatefulWidget {
  // manageTripScreen({required this.tripDetails});
  // List<dynamic> tripDetails = [];
  @override
  State<manageTripScreen> createState() => _manageTripScreenState();
}

class _manageTripScreenState extends State<manageTripScreen> {
  var dateFormat1 = DateFormat("dd-MM-yyyy HH:mm");
  var errormessage;
  bool isError = false;
  bool isItLoading = false;
  String _searchResult = '';
  List<Map<dynamic, dynamic>> dataOfTripsList = [];
  var deleteconfirmed = false;
  var deleted = false;
  var success;
  var clickeddeleteButton = false;
  var erroroccured = false;
  var deleteStatusCode;
  var loader = true;
  var totVehicleList = [];
  var searchController = TextEditingController();
  List<Map<dynamic, dynamic>> tripListData = [];
  bool isHomePageSelected = true;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: const BorderRadius.all(const Radius.circular(13)),
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

  getTripDatas() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var Id = userId == null ? prefs.getString("org_id") : int.parse(userId);
    DateTime now = DateTime.now();
    try {
      var data = {
        "ids": [],
        "userId": userId,
        "isDetailed": true
        // "fromTime": "2010-04-03 18:30:00",
        // "toTime": DateFormat('yyyy-MM-dd HH:mm:ss').format(now)
      };
      // print(data);
      // print("data");
      final url = "${baseUrl}trips/user-trips";
      var dio = Dio();
      final response = await dio.post(url, data: data);
      tripListData.clear();
      // print("res${response.data['list']}");
      for (var i = 0; i < response.data['list'].length; i++) {
        tripListData.add(response.data['list'][i]);
      }
      // print(" data is here ${tripListData[0]['onwardStartDateTime']}");
      // print('triplist:${tripListData}');
      // print('length:${tripListData.length}');
      // print("returnend:${tripListData[0]['actualEndTime']}");
      // print("starttime:${tripListData[0]['actualStartTime']}");
      // print(tripListData.runtimeType);
      print("TripListData: ${tripListData[0]}");
      return tripListData;
    } on SocketException {
      setState(() {
        isItLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print("error from getdata: $e");
    }
  }

  List<Map<String, dynamic>> listTrip = [];

  List<Widget> Addtrip() {
    // print("length of the list is:${tripListData.length}");
    var fullname;
    for (var i = 0; i < tripListData.length; i++) {
      tripListData[i]['driverFirstName'] == null ||
              tripListData[i]['driverFirstName'] == ''
          ? fullname = "Not Available"
          : fullname = tripListData[i]['driverFirstName'];
      tripListData[i]['driverMiddleName'] == null ||
              tripListData[i]['driverMiddleName'] == ''
          ? fullname = fullname + ""
          : fullname = fullname + " " + tripListData[i]['driverMiddleName'];
      tripListData[i]['driverLastName'] == null ||
              tripListData[i]['driverLastName'] == ''
          ? fullname = fullname + ""
          : fullname = fullname + " " + tripListData[i]['driverLastName'];
      // print("full:$fullname");
      var sdate = "--";
      var edate = "--";
      var resdate = "--";
      var reedate = "--";
      var actualsdate = "--";
      var actualedate = "--";
      var reactualsdate = "--";
      var reactualedate = "--";

      if (tripListData[i]['expectedStartTime'] != null) {
        DateTime startdate = DateFormat("yyyy-MM-dd HH:mm")
            .parse(tripListData[i]['expectedStartTime'] ?? "")
            .toLocal();
        sdate = dateFormat1.format(startdate);
      }
      if (tripListData[i]["expectedEndTime"] != null) {
        DateTime enddate = DateFormat("yyyy-MM-dd HH:mm")
            .parse(tripListData[i]["expectedEndTime"] ?? "")
            .toLocal();
        edate = dateFormat1.format(enddate);
      }
      if (tripListData[i]['returnStartTime'] != null) {
        DateTime restartdate = DateFormat("yyyy-MM-dd HH:mm")
            .parse(tripListData[i]['returnStartTime'] ?? "")
            .toLocal();
        resdate = dateFormat1.format(restartdate);
      }
      if (tripListData[i]['returnEndDateTime'] != null) {
        DateTime reenddate = DateFormat("yyyy-MM-dd HH:mm")
            .parse(tripListData[i]['returnEndDateTime'] ?? "")
            .toLocal();
        reedate = dateFormat1.format(reenddate);
      }
      if (tripListData[i]['actualStartTime'] != null) {
        DateTime onactualstartdate = DateFormat("yyyy-MM-dd HH:mm")
            .parse(tripListData[i]['actualStartTime'] ?? "")
            .toLocal();
        actualsdate = dateFormat1.format(onactualstartdate);
      }
      if (tripListData[i]['actualEndTime'] != null) {
        DateTime onactualenddate = DateFormat("yyyy-MM-dd HH:mm")
            .parse(tripListData[i]['actualEndTime'] ?? "")
            .toLocal();
        actualedate = dateFormat1.format(onactualenddate);
      }
      if (tripListData[i]['returnActualStartTime'] != null) {
        DateTime reactualstartdate = DateFormat("yyyy-MM-dd HH:mm")
            .parse(tripListData[i]['returnActualStartTime'] ?? "")
            .toLocal();
        reactualsdate = dateFormat1.format(reactualstartdate);
      }
      if (tripListData[i]['returnActualEndTime'] != null) {
        DateTime reactualenddate = DateFormat("yyyy-MM-dd HH:mm")
            .parse(tripListData[i]['returnActualEndTime'] ?? "")
            .toLocal();
        reactualedate = dateFormat1.format(reactualenddate);
      }
      // print('actualsdate${tripListData[i]['onwardActualStartTime']}');
      listTrip.add(
        {
          "uuid": tripListData[i]['uuid'] ?? "___",
          "tripId": tripListData[i]['tripId'] ?? "___",
          "tripId": tripListData[i]['tripId'] ?? "___",
          "tripName": tripListData[i]['tripName'] ?? "___",
          "vehicleId": tripListData[i]["vehicleId"] ?? "___",
          "vehicleName": tripListData[i]['vehicleName'] ?? "___",
          "driverName": fullname ?? "Not Available",
          "driverImage": tripListData[i]['driverImage'] ?? '___',
          "tripStatus": tripListData[i]['tripStatus'] ?? "___",
          "plannedorunplanned":
              tripListData[i]['tripStatus'].toString() == "Default"
                  ? "unplanned"
                  : "planned",
          "isRecurring": tripListData[i]['isRecurring'] ?? "___",
          "category": tripListData[i]['category'] ?? "___",
          "expectedStartTime": sdate ?? "___",
          "expectedEndTime": edate ?? "___",
          "returnStartDateTime": resdate ?? "___",
          "returnEndDateTime": reedate ?? "___",
          "actualStartTime": actualsdate ?? "___",
          "actualEndTime": actualedate ?? "___",
          "returnActualStartDateTime": reactualsdate ?? "___",
          "returnActualEndDateTime": reactualedate ?? "___",
          "baseStartLat": tripListData[i]['baseStartLat'] ?? "___",
          "baseStartLong": tripListData[i]['baseStartLong'] ?? "___",
          "baseEndLat": tripListData[i]["baseEndLat"] ?? "___",
          "baseEndLong": tripListData[i]["baseEndLong"] ?? "___",
          "deviceId": tripListData[i]['deviceId'] ?? "___",
        },
      );
    }
    // print("trips $ListTrip");
    setState(() {
      listTrip = listTrip;
    });
    List<Widget> Demo = [];
    return Demo;
  }

  @override
  void initState() {
    () async {
      await getTripDatas();
      await Addtrip();
      setState(() {
        loader = false;
        isItLoading = true;
        tripListData = tripListData;
        dataOfTripsList = listTrip;
      });
    }();
    super.initState();
  }

  void searchFun(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      setState(() {
        results = listTrip;
        // usersFiltered = results;
      });
    } else {
      // print("list trip $ListTrip");
      // print("tripName ${ListTrip.where((trip) => trip["tripName"].toBool())}");
      results = listTrip
          .where((person) =>
              person["tripName"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["category"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
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
              person["expectedStartTime"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["expectedEndTime"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["actualStartTime"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["actualEndTime"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["returnStartDateTime"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["returnEndDateTime"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["tripStatus"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["uuid"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")))
          .toList();
      // if (results.isEmpty) {
      //   setState(() {
      //     loader = true;
      //   });
      // } else {
      //   setState(() {
      //     loader = false;
      //   });
      // }
    }
    // // Refresh the UI
    setState(() {
      dataOfTripsList = results;
    });
  }

  void showSnackBar(BuildContext context, String title) {
    final snackBar = SnackBar(
      content: Text(title),
      margin: EdgeInsets.only(
        bottom: 200,
        right: 20,
        left: 20,
      ),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: '',
        disabledTextColor: Colors.white,
        textColor: Colors.yellow,
        onPressed: () {
          //Do whatever you want
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  Future<List<dynamic>> deleteTrips(
      BuildContext ctx, var tripId, var recurring) async {
    // print(tripId);
    // print(recurring);
    if (recurring == null || recurring == "___") {
      recurring = false;
    }
    setState(() {
      // print("try 1 st deletion${deleteconfirmed}");
    });
    final url = "${baseUrl}/trips/delete-trip/$tripId/$recurring";
    var dio = Dio();
    try {
      final response = await dio.delete(url);
      // print(response.data);
      // print("statuscode:${response.statusCode}");
      if (response.statusCode == 200 || response.statusCode == 201) {
        showSnackBar(ctx, response.data['message']);
      } else {
        showSnackBar(ctx, response.data['message']);
      }
      setState(() {
        deleteStatusCode = response.statusCode;
        deleteconfirmed = true;
      });
      route() {
        setState(() {
          clickeddeleteButton = false;
          deleteconfirmed = false;
          // print("this line will execute after 4 seconds");
        });
      }

      // startTimer() async {
      //   var duration = Duration(seconds: 0);
      //   return Timer(duration, route);
      // }
      //
      // await startTimer();
    } on DioError catch (e) {
      print("errroror ${e.response?.data}");
      setState(() {
        var erroroccured = true;
        deleteconfirmed = false;
        deleteStatusCode = 400;
        if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
          showSnackBar(ctx, e.response?.data['message']);
        }
      });
    }
    return totVehicleList;
  }

  showAlertDialog(
      {required BuildContext context,
      required int tripId,
      var recurring,
      required String tripName}) {
    Widget continueButton = TextButton(
      child: Text("Delete"),
      onPressed: () async {
        await deleteTrips(context, tripId, recurring);
        // print("tripdelete:$tripId");
        // print("recuuringdelete:$recurring");
        if (deleteconfirmed == true) {
          Navigator.pop(context);
          final tripDetails = await getTripDatas();
          route() {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => manageTripScreen()),
            );
            setState(() {
              clickeddeleteButton = false;
              deleteconfirmed = false;
            });
          }

          startTimer() async {
            var duration = Duration(seconds: 3);
            return Timer(duration, route);
          }

          await startTimer();
        } else {
          Navigator.pop(context);
        }
      },
    );
    Widget cancelButton = TextButton(
      child: Text("Cancel"),
      onPressed: () {
        Navigator.pop(context);
      },
    );

    // set up the AlertDialog
    AlertDialog alert = AlertDialog(
      content: Text(
          "Trips will be deleted from the system. Do you want to delete the Trip ${tripName.toString()}?"),
      actions: [
        continueButton,
        cancelButton,
      ],
    );

    // show the dialog,
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    print("in build");
    return Scaffold(
      key: _key,
      drawer: const NavBar(),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            centerTitle: true,
            leading:
                Padding(padding: EdgeInsets.only(top: 15), child: _appBar()),
            title: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(translation(context).manageTrips)),
            elevation: 0,
          )),
      backgroundColor: const Color(0xFFEAEAEA),
      body: Container(
          color: const Color(0xFFEAEAEA),
          child: Scaffold(
            floatingActionButton: FloatingActionButton(
              shape: CircleBorder(),
              child: const Icon(
                Icons.add,
                color: commonTextStyle,
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddTripScreen()),
                );
              },
            ),
            body: SingleChildScrollView(
              child: Column(children: [
                Container(
                  height: MediaQuery.of(context).size.height * .12,
                  decoration: BoxDecoration(
                    color: buttonColourBlue,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: MediaQuery.of(context).size.height * .06,
                            width: MediaQuery.of(context).size.width * .96,
                            // padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                            decoration: BoxDecoration(
                              color: searchBoxColorWhite,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: GestureDetector(
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Container(
                                    height: 100,
                                    width: 340,
                                    child: TextField(
                                      controller: searchController,
                                      decoration: InputDecoration(
                                          prefixIcon: Icon(
                                            Icons.search,
                                            color: Colors.black,
                                          ),
                                          suffixIcon: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  searchController.clear();
                                                  _searchResult = '';
                                                  dataOfTripsList = listTrip;
                                                });
                                              },
                                              child: Icon(
                                                Icons.cancel,
                                                color: Colors.black,
                                              )),
                                          hintText: 'Search',
                                          hintStyle:
                                              TextStyle(color: Colors.black),
                                          border: InputBorder.none),
                                      onChanged: (value) async =>
                                          searchFun(value),
                                    ),
                                  ),
                                  // Text('Search', style: manageVehiclePageSearchTextStyle,),
                                  // searchIcon
                                ],
                              ),
                            ),
                          )
                        ],
                      )
                    ],
                  ),
                ),
                SizedBox(height: 14),
                Container(
                  padding: EdgeInsets.fromLTRB(5, 0, 5, 0),
                  height: MediaQuery.of(context).size.height *
                      .800, // container size
                  child: isError == true
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              LottieBuilder.asset(
                                "images/82529-no-network.json",
                              ),
                              Text(errormessage ?? "No Internet connection"),
                            ],
                          ),
                        )
                      : loader
                          ? Center(
                              child: CircularProgressIndicator(
                                semanticsLabel: "right",
                              ),
                            )
                          : dataOfTripsList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      LottieBuilder.asset(
                                          "images/no-data-found.json"),
                                      const Text("No Data available"),
                                      const SizedBox(
                                        height: 20,
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  itemCount: dataOfTripsList.length,
                                  separatorBuilder: (context, index) {
                                    // print(
                                    //     "driver:${dataOfTripsList[index]["tripStatus"]}");
                                    return const SizedBox(
                                      height: 5,
                                    );
                                  },
                                  itemBuilder: (context, index) {
                                    String _onwardstartdate = "";
                                    if (dataOfTripsList[index]["tripStatus"] ==
                                        "Default") {
                                      // print(
                                      //     "onward time ${tripData[index]["onwardStartDateTime"]}");
                                      if (dataOfTripsList[index]
                                                      ["expectedStartTime"]
                                                  .toString() !=
                                              "--" &&
                                          dataOfTripsList[index]
                                                  ["expectedStartTime"] !=
                                              null) {
                                        DateTime onwardstart1 =
                                            DateFormat("dd-MM-yyyy HH:mm")
                                                .parse(dataOfTripsList[index]
                                                    ["expectedStartTime"])
                                                .add(const Duration(
                                                    hours: 5, minutes: 30));

                                        // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
                                        _onwardstartdate =
                                            DateFormat("dd-MM-yyyy hh:mm a")
                                                .format(onwardstart1);
                                      } else {
                                        _onwardstartdate = "---";
                                      }
                                    } else {
                                      if (dataOfTripsList[index]
                                              ["expectedStartTime"] !=
                                          null) {
                                        // print(
                                        //     "${tripData[index]["status"]}");
                                        DateTime onwardstart1 =
                                            DateFormat("dd-MM-yyyy HH:mm")
                                                .parse(dataOfTripsList[index]
                                                    ["expectedStartTime"])
                                                .add(const Duration(
                                                    hours: 5, minutes: 30));

                                        // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
                                        _onwardstartdate =
                                            DateFormat("dd-MM-yyyy hh:mm a")
                                                .format(onwardstart1);
                                        // print("before converted" +
                                        //     tripData[index]
                                        //     ["onwardStartDateTime"]);
                                        // print(
                                        //     "after converted$_onwardstartdate");
                                      } else {
                                        _onwardstartdate = "---";
                                      }
                                    }

                                    String _onwardenddate = "";
                                    if (dataOfTripsList[index]["tripStatus"] ==
                                        "Default") {
                                      // print(
                                      //     "onward time ${tripData[index]["onwardEndDateTime"]}");
                                      if (dataOfTripsList[index]
                                                      ["expectedEndTime"]
                                                  .toString() !=
                                              "--" &&
                                          dataOfTripsList[index]
                                                  ["expectedEndTime"] !=
                                              null) {
                                        DateTime onwardend1 =
                                            DateFormat("dd-MM-yyyy HH:mm")
                                                .parse(dataOfTripsList[index]
                                                    ["expectedEndTime"])
                                                .add(const Duration(
                                                    hours: 5, minutes: 30));

                                        // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
                                        _onwardenddate =
                                            DateFormat("dd-MM-yyyy hh:mm a")
                                                .format(onwardend1);
                                      } else {
                                        _onwardenddate = "---";
                                      }
                                    } else {
                                      if (dataOfTripsList[index]
                                              ["expectedEndTime"] !=
                                          null) {
                                        // print(
                                        //     "${tripData[index]["status"]}");
                                        DateTime onwardend1 =
                                            DateFormat("dd-MM-yyyy HH:mm")
                                                .parse(dataOfTripsList[index]
                                                    ["expectedEndTime"])
                                                .add(const Duration(
                                                    hours: 5, minutes: 30));

                                        // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
                                        _onwardenddate =
                                            DateFormat("dd-MM-yyyy hh:mm a")
                                                .format(onwardend1);
                                        // print("before converted" +
                                        //     tripData[index]
                                        //     ["onwardEndDateTime"]);
                                        // print(
                                        //     "after converted$_onwardenddate");
                                      } else {
                                        _onwardenddate = "---";
                                      }
                                    }
                                    // print(tripData[index]
                                    // ["returnStartDateTime"]);
                                    String _returnstartdate = "";
                                    if (dataOfTripsList[index]
                                                ["returnStartDateTime"] !=
                                            null &&
                                        dataOfTripsList[index]
                                                    ["returnStartDateTime"]
                                                .toString() !=
                                            '--') {
                                      DateTime returnstart1 =
                                          DateFormat("dd-MM-yyyy HH:mm")
                                              .parse(dataOfTripsList[index]
                                                  ["returnStartDateTime"])
                                              .add(const Duration(
                                                  hours: 5, minutes: 30));
                                      // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
                                      _returnstartdate =
                                          DateFormat("dd-MM-yyyy hh:mm a")
                                              .format(returnstart1);
                                      // print("before converted" +
                                      //     tripData[index]
                                      //     ["returnStartDateTime"]);
                                      // print(
                                      //     "after converted$_returnstartdate");
                                    } else {
                                      _returnstartdate = "---";
                                    }

                                    String _returnenddate = "";
                                    if (dataOfTripsList[index]
                                                ["returnEndDateTime"] !=
                                            null &&
                                        dataOfTripsList[index]
                                                ["returnEndDateTime"] !=
                                            "--") {
                                      DateTime returnend1 =
                                          DateFormat("dd-MM-yyyy HH:mm")
                                              .parse(dataOfTripsList[index]
                                                  ["returnEndDateTime"])
                                              .add(const Duration(
                                                  hours: 5, minutes: 30));
                                      // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
                                      _returnenddate =
                                          DateFormat("dd-MM-yyyy hh:mm a")
                                              .format(returnend1);
                                      // print("before converted" +
                                      //     tripData[index]
                                      //     ["returnEndDateTime"]);
                                      // print(
                                      //     "after converted$_returnenddate");
                                    } else {
                                      _returnenddate = "---";
                                    }

                                    String _actualstartdate = "";
                                    if (dataOfTripsList[index]
                                                ["actualStartTime"] !=
                                            null &&
                                        dataOfTripsList[index]
                                                ["actualStartTime"] !=
                                            "--") {
                                      DateTime actualstart1 =
                                          DateFormat("dd-MM-yyyy HH:mm").parse(
                                              dataOfTripsList[index]
                                                  ["actualStartTime"]);
                                      _actualstartdate =
                                          DateFormat("dd-MM-yyyy hh:mm a")
                                              .format(actualstart1);
                                    } else {
                                      _actualstartdate = "---";
                                    }

                                    String _actualenddate = "";
                                    if (dataOfTripsList[index]
                                                ["actualEndTime"] !=
                                            null &&
                                        dataOfTripsList[index]
                                                ["actualEndTime"] !=
                                            "--") {
                                      DateTime actualend1 =
                                          DateFormat("dd-MM-yyyy HH:mm").parse(
                                              dataOfTripsList[index]
                                                  ["actualEndTime"]);
                                      _actualenddate =
                                          DateFormat("dd-MM-yyyy hh:mm a")
                                              .format(actualend1);
                                    } else {
                                      _actualenddate = "---";
                                    }
                                    String _actualreturnstartdate = "";
                                    if (dataOfTripsList[index]
                                                ["returnActualStartDateTime"] !=
                                            null &&
                                        dataOfTripsList[index]
                                                ["returnActualStartDateTime"] !=
                                            "--") {
                                      DateTime actualreturnstart1 =
                                          DateFormat("dd-MM-yyyy HH:mm").parse(
                                              dataOfTripsList[index]
                                                  ["returnActualStartDateTime"])
                                          // .add(const Duration(
                                          // hours: 5, minutes: 30))
                                          ;

                                      // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
                                      _actualreturnstartdate =
                                          DateFormat("dd-MM-yyyy hh:mm a")
                                              .format(actualreturnstart1);
                                      // print("before converted" +
                                      //     tripData[index][
                                      //     "returnActualStartDateTime"]);
                                      // print(
                                      //     "after converted$_actualreturnstartdate");
                                    } else {
                                      _actualreturnstartdate = "---";
                                    }

                                    String _returnActualEnddate = "";
                                    // print(
                                    //     "${tripData[index]["returnActualEndDateTime"]}");
                                    if (dataOfTripsList[index]
                                                ["returnActualEndDateTime"] !=
                                            null &&
                                        dataOfTripsList[index]
                                                    ["returnActualEndDateTime"]
                                                .toString()
                                                .trim() !=
                                            "--") {
                                      DateTime actualreturnend1 =
                                          DateFormat("dd-MM-yyyy HH:mm").parse(
                                              dataOfTripsList[index]
                                                  ["returnActualEndDateTime"])
                                          // .add(const Duration(
                                          // hours: 5, minutes: 30))
                                          ;

                                      // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
                                      _returnActualEnddate =
                                          DateFormat("dd-MM-yyyy hh:mm a")
                                              .format(actualreturnend1);
                                      // print("before converted" +
                                      //     tripData[index]
                                      //     ["returnActualEndDateTime"]);
                                      // print(
                                      //     "after converted$_returnActualEnddate");
                                    } else {
                                      _returnActualEnddate = "---";
                                    }

                                    // print("in item${tripData[index]['driverName']}");
                                    return Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          5, 15, 8, 0),
                                      width: MediaQuery.of(context).size.width *
                                          .94,
                                      // height: clickeddeleteButton
                                      //     ? MediaQuery.of(context)
                                      //             .size
                                      //             .height *
                                      //         .47
                                      //     : MediaQuery.of(context)
                                      //             .size
                                      //             .height *
                                      //         .60,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFFFFFF),
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        border: Border.all(
                                          width: 2,
                                          color: const Color(0xFF000000)
                                              .withOpacity(0.3),
                                        ),
                                      ),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  dataOfTripsList[index][
                                                                  'tripStatus'] !=
                                                              'Completed' &&
                                                          dataOfTripsList[index]
                                                                  [
                                                                  'tripStatus'] !=
                                                              'Cancelled' &&
                                                          dataOfTripsList[index]
                                                                  [
                                                                  'tripStatus'] !=
                                                              'In Progress' &&
                                                          dataOfTripsList[index]
                                                                  [
                                                                  'tripStatus'] !=
                                                              "Inprogress" &&
                                                          dataOfTripsList[index]
                                                                  [
                                                                  'tripStatus'] !=
                                                              "In progress"
                                                      ? Container(
                                                          decoration:
                                                              const BoxDecoration(
                                                            borderRadius: BorderRadius.only(
                                                                topRight:
                                                                    const Radius
                                                                        .circular(
                                                                        9),
                                                                bottomLeft:
                                                                    const Radius
                                                                        .circular(
                                                                        9)
                                                                // bottomRight: Radius.circular(radius)
                                                                ),
                                                            color: blueColor,
                                                          ),
                                                          height: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .height *
                                                              .05,
                                                          width: MediaQuery.of(
                                                                      context)
                                                                  .size
                                                                  .width *
                                                              .21,
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .spaceBetween,
                                                            children: [
                                                              dataOfTripsList[
                                                                                  index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          'Completed' &&
                                                                      dataOfTripsList[index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          'Cancelled' &&
                                                                      dataOfTripsList[index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          'In Progress' &&
                                                                      dataOfTripsList[index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          "Inprogress" &&
                                                                      dataOfTripsList[index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          "In progress"
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        showSnackBar(
                                                                            context,
                                                                            "Loading...");
                                                                        // setState(
                                                                        //         () {
                                                                        //       setState(
                                                                        //               () {
                                                                        //             EasyLoading.show(
                                                                        //                 status: "Loading");
                                                                        //           });
                                                                        //     });
                                                                        // List<dynamic>
                                                                        //     getdata =
                                                                        //     await getTripDatas();
                                                                        showSnackBar(
                                                                            context,
                                                                            "Loading...");
                                                                        DateTime
                                                                            startdate;
                                                                        var sdate =
                                                                            "--";
                                                                        var edate =
                                                                            "--";
                                                                        var resdate =
                                                                            "--";
                                                                        var reedate =
                                                                            "--";
                                                                        var actualsdate =
                                                                            "--";
                                                                        var actualedate =
                                                                            "--";
                                                                        var reactualsdate =
                                                                            "--";
                                                                        var reactualedate =
                                                                            "--";
                                                                        // print("tripdate:${tripData[index]['onwardStartDateTime']}");
                                                                        if (dataOfTripsList[index]["tripStatus"] ==
                                                                            "Default") {
                                                                          if (dataOfTripsList[index]["actualStartTime"].toString() != "--" &&
                                                                              dataOfTripsList[index]["actualStartTime"] != null) {
                                                                            startdate =
                                                                                DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['actualStartTime']).add(const Duration(hours: 5, minutes: 30));
                                                                            sdate =
                                                                                dateFormat1.format(startdate);
                                                                            // print("tripdate:${tripData[index]['onwardActualStartDateTime']}");
                                                                            // print("startdate:${startdate}");
                                                                            // print("sdate:${sdate}");
                                                                          }
                                                                        } else {
                                                                          if (dataOfTripsList[index]['expectedStartTime'] != null &&
                                                                              dataOfTripsList[index]['expectedStartTime'] != '--') {
                                                                            startdate =
                                                                                DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['expectedStartTime']).add(const Duration(hours: 5, minutes: 30));
                                                                            sdate =
                                                                                dateFormat1.format(startdate);
                                                                          }
                                                                        }
                                                                        if (dataOfTripsList[index]["tripStatus"] ==
                                                                            "Default") {
                                                                          if (dataOfTripsList[index]["actualEndTime"].toString() != "--" &&
                                                                              dataOfTripsList[index]["actualEndTime"] != null) {
                                                                            DateTime
                                                                                enddate =
                                                                                DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['actualEndTime']).add(const Duration(hours: 5, minutes: 30));
                                                                            edate =
                                                                                dateFormat1.format(enddate);
                                                                            // print("tripdate:${tripData[index]['onwardActualEndDateTime']}");
                                                                            // print("startdate:${enddate}");
                                                                            // print("sdate:${sdate}");
                                                                          }
                                                                        } else {
                                                                          if (dataOfTripsList[index]['expectedEndTime'] != null &&
                                                                              dataOfTripsList[index]['expectedEndTime'] != '--') {
                                                                            DateTime
                                                                                enddate =
                                                                                DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['expectedEndTime']).add(const Duration(hours: 5, minutes: 30));
                                                                            edate =
                                                                                dateFormat1.format(enddate);
                                                                          }
                                                                        }
                                                                        if (dataOfTripsList[index]['returnStartDateTime'] !=
                                                                                null &&
                                                                            dataOfTripsList[index]['returnStartDateTime'] !=
                                                                                '--') {
                                                                          DateTime
                                                                              restartdate =
                                                                              DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['returnStartDateTime']).add(const Duration(hours: 5, minutes: 30));
                                                                          resdate =
                                                                              dateFormat1.format(restartdate);
                                                                          // print("resdateis ${resdate}");
                                                                        }
                                                                        if (dataOfTripsList[index]['returnEndDateTime'] !=
                                                                                null &&
                                                                            dataOfTripsList[index]['returnEndDateTime'] !=
                                                                                '--') {
                                                                          DateTime
                                                                              reenddate =
                                                                              DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['returnEndDateTime']).add(const Duration(hours: 5, minutes: 30));
                                                                          reedate =
                                                                              dateFormat1.format(reenddate);
                                                                        }
                                                                        if (dataOfTripsList[index]['actualStartTime'] !=
                                                                                null &&
                                                                            dataOfTripsList[index]['actualStartTime'] !=
                                                                                '--') {
                                                                          DateTime
                                                                              onactualstartdate =
                                                                              DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['actualStartTime']);
                                                                          actualsdate =
                                                                              dateFormat1.format(onactualstartdate);
                                                                        }
                                                                        if (dataOfTripsList[index]['actualEndTime'] !=
                                                                                null &&
                                                                            dataOfTripsList[index]['actualEndTime'] !=
                                                                                '--') {
                                                                          DateTime
                                                                              onactualenddate =
                                                                              DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['actualEndTime']);
                                                                          actualedate =
                                                                              dateFormat1.format(onactualenddate);
                                                                        } else {
                                                                          actualedate =
                                                                              "---";
                                                                        }
                                                                        if (dataOfTripsList[index]['returnActualStartTime'] !=
                                                                                null &&
                                                                            dataOfTripsList[index]['returnActualStartTime'] !=
                                                                                '--') {
                                                                          DateTime
                                                                              reactualstartdate =
                                                                              DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['returnActualStartTime']);
                                                                          reactualsdate =
                                                                              dateFormat1.format(reactualstartdate);
                                                                        }
                                                                        if (dataOfTripsList[index]['returnActualEndTime'] !=
                                                                                null &&
                                                                            dataOfTripsList[index]['returnActualEndTime'] !=
                                                                                '--') {
                                                                          DateTime
                                                                              reactualenddate =
                                                                              DateFormat("dd-MM-yyyy HH:mm").parse(dataOfTripsList[index]['returnActualEndTime']);
                                                                          reactualedate =
                                                                              dateFormat1.format(reactualenddate);
                                                                        }
                                                                        ScaffoldMessenger.of(context)
                                                                            .clearSnackBars();
                                                                        loader ==
                                                                                true
                                                                            ? Center(child: CircularProgressIndicator())
                                                                            : Navigator.push(
                                                                                context,
                                                                                MaterialPageRoute(
                                                                                    builder: (context) => EditTripScreen(
                                                                                          // data: getdata,
                                                                                          tripId: dataOfTripsList[index]["tripId"] ?? "",
                                                                                          uuid: dataOfTripsList[index]['uuid'],
                                                                                          tripName: dataOfTripsList[index]['tripName'] ?? "",
                                                                                          vehicleId: dataOfTripsList[index]["vehicleId"] == "" ? null : dataOfTripsList[index]["vehicleId"],
                                                                                          vehicleName: dataOfTripsList[index]['vehicleName'] == "--" ? null : dataOfTripsList[index]['vehicleName'],
                                                                                          driverName: dataOfTripsList[index]['driverName'] == "--" ? null : dataOfTripsList[index]['driverName'],
                                                                                          status: dataOfTripsList[index]['tripStatus'] ?? "",
                                                                                          isRecurring: dataOfTripsList[index]['isRecurring'] != true || dataOfTripsList[index]['isRecurring'] != false ? false : dataOfTripsList[index]['isRecurring'] ?? false,
                                                                                          category: dataOfTripsList[index]['category'],
                                                                                          onwardStartDateTime: sdate == "--" ? null : sdate,
                                                                                          onwardEndDateTime: edate == "--" ? null : edate,
                                                                                          returnStartDateTime: resdate == "--" ? null : resdate,
                                                                                          returnEndDateTime: reedate == "--" ? null : reedate,
                                                                                          onwardActualStartDateTime: actualsdate == "--" ? null : actualsdate,
                                                                                          onwardActualEndDateTime: actualedate == "--" ? null : actualedate,
                                                                                          // returnActualStartDateTime: reactualsdate == "--" ? null : reactualsdate,
                                                                                          // returnActualEndDateTime: reactualedate == "--" ? null : reactualedate,
                                                                                        )),
                                                                              );
                                                                      },
                                                                      child:
                                                                          editIcon)
                                                                  : const Text(
                                                                      ""),
                                                              dataOfTripsList[
                                                                                  index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          'Completed' &&
                                                                      dataOfTripsList[index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          'Cancelled' &&
                                                                      dataOfTripsList[index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          'In Progress' &&
                                                                      dataOfTripsList[index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          "Inprogress" &&
                                                                      dataOfTripsList[index]
                                                                              [
                                                                              'tripStatus'] !=
                                                                          "In progress"
                                                                  ? GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        showAlertDialog(
                                                                            context:
                                                                                context,
                                                                            tripId: dataOfTripsList[index][
                                                                                'tripId'],
                                                                            tripName: dataOfTripsList[index][
                                                                                'tripName'],
                                                                            recurring: dataOfTripsList[index]['isRecurring'] == "___"
                                                                                ? false
                                                                                : dataOfTripsList[index]['isRecurring']);
                                                                        // setState(() {
                                                                        //   clickeddeleteButton =
                                                                        //       true;
                                                                        //   // deleted= false;
                                                                        // });
                                                                      },
                                                                      child:
                                                                          deleteIcon)
                                                                  : const Text(
                                                                      ""),
                                                            ],
                                                          ),
                                                        )
                                                      : const Text(""),
                                                ],
                                              ),
                                            ],
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                  width: 165,
                                                  child: Padding(
                                                    padding:
                                                        EdgeInsets.all(8.0),
                                                    child: Text('Trip Id'),
                                                  )),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Text(
                                                  dataOfTripsList[index]
                                                              ["uuid"] !=
                                                          null
                                                      ? dataOfTripsList[index]
                                                              ["uuid"]
                                                          .toString()
                                                      : "--",
                                                  style:
                                                      vehiclePageCardTextSubHeadStyle,
                                                ),
                                              ),
                                            ],
                                          ),
                                          Divider(
                                            thickness: 2.0,
                                            color: Colors.black12,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 165,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Trip Name'),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    dataOfTripsList[index]
                                                                ["tripName"] !=
                                                            null
                                                        ? dataOfTripsList[index]
                                                                ["tripName"]
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 165,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Trip category'),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    dataOfTripsList[index]
                                                                ["category"] !=
                                                            null
                                                        ? dataOfTripsList[index]
                                                                ["category"]
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 165,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Trip Status'),
                                                ),
                                              ),
                                              Padding(
                                                padding: EdgeInsets.all(8.0),
                                                child: Container(
                                                  padding: EdgeInsets.all(8.0),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            15),
                                                    color: dataOfTripsList[index]['tripStatus'] == "In Progress" ||
                                                            dataOfTripsList[index]
                                                                    [
                                                                    'tripStatus'] ==
                                                                "inprogress" ||
                                                            dataOfTripsList[index]
                                                                    [
                                                                    'tripStatus'] ==
                                                                "In progress" ||
                                                            dataOfTripsList[
                                                                        index][
                                                                    'tripStatus'] ==
                                                                "Inprogress"
                                                        ? InprogressBackgroundColor
                                                        : dataOfTripsList[index]
                                                                    [
                                                                    'tripStatus'] ==
                                                                "Completed"
                                                            ? CompletedBackgroundColor
                                                            : dataOfTripsList[index]
                                                                        [
                                                                        'tripStatus'] ==
                                                                    "Cancelled"
                                                                ? CancelledBackgroundColor
                                                                : dataOfTripsList[index]
                                                                            ['tripStatus'] ==
                                                                        "Not Started"
                                                                    ? NotStartedBackgroundColor
                                                                    : unplannedBackgroundColor,
                                                  ),
                                                  // width:  MediaQuery.of(context).size.width *
                                                  //     .2,

                                                  child: Text(
                                                    dataOfTripsList[index][
                                                                "tripStatus"] !=
                                                            null
                                                        ? dataOfTripsList[index]
                                                                ["tripStatus"]
                                                            .toString()
                                                        : "--",
                                                    style: TextStyle(
                                                        fontWeight:
                                                            FontWeight.w700,
                                                        color: dataOfTripsList[
                                                                            index][
                                                                        'tripStatus'] ==
                                                                    "In Progress" ||
                                                                dataOfTripsList[index][
                                                                        'tripStatus'] ==
                                                                    "inprogress" ||
                                                                dataOfTripsList[index]
                                                                        [
                                                                        'tripStatus'] ==
                                                                    "In progress" ||
                                                                dataOfTripsList[index]
                                                                        [
                                                                        'tripStatus'] ==
                                                                    "Inprogress"
                                                            ? InprogressTextColor
                                                            : dataOfTripsList[index]
                                                                        [
                                                                        'tripStatus'] ==
                                                                    "Completed"
                                                                ? CompletedTextColor
                                                                : dataOfTripsList[index]
                                                                            ['tripStatus'] ==
                                                                        "Cancelled"
                                                                    ? CancelledTextColor
                                                                    : dataOfTripsList[index]['tripStatus'] == "Not Started"
                                                                        ? NotStartedTextColor
                                                                        : unplannedTextColor),
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 165,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Vehicle Name'),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text(
                                                    dataOfTripsList[index][
                                                                "vehicleName"] !=
                                                            null
                                                        ? dataOfTripsList[index]
                                                                ["vehicleName"]
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
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 165,
                                                child: Padding(
                                                  padding: EdgeInsets.all(8.0),
                                                  child: Text('Driver'),
                                                ),
                                              ),
                                              Expanded(
                                                flex: 1,
                                                child: Row(
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: dataOfTripsList[
                                                                      index][
                                                                  'driverImage'] ==
                                                              " "
                                                          ? Icon(
                                                              Icons
                                                                  .account_circle_rounded,
                                                              size: 10,
                                                            )
                                                          : Image.network(
                                                              "${dataOfTripsList[index]['driverImage']}",
                                                              width: 30,
                                                              height: 20,
                                                              errorBuilder:
                                                                  (context,
                                                                      error,
                                                                      stackTrace) {
                                                                return Icon(
                                                                  Icons
                                                                      .account_circle_rounded,
                                                                  size: 25,
                                                                  color: Colors
                                                                      .grey,
                                                                );
                                                              },
                                                            ),
                                                    ),
                                                    Expanded(
                                                      flex: 1,
                                                      child: Padding(
                                                        padding:
                                                            EdgeInsets.all(8.0),
                                                        child: Text(
                                                          dataOfTripsList[index]
                                                                          [
                                                                          "driverName"] ==
                                                                      null ||
                                                                  dataOfTripsList[
                                                                              index]
                                                                          [
                                                                          "driverName"] ==
                                                                      "___" ||
                                                                  dataOfTripsList[
                                                                              index]
                                                                          [
                                                                          "driverName"]
                                                                      .toString()
                                                                      .isEmpty
                                                              ? "___"
                                                              : dataOfTripsList[
                                                                          index]
                                                                      [
                                                                      "driverName"]
                                                                  .toString(),
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
                                          dataOfTripsList[index]['category'].toString().toLowerCase() == "one way" &&
                                                  dataOfTripsList[index]['tripStatus'].toString().toLowerCase() !=
                                                      "completed"
                                              ? Container(
                                                  child: Column(
                                                  children: [
                                                    SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child: Row(children: [
                                                          Column(children: [
                                                            Text(
                                                              "Planned(Date&Time)",
                                                              style: TextStyle(
                                                                  color:
                                                                      buttonColor,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w900,
                                                                  fontSize: 15),
                                                            ),
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      5,
                                                                      5,
                                                                      5,
                                                                      10),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      5,
                                                                      5,
                                                                      0,
                                                                      10),
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            10)),
                                                                color: const Color(
                                                                        0xFF6197CA)
                                                                    .withOpacity(
                                                                        .1),
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                      "Trip Start(Date&Time)",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  Table(
                                                                      columnWidths: {
                                                                        0: FixedColumnWidth(
                                                                            158),
                                                                        1: FixedColumnWidth(
                                                                            158),
                                                                        2: FixedColumnWidth(
                                                                            158),
                                                                        3: FixedColumnWidth(
                                                                            158),
                                                                      },
                                                                      defaultColumnWidth:
                                                                          const FixedColumnWidth(
                                                                              158.0),
                                                                      border: TableBorder.all(
                                                                          color:
                                                                              Colors.transparent),
                                                                      children: [
                                                                        TableRow(
                                                                            children: [
                                                                              Text(
                                                                                _onwardstartdate,
                                                                              ),
                                                                            ])
                                                                      ])
                                                                ],
                                                              ),
                                                              // ),
                                                            ),
                                                          ]),
                                                          Column(children: [
                                                            Container(
                                                              margin:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      0,
                                                                      23,
                                                                      15,
                                                                      10),
                                                              padding:
                                                                  const EdgeInsets
                                                                      .fromLTRB(
                                                                      5,
                                                                      5,
                                                                      0,
                                                                      10),
                                                              width: MediaQuery.of(
                                                                          context)
                                                                      .size
                                                                      .width *
                                                                  0.50,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    const BorderRadius
                                                                        .all(
                                                                        Radius.circular(
                                                                            10)),
                                                                color: const Color(
                                                                        0xFF6197CA)
                                                                    .withOpacity(
                                                                        .1),
                                                              ),
                                                              child: Column(
                                                                mainAxisAlignment:
                                                                    MainAxisAlignment
                                                                        .start,
                                                                crossAxisAlignment:
                                                                    CrossAxisAlignment
                                                                        .center,
                                                                children: [
                                                                  Text(
                                                                      "Trip End(Date&Time)",
                                                                      style: TextStyle(
                                                                          fontSize:
                                                                              16,
                                                                          fontWeight:
                                                                              FontWeight.bold)),
                                                                  Table(
                                                                      columnWidths: {
                                                                        0: FixedColumnWidth(
                                                                            158),
                                                                        1: FixedColumnWidth(
                                                                            158),
                                                                        2: FixedColumnWidth(
                                                                            158),
                                                                        3: FixedColumnWidth(
                                                                            158),
                                                                      },
                                                                      defaultColumnWidth:
                                                                          const FixedColumnWidth(
                                                                              158.0),
                                                                      border: TableBorder.all(
                                                                          color:
                                                                              Colors.transparent),
                                                                      children: [
                                                                        TableRow(
                                                                            children: [
                                                                              Text(
                                                                                _onwardenddate,
                                                                              ),
                                                                            ])
                                                                      ])
                                                                ],
                                                              ),
                                                              // ),
                                                            ),
                                                          ]),
                                                        ])),
                                                    const SizedBox(width: 6),
                                                    dataOfTripsList[index][
                                                                    'tripStatus']
                                                                .toString()
                                                                .toLowerCase() !=
                                                            "cancelled"
                                                        ? Container(
                                                            padding:
                                                                EdgeInsetsDirectional
                                                                    .symmetric(
                                                                        horizontal:
                                                                            8),
                                                            child: _compactBtn(
                                                              label:
                                                                  "Switch Vehicle",
                                                              icon: Icons
                                                                  .published_with_changes_rounded,
                                                              color:
                                                                  buttonColor, // Bright Cyan
                                                              onTap: () =>
                                                                  navigateToSwitch(
                                                                      dataOfTripsList[
                                                                          index]),
                                                            ),
                                                          )
                                                        : const SizedBox(
                                                            width: 1),
                                                    const SizedBox(width: 6),
                                                  ],
                                                ))
                                              : dataOfTripsList[index]['category'].toString().toLowerCase() == "one way" &&
                                                      dataOfTripsList[index]['tripStatus'].toString().toLowerCase() ==
                                                          "completed"
                                                  ? Container(
                                                      child:
                                                          SingleChildScrollView(
                                                              scrollDirection:
                                                                  Axis
                                                                      .horizontal,
                                                              child: Column(
                                                                  children: [
                                                                    Row(children: [
                                                                      Column(
                                                                          children: [
                                                                            Text(
                                                                              "Planned(Date&Time)",
                                                                              style: TextStyle(color: buttonColor, fontWeight: FontWeight.w900, fontSize: 15),
                                                                            ),
                                                                            Container(
                                                                              margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                                                                              padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                              width: MediaQuery.of(context).size.width * 0.50,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                color: const Color(0xFF6197CA).withOpacity(.1),
                                                                              ),
                                                                              child:
                                                                                  // SingleChildScrollView(
                                                                                  //   scrollDirection:
                                                                                  //       Axis.horizontal,
                                                                                  //   child:
                                                                                  Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Text("Trip Start(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                  Table(
                                                                                      columnWidths: {
                                                                                        0: FixedColumnWidth(158),
                                                                                        1: FixedColumnWidth(158),
                                                                                        2: FixedColumnWidth(158),
                                                                                        3: FixedColumnWidth(158),
                                                                                      },
                                                                                      defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                      border: TableBorder.all(color: Colors.transparent),
                                                                                      children: [
                                                                                        TableRow(children: [
                                                                                          Text(
                                                                                            _onwardstartdate,
                                                                                          ),
                                                                                        ])
                                                                                      ])
                                                                                ],
                                                                              ),
                                                                              // ),
                                                                            ),
                                                                          ]),
                                                                      Column(
                                                                          children: [
                                                                            Container(
                                                                              margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                              padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                              width: MediaQuery.of(context).size.width * 0.50,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                color: const Color(0xFF6197CA).withOpacity(.1),
                                                                              ),
                                                                              child: Column(
                                                                                mainAxisAlignment: MainAxisAlignment.start,
                                                                                crossAxisAlignment: CrossAxisAlignment.center,
                                                                                children: [
                                                                                  Text("Trip End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                  Table(
                                                                                      columnWidths: {
                                                                                        0: FixedColumnWidth(158),
                                                                                        1: FixedColumnWidth(158),
                                                                                        2: FixedColumnWidth(158),
                                                                                        3: FixedColumnWidth(158),
                                                                                      },
                                                                                      defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                      border: TableBorder.all(color: Colors.transparent),
                                                                                      children: [
                                                                                        TableRow(children: [
                                                                                          Text(
                                                                                            _onwardenddate,
                                                                                          ),
                                                                                        ])
                                                                                      ])
                                                                                ],
                                                                              ),
                                                                              // ),
                                                                            ),
                                                                          ])
                                                                    ]),
                                                                    Row(children: [
                                                                      Column(
                                                                          children: [
                                                                            Text(
                                                                              "Actual(Date&Time)",
                                                                              style: TextStyle(color: buttonColor, fontWeight: FontWeight.w900, fontSize: 15),
                                                                            ),
                                                                            Container(
                                                                              margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                                                                              padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                              width: MediaQuery.of(context).size.width * 0.50,
                                                                              decoration: BoxDecoration(
                                                                                borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                color: const Color(0xFF6197CA).withOpacity(.1),
                                                                              ),
                                                                              child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                                Text("Trip Start(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                Table(
                                                                                  columnWidths: {
                                                                                    0: FixedColumnWidth(158),
                                                                                    1: FixedColumnWidth(158),
                                                                                    2: FixedColumnWidth(158),
                                                                                    3: FixedColumnWidth(158),
                                                                                  },
                                                                                  defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                  border: TableBorder.all(color: Colors.transparent),
                                                                                  children: [
                                                                                    TableRow(children: [
                                                                                      Text(
                                                                                        _actualstartdate,
                                                                                      ),
                                                                                    ])
                                                                                  ],
                                                                                ),
                                                                              ]),
                                                                            )
                                                                          ]),
                                                                      Column(
                                                                          children: [
                                                                            Container(
                                                                                margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                                padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                width: MediaQuery.of(context).size.width * 0.50,
                                                                                decoration: BoxDecoration(
                                                                                  borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                  color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                ),
                                                                                child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                                  Text("Trip End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                  Table(
                                                                                      columnWidths: {
                                                                                        0: FixedColumnWidth(158),
                                                                                        1: FixedColumnWidth(158),
                                                                                        2: FixedColumnWidth(158),
                                                                                        3: FixedColumnWidth(158),
                                                                                      },
                                                                                      defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                      border: TableBorder.all(color: Colors.transparent),
                                                                                      children: [
                                                                                        TableRow(
                                                                                          children: [
                                                                                            Text(
                                                                                              _actualenddate,
                                                                                            ),
                                                                                            //         ])
                                                                                          ],
                                                                                        ),
                                                                                      ]),
                                                                                ]))
                                                                          ])
                                                                    ])
                                                                  ])))
                                                  : dataOfTripsList[index][
                                                                      'category']
                                                                  .toString()
                                                                  .toLowerCase() ==
                                                              "round" &&
                                                          dataOfTripsList[index]
                                                                      [
                                                                      'tripStatus']
                                                                  .toString()
                                                                  .toLowerCase() ==
                                                              "not started"
                                                      ? Container(
                                                          child:
                                                              SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis
                                                                          .horizontal,
                                                                  child: Column(
                                                                      children: [
                                                                        Row(
                                                                            children: [
                                                                              Column(children: [
                                                                                Text(
                                                                                  "Planned(Date&Time)",
                                                                                  style: TextStyle(color: buttonColor, fontWeight: FontWeight.w900, fontSize: 15),
                                                                                ),
                                                                                Container(
                                                                                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                  width: MediaQuery.of(context).size.width * 0.50,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                  ),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text("Trip Start(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                      Table(
                                                                                          columnWidths: {
                                                                                            0: FixedColumnWidth(158),
                                                                                            1: FixedColumnWidth(158),
                                                                                            2: FixedColumnWidth(158),
                                                                                            3: FixedColumnWidth(158),
                                                                                          },
                                                                                          defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                          border: TableBorder.all(color: Colors.transparent),
                                                                                          children: [
                                                                                            TableRow(children: [
                                                                                              Text(
                                                                                                _onwardstartdate,
                                                                                              ),
                                                                                            ])
                                                                                          ])
                                                                                    ],
                                                                                  ),
                                                                                  // ),
                                                                                ),
                                                                              ]),
                                                                              Column(children: [
                                                                                Container(
                                                                                  margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                  width: MediaQuery.of(context).size.width * 0.50,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                  ),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text("Trip End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                      Table(
                                                                                          columnWidths: {
                                                                                            0: FixedColumnWidth(158),
                                                                                            1: FixedColumnWidth(158),
                                                                                            2: FixedColumnWidth(158),
                                                                                            3: FixedColumnWidth(158),
                                                                                          },
                                                                                          defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                          border: TableBorder.all(color: Colors.transparent),
                                                                                          children: [
                                                                                            TableRow(children: [
                                                                                              Text(
                                                                                                _onwardenddate,
                                                                                              ),
                                                                                            ])
                                                                                          ])
                                                                                    ],
                                                                                  ),
                                                                                  // ),
                                                                                ),
                                                                              ]),
                                                                              Column(children: [
                                                                                Container(
                                                                                  margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                  width: MediaQuery.of(context).size.width * 0.50,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                  ),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text("Return Start(Date&Time)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                                                      Table(
                                                                                          columnWidths: {
                                                                                            0: FixedColumnWidth(158),
                                                                                            1: FixedColumnWidth(158),
                                                                                            2: FixedColumnWidth(158),
                                                                                            3: FixedColumnWidth(158),
                                                                                          },
                                                                                          defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                          border: TableBorder.all(color: Colors.transparent),
                                                                                          children: [
                                                                                            TableRow(children: [
                                                                                              Text(
                                                                                                _returnstartdate,
                                                                                              ),
                                                                                            ])
                                                                                          ])
                                                                                    ],
                                                                                  ),
                                                                                  // ),
                                                                                ),
                                                                              ]),
                                                                              Column(children: [
                                                                                Container(
                                                                                  margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                  width: MediaQuery.of(context).size.width * 0.50,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                  ),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text("Return End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                      Table(
                                                                                          columnWidths: {
                                                                                            0: FixedColumnWidth(158),
                                                                                            1: FixedColumnWidth(158),
                                                                                            2: FixedColumnWidth(158),
                                                                                            3: FixedColumnWidth(158),
                                                                                          },
                                                                                          defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                          border: TableBorder.all(color: Colors.transparent),
                                                                                          children: [
                                                                                            TableRow(children: [
                                                                                              Text(
                                                                                                _returnenddate,
                                                                                              ),
                                                                                            ])
                                                                                          ])
                                                                                    ],
                                                                                  ),
                                                                                  // ),
                                                                                ),
                                                                              ])
                                                                            ]),
                                                                        // Row(
                                                                        //     children: [
                                                                        //       Column(children: [
                                                                        //         Text(
                                                                        //           "Actual(Date&Time)",
                                                                        //           style: TextStyle(color: buttonColor, fontWeight: FontWeight.w900, fontSize: 15),
                                                                        //         ),
                                                                        //         Container(
                                                                        //           margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                                                                        //           padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                        //           width: MediaQuery.of(context).size.width * 0.50,
                                                                        //           decoration: BoxDecoration(
                                                                        //             borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                        //             color: const Color(0xFF6197CA).withOpacity(.1),
                                                                        //           ),
                                                                        //           child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                        //             Text("Trip Start(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                        //             Table(
                                                                        //               columnWidths: {
                                                                        //                 0: FixedColumnWidth(158),
                                                                        //                 1: FixedColumnWidth(158),
                                                                        //                 2: FixedColumnWidth(158),
                                                                        //                 3: FixedColumnWidth(158),
                                                                        //               },
                                                                        //               defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                        //               border: TableBorder.all(color: Colors.transparent),
                                                                        //               children: [
                                                                        //                 TableRow(children: [
                                                                        //                   Text(
                                                                        //                     _actualstartdate,
                                                                        //                   ),
                                                                        //                 ])
                                                                        //               ],
                                                                        //             ),
                                                                        //           ]),
                                                                        //         )
                                                                        //       ]),
                                                                        //       Column(children: [
                                                                        //         Container(
                                                                        //             margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                        //             padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                        //             width: MediaQuery.of(context).size.width * 0.50,
                                                                        //             decoration: BoxDecoration(
                                                                        //               borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                        //               color: const Color(0xFF6197CA).withOpacity(.1),
                                                                        //             ),
                                                                        //             child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                        //               Text("Trip End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                        //               Table(
                                                                        //                   columnWidths: {
                                                                        //                     0: FixedColumnWidth(158),
                                                                        //                     1: FixedColumnWidth(158),
                                                                        //                     2: FixedColumnWidth(158),
                                                                        //                     3: FixedColumnWidth(158),
                                                                        //                   },
                                                                        //                   defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                        //                   border: TableBorder.all(color: Colors.transparent),
                                                                        //                   children: [
                                                                        //                     TableRow(
                                                                        //                       children: [
                                                                        //                         Text(
                                                                        //                           _actualenddate,
                                                                        //                         ),
                                                                        //                       ],
                                                                        //                     ),
                                                                        //                   ]),
                                                                        //             ]))
                                                                        //       ]),
                                                                        //       Column(children: [
                                                                        //         Container(
                                                                        //             margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                        //             padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                        //             width: MediaQuery.of(context).size.width * 0.50,
                                                                        //             decoration: BoxDecoration(
                                                                        //               borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                        //               color: const Color(0xFF6197CA).withOpacity(.1),
                                                                        //             ),
                                                                        //             child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                        //               Text("Return Start(Date&Time)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                                        //               Table(
                                                                        //                   columnWidths: {
                                                                        //                     0: FixedColumnWidth(158),
                                                                        //                     1: FixedColumnWidth(158),
                                                                        //                     2: FixedColumnWidth(158),
                                                                        //                     3: FixedColumnWidth(158),
                                                                        //                   },
                                                                        //                   defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                        //                   border: TableBorder.all(color: Colors.transparent),
                                                                        //                   children: [
                                                                        //                     TableRow(
                                                                        //                       children: [
                                                                        //                         Text(
                                                                        //                           _actualreturnstartdate,
                                                                        //                         ),
                                                                        //                       ],
                                                                        //                     ),
                                                                        //                   ]),
                                                                        //             ]))
                                                                        //       ]),
                                                                        //       Column(children: [
                                                                        //         Container(
                                                                        //             margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                        //             padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                        //             width: MediaQuery.of(context).size.width * 0.50,
                                                                        //             decoration: BoxDecoration(
                                                                        //               borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                        //               color: const Color(0xFF6197CA).withOpacity(.1),
                                                                        //             ),
                                                                        //             child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                        //               Text("Return End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                        //               Table(
                                                                        //                   columnWidths: {
                                                                        //                     0: FixedColumnWidth(158),
                                                                        //                     1: FixedColumnWidth(158),
                                                                        //                     2: FixedColumnWidth(158),
                                                                        //                     3: FixedColumnWidth(158),
                                                                        //                   },
                                                                        //                   defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                        //                   border: TableBorder.all(color: Colors.transparent),
                                                                        //                   children: [
                                                                        //                     TableRow(
                                                                        //                       children: [
                                                                        //                         Text(
                                                                        //                           _returnActualEnddate,
                                                                        //                         ),
                                                                        //                       ],
                                                                        //                     ),
                                                                        //                   ]),
                                                                        //             ]))
                                                                        //       ])
                                                                        //     ])
                                                                      ])))
                                                      : Container(
                                                          child:
                                                              SingleChildScrollView(
                                                                  scrollDirection:
                                                                      Axis
                                                                          .horizontal,
                                                                  child: Column(
                                                                      children: [
                                                                        Row(
                                                                            children: [
                                                                              Column(children: [
                                                                                Text(
                                                                                  "Planned(Date&Time)",
                                                                                  style: TextStyle(color: buttonColor, fontWeight: FontWeight.w900, fontSize: 15),
                                                                                ),
                                                                                Container(
                                                                                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                  width: MediaQuery.of(context).size.width * 0.50,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                  ),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text("Trip Start(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                      Table(
                                                                                          columnWidths: {
                                                                                            0: FixedColumnWidth(158),
                                                                                            1: FixedColumnWidth(158),
                                                                                            2: FixedColumnWidth(158),
                                                                                            3: FixedColumnWidth(158),
                                                                                          },
                                                                                          defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                          border: TableBorder.all(color: Colors.transparent),
                                                                                          children: [
                                                                                            TableRow(children: [
                                                                                              Text(
                                                                                                _onwardstartdate,
                                                                                              ),
                                                                                            ])
                                                                                          ])
                                                                                    ],
                                                                                  ),
                                                                                  // ),
                                                                                ),
                                                                              ]),
                                                                              Column(children: [
                                                                                Container(
                                                                                  margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                  width: MediaQuery.of(context).size.width * 0.50,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                  ),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text("Trip End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                      Table(
                                                                                          columnWidths: {
                                                                                            0: FixedColumnWidth(158),
                                                                                            1: FixedColumnWidth(158),
                                                                                            2: FixedColumnWidth(158),
                                                                                            3: FixedColumnWidth(158),
                                                                                          },
                                                                                          defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                          border: TableBorder.all(color: Colors.transparent),
                                                                                          children: [
                                                                                            TableRow(children: [
                                                                                              Text(
                                                                                                _onwardenddate,
                                                                                              ),
                                                                                            ])
                                                                                          ])
                                                                                    ],
                                                                                  ),
                                                                                  // ),
                                                                                ),
                                                                              ]),
                                                                              Column(children: [
                                                                                Container(
                                                                                  margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                  width: MediaQuery.of(context).size.width * 0.50,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                  ),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text("Return Start(Date&Time)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                                                      Table(
                                                                                          columnWidths: {
                                                                                            0: FixedColumnWidth(158),
                                                                                            1: FixedColumnWidth(158),
                                                                                            2: FixedColumnWidth(158),
                                                                                            3: FixedColumnWidth(158),
                                                                                          },
                                                                                          defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                          border: TableBorder.all(color: Colors.transparent),
                                                                                          children: [
                                                                                            TableRow(children: [
                                                                                              Text(
                                                                                                _returnstartdate,
                                                                                              ),
                                                                                            ])
                                                                                          ])
                                                                                    ],
                                                                                  ),
                                                                                  // ),
                                                                                ),
                                                                              ]),
                                                                              Column(children: [
                                                                                Container(
                                                                                  margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                  width: MediaQuery.of(context).size.width * 0.50,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                  ),
                                                                                  child: Column(
                                                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                                                    children: [
                                                                                      Text("Return End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                      Table(
                                                                                          columnWidths: {
                                                                                            0: FixedColumnWidth(158),
                                                                                            1: FixedColumnWidth(158),
                                                                                            2: FixedColumnWidth(158),
                                                                                            3: FixedColumnWidth(158),
                                                                                          },
                                                                                          defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                          border: TableBorder.all(color: Colors.transparent),
                                                                                          children: [
                                                                                            TableRow(children: [
                                                                                              Text(
                                                                                                _returnenddate,
                                                                                              ),
                                                                                            ])
                                                                                          ])
                                                                                    ],
                                                                                  ),
                                                                                  // ),
                                                                                ),
                                                                              ])
                                                                            ]),
                                                                        Row(
                                                                            children: [
                                                                              Column(crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                                Text(
                                                                                  "Actual(Date&Time)",
                                                                                  style: TextStyle(color: buttonColor, fontWeight: FontWeight.w900, fontSize: 15),
                                                                                ),
                                                                                Container(
                                                                                  margin: const EdgeInsets.fromLTRB(5, 5, 5, 10),
                                                                                  padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                  width: MediaQuery.of(context).size.width * 0.50,
                                                                                  decoration: BoxDecoration(
                                                                                    borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                    color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                  ),
                                                                                  child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                                    Text("Trip Start(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                    Table(
                                                                                      columnWidths: {
                                                                                        0: FixedColumnWidth(158),
                                                                                        1: FixedColumnWidth(158),
                                                                                        2: FixedColumnWidth(158),
                                                                                        3: FixedColumnWidth(158),
                                                                                      },
                                                                                      defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                      border: TableBorder.all(color: Colors.transparent),
                                                                                      children: [
                                                                                        TableRow(children: [
                                                                                          Text(
                                                                                            _actualstartdate,
                                                                                          ),
                                                                                        ])
                                                                                      ],
                                                                                    ),
                                                                                  ]),
                                                                                )
                                                                              ]),
                                                                              Column(children: [
                                                                                Container(
                                                                                    margin: const EdgeInsets.fromLTRB(0, 23, 400, 6),
                                                                                    padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                                    width: MediaQuery.of(context).size.width * 0.50,
                                                                                    decoration: BoxDecoration(
                                                                                      borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                                      color: const Color(0xFF6197CA).withOpacity(.1),
                                                                                    ),
                                                                                    child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                                      Text("Trip End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                                      Table(
                                                                                          columnWidths: {
                                                                                            0: FixedColumnWidth(158),
                                                                                            1: FixedColumnWidth(158),
                                                                                            2: FixedColumnWidth(158),
                                                                                            3: FixedColumnWidth(158),
                                                                                          },
                                                                                          defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                                          border: TableBorder.all(color: Colors.transparent),
                                                                                          children: [
                                                                                            TableRow(
                                                                                              children: [
                                                                                                Text(
                                                                                                  _actualenddate,
                                                                                                ),
                                                                                              ],
                                                                                            ),
                                                                                          ]),
                                                                                    ]))
                                                                              ]),
                                                                              // Column(children: [
                                                                              //   Container(
                                                                              //       margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                              //       padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                              //       width: MediaQuery.of(context).size.width * 0.50,
                                                                              //       decoration: BoxDecoration(
                                                                              //         borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                              //         color: const Color(0xFF6197CA).withOpacity(.1),
                                                                              //       ),
                                                                              //       child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                              //         Text("Return Start(Date&Time)", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                                                                              //         Table(
                                                                              //             columnWidths: {
                                                                              //               0: FixedColumnWidth(158),
                                                                              //               1: FixedColumnWidth(158),
                                                                              //               2: FixedColumnWidth(158),
                                                                              //               3: FixedColumnWidth(158),
                                                                              //             },
                                                                              //             defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                              //             border: TableBorder.all(color: Colors.transparent),
                                                                              //             children: [
                                                                              //               TableRow(
                                                                              //                 children: [
                                                                              //                   Text(
                                                                              //                     _actualreturnstartdate,
                                                                              //                   ),
                                                                              //                 ],
                                                                              //               ),
                                                                              //             ]),
                                                                              //       ]))
                                                                              // ]),
                                                                              // Column(children: [
                                                                              //   Container(
                                                                              //       margin: const EdgeInsets.fromLTRB(0, 23, 15, 10),
                                                                              //       padding: const EdgeInsets.fromLTRB(5, 5, 0, 10),
                                                                              //       width: MediaQuery.of(context).size.width * 0.50,
                                                                              //       decoration: BoxDecoration(
                                                                              //         borderRadius: const BorderRadius.all(Radius.circular(10)),
                                                                              //         color: const Color(0xFF6197CA).withOpacity(.1),
                                                                              //       ),
                                                                              //       child: Column(mainAxisAlignment: MainAxisAlignment.start, crossAxisAlignment: CrossAxisAlignment.center, children: [
                                                                              //         Text("Return End(Date&Time)", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                                                              //         Table(
                                                                              //             columnWidths: {
                                                                              //               0: FixedColumnWidth(158),
                                                                              //               1: FixedColumnWidth(158),
                                                                              //               2: FixedColumnWidth(158),
                                                                              //               3: FixedColumnWidth(158),
                                                                              //             },
                                                                              //             defaultColumnWidth: const FixedColumnWidth(158.0),
                                                                              //             border: TableBorder.all(color: Colors.transparent),
                                                                              //             children: [
                                                                              //               TableRow(
                                                                              //                 children: [
                                                                              //                   Text(
                                                                              //                     _returnActualEnddate,
                                                                              //                   ),
                                                                              //                 ],
                                                                              //               ),
                                                                              //             ]),
                                                                              //       ]))
                                                                              // ])
                                                                            ])
                                                                      ]))),
                                          dataOfTripsList[index]["tripStatus"]
                                                      .toString()
                                                      .replaceAll(" ", '')
                                                      .toLowerCase() ==
                                                  "completed"
                                              ? Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceEvenly,
                                                  children: [
                                                    TextButton(
                                                        style: ButtonStyle(
                                                            elevation:
                                                                MaterialStateProperty
                                                                    .all(2),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(
                                                                        buttonColor)),
                                                        onPressed: () async {
                                                          Navigator.of(context).push(
                                                              MaterialPageRoute(
                                                                  builder:
                                                                      (context) {
                                                            return VehicleTracking(
                                                              trackdata:
                                                                  dataOfTripsList[
                                                                      index],
                                                            );
                                                          }));
                                                        },
                                                        child: Row(
                                                          children: const [
                                                            Image(
                                                                height: 30,
                                                                image: AssetImage(
                                                                    "images/location.png")),
                                                            Text(
                                                              "Track History",
                                                              style: TextStyle(
                                                                  color: Colors
                                                                      .white,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold),
                                                            ),
                                                          ],
                                                        )),
                                                  ],
                                                )
                                              : dataOfTripsList[index]
                                                                  ["tripStatus"]
                                                              .toString()
                                                              .replaceAll(
                                                                  " ", '')
                                                              .toLowerCase() ==
                                                          "in progress" ||
                                                      dataOfTripsList[index]
                                                              ['tripStatus'] ==
                                                          'In Progress' ||
                                                      dataOfTripsList[index]
                                                              ['tripStatus'] ==
                                                          "Inprogress" ||
                                                      dataOfTripsList[index]
                                                              ['tripStatus'] ==
                                                          "In progress"
                                                  ? Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .spaceEvenly,
                                                      children: [
                                                        TextButton(
                                                            style: ButtonStyle(
                                                                elevation:
                                                                    MaterialStateProperty
                                                                        .all(2),
                                                                backgroundColor:
                                                                    MaterialStateProperty
                                                                        .all(
                                                                            buttonColor)),
                                                            onPressed:
                                                                () async {
                                                              print(
                                                                  "tripData[index] : ${dataOfTripsList[index]}");
                                                              var fromTime = DateFormat(
                                                                      'yyyy-MM-dd hh:mm')
                                                                  .format(DateFormat(
                                                                          'dd-MM-yyyy hh:mm')
                                                                      .parse(dataOfTripsList[
                                                                              index]
                                                                          [
                                                                          "expectedStartTime"]));
                                                              fromTime =
                                                                  fromTime +
                                                                      ":00";
                                                              dataOfTripsList[
                                                                          index]
                                                                      [
                                                                      "expectedStartTime"] =
                                                                  fromTime;
                                                              print(
                                                                  "tripData[index] : ${dataOfTripsList[index]}");
                                                              Navigator.of(
                                                                      context)
                                                                  .push(MaterialPageRoute(
                                                                      builder:
                                                                          (context) {
                                                                return LiveTrackScreen(
                                                                  trackdata:
                                                                      dataOfTripsList[
                                                                          index],
                                                                );
                                                              }));
                                                            },
                                                            child: Row(
                                                              children: const [
                                                                Image(
                                                                    height: 30,
                                                                    image: AssetImage(
                                                                        "images/livelocation.png")),
                                                                Text(
                                                                  "Live Track",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold),
                                                                ),
                                                              ],
                                                            )),
                                                      ],
                                                    )
                                                  : const SizedBox(),
                                          SizedBox(
                                            height: 15,
                                          ),
                                        ],
                                      ),
                                    );
                                  }),
                )
              ]),
            ),
          )),
    );
  }

  Widget _compactBtn(
      {required String label,
      required IconData icon,
      required Color color,
      required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding:
            const EdgeInsets.symmetric(vertical: 8), // Reduced vertical height
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                color: color.withOpacity(0.2),
                blurRadius: 4,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 20, color: Colors.white),
            const SizedBox(width: 4),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white, // Text color black as requested
                fontSize: 16,
                fontWeight: FontWeight.w900, // Bold
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void navigateToSwitch(Map<dynamic, dynamic> trip) {
    if (trip["tripStatus"].toString().toLowerCase().contains("progress")) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor:
              const Color(0xFFFEF3C7), // Light Amber/Yellow background
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Round Image Icon
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.amber.shade700, width: 2),
                  image: const DecorationImage(
                    image: AssetImage("images/alert_warning_round.png"),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "SWITCH RESTRICTED",
                style: TextStyle(
                    fontWeight: FontWeight.w900,
                    fontSize: 16,
                    color: Colors.black,
                    letterSpacing: 0.5),
              ),
              const SizedBox(height: 8),
              const Text(
                "This trip is currently In Progress. You cannot switch the vehicle while the trip is active.",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 13,
                    color: Colors.black87,
                    fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0, left: 4, right: 4),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    elevation: 0,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text("OK",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w900,
                          fontSize: 12)),
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => SwitchVehicleScreen(tripData: trip)));
    }
  }
}

import 'dart:async';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/sidebar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../languges/language_constants.dart';
import '../dashboardScreen.dart';
import '../themes.dart';

Color? color;
DateTime now = DateTime.now();
String dateOnly = DateFormat('dd-MM-yyyy').format(now);
Future<bool> _onwillscope(BuildContext context) async {
  Navigator.of(context).push(MaterialPageRoute(builder: (BuildContext ctx) {
    return Dashboard();
  }));
  return true;
}

class TripScreen extends StatefulWidget {
  String excluded;
  TripScreen({required this.status, this.excluded = "none"});
  var status;

  @override
  State<TripScreen> createState() => _TripScreenState();
}

class _TripScreenState extends State<TripScreen> {
  var dateFormat1 = DateFormat("dd-MM-yyyy HH:mm");
  bool _noData = false;
  String _searchResult = '';
  List<Map<dynamic, dynamic>> tripData = [];
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
    return WillPopScope(
        onWillPop: () => _onwillscope(context),
        child: Container(
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

  Future<List<dynamic>> getTripDatas() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    DateTime now = DateTime.now();
    String formattedtoday = DateFormat('yyyy-MM-dd').format(now);
    var data = {
      "toTime": "${formattedtoday} 23:59:59",
      "fromTime": "${formattedtoday} 00:00:00",
      "userId": userId,
    };
    print(userId);
    print(data);
    print("data");
    final url = "${baseUrl}trips/user-trips";
    var dio = Dio();
    final response = await dio.post(url, data: data);
    tripListData.clear();
    // print("res${response.data['list']}");

    for (var i = 0; i < response.data['list'].length; i++) {
      var date = DateTime.parse(response.data['list'][i]
              ['onwardStartDateTime'] ??
          response.data['list'][i]['actualStartTime']);
      var formatted = DateFormat('dd-MM-yyyy').format(date);
      print("dateonly:$dateOnly and date is $formatted");
      if (dateOnly == formatted) {
        tripListData.add(response.data['list'][i]);
        print(response.data['list'][i]);
      }
    }
    // print(" data is here ${tripListData[0]['driverFirstName']}");
    // print('length:${tripListData.length}');
    // print(tripListData);
    // print(tripListData.runtimeType);
    return tripListData;
  }

  List<Map<String, dynamic>> ListTrip = [];
  var sdate = "--";

  var edate = "--";
  var resdate = "--";
  var reedate = "--";
  var actualsdate = "--";
  var actualsdate1 = "--";
  var actualedate = "--";
  var reactualsdate = "--";
  var reactualedate = "--";
  var astart = "--";
  var aend = "--";
  List<Widget> Addtrip() {
    // print("length of the list is:${tripListData.length}");
    // print(widget.status);
    var j = 0;
    var k = 0;
    for (var i = 0; i < tripListData.length; i++) {
      if (widget.excluded == "Completed") {
        j = j + 1;
        if (tripListData[i]["onwardStartDateTime"].toString() != "--" &&
            tripListData[i]["onwardStartDateTime"] != null) {
          DateTime onwardstart1 = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]["onwardStartDateTime"])
              .add(const Duration(hours: 5, minutes: 30));

          // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
          sdate = DateFormat("dd-MM-yyyy hh:mm a").format(onwardstart1);
        } else {
          sdate = "---";
        }
        if (tripListData[i]["onwardEndDateTime"].toString() != "--" &&
            tripListData[i]['onwardEndDateTime'] != null) {
          DateTime enddate = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]['onwardEndDateTime'])
              .add(const Duration(hours: 5, minutes: 30));
          edate = DateFormat("dd-MM-yyyy hh:mm a").format(enddate);
        } else {
          edate = "---";
        }

        print("${j + 1} ${tripListData[i]['tripStatus']}");
        print("inside completed excluded");
        if (tripListData[i]['tripStatus'] != widget.excluded &&
            tripListData[i]['tripStatus']
                    .toString()
                    .toLowerCase()
                    .replaceAll(" ", "") !=
                "Default") {
          print("inside the default");
          // print(tripListData[i]);

          if (tripListData[i]["returnStartTime"].toString() != "--" &&
              tripListData[i]['returnStartTime'] != null) {
            DateTime restartdate = DateFormat("yyyy-MM-dd hh:mm")
                .parse(tripListData[i]['returnStartTime'])
                .add(const Duration(hours: 5, minutes: 30));
            resdate = DateFormat("dd-MM-yyyy hh:mm a").format(restartdate);
          } else {
            resdate = "---";
          }
          if (tripListData[i]["returnEndDateTime"].toString() != "--" &&
              tripListData[i]['returnEndDateTime'] != null) {
            DateTime reenddate = DateFormat("yyyy-MM-dd hh:mm")
                .parse(tripListData[i]['returnEndDateTime'])
                .add(const Duration(hours: 5, minutes: 30));
            reedate = DateFormat("dd-MM-yyyy hh:mm a").format(reenddate);
          } else {
            reedate = "---";
          }
          if (tripListData[i]["actualStartTime"].toString() != "--" &&
              tripListData[i]['actualStartTime'] != null) {
            print(tripListData[i]['actualStartTime']);
            DateTime onactualstartdate = DateFormat("yyyy-MM-dd hh:mm")
                .parse(tripListData[i]['actualStartTime']);
            // .add(const Duration(hours: 5, minutes: 30));

            actualsdate1 =
                DateFormat("dd-MM-yyyy hh:mm a").format(onactualstartdate);
          } else {
            actualsdate1 = "---";
          }
          if (tripListData[i]["actualEndTime"].toString() != "--" &&
              tripListData[i]['actualEndTime'] != null) {
            DateTime onactualenddate = DateFormat("yyyy-MM-dd hh:mm")
                .parse(tripListData[i]['actualEndTime']);
            // .add(const Duration(hours: 5, minutes: 30));
            actualedate =
                DateFormat("dd-MM-yyyy hh:mm a").format(onactualenddate);
          } else {
            actualedate = "---";
          }
          if (tripListData[i]["returnActualStartTime"].toString() != "--" &&
              tripListData[i]['returnActualStartTime'] != null) {
            DateTime reactualstartdate = DateFormat("yyyy-MM-dd hh:mm")
                .parse(tripListData[i]['returnActualStartTime'])
                .add(const Duration(hours: 5, minutes: 30));
            reactualsdate =
                DateFormat("dd-MM-yyyy hh:mm a").format(reactualstartdate);
          } else {
            reactualsdate = "---";
          }
          if (tripListData[i]["returnActualStartTime"].toString() != "--" &&
              tripListData[i]['returnActualEndTime'] != null) {
            DateTime reactualenddate = DateFormat("yyyy-MM-dd hh:mm")
                .parse(tripListData[i]['returnActualEndTime'])
                .add(const Duration(hours: 5, minutes: 30));
            reactualedate =
                DateFormat("dd-MM-yyyy hh:mm a").format(reactualenddate);
          } else {
            reactualedate = "---";
          }
          var fullname;
          tripListData[i]['driverFirstName'] == null
              ? fullname = ""
              : fullname = tripListData[i]['driverFirstName'];
          tripListData[i]['driverMiddleName'] == null
              ? fullname = fullname + ""
              : fullname = fullname + " " + tripListData[i]['driverMiddleName'];
          tripListData[i]['driverLastName'] == null
              ? fullname = fullname + ""
              : fullname = fullname + " " + tripListData[i]['driverLastName'];
          ListTrip.add(
            {
              "tripId": tripListData[i]['uuid'] ?? "---",
              "TripName": tripListData[i]['tripName'] ?? "---",
              "vehicleName": tripListData[i]['vehicleName'] ?? "---",
              "driverName": fullname == "" ? "---" : fullname,
              "status": tripListData[i]['tripStatus'] ?? "---",
              "isRecurring": tripListData[i]['isRecurring'] ?? "---",
              "category": tripListData[i]['category'] ?? "---",
              "onwardStartDateTime": sdate ?? "---",
              "onwardEndDateTime": edate ?? "---",
              "returnStartDateTime": resdate ?? "---",
              "returnEndDateTime": reedate ?? "---",
              "onwardActualStartDateTime": actualsdate1 ?? "---",
              "onwardActualEndDateTime": actualedate ?? "---",
              "returnActualStartDateTime": reactualsdate ?? "---",
              "returnActualEndDateTime": reactualedate ?? "---"
            },
          );
        } else {
          print("in else:${tripListData[i]['tripStatus']}");
          print(tripListData[i]['uuid']);
          if (tripListData[i]["actualStartTime"].toString() != "--" &&
              tripListData[i]['actualStartTime'] != null) {
            DateTime actualStart = DateFormat("yyyy-MM-dd hh:mm")
                .parse(tripListData[i]['actualStartTime']);
            // .add(const Duration(hours: 5, minutes: 30));
            astart = DateFormat("dd-MM-yyyy hh:mm a").format(actualStart);
          } else {
            astart = "---";
          }
          if (tripListData[i]["actualEndTime"].toString() != "--" &&
              tripListData[i]['actualEndTime'] != null) {
            DateTime actualEnd = DateFormat("yyyy-MM-dd hh:mm")
                .parse(tripListData[i]['actualEndTime']);
            // .add(const Duration(hours: 5, minutes: 30));
            aend = DateFormat("dd-MM-yyyy hh:mm a").format(actualEnd);
          } else {
            aend = "---";
          }
          var fullName;
          tripListData[i]['driverFirstName'] == null
              ? fullName = ""
              : fullName = tripListData[i]['driverFirstName'];
          tripListData[i]['driverMiddleName'] == null
              ? fullName = fullName + ""
              : fullName = fullName + " " + tripListData[i]['driverMiddleName'];
          tripListData[i]['driverLastName'] == null
              ? fullName = fullName + ""
              : fullName = fullName + " " + tripListData[i]['driverLastName'];
          ListTrip.add(
            {
              "tripId": tripListData[i]['uuid'] ?? "---",
              "TripName": tripListData[i]['tripName'] ?? "---",
              "vehicleName": tripListData[i]['vehicleName'] ?? "---",
              "driverName": fullName == "" ? "---" : fullName,
              "status": tripListData[i]['tripStatus'] ?? "---",
              "isRecurring": tripListData[i]['isRecurring'] ?? "---",
              "category": tripListData[i]['category'] ?? "---",
              "onwardStartDateTime": sdate ?? "---",
              "onwardEndDateTime": edate ?? "---",
              "returnStartDateTime": resdate ?? "---",
              "returnEndDateTime": reedate ?? "---",
              // 'actualStartTime': astart ?? "---",
              // 'actualEndTime': aend ?? "---",
              "onwardActualStartDateTime": astart ?? "---",
              "onwardActualEndDateTime": aend ?? "---",
              "returnActualStartDateTime": reactualsdate ?? "---",
              "returnActualEndDateTime": reactualedate ?? "---"
            },
          );
        }
      } else if (tripListData[i]['tripStatus'].toLowerCase() ==
          widget.status.toString().toLowerCase()) {
        k = k + 1;

        print("${k + 1} ${tripListData[i]['tripStatus']}");
        print(tripListData[i]['tripId']);
        if (tripListData[i]["onwardStartDateTime"].toString() != "--" &&
            tripListData[i]["onwardStartDateTime"] != null) {
          DateTime onwardstart1 = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]["onwardStartDateTime"])
              .add(const Duration(hours: 5, minutes: 30));

          // DateTime onwardstart = DateTime.parse(tripData[index]["onwardStartDateTime"]).add(const Duration(hours: 5, minutes: 30));
          sdate = DateFormat("dd-MM-yyyy hh:mm a").format(onwardstart1);
        } else {
          sdate = "---";
        }
        if (tripListData[i]["onwardEndDateTime"].toString() != "--" &&
            tripListData[i]['onwardEndDateTime'] != null) {
          DateTime enddate = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]['onwardEndDateTime'])
              .add(const Duration(hours: 5, minutes: 30));
          edate = DateFormat("dd-MM-yyyy hh:mm a").format(enddate);
        } else {
          edate = "---";
        }
        if (tripListData[i]["returnStartTime"].toString() != "--" &&
            tripListData[i]['returnStartTime'] != null) {
          DateTime restartdate = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]['returnStartTime'])
              .add(const Duration(hours: 5, minutes: 30));
          resdate = DateFormat("dd-MM-yyyy hh:mm a").format(restartdate);
        } else {
          resdate = "---";
        }
        if (tripListData[i]["returnEndDateTime"].toString() != "--" &&
            tripListData[i]['returnEndDateTime'] != null) {
          DateTime reenddate = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]['returnEndDateTime'])
              .add(const Duration(hours: 5, minutes: 30));
          reedate = DateFormat("dd-MM-yyyy hh:mm a").format(reenddate);
        } else {
          reedate = "---";
        }
        if (tripListData[i]["actualStartTime"].toString() != "--" &&
            tripListData[i]['actualStartTime'] != null) {
          DateTime onactualstartdate = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]['actualStartTime']);
          // .add(const Duration(hours: 5, minutes: 30));
          actualsdate =
              DateFormat("dd-MM-yyyy hh:mm a").format(onactualstartdate);
        } else {
          actualsdate = "---";
        }
        print(
            "actual:${tripListData[i]["actualStartTime"].toString()}${tripListData[i]['tripId']}");
        if (tripListData[i]["actualEndTime"].toString() != "--" &&
            tripListData[i]['actualEndTime'] != null) {
          DateTime onactualenddate = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]['actualEndTime']);
          // .add(const Duration(hours: 5, minutes: 30));
          actualedate =
              DateFormat("dd-MM-yyyy hh:mm a").format(onactualenddate);
        } else {
          actualedate = "---";
        }
        if (tripListData[i]["returnActualStartTime"].toString() != "--" &&
            tripListData[i]['returnActualStartTime'] != null) {
          DateTime reactualstartdate = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]['returnActualStartTime'])
              .add(const Duration(hours: 5, minutes: 30));
          reactualsdate =
              DateFormat("dd-MM-yyyy hh:mm a").format(reactualstartdate);
        } else {
          reactualsdate = "---";
        }
        if (tripListData[i]["returnActualStartTime"].toString() != "--" &&
            tripListData[i]['returnActualEndTime'] != null) {
          DateTime reactualenddate = DateFormat("yyyy-MM-dd hh:mm")
              .parse(tripListData[i]['returnActualEndTime'])
              .add(const Duration(hours: 5, minutes: 30));
          reactualedate =
              DateFormat("dd-MM-yyyy hh:mm a").format(reactualenddate);
        } else {
          reactualedate = "---";
        }
        var fullname;
        tripListData[i]['driverFirstName'] == null
            ? fullname = ""
            : fullname = tripListData[i]['driverFirstName'];
        tripListData[i]['driverMiddleName'] == null
            ? fullname = fullname + ""
            : fullname = fullname + " " + tripListData[i]['driverMiddleName'];
        tripListData[i]['driverLastName'] == null
            ? fullname = fullname + ""
            : fullname = fullname + " " + tripListData[i]['driverLastName'];
        print("uuid:${tripListData[i]['tripId']}");
        ListTrip.add(
          {
            "tripId": tripListData[i]['uuid'] ?? "---",
            "TripName": tripListData[i]['tripName'] ?? "---",
            "vehicleName": tripListData[i]['vehicleName'] ?? "---",
            "driverName": fullname == "" ? "---" : fullname,
            "status": tripListData[i]['tripStatus'] ?? "---",
            "isRecurring": tripListData[i]['isRecurring'] ?? "---",
            "category": tripListData[i]['category'] ?? "---",
            "onwardStartDateTime": sdate ?? "---",
            "onwardEndDateTime": edate ?? "---",
            "returnStartDateTime": resdate ?? "---",
            "returnEndDateTime": reedate ?? "---",
            "onwardActualStartDateTime": actualsdate ?? "---",
            "onwardActualEndDateTime": actualedate ?? "---",
            "returnActualStartDateTime": reactualsdate ?? "---",
            "returnActualEndDateTime": reactualedate ?? "---"
          },
        );
      }
    }
    // print("length${ListTrip.length}");
    setState(() {
      ListTrip = ListTrip;
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
        tripListData = tripListData;
        tripData = ListTrip;
      });
    }();
    super.initState();
  }

  void searchFun(String enteredKeyword) {
    List<Map<String, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      setState(() {
        results = ListTrip;
        // usersFiltered = results;
      });
    } else {
      results = ListTrip.where((person) =>
              person["TripName"]
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
              person["onwardStartDateTime"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["onwardEndDateTime"]
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
              person["status"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["tripId"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")))
          .toList();
    }
    // // Refresh the UI
    setState(() {
      tripData = results;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    // print("in build");
    return Scaffold(
        key: _key,
        drawer: const NavBar(),
        appBar: AppBar(
          elevation: 0,
          toolbarHeight: 80,
          leading: Padding(padding: EdgeInsets.only(top: 25), child: _appBar()),
          title: Padding(
              padding: EdgeInsets.only(top: 35, left: 25),
              child: Column(children: [
                Text(translation(context).tripsOverview),
                Text(DateFormat.yMMMEd().format(DateTime.now())),
              ])),
        ),
        backgroundColor: const Color(0xFFEAEAEA),
        body: Container(
            color: const Color(0xFFEAEAEA),
            child: Scaffold(
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
                            borderRadius: BorderRadius.all(Radius.circular(5)),
                          ),
                          child: GestureDetector(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Container(
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
                                                tripData = ListTrip;
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
                                  height: 100,
                                  width: 340,
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
                height: MediaQuery.of(context).size.height * .757,
                child: loader
                    ? const Center(
                        child: CircularProgressIndicator(
                          semanticsLabel: "right",
                        ),
                      )
                    : tripData.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
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
                            itemCount: tripData.length,
                            separatorBuilder: (context, index) {
                              return const SizedBox(
                                height: 5,
                              );
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                margin: const EdgeInsets.fromLTRB(5, 15, 8, 0),
                                width: MediaQuery.of(context).size.width * .94,
                                height: clickeddeleteButton
                                    ? MediaQuery.of(context).size.height * .48
                                    : MediaQuery.of(context).size.height * .48,
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
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 10, 0, 1),
                                          child: SizedBox(
                                            child: Text(
                                              "Trip Id",
                                              style: TripsPageTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 15, 10, 5),
                                          child: SizedBox(
                                            child: Text(
                                              tripData[index]["tripId"]
                                                          .toString() ==
                                                      "null"
                                                  ? '____'
                                                  : tripData[index]["tripId"]
                                                      .toString(),
                                              style:
                                                  vehiclePageCardTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      thickness: 1,
                                    ),
                                    // SizedBox(
                                    //   height: 5,
                                    // ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 5),
                                          child: SizedBox(
                                            child: Text(
                                              "Trip Name",
                                              style: TripsPageTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 5),
                                          child: SizedBox(
                                            child: Text(
                                              tripData[index]["TripName"]
                                                          .toString() ==
                                                      'null'
                                                  ? '____'
                                                  : tripData[index]["TripName"]
                                                      .toString(),
                                              style:
                                                  vehiclePageCardTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      thickness: 1,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 5),
                                          child: SizedBox(
                                            child: Text(
                                              "Driver Name",
                                              style: TripsPageTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 5),
                                          child: SizedBox(
                                            child: Text(
                                              tripData[index]["driverName"]
                                                          .toString() ==
                                                      "null"
                                                  ? "____"
                                                  : tripData[index]
                                                          ["driverName"]
                                                      .toString(),
                                              style:
                                                  vehiclePageCardTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      thickness: 1,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 5),
                                          child: SizedBox(
                                            child: Text(
                                              "Vehicle Name",
                                              style: TripsPageTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 5),
                                          child: SizedBox(
                                            child: Text(
                                              tripData[index]["vehicleName"]
                                                          .toString() ==
                                                      "null"
                                                  ? "____"
                                                  : tripData[index]
                                                          ["vehicleName"]
                                                      .toString(),
                                              style:
                                                  vehiclePageCardTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      thickness: 1,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 5),
                                          child: SizedBox(
                                            child: Text(
                                              "Status",
                                              style: TripsPageTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 5),
                                          child: SizedBox(
                                            child: Card(
                                              // shape: S,
                                              color: tripData[index]
                                                          ['status'] ==
                                                      "In Progress"
                                                  ? InprogressBackgroundColor
                                                  : tripData[index]['status'] ==
                                                          "Completed"
                                                      ? CompletedBackgroundColor
                                                      : tripData[index]
                                                                  ['status'] ==
                                                              "Cancelled"
                                                          ? CancelledBackgroundColor
                                                          : tripData[index][
                                                                      'status'] ==
                                                                  "Not Started"
                                                              ? NotStartedBackgroundColor
                                                              : unplannedBackgroundColor,
                                              child: Text(
                                                tripData[index]['status']
                                                    .toString(),
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w700,
                                                    color: tripData[index]
                                                                ['status'] ==
                                                            "In Progress"
                                                        ? InprogressTextColor
                                                        : tripData[index][
                                                                    'status'] ==
                                                                "Completed"
                                                            ? CompletedTextColor
                                                            : tripData[index][
                                                                        'status'] ==
                                                                    "Cancelled"
                                                                ? CancelledTextColor
                                                                : tripData[index]
                                                                            [
                                                                            'status'] ==
                                                                        "Not Started"
                                                                    ? NotStartedTextColor
                                                                    : unplannedTextColor),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Divider(
                                      thickness: 1,
                                    ),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              10, 0, 0, 5),
                                          child: SizedBox(
                                            child: Text(
                                              "Category",
                                              style: TripsPageTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: const EdgeInsets.fromLTRB(
                                              0, 0, 10, 5),
                                          child: SizedBox(
                                            child: Text(
                                              tripData[index]["category"]
                                                  .toString(),
                                              style:
                                                  vehiclePageCardTextSubHeadStyle,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      margin: const EdgeInsets.fromLTRB(
                                          10, 10, 10, 10),
                                      padding: const EdgeInsets.fromLTRB(
                                          0, 10, 0, 10),
                                      width: MediaQuery.of(context).size.width *
                                          0.97,
                                      height:
                                          MediaQuery.of(context).size.height *
                                              0.1,
                                      decoration: BoxDecoration(
                                        borderRadius: const BorderRadius.all(
                                            Radius.circular(10)),
                                        color: const Color(0xFF6197CA)
                                            .withOpacity(.1),
                                      ),
                                      child: SingleChildScrollView(
                                        scrollDirection: Axis.horizontal,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              children: [
                                                tripData[index]['category']
                                                                .toString()
                                                                .toLowerCase() ==
                                                            "one way" &&
                                                        tripData[index][
                                                                    'tripStatus']
                                                                .toString()
                                                                .toLowerCase() !=
                                                            "Default"
                                                    ? SizedBox(
                                                        width: 180,
                                                        child: Text("Onward",
                                                            style:
                                                                TripsPageTextSubHeadStyle),
                                                      )
                                                    : tripData[index]['category']
                                                                    .toString()
                                                                    .toLowerCase() !=
                                                                "one way" &&
                                                            tripData[index][
                                                                        'tripStatus']
                                                                    .toString()
                                                                    .toLowerCase() ==
                                                                "Default"
                                                        ? SizedBox(
                                                            width: 180,
                                                            child: Text(
                                                                "Actual",
                                                                style:
                                                                    TripsPageTextSubHeadStyle),
                                                          )
                                                        : SizedBox(),
                                                SizedBox(
                                                  width: 180,
                                                ),
                                                tripData[index]['category']
                                                            .toString()
                                                            .toLowerCase() ==
                                                        "one way"
                                                    ? SizedBox()
                                                    : Text("Return",
                                                        style:
                                                            TripsPageTextSubHeadStyle),
                                              ],
                                            ),
                                            tripData[index]['category']
                                                        .toString()
                                                        .toLowerCase() ==
                                                    "one way"
                                                ? Table(
                                                    columnWidths: {
                                                      0: FixedColumnWidth(70),
                                                      1: FixedColumnWidth(150),
                                                      2: FixedColumnWidth(150),
                                                      3: FixedColumnWidth(150),
                                                    },
                                                    defaultColumnWidth:
                                                        const FixedColumnWidth(
                                                            150.0),
                                                    border: TableBorder.all(
                                                        color:
                                                            Colors.transparent),
                                                    children: [
                                                      TableRow(children: [
                                                        const Text("Planned:",
                                                            style:
                                                                TripsPageTextSubHeadStyle),
                                                        Text(
                                                          tripData[index][
                                                                      "onwardStartDateTime"] ==
                                                                  "null"
                                                              ? "____"
                                                              : tripData[index][
                                                                  "onwardStartDateTime"],
                                                        ),
                                                        Text(
                                                          tripData[index]["onwardEndDateTime"]
                                                                      .toString() ==
                                                                  "null"
                                                              ? "____"
                                                              : tripData[index][
                                                                      "onwardEndDateTime"]
                                                                  .toString(),
                                                        ),
                                                      ]),
                                                      TableRow(children: [
                                                        const Text("Actual:",
                                                            style:
                                                                TripsPageTextSubHeadStyle),
                                                        Text(
                                                          tripData[index]["onwardActualStartDateTime"]
                                                                      .toString() ==
                                                                  "null"
                                                              ? "____"
                                                              : tripData[index][
                                                                      "onwardActualStartDateTime"]
                                                                  .toString(),
                                                        ),
                                                        Text(
                                                          tripData[index]["onwardActualEndDateTime"]
                                                                      .toString() ==
                                                                  "null"
                                                              ? "____"
                                                              : tripData[index][
                                                                      "onwardActualEndDateTime"]
                                                                  .toString(),
                                                        ),
                                                      ])
                                                    ],
                                                  )
                                                : tripData[index]['tripStatus']
                                                            .toString()
                                                            .toLowerCase() ==
                                                        "Default"
                                                    ? Table(
                                                        columnWidths: {
                                                          0: FixedColumnWidth(
                                                              70),
                                                          1: FixedColumnWidth(
                                                              150),
                                                          2: FixedColumnWidth(
                                                              150),
                                                          3: FixedColumnWidth(
                                                              150),
                                                        },
                                                        defaultColumnWidth:
                                                            const FixedColumnWidth(
                                                                150.0),
                                                        border: TableBorder.all(
                                                            color: Colors
                                                                .transparent),
                                                        children: [
                                                          TableRow(children: [
                                                            Text(
                                                              tripData[index][
                                                                          "actualStartTime"] ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[
                                                                          index]
                                                                      [
                                                                      "actualStartTime"],
                                                            ),
                                                            Text(
                                                              tripData[index]["actualEndTime"]
                                                                          .toString() ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[index]
                                                                          [
                                                                          "actualEndTime"]
                                                                      .toString(),
                                                            ),
                                                          ]),
                                                        ],
                                                      )
                                                    : Table(
                                                        columnWidths: {
                                                          0: FixedColumnWidth(
                                                              70),
                                                          1: FixedColumnWidth(
                                                              150),
                                                          2: FixedColumnWidth(
                                                              150),
                                                          3: FixedColumnWidth(
                                                              150),
                                                        },
                                                        defaultColumnWidth:
                                                            const FixedColumnWidth(
                                                                150.0),
                                                        border: TableBorder.all(
                                                            color: Colors
                                                                .transparent),
                                                        children: [
                                                          TableRow(children: [
                                                            const Text(
                                                                "Planned:",
                                                                style:
                                                                    TripsPageTextSubHeadStyle),
                                                            Text(
                                                              tripData[index]["onwardStartDateTime"]
                                                                          .toString() ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[index]
                                                                          [
                                                                          "onwardStartDateTime"]
                                                                      .toString(),
                                                            ),
                                                            Text(
                                                              tripData[index]["onwardEndDateTime"]
                                                                          .toString() ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[index]
                                                                          [
                                                                          "onwardEndDateTime"]
                                                                      .toString(),
                                                            ),
                                                            Text(
                                                              tripData[index]["returnStartDateTime"]
                                                                          .toString() ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[index]
                                                                          [
                                                                          "returnStartDateTime"]
                                                                      .toString(),
                                                            ),
                                                            Text(
                                                              tripData[index]["returnEndDateTime"]
                                                                          .toString() ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[index]
                                                                          [
                                                                          "returnEndDateTime"]
                                                                      .toString(),
                                                            )
                                                          ]),
                                                          TableRow(children: [
                                                            const Text(
                                                                "Actual:",
                                                                style:
                                                                    TripsPageTextSubHeadStyle),
                                                            Text(
                                                              tripData[index]["onwardActualStartDateTime"]
                                                                          .toString() ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[index]
                                                                          [
                                                                          "onwardActualStartDateTime"]
                                                                      .toString(),
                                                            ),
                                                            Text(
                                                              tripData[index]["onwardActualEndDateTime"]
                                                                          .toString() ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[index]
                                                                          [
                                                                          "onwardActualEndDateTime"]
                                                                      .toString(),
                                                            ),
                                                            Text(
                                                              tripData[index]["returnActualStartDateTime"]
                                                                          .toString() ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[index]
                                                                          [
                                                                          "returnActualStartDateTime"]
                                                                      .toString(),
                                                            ),
                                                            Text(
                                                              tripData[index]['returnActualEndDateTime']
                                                                          .toString() ==
                                                                      "null"
                                                                  ? "____"
                                                                  : tripData[index]
                                                                          [
                                                                          'returnActualEndDateTime']
                                                                      .toString(),
                                                            ),
                                                          ])
                                                        ],
                                                      ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            }),
              )
            ])))));
  }

  @override
  void dispose() {
    // print("dispose");
    super.dispose();
  }
}

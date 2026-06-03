import 'dart:developer';
import 'dart:io';
import 'package:admin_app/screens/themes.dart';
import 'package:admin_app/screens/tracking_screen/live_track.dart';
import 'package:admin_app/screens/tracking_screen/vehicletracking.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/container.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../../api/api.dart';
import '../tripScreens/managetripscreen.dart';

class TrackListScreen extends StatefulWidget {
  const TrackListScreen({super.key});

  @override
  State<TrackListScreen> createState() => _TrackListScreenState();
}

var pickedTime = null;
var pickedDate = null;
String? formatteddateandtime;
final _formKey = GlobalKey<FormState>();
int difference = 0;
var shareDuration = TextEditingController();
var shareStart = TextEditingController();
var PhoneNumbers = TextEditingController();
var emailId = TextEditingController();
var sharePurpose = TextEditingController();
bool isLoading = false;
bool isError = false;
var errormessage;
List<Map<dynamic, dynamic>> _finaldata = [];
List<Map<dynamic, dynamic>> _finaldatatemp = [];
List<Map<dynamic, dynamic>> _data = [];
List<Map<dynamic, dynamic>> _datacurrentdate = [];
List<Map<dynamic, dynamic>> _datacustomrangedate = [];
DateFormat dateFormat = DateFormat("yyyy-MM-dd");
List<String> dropDown = <String>["Current Date", "All Trips", "Date Range"];
String? dropDownselected = "Current Date";
DateTimeRange? datepicked;
bool isdataempty = false;
DateTimeRange? _datepicker;

Future<void> sharetriplocation(BuildContext context, tripId) async {
  final prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var Id = int.parse(userId!);
  const sharelocationurl = "${baseUrl}info/share-location";
  formatteddateandtime = DateFormat("yyyy-MM-dd HH:mm:ss")
      .parse(formatteddateandtime!)
      .subtract(Duration(minutes: 329))
      .toString();
  var data = {
    "tripId": tripId,
    "sharePurpose": sharePurpose.text == "" ? null : sharePurpose.text,
    "shareDuration": shareDuration.text == "" ? null : shareDuration.text,
    "shareCreatedBy": Id,
    "shareStart": formatteddateandtime == "" ? null : formatteddateandtime,
    "PhoneNos": PhoneNumbers.text == "" ? null : PhoneNumbers.text,
    "emailIds": emailId.text == "" ? null : emailId.text
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

class _TrackListScreenState extends State<TrackListScreen> {
  @override
  void initState() {
    setState(() {
      isLoading = true;
    });
        () async {
      await _getData();
      await ondropdownchange("Current Date");
      setState(() {
        _finaldatatemp = _finaldata;
        isLoading = false;
      });
    }();
    super.initState();
  }

  void searchfilter(String enteredKeyword) {
    List<Map<dynamic, dynamic>> resultsdata = [];
    if (enteredKeyword.isEmpty) {
      // print(dropDownselected);
      if (dropDownselected == "Current Date") {
        resultsdata = _finaldatatemp;
      } else if (dropDownselected == "All Trips") {
        resultsdata = _data;
      } else if (dropDownselected == "Date Range") {
        resultsdata = _datacustomrangedate;
      }
    } else {
      if (dropDownselected == "Current Date") {
        _finaldatatemp = _finaldatatemp;
      } else if (dropDownselected == "All Trips") {
        _finaldatatemp = _data;
      } else if (dropDownselected == "Date Range") {
        _finaldatatemp = _datacustomrangedate;
      }
      resultsdata = _finaldatatemp
          .where((trips) =>
      trips["tripName"]
          .toString()
          .toLowerCase()
          .replaceAll(" ", "")
          .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
          trips["vehicleName"]
              .toString()
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
          trips["driverName"]
              .toString()
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
          trips["tripStatus"]
              .toString()
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
          trips["onwardStartDateTime"]
              .toString()
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
          trips["actualStartTime"]
              .toString()
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
          trips["plannedorunplanned"]
              .toString()
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
          trips["actualEndTime"]
              .toString()
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
          trips["uuid"]
              .toString()
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
          trips["onwardEndDateTime"]
              .toString()
              .toLowerCase()
              .replaceAll(" ", "")
              .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")))
          .toList();
    }
    // print("In search");
    // for (var i in resultsdata) {
    // print("result Data records: ${resultsdata}");
    // }
    setState(() {
      _finaldata = resultsdata;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading == true) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    } else {
      return Column(
        children: [
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: blueColor,
                style: BorderStyle.solid,
                width: 7.0,
              ),
            ),
            height: 70,
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Flexible(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(),
                    child: TextField(
                      onChanged: (val) {
                        searchfilter(val);
                      },
                      cursorColor: Colors.grey.shade100,
                      decoration: InputDecoration(
                          fillColor: Colors.white,
                          filled: true,
                          border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none),
                          hintText: 'Search',
                          hintStyle:
                          TextStyle(color: Colors.grey, fontSize: 18),
                          prefixIcon: Container(
                            padding: EdgeInsets.all(15),
                            child: Image.asset('images/search.png'),
                            width: 18,
                          )),
                    ),
                  ),
                ),
                DropdownButton<String>(
                    dropdownColor: Colors.blue,
                    value: dropDownselected,
                    underline: Container(),
                    icon: const Icon(Icons.sort, color: Colors.grey),
                    items:
                    dropDown.map<DropdownMenuItem<String>>((String value) {
                      if (value == "Date Range") {
                        return DropdownMenuItem(
                          onTap: () async {},
                          value: value,
                          child: Text(value),
                        );
                      } else {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }
                    }).toList(),
                    onChanged: (String? value) async {
                      if (value != null) {
                        setState(() {
                          isLoading = true;
                          dropDownselected = value;
                        });

                        await ondropdownchange(value);
                      }
                    })
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                color: blueColor,
                style: BorderStyle.solid,
                width: 10.0,
              ),
            ),
          ),
          Expanded(
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
                : _finaldata.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  LottieBuilder.asset("images/no-data-found.json"),
                  const Text("No data available"),
                ],
              ),
            )
                : ListView.separated(
                itemBuilder: (ctx, i) {
                  print(
                      "final data length in listview ${_finaldata.length}");
                  DateTime? startdate;
                  DateTime? enddate;
                  DateTime? expectedStartDate;
                  DateTime? expectedEndDate;
                  if (_finaldata[i]["plannedorunplanned"]
                      .toString()
                      .toUpperCase() ==
                      "PLANNED") {
                    if (_finaldata[i]["expectedStartTime"].toString() != "----") {
                      expectedStartDate = DateFormat("yyyy-MM-dd h:mm")
                          .parse(_finaldata[i]["expectedStartTime"])
                          .add(Duration(hours: 5, minutes: 30))
                          .toLocal();
                    }
                    if (_finaldata[i]["expectedEndTime"].toString() != "----") {
                      expectedEndDate = DateFormat("yyyy-MM-dd h:mm")
                          .parse(_finaldata[i]["expectedEndTime"])
                          .add(Duration(hours: 5, minutes: 30))
                          .toLocal();
                    }
                  } else {
                    if (_finaldata[i]["onwardStartDateTime"].toString() !=
                        "----") {
                      startdate = DateFormat("yyyy-MM-dd h:mm")
                          .parse(_finaldata[i]["onwardStartDateTime"])
                          .add(Duration(hours: 5, minutes: 30))
                          .toLocal();
                    }
                    if (_finaldata[i]["onwardEndDateTime"].toString() != "----") {
                      enddate = DateFormat("yyyy-MM-dd h:mm")
                          .parse(_finaldata[i]["onwardEndDateTime"])
                          .add(Duration(hours: 5, minutes: 30))
                          .toLocal();
                    }
                  }
                  var dateFormat1 = DateFormat("dd-MM-yyyy hh:mm a");
                  var actualStartTime;
                  // print(
                  //     "actulaStartTime ${_finaldata[index]["actualStartTime"]}");
                  if (_finaldata[i]["actualStartTime"] != null &&
                      _finaldata[i]["actualStartTime"] != "null" &&
                      _finaldata[i]["actualStartTime"] != "----") {
                    // print(
                    //     "actulaStartTime not nulll ${_finaldata[index]["actualStartTime"]}");

                    actualStartTime = dateFormat1.format(DateTime.parse(
                        _finaldata[i]["actualStartTime"]));
                    // print("in value isss nulll $actualStartTime");
                  }
                  var actualEndTime;

                  if (_finaldata[i]["actualEndTime"] != null &&
                      _finaldata[i]["actualEndTime"] != "null" &&
                      _finaldata[i]["actualEndTime"] != "----") {
                    actualEndTime = dateFormat1.format(
                        DateTime.parse(_finaldata[i]["actualEndTime"]));
                  }
                  // print("actualEndTime: ${actualEndTime}");
                  return Container(
                    decoration: BoxDecoration(
                      // borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          offset: const Offset(0, 2),
                          // blurRadius: 2,
                          color: Colors.blue.withOpacity(0.1),
                        ),
                      ],
                    ),
                    child: Card(
                      borderOnForeground: true,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15.0),
                        side: BorderSide(
                          color: Colors.grey,
                          width: 1.0,
                        ),
                      ),
                      margin: const EdgeInsets.all(15.0),
                      // elevation: 2,
                      child: Column(
                        children: [
                          Row(
                            // mainAxisAlignment:
                            //     MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Trip Name'),
                                ),
                              ),
                              // Text("Trip Name"),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    _finaldata[i]["tripName"] != null
                                        ? _finaldata[i]["tripName"]
                                        .toString()
                                        : "--",
                                    style:
                                    vehiclePageCardTextSubHeadStyle,
                                  ),
                                ),
                              ),
                              // Container(
                              //     width: 250,
                              //     child: Expanded(
                              //       child: Text(
                              //         _finaldata[index]["tripName"],
                              //         overflow: TextOverflow.ellipsis,
                              //         textAlign: TextAlign.end,
                              //         style: TextStyle(
                              //             fontWeight: FontWeight.bold),
                              //       ),
                              //     )),
                            ],
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Trip Id'),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    _finaldata[i]["uuid"] != null
                                        ? _finaldata[i]["uuid"]
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
                            thickness: 1,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Vehicle Name'),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    _finaldata[i]["vehicleName"] != null
                                        ? _finaldata[i]["vehicleName"]
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
                            thickness: 1,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Driver Name'),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    _finaldata[i]["driverName"] != null
                                        ? _finaldata[i]["driverName"]
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
                            thickness: 1,
                          ),
                          Row(
                            // crossAxisAlignment: CrossAxisAlignment.center,
                            // mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Container(
                                width: 46.w,
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Trip status'),
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Container(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    _finaldata[i]["tripStatus"],
                                    style: _finaldata[i]["tripStatus"]
                                        .toString()
                                        .replaceAll(" ", '')
                                        .toLowerCase() ==
                                        "inprogress"
                                        ? InprogressTextStyle
                                        : _finaldata[i]["tripStatus"]
                                        .toString()
                                        .replaceAll(" ", '')
                                        .toLowerCase() ==
                                        "cancelled"
                                        ? CancelledTextStyle
                                        : _finaldata[i]["tripStatus"]
                                        .toString()
                                        .replaceAll(
                                        " ", '')
                                        .toLowerCase() ==
                                        "notstarted"
                                        ? NotStartedTextStyle
                                        : CompletedTextStyle,
                                  ),
                                  decoration: BoxDecoration(
                                    borderRadius:
                                    BorderRadius.circular(15),
                                    color: _finaldata[i]["tripStatus"]
                                        .toString()
                                        .replaceAll(" ", '')
                                        .toLowerCase() ==
                                        "inprogress"
                                        ? color =
                                        InprogressBackgroundColor
                                        : _finaldata[i]["tripStatus"]
                                        .toString()
                                        .replaceAll(" ", '')
                                        .toLowerCase() ==
                                        "cancelled"
                                        ? color =
                                        CancelledBackgroundColor
                                        : _finaldata[i]["tripStatus"]
                                        .toString()
                                        .replaceAll(
                                        " ", '')
                                        .toLowerCase() ==
                                        "notstarted"
                                        ? color =
                                        NotStartedBackgroundColor
                                        : CompletedBackgroundColor,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            thickness: 1,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('Trip Type '),
                                ),
                              ),
                              Expanded(
                                child: Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text(
                                    _finaldata[i]["plannedorunplanned"]
                                        .toString()
                                        .toUpperCase() ==
                                        "PLANNED"
                                        ? "Planned trip"
                                        : "Unplanned trip",
                                    style:
                                    vehiclePageCardTextSubHeadStyle,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(
                            thickness: 1,
                          ),
                          Container(
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _finaldata[i]["plannedorunplanned"]
                                          .toString()
                                          .toUpperCase() ==
                                          "PLANNED"
                                          ? "Planned Start Date "
                                          : "Start Date",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      _finaldata[i]["plannedorunplanned"]
                                          .toString()
                                          .toUpperCase() ==
                                          "PLANNED"
                                          ? _finaldata[i][
                                      "expectedStartTime"] !=
                                          "----"
                                          ? dateFormat1.format(
                                          expectedStartDate!)
                                          : "----"
                                          : startdate != null
                                          ? dateFormat1
                                          .format(startdate!)
                                          : "----",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                ),
                                // Container(
                                //   color: Colors.black45,
                                //   height: 40,
                                //   width: 1,
                                // ),
                                Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      _finaldata[i]["plannedorunplanned"]
                                          .toString()
                                          .toUpperCase() ==
                                          "PLANNED"
                                          ? "Planned End Date"
                                          : "End Date",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      _finaldata[i]["plannedorunplanned"]
                                          .toString()
                                          .toUpperCase() ==
                                          "PLANNED"
                                          ? expectedEndDate != "----" &&
                                          expectedEndDate !=
                                              null
                                          ? dateFormat1.format(
                                          expectedEndDate!)
                                          : "----"
                                          : enddate != "----" &&
                                          enddate != null
                                          ? dateFormat1
                                          .format(enddate!)
                                          : "----",
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            ),
                          ),
                          _finaldata[i]["tripStatus"] == "Completed"
                              ? Container(
                            margin: EdgeInsets.only(top: 10),
                            height: 50,
                            decoration: BoxDecoration(
                                color: Colors.blue.shade50,
                                borderRadius:
                                BorderRadius.circular(10)),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Actual Start Date",
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      actualStartTime != null
                                          ? actualStartTime
                                          : "----",
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.bold),
                                    )
                                  ],
                                ),
                                // Container(
                                //   color: Colors.black45,
                                //   height: 40,
                                //   width: 1,
                                // ),
                                Column(
                                  mainAxisAlignment:
                                  MainAxisAlignment.center,
                                  crossAxisAlignment:
                                  CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      "Actual End Date",
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                    SizedBox(
                                      height: 10,
                                    ),
                                    Text(
                                      actualEndTime != null
                                          ? actualEndTime
                                          : "----",
                                      style: TextStyle(
                                          fontWeight:
                                          FontWeight.bold),
                                    )
                                  ],
                                )
                              ],
                            ),
                          )
                              : Container(),
                          _finaldata[i]["tripStatus"]
                              .toString()
                              .replaceAll(" ", '')
                              .toLowerCase() ==
                              "inprogress"
                              ? Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              TextButton(
                                style: ButtonStyle(
                                    elevation:
                                    MaterialStateProperty.all(
                                        2),
                                    backgroundColor:
                                    MaterialStateProperty.all(
                                        Colors.blue)),
                                onPressed: () async {
                                  print(
                                      "data passed to Livetrackscreen:${_finaldata[i]}");
                                  // print(
                                  //     "Selected Trip: ${_finaldata[index]}");
                                  Navigator.of(context).push(
                                      MaterialPageRoute(
                                          builder: (context) {
                                            return LiveTrackScreen(
                                              trackdata: _finaldata[i],
                                            );
                                          }));
                                },
                                child: Row(
                                  children: const [
                                    Image(
                                        height: 20,
                                        image: AssetImage(
                                            "images/livelocation.png")),
                                    Text(
                                      "Live Location",
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight:
                                          FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          )
                              : _finaldata[i]["tripStatus"]
                              .toString()
                              .replaceAll(" ", '')
                              .toLowerCase() ==
                              "completed"
                              ? Row(
                            mainAxisAlignment:
                            MainAxisAlignment.spaceEvenly,
                            children: [
                              Padding(
                                padding: EdgeInsets.all(8.0),
                                child: TextButton(
                                    style: ButtonStyle(
                                        elevation:
                                        MaterialStateProperty
                                            .all(2),
                                        backgroundColor:
                                        MaterialStateProperty
                                            .all(Colors
                                            .blue)),
                                    onPressed: () async {
                                      print(
                                          "_final Data for Navigator: ${_finaldata}");
                                      Navigator.of(context).push(
                                          MaterialPageRoute(
                                              builder:
                                                  (context) {
                                                return VehicleTracking(
                                                  trackdata:
                                                  _finaldata[i],
                                                );
                                              }));
                                    },
                                    child: Row(
                                      children: const [
                                        Image(
                                            height: 20,
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
                              ),
                            ],
                          )
                              : const Divider(
                            thickness: 1,
                          ),
                          _finaldata[i]["tripStatus"]
                              .toString()
                              .replaceAll(" ", '')
                              .toLowerCase() ==
                              "inprogress" ||
                              _finaldata[i]["tripStatus"]
                                  .toString()
                                  .replaceAll(" ", '')
                                  .toLowerCase() ==
                                  "completed" ||
                              _finaldata[i]["tripStatus"]
                                  .toString()
                                  .replaceAll(" ", '')
                                  .toLowerCase() ==
                                  "notstarted"
                              ? Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Row(
                              mainAxisAlignment:
                              MainAxisAlignment.end,
                              children: [
                                Text("Share Location"),
                                IconButton(
                                    onPressed: () async {
                                      _formKey.currentState
                                          ?.reset();
                                      pickedDate = null;
                                      pickedTime = null;
                                      sharePurpose.text = "";
                                      shareDuration.text = "";
                                      PhoneNumbers.text = "";
                                      emailId.text = "";
                                      shareStart.clear();
                                      // print(
                                      //     "_final data: ${_finaldata[index]}");
                                      // print(
                                      //     "sharePurpose:  ${sharePurpose.text}");
                                      // print(
                                      //     "shareDuration:  ${shareDuration.text}");
                                      // print(
                                      //     "sharePurpose:  ${PhoneNumbers.text}");
                                      // print(
                                      //     "emailid:  ${emailId.text}");
                                      showDialog(
                                          context: context,
                                          builder:
                                              (BuildContext ctx) {
                                            return Form(
                                              key: _formKey,
                                              child: AlertDialog(
                                                scrollable: true,
                                                title: Row(
                                                  mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                                  children: [
                                                    const Text(
                                                        'Share Location'),
                                                    IconButton(
                                                      onPressed:
                                                          () {
                                                        Navigator
                                                            .pop(
                                                            ctx);
                                                      },
                                                      icon: const Icon(
                                                          Icons
                                                              .close_outlined),
                                                      color: Colors
                                                          .red,
                                                    )
                                                  ],
                                                ),
                                                content: Padding(
                                                  padding:
                                                  const EdgeInsets
                                                      .all(
                                                      8.0),
                                                  child: Column(
                                                    children: <
                                                        Widget>[
                                                      TextFormField(
                                                        validator:
                                                            (value) {
                                                          if (value ==
                                                              null) {
                                                            return "Share Purpose is required";
                                                          }
                                                          return null;
                                                        },
                                                        controller:
                                                        sharePurpose,
                                                        decoration:
                                                        InputDecoration(
                                                          label:
                                                          Row(
                                                            children: [
                                                              const Text('*',
                                                                  style: TextStyle(color: Colors.red)),
                                                              Padding(
                                                                padding: EdgeInsets.all(3.0),
                                                              ),
                                                              Text("Share Purpose")
                                                            ],
                                                          ),
                                                          icon: Icon(
                                                              Icons.share_location_rounded),
                                                        ),
                                                      ),
                                                      TextFormField(
                                                        validator:
                                                            (value) {
                                                          if (value ==
                                                              null) {
                                                            return "Share Duration is required";
                                                          }
                                                          return null;
                                                        },
                                                        controller:
                                                        shareDuration,
                                                        keyboardType:
                                                        TextInputType
                                                            .number,
                                                        decoration:
                                                        InputDecoration(
                                                          label:
                                                          Row(
                                                            children: [
                                                              const Text('*',
                                                                  style: TextStyle(color: Colors.red)),
                                                              Padding(
                                                                padding: EdgeInsets.all(3.0),
                                                              ),
                                                              Text("Share Duration")
                                                            ],
                                                          ),
                                                          icon: Icon(
                                                              Icons.timelapse_outlined),
                                                        ),
                                                      ),
                                                      TextFormField(
                                                        validator:
                                                            (value) {
                                                          if (value ==
                                                              null) {
                                                            return "Phone Nos is required";
                                                          }
                                                          return null;
                                                        },
                                                        controller:
                                                        PhoneNumbers,
                                                        decoration:
                                                        InputDecoration(
                                                          label:
                                                          Row(
                                                            children: [
                                                              const Text('*',
                                                                  style: TextStyle(color: Colors.red)),
                                                              Padding(
                                                                padding: EdgeInsets.all(3.0),
                                                              ),
                                                              Text("Phone Numbers")
                                                            ],
                                                          ),
                                                          icon: Icon(
                                                              Icons.phone),
                                                        ),
                                                      ),
                                                      TextFormField(
                                                        autovalidateMode:
                                                        AutovalidateMode
                                                            .onUserInteraction,
                                                        validator:
                                                            (value) {
                                                          if (value ==
                                                              null) {
                                                            return "Atleast one Email Id is required";
                                                          }
                                                          return null;
                                                        },
                                                        controller:
                                                        emailId,
                                                        decoration:
                                                        InputDecoration(
                                                          label:
                                                          Row(
                                                            children: [
                                                              const Text('*',
                                                                  style: TextStyle(color: Colors.red)),
                                                              Padding(
                                                                padding: EdgeInsets.all(3.0),
                                                              ),
                                                              Text("Email Addresses")
                                                            ],
                                                          ),
                                                          icon: Icon(
                                                              Icons.email_outlined),
                                                        ),
                                                      ),
                                                      TextFormField(
                                                        validator:
                                                            (value) {
                                                          if (value ==
                                                              null) {
                                                            return "Sharing date is required";
                                                          }
                                                          return null;
                                                        },
                                                        controller:
                                                        shareStart,
                                                        // initialValue:
                                                        //     formatteddateandtime ??
                                                        //         "",
                                                        keyboardType:
                                                        TextInputType
                                                            .none,
                                                        onTap:
                                                            () async {
                                                          String?
                                                          formattedDate;
                                                          String?
                                                          formattedTime;
                                                          pickedDate =
                                                          await showDatePicker(
                                                            context:
                                                            context,
                                                            initialDate:
                                                            DateTime.now().toLocal(),
                                                            firstDate:
                                                            DateTime.now().toLocal(),
                                                            lastDate: DateTime.now()
                                                                .toLocal()
                                                                .add(const Duration(days: 900)),
                                                          );
                                                          if (pickedDate !=
                                                              null) {
                                                            formattedDate =
                                                                DateFormat('yyyy-MM-dd').format(pickedDate);
                                                            pickedTime = await showTimePicker(
                                                                context: context,
                                                                initialTime: TimeOfDay.fromDateTime(DateTime.now()));
                                                            // print(
                                                            //     "selected date: ${pickedDate.toString()}");

                                                            if (pickedTime !=
                                                                null) {
                                                              formattedTime = pickedTime.hour.toString() +
                                                                  ":" +
                                                                  pickedTime.minute.toString() +
                                                                  ":" +
                                                                  "59";
                                                              // print("formattedTime: ${formattedTime}");
                                                              formatteddateandtime =
                                                              "$formattedDate $formattedTime";
                                                              // print("formatteddateandtime: ${formatteddateandtime}");
                                                              DateTime
                                                              a =
                                                              DateFormat("yyyy-MM-dd HH:mm:ss").parse(formatteddateandtime!);
                                                              // print("a date: ${a.toString()}");
                                                              DateTime
                                                              b =
                                                              DateTime.now();
                                                              // DateTime.now().add(Duration(minutes: 330));
                                                              // print("b datetime now: ${b.toString()}");
                                                              difference =
                                                              0;
                                                              difference =
                                                                  b.difference(a).inMinutes;
                                                              // print("difference: ${difference}");
                                                              setState(() {
                                                                shareStart.text = formatteddateandtime ?? "";
                                                              });
                                                            }
                                                          } else {
                                                            return null;
                                                          }
                                                        },
                                                        decoration:
                                                        InputDecoration(
                                                          label:
                                                          Row(
                                                            children: [
                                                              const Text('*',
                                                                  style: TextStyle(color: Colors.red)),
                                                              Padding(
                                                                padding: EdgeInsets.all(3.0),
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
                                                      child: const Text(
                                                          "Submit"),
                                                      onPressed:
                                                          () async {
                                                        if (pickedTime == null ||
                                                            pickedDate ==
                                                                null ||
                                                            sharePurpose.text ==
                                                                "" ||
                                                            shareDuration.text ==
                                                                "" ||
                                                            PhoneNumbers.text ==
                                                                "" ||
                                                            emailId.text ==
                                                                "") {
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              backgroundColor:
                                                              Colors.red.shade900,
                                                              behavior:
                                                              SnackBarBehavior.floating,
                                                              action:
                                                              SnackBarAction(
                                                                label: 'Dismiss',
                                                                disabledTextColor: Colors.white,
                                                                textColor: Colors.yellow,
                                                                onPressed: () {
                                                                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                                                                },
                                                              ),
                                                              content:
                                                              Text(
                                                                'Please fill all details!',
                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          );
                                                        } else if (difference >
                                                            0) {
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              backgroundColor:
                                                              Colors.red.shade900,
                                                              content:
                                                              Text(
                                                                'Please enter current or future time',
                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          );
                                                        } else if (!RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(emailId
                                                            .text) &&
                                                            PhoneNumbers.text.length <
                                                                10) {
                                                          // print(
                                                          //     "email or  phone required");
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              backgroundColor:
                                                              Colors.redAccent,
                                                              behavior:
                                                              SnackBarBehavior.floating,
                                                              content:
                                                              Text(
                                                                'Email Id or Phone no is Mandatory',
                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          );
                                                        } else {
                                                          ScaffoldMessenger.of(context)
                                                              .showSnackBar(
                                                            SnackBar(
                                                              backgroundColor:
                                                              Colors.teal,
                                                              behavior:
                                                              SnackBarBehavior.floating,
                                                              content:
                                                              Text(
                                                                'Sharing in progress, please wait...',
                                                                style: TextStyle(fontWeight: FontWeight.bold),
                                                              ),
                                                            ),
                                                          );
                                                          _formKey
                                                              .currentState!
                                                              .validate();
                                                          await sharetriplocation(
                                                              ctx,
                                                              _finaldata[i]["tripId"]);
                                                          _formKey
                                                              .currentState
                                                              ?.reset();
                                                        }
                                                      })
                                                ],
                                              ),
                                            );
                                          });
                                    },
                                    icon: const Image(
                                      image: AssetImage(
                                          "images/share.png"),
                                    ))
                              ],
                            ),
                          )
                              : const SizedBox(),
                        ],
                      ),
                    ),
                  );
                },
                separatorBuilder: (ctx, index) {
                  return const SizedBox(
                    height: 0,
                  );
                },
                itemCount: _finaldata.length),
          )
        ],
      );
    }
  }

  Future<void> _getData() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    // print("User ID: ${userId}");
    int Id = int.parse(userId!);
    // print(Id.toString());
    try {
      var url = "${baseUrl}trips/user-trips";
      final response = await Dio()
          .post(url, data: {"ids": [], "userId": Id, "isDetailed": true});
      // final response =
      //     await Dio().get("$productionBaseUrl:11014/trips/list-trips/$Id");
      _data.clear();
      // print("response data: ${response.data['list']}");
      for (var i = 0; i < response.data['list'].length; i++) {
        var fullname;
        response.data['list'][i]['driverFirstName'] == null
            ? fullname = ""
            : fullname = response.data['list'][i]['driverFirstName'];
        response.data['list'][i]['driverMiddleName'] == null
            ? fullname = fullname + ""
            : fullname =
            fullname + " " + response.data['list'][i]['driverMiddleName'];
        response.data['list'][i]['driverLastName'] == null
            ? fullname = fullname + ""
            : fullname =
            fullname + " " + response.data['list'][i]['driverLastName'];
        // print("actual date is: ${response.data['list'][i]["actualStartTime"]}");
        // print("actual date is: ${response.data['list'][i]["tripStatus"]}");
        // print(response.data['list'][i]["uuid"]);
        _data.add({
          "uuid": response.data['list'][i]['uuid'],
          "tripId": response.data['list'][i]['tripId'],
          "tripName": response.data['list'][i]['tripName'] ?? "Not Available",
          "vehicleId": response.data['list'][i]['vehicleId'] ?? "----",
          "vehicleName":
          response.data['list'][i]['vehicleName'] ?? "Not Available",
          "driverId": response.data['list'][i]['driverId'] ?? "----",
          "driverName": fullname == "" ? "Not Available" : fullname,
          "plannedorunplanned":
          response.data['list'][i]['tripStatus'].toString().toLowerCase() ==
              "default"
              ? "unplanned"
              : "planned",
          "tripStatus": response.data['list'][i]['tripStatus'] ?? "----",
          "actualStartTime":
          response.data['list'][i]["actualStartTime"] ?? "----",
          "actualEndTime": response.data['list'][i]["actualEndTime"] ?? "----",
          "onwardStartDateTime":
          response.data['list'][i]['onwardStartDateTime'] ?? "----",
          "onwardEndDateTime":
          response.data['list'][i]["onwardEndDateTime"] ?? "----",
          "expectedStartTime":
          response.data['list'][i]['expectedStartTime'] ?? "----",
          "expectedEndTime":
          response.data['list'][i]["expectedEndTime"] ?? "----",
          "TotalDistance": response.data['list'][i]['totalDistance'] == null
              ? "----"
              : response.data['list'][i]['totalDistance'].toStringAsFixed(2),
          "Category": response.data['list'][i]['category'] ?? "----",
          "baseStartLat": response.data['list'][i]['baseStartLat'] ?? "----",
          "baseStartLong": response.data['list'][i]['baseStartLong'] ?? "----",
          "baseEndLat": response.data['list'][i]['baseEndLat'] ?? "----",
          "baseEndLong": response.data['list'][i]['baseEndLong'] ?? "----",
          "deviceId": response.data['list'][i]['deviceId'] ?? "----",
        });
      }
      // for (var i in _data) {
      //   print("uuid from _data : ${i["uuid"]}");
      // }
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print("error from getdata: $e");
    }
  }

  Future<void> ondropdownchange(String value) async {
    switch (value) {
      case "All Trips":
        setState(() {
          _finaldata = _data;
          for (var i in _finaldata) {
            print("uuid from _finaldata : ${i["uuid"]}");
          }
        });
        print("_finaldata length ${_finaldata.length}");
        break;
    // case "Date Range":
      case "Date Range":
      // print("date range");
        await sortdataondaterange();
        // print("selected date range");
        break;
      default:
        await sortdatatocurrentdate();
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> sortdataondaterange() async {
    // print("inside sort date and range fn");
    _datepicker = await showDateRangePicker(
        context: context,
        firstDate: DateTime.now().toLocal().subtract(const Duration(days: 180)),
        lastDate: DateTime.now().toLocal());
    print(_datepicker);
    if (_datepicker != null) {
      print("Printing here means the _datepicker is not null");
      setState(() {
        datepicked = _datepicker;
      });
    }
    // print(datepicked);

    try {
      _datacustomrangedate.clear();
      DateTime startdate = datepicked!.start;
      DateTime enddate = datepicked!.end;
      String startdateformat = "${dateFormat.format(startdate)} 00:00:00";
      String enddateformat = "${dateFormat.format(enddate)} 23:59:59";
      DateTime startDateFormatted =
      DateFormat("yyyy-MM-dd HH:mm:ss").parse(startdateformat);
      DateTime endDateFormatted =
      DateFormat("yyyy-MM-dd HH:mm:ss").parse(enddateformat);
      // print(DateFormat.yMMMMd().format(startDateFormatted));
      // print(endDateFormatted);
      // print("going to enter the for loop in custom date and range fn");
      for (int i = 0; i < _data.length; i++) {
        if (_data[i]["expectedStartTime"] != "----") {
          DateTime tripdate = DateFormat("yyyy-MM-dd HH:mm:ss")
              .parse(_data[i]["expectedStartTime"])
              .add(const Duration(hours: 5, minutes: 30));

          // var formatteddate = dateFormat.format(tripdate);
          if (tripdate.isAfter(startDateFormatted) &&
              tripdate.isBefore(endDateFormatted)) {
            _datacustomrangedate.add({
              "uuid": _data[i]["uuid"],
              "tripId": _data[i]['tripId'],
              "tripName": _data[i]['tripName'],
              "vehicleId": _data[i]['vehicleId'],
              "vehicleName": _data[i]['vehicleName'],
              "driverName": _data[i]['driverName'],
              "plannedorunplanned": _data[i]['plannedorunplanned'],
              "tripStatus": _data[i]['tripStatus'],
              "expectedStartTime": _data[i]['expectedStartTime'],
              "expectedEndTime": _data[i]['expectedStartTime'],
              "onwardStartDateTime": _data[i]['onwardStartDateTime'],
              "onwardEndDateTime": _data[i]["onwardEndDateTime"],
              "actualStartTime": _data[i]['actualStartTime'],
              "actualEndTime": _data[i]['actualEndTime'],
              "TotalDistance": _data[i]['totalDistance'],
              "Category": _data[i]['Category'],
              "driverId": _data[i]['driverId'],
              "baseStartLat": _data[i]['baseStartLat'],
              "baseStartLong": _data[i]['baseStartLong'],
              "baseEndLat": _data[i]['baseEndLat'],
              "baseEndLong": _data[i]['baseEndLong'],
            });
          }
        }
      }
      for (var i in _datacustomrangedate) {
        print("_data custom range data: ${i}");
      }

      if (_datacustomrangedate.isEmpty) {
        setState(() {
          isdataempty = true;
        });
      }
      setState(() {
        _finaldata = _datacustomrangedate;
      });
    } catch (e) {
      rethrow;
    }
  }

  Future<void> sortdatatocurrentdate() async {
    _datacurrentdate.clear();
    String currentdate = dateFormat.format(DateTime.now().toLocal());
    try {
      for (int i = 0; i < _data.length; i++) {
        if (_data[i]["expectedStartTime"] != "----") {
          DateTime tripdate = dateFormat
              .parse(_data[i]["expectedStartTime"])
              .add(const Duration(hours: 5, minutes: 30));
          var formatteddate = dateFormat.format(tripdate);
          // print(formatteddate);
          if (formatteddate == currentdate) {
            _datacurrentdate.add({
              "uuid": _data[i]["uuid"],
              "tripId": _data[i]['tripId'],
              "tripName": _data[i]['tripName'],
              "vehicleId": _data[i]['vehicleId'],
              "vehicleName": _data[i]['vehicleName'],
              "driverName": _data[i]['driverName'],
              "plannedorunplanned": _data[i]['plannedorunplanned'],
              "tripStatus": _data[i]['tripStatus'],
              "expectedStartTime": _data[i]['expectedStartTime'],
              "expectedEndTime": _data[i]['expectedStartTime'],
              "onwardStartDateTime": _data[i]['onwardStartDateTime'],
              "onwardEndDateTime": _data[i]["onwardEndDateTime"],
              "actualStartTime": _data[i]['actualStartTime'],
              "actualEndTime": _data[i]['actualEndTime'],
              "TotalDistance": _data[i]['totalDistance'],
              "Category": _data[i]['Category'],
              "driverId": _data[i]['driverId'],
              "baseStartLat": _data[i]['baseStartLat'],
              "baseStartLong": _data[i]['baseStartLong'],
              "baseEndLat": _data[i]['baseEndLat'],
              "baseEndLong": _data[i]['baseEndLong'],
            });
          }
        }
      }

      if (_datacurrentdate.isEmpty) {
        setState(() {
          isdataempty = true;
        });
      }
      setState(() {
        _finaldata = _datacurrentdate;
      });
    } catch (e) {
      throw e;
    }
  }

  void _showSnackBar(BuildContext context) {
    final snackBar = SnackBar(
      content:
      const Text('Please Select a Date Range to go to the track history'),
      backgroundColor: Colors.red,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Dismiss',
        disabledTextColor: Colors.white,
        textColor: Colors.grey,
        onPressed: () {
          ScaffoldMessenger.of(context).hideCurrentSnackBar();
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    // print("dispose");
    super.dispose();
  }
}

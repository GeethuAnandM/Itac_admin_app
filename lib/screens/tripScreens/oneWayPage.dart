import 'dart:io';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/themes.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';
import '../adminlogin.dart';
import '../color.dart';
import '../custom_widget.dart';
import 'managetripscreen.dart';

bool isDriverName = false;
final _FormKey = GlobalKey<FormState>();
String dropdownValue = 'No';

class OneWay extends StatefulWidget {
  @override
  State<OneWay> createState() => _OneWayState();
}

class _OneWayState extends State<OneWay> {
  Future<List<VehicleDrop>> filterdata(filter) async {
    var res =
        totVehicle.where((element) => element.name.contains(filter)).toList();
    return res;
  }

  Future<List<Trips>> filterTrip(filter) async {
    var res =
        _totTrip.where((element) => element.name.contains(filter)).toList();
    return res;
  }

  final storage = const FlutterSecureStorage();
  String? formattedTime;
  String? formatted24;
  String? formatted124;
  bool Isloading = false;
  var message = "";
  var VehicleList = [];
  var DeviceList = [];
  List<dynamic> allids = [];
  var dio = Dio();
  VehicleDrop? vehicleNameselected;
  List<VehicleDrop> totVehicle = [];
  List<Trips> _totTrip = [];
  Trips? drivernames;
  bool isrecurringchk = false;

  Future<List<dynamic>> getVehiclesDetails() async {
    final prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("user_id");
    final url = "${baseUrl}api/list-vehicles/$username";
    var dio = Dio();
    final response = await dio.get(url);
    VehicleList = response.data;
    allids = [];
    for (var i in VehicleList) {
      if (i['deviceId'] != null && i['deviceId'] != "") {
        allids.add(i['deviceId']);
      }
    }
    return VehicleList;
  }

  Future<List<dynamic>> getDeviceCurrentLocation() async {
    var data = {"deviceIds": allids};
    final url2 = "${baseUrl}location/getDeviceCurrentLocation";
    final response = await dio.post(url2, data: data);
    DeviceList = await response.data;
    return DeviceList;
  }

  List<Widget> AddVehicleNames() {
    var dIds = [];
    var vDids = [];
    for (var i in DeviceList) {
      dIds.add(i["id"]);
    }
    for (var i in VehicleList) {
      vDids.add(i['deviceId']);
    }
    // print("inside addvehicles, vehicles list${vDids}");
    totVehicle.clear();
    for (var i = 0; i < VehicleList.length; i++) {
      // print(VehicleList[i]);
      for (var j = 0; j < DeviceList.length; j++) {
        // print(DeviceList[j]);
        if (DeviceList[j]["id"] == VehicleList[i]["deviceId"]) {
          print("hello");
          totVehicle.add(
            VehicleDrop(
                VehicleList[i]["vehicleId"], VehicleList[i]["vehicleName"]),
          );
        }
      }
    }
    // print(totVehicle);
    setState(() {});

    List<Widget> Demo = [];
    return Demo;
  }

  // Future chkdrivername(dynamic drivername) async {
  //   final prefs = await SharedPreferences.getInstance();
  //   var userId = prefs.getString("user_id");
  //   var Id = int.parse(userId!);
  //   var orgId = prefs.getString("org_id");
  //   final url = "$baseUrl:11022/api/list-driver/$orgId";
  //   var dio = Dio();
  //   final response = await dio.get(url);
  //   print("reschk${response.data}");
  //   var fullname = "";
  //   totTrip.clear();
  //   for (var i = 0; i < response.data.length; i++) {
  //     print(response.data[i]);
  //     response.data[i]['firstName'] == null ||
  //             response.data[i]['firstName'] == ''
  //         ? fullname = ""
  //         : fullname = response.data[i]['firstName'];
  //     response.data[i]['middleName'] == null ||
  //             response.data[i]['middleName'] == ''
  //         ? fullname = fullname + ""
  //         : fullname = fullname + " " + response.data[i]['middleName'];
  //     response.data[i]['lastName'] == null || response.data[i]['lastName'] == ''
  //         ? fullname = fullname + ""
  //         : fullname = fullname + " " + response.data[i]['lastName'];
  //     print("driver fullname ${fullname} ${drivername}");
  //     print("driver fullname ${fullname.length} ${drivername.length}");
  //     if (fullname == drivername) {
  //       print(response.data[i]['driverId']);
  //       driverNameController.text = fullname;
  //       setState(() {
  //         driverNameController.text = fullname;
  //         // EasyLoading.dismiss();
  //       });
  //       totTrip.add(Trips(
  //         response.data[i]['driverId'],
  //         fullname,
  //       ));
  //     }
  //   }
  //   return null;
  // }

  List<Map<dynamic, dynamic>> driverlist = [];
  Future<List<dynamic>> getdata() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var orgId = prefs.getString("org_id");
    final url = "${baseUrl}api/list-driver/$orgId";
    var dio = Dio();
    final response = await dio.get(url);
    driverlist.clear();
    print("res${response.data}");
    var fullname = "";
    for (var i = 0; i < response.data.length; i++) {
      if (response.data[i]['vehicleId'] == vehicleNameselected?.id) {
        response.data[i]['firstName'] == null ||
                response.data[i]['firstName'] == ''
            ? fullname = ""
            : fullname = response.data[i]['firstName'];
        response.data[i]['middleName'] == null ||
                response.data[i]['middleName'] == ''
            ? fullname = fullname + ""
            : fullname = fullname + " " + response.data[i]['middleName'];
        response.data[i]['lastName'] == null ||
                response.data[i]['lastName'] == ''
            ? fullname = fullname + ""
            : fullname = fullname + " " + response.data[i]['lastName'];
        print("driver details $fullname");
        driverNameController.text = fullname;
        // isDriverName = true;
      }
    }

    setState(() {
      isDriverName = isDriverName;
      driverNameController.text = fullname;
      // EasyLoading.dismiss();
    });
    print(" data is here $driverlist");
    print('length:${driverlist.length}');
    print(driverlist.runtimeType);
    return driverlist;
  }

  Future getdriverName() async {
    print("getdrivername");
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    print("userid:${userId}");
    var orgId = prefs.getString("org_id");
    final url = "$baseUrl:11022/api/list-driver/$orgId";
    var dio = Dio();
    final response = await dio.get(url);
    print("reschk${response.data}");
    var fullname = "";
    _totTrip.clear();
    for (var i = 0; i < response.data.length; i++) {
      response.data[i]['firstName'] == null ||
              response.data[i]['firstName'] == ''
          ? fullname = ""
          : fullname = response.data[i]['firstName'];
      response.data[i]['middleName'] == null ||
              response.data[i]['middleName'] == ''
          ? fullname = fullname + ""
          : fullname = fullname + " " + response.data[i]['middleName'];
      response.data[i]['lastName'] == null || response.data[i]['lastName'] == ''
          ? fullname = fullname + ""
          : fullname = fullname + " " + response.data[i]['lastName'];
      print("driver details $fullname");
      _totTrip.add(Trips(
        response.data[i]['driverId'],
        fullname,
      ));
    }
    setState(() {
      Isloading = false;
    });
    return null;
  }

  bool _value = false;
  int val = 0;
  var submitbutton = false;
  var errormessage = '';
  var vehicleadded = false;

  _addTripDetails({
    var vehicleName,
    tripName,
    recurring,
    drivername,
    enddate,
    onwardstartdate,
    onwardstarttime,
    onwardenddata,
    onwardendtime,
  }) async {
    String? orgId = await storage.read(key: "org_ids") ??
        await storage.read(key: "temp_org_ids");
    // print("org_id $orgId");
    setState(() {
      submitbutton = true;
      // EasyLoading.show(status: "Loading");
    });
    var onwardstartdatetochk = DateTime.parse(onwardstartdate);
    var onwardenddateexpected = onwardstartdatetochk.add(Duration(hours: 24));
    var onwardenddategot = DateTime.parse(onwardenddata);
    print(
        "$vehicleName,$tripName,$recurring,${drivernames},$enddate,$onwardstartdate,$onwardstarttime,$onwardendtime,$onwardenddata");
    var data;
    DateTime onwardStartTimeformat = DateFormat("HH:mm").parse(onwardstarttime).subtract(const Duration(hours: 5,minutes: 30));
    DateTime onwardendtimeformat = DateFormat("HH:mm").parse(onwardendtime).subtract(const Duration(hours: 5,minutes: 30));
    if (recurring == false) {
      data = {
        "isRecurring": recurring,
        "category": "One Way",
        "onwardEndDate": onwardenddata,
        "onwardEndTime": DateFormat("HH:mm").format(onwardendtimeformat) + ":00",
        "onwardStartDate": onwardstartdate,
        "onwardStartTime": DateFormat("HH:mm").format(onwardStartTimeformat) + ":00",
        "orgId": int.parse(orgId!),
        "vehicleId":
            vehicleNameselected == null ? null : vehicleNameselected?.id,
        "driverId": drivernames == null ? null : drivernames?.id,
        "status": "Not Started",
        "tripName": tripName
      };
    } else {
      if (enddate == null) {
        setState(() {
          errormessage = "end date is required";
        });
      } else {
        data = {
          "isRecurring": recurring,
          "category": "One Way",
          "endDate": enddate,
          "onwardEndDate": onwardenddata,
          "onwardEndTime": DateFormat("HH:mm").format(onwardendtimeformat) + ":00",
          "onwardStartDate": onwardstartdate,
          "onwardStartTime":  DateFormat("HH:mm").format(onwardStartTimeformat) + ":00",
          "orgId": int.parse(orgId!),
          "vehicleId":
              vehicleNameselected == null ? null : vehicleNameselected?.id,
          "driverId": drivernames == null ? null : drivernames?.id,
          "status": "Not Started",
          "tripName": tripName
        };
      }
      ;
    }
    print(data);
    const url2 = "${baseUrl}trips/save-trip";
    var vehLocationList = [];
    var dio = Dio();
    try {
      final response = await dio.post(url2, data: data);
      print(response.statusCode);
      print(response.data);
      print(response.statusCode);
      showSnackBar(context, "Trip added Succesfully");
      setState(() {
        // submitbutton= false;
        errormessage = "Trip added Succesfully";
        vehicleadded = true;
      });
      if (response.statusCode == 200) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (context) => manageTripScreen(

                  )),
        );
      }
    } on DioError catch (e) {
      print("in dio error");
      if (e.response?.statusCode == 400) {
        showSnackBar(context, e.response?.data["message"]);
      } else if (e.response?.statusCode == 404) {
        showSnackBar(context, "Something Went Wrong");
      } else if (e.response?.statusCode == 500) {
        showSnackBar(context, "Server Error");
      }
    }
    catch(e){
      print(e);
      print("in catch error");
    }
    // return vehLocationList;
  }

  final endDateController = TextEditingController();
  final vehicleNameController = TextEditingController();
  final driverNameController = TextEditingController();
  final onwardPlannedStartDateController = TextEditingController();
  final onwardPlannedstartTimeController = TextEditingController();
  final onwardPannedEndDateController = TextEditingController();
  final onwardPlannedEndTimeController = TextEditingController();
  final tripNameController = TextEditingController();
  var themeColor;

  @override
  void initState() {
    () async {
      Isloading = true;
      await getVehiclesDetails();
      await getDeviceCurrentLocation();
      await AddVehicleNames();
      _totTrip.clear();
      await getdriverName();
      // await gettrips();
    }();
    super.initState();
  }

  // Future<List<VehicleDrop>> filterdata(filter) async{
  //  var res =  totVehicle.where((element) => element.name.contains(filter)).toList();
  //  return res;
  // }
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    // SharedPreferences.getInstance().then((pref) async {
    //   setState(() {
    //     themeColor= pref.getString("ThemeMode");
    //   });
    // });
    for(var i=0;i<_totTrip.length;i++){
      print(" _tottrip data ${_totTrip[i].name}");
    }
    print(themecolruserselected);
    print("activetheme$activeTheme");
    print("pink theme $pinkAndBlueGreyTheme");
    return Isloading == true
        ? Center(
            child: CircularProgressIndicator(
              semanticsLabel: "right",
            ),
          )
        : SingleChildScrollView(
            child: Column(children: [
              Container(
                  child: Image.asset('images/addtrip.jpg',
                      height: 200, width: 360, fit: BoxFit.cover)),
              Container(
                margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomRight,
                      colors: [Colors.white54, Colors.white54]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ],
                ),
                child: Center(
                  child: Form(
                      key: _FormKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .03,
                          ),
                          Row(
                            children: [
                              Container(
                                child: Image.asset(
                                  'images/adminimage6.png',
                                  color: commonTextStyle,
                                  width: 40,
                                  height: 36,
                                  fit: BoxFit.fill,
                                ),
                                decoration: BoxDecoration(
                                    color: blueColor,
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(5))),
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    controller: tripNameController,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Trip Name';
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("Trip Name"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "Trip Name",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Text(
                            "Onward",
                            style: TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 20),
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.date_range_sharp,
                                size: 40,
                                color: blueColor,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Start Date';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onTap: () async {
                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime.now(),
                                        firstDate: DateTime.now(),
                                        lastDate: DateTime.now()
                                            .add(const Duration(days: 320)),
                                      );
                                      if (pickedDate != null) {
                                        print(
                                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(pickedDate);
                                        print(formattedDate);
                                        setState(() {
                                          onwardPlannedStartDateController
                                              .text = formattedDate.toString();
                                        });
                                      } else {
                                        return;
                                      }
                                    },
                                    // }
                                    controller:
                                        onwardPlannedStartDateController,
                                    keyboardType: TextInputType.none,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("Start Date"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "Start Date",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.timelapse,
                                size: 40,
                                color: blueColor,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter Start Time';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onTap: () async {
                                      print(onwardPlannedStartDateController
                                          .text);
                                      if (onwardPlannedStartDateController
                                              .text ==
                                          "") {
                                        showSnackBar(context,
                                            "Please Pick the Starting Date First");
                                      } else {
                                        final TimeOfDay? newTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        print(newTime);
                                        if (newTime != null) {
                                          print(newTime);
                                          DateTime parsedTime = DateFormat.jm()
                                              .parse(newTime
                                                  .format(context)
                                                  .toString());
                                          formatted24 = DateFormat('HH:mm:ss')
                                              .format(parsedTime);
                                          formattedTime = DateFormat('HH:mm')
                                              .format(parsedTime);
                                          print(formattedTime);
                                          setState(() {
                                            onwardPlannedstartTimeController
                                                    .text =
                                                (formattedTime! + ":00")!;
                                            print(newTime);
                                          });
                                        }
                                      }
                                    },
                                    controller:
                                        onwardPlannedstartTimeController,
                                    keyboardType: TextInputType.none,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("Start Time"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "Start Time",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_month,
                                size: 40,
                                color: blueColor,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter End Date';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onTap: () async {
                                      if (onwardPlannedStartDateController
                                              .text ==
                                          "") {
                                        showSnackBar(context,
                                            "Please Pick the Start Time First");
                                      } else if (onwardPlannedstartTimeController
                                              .text ==
                                          "") {
                                        showSnackBar(context,
                                            "Please Pick the Starting Date First");
                                      } else {
                                        print(
                                            "date:${DateTime.parse(onwardPlannedStartDateController.text)}");
                                        DateTime? pickedDate =
                                            await showDatePicker(
                                          context: context,
                                          initialDate:
                                              onwardPlannedStartDateController
                                                          .text !=
                                                      ""
                                                  ? DateTime.parse(
                                                      onwardPlannedStartDateController
                                                          .text)
                                                  : DateTime.now(),
                                          firstDate:
                                              onwardPlannedStartDateController
                                                          .text !=
                                                      ""
                                                  ? DateTime.parse(
                                                      onwardPlannedStartDateController
                                                          .text)
                                                  : DateTime.now(),
                                          lastDate: DateTime.now()
                                              .add(Duration(days: 320)),
                                        );
                                        if (pickedDate != null) {
                                          print(
                                              pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                          String formattedDate =
                                              DateFormat('yyyy-MM-dd')
                                                  .format(pickedDate);
                                          print(formattedDate);
                                          setState(() {
                                            onwardPannedEndDateController.text =
                                                formattedDate.toString();
                                          });
                                        } else {
                                          return;
                                        }
                                      }
                                    },
                                    // },
                                    controller: onwardPannedEndDateController,
                                    keyboardType: TextInputType.none,
                                    autofocus: false,
                                    readOnly: true,
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("End Date"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "End Date",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.timelapse,
                                size: 40,
                                color: blueColor,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Enter End Time';
                                      } else {
                                        return null;
                                      }
                                    },
                                    onTap: () async {
                                      if (onwardPlannedStartDateController
                                              .text ==
                                          "") {
                                        showSnackBar(context,
                                            "Please Pick the Starting Date First");
                                      } else if (onwardPlannedstartTimeController
                                              .text ==
                                          "") {
                                        showSnackBar(context,
                                            "Please Pick the Starting Time First");
                                      } else if (onwardPannedEndDateController
                                              .text ==
                                          "") {
                                        showSnackBar(context,
                                            "Please Pick the End Date First");
                                      } else {
                                        final TimeOfDay? newTime =
                                            await showTimePicker(
                                          context: context,
                                          initialTime: TimeOfDay.now(),
                                        );
                                        print(newTime);
                                        if (newTime != null) {
                                          print(newTime);
                                          DateTime parsedTime = DateFormat.jm()
                                              .parse(newTime
                                                  .format(context)
                                                  .toString());
                                          formatted124 = DateFormat('HH:mm:ss')
                                              .format(parsedTime);
                                          String formattedTime =
                                              DateFormat('HH:mm')
                                                  .format(parsedTime);
                                          print(formattedTime);
                                          var totalstartdate =
                                              onwardPlannedStartDateController
                                                      .text +
                                                  " " +
                                                  onwardPlannedstartTimeController
                                                      .text;
                                          var totalenddate =
                                              onwardPannedEndDateController
                                                      .text +
                                                  " " +
                                                  formattedTime;
                                          print(
                                              "totalstartdate.${totalstartdate}");
                                          print("totalenddate.${totalenddate}");
                                          Duration diff = DateTime.parse(
                                                  totalenddate.toString())
                                              .difference(DateTime.parse(
                                                  totalstartdate.toString()));

                                          if (diff.inHours <= 24) {
                                            isrecurringchk = true;
                                          } else {
                                            isrecurringchk = false;
                                          }
                                          setState(() {
                                            isrecurringchk = isrecurringchk;
                                            onwardPlannedEndTimeController
                                                    .text =
                                                formattedTime.toString() +
                                                    ":00";
                                          });
                                        } else {
                                          return;
                                        }
                                      }
                                    },
                                    // },
                                    controller: onwardPlannedEndTimeController,
                                    keyboardType: TextInputType.none,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("End Time"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "End Time",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Row(children: [
                            SizedBox(
                              width: 50,
                            ),
                            Container(
                              margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
                              width: MediaQuery.of(context).size.width * .8,
                              decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(10))),
                              child: DropdownButtonFormField<String>(
                                // validator: (value) => value == null
                                //     ? "Select a Recurring Date"
                                //     : null,
                                // value: vehicleNameselected,
                                hint: Text(
                                  'Is Recurring',
                                  style: TextStyle(fontSize: 12),
                                ),
                                elevation: 16,
                                iconSize: 20,
                                icon: const Icon(Icons.arrow_drop_down),
                                isDense: true,
                                decoration: InputDecoration(
                                  label: Row(
                                    children: [
                                      Text("Is Recurring"),
                                      Padding(
                                        padding: EdgeInsets.all(3.0),
                                      ),
                                      // const Text('*',
                                      //     style: TextStyle(color: Colors.red)),
                                    ],
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onChanged: (String? newValue) async {
                                  if (newValue == "No") {
                                    setState(() {
                                      _value = false;
                                      print("_value:${_value}");
                                    });
                                  } else {
                                    setState(() {
                                      _value = true;
                                    });
                                  }
                                  setState(() {
                                    dropdownValue = newValue!;
                                  });
                                },
                                items: <String>[
                                  'No',
                                  'Yes'
                                ].map<DropdownMenuItem<String>>((String value) {
                                  print("value:${value}");
                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Center(
                                        child: Text(
                                      value,
                                      style: TextStyle(fontSize: 17),
                                    )),
                                  );
                                }).toList(),
                              ),
                            ),
                          ]),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          _value == true
                              ? Row(
                                  children: [
                                    Icon(
                                      Icons.update,
                                      size: 40,
                                      color: blueColor,
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
                                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      width: MediaQuery.of(context).size.width *
                                          .82,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Center(
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value!.isEmpty) {
                                              return 'Enter recurring Date';
                                            } else {
                                              return null;
                                            }
                                          },
                                          onTap: () async {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now()
                                                  .add(Duration(hours: 24)),
                                              firstDate: DateTime.now()
                                                  .add(Duration(hours: 24)),
                                              lastDate: DateTime.now()
                                                  .add(Duration(days: 320)),
                                            );
                                            if (pickedDate != null) {
                                              print(
                                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(pickedDate);
                                              print(formattedDate);
                                              setState(() {
                                                endDateController.text =
                                                    formattedDate.toString();
                                              });
                                            } else {
                                              return;
                                            }
                                          },
                                          controller: endDateController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            label: Row(
                                              children: [
                                                Text("End Date"),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                const Text('*',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ],
                                            ),
                                            hintText: "End Date",
                                            border: new OutlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : SizedBox(),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Row(children: [
                            Container(
                              child: Image.asset(
                                'images/caricontransparent.png',
                                color: commonTextStyle,
                                width: 40,
                                height: 36,
                                fit: BoxFit.fill,
                              ),
                              decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 2, 0),
                                width: MediaQuery.of(context).size.width * .8,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: DropdownSearch<VehicleDrop>(
                                  compareFn: (item1, item2) => item1.id == item2.id,
                                  decoratorProps:
                                      const DropDownDecoratorProps(
                                          decoration:
                                              InputDecoration(
                                                  hintText:
                                                      'Select Vehicle Name')),
                                  popupProps: PopupProps.bottomSheet(
                                      searchFieldProps: TextFieldProps(
                                          decoration: InputDecoration(
                                              hintText: "Select Vehicle Name")),
                                      showSearchBox: true),
                                  items: (filter, loadProps) => filterdata(filter),
                                  // asyncItems: (String filter) =>
                                  //     filterdata(filter),
                                  onSelected: (VehicleDrop? data) async {
                                    if (data != null) {
                                      setState(() {
                                        vehicleNameselected = data;
                                        // EasyLoading.show(status: "Loading");
                                      });
                                      await getdata();

                                      print(
                                          "newvalue${vehicleNameselected?.id}");
                                    }
                                  },
                                )),
                          ]),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .02,
                          ),
                          Row(
                            children: [
                              Icon(
                                Icons.person,
                                size: 40,
                                color: blueColor,
                              ),
                              isDriverName == true
                                  ? Container(
                                      margin: EdgeInsets.fromLTRB(11, 0, 1, 0),
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Center(
                                        child: TextFormField(
                                          controller: driverNameController,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          keyboardType: TextInputType.text,
                                          autofocus: false,
                                          validator: (value) => value == null
                                              ? "Select a Driver"
                                              : null,
                                          decoration: InputDecoration(
                                            enabled: false,
                                            label: Row(
                                              children: [
                                                Text("Driver Name"),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                const Text('*',
                                                    style: TextStyle(
                                                        color: Colors.red)),
                                              ],
                                            ),
                                            hintText: "Driver Name",
                                            border: new OutlineInputBorder(
                                              borderSide: new BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  : Container(
                                      margin: EdgeInsets.fromLTRB(10, 0, 2, 0),
                                      width: MediaQuery.of(context).size.width *
                                          .8,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: DropdownSearch<Trips>(
                                        compareFn: (item1, item2) => item1.id == item2.id,
                                        decoratorProps:
                                            const DropDownDecoratorProps(
                                                decoration:
                                                    InputDecoration(
                                                        hintText:
                                                            'Select Driver Name')),
                                        popupProps: PopupProps.bottomSheet(
                                            searchFieldProps: TextFieldProps(
                                                decoration: InputDecoration(
                                                    hintText:
                                                        "Select Driver Name ")),
                                            showSearchBox: true),
                                        items: (filter, loadProps) async {
    return _totTrip;
  },
                                        // asyncItems: (String filter) =>
                                        //     filterTrip(filter),
                                        onSaved: (Trips? data) async {
                                          if (data != null) {
                                            setState(() {
                                              drivernames = data;
                                              // EasyLoading.show(status: "Loading");
                                            });
                                            await getdata();
                                            // print("newvalue${drivernames?.id}");
                                          }
                                        },
                                      )),
                            ],
                          ),
                          SizedBox(
                            height: MediaQuery.of(context).size.height * .05,
                          ),
                          Container(
                              child: CustomButton(
                                  buttontext: "Submit",
                                  onpress: () async {
                                    var add;
                                    // print("drivername${drivernames}");
                                    var dateFormat1 = DateFormat("hh:mm:ss");
                                    DateTime onwardPlannedstartTimeControllers =
                                        // DateTime.parse(
                                        //         onwardPlannedstartTimeController
                                        //             .text)
                                        //     .toLocal();
                                        DateFormat('HH:mm').parse(
                                            onwardPlannedstartTimeController
                                                .text);
                                    var onwardPlannedstartTimeControllerparse =
                                        dateFormat1.format(
                                            onwardPlannedstartTimeControllers);
                                    DateTime onwardPlannedEndTimeControllers =
                                        // DateTime.parse(
                                        //         onwardPlannedEndTimeController
                                        //             .text)
                                        //     .toLocal();
                                        DateFormat('HH:mm').parse(
                                            onwardPlannedEndTimeController
                                                .text);
                                    var onwardPlannedEndTimeControllerparse =
                                        dateFormat1.format(
                                            onwardPlannedEndTimeControllers);
                                    print("hello");
                                    if (_FormKey.currentState!.validate()) {
                                      if (_value == true) {
                                        add = await _addTripDetails(
                                            drivername:
                                                drivernames?.name == null
                                                    ? null
                                                    : drivernames?.name,
                                            vehicleName: vehicleNameselected
                                                ?.name
                                                .toString(),
                                            recurring: _value,
                                            tripName: tripNameController.text,
                                            onwardstartdate:
                                                onwardPlannedStartDateController
                                                    .text,
                                            onwardstarttime: formatted24,
                                            enddate: endDateController.text,
                                            onwardenddata:
                                                onwardPannedEndDateController
                                                    .text,
                                            onwardendtime: formatted124);
                                      } else {
                                        print("hai");
                                        add = await _addTripDetails(
                                            drivername: drivernames?.name,
                                            vehicleName: vehicleNameselected
                                                ?.name
                                                .toString(),
                                            recurring: _value,
                                            tripName: tripNameController.text,
                                            onwardstartdate:
                                                onwardPlannedStartDateController
                                                    .text,
                                            onwardstarttime: formatted24,
                                            // enddate: endDateController.text,
                                            onwardenddata:
                                                onwardPannedEndDateController
                                                    .text,
                                            onwardendtime: formatted124);
                                      }
                                      print("add:$add");
                                      print("data added");
                                    }
                                  })),
                          // SizedBox(
                          //   height: MediaQuery.of(context).size.height * .025,
                          // ),
                          Container(
                            margin: EdgeInsets.fromLTRB(15, 35, 15, 10),
                            child: Center(
                              child: GestureDetector(
                                  onTap: () async {
                                    Navigator.of(context)
                                        .push(MaterialPageRoute(
                                      builder: (BuildContext context) =>
                                          manageTripScreen(
                                      ),
                                    ));
                                    //   // (route) => false,
                                    // );
                                    // Navigator.pop(context);
                                  },
                                  child: Text("Back to Tripscreen?",
                                      textAlign: TextAlign.center,
                                      style: blueColouredTextStyle)),
                            ),
                          ),
                        ],
                      )),
                ),
              ),
            ]),
          );
  }

  void showSnackBar(BuildContext context, String title) {
    final snackBar = SnackBar(
      content: Text(title),
      margin: EdgeInsets.only(
        bottom: 450,
        right: 20,
        left: 20,
      ),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: 'Dismiss',
        disabledTextColor: Colors.white,
        textColor: Colors.yellow,
        onPressed: () {
          //Do whatever you want
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
}

class VehicleDrop {
  VehicleDrop(this.id, this.name);

  String name;
  int id;

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VehicleDrop && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class Trips {
  Trips(this.id, this.name);

  String name;
  int id;

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Trips && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
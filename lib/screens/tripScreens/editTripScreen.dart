import 'dart:async';
import 'dart:io';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/sidebar.dart';
import 'package:admin_app/screens/themes.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../languges/language_constants.dart';
import '../custom_widget.dart';
import 'managetripscreen.dart';
import 'oneWayPage.dart';

class EditTripScreen extends StatefulWidget {
  var vehicleId;
  EditTripScreen({
    super.key,
    // required this.data,
    required this.tripId,
    required this.tripName,
    required this.vehicleId,
    required this.vehicleName,
    required this.onwardStartDateTime,
    required this.onwardEndDateTime,
    required this.returnStartDateTime,
    required this.driverName,
    required this.isRecurring,
    required this.status,
    required this.category,
    required this.returnEndDateTime,
    required this.onwardActualStartDateTime,
    required this.onwardActualEndDateTime,
    // required this.returnActualStartDateTime,
    // required this.returnActualEndDateTime,
    required this.uuid,
  });

  // List<dynamic> data = [];
  var tripId;

  var uuid;
  var tripName;
  var vehicleName;
  var driverName;
  var status;
  var category;
  bool isRecurring;
  var onwardStartDateTime;
  var onwardEndDateTime;
  var returnStartDateTime;
  var returnEndDateTime;
  var onwardActualStartDateTime;
  var onwardActualEndDateTime;
  // var returnActualStartDateTime;
  // var returnActualEndDateTime;
  @override
  State<EditTripScreen> createState() => _EditTripScreenState();
}

class _EditTripScreenState extends State<EditTripScreen> {
  void showSnackBar(BuildContext context, String title) {
    final snackBar = SnackBar(
      content: Text(title),
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

  Future<List<VehicleDrop>> filterdata(filter) async {
    var res =
        totVehicle.where((element) => element.name.contains(filter)).toList();
    return res;
  }

  Future<List<Trips>> filterTrip(filter) async {
    var res =
        totTrip.where((element) => element.name.contains(filter)).toList();
    return res;
  }

  Map<String, dynamic> datas = {};
  var statuscode;
  var errormessage = '';
  GlobalKey<ScaffoldState> _key = GlobalKey();
  final storage = FlutterSecureStorage();
  final _formKey = GlobalKey<FormState>();
  final vehiclenameController = TextEditingController();
  final driverNameController = TextEditingController();
  final tripNameController = TextEditingController();
  final onwardStartDateController = TextEditingController();
  final onwardStartTimeController = TextEditingController();
  final onwardEndDateController = TextEditingController();
  final onwardEndTimeController = TextEditingController();
  final returnStartDateController = TextEditingController();
  final returnStartTimeController = TextEditingController();
  final returnEndDateController = TextEditingController();
  final returnEndTimeController = TextEditingController();

  bool Isloading = false;
  var message = "";
  var VehicleList = [];
  var DeviceList = [];
  List<dynamic> allids = [];
  var dio = Dio();
  // VehicleDrop? vehicleNameselected;
  List<VehicleDrop> totVehicle = [];
  List<Trips> totTrip = [];
  // Trips? drivernames;
  bool isrecurringchk = false;
  List<VehicleDrop> vehiclenames = [];
  DateFormat dateFormat = DateFormat("yyyy-MM-dd");
  DateFormat timeFormat = DateFormat("HH:mm:ss");
  VehicleDrop? _vehicleNameselected;
  Trips? _driverNameselected;
  String? vehselected;

  Future<void> getVehicleName() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString("user_id");

      if (userId == null || userId.isEmpty) {
        print("User ID is null");
        return;
      }

      vehiclenames.clear();

      final url = "${baseUrl}api/list-vehicles/$userId";
      final result = await Dio().get(url);

      if (result.statusCode == 200 && result.data is List) {
        for (int i = 0; i < result.data.length; i++) {
          if (result.data[i]["vehicleId"] != null &&
              result.data[i]["vehicleName"] != null) {
            if (widget.vehicleId == result.data[i]["vehicleId"]) {
              _vehicleNameselected = VehicleDrop(
                result.data[i]["vehicleId"],
                result.data[i]["vehicleName"],
              );
            }

            vehiclenames.add(
              VehicleDrop(
                result.data[i]["vehicleId"],
                result.data[i]["vehicleName"],
              ),
            );
          }
        }

        print(_vehicleNameselected?.name);
        print(vehiclenames);
        ScaffoldMessenger.of(context).hideCurrentSnackBar();
      }
    } on SocketException {
      print("No Internet Connection");
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      setState(() {
        errormessage = "No Internet Connection";
      });
    } catch (e, stackTrace) {
      print("getVehicleName Error: $e");
      print(stackTrace);
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      setState(() {
        errormessage = "Something went wrong";
      });
    }
  }

  Future chkdrivername(dynamic drivername) async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var orgId = prefs.getString("org_id");
    final url = "${baseUrl}api/list-driver/$userId";
    var dio = Dio();
    final response = await dio.get(url);
    print("reschk${response.data}");
    var fullname = "";
    for (var i = 0; i < response.data.length; i++) {
      print(response.data[i]);
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
      print("driver fullname ${fullname} ${drivername}");
      print("driver fullname ${fullname.length} ${drivername.length}");
      if (fullname == drivername) {
        print(response.data[i]['driverId']);
        driverNameController.text = fullname;
        setState(() {
          driverNameController.text = fullname;
          // EasyLoading.dismiss();
        });
        totTrip.add(Trips(
          response.data[i]['driverId'],
          fullname,
        ));
      }
    }
    return null;
  }

  List<Map<dynamic, dynamic>> driverlist = [];
  Future<List<dynamic>> getdata() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var orgId = prefs.getString("org_id");
    final url = "${baseUrl}api/list-driver/$orgId";
    print(url);
    var dio = Dio();
    final response = await dio.get(url);
    driverlist.clear();
    print("res${response.data}");
    var fullname = "";
    for (var i = 0; i < response.data.length; i++) {
      if (response.data[i]['vehicleId'] == _vehicleNameselected?.id) {
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
        isDriverName = true;
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
    // print("getdrivername");

    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var orgId = prefs.getString("org_id");
    try {
      final url = "${baseUrl}api/list-driver/$orgId";

      var dio = Dio();
      final response = await dio.get(url);
      print(response);
      var fullname = "";
      for (var i = 0; i < response.data.length; i++) {
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
        if (widget.driverName == fullname) {
          print("matched");
          print(widget.driverName);
          _driverNameselected = Trips(response.data[i]['driverId'], fullname);
          print(_driverNameselected?.name);
        }
        totTrip.add(Trips(
          response.data[i]['driverId'],
          fullname,
        ));

        setState(() {
          statuscode = response.statusCode;
        });
      }
      return;
    } on SocketException {
      setState(() {
        isloading = false;
        errormessage = 'No Internet connection';
      });
    } on DioError catch (e) {
      print("error from dioerror");
      print(e.response!.data);
    } catch (e) {
      print("error from getdata: $e");
    }
  }

  List<Widget> AddVehicleNames() {
    var dIds = [];
    var vDids = [];
    for (var i in DeviceList) {
      dIds.add(i["id"]);
    }
    // print("inside addvehicles, device list :${dIds}");
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
    print(totVehicle);
    setState(() {});
    List<Widget> Demo = [];
    return Demo;
  }

  Future updateTrip() async {
    var dateFormat1 = DateFormat("yyyy-MM-dd");
    var timeFormat = DateFormat("HH:mm:ss");
    var userId = await storage.read(key: "org_ids") ??
        await storage.read(key: "temp_org_ids");
    userId ??= "1";
    print("drivernameselected");

    var drivernamesend;
    var vehiclenamesend;
    print(_driverNameselected);
    for (int i = 0; i < totTrip.length; i++) {
      if (_driverNameselected?.name == totTrip[i].name) {
        drivernamesend = totTrip[i].id;
      }
    }
    for (int i = 0; i < vehiclenames.length; i++) {
      if (_vehicleNameselected?.name == vehiclenames[i].name) {
        vehiclenamesend = vehiclenames[i].id;
      }
    }
    if (_driverNameselected != null) {
      DateTime starttime = DateFormat("HH:mm:ss")
          .parse(onstarttime ?? "")
          .subtract(Duration(hours: 5, minutes: 30));
      var stime = timeFormat.format(starttime);
      DateTime endtime = DateFormat("HH:mm:ss")
          .parse(onendtime ?? "")
          .subtract(Duration(hours: 5, minutes: 30));
      var etime = timeFormat.format(endtime);
      DateTime startdate = DateFormat("dd-MM-yyyy").parse(onstartdate ?? "");
      var sdate = dateFormat1.format(startdate);
      DateTime enddate = DateFormat("dd-MM-yyyy").parse(onenddate ?? "");
      var edate = dateFormat1.format(enddate);
      // print("onstart:$enddate");
      if (widget.category.toString().toLowerCase() == "one way") {
        datas = {
          "vehicleId": vehiclenamesend,
          "driverId": drivernamesend,
          "category": widget.category,
          "onwardStartDate": sdate,
          "onwardStartTime": stime,
          "onwardEndDate": edate,
          "onwardEndTime": etime,
          "endDate": edate,
          "status": widget.status,
          "tripName": trips,
          "orgId": userId,
          "uuid": widget.uuid,
          "tripId": widget.tripId,
          "applyForRecurring": widget.isRecurring
        };
      } else {
        DateTime starttime = DateFormat("HH:mm:ss")
            .parse(onstarttime ?? "")
            .subtract(Duration(hours: 5, minutes: 30));
        var stime = timeFormat.format(starttime);
        DateTime endtime = DateFormat("HH:mm:ss")
            .parse(onendtime ?? "")
            .subtract(Duration(hours: 5, minutes: 30));
        var etime = timeFormat.format(endtime);
        DateTime startdate = DateFormat("dd-MM-yyyy").parse(onstartdate ?? "");
        var sdate = dateFormat1.format(startdate);
        DateTime enddate = DateFormat("dd-MM-yyyy").parse(onenddate ?? "");
        var edate = dateFormat1.format(enddate);
        print("onstart:$edate");
        DateTime returnstart = DateFormat("HH:mm:ss")
            .parse(returnStartTimeController.text)
            .subtract(Duration(hours: 5, minutes: 30));
        var rstime = timeFormat.format(returnstart);
        DateTime returnend = DateFormat("HH:mm:ss")
            .parse(returnEndTimeController.text)
            .subtract(Duration(hours: 5, minutes: 30));
        var retime = timeFormat.format(returnend);
        DateTime restartdate =
            DateFormat("dd-MM-yyyy").parse(returnStartDateController.text);
        var resdate = dateFormat1.format(restartdate);
        DateTime reenddate =
            DateFormat("dd-MM-yyyy").parse(returnEndDateController.text);
        var reedate = dateFormat1.format(reenddate);
        datas = {
          "vehicleId": vehiclenamesend,
          "driverId": drivernamesend,
          "category": widget.category,
          "onwardStartDate": sdate,
          "onwardStartTime": stime,
          "onwardEndDate": edate,
          "onwardEndTime": etime,
          "endDate": edate,
          "returnStartDate": resdate,
          "returnStartTime": rstime,
          "returnEndDate": reedate,
          "returnEndTime": retime,
          "status": widget.status,
          "tripName": trips,
          "orgId": userId,
          "uuid": widget.uuid,
          "tripId": widget.tripId,
          "applyForRecurring": widget.isRecurring,
        };
      }

      print("editrip:${datas}");
      try {
        final result =
            await Dio().post("${baseUrl}trips/save-trip", data: datas);
        // print("asdadsa"+result.data);
        if (result.statusCode == 200) {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => manageTripScreen()));
          return true;
        }
      } on DioError catch (e) {
        print("errroror ${e.response?.data}");
        if (e.response?.statusCode == 400 || e.response?.statusCode == 404) {
          showSnackBar(context, e.response?.data['message']);
          return false;
        }
      }
    } else {
      //error msg here
      return false;
    }
  }

  bool isloading = false;
  dynamic vehicleName;

  dynamic trips;
  dynamic driver;
  dynamic onstartdate;
  dynamic onstarttime;
  dynamic onenddate;
  dynamic onendtime;
  dynamic restartdate;
  dynamic restarttime;
  dynamic reenddate;
  dynamic reendtime;
  String? startdate;
  String? starttime;
  String? enddate;
  String? endtime;
  String? returnstartdate;
  String? returnstarttime;
  String? returnenddate;
  String? returnendtime;
  @override
  void initState() {
    () async {
      setState(() {
        isloading = true;
      });

      await getVehicleName();
      await getdriverName();
      await AddVehicleNames();
      print("returnen:${widget.returnEndDateTime}");
      tripNameController.text = widget.tripName;
      if (widget.onwardStartDateTime != null ||
          widget.onwardStartDateTime != "--") {
        startdate = widget.onwardStartDateTime.toString().split(" ")[0];
        starttime = widget.onwardStartDateTime.toString().split(" ")[1];
        print("data1:${widget.onwardStartDateTime}");
        print("data:$startdate");
        print("datatime:$starttime");
        onwardStartDateController.text = startdate!;
        onwardStartTimeController.text = starttime! + ":00";
      }
      if (widget.onwardEndDateTime != null) {
        enddate = widget.onwardEndDateTime.toString().split(" ")[0];
        endtime = widget.onwardEndDateTime.toString().split(" ")[1];
        onwardEndDateController.text = enddate!;
        onwardEndTimeController.text = endtime! + ":00";
      }
      if (widget.category.toString().toLowerCase() == "round") {
        print("start:${widget.returnStartDateTime}");
        if (widget.returnStartDateTime != null &&
            widget.returnEndDateTime != "--") {
          returnstartdate = widget.returnStartDateTime.toString().split(" ")[0];
          returnstarttime = widget.returnStartDateTime.toString().split(" ")[1];
          returnStartDateController.text = returnstartdate!;
          returnStartTimeController.text = returnstarttime! + ":00";
        }

        if (widget.returnEndDateTime != null &&
            widget.returnEndDateTime != "--") {
          returnenddate = widget.returnEndDateTime.toString().split(" ")[0];
          returnendtime = widget.returnEndDateTime.toString().split(" ")[1];
          returnEndDateController.text = returnenddate!;
          returnEndTimeController.text = returnendtime! + ":00";
        }
      }
      setState(() {
        isloading = false;
      });
    }();
    super.initState();
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

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    print(widget.onwardStartDateTime);
    return SafeArea(
        child: Scaffold(
      key: _key,
      drawer: const NavBar(),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            centerTitle: true,
            leading: Padding(
                padding: const EdgeInsets.only(top: 15), child: _appBar()),
            title: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(translation(context).editTrips)),
            elevation: 0,
          )),
      body: isloading == true
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    Container(
                        child: Image.asset('images/tripimage.jpeg',
                            height: 198, width: 360, fit: BoxFit.cover)),
                    Container(
                      margin: const EdgeInsets.fromLTRB(0, 5, 0, 0),
                      padding: const EdgeInsets.fromLTRB(10, 10, 0, 20),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomRight,
                            colors: [Colors.white54, Colors.white54]),
                        // color:
                        // // Colors.white,
                        // Color(0xFF2196F3),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(30)),
                        // borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            offset: const Offset(0, 1),
                            blurRadius: 4,
                            color: Colors.black.withOpacity(0.2),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .06,
                            ),
                            Row(children: [
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
                                margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    validator: (val) {
                                      if (val == null || val == "") {
                                        return "Trip Name is Required";
                                      } else {
                                        return null;
                                      }
                                    },
                                    controller: tripNameController,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      label: Row(
                                        children: const [
                                          Text('*',
                                              style:
                                                  TextStyle(color: redColor)),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          Text(
                                            "Trip Name",
                                            style: TextStyle(
                                                color: blackColor,
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
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
                                  margin: EdgeInsets.fromLTRB(0, 0, 2, 0),
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  width:
                                      MediaQuery.of(context).size.width * .82,
                                  decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: DropdownSearch<VehicleDrop>(
                                    compareFn: (item1, item2) =>
                                        item1.id == item2.id,
                                    selectedItem: _vehicleNameselected,
                                    decoratorProps:
                                        const DropDownDecoratorProps(
                                            decoration: InputDecoration(
                                      hintText: 'Select Vehicle Name',
                                      hintStyle: TextStyle(color: Colors.black),
                                    )),
                                    popupProps: PopupProps.bottomSheet(
                                        searchFieldProps: TextFieldProps(
                                            decoration: InputDecoration(
                                                hintText:
                                                    "Select Vehicle Name")),
                                        showSearchBox: true),
                                    items: (filter, loadProps) async {
                                      return vehiclenames;
                                    },
                                    // asyncItems: (String filter) =>
                                    //     filterdata(filter),
                                    onSaved: (VehicleDrop? data) async {
                                      if (data != null) {
                                        setState(() {
                                          _vehicleNameselected = data;
                                          // EasyLoading.show(status: "Loading");
                                        });
                                        await getdata();

                                        print(
                                            "newvalue${_vehicleNameselected?.id}");
                                      }
                                    },
                                  )),
                            ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            Row(children: [
                              Icon(
                                Icons.person,
                                size: 40,
                                color: blueColor,
                              ),
                              Container(
                                  margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                  padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                  width:
                                      MediaQuery.of(context).size.width * .82,
                                  decoration: BoxDecoration(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(10))),
                                  child: DropdownSearch<Trips>(
                                    compareFn: (item1, item2) =>
                                        item1.id == item2.id,
                                    selectedItem: _driverNameselected,
                                    decoratorProps:
                                        const DropDownDecoratorProps(
                                            decoration: InputDecoration(
                                      hintText: 'Select Driver Name',
                                      hintStyle: TextStyle(color: Colors.black),
                                    )),
                                    popupProps: PopupProps.bottomSheet(
                                        searchFieldProps: TextFieldProps(
                                            decoration: InputDecoration(
                                                hintStyle: TextStyle(
                                                    color: Colors.black),
                                                hintText:
                                                    "Select Driver Name")),
                                        showSearchBox: true),
                                    items: (filter, loadProps) async {
                                      return totTrip;
                                    },
                                    // asyncItems: (String filter) =>
                                    //     filterTrip(filter),
                                    onSelected: (Trips? data) async {
                                      if (data != null) {
                                        setState(() {
                                          _driverNameselected = data;
                                          // EasyLoading.show(status: "Loading");
                                        });
                                        await getdata();
                                        print(
                                            "newvalue${_driverNameselected?.id}");
                                      }
                                    },
                                  )),
                            ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            Row(children: [
                              Icon(
                                Icons.date_range_sharp,
                                size: 40,
                                color: blueColor,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: widget.status == "In Progress" ||
                                          widget.status == "Inprogress" ||
                                          widget.status == "In progress"
                                      ? TextFormField(
                                          // enabled: false,
                                          validator: (value) {
                                            if (value == null) {
                                              return "Onward Start Date is required";
                                            }
                                          },
                                          onTap: () async {
                                            print("startdate:${startdate}");
                                            print(
                                                "startcontroller${onwardStartDateController.text}");
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateTime.now(),
                                              firstDate: DateTime.now(),
                                              lastDate: widget.isRecurring ==
                                                      true
                                                  ? DateTime.parse(
                                                      onwardStartDateController
                                                          .text)
                                                  : DateTime(2060),
                                            );
                                            if (pickedDate != null) {
                                              print(
                                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(pickedDate);
                                              print(formattedDate);
                                              setState(() {
                                                onwardStartDateController.text =
                                                    formattedDate.toString();
                                              });
                                            } else {
                                              return;
                                            }
                                          },
                                          controller: onwardStartDateController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon: const Icon(Icons.date_range,color: blueColor,),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Onward Start Date",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        )
                                      : TextFormField(
                                          validator: (value) {
                                            if (value == null) {
                                              return "Onward Start Date is required";
                                            }
                                          },
                                          onTap: () async {
                                            print("startdate:${startdate}");
                                            print(
                                                "startcontroller${onwardStartDateController.text}");
                                            print(DateFormat("dd-MM-yyyy")
                                                .parse(onwardStartDateController
                                                    .text));
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateFormat(
                                                      "dd-MM-yyyy")
                                                  .parse(
                                                      onwardStartDateController
                                                          .text),
                                              firstDate: DateFormat(
                                                      "dd-MM-yyyy")
                                                  .parse(
                                                      onwardStartDateController
                                                          .text),
                                              lastDate: widget.isRecurring ==
                                                      true
                                                  ? DateTime.now()
                                                      .add(Duration(days: 1))
                                                  : DateTime(2060),
                                            );
                                            if (pickedDate != null) {
                                              print(
                                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(pickedDate);
                                              print(formattedDate);
                                              setState(() {
                                                onwardStartDateController.text =
                                                    formattedDate.toString();
                                              });
                                              print("formatted$formattedDate");
                                            } else {
                                              return;
                                            }
                                          },
                                          controller: onwardStartDateController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon: const Icon(Icons.date_range,color: blueColor,),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Onward Start Date",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            Row(children: [
                              Icon(
                                Icons.timelapse,
                                size: 40,
                                color: blueColor,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: widget.status == "In Progress" ||
                                          widget.status == "Inprogress" ||
                                          widget.status == "In progress"
                                      ? TextFormField(
                                          enabled: false,
                                          validator: (value) {
                                            if (value == null) {
                                              return "Onward Start Time is required";
                                            }
                                          },
                                          onTap: () async {
                                            // final TimeOfDay? newTime =
                                            // await showTimePicker(
                                            //   context: context,
                                            //   initialTime: TimeOfDay.now(),
                                            // );
                                            // print(newTime);
                                            // if (newTime != null) {
                                            //   print(newTime);
                                            //   DateTime parsedTime = DateFormat.jm()
                                            //       .parse(newTime
                                            //       .format(context)
                                            //       .toString());
                                            //   String formattedTime =
                                            //   DateFormat('HH:mm:ss')
                                            //       .format(parsedTime);
                                            //   print(formattedTime);
                                            //   setState(() {
                                            //     onwardStartTimeController.text =
                                            //         formattedTime;
                                            //     print(newTime);
                                            //   });
                                            // }
                                          },
                                          controller:
                                              onwardStartTimeController.text ==
                                                      null
                                                  ? TextEditingController(
                                                      text: starttime ?? "")
                                                  : onwardStartTimeController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon:
                                            // const Icon(Icons.access_time_rounded),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Onward Start Time",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        )
                                      : TextFormField(
                                          validator: (value) {
                                            if (value == null) {
                                              return "Onward Start Time is required";
                                            }
                                          },
                                          onTap: () async {
                                            final TimeOfDay? newTime =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );
                                            print(newTime);
                                            if (newTime != null) {
                                              print(newTime);
                                              DateTime parsedTime =
                                                  DateFormat.jm().parse(newTime
                                                      .format(context)
                                                      .toString());
                                              String formattedTime =
                                                  DateFormat('HH:mm:ss')
                                                      .format(parsedTime);
                                              print(formattedTime);
                                              setState(() {
                                                onwardStartTimeController.text =
                                                    formattedTime;
                                                print(newTime);
                                              });
                                            }
                                          },
                                          controller:
                                              onwardStartTimeController.text ==
                                                      null
                                                  ? TextEditingController(
                                                      text: starttime ?? "")
                                                  : onwardStartTimeController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon:
                                            // const Icon(Icons.access_time_rounded),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Onward Start Time",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            Row(children: [
                              Icon(
                                Icons.date_range_sharp,
                                size: 40,
                                color: blueColor,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: widget.status == "In Progress" ||
                                          widget.status == "Inprogress" ||
                                          widget.status == "In progress"
                                      ? TextFormField(
                                          validator: (value) {
                                            if (value == null) {
                                              return "Onward End Date is required";
                                            }
                                          },
                                          onTap: () async {
                                            // var dat =DateTime.parse(onwardEndDateController.text);
                                            // var date=DateTime.parse(onwardEndDateController.text);
                                            // print(onwardEndDateController.text);

                                            var lastdate =
                                                DateFormat("dd-MM-yyyy").parse(
                                                    onwardEndDateController
                                                        .text);
                                            var lastdat =
                                                DateFormat("yyyy-MM-dd")
                                                    .format(lastdate);
                                            var date = DateFormat("dd-MM-yyyy")
                                                .parse(onwardStartDateController
                                                    .text);
                                            var dat = DateFormat("yyyy-MM-dd")
                                                .format(date);
                                            print("date:${lastdat}");
                                            print(dat);
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate:
                                                  DateTime.parse(lastdat),
                                              firstDate: DateTime.parse(dat),
                                              lastDate: widget.isRecurring ==
                                                      true
                                                  ? DateTime.parse(lastdat)
                                                  : DateTime.parse(lastdat)
                                                      .add(Duration(days: 180)),
                                            );
                                            if (pickedDate != null) {
                                              print(
                                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate =
                                                  DateFormat('yyyy-MM-dd')
                                                      .format(pickedDate);
                                              print(
                                                  "formatted${formattedDate}");
                                              setState(() {
                                                onwardEndDateController.text =
                                                    formattedDate.toString();
                                              });
                                            } else {
                                              return;
                                            }
                                          },
                                          controller: onwardEndDateController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon: const Icon(Icons.date_range),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Onward End Date",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        )
                                      : TextFormField(
                                          validator: (value) {
                                            if (value == null) {
                                              return "Onward End Date is required";
                                            }
                                          },
                                          onTap: () async {
                                            print(
                                                "end date:${DateFormat("dd-MM-yyyy").parse(onwardStartDateController.text)}");
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateFormat(
                                                      "dd-MM-yyyy")
                                                  .parse(
                                                      onwardStartDateController
                                                          .text),
                                              firstDate: DateFormat(
                                                      "dd-MM-yyyy")
                                                  .parse(
                                                      onwardStartDateController
                                                          .text),
                                              lastDate: widget.isRecurring ==
                                                      true
                                                  ? DateTime.now()
                                                      .add(Duration(days: 1))
                                                  : DateTime.now()
                                                      .add(Duration(days: 24)),
                                            );
                                            if (pickedDate != null) {
                                              print(
                                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(pickedDate);
                                              print(formattedDate);
                                              setState(() {
                                                onwardEndDateController.text =
                                                    formattedDate.toString();
                                              });
                                            } else {
                                              return;
                                            }
                                          },
                                          controller:
                                              onwardEndDateController.text ==
                                                      null
                                                  ? TextEditingController(
                                                      text: enddate ?? "")
                                                  : onwardEndDateController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon: const Icon(Icons.date_range),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Onward End Date",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            Row(children: [
                              Icon(
                                Icons.timelapse,
                                size: 40,
                                color: blueColor,
                              ),
                              Container(
                                margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                width: MediaQuery.of(context).size.width * .82,
                                decoration: const BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    validator: (value) {
                                      if (value == null) {
                                        return "Onward End Time is required";
                                      }
                                    },
                                    onTap: () async {
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
                                        String formattedTime =
                                            DateFormat('HH:mm:ss')
                                                .format(parsedTime);
                                        print(formattedTime);
                                        setState(() {
                                          onwardEndTimeController.text =
                                              formattedTime;
                                          print(newTime);
                                        });
                                      }
                                    },
                                    controller:
                                        onwardEndTimeController.text == null
                                            ? TextEditingController(
                                                text: endtime ?? "")
                                            : onwardEndTimeController,
                                    keyboardType: TextInputType.none,
                                    autofocus: false,
                                    decoration: InputDecoration(
                                      // suffixIcon:
                                      // const Icon(Icons.access_time_rounded),
                                      floatingLabelBehavior:
                                          FloatingLabelBehavior.always,
                                      label: Row(
                                        children: const [
                                          Text('*',
                                              style:
                                                  TextStyle(color: redColor)),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          Text(
                                            "Onward End Time",
                                            style: TextStyle(
                                                color: blackColor,
                                                fontWeight: FontWeight.w700),
                                          )
                                        ],
                                      ),
                                      border: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: const TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: const BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            widget.category.toString().toLowerCase() ==
                                    "one way"
                                ? const SizedBox()
                                : Row(children: [
                                    Icon(
                                      Icons.date_range_sharp,
                                      size: 40,
                                      color: blueColor,
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      width: MediaQuery.of(context).size.width *
                                          .82,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Center(
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null) {
                                              return "Return Start Date is required";
                                            }
                                          },
                                          onTap: () async {
                                            print(
                                                "return:${DateFormat("yyyy-MM-dd").parse(onwardEndDateController.text)}");
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateFormat(
                                                      "dd-MM-yyyy")
                                                  .parse(onwardEndDateController
                                                      .text),
                                              firstDate: DateFormat(
                                                      "dd-MM-yyyy")
                                                  .parse(onwardEndDateController
                                                      .text),
                                              lastDate: widget.isRecurring ==
                                                      true
                                                  ? DateTime.parse(
                                                      onwardEndDateController
                                                          .text)
                                                  : DateTime(2060),
                                            );
                                            if (pickedDate != null) {
                                              print(
                                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(pickedDate);
                                              print(formattedDate);
                                              setState(() {
                                                returnStartDateController.text =
                                                    formattedDate.toString();
                                              });
                                            } else {
                                              return;
                                            }
                                          },
                                          controller: returnStartDateController
                                                      .text ==
                                                  null
                                              ? TextEditingController(
                                                  text: returnstartdate ?? "")
                                              : returnStartDateController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon:
                                            // const Icon(Icons.date_range),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Return Start Date",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            widget.category.toString().toLowerCase() ==
                                    "one way"
                                ? const SizedBox()
                                : Row(children: [
                                    Icon(
                                      Icons.timelapse,
                                      size: 40,
                                      color: blueColor,
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      width: MediaQuery.of(context).size.width *
                                          .82,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Center(
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null) {
                                              return "Return Start Time is required";
                                            }
                                          },
                                          onTap: () async {
                                            final TimeOfDay? newTime =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );
                                            print(newTime);
                                            if (newTime != null) {
                                              print(newTime);
                                              DateTime parsedTime =
                                                  DateFormat.jm().parse(newTime
                                                      .format(context)
                                                      .toString());
                                              String formattedTime =
                                                  DateFormat('HH:mm:ss')
                                                      .format(parsedTime);
                                              print(formattedTime);
                                              setState(() {
                                                returnStartTimeController.text =
                                                    formattedTime;
                                                print(newTime);
                                              });
                                            }
                                          },
                                          controller: returnStartTimeController
                                                      .text ==
                                                  null
                                              ? TextEditingController(
                                                  text: returnstarttime ?? "")
                                              : returnStartTimeController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon: const Icon(
                                            //     Icons.access_time_rounded),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Return Start Time",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            widget.category.toString().toLowerCase() ==
                                    "one way"
                                ? const SizedBox()
                                : Row(children: [
                                    Icon(
                                      Icons.date_range_sharp,
                                      size: 40,
                                      color: blueColor,
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      width: MediaQuery.of(context).size.width *
                                          .82,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Center(
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null) {
                                              return "Return End Date is required";
                                            }
                                          },
                                          onTap: () async {
                                            DateTime? pickedDate =
                                                await showDatePicker(
                                              context: context,
                                              initialDate: DateFormat(
                                                      "dd-MM-yyyy")
                                                  .parse(
                                                      returnStartDateController
                                                          .text),
                                              firstDate: DateFormat(
                                                      "dd-MM-yyyy")
                                                  .parse(
                                                      returnStartDateController
                                                          .text),
                                              lastDate: widget.isRecurring ==
                                                      true
                                                  ? DateTime.parse(
                                                      returnStartDateController
                                                          .text)
                                                  : DateTime(2060),
                                            );
                                            if (pickedDate != null) {
                                              print(
                                                  pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                              String formattedDate =
                                                  DateFormat('dd-MM-yyyy')
                                                      .format(pickedDate);
                                              print(formattedDate);
                                              setState(() {
                                                returnEndDateController.text =
                                                    formattedDate.toString();
                                              });
                                            } else {
                                              return;
                                            }
                                          },
                                          controller:
                                              returnEndDateController.text ==
                                                      null
                                                  ? TextEditingController(
                                                      text: returnenddate ?? "")
                                                  : returnEndDateController,
                                          keyboardType: TextInputType.none,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon:
                                            // const Icon(Icons.date_range),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Return End Date",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            widget.category.toString().toLowerCase() ==
                                    "one way"
                                ? const SizedBox()
                                : Row(children: [
                                    Icon(
                                      Icons.timelapse,
                                      size: 40,
                                      color: blueColor,
                                    ),
                                    Container(
                                      margin: EdgeInsets.fromLTRB(0, 0, 3, 0),
                                      padding: EdgeInsets.fromLTRB(10, 0, 0, 0),
                                      width: MediaQuery.of(context).size.width *
                                          .82,
                                      decoration: const BoxDecoration(
                                          borderRadius: BorderRadius.all(
                                              Radius.circular(10))),
                                      child: Center(
                                        child: TextFormField(
                                          validator: (value) {
                                            if (value == null) {
                                              return "Return End Time is required";
                                            }
                                          },
                                          onTap: () async {
                                            final TimeOfDay? newTime =
                                                await showTimePicker(
                                              context: context,
                                              initialTime: TimeOfDay.now(),
                                            );
                                            print(newTime);
                                            if (newTime != null) {
                                              print(newTime);
                                              DateTime parsedTime =
                                                  DateFormat.jm().parse(newTime
                                                      .format(context)
                                                      .toString());
                                              String formattedTime =
                                                  DateFormat('HH:mm:ss')
                                                      .format(parsedTime);
                                              print(formattedTime);
                                              setState(() {
                                                returnEndTimeController.text =
                                                    formattedTime;
                                                print(newTime);
                                              });
                                            }
                                          },
                                          controller:
                                              returnEndTimeController.text ==
                                                      null
                                                  ? TextEditingController(
                                                      text: returnendtime ?? "")
                                                  : returnEndTimeController,
                                          keyboardType: TextInputType.number,
                                          autofocus: false,
                                          decoration: InputDecoration(
                                            // suffixIcon: const Icon(
                                            //     Icons.access_time_rounded),
                                            floatingLabelBehavior:
                                                FloatingLabelBehavior.always,
                                            label: Row(
                                              children: const [
                                                Text('*',
                                                    style: TextStyle(
                                                        color: redColor)),
                                                Padding(
                                                  padding: EdgeInsets.all(3.0),
                                                ),
                                                Text(
                                                  "Return End Time",
                                                  style: TextStyle(
                                                      color: blackColor,
                                                      fontWeight:
                                                          FontWeight.w700),
                                                )
                                              ],
                                            ),
                                            border: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.black),
                                              borderRadius:
                                                  BorderRadius.circular(5.0),
                                            ),
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                color: Colors.black,
                                                fontWeight: FontWeight.w400),
                                            errorBorder: UnderlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(7.0),
                                              borderSide: const BorderSide(
                                                color: Colors.red,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ]),
                            SizedBox(
                              height: MediaQuery.of(context).size.height * .02,
                            ),
                            errormessage.toString().isNotEmpty
                                ? Container(
                                    margin: EdgeInsets.fromLTRB(5, 5, 5, 0),
                                    child: Center(
                                      child: Text(
                                        errormessage,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: offlineColor),
                                      ),
                                    ),
                                  )
                                : Text(''),
                            CustomButton(
                                buttontext: "Update",
                                onpress: () async {
                                  if (vehiclenameController.text != "" ||
                                      vehiclenameController.text != null) {
                                    var vehicleName2 =
                                        vehiclenameController.text;
                                    vehicleName = vehicleName2;
                                    print('edited ');
                                    print(vehicleName);
                                  } else {
                                    print('not edted ');
                                    var vehicleName2 = widget.vehicleName;
                                    vehicleName = vehicleName2;
                                    print(vehicleName);
                                  }

                                  if (tripNameController.text != "") {
                                    var trips2 = tripNameController.text;
                                    trips = trips2;
                                    print('edited ');
                                    print(trips);
                                  } else {
                                    print('not edted ');
                                    var trips2 = widget.tripName;
                                    trips = trips2;
                                    print(trips);
                                  }

                                  if (driverNameController.text != "") {
                                    var driver2 = driverNameController.text;
                                    driver = driver2;
                                    print('edited ');
                                    print(driver);
                                  } else {
                                    print('not edted ');
                                    var driver2 = widget.driverName;
                                    driver = driver2;
                                  }

                                  if (onwardStartDateController.text != "") {
                                    var onstartdate2 =
                                        onwardStartDateController.text;
                                    onstartdate = onstartdate2;
                                    print('edited');
                                    print(onstartdate);
                                  } else {
                                    var onstartdate2 = startdate;
                                    onstartdate = onstartdate2;
                                    print("else$onstartdate");
                                  }

                                  if (onwardStartTimeController.text != "") {
                                    var onstarttime2 =
                                        onwardStartTimeController.text;
                                    onstarttime = onstarttime2;
                                    print('edited ');
                                    print(onstarttime);
                                  } else {
                                    var onstarttime2 = starttime;
                                    onstarttime = onstarttime2;
                                    print(onstarttime);
                                  }

                                  if (onwardEndDateController.text != "") {
                                    var onenddate2 =
                                        onwardEndDateController.text;
                                    onenddate = onenddate2;
                                    print('edited');
                                    print("onend:$onenddate");
                                  } else {
                                    var onenddate2 = enddate;
                                    onenddate = onenddate2;
                                    print(onenddate);
                                  }

                                  if (onwardEndTimeController.text != "") {
                                    var onendtime2 =
                                        onwardEndTimeController.text;
                                    onendtime = onendtime2;
                                    print('edited ');
                                    print(onendtime);
                                  } else {
                                    var onendtime2 = endtime;
                                    onendtime = onendtime2;
                                    print(onendtime);
                                  }
                                  if (widget.category
                                          .toString()
                                          .toLowerCase() !=
                                      "one way") {
                                    if (returnStartDateController.text != "") {
                                      var restartdate2 =
                                          returnStartDateController.text;
                                      restartdate = restartdate2;
                                      print('edited');
                                      print(restartdate);
                                    } else {
                                      var restartdate2 = returnstartdate;
                                      restartdate = restartdate2;
                                      print(restartdate2);
                                    }

                                    if (returnStartTimeController.text != "") {
                                      var restarttime2 =
                                          returnStartTimeController.text;
                                      restarttime = restarttime2;
                                      print('edited');
                                      print(restarttime);
                                    } else {
                                      var restarttime2 = returnstarttime;
                                      restarttime = restarttime2;
                                      print(restarttime);
                                    }

                                    if (returnEndDateController.text != "") {
                                      var reenddate2 =
                                          returnEndDateController.text;
                                      reenddate = reenddate2;
                                      print('edited ');
                                      print(reenddate);
                                    } else {
                                      var reenddate2 = returnenddate;
                                      reenddate = reenddate2;
                                      print(reenddate);
                                    }

                                    if (returnEndTimeController.text != "") {
                                      var reendtime2 =
                                          returnEndTimeController.text;
                                      reendtime = reendtime2;
                                      print('edited ');
                                      print(reendtime);
                                    } else {
                                      var reendtime2 = returnendtime;
                                      reendtime = reendtime2;
                                      print(reendtime);
                                    }
                                  }
                                  final data = await updateTrip();
                                  if (statuscode == 200) {
                                    print("all data:${data}");
                                    if (data) {
                                      showSnackBar(
                                          context, "Trip Updated Succesfully");
                                      route() {
                                        Navigator.pushReplacement(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  manageTripScreen()),
                                        );
                                        // Navigator.pop(context);
                                      }

                                      startTimer() async {
                                        var duration = Duration(seconds: 0);
                                        // return Timer(duration, route);
                                      }

                                      await startTimer();
                                    }
                                  } else {
                                    print(
                                        "value not updated  some error occured");
                                  }
                                }),
                            // SizedBox(
                            //   height: MediaQuery.of(context).size.height * .025,
                            // ),
                            Container(
                              margin: EdgeInsets.fromLTRB(40, 10, 40, 10),
                              child: Center(
                                child: TextButton(
                                    onPressed: () async {
                                      Navigator.of(context)
                                          .push(MaterialPageRoute(
                                        builder: (BuildContext context) =>
                                            manageTripScreen(),
                                      ));
                                      //   // (route) => false,
                                      // );
                                      // Navigator.pop(context);
                                    },
                                    child: Text("Cancel",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontSize: 20, color: Colors.blue))),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    ));
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
}

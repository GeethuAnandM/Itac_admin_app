import 'dart:math';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/custom_widget.dart';
import 'package:admin_app/screens/reportsscreen.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import "package:flutter/material.dart";
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../addvehiclescreen.dart';
import '../themes.dart';
import 'distanceReport.dart';
// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';

bool isRouteBtnClicked = false;

class RouteReportsScreen extends StatefulWidget {
  List<dynamic> vehicleList = [];
  List<dynamic> vehicleDetailslist = [];
  RouteReportsScreen(
      {super.key, required this.vehicleList, required this.vehicleDetailslist});

  @override
  State<RouteReportsScreen> createState() => _RouteReportsScreenState();
}

class _RouteReportsScreenState extends State<RouteReportsScreen> {
  bool downloadpdf = false;
  List<VehicleDetails> _showvehicleDetailslist = [];
  var _filterclicked;
  List<VehicleDrop> Vehicledetails = [];
  VehicleDrop? selectedVehicleDrop;
  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();

  DateTime? startDateNew;
  DateTime? endDateNew;
  List<dynamic> selectedVehicles = [];
  var reportInterval = 15;
  var reportIntervalController = TextEditingController();
  var submitClicked = false;
  var showTable2 = [];
  bool nodata = false;
  List<dynamic> showTable = [];
  bool isTime1GreaterThanTime2 = false;

  var startTime;
  var endTime;

  List<VehicleDrop> _fallbackVehicleTypes() {
    return widget.vehicleList
        .map((item) => VehicleDrop(
              item["id"]?.toString() ??
                  item["vehicleId"]?.toString() ??
                  item["deviceId"]?.toString() ??
                  '',
              item["name"]?.toString() ??
                  item["licensePlate"]?.toString() ??
                  item["vehicleName"]?.toString() ??
                  item["registrationNumber"]?.toString() ??
                  'Unknown Vehicle',
            ))
        .where((item) => item.id.isNotEmpty)
        .toList();
  }

  Future<List<VehicleDrop>> loadVehicleTypes(String filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("user_id");
      debugPrint('[RouteReport] loadVehicleTypes() triggered');
      debugPrint('[RouteReport] GET ${baseUrl}vehicle/vehicles/$userId');
      debugPrint('[RouteReport] userId: $userId');
      debugPrint('[RouteReport] filter: $filter');

      if (userId == null || userId.isEmpty) {
        debugPrint('[RouteReport] userId is missing for vehicles API');
        return _fallbackVehicleTypes();
      }

      final response = await Dio().get("${baseUrl}vehicle/vehicles/$userId");
      debugPrint('[RouteReport] list-vehicles status: ${response.statusCode}');
      debugPrint('[RouteReport] list-vehicles raw response: ${response.data}');

      final rawData = response.data is List
          ? List<dynamic>.from(response.data)
          : <dynamic>[];
      final loadedVehicles = rawData
          .map((item) => VehicleDrop(
                item['vehicleId']?.toString() ??
                    item['id']?.toString() ??
                    item['deviceId']?.toString() ??
                    '',
                item['licensePlate']?.toString() ??
                    item['name']?.toString() ??
                    item['vehicleName']?.toString() ??
                    item['registrationNumber']?.toString() ??
                    'Unknown Vehicle',
              ))
          .where((item) => item.id.toString().isNotEmpty)
          .toList();

      final normalizedFilter = filter.trim().toLowerCase();
      final filteredVehicles = normalizedFilter.isEmpty
          ? loadedVehicles
          : loadedVehicles
              .where(
                  (item) => item.name.toLowerCase().contains(normalizedFilter))
              .toList();

      Vehicledetails = loadedVehicles;
      debugPrint(
          '[RouteReport] mapped vehicles: ${filteredVehicles.map((e) => '${e.id}:${e.name}').toList()}');
      return filteredVehicles;
    } catch (e) {
      debugPrint('[RouteReport] Unable to load vehicles: $e');
      final fallbackVehicles = _fallbackVehicleTypes();
      Vehicledetails = fallbackVehicles;
      return fallbackVehicles;
    }
  }

  Future<List<dynamic>> getRouteReport(
      var fromDate, fromTime, toDate, toTime, vehiclesList) async {
    print('input data are:');
    print(fromDate);
    print(fromTime);
    print(toDate);
    print(toTime);
    print(vehiclesList);
    // String timeString = "18:58 PM";
    // List<String> timeParts = fromTime.split(":");
    // String timeWithoutAMPM = timeParts[0] + ":" + timeParts[1];
    String timeWithoutAMPM = fromTime.substring(0, 5);
    print(timeWithoutAMPM);
    String timeWithoutAMPM2 = toTime.substring(0, 5);
    if (fromDate == toDate) {
      DateTime dateTime1 = DateFormat("hh:mm a").parse(fromTime);
      DateTime dateTime2 = DateFormat("hh:mm a").parse(toTime);
      isTime1GreaterThanTime2 = dateTime1.isAfter(dateTime2);
      print("time is gfreater roite than: $isTime1GreaterThanTime2");
    }
    print(fromTime);

    print(fromTime);
    if (fromTime.toString().contains("PM")) {
      startTime = startTime.toString().replaceAll("00:", "12:");
    }
    print("to timeissss:$toTime");

    if (toTime.toString().contains("PM") && toTime.toString().contains("12:")) {
      endTime = endTime.toString().replaceAll("00:", "12:");
    }
    print("the value passing final is:${startTime}");
    print("the value passing final endTime is:${endTime}");
    print("time issssshgdgdg ${fromDate}T${fromTime}");
    // List<String> timeParts2 = toTime.split(":");
    // String timeWithoutAMPM2 = timeParts2[0] + ":" + timeParts2[1];
    print("all device ids from reportInterval: ${reportInterval}");
    var data = {
      "fromTime": "${fromDate}T$startTime:00.048Z",
      "listDevices": vehiclesList,
      "reportInterval": reportInterval,
      "toTime": "${toDate}T$endTime:00.048Z",
    };
    print(data);
    showTable.clear();
    const url2 = "${baseUrl}api/route-report";
    try {
      print('route report in try');
      var dio = Dio();
      final response = await dio.post(url2, data: data);
      showTable2 = response.data;
      print(showTable2);
      print(showTable2.length);
      print(response);
      int a = response.data.length;
      if (a == 0) {
        setState(() {
          nodata = true;
          submitClicked = false;
        });
      } else {
        try {
          for (var i = 0; i < a; i++) {
            double lat = showTable2[i]['lattitude'];
            double long = showTable2[i]['longitude'];
            print("the late is: $lat");
            print("the longi is: $long");
            final url =
                "http://13.234.100.167/nominatim/reverse?format=json&lat=$lat&lon=$long&zoom=18&addressdetails=1";
            final location = await dio.get(url);
            print("my location data is:${location.data}");
            List<Map<String, dynamic>> locationdata = [location.data];
            print("my location is:${locationdata}");
            print(location.data['display_name']);
            // final inputFormat = DateFormat("HH:mm");
            // final outputFormat = DateFormat("hh:mm a");
            // final inputTimeDate = inputFormat.parse(showTable2[i]['startTime']);
            // var convertedTime= outputFormat.format(inputTimeDate);
            // print("selected time to convert is2:$convertedTime");
            print("selected showww :${showTable2[i]['routeInstanceTime']}");
            // DateTime dateTime = DateTime.parse(showTable2[i]['routeInstanceTime'].toString());
            // DateFormat formatter = DateFormat('dd-MM-yyyy hh:mm a');
            // final inputDate = DateTime.parse(showTable2[i]['routeInstanceTime']);
            // final convertedTime = DateFormat('yyyy-MM-dd | hh:mm:ss a').format(inputDate);
            // String convertedTime = formatter.format(dateTime);
            // print("selected time to convert is2:$convertedTime");

            showTable.add({
              "deviceName": showTable2[i]['deviceName'],
              "routeInstanceTime": showTable2[i]['routeInstanceTime'],
              // convertedTime,
              "distance": showTable2[i]['distance'],
              "cumulativeDistance": showTable2[i]['cumulativeDistance'],
              "fromLocation": location.data['display_name']
            });
            print("my table is:$showTable");
          }
        } catch (e) {
          print(e);
          print('error occured');
        }
        setState(() {
          // isRouteBtnClicked = true;
          showTable = showTable;
          submitClicked = false;
          _filterclicked = true;
          _showvehicleDetailslist = _showvehicleDetailslist;
          downloadpdf = true;
        });
      }
      // vehLocationList = await response.data;
      // print("in get getDeviceCurrentLocation");
      // setState(() {
      //   loader = false;
      // });
    } catch (e) {
      print(e);
      setState(() {
        submitClicked = false;
      });
      print("Some error occured");
    }
    // print("online count: ${onlineVehicles}");
    List<dynamic> vehLocationList = [];
    return vehLocationList;
  }

  List<Widget> AddVehicleNames() {
    Vehicledetails = _fallbackVehicleTypes();
    setState(() {});

    List<Widget> Demo = [];
    return Demo;
  }

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime =
        DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  void initState() {
    () {
      AddVehicleNames();
      reportIntervalController =
          TextEditingController(text: reportInterval.toString());

      setState(() {
        isRouteBtnClicked = false;
      });
    }();
    super.initState();
  }

  @override
  void dispose() {
    isRouteBtnClicked = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // print("widget is that: ${widget.vehicleList}");
    print(Vehicledetails);
    return ListView(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin:
                const EdgeInsets.only(left: 8, right: 8, bottom: 0.0, top: 0.0),
            padding: const EdgeInsets.only(
                left: 10, right: 10, bottom: 20, top: 0.0),
            decoration: BoxDecoration(
              color: Colors.white60,
              borderRadius: BorderRadius.circular(4),
              // boxShadow: [
              //   BoxShadow(
              //     offset: const Offset(0, 1),
              //     blurRadius: 2,
              //     color: Colors.black.withOpacity(0.2),
              //   ),
              // ],
            ),
            // color: Color(0xFF0B6ECB),
            // height: downloadpdf == true
            //     ? MediaQuery.of(context).size.height * .55
            //     : MediaQuery.of(context).size.height * .47,
            width: MediaQuery.of(context).size.width * .98,
            child: SingleChildScrollView(
              child: Column(
                // mainAxisAlignment: MainAxisAlignment.start,
                // crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        color: Colors.white54,
                        width: 150,
                        child: TextFormField(
                          onTap: isRouteBtnClicked == true
                              ? () {
                                  const snackBar = SnackBar(
                                    content: Text(
                                        'Cannot pick date after submitting the data'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              : () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.now(),
                                    firstDate: DateTime.now()
                                        .subtract(Duration(days: 5000)),
                                    lastDate: DateTime.now(),
                                  );

                                  if (pickedDate != null) {
                                    print(
                                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    print(formattedDate);
                                    setState(() {
                                      _startDateController.text = formattedDate;
                                    });
                                  } else {
                                    print("Date is not selected");
                                  }

                                  // DateTimeRange? result = await showDateRangePicker(
                                  //   context: context,
                                  //   firstDate: DateTime(2022, 1, 1), // the earliest allowable
                                  //   lastDate: DateTime(2030, 12, 31), // the latest allowable
                                  //   currentDate: DateTime.now(),
                                  //   saveText: 'Done',
                                  // );
                                  // print(result);
                                  // DateTime? startDate = result?.start;
                                  // DateTime? endDate = result?.end;
                                  // String start = startDate.toString().split(' ')[0];
                                  // String end = endDate.toString().split(' ')[0];
                                  // if (result != null) {
                                  //   setState(() {
                                  //     startDateController.text = start.toString();
                                  //     endDateController.text = end.toString();
                                  //     //set output date to TextField value.
                                  //   });
                                  // } else {
                                  //   print("Date is not selected");
                                  // }
                                },
                          readOnly: true,
                          controller: _startDateController,
                          style: const TextStyle(height: 1),
                          decoration: InputDecoration(
                            label: Row(
                              children: [
                                const Text('*',
                                    style: TextStyle(color: Colors.red)),
                                const Padding(
                                  padding: EdgeInsets.all(3.0),
                                ),
                                const Text(
                                  "Start Date",
                                  style: TextStyle(color: Colors.black),
                                )
                              ],
                            ),
                            // suffixText: '*',
                            suffixStyle: const TextStyle(
                              color: Colors.red,
                            ),
                            hintText: 'Start Date',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white54,
                        width: 150,
                        margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            label: Row(
                              children: [
                                const Text('*',
                                    style: TextStyle(color: Colors.red)),
                                const Padding(
                                  padding: EdgeInsets.all(3.0),
                                ),
                                const Text(
                                  "Start Time",
                                  style: TextStyle(color: Colors.black),
                                )
                              ],
                            ),
                            // suffixText: '*',
                            suffixStyle: const TextStyle(
                              color: Colors.red,
                            ),
                            hintText: 'Start Time',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                          ),
                          controller: _startTimeController,
                          onTap: isRouteBtnClicked == true
                              ? () {
                                  const snackBar = SnackBar(
                                    content: Text(
                                        'Cannot pick date after submitting the data'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              : () async {
                                  final TimeOfDay? time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  print(time.toString());
                                  if (time != null) {
                                    // final dateFormat = DateFormat('hh:mm a');
                                    DateTime tempDate = DateFormat("hh:mm")
                                        .parse(time.hour.toString() +
                                            ":" +
                                            time.minute.toString());
                                    var dateFormat = DateFormat(
                                        "HH:mm"); // you can change the format here
                                    print(dateFormat.format(tempDate));
                                    var finaltime = dateFormat.format(tempDate);
                                    print(finaltime);
                                    var dateFormat2 = DateFormat(
                                        "HH:mm aa"); // you can change the format here
                                    print(dateFormat.format(tempDate));
                                    var finaltime222 =
                                        dateFormat2.format(tempDate);
                                    print("the start time222 is:$finaltime222");
                                    String formattedTime = formatTime(time);
                                    print(formattedTime);
                                    List<String> timeParts =
                                        finaltime.split(':');

                                    int hours = int.parse(timeParts[0]);
                                    int minutes = int.parse(timeParts[1]);

                                    print('Hours: $hours');
                                    print('Minutes: $minutes');
                                    startDateNew = DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      hours,
                                      minutes,
                                    );
                                    print(
                                        'new time issss Minutes: $startDateNew');
                                    print(
                                        time.format(context)); //output 10:51 PM
                                    setState(() {
                                      startTime = finaltime;
                                      _startTimeController.text = formattedTime;
                                      // time.format(context);
                                    });
                                    //DateFormat() is from intl package, you can format the time on any pattern you need.
                                  } else {
                                    print("Time is not selected");
                                  }
                                },
                        ),
                      ),

                      // endDateController.text.isNotEmpty ?
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        color: Colors.white54,
                        width: 150,
                        child: TextFormField(
                          onTap: isRouteBtnClicked == true
                              ? () {
                                  const snackBar = SnackBar(
                                    content: Text(
                                        'Cannot pick date after submitting the data'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              : () async {
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime.parse(
                                        _startDateController.text),
                                    firstDate: DateTime.parse(
                                        _startDateController.text),
                                    lastDate: DateTime.now(),
                                  );

                                  if (pickedDate != null) {
                                    print(
                                        pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                    String formattedDate =
                                        DateFormat('yyyy-MM-dd')
                                            .format(pickedDate);
                                    print(formattedDate);
                                    setState(() {
                                      _endDateController.text = formattedDate;
                                    });
                                  } else {
                                    print("Date is not selected");
                                  }
                                },
                          readOnly: true,
                          controller: _endDateController,
                          style: const TextStyle(height: 1),
                          decoration: InputDecoration(
                            label: Row(
                              children: [
                                const Text('*',
                                    style: TextStyle(color: Colors.red)),
                                const Padding(
                                  padding: EdgeInsets.all(3.0),
                                ),
                                const Text(
                                  "End Date",
                                  style: TextStyle(color: Colors.black),
                                )
                              ],
                            ),
                            // suffixText: '*',
                            suffixStyle: const TextStyle(
                              color: Colors.red,
                            ),
                            hintText: 'End Date',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                          ),
                        ),
                      ),
                      Container(
                        color: Colors.white54,
                        width: 150,
                        margin: const EdgeInsets.fromLTRB(5, 10, 5, 5),
                        child: TextFormField(
                          readOnly: true,
                          decoration: InputDecoration(
                            label: Row(
                              children: [
                                const Text('*',
                                    style: TextStyle(color: Colors.red)),
                                const Padding(
                                  padding: EdgeInsets.all(3.0),
                                ),
                                const Text(
                                  "End Time",
                                  style: TextStyle(color: Colors.black),
                                )
                              ],
                            ),
                            // suffixText: '*',
                            suffixStyle: const TextStyle(
                              color: Colors.red,
                            ),
                            hintText: 'End Time',
                            hintStyle: const TextStyle(color: Colors.grey),
                            border: new OutlineInputBorder(
                              borderSide: new BorderSide(color: Colors.black),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                          ),
                          controller: _endTimeController,
                          onTap: isRouteBtnClicked == true
                              ? () {
                                  const snackBar = SnackBar(
                                    content: Text(
                                        'Cannot pick date after submitting the data'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              : () async {
                                  final TimeOfDay? time = await showTimePicker(
                                    context: context,
                                    initialTime: TimeOfDay.now(),
                                    builder:
                                        (BuildContext context, Widget? child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(
                                            alwaysUse24HourFormat: true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  if (time != null) {
                                    DateTime tempDate = DateFormat("hh:mm")
                                        .parse(time.hour.toString() +
                                            ":" +
                                            time.minute.toString());
                                    var dateFormat = DateFormat(
                                        "HH:mm"); // you can change the format here
                                    print(dateFormat.format(tempDate));
                                    var finaltime = dateFormat.format(tempDate);
                                    print(finaltime);
                                    var dateFormat2 = DateFormat(
                                        "HH:mm aa"); // you can change the format here
                                    print(dateFormat.format(tempDate));
                                    var finaltime222 =
                                        dateFormat2.format(tempDate);
                                    print("the start time222 is:$finaltime222");
                                    String formattedTime = formatTime(time);
                                    print(formattedTime);
                                    List<String> timeParts =
                                        finaltime.split(':');

                                    int hours = int.parse(timeParts[0]);
                                    int minutes = int.parse(timeParts[1]);

                                    print('Hours: $hours');
                                    print('Minutes: $minutes');
                                    endDateNew = DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      hours,
                                      minutes,
                                    );
                                    print(
                                        'new time issss Minutes: $startDateNew');
                                    print(time.format(context));
                                    setState(() {
                                      endTime = finaltime;
                                      _endTimeController.text = formattedTime;
                                      // time.format(context);
                                    });
                                    //DateFormat() is from intl package, you can format the time on any pattern you need.
                                  } else {
                                    print("Time is not selected");
                                  }
                                },
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 300,
                    margin: EdgeInsets.fromLTRB(5, 5, 5, 25),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text("Report Interval"),
                        Container(
                          margin: const EdgeInsets.fromLTRB(5, 0, 5, 0),
                          width: 70,
                          child: TextFormField(
                            enabled: isRouteBtnClicked == true ? false : true,
                            keyboardType: TextInputType.number,
                            // readOnly: true,
                            decoration: InputDecoration(
                              suffixStyle: const TextStyle(
                                color: Colors.red,
                              ),
                              hintText: '50',
                              hintStyle: const TextStyle(color: Colors.grey),
                              border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(7.0),
                              ),
                            ),
                            controller: reportIntervalController,
                            // onTap: () async {},
                            onFieldSubmitted: (String value) {
                              print("fierld is submitted $value");
                              setState(() {
                                reportInterval = int.parse(value);
                              });
                            },
                          ),
                        ),
                        Column(
                          // mainAxisAlignment: MainAxisAlignment.center,
                          // crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              child: const Icon(
                                Icons.arrow_drop_up,
                                size: 50,
                              ),
                              onTap: isRouteBtnClicked == true
                                  ? () {
                                      const snackBar = SnackBar(
                                        content: Text(
                                            'Cannot pick date after submitting the data'),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  : () {
                                      setState(() {
                                        reportInterval++;
                                        reportIntervalController.text =
                                            reportInterval.toString();
                                      });
                                    },
                            ),
                            InkWell(
                              child: const Icon(
                                Icons.arrow_drop_down,
                                size: 50,
                              ),
                              onTap: isRouteBtnClicked == true
                                  ? () {
                                      const snackBar = SnackBar(
                                        content: Text(
                                            'Cannot pick date after submitting the data'),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  : () {
                                      setState(() {
                                        print(
                                            "print decrement value$reportInterval");
                                        if (reportInterval == 0) {
                                        } else {
                                          reportInterval--;
                                          reportIntervalController.text =
                                              reportInterval.toString();
                                        }
                                      });
                                    },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Container(
                    // margin: const EdgeInsets.fromLTRB(5, 10, 5, 15),

                    // height: 100,
                    // width: 300,
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                    // margin: const EdgeInsets.fromLTRB(5, 10, 5, 15),
                    height: 25.h,

                    // height: 100,
                    // width: 300,
                    child: SingleChildScrollView(
                      child: DropdownSearch<VehicleDrop>(
                        enabled: isRouteBtnClicked != true,
                        items: (filter, loadProps) => loadVehicleTypes(filter),
                        selectedItem: selectedVehicleDrop,
                        compareFn:
                            (VehicleDrop item, VehicleDrop selectedItem) {
                          return item.id == selectedItem.id;
                        },
                        itemAsString: (VehicleDrop item) => item.name,
                        decoratorProps: DropDownDecoratorProps(
                           decoration: InputDecoration(
                          hintText: 'Select Vehicle',
                          helperText: 'Single vehicle only',
                          label: Row(
                            children: [
                              const Text('*',
                                  style: TextStyle(color: Colors.red)),
                              const Padding(
                                padding: EdgeInsets.all(3.0),
                              ),
                              const Text(
                                "Select Vehicle",
                                style: TextStyle(color: Colors.black),
                              )
                            ],
                          ),
                          enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(7)),
                        )),
                        popupProps: const PopupProps.menu(
                          searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                  hintText: "Search Vehicles",
                                  hintStyle: TextStyle(color: Colors.grey))),
                          showSearchBox: true,
                        ),
                        onSelected: (VehicleDrop? data) {
                          setState(() {
                            selectedVehicleDrop = data;
                            selectedVehicles =
                                data == null ? [] : [data.id.toString()];
                          });
                          print(selectedVehicles);
                        },
                      ),
                    ),
                  ),
                  submitClicked == true
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: buttonColor,
                          ),
                        )
                      : Container(
                          margin: const EdgeInsets.fromLTRB(5, 10, 5, 15),
                          child: CustomButton(
                              buttontext: "Submit",
                              onpress: () async {
                                if (_startDateController.text.isEmpty ||
                                    _endDateController.text.isEmpty ||
                                    _startTimeController.text.isEmpty ||
                                    _endTimeController.text.isEmpty ||
                                    selectedVehicles.isEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        Future.delayed(Duration(seconds: 4),
                                            () {
                                          Navigator.of(context,
                                                  rootNavigator: true)
                                              .pop();
                                        });
                                        return AlertDialog(
                                          title: Center(
                                            child: Text(
                                              "Please fill all required fields before submitting",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          ),
                                        );
                                      });
                                  return;
                                }
                                bool? isTime1BeforeTime2 =
                                    endDateNew?.isBefore(startDateNew!);
                                print("ned time is:$isTime1BeforeTime2");
                                if (DateTime.parse(_startDateController.text)
                                        .compareTo(DateTime.parse(
                                            _endDateController.text)) >
                                    0) {
                                  print("Enddate is before Startdate");
                                  final snackBar = const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(bottom: 230.0),
                                    content: Text(
                                        'End date cannot be before the start date'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                  return;
                                }
                                // if(isTime1BeforeTime2 == true){
                                //   final snackBar = const SnackBar(
                                //     behavior: SnackBarBehavior.floating,
                                //     margin: EdgeInsets.only(bottom: 230.0),
                                //     content: Text(
                                //         'End time cannot be before the start time'),
                                //   );
                                //   ScaffoldMessenger.of(context)
                                //       .showSnackBar(snackBar);
                                // }
                                else {
                                  setState(() {
                                    submitClicked = true;
                                  });
                                  await getRouteReport(
                                      _startDateController.text,
                                      _startTimeController.text,
                                      _endDateController.text,
                                      _endTimeController.text,
                                      selectedVehicles);
                                  if (showTable.length != 0) {
                                    showModalBottomSheet(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return Wrap(children: [
                                          Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Center(
                                                child: Container(
                                                  margin: EdgeInsets.fromLTRB(
                                                      0, 15, 0, 10),
                                                  color: Colors.black26,
                                                  width: 50,
                                                  height: 2,
                                                ),
                                              ),
                                              GestureDetector(
                                                  child: Container(
                                                    margin: EdgeInsets.fromLTRB(
                                                        8, 10, 5, 15),
                                                    child: Row(
                                                      children: [
                                                        Icon(Icons
                                                            .download_for_offline_rounded),
                                                        SizedBox(
                                                          width: 8,
                                                        ),
                                                        Text("Download Pdf"),
                                                        SizedBox(
                                                          width: 5,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  onTap: () async {
                                                    await createPDF();
                                                    print("pdf added");
                                                  }),
                                              Flex(
                                                  direction: Axis.vertical,
                                                  children: [
                                                    Container(
                                                      // height: MediaQuery.of(context).size.height * .45,
                                                      child:
                                                          SingleChildScrollView(
                                                        scrollDirection:
                                                            Axis.horizontal,
                                                        child:
                                                            SingleChildScrollView(
                                                                scrollDirection:
                                                                    Axis
                                                                        .horizontal,
                                                                child:
                                                                    Container(
                                                                  // margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                                                                  // padding: EdgeInsets.fromLTRB(0, 0, 0, 50),
                                                                  width: 1200,
                                                                  height: MediaQuery.of(
                                                                              context)
                                                                          .size
                                                                          .height *
                                                                      .45,
                                                                  child:
                                                                      DataTable2(
                                                                    headingRowHeight:
                                                                        40,
                                                                    dataRowHeight:
                                                                        100,
                                                                    scrollController:
                                                                        ScrollController(),
                                                                    // minWidth: 3,
                                                                    columnSpacing:
                                                                        6,
                                                                    fixedTopRows:
                                                                        1,
                                                                    columns: const <
                                                                        DataColumn>[
                                                                      DataColumn(
                                                                          label:
                                                                              Text("Sl No")),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Vehicle Name')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text("Date Time")),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Distance(KM)')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text("Cumulative Distance(KM)")),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Location')),
                                                                    ],
                                                                    rows: List
                                                                        .generate(
                                                                      showTable
                                                                          .length,
                                                                      (index) =>
                                                                          DataRow(
                                                                        cells: <
                                                                            DataCell>[
                                                                          DataCell(
                                                                              Text("${index + 1}")),
                                                                          DataCell(
                                                                              Text(showTable[index]['deviceName'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['routeInstanceTime'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['distance'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['cumulativeDistance'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['fromLocation'].toString())),
                                                                          // DataCell(Text(usersFiltered[index].district)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )),
                                                      ),
                                                    ),
                                                  ]),

                                              // Container(
                                              //   child: ListView(
                                              //     scrollDirection: Axis.horizontal,
                                              //     children: [
                                              //       Container(
                                              //       // height:
                                              //       // 550,
                                              //       // MediaQuery.of(context).size.height * .82,
                                              //       width:
                                              //       // MediaQuery.of(context).size.width * 1.42,
                                              //       1000,
                                              //       // MediaQuery.of(context).size.width * 10,
                                              //       child:
                                              //       DataTable2(
                                              //         headingRowHeight: 40,
                                              //         dataRowHeight: 100,
                                              //         scrollController: ScrollController(),
                                              //         // minWidth: 1,
                                              //         columnSpacing: 5,
                                              //         fixedTopRows: 1,
                                              //         columns: const <DataColumn>[
                                              //           DataColumn(label: Text("Sl No")),
                                              //           DataColumn(label: Text('Vehicle Name')),
                                              //           DataColumn(label: Text('Start Date')),
                                              //           DataColumn(label: Text('Start Time')),
                                              //           DataColumn(label: Text('Duration')),
                                              //           DataColumn(label: Text('Location')),
                                              //
                                              //         ],
                                              //         rows: List.generate(
                                              //
                                              //           showTable.length,
                                              //               (index) => DataRow(
                                              //             cells: <DataCell>[
                                              //               DataCell(Text("${index + 1}")),
                                              //               DataCell(Text(showTable[index]['vehicleName'].toString())),
                                              //               DataCell(Text(showTable[index]['startDate'].toString())),
                                              //               DataCell(Text(showTable[index]['startTime'].toString())),
                                              //               DataCell(Text(showTable[index]['duration'].toString())),
                                              //               DataCell(Text(showTable[index]['fromLocation'].toString())),
                                              //
                                              //               // DataCell(Text(usersFiltered[index].district)),
                                              //             ],
                                              //           ),
                                              //         ),
                                              //       ),
                                              //     ),
                                              //           ]
                                              //   ),
                                              // ),
                                            ],
                                          ),
                                        ]);
                                      },
                                      isDismissible: false,
                                    );
                                  } else if (_startDateController
                                          .text.isEmpty ||
                                      _startTimeController.text.isEmpty ||
                                      _endDateController.text.isEmpty ||
                                      _endTimeController.text.isEmpty ||
                                      selectedVehicles.isEmpty) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          // Future.delayed(
                                          //     Duration(
                                          //         seconds: 3), () {
                                          //   Navigator.of(context, rootNavigator: true).pop();
                                          // }
                                          // );
                                          return AlertDialog(
                                            title: Text(
                                              "Please fill all required fields before submitting",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          );
                                        });
                                  } else if (isTime1GreaterThanTime2 != true &&
                                      nodata == true) {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          Future.delayed(Duration(seconds: 4),
                                              () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          });
                                          return AlertDialog(
                                            title: Text(
                                              isTime1GreaterThanTime2 == true
                                                  ? "End time cannot be before the start time"
                                                  : "No Records Found",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          );
                                        });
                                  } else {
                                    showDialog(
                                        context: context,
                                        builder: (context) {
                                          Future.delayed(Duration(seconds: 4),
                                              () {
                                            Navigator.of(context,
                                                    rootNavigator: true)
                                                .pop();
                                          });
                                          return AlertDialog(
                                            title: Text(
                                              isTime1GreaterThanTime2 == true
                                                  ? "End time cannot be before the start time"
                                                  : "Some error occured",
                                              style: TextStyle(fontSize: 15),
                                            ),
                                          );
                                        });
                                  }

                                  // Addvehicles();
                                  setState(() {
                                    _filterclicked = true;
                                  });
                                  print("data added");
                                }
                              }),
                        ),
                  // downloadpdf == true
                  //     ? Container(
                  //   margin: const EdgeInsets.fromLTRB(5, 10, 5, 15),
                  //   child: CustomButton(
                  //       buttontext: "Download PDF",
                  //       onpress: () async {
                  //         await createPDF();
                  //         print("pdf added");
                  //       }),
                  // )
                  //     : const SizedBox(),
                ],
              ),
            ),
          ),
          // Container(
          //     margin: const EdgeInsets.only(
          //         left: 8, right: 8, bottom: 0.0, top: 20),
          //     padding: const EdgeInsets.only(
          //         left: 10, right: 10, bottom: 0.0, top: 0.0),
          //     decoration: BoxDecoration(
          //       color: Colors.white,
          //       borderRadius: BorderRadius.circular(4),
          //       boxShadow: [
          //         BoxShadow(
          //           offset: const Offset(0, 1),
          //           blurRadius: 2,
          //           color: Colors.black.withOpacity(0.2),
          //         ),
          //       ],
          //     ),
          //     // color: Color(0xFF0B6ECB),
          //     height: MediaQuery.of(context).size.height * .98,
          //     width: MediaQuery.of(context).size.width * .98,
          //     child: _filterclicked == true
          //         ?
          //     SingleChildScrollView(
          //       scrollDirection: Axis.horizontal,
          //       child: SingleChildScrollView(
          //         scrollDirection: Axis.horizontal,
          //         child: Container(
          //           height:
          //           // 550,
          //           MediaQuery.of(context).size.height * .82,
          //           width:
          //           // MediaQuery.of(context).size.width * 1.42,
          //           500,
          //           // MediaQuery.of(context).size.width * 10,
          //           child: DataTable2(
          //             fixedTopRows: 1,
          //             columns: const <DataColumn>[
          //               DataColumn(label: Text("Sl No")),
          //               DataColumn(label: Text('Vehicle Name')),
          //               DataColumn(label: Text('Distance')),
          //             ],
          //             rows: List.generate(
          //               showTable.length,
          //                   (index) => DataRow(
          //                 cells: <DataCell>[
          //                   DataCell(Text("${index + 1}")),
          //                   DataCell(Text(showTable[index]['deviceName'].toString())),
          //                   DataCell(Text(showTable[index]['distance'].toString())),
          //
          //                   // DataCell(Text(usersFiltered[index].district)),
          //                 ],
          //               ),
          //             ),
          //           ),
          //         ),
          //       ),
          //     )
          //         : const Text("")),
        ],
      ),
    ]);
  }

  Future<void> createPDF() async {
    //Create a PDF document.
    final PdfDocument document = PdfDocument();

    //Add page to the PDF
    final PdfPage page = document.pages.add();
    //Get page client size
    final Size pageSize = page.getClientSize();
    //Draw rectangle
    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(0, 0, pageSize.width, pageSize.height),
        pen: PdfPen(PdfColor(142, 170, 219, 255)));
    //Generate PDF grid.
    final PdfGrid grid = getGrid();
    //Draw the header section by creating text element
    final PdfLayoutResult? result = await drawHeader(page, pageSize, grid);
    //Draw grid
    drawGrid(page, grid, result!);
    // drawFooter(page, pageSize);
    //Save and launch the document
    List<int> bytes = await document.save();

    // Dispose the document
    document.dispose();

    //Save the file and launch/download
    SaveFile.saveAndLaunchFile(bytes,
        'Reports_Adminapp_${DateTime.now().microsecondsSinceEpoch.toString()}.pdf');
  }

  Future<PdfLayoutResult?> drawHeader(
      PdfPage page, Size pageSize, PdfGrid grid) async {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));
    //Draw string
    page.graphics.drawString(
        'Route Report', PdfStandardFont(PdfFontFamily.helvetica, 30),
        brush: PdfBrushes.white,
        bounds: Rect.fromLTWH(25, 0, pageSize.width - 115, 90),
        format: PdfStringFormat(lineAlignment: PdfVerticalAlignment.middle));

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(65, 104, 205)));
    // var url = "http://13.233.175.113/assets/images/logo-itac.png";
    // var response = await get(Uri.parse(url));
    // var data = response.bodyBytes;
    // page.graphics.drawImage(
    //     PdfBitmap(data), Rect.fromLTWH(350, 0, pageSize.width - 200, 100));
    // page.graphics.drawString(
    //     '\$' + "200000", PdfStandardFont(PdfFontFamily.helvetica, 18),
    //     bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 100),
    //     brush: PdfBrushes.white,
    //     format: PdfStringFormat(
    //         alignment: PdfTextAlignment.center,
    //         lineAlignment: PdfVerticalAlignment.middle));

    final PdfFont contentFont = PdfStandardFont(PdfFontFamily.helvetica, 9);
    //Draw string
    // page.graphics.drawString('Amount', contentFont,
    //     brush: PdfBrushes.white,
    //     bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 33),
    //     format: PdfStringFormat(
    //         alignment: PdfTextAlignment.center,
    //         lineAlignment: PdfVerticalAlignment.bottom));
    //Create data format and convert it to text.
    final DateFormat format = DateFormat.yMMMMd('en_US');
    Random random = Random();
    int randomNumber = random.nextInt(100);
    final String invoiceNumber =
        'Report Number: $randomNumber${DateTime.now().microsecondsSinceEpoch.toString()}\r\n\r\nDate: ${format.format(DateTime.now())}';
    final Size contentSize = contentFont.measureString(invoiceNumber);
    // const String address =
    // 'Bill To: \r\n\r\nAbraham Swearegin, \r\n\r\nUnited States, California, San Mateo, \r\n\r\n9920 BridgePointe Parkway, \r\n\r\n9365550136';
    return PdfTextElement(text: invoiceNumber, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 30), 120,
            contentSize.width + 30, pageSize.height - 120));

    // return PdfTextElement(text: address, font: contentFont).draw(
    //     page: page,
    //     bounds: Rect.fromLTWH(30, 120,
    //         pageSize.width - (contentSize.width + 30), pageSize.height - 120));
  }

  PdfGrid getGrid() {
    //Create a PDF grid
    final PdfGrid grid = PdfGrid();
    //Secify the columns count to the grid.
    grid.columns.add(count: 10);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.cells[0].value = 'Sl No';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Date Time';
    headerRow.cells[2].value = 'Vehicle Name';
    headerRow.cells[3].value = 'Distance(KM)';
    headerRow.cells[4].value = 'Cumulative Distance(KM)';
    headerRow.cells[5].value = 'Location';

    print(showTable.length);
    for (int i = 0; i < showTable.length; i++) {
      addProducts(
          "${i + 1}",
          showTable[i]['routeInstanceTime'].toString(),
          showTable[i]['deviceName'].toString(),
          showTable[i]['distance'].toString(),
          showTable[i]['cumulativeDistance'].toString(),
          showTable[i]['fromLocation'].toString(),
          grid);
    }
    // addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 3, 149.97, grid);
    // addProducts('So-B909-M', 'Mountain Bike Socks,M', 9.5, 2, 19, grid);
    // addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 4, 199.96, grid);
    // addProducts('FK-5136', 'ML Fork', 175.49, 6, 1052.94, grid);
    // addProducts('HL-U509', 'Sports-100 Helmet,Black', 34.99, 1, 34.99, grid);
    //Apply the grid built-in style.
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    grid.columns[0].width = 40;
    grid.columns[1].width = 100;
    grid.columns[2].width = 100;
    grid.columns[3].width = 70;
    grid.columns[4].width = 70;
    grid.columns[5].width = 100;
    // grid.columns[2].width = 200;
    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        }
        cell.style.cellPadding =
            PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
      }
    }
    return grid;
  }

  void addProducts(
      String slNo,
      String InstanceDate,
      String vehicleName,
      String distance,
      String cumulativeDistance,
      var location,
      PdfGrid grid) async {
    // final data = await rootBundle.load("images/Fonts/arial.ttf");
    // final  dataint = data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);
    // final  PdfFont  font  =  PdfTrueTypeFont(dataint,12);
    PdfGridRow row = grid.rows.add();
    // grid.style.font = font;
    row.cells[0].value = slNo;
    row.cells[1].value = InstanceDate;
    row.cells[2].value = vehicleName;
    row.cells[3].value = distance;
    row.cells[4].value = cumulativeDistance;
    row.cells[5].value = location;
  }

  void drawGrid(PdfPage page, PdfGrid grid, PdfLayoutResult result) {
    Rect? totalPriceCellBounds;
    Rect? quantityCellBounds;
    //Invoke the beginCellLayout event.
    grid.beginCellLayout = (Object sender, PdfGridBeginCellLayoutArgs args) {
      final PdfGrid grid = sender as PdfGrid;
      if (args.cellIndex == grid.columns.count - 1) {
        totalPriceCellBounds = args.bounds;
      } else if (args.cellIndex == grid.columns.count - 2) {
        quantityCellBounds = args.bounds;
      }
    };
    //Draw the PDF grid and get the result.
    result = grid.draw(
        page: page, bounds: Rect.fromLTWH(0, result.bounds.bottom + 40, 0, 0))!;

    //Draw grand total.
    // page.graphics.drawString('Grand Total',
    //     PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
    //     bounds: Rect.fromLTWH(
    //         quantityCellBounds!.left,
    //         result.bounds.bottom + 10,
    //         quantityCellBounds!.width,
    //         quantityCellBounds!.height));
    // page.graphics.drawString("20000",
    //     PdfStandardFont(PdfFontFamily.helvetica, 9, style: PdfFontStyle.bold),
    //     bounds: Rect.fromLTWH(
    //         totalPriceCellBounds!.left,
    //         result.bounds.bottom + 10,
    //         totalPriceCellBounds!.width,
    //         totalPriceCellBounds!.height));
  }

  // List<Widget> Addvehicles() {
  //   print(
  //       "Total length of total vehicle is that: ${widget.vehicleList.length}");
  //   for (var i = 0; i < widget.vehicleDetailslist.length; i++) {
  //     _showvehicleDetailslist.add(VehicleDetails(
  //       VehicleName: widget.vehicleDetailslist[i]['vehicleName'],
  //       Distance: widget.vehicleDetailslist[i]['model'],
  //       VehicleId: widget.vehicleDetailslist[i]['model'],
  //     ));
  //   }
  //
  //   setState(() {
  //     _filterclicked = true;
  //     _showvehicleDetailslist = _showvehicleDetailslist;
  //     downloadpdf = true;
  //   });
  //
  //   List<Widget> Demo = [];
  //   return Demo;
  // }
}

class VehicleDetailsRep {
  String vehicleName;
  int vehicleId;

  VehicleDetailsRep({
    required this.vehicleName,
    required this.vehicleId,
  });
}

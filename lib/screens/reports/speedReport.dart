import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/custom_widget.dart';
import 'package:admin_app/screens/reportsscreen.dart';
import 'package:data_table_2/data_table_2.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import "package:flutter/material.dart";
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:multi_select_flutter/chip_field/multi_select_chip_field.dart';
import 'package:multi_select_flutter/multi_select_flutter.dart';
import 'package:pdf/widgets.dart' as PdfWidget;
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_pdf/pdf.dart';

import '../addvehiclescreen.dart';
import '../themes.dart';

// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
bool isSpeedSubmitbtnclicked = false;

class SpeedReportsScreen extends StatefulWidget {
  List<dynamic> vehicleList = [];
  List<dynamic> vehicleDetailslist = [];
  SpeedReportsScreen(
      {super.key, required this.vehicleList, required this.vehicleDetailslist});

  @override
  State<SpeedReportsScreen> createState() => _SpeedReportsScreenState();
}

class _SpeedReportsScreenState extends State<SpeedReportsScreen> {
  bool downloadpdf = false;
  List<VehicleDetails> _showvehicleDetailslist = [];
  var _filterclicked;
  bool nodata = false;
  final _startDateController = TextEditingController();
  final _startTimeController = TextEditingController();
  final _endDateController = TextEditingController();
  final _endTimeController = TextEditingController();
  var startTime;
  var endTime;
  DateTime? startDateNew;
  DateTime? endDateNew;
  List<dynamic> selectedVehicles = [];
  var reportInterval = 30;
  var reportIntervalController= TextEditingController();
  bool selectAll = false;
  var submitClicked = false;
  var showTable2 = [];
  List<VehicleDrop> SpeedVehicledetails = [];
  List<dynamic> showTable = [];
  bool isTime1GreaterThanTime2= false;
  Future<List<dynamic>> getDistanceReport(
      var fromDate, fromTime, toDate, toTime, vehiclesList) async {
    print('input data are:');
    print(fromDate);
    print(fromTime);
    print(toDate);
    print(toTime);
    print(vehiclesList);
    if(fromDate == toDate) {
      DateTime dateTime1 = DateFormat("hh:mm a").parse(fromTime);
      DateTime dateTime2 = DateFormat("hh:mm a").parse(toTime);

      isTime1GreaterThanTime2 = dateTime1.isAfter(dateTime2);
      print("time is gfreater than: $isTime1GreaterThanTime2");
    }
    String timeWithoutAMPM = fromTime.substring(0, 5);
    print("timeWithoutAMPM 111: $timeWithoutAMPM");
    String timeWithoutAMPM2 = toTime.substring(0, 5);
    print("timeWithoutAMPM 222: $timeWithoutAMPM2");

    print(reportInterval);
    showTable = [];
    print(fromTime);
    if(fromTime.toString().contains("PM")){
      startTime= startTime.toString().replaceAll("00:", "12:");
    }
    print("to timeissss:$toTime");

    // if(toTime.toString().contains("PM")){
    //   endTime= endTime.toString().replaceAll("00", "12");
    // }
    if(toTime.toString().contains("PM") && toTime.toString().contains("12:")){
      endTime= endTime.toString().replaceAll("00:", "12:");
    }
    print("the value passing final is:${startTime}");
    print("the value passing final endTime is:${endTime}");
    print("time issssshgdgdg ${fromDate}T${fromTime}");
    // print("all device ids from getDeviceCurrentLocation: ${allids}");
    var data = {
      "fromTime":
      "${fromDate}T${startTime}:00.048Z",
      "lstVehicles": vehiclesList,
      "speedLimit": reportInterval,
      "toTime":
      // "2023-07-12T08:32:49.048Z"
      "${toDate}T${endTime}:00.048Z"
    };
    print(data);
    const url2 = "${baseUrl}api/speed-report";
    if(isTime1GreaterThanTime2 != true) {
      try {
        print('Distance report in try');
        var dio = Dio();
        final response = await dio.post(url2, data: data);
        showTable2 = response.data;
        print("result from api ");
        print(response.data);
        print(showTable2.length);
        print("my response is that:$response");
        int a = response.data.length;
        if (a == 0) {
          setState(() {
            nodata = true;
            submitClicked = false;
          });
        } else {
          try {
            for (var i = 0; i < a; i++) {
              var fromlat = showTable2[i]['fromLattitude'];
              var fromlong = showTable2[i]['fromLongitude'];
              final url =
                  "http://13.234.100.167/nominatim/reverse?format=json&lat=$fromlat&lon=$fromlong&zoom=18&addressdetails=1";
              final location = await dio.get(url);
              var toLattitude = showTable2[i]['toLattitude'];
              var toLongitude = showTable2[i]['toLongitude'];
              final url2 =
                  "http://13.234.100.167/nominatim/reverse?format=json&lat=$toLattitude&lon=$toLongitude&zoom=18&addressdetails=1";
              final location2 = await dio.get(url2);
              List<Map<String, dynamic>> locationdata = [location.data];
              print("my location is:${locationdata}");
              print(location.data['display_name']);
              // DateTime _selectedTime;
              //
              // _selectedTime = showTable2[i]['startDate'].replacing(hour: showTable2[i]['startDate'].hourOfPeriod);
              // print("selected time to convert is:$_selectedTime");
              // var dateFormat1 = DateFormat("hh:mm a");
              // dateFormat1.format(showTable2[i]['startTime']);
              // print('Formated date is$dateFormat1');
              final inputFormat = DateFormat("HH:mm");
              final outputFormat = DateFormat("hh:mm a");
              final inputTimeDate = inputFormat.parse(
                  showTable2[i]['startTime']);
              var convertedTime = outputFormat.format(inputTimeDate);
              print("selected time to convert is2:$convertedTime");

              showTable.add({
                "vehicleName": showTable2[i]['vehicleName'],
                "startDate": showTable2[i]['startDate'],
                "startTime": convertedTime,
                "duration": showTable2[i]['duration'],
                "distance": showTable2[i]['distance'],
                "avgSpeed": showTable2[i]['avgSpeed'],
                "fromLocation": location.data['display_name'],
                "toLocation": location2.data['display_name'],
              });
              print("my table is:$showTable");
            }
          } catch (e) {
            print(e);
            print('error occured 2nd');
          }

          setState(() {
            // isSpeedSubmitbtnclicked = true;
            nodata = false;
            showTable = showTable;
            submitClicked = false;
            _filterclicked = true;
            _showvehicleDetailslist = _showvehicleDetailslist;
            downloadpdf = true;
          });
        }
      } catch (e) {
        print(e);
        setState(() {
          submitClicked = false;
        });
        print("Some error occured");
      }
    }
    else {
      setState(() {
        // nodata = true;
        submitClicked = false;
      });
    }


    // print("online count: ${onlineVehicles}");
    List<dynamic> vehLocationList = [];
    return vehLocationList;
  }

  List<Widget> AddVehicleNames() {
    SpeedVehicledetails.clear();
    for (var i = 0; i < widget.vehicleList.length; i++) {
      // print(VehicleList[i]);
      SpeedVehicledetails.add(
        VehicleDrop(widget.vehicleList[i]["id"], widget.vehicleList[i]["name"]),
      );
    }
    // print(totVehicle);
    setState(() {});

    List<Widget> Demo = [];
    return Demo;
  }

  String formatTime(TimeOfDay time) {
    final now = DateTime.now();
    final dateTime = DateTime(now.year, now.month, now.day, time.hour, time.minute);
    final formatter = DateFormat('hh:mm a');
    return formatter.format(dateTime);
  }

  @override
  void initState() {
    ()  {
      AddVehicleNames();
      reportIntervalController= TextEditingController(text: reportInterval.toString() );
      setState(() {
        isSpeedSubmitbtnclicked = false;
      });
    }();
    super.initState();
  }

  @override
  void dispose() {
    isSpeedSubmitbtnclicked = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("widget is that: ${widget.vehicleList}");
    final _items = widget.vehicleList
        .map((Vehiclesnames) => MultiSelectItem(
            Vehiclesnames['id'], Vehiclesnames['name'].toString()))
        .toList();
    return ListView(children: [
      Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            margin:
                const EdgeInsets.only(left: 8, right: 8, bottom: 0.0, top: 0.0),
            padding: const EdgeInsets.only(
                left: 10, right: 10, bottom: 30, top: 0.0),
            decoration: BoxDecoration(
              color: Colors.white54,
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
                  SizedBox(
                    height: MediaQuery.of(context).size.height * .0,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        color: Colors.white54,
                        width: 150,
                        child: TextFormField(
                          onTap: isSpeedSubmitbtnclicked == true
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
                              children: const [
                                Text('*', style: TextStyle(color: Colors.red)),
                                Padding(
                                  padding: EdgeInsets.all(3.0),
                                ),
                                Text(
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
                          onTap: isSpeedSubmitbtnclicked == true
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
                                    builder: (BuildContext context, Widget? child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
                                        child: child!,
                                      );
                                    },
                                  );
                                  print(time.toString());
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
                                    var finaltime222 = dateFormat2.format(tempDate);
                                    print("the start time222 is:$finaltime222");
                                    String formattedTime = formatTime(time);
                                    print(formattedTime);
                                    List<String> timeParts = finaltime.split(':');
                                    int hours = int.parse(timeParts[0]);
                                    int minutes = int.parse(timeParts[1]);

                                    print('Hours: $hours');
                                    print('Minutes: $minutes');
                                    startDateNew= DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      hours,
                                      minutes,
                                    );
                                    print('new time issss Minutes: $startDateNew');
                                    print(time.format(context));
                                    setState(() {
                                      startTime= finaltime;
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
                          onTap: isSpeedSubmitbtnclicked == true
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
                          onTap: isSpeedSubmitbtnclicked == true
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
                                    builder: (BuildContext context, Widget? child) {
                                      return MediaQuery(
                                        data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
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
                                    var finaltime222 = dateFormat2.format(tempDate);
                                    print("the start end time isss is:$finaltime222");
                                    String formattedTime = formatTime(time);
                                    print(formattedTime);
                                    List<String> timeParts = finaltime.split(':');

                                    int hours = int.parse(timeParts[0]);
                                    int minutes = int.parse(timeParts[1]);

                                    print('Hours: $hours');
                                    print('Minutes: $minutes');
                                    endDateNew= DateTime(
                                      DateTime.now().year,
                                      DateTime.now().month,
                                      DateTime.now().day,
                                      hours,
                                      minutes,
                                    );
                                    print('new time issss Minutes: $startDateNew');
                                    print(time.format(context));
                                    setState(() {
                                      endTime= finaltime;
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
                        const Text("Average Speed Limit"),
                        Container(
                          margin: EdgeInsets.fromLTRB(5, 0, 5, 0),
                          width: 70,
                          child: TextFormField(
                            keyboardType: TextInputType.number,
                            enabled:
                                isSpeedSubmitbtnclicked == true ? false : true,
                            // readOnly: true,
                            decoration: InputDecoration(
                              suffixStyle: const TextStyle(
                                color: Colors.red,
                              ),
                              hintText: '50',
                              hintStyle: const TextStyle(color: Colors.black),
                              border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(7.0),
                              ),
                            ),
                            controller: reportIntervalController,
                            onFieldSubmitted: (String value){
                              print("fierld is submitted $value");
                              setState(() {
                                reportInterval= int.parse(value);
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
                              onTap: isSpeedSubmitbtnclicked == true
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
                                        reportIntervalController.text= reportInterval.toString();
                                      });
                                    },
                            ),
                            InkWell(
                              child: const Icon(
                                Icons.arrow_drop_down,
                                size: 50,
                              ),
                              onTap: isSpeedSubmitbtnclicked == true
                                  ? () {
                                      const snackBar = SnackBar(
                                        content: Text('Cannot pick date after submitting the data'),
                                      );
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(snackBar);
                                    }
                                  : () {
                                      setState(() {
                                        print("print decrement value$reportInterval");
                                        if(reportInterval ==0){
                                        }
                                        else {
                                          reportInterval--;
                                          reportIntervalController.text= reportInterval.toString();
                                        }
                                      });
                                    },
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Checkbox(
                          value: selectAll,
                          onChanged: (bool? val) {
                            setState(() {
                              selectAll = val!;
                            });
                          }),
                      Text("Select All")
                      // ElevatedButton(onPressed: (){
                      //   setState(() {
                      //     selectAll = true;
                      //   });
                      // }, child: Text("Select All"))
                    ],
                  ),
                  Container(
                    height: 25.h,
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                    child: SingleChildScrollView(
                      child: DropdownSearch<VehicleDrop>.multiSelection(
                        enabled: isSpeedSubmitbtnclicked == true ? false : true,
                        dropdownDecoratorProps: DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                                label: Row(
                                  children: [
                                    const Text('*',
                                        style: TextStyle(color: Colors.red)),
                                    const Padding(
                                      padding: EdgeInsets.all(3.0),
                                    ),
                                    const Text(
                                      "Select vehicles",
                                      style: TextStyle(color: Colors.black),
                                    )
                                  ],
                                ),
                                enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(7)),
                                hintText: 'Select vehicles')),
                        items: SpeedVehicledetails,
                        selectedItems:
                            selectAll == true ? SpeedVehicledetails : [],
                        popupProps: const PopupPropsMultiSelection.menu(
                          searchFieldProps: TextFieldProps(
                              decoration:
                                  InputDecoration(hintText: "Search Vehicles")),
                          showSearchBox: true,
                        ),
                        onChanged: (List<VehicleDrop> data) {
                          setState(() {
                            selectedVehicles = data.map((e) => e.id).toList();
                          });
                          print(selectedVehicles);
                        },
                        // selectedItems: selectedVehicles,
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
                          margin: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                          child: CustomButton(
                              buttontext: "Submit",
                              onpress: () async {
                                if(_startDateController.text.isEmpty || _endDateController.text.isEmpty
                                    || _startTimeController.text.isEmpty || _endTimeController.text.isEmpty

                                // || (selectAll == false || selectedVehicles.isEmpty)

                                ){
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        Future.delayed(Duration(seconds: 4), () {
                                          Navigator.of(context, rootNavigator: true)
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
                                }
                                bool? isTime1BeforeTime2 = endDateNew?.isBefore(startDateNew!);
                                print("ned time is:$isTime1BeforeTime2");
                                if (DateTime.parse(_startDateController.text)
                                        .compareTo(DateTime.parse(
                                            _endDateController.text)) >
                                    0) {
                                  print("End date is before Startdate");
                                  final snackBar = const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(bottom: 230.0),
                                    content: Text(
                                        'End date cannot be before the start date'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
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
                                  if (selectAll == true) {
                                    selectedVehicles =
                                        SpeedVehicledetails.map((e) => e.id)
                                            .toList();
                                  }
                                  print("start tume contyrooler is:n ${_startTimeController.text}");
                                  print("start tume _endTimeController is:n ${_endTimeController.text}");
                                  print("start tume contyrooler is:n ${startTime}");
                                  await getDistanceReport(
                                      _startDateController.text,
                                      // startTime.toString(),
                                      _startTimeController.text,
                                      _endDateController.text,
                                      // endTime.toString(),
                                      _endTimeController.text,
                                      selectedVehicles);
                                  if (showTable.length != 0) {
                                    setState(() {
                                      submitClicked = false;
                                    });
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
                                                                  width: 1500,
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
                                                                        150,
                                                                    scrollController:
                                                                        ScrollController(),
                                                                    // minWidth: 1,
                                                                    columnSpacing:
                                                                        5,
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
                                                                              Text('Start Date')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Start Time')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Duration (hh:mm:ss)')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Distance(KM)')),
                                                                      DataColumn(
                                                                          label:
                                                                          Text('Average Speed (KM/H)')
                                                                      
                                                                      ),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('From Location')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('To Location')),
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
                                                                              Text(showTable[index]['vehicleName'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['startDate'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['startTime'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['duration'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['distance'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['avgSpeed'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['fromLocation'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['toLocation'].toString())),

                                                                          // DataCell(Text(usersFiltered[index].district)),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )),
                                                      ),
                                                    ),
                                                  ]),
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
                                  } else if ( nodata == true) {
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
                                            title: Text(isTime1GreaterThanTime2 == true ?
                                            "End time cannot be before the start time":
                                              "No Records Found",
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
                                            title: Text(isTime1GreaterThanTime2 == true ?
                                            "End time cannot be before the start time" :
                                                "Some error occured",
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
        'Speed Report', PdfStandardFont(PdfFontFamily.helvetica, 30),
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

    final PdfFont contentFont = PdfStandardFont(
        PdfFontFamily.helvetica, 9);
//Create a PDF true type font object.
//     final data = await rootBundle.load("Fonts/arial.ttf");
//     final  dataint = data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);
//     final  PdfFont  font  =  PdfTrueTypeFont(dataint,12);
    final DateFormat format = DateFormat.yMMMMd('en_US');
    Random random = Random();
    int randomNumber = random.nextInt(100);
    final String invoiceNumber =
        'Report Number: $randomNumber${DateTime.now().microsecondsSinceEpoch.toString()}\r\n\r\nDate: ${format.format(DateTime.now())}';
    final Size contentSize = contentFont.measureString(invoiceNumber);
    return PdfTextElement(text: invoiceNumber, font: contentFont).draw(
        page: page,
        bounds: Rect.fromLTWH(pageSize.width - (contentSize.width + 30), 120,
            contentSize.width + 30, pageSize.height - 120));
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
    headerRow.cells[1].value = 'Vehicle Name';
    headerRow.cells[2].value = 'Start Date';
    headerRow.cells[3].value = 'Start Time';
    headerRow.cells[4].value = 'Duration (hh:mm:ss)';
    headerRow.cells[5].value = 'Distance (KM)';
    headerRow.cells[6].value = 'Average Speed (KM/H)';
    headerRow.cells[7].value = 'From Location';
    headerRow.cells[8].value = 'To Location';

    print(showTable.length);
    for (int i = 0; i < showTable.length; i++) {
      String text = showTable[i]['fromLocation'].toString();
      if (text.contains("ā")) {
        text = text.replaceAll("ā", "a");
      }
      String text2 = showTable[i]['toLocation'].toString();
      if (text.contains("ā")) {
        text = text.replaceAll("ā", "a");
      }

      addProducts(
          "${i + 1}",
          showTable[i]['vehicleName'].toString(),
          showTable[i]['startDate'].toString(),
          showTable[i]['startTime'].toString(),
          showTable[i]['duration'].toString(),
          showTable[i]['distance'].toString(),
          showTable[i]['avgSpeed'].toString(),
          text,
          // showTable[i]['fromLocation'].toString(),
          // showTable[i]['toLocation'].toString(),
          text2,
          grid);
    }
    // addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 3, 149.97, grid);
    // addProducts('So-B909-M', 'Mountain Bike Socks,M', 9.5, 2, 19, grid);
    // addProducts('LJ-0192', 'Long-Sleeve Logo Jersey,M', 49.99, 4, 199.96, grid);
    // addProducts('FK-5136', 'ML Fork', 175.49, 6, 1052.94, grid);
    // addProducts('HL-U509', 'Sports-100 Helmet,Black', 34.99, 1, 34.99, grid);
    //Apply the grid built-in style.
    grid.applyBuiltInStyle(PdfGridBuiltInStyle.listTable4Accent5);
    grid.columns[0].width = 30;
    grid.columns[1].width = 85;
    // grid.columns[2].width = 100;
    // grid.columns[3].width = 70;
    // grid.columns[4].width = 70;
    grid.columns[6].width = 50;
    grid.columns[7].width = 70;
    grid.columns[8].width = 70;

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
      String vehicleName,
      String startDate,
      String startTime,
      String duration,
      String distance,
      String avgSpeed,
      String fromLocation,
      String toLocation,
      PdfGrid grid) async {
    // final data = await rootBundle.load("Fonts/arial.ttf");
    // final  dataint = data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);
    // final  PdfFont  font  =  PdfTrueTypeFont(dataint,12);
    PdfGridRow row = grid.rows.add();
    // grid.style.font = font;
    row.cells[0].value = slNo;
    row.cells[1].value = vehicleName;
    row.cells[2].value = startDate;
    row.cells[3].value = startTime;
    row.cells[4].value = duration;
    row.cells[5].value = distance;
    row.cells[6].value = avgSpeed;
    row.cells[7].value = fromLocation;
    row.cells[8].value = toLocation;
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

  List<Widget> Addvehicles() {
    print(
        "Total length of total vehicle is that: ${widget.vehicleList.length}");
    for (var i = 0; i < widget.vehicleDetailslist.length; i++) {
      _showvehicleDetailslist.add(VehicleDetails(
        VehicleName: widget.vehicleDetailslist[i]['vehicleName'],
        Distance: widget.vehicleDetailslist[i]['model'],
        VehicleId: widget.vehicleDetailslist[i]['model'],
      ));
    }

    setState(() {
      _filterclicked = true;
      _showvehicleDetailslist = _showvehicleDetailslist;
      downloadpdf = true;
    });

    List<Widget> Demo = [];
    return Demo;
  }
}

class VehicleDetails {
  var VehicleName;
  var Distance;
  var VehicleId;

  VehicleDetails({
    required this.Distance,
    required this.VehicleName,
    required this.VehicleId,
  });
}

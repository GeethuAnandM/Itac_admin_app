import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/tripScreens/roundTripPage.dart';
import 'package:admin_app/screens/tripScreens/tripsscreen.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

import 'dashboard_chart.dart';

List<Chart> _Lists = [];
DateTime now = DateTime.now();
String dateOnly = DateFormat('dd-MM-yyyy').format(now);

class stackedColumn extends StatefulWidget {
  List<Chart> dashtripList = [];
  var unplanned, planned, completed;
  stackedColumn(
      {required this.dashtripList,
      required this.unplanned,
      required this.completed,
      required this.planned});
  @override
  _stackedColumnState createState() => _stackedColumnState();
}

class _stackedColumnState extends State<stackedColumn> {
  var _unplanned = 0;
  var planned = 0;
  var completed = 0;
  var date = 0;
  var datas = [];
  bool loading = true;

  List<StackedData> stackedData = [];
  List<Map<dynamic, dynamic>> tripData = [];
  List<Map<dynamic, dynamic>> tripListData = [];

  late TooltipBehavior _tooltip;
  Future<String?> tripDashboard() async {
    // print("dashboard ${widget.dashtripList}");
    // final prefs = await SharedPreferences.getInstance();
    // var userId = prefs.getString("user_id");
    // var Id = int.parse(userId!);
    // var dio = Dio();
    // try {
    //   final response =
    //       await dio.get('$productionBaseUrl:11014/dashboard/trip?userId=$Id');
    //   if (response.statusCode == 200) {
    //     datas = response.data;
    //     for (var i = 0; i < datas.length; i++) {
    //       planned = datas[i]['planned'] + planned;
    //       _unplanned = datas[i]['unplanned'] != null
    //           ? datas[i]['unplanned'] + _unplanned
    //           : 0;
    //       completed = datas[i]['completed'] + completed;
    //     }
    //     print("datas${datas.length}");
    //     print("planned${planned}");
    //     print("completed${completed}");
    //     print("unplanned${_unplanned}");
    // for (var i = 0; i < widget.dashtripList.length; i++) {
    //   // print("jjjjjjjj");
    //   DateTime date = DateFormat("yyyy-MM-dd").parse(widget.dashtripList[i]['date']);
    //   var dateFormat1 = DateFormat("dd-MM-yyyy");
    //
    //   // print(datas[i]['date']);
    //   // print(dateFormat1.format(date));
    //   _Lists.add(
    //     Chart(
    //       Date: dateFormat1.format(date),
    //       Planned: widget.dashtripList[i]['planned'],
    //       Unplanned: widget.dashtripList[i]['unplanned'] ?? 0,
    //       Completed: widget.dashtripList[i]['completed'],
    //     ),
    //   );
    // }
    stackedData.clear();
    for (var i = 0; i < widget.dashtripList.length; i++) {
      stackedData.add(StackedData(
          widget.dashtripList[i].Date,
          int.parse(widget.dashtripList[i].Unplanned.toString()),
          int.parse(widget.dashtripList[i].Planned.toString()),
          int.parse(widget.dashtripList[i].Completed.toString())));
    }
    // print("${stackedData} stackeddata");

    // print("datestack${_Lists.first.Date}");
    setState(() {
      _Lists = widget.dashtripList;
      stackedData = stackedData;
    });
    // }
    // }catch (e) {
    //   print(e);
    //   final String? responseString = "Error";
    //   return responseString;
    // }
  }

  Future<List<dynamic>> getTripDatas() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var Id = int.parse(userId!);
    final url = "${baseUrl}trips/list-trips/$Id";
    var dio = Dio();
    final response = await dio.get(url);
    tripListData.clear();
    // print("res${response.data['list']}");
    for (var i = 0; i < response.data['list'].length; i++) {
      tripListData.add(response.data['list'][i]);
    }
    // print(" stack column triplistdata $tripListData");
    // print('triplistdata length:${tripListData.length}');
    // print(tripListData.runtimeType);
    return tripListData;
  }

  List<Map<String, dynamic>> ListTrip = [];
  List<Widget> Addtrip() {
    for (var i = 0; i < tripListData.length; i++) {
      // print(i);
      ListTrip.add(
        {
          "status": tripListData[i]['status'],
        },
      );
    }
    setState(() {
      ListTrip = ListTrip;
    });
    List<Widget> Demo = [];
    return Demo;
  }

  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    () async {
      await tripDashboard();
      // await getTripDatas();
      Addtrip();
      setState(() {
        loading = false;
        tripListData = tripListData;
        tripData = ListTrip;
        planned = planned;
        _unplanned = _unplanned;
        completed = completed;
        stackedData = stackedData;
      });
    }();
    super.initState();
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    // print("list data ${_Lists}");
    // print("stacked data ${_unplanned}");
    // print("loading${loading}");
    for (var i = 0; i < widget.dashtripList.length; i++) {
      if (dateOnly == widget.dashtripList[i].Date) {
        _unplanned = widget.dashtripList[i].Unplanned;
        planned = widget.dashtripList[i].Planned;
        completed = widget.dashtripList[i].Completed;
      }
    }
    return Scaffold(
        body: loading == true || _Lists.isEmpty
            ? const Center(child: SizedBox())
            : Center(
                child: Container(
                    child: SfCartesianChart(
                        backgroundColor: Colors.white,
                        enableAxisAnimation: true,
                        onLegendTapped: (LegendTapArgs args) async {
                          // print("args:${args.seriesIndex}");
                          // for (var i = 0; i < widget.dashtripList.length; i++) {
                          // if (dateOnly == widget.dashtripList[i].Date) {
                          if (args.seriesIndex == 0) {
                            // print("unplanned");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TripScreen(
                                        status: "Default",
                                      )),
                            );
                          } else if (args.seriesIndex == 1) {
                            // print("planned");
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TripScreen(
                                        status: "Planned",
                                        excluded: "Completed",
                                      )),
                            );
                          } else {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => TripScreen(
                                        status: "Completed",
                                      )),
                            );
                          }
                          // }
                          // }
                        },
                        primaryXAxis: CategoryAxis(
                          name: 'primaryXAxis',
                          labelRotation: 60,
                          title: AxisTitle(
                              text: 'Date'.toString(),
                              textStyle: TextStyle(color: Colors.black)),
                        ),
                        primaryYAxis: NumericAxis(
                          title: AxisTitle(
                              text: 'Trips Count'.toString(),
                              textStyle: TextStyle(color: Colors.black)),
                          minimum: 0,
                          // interval: 700 < 200 ? 100 : 2000,
                          majorGridLines: MajorGridLines(width: 0),
                          //Hide the axis line of x-axis
                          axisLine: AxisLine(width: 0),
                        ),
                        legend: Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            textStyle: TextStyle(
                                color: blackColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            overflowMode: LegendItemOverflowMode.wrap),
                        series: <CartesianSeries>[
                    ColumnSeries<StackedData, String>(
                        name: 'Unplanned ${_unplanned}',
                        color: Color(0xFF066A86),
                        width: 0.5,
                        dataSource: stackedData,
                        xValueMapper: (StackedData data, _) => data.x,
                        yValueMapper: (StackedData data, _) => data.y1),
                    ColumnSeries<StackedData, String>(
                      name: ' Planned ${planned}',
                      color: Color(0xFF46BEE2),
                      width: 0.5,
                      dataSource: stackedData,
                      xValueMapper: (StackedData data, _) => data.x,
                      yValueMapper: (StackedData data, _) => data.y2,
                    ),
                    ColumnSeries<StackedData, String>(
                        name: 'Completed ${completed}',
                        color: Color(0xFF4179EE),
                        width: 0.5,
                        dataSource: stackedData,
                        xValueMapper: (StackedData data, _) => data.x,
                        yValueMapper: (StackedData data, _) => data.y3),
                  ]))));
  }
}

class StackedData {
  StackedData(this.x, this.y1, this.y2, this.y3);
  final String x;
  final int? y1;
  final int? y2;
  final int? y3;
}

// class Chart {
//   Chart(
//       {required this.Date,
//       required this.Planned,
//       required this.Unplanned,
//       required this.Completed});
//
//   var Date;
//   var Planned;
//   var Unplanned;
//   var Completed;
// }

import 'package:admin_app/api/api.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:dio/dio.dart';
import 'themes.dart';

int events = 0;
List<ChartData> chartData = [];

class multibar extends StatefulWidget {
  @override
  _multibarState createState() => _multibarState();
}

class _multibarState extends State<multibar> {
  late TooltipBehavior _tooltip;

  List<Bar> Lists = [];
  var totalEvents = [];
  int high = 0;
  int critical = 0;
  int medium = 0;
  int low = 0;
  Future<Object?> getTotalEvents() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var Id = int.parse(userId!);
    // print("user is strored is $userId");
    var data = {"userId": userId};
    // print(userId.runtimeType);
    try {
      final response =
          await Dio().get("${baseUrl}dashboard/event?userId=${Id}");
      // print(response.data);
      if (response.statusCode == 200) {
        totalEvents = response.data;
        // print("response is 200");
        for (var i = 0; i < totalEvents.length; i++) {
          // print("total");
          if (totalEvents[i]['priority'] == "HIGH") {
            high++;
          } else if (totalEvents[i]['priority'] == "CRITICAL") {
            critical++;
          } else if (totalEvents[i]['priority'] == "MEDIUM") {
            medium++;
          } else if (totalEvents[i]['priority'] == "LOW") {
            low++;
          }
        }
        // print(high);
        // print(critical);
        // print(medium);
        // print(low);
        for (var i = 0; i < totalEvents.length; i++) {
          DateTime date =
              DateFormat("yyyy-MM-dd").parse(totalEvents[i]['eventTime']);
          var dateFormat1 = DateFormat("dd-MM-yyyy");
          Lists.add(Bar(
            Date: dateFormat1.format(date),
            Critical: critical,
            High: high,
            Medium: medium,
            Low: low,
          ));
        }
        setState(() {
          Lists = Lists;
        });
      }
    } catch (e) {
      // print("on multibar graph" + e.toString());
      final String? responseString = "Error";
      return responseString;
    }
  }

  bool loading = false;
  @override
  void initState() {
    _tooltip = TooltipBehavior(enable: true);
    () async {
      await getTotalEvents();
      // print("events data:$Lists");
      setState(() {
        loading = false;
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
    // print(high);
    // print(critical);
    // print(medium);
    // print(low);
    chartData.clear();
    for (var i = 0; i < Lists.length; i++) {
      chartData.add(ChartData(
          Lists[i].Date,
          Lists[i].Critical.toDouble(),
          Lists[i].High.toDouble(),
          Lists[i].Medium.toDouble(),
          Lists[i].Low.toDouble()));
    }
    return Scaffold(
        body: Center(
            child: loading == true || Lists.isEmpty
                ? const Center(child: SizedBox())
                : Center(
                    child: Container(
                    child: SfCartesianChart(
                        onLegendTapped: (LegendTapArgs args) async {
                          // print("args:${args.seriesIndex}");
                          if (args.seriesIndex == 0) {
                            // print("critical");
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => ScreenEvents(
                            //       )),
                            // );
                          } else if (args.seriesIndex == 1) {
                            // print("High");
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => ScreenEvents(
                            //       )),
                            // );
                          } else if (args.seriesIndex == 2) {
                            // print("medium");
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => ScreenEvents(
                            //       )),
                            // );
                          } else {
                            // print("low");
                            // Navigator.push(
                            //   context,
                            //   MaterialPageRoute(
                            //       builder: (context) => ScreenEvents(
                            //       )),
                            // );
                          }
                        },
                        primaryXAxis: CategoryAxis(
                          labelRotation: 60,
                          title: AxisTitle(
                              text: 'Date'.toString(),
                              textStyle: TextStyle(color: Colors.black)),
                        ),
                        primaryYAxis: CategoryAxis(
                          labelPlacement: LabelPlacement.onTicks,
                          minimum: 1,
                          maximum: 25,
                          title: AxisTitle(
                              text: 'Events'.toString(),
                              textStyle: TextStyle(color: Colors.black)),
                        ),
                        palette: <Color>[
                          Color(0xFFB70202),
                          Color(0xFFF97515),
                          Color(0xFF31A88B),
                          greenColor
                        ],
                        // primaryXAxis: CategoryAxis(),
                        legend: Legend(
                            isVisible: true,
                            position: LegendPosition.bottom,
                            textStyle: TextStyle(
                                color: blackColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold),
                            overflowMode: LegendItemOverflowMode.wrap),
                        series: <CartesianSeries>[
                          ColumnSeries<ChartData, String>(
                              legendItemText:
                                  "Critical ${Lists.first.Critical}",
                              width: 0.3,
                              dataSource: chartData,
                              xValueMapper: (ChartData data, _) => data.a,
                              yValueMapper: (ChartData data, _) => data.b),
                          ColumnSeries<ChartData, String>(
                            name: "High ${Lists.first.High}",
                            width: 0.3,
                            dataSource: chartData,
                            xValueMapper: (ChartData data, _) => data.a,
                            yValueMapper: (ChartData data, _) => data.c,
                          ),
                          ColumnSeries<ChartData, String>(
                              name: "Medium ${Lists.first.Medium}",
                              width: 0.3,
                              dataSource: chartData,
                              xValueMapper: (ChartData data, _) => data.a,
                              yValueMapper: (ChartData data, _) => data.d),
                          ColumnSeries<ChartData, String>(
                              legendItemText: "Low ${Lists.first.Low}",
                              width: 0.3,
                              dataSource: chartData,
                              xValueMapper: (ChartData data, _) => data.a,
                              yValueMapper: (ChartData data, _) => data.e),
                        ]),
                  ))));
  }
}

class ChartData {
  ChartData(this.a, this.b, this.c, this.d, this.e);
  final String a;
  final double? b;
  final double? c;
  final double? d;
  final double? e;
}

class Bar {
  Bar({
    required this.Date,
    required this.Critical,
    required this.High,
    required this.Medium,
    required this.Low,
  });
  var Date;
  int Critical;
  int High;
  int Medium;
  int Low;
}

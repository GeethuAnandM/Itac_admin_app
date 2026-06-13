import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/themes.dart';
import 'package:admin_app/screens/vehiclescreen.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '../utils/vehicle_list_normalizer.dart';

class Piechart extends StatefulWidget {
  var Lists = [];

  Piechart({required this.Lists});

  @override
  _PiechartState createState() => _PiechartState();
}

class _PiechartState extends State<Piechart> {
  bool loading = true;
  var totVehicleList = [];
  var vehLocationList = [];
  List<dynamic> allids = [];
  var dio = Dio();
  var offlineVehicle = 0;
  var vehicleLocationList = [];
  var onlinevehicle = 0;
  List<PieData> pieData = [];
  // List<Pie> Lists = [];
  Future<List<dynamic>> getVehiclesDetails() async {
    final prefs = await SharedPreferences.getInstance();
    var username = prefs.getString("user_id");
    final url = "${baseUrl}vehicle/vehicles/$username";
    //show error message try catch
    var dio = Dio();
    final response = await dio.get(url);
    totVehicleList = normalizeVehicleListResponse(response.data);
    allids = [];
    for (var i in totVehicleList) {
      if (i['deviceId'] != null && i['deviceId'] != "") {
        allids.add(i['deviceId']);
      }
    }
    // print('length of total vehicle list: ${totVehicleList.length}');
    // print("inside getvehiclesdetails: ${totVehicleList} ");
    return totVehicleList;
  }

  Future<List<dynamic>> getDeviceCurrentLocation() async {
    var data = {"deviceIds": allids};
    final url2 = "${baseUrl}location/getDeviceCurrentLocation";
    final response = await dio.post(url2, data: data);
    vehicleLocationList.clear();
    vehicleLocationList = await response.data;
    // print("in get getDeviceCurrentLocation");
    // print(
    //     "inside get devicelocation, devicelist: ${vehicleLocationList.length}");
    return vehicleLocationList;
  }

  Future<String?> getTotaVehicles() async {
    try {
      pieData = _buildPieData();
      // print("inside get devicelocation, devicelist: ${vehLocationList.length}");
      // print("pieDta:${pieData.first.y}");
    } catch (e) {
      // print(e);
      final String? responseString = "Error";
      return responseString;
    }
  }

  @override
  initState() {
    () async {
      // await getVehiclesDetails();
      // await getDeviceCurrentLocation();
      await getTotaVehicles();
      setState(() {
        loading = false;
        vehLocationList = vehLocationList;
      });
    }();

    super.initState();
  }

  @override
  void didUpdateWidget(covariant Piechart oldWidget) {
    super.didUpdateWidget(oldWidget);
    pieData = _buildPieData();
  }

  double _toDouble(dynamic value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  List<PieData> _buildPieData() {
    if (widget.Lists.isEmpty) {
      return [];
    }

    final onlineCount = _toDouble(widget.Lists.first.OnlineCount);
    final offlineCount = _toDouble(widget.Lists.first.OfflineCount);

    return [
      PieData(
        x: 'Online ${onlineCount.toInt()}',
        y: onlineCount,
        color: Color(0xFF46BEE2),
      ),
      PieData(
        x: 'Offline ${offlineCount.toInt()}',
        y: offlineCount,
        color: Color(0xFFADADAD),
      ),
    ];
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    // print(widget.Lists);
    // print("inside get devicelocation, devicelist: ${vehLocationList.length}");
    // print(pieData);
    return Scaffold(
      body: Center(
          child: loading == true || widget.Lists.isEmpty
              ? const Center(child: SizedBox())
              : pieData.every((item) => (item.y ?? 0) <= 0)
                  ? const Center(
                      child: Text(
                        "No vehicle status data",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    )
                  : Center(
                      child: Container(
                      child: SfCircularChart(
                          backgroundColor: Colors.white,
                          tooltipBehavior: TooltipBehavior(enable: false),
                          onLegendTapped: (LegendTapArgs args) async {
                            // print(args.pointIndex);
                            final vehicledetails = await getVehiclesDetails();
                            final devicedetails =
                                await getDeviceCurrentLocation();
                            if (args.pointIndex == 0) {
                              // print("device:${devicedetails}");
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VehicleScreen(
                                        status: "Online",
                                        deviceLocationList: devicedetails,
                                        vehicleList: vehicledetails,
                                        Lists: widget.Lists)),
                              );
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => VehicleScreen(
                                        status: "Offline",
                                        deviceLocationList: devicedetails,
                                        vehicleList: vehicledetails,
                                        Lists: widget.Lists)),
                              );
                            }
                          },
                          annotations: <CircularChartAnnotation>[
                            CircularChartAnnotation(
                                widget: Container(
                              child: Text(
                                "Total Vehicle:${widget.Lists.first.OnlineCount + widget.Lists.first.OfflineCount}",
                                style: const TextStyle(
                                  color: Colors.blueGrey,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ))
                          ],
                          legend: Legend(
                              textStyle: const TextStyle(
                                  color: blackColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.bold),
                              isVisible: true,
                              iconWidth: 20,
                              position: LegendPosition.bottom),
                          series: <CircularSeries>[
                            DoughnutSeries<PieData, String>(
                                explode: true,
                                explodeIndex: 1,
                                dataSource: pieData,
                                pointColorMapper: (PieData data, image) =>
                                    data.color,
                                xValueMapper: (PieData data, image) => data.x,
                                yValueMapper: (PieData data, image) => data.y),
                          ]),
                    ))),
    );
  }
}

class PieData {
  PieData({this.x, this.y, this.color});
  final String? x;
  final double? y;
  final Color? color;
// void Function()? onpress;
}

class Pie {
  Pie(
      {required this.MovingCount,
      required this.OnlineCount,
      required this.IdleCount,
      required this.StoppedCount,
      required this.OfflineCount});
  var MovingCount;
  var OnlineCount;
  var IdleCount;
  var StoppedCount;
  var OfflineCount;
}

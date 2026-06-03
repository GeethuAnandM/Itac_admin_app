import 'dart:io';
import 'package:admin_app/api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../languges/language_constants.dart';
import '../languges/language_model.dart';
import '../main.dart';
import '/screens/sidebar.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'dashboard_chart.dart';
import 'eventsscreen.dart';
import 'multibar.dart';
import 'piechart.dart';
import 'stackColumndiagram.dart';

// var totVehicleList = [];

List<Chart> _dashtripList = [];
var _unplanned = 0;
var _planned = 0;
var _completed = 0;
var total_trips = 0;

class Dashboard extends StatefulWidget {
  @override
  State<Dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  var errormessage;
  bool isError = false;
  List<Pie> _Lists = [];
  var _vehLocationList = [];
  var _datas = [];
  List<PieChart> Lists = [];
  List<Map<dynamic, dynamic>> _triplist = [];
  // bool isLoading = false;

  bool isHomePageSelected = true;
  bool loading = true;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  var _dateFormat1;

  getdatas() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var Id = int.parse(userId!);
    // print("id${Id}");
    var dio = Dio();
    // try {
    // final url = "$productionBaseUrl:11014/trips/list-trips/$Id";
    // var dio = Dio();
    // final response = await dio.get(url);
    // triplist.clear();
    // print("res${response.data['list']}");
    // for (var i = 0; i < response.data['list'].length; i++) {
    //   triplist.add(response.data['list'][i]);
    // }
    // print('length:${triplist.length}');
    // print(" data is here $triplist");
    // print(triplist.runtimeType);
    // return triplist;
    // } on SocketException {
    //   setState(() {
    //     isLoading = false;
    //     errormessage = 'No Internet connection';
    //     isError = true;
    //   });
    // } catch (e) {
    //   print("error from getdata: $e");
    // }

    try {
      // print("id is $Id");
      final response = await dio.get('${baseUrl}dashboard/trip?userId=$Id');
      // print("hello");
      if (response.statusCode == 200) {
        _datas = response.data;
        _planned = 0;
        _completed = 0;
        _unplanned = 0;
        for (var i = 0; i < _datas.length; i++) {
          _planned = _datas[i]['planned'] + _planned;
          _unplanned = _datas[i]['unplanned'] != null
              ? _datas[i]['unplanned'] + _unplanned
              : 0;
          _completed = _datas[i]['completed'] + _completed;
        }
        // print("datas trip:${_datas.length}");
        // print("planned trip${_planned}");
        // print("completed trip${_completed}");
        // print("unplnned ${_unplanned}");

        for (var i = 0; i < _datas.length; i++) {
          DateTime date = DateFormat("yyyy-MM-dd").parse(_datas[i]['date']);
          _dateFormat1 = DateFormat("dd-MM-yyyy");
          _dashtripList.add(Chart(
            Date: _dateFormat1.format(date),
            Planned: _datas[i]['planned'],
            Unplanned: _datas[i]['unplanned'] ?? 0,
            Completed: _datas[i]['completed'],
          ));
        }
        // print("Trip List length:${_dashtripList.length}");
        setState(() {
          _dashtripList = _dashtripList;
        });
      }
    } catch (e) {
      // print(e);
      final String? responseString = "Error";
      return responseString;
    }
  }

  Widget _icon(IconData icon) {
    return Container(
      padding: EdgeInsets.only(top: 10, left: 10),
      decoration: BoxDecoration(
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

  var totalEvents = [];
  getTotalEvents() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var Id = int.parse(userId!);
    // print("user is strored is $userId");
    var data = {"userId": userId};
    try {
      final response =
          await Dio().get("${baseUrl}dashboard/event?userId=${Id}");
      totalEvents = response.data;
      // print("totalevents:${totalEvents}");
      return totalEvents;
    } on SocketException {
      setState(() {
        // isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      // print("error from getdata: $e");
    }
  }

  getTotaVehicles() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var Id = int.parse(userId!);
    // print("Id is " + Id.toString());
    var dio = Dio();
    try {
      final response =
          await dio.get('${baseUrl}vehicle/vehicle-status?userId=${Id}');
      _vehLocationList.clear();
      Lists.clear();
      if (response.statusCode == 200) {
        final status = _vehicleStatusMap(response.data);
        final movingCount = _toInt(status['movingCount']);
        final stoppedCount = _toInt(status['stoppedCount']);
        final idleCount = _toInt(status['idleCount']);
        final offlineCount = _toInt(status['offlineCount']);

        _vehLocationList.add(status);
        Lists.add(PieChart(
            OnlineCount: movingCount + stoppedCount + idleCount,
            IdleCount: idleCount,
            MovingCount: movingCount,
            StoppedCount: stoppedCount,
            OfflineCount: offlineCount));
      }
      setState(() {
        // print("Vehicles:${_vehLocationList}");
        // print("Listss.${Lists}");
        Lists = Lists;
      });
      return _vehLocationList;
    } on SocketException {
      setState(() {
        // isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      // print("error from getdata: $e");
    }
  }

  Map<String, dynamic> _vehicleStatusMap(dynamic payload) {
    if (payload is List && payload.isNotEmpty && payload.first is Map) {
      return Map<String, dynamic>.from(payload.first as Map);
    }
    if (payload is Map) {
      return Map<String, dynamic>.from(payload);
    }
    return <String, dynamic>{};
  }

  int _toInt(dynamic value) {
    if (value is int) {
      return value;
    }
    if (value is num) {
      return value.toInt();
    }
    return int.tryParse(value?.toString() ?? '') ?? 0;
  }

  Stream getNumbers(Duration refreshTime) async* {
    while (true) {
      // print("inside getnumbers fn");
      await Future.delayed(refreshTime);
      yield await getTotaVehicles();
    }
  }

  @override
  void initState() {
    () async {
      await getTotaVehicles();
      // await getTotalEvents();
      if (_dashtripList.isEmpty) {
        // print("hello");
        DateTime now = DateTime.now();
        String _dateOnly = DateFormat('yyyy-MM-dd').format(now);
        await getdatas();
        for (var i = 0; i < _datas.length; i++) {
          if (_dateOnly == _datas[i]['date']) {
            total_trips = _datas[i]['unplanned'] +
                _datas[i]['planned'] +
                _datas[i]['completed'];
          }
        }
      }
      setState(() {
        _triplist = _triplist;
        _planned = _planned;
        _unplanned = _unplanned;
        _completed = _completed;
        _vehLocationList = _vehLocationList;
        Lists = Lists;
        _dashtripList = _dashtripList;
        loading = false;
        total_trips = total_trips;
        // isLoading = true;
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
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual,
        overlays: [SystemUiOverlay.bottom]);
    return SafeArea(
        child: Scaffold(
            key: _key,
            drawer: NavBar(),
            appBar: PreferredSize(
                preferredSize: Size.fromHeight(60.0),
                child: AppBar(
                  centerTitle: true,
                  leading: Padding(
                      padding: EdgeInsets.only(top: 15), child: _appBar()),
                  title: Padding(
                      padding: EdgeInsets.only(top: 20, left: 15),
                      child: Text(
                        translation(context).dashBoard,
                        overflow: TextOverflow.visible,
                      )),
                  elevation: 0,
                  actions: [
                    DropdownButton<Language>(
                      underline: const SizedBox(),
                      icon: Padding(
                        padding: EdgeInsets.only(top: 25, right: 20),
                        child: Icon(
                          Icons.language,
                          size: 27,
                          color: Colors.white,
                        ),
                      ),
                      onChanged: (Language? language) async {
                        if (language != null) {
                          // print(language.name);
                          Locale _locale =
                              await setLocale(language.languageCode);
                          AdminApp.setLocale(context, _locale);
                        }
                      },
                      items: Language.languageList()
                          .map<DropdownMenuItem<Language>>(
                            (e) => DropdownMenuItem<Language>(
                              value: e,
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceAround,
                                children: <Widget>[
                                  Text(
                                    e.flag,
                                    style: const TextStyle(fontSize: 30),
                                  ),
                                  Text(e.name)
                                ],
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  ],
                )),
            body: isError == true
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
                :
                // : loading == true
                // ? Center(child: CircularProgressIndicator()) :
                SingleChildScrollView(
                    child: Center(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                        Divider(
                          height: 1,
                          thickness: 10,
                          color: blackColor,
                        ),
                        Lists.isEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: 5.0, left: 5, right: 5),
                                child: Card(
                                    elevation: 10,
                                    color: Colors.white,
                                    child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                'Vehicle Status',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              Text(DateFormat.yMMMEd()
                                                  .format(DateTime.now())),
                                              SizedBox(
                                                height: 5,
                                              ),
                                              SizedBox(
                                                height: 150,
                                              ),
                                              Center(
                                                child: Text(
                                                  "Retrieving Vehicles Data",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 150,
                                              ),
                                            ]))))
                            : StreamBuilder(
                                stream: getNumbers(const Duration(seconds: 10)),
                                initialData: Lists,
                                builder: (context, snapshot) {
                                  return Padding(
                                      padding: EdgeInsets.only(
                                          top: 5.0, right: 5, left: 5),
                                      child: Card(
                                          elevation: 10,
                                          color: Colors.white,
                                          child: Padding(
                                              padding: EdgeInsets.all(3),
                                              child: Column(
                                                children: [
                                                  Text(
                                                    'Vehicle Status',
                                                    style: TextStyle(
                                                        fontSize: 25,
                                                        fontWeight:
                                                            FontWeight.w500),
                                                  ),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Text(DateFormat.yMMMEd()
                                                      .format(DateTime.now())),
                                                  SizedBox(
                                                    height: 5,
                                                  ),
                                                  Container(
                                                    width: 450,
                                                    height: 350,
                                                    // margin: EdgeInsets.only(top: 15),
                                                    child:
                                                        Piechart(Lists: Lists),
                                                    // color: commonTextStyle,
                                                  ),
                                                  Row(children: [
                                                    Padding(
                                                        padding:
                                                            EdgeInsets.only(
                                                                left: 109)),
                                                    Text(
                                                      'Moving:${Lists[0].MovingCount.toString()}',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                    SizedBox(
                                                      width: 39,
                                                    ),
                                                    Text(
                                                      'Stopped:${Lists[0].StoppedCount.toString()}',
                                                      style: TextStyle(
                                                          fontSize: 11,
                                                          fontWeight:
                                                              FontWeight.w600),
                                                    ),
                                                  ]),
                                                ],
                                              ))));
                                }),
                        _dashtripList.isEmpty
                            ? Padding(
                                padding: EdgeInsets.only(
                                    top: 5.0, left: 5, right: 5),
                                child: Card(
                                    elevation: 10,
                                    color: Colors.white,
                                    child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            children: [
                                              SizedBox(
                                                height: 3,
                                              ),
                                              Text(
                                                'Trips Overview',
                                                style: TextStyle(
                                                    fontSize: 25,
                                                    fontWeight:
                                                        FontWeight.w500),
                                              ),
                                              Text(DateFormat.yMMMEd()
                                                  .format(DateTime.now())),
                                              SizedBox(
                                                height: 3,
                                              ),
                                              SizedBox(
                                                height: 150,
                                              ),
                                              Center(
                                                child: Text(
                                                  "Retrieving Trip Data",
                                                  style: TextStyle(
                                                      fontSize: 20,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                              SizedBox(
                                                height: 150,
                                              ),
                                            ]))))
                            : Padding(
                                padding: EdgeInsets.only(
                                    top: 5.0, left: 5, right: 5),
                                child: Card(
                                    elevation: 10,
                                    color: Colors.white,
                                    child: Padding(
                                        padding: EdgeInsets.all(3),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Text(
                                              'Trips Overview',
                                              style: TextStyle(
                                                  fontSize: 25,
                                                  fontWeight: FontWeight.w500),
                                            ),
                                            SizedBox(
                                              height: 5,
                                            ),
                                            Text(DateFormat.yMMMEd()
                                                .format(DateTime.now())),
                                            SizedBox(
                                              height: 3,
                                            ),
                                            Container(
                                                width: 450,
                                                height: 350,
                                                child: stackedColumn(
                                                  dashtripList: _dashtripList,
                                                  completed: _completed,
                                                  planned: _planned,
                                                  unplanned: _unplanned,
                                                )),
                                            Text(
                                              "Total Trips:${total_trips}",
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            SizedBox(
                                              height: 20,
                                            ),
                                            Text(
                                              "All rights reserved © 2022 cogniphi.com",
                                              style: TextStyle(
                                                color: Color(0xFF848282),
                                              ),
                                            )
                                          ],
                                        ))),
                              ),
                        // totalEvents.isEmpty
                        //     ? Padding(
                        //         padding: EdgeInsets.only(
                        //             top: 5.0, left: 5, right: 5),
                        //         child: Card(
                        //             elevation: 10,
                        //             color: Colors.white,
                        //             child: Padding(
                        //                 padding: EdgeInsets.all(3),
                        //                 child: Column(
                        //                     mainAxisAlignment:
                        //                         MainAxisAlignment.start,
                        //                     children: [
                        //                       SizedBox(
                        //                         height: 3,
                        //                       ),
                        //                       Text(
                        //                         'Events',
                        //                         style: TextStyle(
                        //                             fontSize: 25,
                        //                             fontWeight:
                        //                                 FontWeight.w500),
                        //                       ),
                        //                       SizedBox(
                        //                         height: 150,
                        //                       ),
                        //                       Center(
                        //                         child: Text(
                        //                           "Retrieving Event Data",
                        //                           style: TextStyle(
                        //                               fontSize: 20,
                        //                               fontWeight:
                        //                                   FontWeight.bold),
                        //                         ),
                        //                       ),
                        //                       SizedBox(
                        //                         height: 150,
                        //                       ),
                        //                     ]))))
                        //     : Padding(
                        //         padding: EdgeInsets.only(
                        //             top: 5.0, left: 5, right: 5),
                        //         child: Card(
                        //             elevation: 10,
                        //             color: Colors.white,
                        //             child: Padding(
                        //                 padding: EdgeInsets.all(3),
                        //                 child: Column(
                        //                   mainAxisAlignment:
                        //                       MainAxisAlignment.start,
                        //                   children: [
                        //                     SizedBox(
                        //                       height: 3,
                        //                     ),
                        //                     Text(
                        //                       'Events',
                        //                       style: TextStyle(
                        //                           fontSize: 25,
                        //                           fontWeight: FontWeight.w500),
                        //                     ),
                        //                     SizedBox(
                        //                       height: 5,
                        //                     ),
                        //                     Text(
                        //                       "Total Event:${totalEvents.length}",
                        //                       style: TextStyle(
                        //                           fontWeight: FontWeight.bold),
                        //                     ),
                        //                     GestureDetector(
                        //                       onTap: () async {
                        //                         // Navigator.push(
                        //                         //   context,
                        //                         //   MaterialPageRoute(
                        //                         //       builder: (context) =>
                        //                         //           ScreenEvents()),
                        //                         // );
                        //                       },
                        //                       child: Container(
                        //                         width: 450,
                        //                         height: 350,
                        //                         child: multibar(),
                        //                       ),
                        //                     ),
                        //                   ],
                        //                 ))),
                        //       ),
                      ])))));
  }

  @override
  void dispose() {
    // print("dispose");
    super.dispose();
  }
}

class Pie {
  Pie({
    required this.MovingCount,
    required this.StoppedCount,
  });
  var MovingCount;
  var StoppedCount;
}

class PieChart {
  PieChart(
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

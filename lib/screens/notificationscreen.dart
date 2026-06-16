import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/themes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../languges/language_constants.dart';

ValueNotifier<List<dynamic>> notification = ValueNotifier([]);
var loader = true;
List<dynamic> ListNoti = [];
List<dynamic> usersFiltered = [];
List<dynamic> results = [];
var dateTime;

getNotification() async {
  final prefs = await SharedPreferences.getInstance();
  var userId = prefs.getString("user_id");
  var orgId = prefs.getString("org_id");
  final url = "${baseUrl}notifications/list-notification/$userId/$orgId";

  var dio = Dio();
  final response = await dio.get(url);

  notification.value.clear();
  usersFiltered.clear();

  print(response.data);

  notification.value.addAll(response.data);
  notification.notifyListeners();
  usersFiltered.addAll(response.data);
}

var searchController = TextEditingController();
String _searchResult = '';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({Key? key}) : super(key: key);

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  String _safeText(dynamic value) {
    if (value == null) {
      return '';
    }

    final text = value.toString().trim();
    return text == 'null' ? '' : text;
  }

  String _displayText(dynamic value) {
    final text = _safeText(value);
    return text.isEmpty ? '---' : text;
  }

  String _eventDetailValue(dynamic eventDetail, String key) {
    if (eventDetail is Map && eventDetail[key] != null) {
      return _safeText(eventDetail[key]);
    }
    return '';
  }

  String _eventDetailText(dynamic eventDetail) {
    final date = _eventDetailValue(eventDetail, 'date');
    final time = _eventDetailValue(eventDetail, 'time');
    final combined = [date, time].where((part) => part.isNotEmpty).join(' ');
    return combined.isEmpty ? '---' : combined;
  }

  bool _matchesSearch(dynamic value, String enteredKeyword) {
    final normalizedValue = _safeText(value).toLowerCase().replaceAll(" ", "");
    final normalizedKeyword =
        enteredKeyword.toLowerCase().replaceAll(" ", "");
    return normalizedValue.contains(normalizedKeyword);
  }

  @override
  void initState() {
    () async {
      await getNotification();

      print(ListNoti.length);
      print(usersFiltered);

      setState(() {
        loader = false;
        ListNoti = usersFiltered;
      });
    }();
    super.initState();
  }

  void _runFilter(dynamic enteredKeyword) {
    print("list data $usersFiltered");

    if (enteredKeyword.isEmpty) {
      setState(() {
        results = usersFiltered;
      });
    } else {
      results = usersFiltered.where((person) {
        final eventDetail = person['eventDetail'];

        return _matchesSearch(person['title'], enteredKeyword) ||
            _matchesSearch(person['alertId'], enteredKeyword) ||
            _matchesSearch(
                _eventDetailValue(eventDetail, 'license_plate'),
                enteredKeyword) ||
            _matchesSearch(
                _eventDetailValue(eventDetail, 'trip_name'), enteredKeyword) ||
            _matchesSearch(_eventDetailValue(eventDetail, 'vehicle_name'),
                enteredKeyword) ||
            _matchesSearch(person['imei'], enteredKeyword) ||
            _matchesSearch(person['priority'], enteredKeyword) ||
            _matchesSearch(
                _eventDetailValue(eventDetail, 'location'), enteredKeyword) ||
            _matchesSearch(person['message'], enteredKeyword);
      }).toList();
    }

    notification.value.clear();
    notification.value.addAll(results);
    notification.notifyListeners();

    print("not data ${notification.value}");

    setState(() {
      ListNoti = results;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
            backgroundColor: Colors.white,
            centerTitle: true,
            leading: IconButton(
                icon: Icon(
                  Icons.close,
                  color: Colors.black,
                ),
                onPressed: () {
                  Navigator.pop(context);
                }),
            title: Text(
              translation(context).notification,
              style: TextStyle(
                  color: Colors.black87, fontFamily: 'Overpass', fontSize: 20),
            ),
            elevation: 0.0),
        backgroundColor: Colors.white.withOpacity(0.90),
        body: Column(
          children: [
            Container(
              decoration: BoxDecoration(
                color: searchBoxColorWhite,
                borderRadius: BorderRadius.all(Radius.circular(5)),
              ),
              child: TextField(
                controller: searchController,
                decoration: InputDecoration(
                    prefixIcon: Icon(Icons.search),
                    suffixIcon: GestureDetector(
                        onTap: () {
                          setState(() {
                            searchController.clear();
                            _searchResult = '';
                            notification.value.clear();
                            notification.value.addAll(usersFiltered);
                            notification.notifyListeners();
                          });
                        },
                        child: Icon(Icons.cancel)),
                    hintText: 'Search',
                    border: InputBorder.none),
                onChanged: (value) async => _runFilter(value),
              ),
            ),
            ValueListenableBuilder(
              valueListenable: notification,
              builder: (BuildContext ctx, List<dynamic> data, Widget? __) {
                print("data:${data.length}");
                return loader == true
                    ? Center(child: CircularProgressIndicator())
                    : data.isEmpty
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
                        : Expanded(
                            child: ListView.builder(
                                itemCount: data.length,
                                itemBuilder: (context, index) {
                                  final value = data[index];

                                  if (value["eventDetail"] != null) {
                                    if (value["eventDetail"]["eventTime"] !=
                                        null) {
                                      DateTime? eventTime = DateTime.tryParse(
                                          value["eventDetail"]["eventTime"]);
                                      if (eventTime != null) {
                                        dateTime =
                                            DateFormat('yyyy-MM-dd HH:mm:ss a')
                                                .format(eventTime);
                                      }
                                    }
                                  } else {
                                    print(
                                        "Event Detail : ${value["eventDetail"]}");
                                  }

                                  return Container(
                                    padding: EdgeInsets.fromLTRB(9, 10, 0, 10),
                                    decoration: BoxDecoration(
                                      border: Border(
                                        top: BorderSide(
                                          color: const Color(0xfff8f8f8),
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        ListTile(
                                            title: Row(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  CircleAvatar(
                                                    backgroundColor:
                                                        Color(0xFFE8BCA7),
                                                    radius: 16,
                                                    child: Center(
                                                        child: IconButton(
                                                      onPressed: () {},
                                                      icon: Icon(
                                                        Icons.message,
                                                        color:
                                                            Color(0xFFF66D24),
                                                        size: 18,
                                                      ),
                                                    )),
                                                  ),
                                                  SizedBox(
                                                    width: 10,
                                                  ),
                                                  Container(
                                                      decoration: BoxDecoration(
                                                          color:
                                                              Color(0xFFEECBB7),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      16)),
                                                      width: 70,
                                                      height: 25,
                                                      child: Padding(
                                                          padding:
                                                              EdgeInsets.only(
                                                                  left: 14,
                                                                  top: 2),
                                                          child: Text(
                                                            "Event",
                                                            style: TextStyle(
                                                                color: Color(
                                                                  0xFFDC6919,
                                                                ),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ))),
                                                ]),
                                            subtitle: Container(
                                                padding:
                                                    EdgeInsets.only(left: 40),
                                                child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      SizedBox(
                                                        height: 15,
                                                      ),
                                                      Text(
                                                        value['title'] ?? "---",
                                                        style: TextStyle(
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 19),
                                                      ),
                                                      SizedBox(
                                                        height: 7,
                                                      ),
                                                      Text(
                                                          value['message'] ??
                                                              "---",
                                                          style: TextStyle(
                                                            color: Color(
                                                                0xFF848282),
                                                            fontSize: 16.5,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          )),
                                                      SizedBox(
                                                        height: 7,
                                                      ),
                                                      Row(children: [
                                                        SizedBox(
                                                          width: 0,
                                                        ),
                                                        Text("Event Detail: ",
                                                            style: TextStyle(
                                                              fontSize: 16.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            )),
                                                        Text(_eventDetailText(
                                                            value["eventDetail"])),
                                                      ]),
                                                      SizedBox(
                                                        height: 7,
                                                      ),
                                                      Row(children: [
                                                        Icon(
                                                          Icons
                                                              .date_range_rounded,
                                                          size: 20,
                                                          color: Color(
                                                              0xFF0765CB),
                                                        ),
                                                        SizedBox(
                                                          width: 3,
                                                        ),
                                                        Text(
                                                            _displayText(
                                                                value["timeOfAlert"]),
                                                            style: TextStyle(
                                                              fontSize: 16.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            )),
                                                        SizedBox(
                                                          width: 6,
                                                        ),
                                                        Text(
                                                          _displayText(
                                                              value['priority']),
                                                          style: TextStyle(
                                                            fontSize: 16.5,
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            color: value[
                                                                        'priority'] ==
                                                                    "CRITICAL"
                                                                ? Color(
                                                                    0xFF9A3434)
                                                                : value['priority'] ==
                                                                        "HIGH"
                                                                    ? Color(
                                                                        0xFFFA822B,
                                                                      )
                                                                    : value['priority'] ==
                                                                            "MEDIUM"
                                                                        ? Color(
                                                                            0xFFF36969,
                                                                          )
                                                                        : Color(
                                                                            0xFFDFC22B,
                                                                          ),
                                                          ),
                                                        ),
                                                      ]),
                                                      SizedBox(
                                                        height: 7,
                                                      ),
                                                      Row(children: [
                                                        Text("Location: ",
                                                            style: TextStyle(
                                                              fontSize: 16.5,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                            )),
                                                        Expanded(
                                                          child: Text(_displayText(
                                                              _eventDetailValue(
                                                                  value["eventDetail"],
                                                                  "location"))),
                                                        ),
                                                      ]),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .end,
                                                        children: [
                                                          value['isRead'] ==
                                                                  true
                                                              ? Image.asset(
                                                                  "images/double-check.png",
                                                                  width: 20,
                                                                  height: 20,
                                                                )
                                                              : Card(
                                                                  color: Colors
                                                                      .white,
                                                                  child: Text(
                                                                    "",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white),
                                                                  )),
                                                        ],
                                                      )
                                                    ]))),
                                      ],
                                    ),
                                  );
                                }));
              },
            ),
          ],
        ));
  }
}

import 'dart:convert';
import 'dart:io';
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

// import 'package:modal_bottom_sheet/modal_bottom_sheet.dart';
bool isEventSubmitbtnclicked = false;

class EventReportsScreen extends StatefulWidget {
  List<dynamic> vehicleList = [];
  List<dynamic> vehicleDetailslist = [];
  EventReportsScreen(
      {super.key, required this.vehicleList, required this.vehicleDetailslist});

  @override
  State<EventReportsScreen> createState() => _EventReportsScreenState();
}

class _EventReportsScreenState extends State<EventReportsScreen> {
  static const String _reverseGeocodeUrl =
      "http://13.234.100.167/nominatim/reverse";
  static const int _maxEventReportRangeDays = 7;

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
  List<String> selectedVehicleNames = [];
  VehicleDrop? selectedVehicleDrop;
  var submitClicked = false;
  var showTable2 = [];
  List<VehicleDrop> eventVehicleDetails = [];
  List<EventDrop> selectedEvents = [];
  List<dynamic> showTable = [];
  bool isTime1GreaterThanTime2 = false;
  final Map<String, String> _eventLocationCache = {};
  double get iosFontAdjustment => Platform.isIOS ? 6.0 : 0.0;

  String? get _eventTypesUrl => "${baseUrl}device/getEvents";

  String? get _eventReportUrl => "${baseUrl}api/event-report";

  bool get _hasEventTypesApi =>
      _eventTypesUrl != null && _eventTypesUrl!.isNotEmpty;

  bool get _hasEventReportApi =>
      _eventReportUrl != null && _eventReportUrl!.isNotEmpty;

  Future<List<VehicleDrop>> loadVehicleTypes(String filter) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("user_id");
      debugPrint('[EventReport] loadVehicleTypes() triggered');
      debugPrint('[EventReport] GET ${baseUrl}vehicle/vehicles/$userId');
      debugPrint('[EventReport] userId: $userId');
      debugPrint('[EventReport] filter: $filter');

      if (userId == null || userId.isEmpty) {
        debugPrint('[EventReport] userId is missing for vehicles API');
        return [];
      }

      final response = await Dio().get("${baseUrl}vehicle/vehicles/$userId");
      debugPrint('[EventReport] list-vehicles status: ${response.statusCode}');
      debugPrint('[EventReport] list-vehicles raw response: ${response.data}');

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

      eventVehicleDetails = loadedVehicles;
      debugPrint(
          '[EventReport] mapped vehicles: ${filteredVehicles.map((e) => '${e.id}:${e.name}').toList()}');
      return filteredVehicles;
    } catch (e) {
      debugPrint('[EventReport] Unable to load vehicles: $e');
      return [];
    }
  }

  Future<List<EventDrop>> loadEventTypes(String filter) async {
    if (!_hasEventTypesApi) {
      debugPrint('[EventReport] Event types URL is empty.');
      return [];
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString("user_id");
      debugPrint('[EventReport] loadEventTypes() triggered');
      debugPrint('[EventReport] POST $_eventTypesUrl');
      debugPrint('[EventReport] userId: $userId');
      debugPrint('[EventReport] filter: $filter');

      if (userId == null || userId.isEmpty) {
        debugPrint('[EventReport] userId is missing in SharedPreferences');
        return [];
      }

      final formData = FormData.fromMap({
        "userId": userId,
      });
      debugPrint('[EventReport] getEvents content-type: multipart/form-data');

      final response = await Dio().post(
        _eventTypesUrl!,
        data: formData,
      );
      debugPrint('[EventReport] getEvents status: ${response.statusCode}');
      debugPrint('[EventReport] getEvents raw response: ${response.data}');

      dynamic source = response.data;
      if (source is Map) {
        source = source['list'] ??
            source['data'] ??
            source['events'] ??
            source['result'] ??
            source;
      }

      final rawData = source is List ? List<dynamic>.from(source) : <dynamic>[];
      debugPrint('[EventReport] parsed event count: ${rawData.length}');

      final loadedEvents = rawData
          .map((item) => EventDrop(
                item['id']?.toString() ??
                    item['events']?.toString() ??
                    item['eventCode']?.toString() ??
                    item['eventName']?.toString() ??
                    '',
                item['name']?.toString() ??
                    item['eventName']?.toString() ??
                    item['eventCode']?.toString() ??
                    'Unknown Event',
              ))
          .where((item) => item.id.isNotEmpty)
          .toList();
      final normalizedFilter = filter.trim().toLowerCase();
      final filteredEvents = normalizedFilter.isEmpty
          ? loadedEvents
          : loadedEvents
              .where(
                  (item) => item.name.toLowerCase().contains(normalizedFilter))
              .toList();
      debugPrint(
          '[EventReport] mapped dropdown events: ${filteredEvents.map((e) => '${e.id}:${e.name}').toList()}');
      return filteredEvents;
    } catch (e) {
      debugPrint('[EventReport] Unable to load event types: $e');
      return [];
    }
  }

  List<dynamic> _asApiValues(List<dynamic> values) {
    return values
        .map((value) => int.tryParse(value.toString()) ?? value)
        .toList();
  }

  String _to24HourFormat(String? displayedTime, String? fallback) {
    if (fallback != null && fallback.isNotEmpty) {
      return fallback;
    }
    if (displayedTime == null || displayedTime.isEmpty) {
      return '';
    }
    return DateFormat("HH:mm")
        .format(DateFormat("hh:mm a").parse(displayedTime));
  }

  double? _parseCoordinate(dynamic value) {
    if (value == null) {
      return null;
    }
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value.toString().trim());
  }

  String _normalizeLocationText(String? value) {
    return value?.trim() ?? '';
  }

  Future<String> _resolveEventLocation(
    Dio dio,
    Map<dynamic, dynamic> item, {
    String fallbackLocation = '',
  }) async {
    final lat = _parseCoordinate(
      item['lattitude'] ??
          item['latitude'] ??
          item['fromLattitude'] ??
          item['fromLatitude'] ??
          item['lat'],
    );
    final long = _parseCoordinate(
      item['longitude'] ??
          item['fromLongitude'] ??
          item['long'] ??
          item['lng'] ??
          item['lon'],
    );
    final normalizedFallback = _normalizeLocationText(fallbackLocation);

    if (lat == null || long == null) {
      return normalizedFallback;
    }

    final cacheKey = '$lat,$long';
    final cachedLocation = _eventLocationCache[cacheKey];
    if (cachedLocation != null && cachedLocation.isNotEmpty) {
      return cachedLocation;
    }

    final url =
        "$_reverseGeocodeUrl?format=json&lat=$lat&lon=$long&zoom=18&addressdetails=1";

    try {
      final location = await dio.get(url);
      final displayName = _normalizeLocationText(
        location.data is Map ? location.data['display_name']?.toString() : null,
      );
      if (displayName.isNotEmpty) {
        _eventLocationCache[cacheKey] = displayName;
        return displayName;
      }
    } catch (e) {
      debugPrint(
          '[EventReport] reverse-geocode failed for lat=$lat lon=$long: $e');
    }

    return normalizedFallback;
  }

  DateTime get _minSelectableDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month - 6, now.day);
  }

  DateTime get _maxSelectableDate {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime _clampDate(DateTime value, DateTime firstDate, DateTime lastDate) {
    if (value.isBefore(firstDate)) {
      return firstDate;
    }
    if (value.isAfter(lastDate)) {
      return lastDate;
    }
    return value;
  }

  DateTime _maxEndDateFromStart(DateTime startDate) {
    final maxRangeEnd = DateTime(
      startDate.year,
      startDate.month,
      startDate.day,
    ).add(const Duration(days: _maxEventReportRangeDays - 1));

    return maxRangeEnd.isBefore(_maxSelectableDate)
        ? maxRangeEnd
        : _maxSelectableDate;
  }

  bool _isDateRangeWithinLimit(DateTime startDate, DateTime endDate) {
    final normalizedStart =
        DateTime(startDate.year, startDate.month, startDate.day);
    final normalizedEnd = DateTime(endDate.year, endDate.month, endDate.day);
    return !normalizedEnd.isAfter(_maxEndDateFromStart(normalizedStart));
  }

  void _syncEndDateWithStart(DateTime startDate) {
    if (_endDateController.text.isEmpty) {
      return;
    }

    final endDate = DateTime.parse(_endDateController.text);
    final allowedEndDate = _clampDate(
      endDate,
      startDate,
      _maxEndDateFromStart(startDate),
    );

    if (allowedEndDate != endDate) {
      _endDateController.text = DateFormat('yyyy-MM-dd').format(allowedEndDate);
    }
  }

  DateTime? _parseDateTimeFromParts(String? date, String? time) {
    final rawDate = date?.trim() ?? '';
    final rawTime = time?.trim() ?? '';
    if (rawDate.isEmpty || rawTime.isEmpty) {
      return null;
    }

    final formats = <DateFormat>[
      DateFormat('yyyy-MM-dd HH:mm:ss'),
      DateFormat('yyyy-MM-dd HH:mm'),
      DateFormat('yyyy-MM-dd hh:mm:ss a'),
      DateFormat('yyyy-MM-dd hh:mm a'),
    ];

    for (final format in formats) {
      try {
        return format.parse('$rawDate $rawTime');
      } catch (_) {}
    }

    return null;
  }

  String _formatDurationValue(String? rawValue) {
    if (rawValue == null) {
      return '-';
    }

    final trimmed = rawValue.trim();
    if (trimmed.isEmpty || trimmed.toLowerCase() == 'null') {
      return '-';
    }

    final parsed = double.tryParse(trimmed);
    if (parsed == null) {
      return trimmed;
    }

    return parsed.toStringAsFixed(2).replaceFirst(RegExp(r'([.]*0+)$'), '');
  }

  Map<String, dynamic> _normalizeEventRow(Map<dynamic, dynamic> item) {
    final rawEventDateTime = item['eventTime']?.toString() ??
        item['dateTime']?.toString() ??
        item['eventDateTime']?.toString() ??
        item['creationTime']?.toString() ??
        '';
    final eventDateTime = DateTime.tryParse(
          rawEventDateTime,
        ) ??
        _parseDateTimeFromParts(
          item['startDate']?.toString() ?? item['date']?.toString(),
          item['startTime']?.toString() ?? item['time']?.toString(),
        );

    final dateTimeText = eventDateTime != null
        ? DateFormat('dd-MM-yyyy | hh:mm:ss a').format(eventDateTime)
        : [
            rawEventDateTime,
            item['date']?.toString(),
            item['startDate']?.toString(),
            item['time']?.toString(),
            item['startTime']?.toString(),
          ]
            .where((value) => value != null && value.trim().isNotEmpty)
            .join(' | ');

    final vehicleName = item['vehicleName']?.toString() ??
        item['vehicle']?.toString() ??
        item['licensePlate']?.toString() ??
        item['regNo']?.toString() ??
        '';

    final durationValue = item['durationMinutes']?.toString() ??
        item['durationInMinutes']?.toString() ??
        item['duration']?.toString() ??
        item['eventDuration']?.toString();

    final eventName = item['eventName']?.toString() ??
        item['event']?.toString() ??
        item['events']?.toString() ??
        item['eventCode']?.toString() ??
        selectedEvents.map((event) => event.name).join(', ');

    final locationValue = item['location']?.toString() ?? '';

    return {
      'vehicleName': vehicleName,
      'speed': item['speed']?.toString() ??
          item['speedKmh']?.toString() ??
          item['speedKMH']?.toString() ??
          item['currentSpeed']?.toString() ??
          item['avgSpeed']?.toString() ??
          '',
      'dateTime': dateTimeText,
      'duration': _formatDurationValue(durationValue),
      'eventName': eventName,
      'location': locationValue.trim().isEmpty ? '' : locationValue,
      'fromLocation': item['fromLocation']?.toString() ??
          item['location']?.toString() ??
          '',
      'toLocation': item['toLocation']?.toString() ??
          item['endLocation']?.toString() ??
          '',
    };
  }

  void _showPendingApiDialog(String title) {
    showDialog(
        context: context,
        builder: (context) {
          Future.delayed(const Duration(seconds: 4), () {
            if (Navigator.of(context, rootNavigator: true).canPop()) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          });
          return AlertDialog(
            title: Text(
              title,
              style: const TextStyle(fontSize: 15),
            ),
          );
        });
  }

  Future<List<dynamic>> getEventReport(var fromDate, fromTime, toDate, toTime,
      vehiclesList, List<EventDrop> events, List<String> vehicleNames) async {
    print('input data are:');
    print(fromDate);
    print(fromTime);
    print(toDate);
    print(toTime);
    print(vehiclesList);
    print(events.map((event) => event.id).toList());
    if (fromDate == toDate) {
      DateTime dateTime1 = DateFormat("hh:mm a").parse(fromTime);
      DateTime dateTime2 = DateFormat("hh:mm a").parse(toTime);

      isTime1GreaterThanTime2 = dateTime1.isAfter(dateTime2);
      print("time is gfreater than: $isTime1GreaterThanTime2");
    }
    String timeWithoutAMPM = fromTime.substring(0, 5);
    print("timeWithoutAMPM 111: $timeWithoutAMPM");
    String timeWithoutAMPM2 = toTime.substring(0, 5);
    print("timeWithoutAMPM 222: $timeWithoutAMPM2");

    showTable = [];
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

    if (isTime1GreaterThanTime2 == true) {
      setState(() {
        submitClicked = false;
      });
      return [];
    }

    if (!_hasEventReportApi) {
      setState(() {
        submitClicked = false;
        nodata = false;
      });
      return [];
    }

    final formattedStartTime =
        _to24HourFormat(fromTime.toString(), startTime?.toString());
    final formattedEndTime =
        _to24HourFormat(toTime.toString(), endTime?.toString());
    final data = {
      "vehicleNames": vehicleNames,
      "fromTime": "${fromDate}T$formattedStartTime",
      "toTime": "${toDate}T$formattedEndTime",
      "events": _asApiValues(events.map((event) => event.id).toList()),
      "lstVehicles": _asApiValues(vehiclesList),
    };
    final payloadJson = jsonEncode(data);
    debugPrint('[EventReport] event-report payload json:');
    debugPrint(payloadJson);
    try {
      final dio = Dio();
      final response = await dio.post(_eventReportUrl!, data: data);
      debugPrint('[EventReport] event-report status: ${response.statusCode}');
      debugPrint('[EventReport] event-report raw response: ${response.data}');
      showTable2 =
          response.data is List ? List<dynamic>.from(response.data) : [];
      final resolvedRows = <Map<String, dynamic>>[];
      for (final item in showTable2.whereType<Map>()) {
        final normalizedItem = Map<dynamic, dynamic>.from(item);
        final row = _normalizeEventRow(normalizedItem);
        final resolvedLocation = await _resolveEventLocation(
          dio,
          normalizedItem,
          fallbackLocation: row['location']?.toString() ?? '',
        );
        if (resolvedLocation.isNotEmpty) {
          row['location'] = resolvedLocation;
        }
        resolvedRows.add(row);
      }
      showTable = resolvedRows;

      setState(() {
        nodata = showTable.isEmpty;
        submitClicked = false;
        _filterclicked = true;
        downloadpdf = showTable.isNotEmpty;
      });
    } catch (e) {
      if (e is DioError) {
        debugPrint(
            '[EventReport] event-report error status: ${e.response?.statusCode}');
        debugPrint(
            '[EventReport] event-report error body: ${e.response?.data}');
      }
      print('Unable to load event report: $e');
      setState(() {
        submitClicked = false;
        nodata = false;
      });
      print("Some error occured");
    }

    List<dynamic> vehLocationList = [];
    return vehLocationList;
  }

  List<Widget> AddVehicleNames() {
    eventVehicleDetails.clear();
    for (var i = 0; i < widget.vehicleList.length; i++) {
      eventVehicleDetails.add(
        VehicleDrop(
          widget.vehicleList[i]["vehicleId"] ?? widget.vehicleList[i]["id"],
          widget.vehicleList[i]["licensePlate"] ??
              widget.vehicleList[i]["name"] ??
              widget.vehicleList[i]["vehicleName"],
        ),
      );
    }
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
      setState(() {
        isEventSubmitbtnclicked = false;
      });
    }();
    super.initState();
  }

  @override
  void dispose() {
    isEventSubmitbtnclicked = false;

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print("widget is that: ${widget.vehicleList}");
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
                          onTap: isEventSubmitbtnclicked == true
                              ? () {
                                  const snackBar = SnackBar(
                                    content: Text(
                                        'Cannot pick date after submitting the data'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              : () async {
                                  final DateTime firstDate = _minSelectableDate;
                                  final DateTime lastDate = _maxSelectableDate;
                                  final DateTime initialDate = _clampDate(
                                    _startDateController.text.isNotEmpty
                                        ? DateTime.parse(
                                            _startDateController.text)
                                        : lastDate,
                                    firstDate,
                                    lastDate,
                                  );
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: firstDate,
                                    lastDate: lastDate,
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
                                      _syncEndDateWithStart(pickedDate);
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
                          onTap: isEventSubmitbtnclicked == true
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
                                    print(time.format(context));
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
                          onTap: isEventSubmitbtnclicked == true
                              ? () {
                                  const snackBar = SnackBar(
                                    content: Text(
                                        'Cannot pick date after submitting the data'),
                                  );
                                  ScaffoldMessenger.of(context)
                                      .showSnackBar(snackBar);
                                }
                              : () async {
                                  final DateTime firstDate = _minSelectableDate;
                                  final DateTime startDate =
                                      _startDateController.text.isNotEmpty
                                          ? DateTime.parse(
                                              _startDateController.text)
                                          : _maxSelectableDate;
                                  final DateTime endFirstDate =
                                      startDate.isAfter(firstDate)
                                          ? startDate
                                          : firstDate;
                                  final DateTime endLastDate =
                                      _maxEndDateFromStart(endFirstDate);
                                  final DateTime initialDate = _clampDate(
                                    _endDateController.text.isNotEmpty
                                        ? DateTime.parse(
                                            _endDateController.text)
                                        : startDate,
                                    endFirstDate,
                                    endLastDate,
                                  );
                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: initialDate,
                                    firstDate: endFirstDate,
                                    lastDate: endLastDate,
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
                          onTap: isEventSubmitbtnclicked == true
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
                                    print(
                                        "the start end time isss is:$finaltime222");
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
                    margin: const EdgeInsets.fromLTRB(0, 5, 0, 20),
                    child: DropdownSearch<EventDrop>.multiSelection(
                      compareFn: (item, selectedItem) =>
                          item.id == selectedItem.id,
                      enabled: isEventSubmitbtnclicked == true ? false : true,
                      selectedItems: selectedEvents,
                      itemAsString: (EventDrop item) => item.name,
                      items: (filter, loadProps) => loadEventTypes(filter),
                      decoratorProps: DropDownDecoratorProps(
                          decoration: InputDecoration(
                              label: Row(
                                children: const [
                                  Text('*',
                                      style: TextStyle(color: Colors.red)),
                                  Padding(
                                    padding: EdgeInsets.all(3.0),
                                  ),
                                  Text(
                                    "Select Events",
                                    style: TextStyle(color: Colors.black),
                                  )
                                ],
                              ),
                              enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(7)),
                              hintText: 'Select events')),
                      popupProps: MultiSelectionPopupProps.menu(
                        showSearchBox: true,
                        searchFieldProps: TextFieldProps(
                          decoration:
                              InputDecoration(hintText: "Search Events"),
                        ),
                      ),
                      onSelected: (List<EventDrop> data) {
                        setState(() {
                          selectedEvents = data;
                        });
                      },
                    ),
                  ),
                  Container(
                    margin: const EdgeInsets.fromLTRB(0, 0, 0, 6),
                    alignment: Alignment.centerLeft,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.info_outline_rounded,
                          size: 14.sp,
                          color: const Color(0xFFB26A00),
                        ),
                        SizedBox(width: 5),
                        Text(
                          "Single vehicle only",
                          style: TextStyle(
                            fontSize: 11.sp + iosFontAdjustment,
                            fontWeight: FontWeight.w600,
                            color: const Color(0xFFB26A00),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    height: 18.h,
                    margin: EdgeInsets.fromLTRB(0, 5, 0, 10),
                    child: SingleChildScrollView(
                      child: DropdownSearch<VehicleDrop>(
                        enabled: isEventSubmitbtnclicked == true ? false : true,
                        items: (filter, loadProps) => loadVehicleTypes(filter),
                        selectedItem: selectedVehicleDrop,
                        compareFn:
                            (VehicleDrop item, VehicleDrop selectedItem) {
                          return item.id == selectedItem.id;
                        },
                        itemAsString: (VehicleDrop item) => item.name,
                        decoratorProps: DropDownDecoratorProps(
                            decoration: InputDecoration(
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
                                hintText: 'Choose a vehicle')),
                        popupProps: const PopupProps.menu(
                          searchFieldProps: TextFieldProps(
                              decoration:
                                  InputDecoration(hintText: "Search Vehicles")),
                          showSearchBox: true,
                        ),
                        onSelected: (VehicleDrop? data) {
                          setState(() {
                            selectedVehicleDrop = data;
                            selectedVehicles =
                                data == null ? [] : [data.id.toString()];
                            selectedVehicleNames =
                                data == null ? [] : [data.name.toString()];
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
                          margin: const EdgeInsets.fromLTRB(5, 0, 5, 10),
                          child: CustomButton(
                              buttontext: "Submit",
                              onpress: () async {
                                if (_startDateController.text.isEmpty ||
                                    _endDateController.text.isEmpty ||
                                    _startTimeController.text.isEmpty ||
                                    _endTimeController.text.isEmpty ||
                                    selectedEvents.isEmpty ||
                                    selectedVehicles.isEmpty) {
                                  showDialog(
                                      context: context,
                                      builder: (context) {
                                        Future.delayed(
                                            const Duration(seconds: 4), () {
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
                                  return;
                                }
                                if (!_isDateRangeWithinLimit(
                                  DateTime.parse(_startDateController.text),
                                  DateTime.parse(_endDateController.text),
                                )) {
                                  final snackBar = const SnackBar(
                                    behavior: SnackBarBehavior.floating,
                                    margin: EdgeInsets.only(bottom: 230.0),
                                    content: Text(
                                        'Date range cannot be more than 7 days'),
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
                                  print(
                                      "start tume contyrooler is:n ${_startTimeController.text}");
                                  print(
                                      "start tume _endTimeController is:n ${_endTimeController.text}");
                                  print(
                                      "start tume contyrooler is:n ${startTime}");
                                  await getEventReport(
                                      _startDateController.text,
                                      _startTimeController.text,
                                      _endDateController.text,
                                      _endTimeController.text,
                                      selectedVehicles,
                                      selectedEvents,
                                      selectedVehicleNames);
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
                                                                  width: 1250,
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
                                                                        90,
                                                                    scrollController:
                                                                        ScrollController(),
                                                                    // minWidth: 1,
                                                                    columnSpacing:
                                                                        12,
                                                                    fixedTopRows:
                                                                        1,
                                                                    columns: const <DataColumn>[
                                                                      DataColumn(
                                                                          label:
                                                                              Text("Sl No")),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Vehicle Name')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Speed (KM/H)')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Date Time')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Event')),
                                                                      DataColumn(
                                                                          label:
                                                                              Text('Duration')),
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
                                                                        cells: <DataCell>[
                                                                          DataCell(
                                                                              Text("${index + 1}")),
                                                                          DataCell(
                                                                              Text(showTable[index]['vehicleName'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['speed'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['dateTime'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['eventName'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['duration'].toString())),
                                                                          DataCell(
                                                                              Text(showTable[index]['location'].toString())),

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
                                  } else if (nodata == true) {
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
    final String reportTitle = await _buildEventReportTitle();
    document.pageSettings.orientation = PdfPageOrientation.landscape;
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
    final PdfLayoutResult? result =
        await drawHeader(page, pageSize, grid, reportTitle);
    //Draw grid
    drawGrid(page, grid, result!);
    // drawFooter(page, pageSize);
    //Save and launch the document
    List<int> bytes = await document.save();

    // Dispose the document
    document.dispose();

    //Save the file and launch/download
    SaveFile.saveAndLaunchFile(bytes, _buildEventReportFileName(reportTitle));
  }

  String _sanitizeFileNamePart(String value) {
    return value
        .replaceAll(RegExp(r'[<>:"/\\|?*]'), '_')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
  }

  String _formatFileDateTime(String dateText, String timeText) {
    final normalizedDate = dateText.trim();
    final normalizedTime = timeText.trim().toUpperCase();

    try {
      final parsedDate = DateFormat('yyyy-MM-dd').parseStrict(normalizedDate);
      final parsedTime = DateFormat('hh:mm a').parseStrict(normalizedTime);
      final combined = DateTime(
        parsedDate.year,
        parsedDate.month,
        parsedDate.day,
        parsedTime.hour,
        parsedTime.minute,
      );
      return DateFormat('dd-MM-yyyy _ hh_mm_ss a').format(combined);
    } catch (_) {
      final fallback = '$normalizedDate _ $normalizedTime'
          .replaceAll(':', '_')
          .replaceAll('  ', ' ');
      return _sanitizeFileNamePart(fallback);
    }
  }

  Future<String> _getOrganizationName() async {
    final prefs = await SharedPreferences.getInstance();
    final cachedOrgName = (prefs.getString('org_name') ?? '').trim();
    if (cachedOrgName.isNotEmpty) {
      return cachedOrgName;
    }

    final keycloakUserId = prefs.getString("keycloak_user");
    if (keycloakUserId != null && keycloakUserId.isNotEmpty) {
      try {
        final response =
            await Dio().get("${baseUrl}api/user-detail/$keycloakUserId");
        final orgName = response.data is Map
            ? response.data['org_name']?.toString().trim() ?? ''
            : '';
        if (orgName.isNotEmpty) {
          await prefs.setString('org_name', orgName);
          return orgName;
        }
      } catch (e) {
        debugPrint('[EventReport] Unable to load organization name: $e');
      }
    }

    final orgId = (prefs.getString('org_id') ?? '').trim();
    if (orgId.isNotEmpty) {
      return orgId;
    }

    return 'ORGANIZATION';
  }

  Future<String> _buildEventReportTitle() async {
    final fromDateTime = _formatFileDateTime(
      _startDateController.text,
      _startTimeController.text,
    );
    final toDateTime = _formatFileDateTime(
      _endDateController.text,
      _endTimeController.text,
    );

    final orgName = await _getOrganizationName();
    final normalizedOrgName =
        orgName.trim().isEmpty ? 'ORGANIZATION' : orgName.trim();
    return '$normalizedOrgName - EVENT REPORT ($fromDateTime To $toDateTime)';
  }

  String _buildEventReportFileName(String reportTitle) {
    return '${_sanitizeFileNamePart(reportTitle)}.pdf';
  }

  Future<PdfLayoutResult?> drawHeader(
      PdfPage page, Size pageSize, PdfGrid grid, String reportTitle) async {
    //Draw rectangle
    page.graphics.drawRectangle(
        brush: PdfSolidBrush(PdfColor(91, 126, 215, 255)),
        bounds: Rect.fromLTWH(0, 0, pageSize.width - 115, 90));

    page.graphics.drawRectangle(
        bounds: Rect.fromLTWH(400, 0, pageSize.width - 400, 90),
        brush: PdfSolidBrush(PdfColor(65, 104, 205)));

    final double titleFontSize = reportTitle.length > 90
        ? 11
        : reportTitle.length > 65
            ? 13
            : 16;
    final PdfFont titleFont = PdfStandardFont(
      PdfFontFamily.helvetica,
      titleFontSize,
      style: PdfFontStyle.bold,
    );
    //Draw string
    page.graphics.drawString(
      reportTitle,
      titleFont,
      brush: PdfBrushes.white,
      bounds: Rect.fromLTWH(20, 10, pageSize.width - 40, 70),
      format: PdfStringFormat(
        alignment: PdfTextAlignment.left,
        lineAlignment: PdfVerticalAlignment.middle,
      ),
    );
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
    grid.style.font = PdfStandardFont(PdfFontFamily.helvetica, 8);
    //Secify the columns count to the grid.
    grid.columns.add(count: 7);
    //Create the header row of the grid.
    final PdfGridRow headerRow = grid.headers.add(1)[0];
    //Set style
    headerRow.style.backgroundBrush = PdfSolidBrush(PdfColor(68, 114, 196));
    headerRow.style.textBrush = PdfBrushes.white;
    headerRow.style.font = PdfStandardFont(
      PdfFontFamily.helvetica,
      9,
      style: PdfFontStyle.bold,
    );
    headerRow.cells[0].value = 'Sl No';
    headerRow.cells[0].stringFormat.alignment = PdfTextAlignment.center;
    headerRow.cells[1].value = 'Vehicle Name';
    headerRow.cells[2].value = 'Speed (KM/H)';
    headerRow.cells[3].value = 'Date Time';
    headerRow.cells[4].value = 'Event';
    headerRow.cells[5].value = 'Duration';
    headerRow.cells[6].value = 'Location';

    print(showTable.length);
    for (int i = 0; i < showTable.length; i++) {
      String text = showTable[i]['location'].toString();
      if (text.contains("ā")) {
        text = text.replaceAll("ā", "a");
      }
      if (text.contains("ā")) {
        text = text.replaceAll("ā", "a");
      }

      addProducts(
          "${i + 1}",
          showTable[i]['vehicleName'].toString(),
          showTable[i]['speed'].toString(),
          showTable[i]['dateTime'].toString(),
          showTable[i]['eventName'].toString(),
          showTable[i]['duration'].toString(),
          text,
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
    grid.columns[1].width = 105;
    grid.columns[2].width = 55;
    grid.columns[3].width = 125;
    grid.columns[4].width = 90;
    grid.columns[5].width = 70;
    grid.columns[6].width = 250;

    for (int i = 0; i < headerRow.cells.count; i++) {
      headerRow.cells[i].stringFormat.wordWrap = PdfWordWrapType.word;
      headerRow.cells[i].stringFormat.lineLimit = false;
      headerRow.cells[i].style.cellPadding =
          PdfPaddings(bottom: 5, left: 5, right: 5, top: 5);
    }
    for (int i = 0; i < grid.rows.count; i++) {
      final PdfGridRow row = grid.rows[i];
      for (int j = 0; j < row.cells.count; j++) {
        final PdfGridCell cell = row.cells[j];
        if (j == 0) {
          cell.stringFormat.alignment = PdfTextAlignment.center;
        } else {
          cell.stringFormat.alignment = PdfTextAlignment.left;
        }
        cell.stringFormat.wordWrap = PdfWordWrapType.word;
        cell.stringFormat.lineLimit = false;
        if (j == 6) {
          cell.stringFormat.alignment = PdfTextAlignment.left;
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
      String speed,
      String dateTime,
      String eventName,
      String duration,
      String location,
      PdfGrid grid) async {
    // final data = await rootBundle.load("Fonts/arial.ttf");
    // final  dataint = data.buffer.asUint8List(data.offsetInBytes,data.lengthInBytes);
    // final  PdfFont  font  =  PdfTrueTypeFont(dataint,12);
    PdfGridRow row = grid.rows.add();
    // grid.style.font = font;
    row.cells[0].value = slNo;
    row.cells[1].value = vehicleName;
    row.cells[2].value = speed;
    row.cells[3].value = dateTime;
    row.cells[4].value = eventName;
    row.cells[5].value = duration;
    row.cells[6].value = location;
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

class EventDrop {
  final String id;
  final String name;

  EventDrop(this.id, this.name);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is EventDrop && runtimeType == other.runtimeType && id == other.id;

  @override
  int get hashCode => id.hashCode;

  @override
  String toString() => name;
}

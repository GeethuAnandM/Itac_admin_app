import 'dart:async';
import 'dart:io';
import 'dart:typed_data';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/sidebar.dart';
import 'package:admin_app/screens/tracking_screen/location_tab_variables.dart';
import 'package:admin_app/screens/tracking_screen/singleVehLocation.dart';
import 'package:admin_app/screens/tracking_screen/vehicle_live_location.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../languges/language_constants.dart';
import '../utils/vehicle_list_normalizer.dart';
import '/screens/themes.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'addvehiclescreen.dart';
import 'editvehiclescreen.dart';
// var vehicleList = [];

var lati;
var long;

class ManageVehicleScreen extends StatefulWidget {
  ManageVehicleScreen(
      {required this.vehicleList, required this.deviceLocationList});
  List<dynamic> vehicleList = [];
  var deviceLocationList = [];
  @override
  State<ManageVehicleScreen> createState() => _ManageVehicleScreenState();
}

class _ManageVehicleScreenState extends State<ManageVehicleScreen> {
  List<dynamic> vehicleId = [];

  var errormessage;
  bool isError = false;
  bool isLoading = true;
  bool isHomePageSelected = true;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  Widget _icon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
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

  List<ManageVehicles> Lists = [];
  var searchController = TextEditingController();
  String _searchResult = '';
  List<Map<dynamic, dynamic>> usersFiltered = [];
  // @override
  // void initState() {
  //   super.initState();
  //   usersFiltered = vehicleList;
  // }

  getdatas() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    try {
      final url = "${baseUrl}vehicle/vehicles/$userId";
      var dio = Dio();
      final response2 = await dio.get(url);
      List<dynamic> newList = normalizeVehicleListResponse(response2.data);
      for (var i = 0; i < 3; i++) {
        print(" record No.${i + 1} here: " + newList[i]);
      }

      // print(newList.runtimeType);
      return newList;
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      // print("error from getdata: $e");
    }
  }

  var getVehicleTypes = [];
  List<dynamic> getVehicleTypeNames = [];

  getVehicleTypeList() async {
    try {
      final url = "${baseUrl}api/vehicle-types";
      var dio = Dio();
      final response2 = await dio.get(url);
      getVehicleTypes = response2.data;
      // print("reponse data are:${response2.data}");
      // print("reponse data are:${getVehicleTypes}");
      // print("reponse data are:${getVehicleTypes.runtimeType}");

      for (var i in getVehicleTypes) {
        // print(i['name']);
        getVehicleTypeNames.add(i['name']);
        // print("KKKKKKKKKK");
        // print(getVehicleTypeNames);
      }
      // print(getVehicleTypeNames);

      // print(newList[0]['name']);

      // print(" data is here $getVehicleTypeNames");
      // print(getVehicleTypeNames.runtimeType);
      return getVehicleTypes;
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      // print("error from getdata: $e");
    }
  }

  List<Map<String, dynamic>> newListFinal = [];
  var allDeviceIds = [];
  List<dynamic> getDevice = [];

  final List<Map<String, dynamic>> demolist = [
    {"id": 1, "name": "Jishnu", "age": 45},
  ];
  List<Map<dynamic, dynamic>> ListVehicles = [];
  List Listids = [];
  var singleIdData;
  Future<List<dynamic>> getSingleVehiclesIdDetails(vehId) async {
    setState(() {
      loader = true;
    });
    var ids = [];
    ids.add(vehId);
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var data = {"vehicleIds": ids};
    try {
      final url = "${baseUrl}location/vehicle-location";
      var dio = Dio();
      final response = await dio.post(url, data: data);
      singleIdData = response.data;
      print("location data:${response.data}");
      lati = singleIdData[0]["latitude"];
      print(lati.toString());
      long = singleIdData[0]["longitude"];
      print(long.toString());
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print("error from getdata: $e");
    }
    return singleIdData;
  }

  Future<List<dynamic>> getVehiclesIdDetails() async {
    setState(() {
      loader = true;
    });
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var data = {"vehicleIds": vehicleId};
    try {
      final url = "${baseUrl}location/vehicle-location";
      //show error message try catch
      var dio = Dio();
      final response = await dio.post(url, data: data);
      idData = response.data;
      // print("location data:${response.data}");
      // print("vehicletstatus device :${response.data[1]}");
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print("error from getdata: $e");
    }

    // print('length of total vehicle list: ${totVehicleList.length}');
    // print("inside getvehiclesdetails: ${totVehicleList} ");
    return totVehicleList;
    // newList = [response.data, newList2];
  }

  var FormattedDate;
  List<Widget> Addvehicles() {
    // print("length of the list is:${widget.deviceLocationList.length}");
    // print(widget.deviceLocationList);
    ListVehicles.clear();
    for (var i = 0; i < widget.vehicleList.length; i++) {
      var x = 0;
      for (var j = 0; j < widget.deviceLocationList.length; j++) {
        // for(var k = 0; k < widget.vehicleList[i]['insurances'].length; k++){
        if (widget.deviceLocationList[j]['packetTime'] != null) {
          DateTime date = DateFormat("yyyy-MM-dd hh:mm").parse(widget
              .deviceLocationList[j]['packetTime']
              .toString()
              .replaceAll('T', ' '));
          FormattedDate = DateFormat("dd-MM-yyyy hh:mm a").format(date);
        }
        // print('GG');
        // print(widget.deviceLocationList[j]['id']);
        if (widget.vehicleList[i]['deviceId'] ==
            widget.deviceLocationList[j]['id']) {
          for (var l = 0; l < idData.length; l++) {
            // print("new deviceImei data is:${widget.vehicleList[i]}");
            // print("new deviceImeideviceLocationList data is:${widget.deviceLocationList[j]}");
            if (idData[l]['vehicleId'] == widget.vehicleList[i]['vehicleId']) {
              ListVehicles.add({
                "deviceImei": widget.vehicleList[i]['deviceImei'],
                "modelId": widget.vehicleList[i]['modelId'],
                "manufacturerId": widget.vehicleList[i]['manufacturerId'],
                "VehicleModel": widget.vehicleList[i]['model'] != null
                    ? widget.vehicleList[i]['model']
                    : "--",
                "LastReportedTime": FormattedDate,
                "VehicleName": widget.vehicleList[i]['vehicleName'],
                "VehicleType": widget.vehicleList[i]['vehicleTypeName'] != null
                    ? widget.vehicleList[i]['vehicleTypeName']
                    : "--",
                "vehicleTypeId": widget.vehicleList[i]['vehicleTypeId'],
                "manufacturer":
                    widget.vehicleList[i]['manufacturerName'] != null
                        ? widget.vehicleList[i]['manufacturerName']
                        : "--",
                "VIN": widget.vehicleList[i]['vin'] != null
                    ? widget.vehicleList[i]['vin']
                    : "--",
                "VehicleLicensePlate":
                    widget.vehicleList[i]['licensePlate'] != null
                        ? widget.vehicleList[i]['licensePlate']
                        : "--",
                "maintenanceName": null,
                "maintenanceDueDate": null,
                "vehicleMovementStatus": widget.deviceLocationList[j]['speed'],
                "vehicleStatus": idData[l]['vehicleStatus'],
                "deviceStatus": idData[l]['deviceStatus'],
                "insuranceValidity": "",
                // widget.vehicleList[i]['insurances'][0]['insuranceExpiry'],
                // widget.vehicleList[i]['insurances'][0]['insuranceExpiry'],
                "VehicleId": widget.vehicleList[i]['vehicleId'],
                "deviceName": widget.deviceLocationList[j]['deviceName'] == null
                    ? "___"
                    : widget.deviceLocationList[j]['deviceName'],
                "deviceId": widget.deviceLocationList[j]['id']
              });
            }
          }
          x = 1;
          break;
        }
      }
      if (x == 0) {
        ListVehicles.add({
          // "deviceImei": widget.vehicleList[i]['deviceImei'],
          "modelId": widget.vehicleList[i]['modelId'],
          "manufacturerId": widget.vehicleList[i]['manufacturerId'],
          "deviceImei": "--",
          "VehicleModel": widget.vehicleList[i]['model'] != null
              ? widget.vehicleList[i]['model']
              : "--",
          "LastReportedTime": "--",
          "VehicleName": widget.vehicleList[i]['vehicleName'],
          "VehicleType": widget.vehicleList[i]['vehicleTypeName'],
          "vehicleTypeId": widget.vehicleList[i]['vehicleTypeId'],
          "manufacturer": widget.vehicleList[i]['manufacturerName'],
          "VIN": widget.vehicleList[i]['vin'],
          "VehicleLicensePlate": widget.vehicleList[i]['licensePlate'],
          // "insuranceNumber": widget.vehicleList[i]['insurances'][k]
          // ['insuranceName'] !=
          //     null
          //     ? widget.vehicleList[i]['insurances'][k]['insuranceName']
          //     : "--",
          "maintenanceName": "--",
          "maintenanceDueDate": "--",
          "vehicleMovementStatus": "--",
          "vehicleStatus": "--",
          "deviceStatus": "--",
          "insuranceValidity": "",
          // widget.vehicleList[i]['insurances'][0]['insuranceExpiry'],
          "VehicleId": widget.vehicleList[i]['vehicleId'],
          "deviceName": "--"
        });
      }
    }

    for (var i = 0; i < widget.vehicleList.length; i++) {
      if (widget.vehicleList[i]['insurances'] != null) {
        for (var j = 0; j < widget.vehicleList[i]['insurances'].length; j++) {
          for (var k = 0; k < ListVehicles.length; k++) {
            if (widget.vehicleList[i]['vehicleId'] ==
                ListVehicles[k]['VehicleId']) {
              ListVehicles[k]["insuranceValidity"] = widget.vehicleList[i]
                          ['insurances'][j]['insuranceExpiry'] !=
                      null
                  ? widget.vehicleList[i]['insurances'][j]['insuranceExpiry']
                  : "--";

              ListVehicles[k]["insuranceNumber"] = widget.vehicleList[i]
                          ['insurances'][j]['insuranceName'] !=
                      null
                  ? widget.vehicleList[i]['insurances'][j]['insuranceName']
                  : "--";
            }
          }
        }
      }
    }

    // print(" length${ListVehicles}");

    setState(() {
      // Lists = Lists;
      ListVehicles = ListVehicles;
    });

    List<Widget> Demo = [];
    return Demo;
  }

  var totVehicleList = [];
  var deleteconfirmed = false;
  var deleted = false;
  var success;
  var clickeddeleteButton = false;
  var erroroccured = false;
  var deleteStatusCode;
  Future<List<dynamic>> deleteVehicle(var vehicleId) async {
    setState(() {
      // deletion= true;
      // print("try 1 st deletion${deleteconfirmed}");
    });
    try {
      final url = "${baseUrl}api/delete-vehicle/$vehicleId";
      var dio = Dio();

      final response = await dio.delete(url);
      // print(response.data);

      // print(response.statusCode);
      setState(() {
        deleteStatusCode = response.statusCode;
        deleteconfirmed = true;
      });
      route() async {
        // print("delete success");
        final vehicledetails = await getVehiclesIdDetails();
        final devicedetails = await getDeviceCurrentLocation();
        // print("delete success2");
        setState(() {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => ManageVehicleScreen(
                      vehicleList: vehicledetails,
                      deviceLocationList: devicedetails,
                    )),
          );
        });
      }

      startTimer() async {
        var duration = Duration(seconds: 1);
        return Timer(duration, route);
      }

      await startTimer();
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        var erroroccured = true;
        deleteconfirmed = true;
        deleteStatusCode = 400;

        // deletion= false;
        // deletebutton= false;
        // print("catch deletion${deleteconfirmed}");
      });
    }
    return totVehicleList;
  }

  // var totVehicleList = [];

  var vehLocationList = [];
  List<dynamic> allids = [];

  List<dynamic> idData = [];
  var dio = Dio();
  var offlineVehicles = 0;
  var onlineVehicles = 0;

  var loader = false;

  Future<List<dynamic>> getVehiclesDetails() async {
    setState(() {
      loader = true;
    });
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    try {
      final url = "${baseUrl}vehicle/vehicles/$userId";
      //show error message try catch
      var dio = Dio();
      final response = await dio.get(url);
      totVehicleList = normalizeVehicleListResponse(response.data);
      widget.vehicleList = List<dynamic>.from(totVehicleList);
      allids = [];
      vehicleId = [];
      for (var i in totVehicleList) {
        if (i['deviceId'] != null || i['deviceId'] != "") {
          allids.add(i['deviceId']);
          vehicleId.add(i['vehicleId']);
        }
        // print("allid:$allids");
        // print("vehicle:${vehicleId}");
      }
      print("All:$allids");
      print("All:${allids.length}");
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print("error from getdata: $e");
    }

    print('length of total vehicle list: ${totVehicleList.length}');
    print("inside getvehiclesdetails: ${totVehicleList} ");
    return totVehicleList;
    // newList = [response.data, newList2];
  }

  Future<List<dynamic>> getDeviceCurrentLocation() async {
    // print("all device ids from getDeviceCurrentLocation: ${allids}");
    var data = {"deviceIds": allids};
    try {
      const url2 = "${baseUrl}location/getDeviceCurrentLocation";
      final response = await dio.post(url2, data: data);
      vehLocationList = await response.data;
      print("in get getDeviceCurrentLocation");
      setState(() {
        loader = false;
      });
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        loader = false;
      });
      print("Some error occured");
    }
    // print("online count: ${onlineVehicles}");
    return vehLocationList;
  }

  //funtion to  search

  List<Map<dynamic, dynamic>> getDeviceNames = [];
  List<Map<dynamic, dynamic>> excludedDeviceNames = [];
  List newdevicenames = [];
  Future<List<dynamic>> getDeviceLists() async {
    excludedDeviceNames = [];
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    print("user iddd is: $userId");
    final url = "${baseUrl}device/getDevices/$userId";
    print("URL: ${url}");
    try {
      var dio = Dio();
      final response = await dio.get(url);
      print(response.data['list']);
      print("get debviceeeeee sisss :${response.data}");

      setState(() {
        editbuttonclicked = false;
      });
      setState(() {
        allDeviceIds = response.data['list'];
      });
      print("device data are length :${allDeviceIds.length}");
      for (var i in allDeviceIds) {
        print("device details: ${i["deviceId"]}");
        print("device details: ${i["deviceId"]}");
        if (i["deviceId"] != "null") {
          print("devicexssssss are $i");
          excludedDeviceNames.add(
              {"id": i['deviceId'], "name": i['deviceName'], "uid": i['uid']});
        }
      }

      // allids
      for (var i = 0; i < excludedDeviceNames.length; i++) {}
      print("excludedDeviceNames 5555 data are:${excludedDeviceNames.length}");
      print("excludedDeviceNames 5555 data are:${allids.length}");
      newdevicenames = [];
      for (var j in allids) {
        print("all id loop is:${j}");
        for (var i = 0; i < excludedDeviceNames.length; i++) {
          if (j != null) {
            if (excludedDeviceNames[i]['id'] == j) {
              newdevicenames.add(excludedDeviceNames[i]);
              print("j from allids iss $j");
              print(
                  "i from excludedDeviceNames iss ${excludedDeviceNames[i]['id']}");
              print("id matches");
            }
          }
        }
      }
      // List newListfordevices = [];
      // List<int> a = [1, 2, 3, 4, 5, 6, 7, 8];
      // List<int> b = [3, 5, 8];
      //
      // List newListfordevices = a.where((element) => !b.contains(element)).toList();
      //
      // print(newListfordevices);
      print("newdevicenames early data data are:${newdevicenames}");
      print("newdevicenames early data data are:${newdevicenames.length}");

      print("newdevicenames data data are:${allids.length}");
      print("allDeviceIds data data are:${allDeviceIds}");
      print("allDeviceIds data data are:${allDeviceIds.length}");
      List<int> aIds =
          List<int>.from(newdevicenames.map((element) => element['id']));

      // List newList = allDeviceIds.where((element) => !aIds.contains(element['deviceId'])).toList();
      newListFinal = allDeviceIds
          .where((element) => !aIds.contains(element['deviceId']))
          .map((element) => {
                'deviceId': element['deviceId'],
                'deviceName': element['deviceName'],
                'uid': element['uid'],
              })
          .toList();
      print("newList data data are:${newListFinal.length}");

      print(newListFinal);
      List eList = [];
      List noList = [];
      // for(var i=0; i<allDeviceIds.length; i++){
      //   for(var j=0; j<allids.length; j++){
      //
      //     if(allids[j] != null){
      //       if(allDeviceIds[i]['deviceId']== allids[j]){
      //         eList.add(allids[j]);
      //       }
      //       else {
      //         noList.add(allDeviceIds[i]['deviceId']);
      //       }
      //     }
      //   }
      //
      // }
      print("eList in ifffff data data are:${eList}");
      print("noList in ifffff data data are:${noList}");

      // for (var element in newdevicenames) {
      //   if (!allids.contains(element['id'])) {
      //     print("newdevicenames data data are:${element}");
      //     newListfordevices.add(element);
      //   }
      // }
      // List<int> filteredB = allids.where((element) => element != null).toList();
      //
      // List newListfordevices = newdevicenames.where((element) => !filteredB.contains(element['id'])).toList();

      // print("the filtered list is that : $newListfordevices");
      // print("the filtered list is that : ${newListfordevices.length}");

      // for (int element in allids) {
      //   if (!excludedDeviceNames.contains(element)) {
      //     newListfordevices.add(element);
      //   }
      // }
      print("device data are:${excludedDeviceNames}");
      print("excludedDeviceNames data are:${excludedDeviceNames.length}");
      print("newdevicenames data are:${newdevicenames.length}");
      // newdevicenames =newList;
      print("newdevicenames data data are:${newdevicenames}");
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        editbuttonclicked = false;
      });
    }

    print(getDeviceNames);
    print(" devices names is here $getDeviceNames");
    print(" existing devices names is here $excludedDeviceNames");
    print(" devices names is here ${getDeviceNames.length}");
    print(" existing devices names is here ${excludedDeviceNames.length}");

    print(getDeviceNames.runtimeType);
    return getDeviceNames;
  }

  void showSnackBar(BuildContext context, String title) {
    final snackBar = SnackBar(
      content: Text(title),
      margin: EdgeInsets.only(
        bottom: 300,
        right: 20,
        left: 20,
      ),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: '',
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
  void initState() {
    () async {
      // await getVehicles();
      //  print("this:${vehicleList.length}");
      //  usersFiltered = Lists
      await getVehiclesDetails();
      await getVehiclesIdDetails();
      await Addvehicles();

      print(" list vehicle length${ListVehicles.length}");
      print("user filter length ${usersFiltered.length}");
      setState(() {
        idData = idData;
        usersFiltered = ListVehicles;
        isLoading = false;
      });
    }();
    super.initState();
  }

  void _runFilter(dynamic enteredKeyword) {
    List<Map<dynamic, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      setState(() {
        results = ListVehicles;
        // usersFiltered = results;
      });
    } else {
      results = ListVehicles.where((person) =>
              person["VehicleName"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["VehicleType"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["VehicleLicensePlate"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["VehicleModel"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["insuranceNumber"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["deviceName"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["insuranceNumber"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")))
          .toList();
    }
    // we use the toLowerCase() method to make it case-insensitive
    // Refresh the UI
    setState(() {
      usersFiltered = results;
    });
  }

  var editbuttonclicked;
  var addButtonClicked = false;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    return Scaffold(
      key: _key,
      drawer: NavBar(),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            centerTitle: true,
            leading:
                Padding(padding: EdgeInsets.only(top: 15), child: _appBar()),
            title: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(translation(context).manageVehicles)),
            elevation: 0,
          )),
      body: Container(
        color: Color(0xFFEAEAEA),
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: addButtonClicked
                ? Center(
                    child: CircularProgressIndicator(
                    color: Colors.white,
                  ))
                : Icon(Icons.add),
            onPressed: () async {
              setState(() {
                addButtonClicked = true;
              });
              await getVehicleTypeList();
              await getDeviceLists();
              setState(() {
                addButtonClicked = false;
              });
              print("Excluded: ${excludedDeviceNames}");
              print("Excluded: ${excludedDeviceNames.length}");

              print("vehicle types are here: ${await getVehicleTypes}");
              // getVehicleTypeName()  {
              //   print("get types called");
              //   for(var i; i > getVehicleTypes.length; i++){
              //     getVehicleTypeNames.add(getVehicleTypes[i]["name"]);
              //   }
              // }
              // await getVehicleTypeName();
              print(getVehicleTypeNames);
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => AddVehicleScreen(
                          deviceId: newListFinal,
                          // excludedDeviceNames,
                          getVehicleTypes: getVehicleTypes,
                          vehicleList: totVehicleList.isNotEmpty
                              ? totVehicleList
                              : widget.vehicleList,
                        )),
              );
            },
          ),
          body: Column(
            children: [
              Container(
                height: MediaQuery.of(context).size.height * .12,
                padding: EdgeInsets.fromLTRB(8, 5, 8, 5),
                decoration: BoxDecoration(
                  color: buttonColourBlue,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * .06,
                            decoration: BoxDecoration(
                              color: searchBoxColorWhite,
                              borderRadius:
                                  BorderRadius.all(Radius.circular(5)),
                            ),
                            child: TextField(
                              controller: searchController,
                              decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.search,
                                    color: Colors.black,
                                  ),
                                  suffixIcon: GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          searchController.clear();
                                          _searchResult = '';
                                          usersFiltered = ListVehicles;
                                        });
                                      },
                                      child: Icon(Icons.cancel,
                                          color: Colors.black)),
                                  hintText: 'Search',
                                  hintStyle: TextStyle(color: Colors.black),
                                  border: InputBorder.none),
                              onChanged: (value) async => _runFilter(value),
                            ),
                          ),
                        ),
                      ],
                    )
                  ],
                ),
              ),
              Expanded(
                child: Container(
                    padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                    child: isError == true
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
                        : isLoading == true
                            ? Center(child: CircularProgressIndicator())
                            : usersFiltered.isNotEmpty
                                ? ListView.builder(
                                    itemCount: usersFiltered.length,
                                    itemBuilder: (context, index) {
                                      var formattedDate;
                                      // print(
                                      //     "date coming is ${usersFiltered[index]['insuranceValidity']}");
                                      if (usersFiltered[index]
                                                  ['insuranceValidity'] !=
                                              null &&
                                          usersFiltered[index]
                                                  ['insuranceValidity'] !=
                                              '') {
                                        DateTime dateTime = DateTime.parse(
                                            usersFiltered[index]
                                                ['insuranceValidity']);
                                        formattedDate = DateFormat('yyyy-MM-dd')
                                            .format(dateTime);
                                      }
                                      return SingleChildScrollView(
                                        scrollDirection: Axis.vertical,
                                        child: Container(
                                          margin:
                                              EdgeInsets.fromLTRB(0, 15, 0, 0),
                                          padding:
                                              EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          decoration: BoxDecoration(
                                              color: Color(0xFFFFFFFF),
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(10)),
                                              border: Border.all(
                                                width: 1,
                                                color: Color(0xFF000000)
                                                    .withOpacity(0.3),
                                              )),
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Container(
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topRight: Radius
                                                                      .circular(
                                                                          9),
                                                                  bottomLeft:
                                                                      Radius.circular(
                                                                          9)),
                                                          color: blueColor,
                                                        ),
                                                        child: Row(
                                                          // crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Tooltip(
                                                              child:
                                                                  GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        print(
                                                                            "vehicle data is:${usersFiltered[index]}");
                                                                        showSnackBar(
                                                                            context,
                                                                            "Loading...");
                                                                        await getVehicleTypeList();
                                                                        await getDeviceLists();
                                                                        print(
                                                                            "device type issss that on click second:${usersFiltered[index]['vehicleTypeId']}");
                                                                        print(
                                                                            "device id is that:${usersFiltered[index]['VehicleType']}");
                                                                        print(
                                                                            "device type issss that on click:${usersFiltered[index]['vehicleType']}");
                                                                        print(
                                                                            "device type issss that on click:${usersFiltered[index]['vehicleTypeId']}");
                                                                        Navigator
                                                                            .push(
                                                                          context,
                                                                          MaterialPageRoute(
                                                                              builder: (context) => EditVehicleScreen(
                                                                                    detailsforedit: usersFiltered[index],
                                                                                    deviceId: newListFinal,
                                                                                    getVehicleTypes: getVehicleTypes,
                                                                                    data: totVehicleList.isNotEmpty ? totVehicleList : widget.vehicleList,
                                                                                    vehicleCurrentDeviceId: usersFiltered[index]['deviceId'],
                                                                                    vehicleid: usersFiltered[index]['VehicleId'],
                                                                                    vehicleName: usersFiltered[index]['VehicleName'],
                                                                                    vehicleType: usersFiltered[index]['VehicleType'],
                                                                                    vehicleLicensePlate: usersFiltered[index]['VehicleLicensePlate'],
                                                                                    vin: usersFiltered[index]['VIN'],
                                                                                    insuranceValidity: usersFiltered[index]['insuranceValidity'],
                                                                                    maintenanceDueDate: usersFiltered[index]['maintenanceDueDate'],
                                                                                    insuranceNumber: usersFiltered[index]['insuranceNumber'],
                                                                                    VehicleModel: usersFiltered[index]['VehicleModel'],
                                                                                    manufacturer: usersFiltered[index]['manufacturer'],
                                                                                    deviceIMEI: usersFiltered[index]['deviceImei'],
                                                                                    maintenanceName: usersFiltered[index]['maintenanceName'],
                                                                                    deviceName: usersFiltered[index]['deviceName'],
                                                                                    vehicleTypeId: usersFiltered[index]['vehicleTypeId'],
                                                                                  )),
                                                                        );
                                                                      },
                                                                      child:
                                                                          editIcon),
                                                              message:
                                                                  "Edit Vehicle",
                                                            ),
                                                            SizedBox(
                                                              width: 2.h,
                                                            ),
                                                            Tooltip(
                                                              child:
                                                                  GestureDetector(
                                                                      onTap:
                                                                          () async {
                                                                        // setState(() {
                                                                        //   clickeddeleteButton =
                                                                        //       true;
                                                                        //   // deleted= false;
                                                                        // });
                                                                        showDialog(
                                                                          context:
                                                                              context,
                                                                          builder: (context) =>
                                                                              AlertDialog(
                                                                            title:
                                                                                Text(
                                                                              'Do you want to delete the vehicle ${usersFiltered[index]['VehicleName'].toString()}',
                                                                              style: TextStyle(fontSize: 16),
                                                                            ),
                                                                            // content: Text('',
                                                                            //     style: TextStyle(fontSize: 10)),
                                                                            actions: [
                                                                              // deletion == true?
                                                                              Row(
                                                                                children: [
                                                                                  Container(
                                                                                      child: ElevatedButton(
                                                                                          style: ElevatedButton.styleFrom(backgroundColor: offlineColor),
                                                                                          onPressed: () async {
                                                                                            await deleteVehicle(usersFiltered[index]['VehicleId']);
                                                                                            if (deleteStatusCode == 200) {
                                                                                              Navigator.pop(context);
                                                                                              showDialog(
                                                                                                  context: context,
                                                                                                  builder: (context) {
                                                                                                    Future.delayed(Duration(seconds: 4), () {
                                                                                                      Navigator.of(context, rootNavigator: true).pop();
                                                                                                      // Navigator
                                                                                                      //     .pop(
                                                                                                      //     context);
                                                                                                      // Navigator.of(context).pop();
                                                                                                    });
                                                                                                    return AlertDialog(
                                                                                                      // (context) =>
                                                                                                      // AlertDialog(
                                                                                                      title: Center(
                                                                                                        child: Text(
                                                                                                          "Vehicle Deleted Sucessfully",
                                                                                                          style: TextStyle(fontSize: 15),
                                                                                                        ),
                                                                                                      ),
                                                                                                      content: Container(
                                                                                                        // height: 30.h,
                                                                                                        // width: 30.w,
                                                                                                        margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                                                                                                        child: Lottie.asset('images/117063-delete.json',
                                                                                                            // height: ,
                                                                                                            fit: BoxFit.fill),
                                                                                                      ),
                                                                                                      // content: Text('',
                                                                                                      //     style: TextStyle(fontSize: 10)),
                                                                                                    );
                                                                                                  });
                                                                                              // final vehicledetails= await getVehiclesDetails();
                                                                                              // final devicedetails= await getDeviceCurrentLocation();
                                                                                              // Navigator.pushReplacement(
                                                                                              //   context,
                                                                                              //   MaterialPageRoute(
                                                                                              //       builder: (context) => ManageVehicleScreen(vehicleList: vehicledetails, deviceLocationList: devicedetails,)),
                                                                                              // );
                                                                                            } else {
                                                                                              Navigator.pop(context);
                                                                                              showDialog(
                                                                                                  context: context,
                                                                                                  builder: (context) {
                                                                                                    Future.delayed(Duration(seconds: 3), () {
                                                                                                      Navigator.of(context, rootNavigator: true).pop();
                                                                                                    });
                                                                                                    return AlertDialog(
                                                                                                      title: Center(
                                                                                                        child: Text(
                                                                                                          "Some error occured",
                                                                                                          style: TextStyle(fontSize: 15),
                                                                                                        ),
                                                                                                      ),
                                                                                                    );
                                                                                                  });
                                                                                            }
                                                                                            // await deleteVehicle(usersFiltered[index]['VehicleId']);
                                                                                            // Navigator.pop(
                                                                                            //     context);
                                                                                          },
                                                                                          child: Center(
                                                                                              child: Text(
                                                                                            'Confirm',
                                                                                            style: vehiclePageCardTextNormalWhiteStyle,
                                                                                          )))),
                                                                                  ElevatedButton(
                                                                                      style: ElevatedButton.styleFrom(backgroundColor: blueColor),
                                                                                      onPressed: () {
                                                                                        Navigator.pop(context);
                                                                                      },
                                                                                      child: Center(
                                                                                          child: Text(
                                                                                        'Cancel',
                                                                                        style: vehiclePageCardTextNormalWhiteStyle,
                                                                                      )))
                                                                                ],
                                                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                                              )
                                                                            ],
                                                                          ),
                                                                        );
                                                                      },
                                                                      child:
                                                                          deleteIcon),
                                                              message:
                                                                  "Delete Vehicle",
                                                            ),
                                                          ],
                                                        ),
                                                        padding:
                                                            EdgeInsets.all(8),
                                                      ),
                                                    ],
                                                  ),
                                                ],
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child:
                                                          Text('Vehicle Name'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Row(
                                                      children: [
                                                        Container(
                                                          margin: EdgeInsets
                                                              .fromLTRB(
                                                                  0, 15, 5, 5),
                                                          height: 45,
                                                          width: 45,
                                                          child: Tooltip(
                                                            child: Image.asset(
                                                              (usersFiltered[index]["deviceStatus"] ==
                                                                              "Offline" ||
                                                                          usersFiltered[index]["deviceId"] ==
                                                                              null) &&
                                                                      usersFiltered[index]['VehicleType']
                                                                              .toString() ==
                                                                          'Car'
                                                                  ? 'images/new-car-icon-red.png'
                                                                  : (usersFiltered[index]["deviceStatus"] == "Offline" ||
                                                                              usersFiltered[index]["deviceId"] ==
                                                                                  null) &&
                                                                          usersFiltered[index]['VehicleType'].toString() ==
                                                                              'Truck'
                                                                      ? "images/truckred.png"
                                                                      : (usersFiltered[index]["deviceStatus"] == "Offline" || usersFiltered[index]["deviceId"] == null) &&
                                                                              usersFiltered[index]['VehicleType'].toString() == 'Bus'
                                                                          ? 'images/bus-red.png'
                                                                          : (usersFiltered[index]["deviceStatus"] == "Offline" || usersFiltered[index]["deviceId"] == null) && usersFiltered[index]['VehicleType'].toString() == 'Special'
                                                                              ? 'images/special-red.png'
                                                                              : usersFiltered[index]["vehicleStatus"].toString() == "Moving" && usersFiltered[index]["VehicleType"] == "Car"
                                                                                  ? 'images/car-icon-blue-green.png'
                                                                                  : usersFiltered[index]["vehicleStatus"].toString() == "Stop" && usersFiltered[index]["VehicleType"] == "Car"
                                                                                      ? 'images/car-icon-blue-dark-green.png'
                                                                                      : usersFiltered[index]["vehicleStatus"].toString() == "Moving" && usersFiltered[index]["VehicleType"] == "Bus"
                                                                                          ? 'images/bus-blue-gree.png'
                                                                                          : usersFiltered[index]["vehicleStatus"].toString() == "Stop" && usersFiltered[index]["VehicleType"] == "Bus"
                                                                                              ? 'images/bus-dark-blue-green.png'
                                                                                              : usersFiltered[index]["vehicleStatus"].toString() == "Moving" && usersFiltered[index]["VehicleType"] == "Truck"
                                                                                                  ? 'images/truck-blue-green.png'
                                                                                                  : usersFiltered[index]["vehicleStatus"].toString() == "Stop" && usersFiltered[index]["VehicleType"] == "Truck"
                                                                                                      ? 'images/truck-darkblue-green.png'
                                                                                                      : usersFiltered[index]["vehicleStatus"].toString() == "Moving" && usersFiltered[index]["VehicleType"] == "Special"
                                                                                                          ? 'images/common-icon-green-blue.png'
                                                                                                          : 'images/common-icon-green-dark.png',
                                                              // width: 60,
                                                              // height: 40,
                                                              fit: BoxFit.fill,
                                                            ),
                                                            message:
                                                                "Vehicle Type",
                                                          ),
                                                        ),
                                                        Expanded(
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child: Text(
                                                              usersFiltered[index]
                                                                          [
                                                                          "VehicleName"] !=
                                                                      null
                                                                  ? usersFiltered[
                                                                              index]
                                                                          [
                                                                          "VehicleName"]
                                                                      .toString()
                                                                  : "--",
                                                              style:
                                                                  vehiclePageCardTextSubHeadStyle,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 2.0,
                                                color: Colors.black12,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          'Vehicle License Plate'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        usersFiltered[index][
                                                                    "VehicleLicensePlate"] !=
                                                                null
                                                            ? usersFiltered[
                                                                        index][
                                                                    "VehicleLicensePlate"]
                                                                .toString()
                                                            : "--",
                                                        style:
                                                            vehiclePageCardTextSubHeadStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 2.0,
                                                color: Colors.black12,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          'Last Reported Time'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        usersFiltered[index][
                                                                    "LastReportedTime"] !=
                                                                null
                                                            ? usersFiltered[
                                                                        index][
                                                                    "LastReportedTime"]
                                                                .toString()
                                                            : "--",
                                                        style:
                                                            vehiclePageCardTextSubHeadStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 2.0,
                                                color: Colors.black12,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child:
                                                          Text('Vehicle Type'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        usersFiltered[index][
                                                                    "VehicleType"] !=
                                                                null
                                                            ? usersFiltered[
                                                                        index][
                                                                    "VehicleType"]
                                                                .toString()
                                                            : "--",
                                                        style:
                                                            vehiclePageCardTextSubHeadStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 2.0,
                                                color: Colors.black12,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child:
                                                          Text('Vehicle Model'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        usersFiltered[index][
                                                                    "VehicleModel"] !=
                                                                null
                                                            ? usersFiltered[
                                                                        index][
                                                                    "VehicleModel"]
                                                                .toString()
                                                            : "--",
                                                        style:
                                                            vehiclePageCardTextSubHeadStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 2.0,
                                                color: Colors.black12,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text('VIN'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        usersFiltered[index]
                                                                    ["VIN"] !=
                                                                null
                                                            ? usersFiltered[
                                                                        index]
                                                                    ["VIN"]
                                                                .toString()
                                                            : "--",
                                                        style:
                                                            vehiclePageCardTextSubHeadStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 2.0,
                                                color: Colors.black12,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          'Insurance Number'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        usersFiltered[index][
                                                                    "insuranceNumber"] !=
                                                                null
                                                            ? usersFiltered[
                                                                        index][
                                                                    "insuranceNumber"]
                                                                .toString()
                                                            : "--",
                                                        style:
                                                            vehiclePageCardTextSubHeadStyle,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(
                                                thickness: 2.0,
                                                color: Colors.black12,
                                              ),
                                              Row(
                                                children: [
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                          'Insurance Validity'),
                                                    ),
                                                  ),
                                                  Expanded(
                                                    child: Padding(
                                                      padding:
                                                          EdgeInsets.all(8.0),
                                                      child: Text(
                                                        usersFiltered[index][
                                                                    "insuranceValidity"] !=
                                                                null
                                                            ? usersFiltered[
                                                                        index][
                                                                    "insuranceValidity"]
                                                                .toString()
                                                            : "--",
                                                        style:
                                                            vehiclePageCardTextSubHeadStyle,
                                                      ),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: 15,
                                                  )
                                                ],
                                              ),
                                              SizedBox(
                                                height: 1.h,
                                              ),
                                              usersFiltered[index]
                                                          ["deviceStatus"] ==
                                                      'Online'
                                                  ? Divider(
                                                      thickness: 2.0,
                                                      color: Colors.black12,
                                                    )
                                                  : Container(),
                                              usersFiltered[index]
                                                          ["deviceStatus"] ==
                                                      'Online'
                                                  ? GestureDetector(
                                                      onTap: () async {
                                                        getSingleVehiclesIdDetails(
                                                            usersFiltered[index]
                                                                ["VehicleId"]);
                                                        ByteData
                                                            byteDatacurrent =
                                                            await DefaultAssetBundle
                                                                    .of(context)
                                                                .load(
                                                                    "images/navigation-marker.png");
                                                        urlList2 =
                                                            byteDatacurrent
                                                                .buffer
                                                                .asUint8List();
                                                        print(
                                                            "Selected Vehicle details: ${usersFiltered[index]}");
                                                        deviceID =
                                                            usersFiltered[index]
                                                                ["deviceId"];
                                                        var vehicleName =
                                                            usersFiltered[index]
                                                                ["VehicleName"];
                                                        print(lati);
                                                        print(long);
                                                        if (lati != null &&
                                                            long != null) {
                                                          var data = {
                                                            "lat": lati,
                                                            "lng": long
                                                          };
                                                          print(deviceID
                                                                  .toString() +
                                                              ", " +
                                                              vehicleName +
                                                              ", " +
                                                              data.toString());
                                                          SelectedVehCoords =
                                                              data;
                                                          getCurrentLocation();
                                                          print("SelectedVehicleCoordinates" +
                                                              SelectedVehCoords
                                                                  .toString());
                                                          Navigator.push(
                                                            context,
                                                            MaterialPageRoute(
                                                                builder:
                                                                    (context) =>
                                                                        CurrentLocationMap()),
                                                          );
                                                        } else {
                                                          print(
                                                              "Coordinates null");
                                                        }
                                                      },
                                                      child: Row(
                                                        children: [
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Text(
                                                                  'Track Vehicle'),
                                                            ),
                                                          ),
                                                          Expanded(
                                                            child: Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(8.0),
                                                              child: Icon(
                                                                Icons
                                                                    .trending_up,
                                                                color:
                                                                    blackColor,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    )
                                                  : Container(),
                                            ],
                                          ),
                                        ),
                                      );
                                    })
                                : Center(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        LottieBuilder.asset(
                                            "images/no-data-found.json"),
                                        const Text("No Data available"),
                                        const SizedBox(
                                          height: 20,
                                        ),
                                      ],
                                    ),
                                  )),
              ),

              // SizedBox(child: Text(data[0])),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
}

class ManageVehicles {
  var VehicleId;
  var VehicleName;
  var VehicleLicensePlate;
  var vehicleStatus;
  var vehicleMovementStatus;
  var LastReportedTime;
  var VehicleType;
  var VehicleModel;
  var VIN;
  var deviceIMEI;
  var manufacturer;
  var maintenanceName;
  var maintenanceDueDate;
  var insuranceNumber;
  var insuranceValidity;

  ManageVehicles(
      {required this.VehicleId,
      required this.deviceIMEI,
      required this.VehicleModel,
      required this.LastReportedTime,
      required this.VehicleName,
      required this.VehicleType,
      required this.manufacturer,
      required this.VIN,
      required this.VehicleLicensePlate,
      required this.insuranceNumber,
      required this.maintenanceName,
      required this.maintenanceDueDate,
      required this.vehicleMovementStatus,
      required this.vehicleStatus,
      required this.insuranceValidity});
}

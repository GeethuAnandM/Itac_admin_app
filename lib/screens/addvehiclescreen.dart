import 'dart:async';
import 'dart:core';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/sidebar.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:search_choices/search_choices.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../languges/language_constants.dart';
import '../utils/vehicle_list_normalizer.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'custom_widget.dart';
import 'managevehiclescreen.dart';

var vehicleName,
    vehicleType,
    licensePlateNumber,
    vin,
    orgId,
    deviceIds,
    modelName,
    manufacturerName,
    insuranceNumber,
    insuranceValidity;

class AddVehicleScreen extends StatefulWidget {
  AddVehicleScreen(
      {required this.deviceId,
      required this.getVehicleTypes,
      required this.vehicleList});
  List<dynamic> vehicleList = [];
  var getVehicleTypes = [];
  var deviceId = [];
  @override
  State<AddVehicleScreen> createState() => _AddVehicleScreenState();
}

class _AddVehicleScreenState extends State<AddVehicleScreen> {
  bool _isObscure = true;
  bool _isObscure2 = true;

  List<ManageVehicles> TotalVehicle = [];

  bool licenseplatematch = false;
  bool vinmatch = false;

  var vehiclestatus;
  var vehiclemovementstatus;
  var carselection;
  var busselection;
  var truckselection;
  var submitbutton = false;
  var message = '';
  var vehicleadded = false;

  route() {
    Navigator.pop(context);
  }

  startTimer() async {
    var duration = Duration(seconds: 2);
    return Timer(duration, route);
  }

  Future<dynamic> createVehicleDetails(
    vehicleName,
    vehicleType,
    licensePlateNumber,
    vin,
    orgId,
    deviceIds,
    modelName,
    // manufacturerName,
    insuranceNumber,
    insuranceValidity,
  ) async {
    setState(() {
      submitbutton = true;
    });
    final prefs = await SharedPreferences.getInstance();
    var orgId = prefs.getString("org_id");
    print('values are');
    print(deviceIds);
    print(orgId);
    print(vehicleName);
    print(vehicleType);
    print(licensePlateNumber);
    print(vin);
    print(modelName);
    print(manufacturerName);
    print(insuranceNumber);
    print(insuranceValidity);
    print(insuranceValidity.runtimeType);
    print("all device ids from getDeviceCurrentLocation: ${vehicleName}");
    print(
        "all device ids from getDeviceCurrentLocation: ${licensePlateNumber}");
    print("all device ids from getDeviceCurrentLocation: ${modelName}");
    print("all device ids from getDeviceCurrentLocation: ${vehicleType}");
    print("all device ids from getDeviceCurrentLocation: ${vin}");
    print(
        "all device ids from deviceIMEIController.text: ${deviceIMEIController.text}");

    var data = {
      "insurances": [
        {
          "insuranceName": insuranceNumber.toString(),
          "insuranceExpiry": insuranceValidity.toString()
        }
      ],
      "vehicleName": vehicleName.toString(),
      "vehicleTypeId": vehicleType.toString(),
      "orgId": orgId.toString(),
      "deviceId": vehicleNameselected?.id.toString(),
      "licensePlate": licensePlateNumber.toString(),
      "vin": vin.toString(),
      "model":
          vehiclemodelsIs == 1077979889 ? null : selectedmodelis.toString(),
      "manufacturerId": manufactureIs,
      "modelId": vehiclemodelsIs == 1077979889 ? null : vehiclemodelsIs,
      "deviceImei": deviceIMEIController.text
      // "manufacturer":manufacturerName.toString()
    };
    const url2 = "${baseUrl}api/create-vehicle";
    var vehLocationList = [];
    try {
      print("in try  section");
      var dio = Dio();
      print("data: ${data}");
      final response = await dio.post(url2, data: data);
      print("reposnsssseeeesss:$response");
      print("Response : ${response.data}");
      print(response.statusCode);
      if (response.statusCode == 500 || response.statusCode == 201) {
        showSnackBar("Some error occured");
      } else {
        showSnackBar("Vehicle added sucessfully");
      }
      setState(() {
        // submitbutton= false;
        message = "Vehicle Added Sucessfully";
        vehicleadded = true;
      });
      // vehLocationList =  response.data;
      // await startTimer();
      print("in get getDeviceCurrentLocation");
      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 4), () {
              Navigator.of(context, rootNavigator: true).pop();
            });
            return AlertDialog(
              // (context) =>
              // AlertDialog(
              title: Text(
                "Vehicle Added Successfully",
                style: TextStyle(fontSize: 15),
              ),
              content: Container(
                // height: 30.h,
                // width: 30.w,
                margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
                child: Lottie.asset('images/19231-payment-successful.json',
                    // height: ,
                    fit: BoxFit.fill),
              ),
              // content: Text('',
              //     style: TextStyle(fontSize: 10)),
            );
          });
      // print(": ${vehLocationList}");

      return vehLocationList;
    } on DioError catch (e) {
      print(e.response!.data);
      showSnackBar(e.response!.data['message']);
      setState(() {
        submitbutton = false;
      });
    } catch (e) {
      print(e);
      print("some error occured");

      showDialog(
          context: context,
          builder: (context) {
            Future.delayed(Duration(seconds: 4), () {
              Navigator.of(context, rootNavigator: true).pop();
            });
            return AlertDialog(
              title: Text(
                "Please fill all required fields before submitting",
                style: TextStyle(fontSize: 15),
              ),
            );
          });
      await startTimer();
      setState(() {
        submitbutton = false;
        message = "Please fill all required fields before submitting";
      });
    }
  }

  final vehicleNameController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  final LicensePlateController = TextEditingController();
  final vinController = TextEditingController();
  final deviceIMEIController = TextEditingController();
  final manufacturerController = TextEditingController();
  final modelNameController = TextEditingController();
  final insuranceNumberController = TextEditingController();
  final insuranceValidityController = TextEditingController();

  // final maintenanceNameController = TextEditingController();
  // final maintenanceDueDateController = TextEditingController();

  Future<List<VehicleDropNew>> filterdata(filter) async {
    List<VehicleDropNew> res = [];
    res = totDevices.where((element) => element.name.contains(filter)).toList();
    // setState(() {
    //
    // });
    return res;
  }

  VehicleDropNew? vehicleNameselected;
  List<VehicleDropNew> totDevices = [];

  List<Widget> AddDevices() {
    print("devices total length is:${widget.deviceId.length}");
    print("devices total length is:${widget.deviceId}");

    var newdeviceid = [];
    newdeviceid = widget.deviceId;

    totDevices = [];
    Set<String> addedDeviceIds = Set<String>();
    List added = [];
    var a = 1;
    for (var i = 0; i < newdeviceid.length; i++) {
      var deviceId = newdeviceid[i]['deviceId'];
      var deviceName = newdeviceid[i]['deviceName'];
      var deviceImei = newdeviceid[i]['uid'];
      print("Device ID isssss in addd: $deviceId");
      print("Device ID isssss in addd: $deviceName");

      // if(a==1){
      added.add(deviceId.toString());
      //   a=2;
      // }
      // Check if the device ID has already been added
      if (added.toString().contains(deviceId.toString())) {
        print("Device ID already exists: $deviceId");
        // Skip adding the duplicate device
      }
      // else {
      if (totDevices.length <= newdeviceid.length) {
        totDevices.add(VehicleDropNew(deviceId, deviceName, deviceImei));
        print("Device ID does not exists: $deviceId");
        print("Device totDevices s: ${totDevices.length}");

        added.add(deviceId.toString());
      }
      // }

      // else {
      //   print("Device ID does not exists: $deviceId");
      //   totDevices.add(VehicleDropNew(deviceId, deviceName, deviceImei));
      //   addedDeviceIds.add(deviceId.toString());
      //   added.add(deviceId);
      // }

      // Add the device to the list and mark its ID as added
    }

    print("Devices added to the class: $totDevices");
    print("Devices added to the class: ${totDevices.length}");
    List<Widget> Demo = [];
    return Demo;
  }

  List<Widget> CheckLicensePlate() {
    // for (var i = 0; i < widget.vehicleList.length; i++) {
    //   if (widget.vehicleList[i]['vehicleId'] == 9562) {
    //     print(widget.vehicleList[i]['vehicleId']);
    //   } else {
    //     print('not matching');
    //   }
    // }
    print("vehicle list are:${widget.vehicleList}");
    print("devices added to the class is:${totDevices}");
    List<Widget> Demo = [];
    return Demo;
  }

  var insuranceValidity;
  var vehicletype = "";
  List<Map<String, dynamic>> vehicleTypes = [];
  var vehicleTypeId = [];

  getVehicleTypes() async {
    const url = "${baseUrl}api/vehicle-types";
    //show error message try catch
    var dio = Dio();
    final response = await dio.get(url);
    // setState(() async {
    print("vehicvles types api is: ${response.data}");
    vehicleTypes = response.data;
    // print(vehicleTypes[0]['vehicleTypeId']);
    print(vehicleTypes);
    print(vehicleTypes.runtimeType);

    for (var i in vehicleTypes) {
      // vehicleTypeId.add(vehicleTypes[i]['vehicleTypeId']);
      print("vehicle id list is $vehicleTypeId ");
    }
    // });
    print('length of total vehicle list: ${vehicleTypes.length}');
    print("inside getvehiclesdetails: ${vehicleTypes} ");
    print(vehicleTypeId);
  }

  List manufactures = [];
  var manufacturesId = [];
  var manufactureIs;

  Future getmanufactures() async {
    const url = "${baseUrl}api/manufacturer/439";
    //show error message try catch
    var dio = Dio();
    final response = await dio.get(url);
    // setState(() async {
    print('mamnufactures isisisssss: ${response.data}');
    setState(() {
      manufactures = response.data;
    });
    // print(vehicleTypes[0]['vehicleTypeId']);
    print("mamnufactures in function are $manufactures");
    print(manufactures.runtimeType);

    for (var i in manufactures) {
      // vehicleTypeId.add(vehicleTypes[i]['vehicleTypeId']);
      print("vehicle id list is $manufacturesId ");
    }
    // });
    print('length of total vehicle list: ${manufactures.length}');
    print("inside getvehiclesdetails: ${manufactures} ");
    print(manufacturesId);
  }

  var getVehicleTypesNew = [];

  Future getvehicleTypes() async {
    const url = "${baseUrl}api/vehicle-types";
    getVehicleTypesNew = [];
    try {
      var dio = Dio();
      final response = await dio.post(url, data: {
        "manufacturerids": [manufactureIs]
      });
      setState(() {
        getVehicleTypesNew = response.data;
      });
      print("getVehicleTypesNew modelsss areaaa 3333are $getVehicleTypesNew");
    } catch (e) {
      print(e);
    }
  }

  List vehiclemodels = [];
  var vehiclemodelsId = [];
  var vehiclemodelsIs;
  var modelisloaded = false;
  var selectedmodelis;
  Future getvehiclemodels() async {
    const url = "${baseUrl}api/vehicle-model";
    vehiclemodels = [];
    //show error message try catch
    print("manufactyure is ${manufactureIs}  type id is: ${vehicleType}}");
    try {
      var dio = Dio();
      final response = await dio.post(url, data: {
        // "manufacturerids": [manufactureIs],
        // "typeids": [vehicleType]

        "manufacturerids": [manufactureIs],
        "typeids": [vehicleType]
      });
      // setState(() async {
      vehiclemodels = response.data;
      print("vehicle modelsss areaaa 3333are $vehiclemodels");
      setState(() {
        modelisloaded = true;
      });
      // print(vehicleTypes[0]['vehicleTypeId']);
      print("vehicle modelsss areaaa are $vehiclemodels");
      print(vehiclemodels.runtimeType);
    } catch (e) {
      vehiclemodels = [
        {
          "manufacturerId": manufactureIs,
          "modelId": 1077979889,
          "modelName": "No Models Found",
          "typeId": 2
        }
      ];
      setState(() {});
      print("vehicle modelsss in catrch areaaa are $vehiclemodels");

      print(e);
    }
    print('length of total vehicle list: ${manufactures.length}');
    print("inside getvehiclesdetails: ${manufactures} ");
    print(manufacturesId);
  }

  // var deviceId;
  var vehicleType;

  var totVehicleList = [];

  var vehLocationList = [];
  List<dynamic> allids = [];
  var dio = Dio();
  var offlineVehicles = 0;
  var onlineVehicles = 0;
  var loader = false;
  final _formKey = GlobalKey<FormState>();
  Future<List<dynamic>> getVehiclesDetails() async {
    setState(() {
      loader = true;
    });
    final prefs = await SharedPreferences.getInstance();

    var userId = prefs.getString("user_id");
    final url = "${baseUrl}vehicle/vehicles/$userId";
    //show error message try catch
    var dio = Dio();
    try {
      final response = await dio.get(url);
      totVehicleList = normalizeVehicleListResponse(response.data);
      allids = [];
      for (var i in totVehicleList) {
        if (i['deviceId'] != null && i['deviceId'] != "") {
          allids.add(i['deviceId']);
        }
        // print(allids);
      }
    } catch (e) {
      print(e);
      print("Some error occured");
    }
    print('length of total vehicle list: ${totVehicleList.length}');
    print("inside getvehiclesdetails: ${totVehicleList} ");
    return totVehicleList;
    // newList = [response.data, newList2];
  }

  Future<List<dynamic>> getDeviceCurrentLocation() async {
    // print("all device ids from getDeviceCurrentLocation: ${allids}");
    var data = {"deviceIds": allids};
    const url2 = "${baseUrl}location/getDeviceCurrentLocation";
    try {
      final response = await dio.post(url2, data: data);
      vehLocationList = await response.data;
      print("in get getDeviceCurrentLocation");
      setState(() {
        loader = false;
      });
    } catch (e) {
      print(e);
      setState(() {
        loader = false;
      });
      print("Some error occured");
    }
    print("online count: ${onlineVehicles}");
    return vehLocationList;
  }

  var getVehicleTypeNames = [];

  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool isHomePageSelected = true;

  Widget _icon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(13)),
        // color: commonTextStyle,
      ),
      child: InkWell(
        onTap: () {
          scaffoldKey.currentState?.openDrawer();
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

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(title),
      margin: EdgeInsets.only(
        bottom: 450,
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
      await AddDevices();
      await CheckLicensePlate();
      await getmanufactures();
      print(getVehicleTypeNames);
      // totalVehicle = [];
      print("get vehicles type called");
      // await getVehicleTypes();
      print("deviceId from page length:${widget.deviceId.length}");
      print("type length:${widget.deviceId}");
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
    print("deviceId from page length:${widget.deviceId.length}");
    print("deviceId from page length:${widget.deviceId}");

    double iconSize = 35;
    return Scaffold(
        key: scaffoldKey,
        drawer: NavBar(),
        appBar: PreferredSize(
            preferredSize: Size.fromHeight(60.0),
            child: AppBar(
                centerTitle: true,
                leading: Padding(
                    padding: EdgeInsets.only(top: 15), child: _appBar()),
                elevation: 0,
                title: Padding(
                  padding: EdgeInsets.only(top: 20),
                  child: Text(translation(context).addVehicle),
                ))),
        body: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              // crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                    // margin: EdgeInsets.all(5),
                    // height: 300,
                    //   width: 300,
                    child: Lottie.asset('images/106415-vehicles.json',
                        height: 130, fit: BoxFit.cover)),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  // height: MediaQuery.of(context).size.height * .865,
                  // width: MediaQuery.of(context).size.width * .96,
                  padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
                  child: Center(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Center(
                        //   child: Text("Add Vehicle",
                        //     // style: blueColouredTextStyle,
                        //   ),
                        // ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .03,
                        ),
                        Row(
                          children: [
                            Container(
                              child: Image.asset(
                                'images/caricontransparent.png',
                                width: 35,
                                height: 35,
                                fit: BoxFit.fill,
                              ),
                              decoration: BoxDecoration(
                                  color: blueColor,
                                  borderRadius:
                                      BorderRadius.all(Radius.circular(5))),
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                // width: MediaQuery.of(context).size.width * .8 ,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    controller: vehicleNameController,
                                    // controller: TextEditingController(text: TotalVehicle[0].VehicleName.toString(),),
                                    // onChanged: (text) {
                                    //   passwordController.text = text;
                                    //   print('dmeo contit ffff ${passwordController.text}');
                                    // },
                                    keyboardType: TextInputType.streetAddress,
                                    autofocus: false,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Vehicle name can not be empty';
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("Vehicle Name"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "Vehicle Name",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.contact_mail_rounded,
                              size: iconSize,
                              color: blueColor,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                // width: MediaQuery.of(context).size.width * .8 ,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    onChanged: (e) {
                                      setState(() {
                                        licenseplatematch = false;
                                      });
                                    },
                                    controller: LicensePlateController,
                                    keyboardType: TextInputType.streetAddress,
                                    autofocus: false,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'License plate number can not be empty';
                                      } else if (licenseplatematch == true) {
                                        return "License plate is already exists";
                                      }
                                      // "^[A-Z]{2}{0, 1}[0-9]{2}{0, 1}[A-Z]{1, 2}{0, 1}[0-9]{4}"
                                      // else if (!RegExp("^[A-Z]{2}[-][0-9]{1,2}[-][A-Z,a-z]{1,2}[-][0-9]{1}"
                                      //         ).hasMatch(value!)) {
                                      //           return 'Enter a valid License plate number eg: KL-48-JJ-1020';
                                      //
                                      //         }
                                      else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("License Plate Number"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "License Plate Number",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.confirmation_num,
                              size: iconSize,
                              color: blueColor,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                // width: MediaQuery.of(context).size.width * .8 ,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    onChanged: (e) {
                                      setState(() {
                                        vinmatch = false;
                                      });
                                    },
                                    controller: vinController,
                                    keyboardType: TextInputType.streetAddress,
                                    autofocus: false,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'VIN can not be empty';
                                      } else if (vinmatch == true) {
                                        return 'VIN number is already exists';
                                      }
                                      // else if (!RegExp("^[A-Z]{2}[ -][0-9]{1,2}(?: [A-Z])?(?: [A-Z]*)? [0-9]{4}").hasMatch(value!)) {
                                      //   return 'Please enter a valid VIN number';
                                      // }
                                      // ”^[A-Z]{2}[\\ -]{0, 1}[0-9]{2}[\\ -]{0, 1}[A-Z]{1, 2}[\\ -]{0, 1}[0-9]{4}$”
                                      // else if(value!.length < 17){
                                      //   return "VIN should be 17 characters long";
                                      // }
                                      else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("VIN"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "VIN",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),
                        // DropdownSearch<dynamic>(
                        //   popupProps: PopupProps.menu(
                        //     showSearchBox: true,
                        //     showSelectedItems: true,
                        //     // disabledItemFn: (String s) => s.startsWith('I'),
                        //   ),
                        //   // items: widget.deviceId.map((dynamic e)=>e['name']).toList(),
                        //   // [1,2,3,45,4],
                        //   dropdownDecoratorProps: DropDownDecoratorProps(
                        //     dropdownSearchDecoration: InputDecoration(
                        //       labelText: "Menu mode",
                        //       hintText: "country in menu mode",
                        //     ),
                        //   ),
                        //   // onChanged: print,
                        //   selectedItem: "DM-1-Honda-1496",
                        // ),

                        // SearchChoices.single(
                        //   items: <DropdownMenuItem> [1,2,3,4,5,6,7,7,8 ],
                        //   value: selectedValueSingleDialog,
                        //   hint: "Select one",
                        //   searchHint: "Select one",
                        //   onChanged: (value) {
                        //     setState(() {
                        //       // selectedValueSingleDialog = value;
                        //     });
                        //   },
                        //   isExpanded: true,
                        // ),
                        Row(
                          children: [
                            Icon(
                              Icons.gps_fixed,
                              size: iconSize,
                              color: blueColor,
                            ),
                            Expanded(
                              child: Container(
                                  margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                  padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                  // width: MediaQuery.of(context).size.width * .8 ,
                                  child: DropdownSearch<VehicleDropNew>(
                                    popupProps: PopupProps.bottomSheet(
                                        showSearchBox: true,
                                        searchFieldProps: TextFieldProps(
                                            decoration: InputDecoration(
                                                hintText:
                                                    "Search device name"))),
                                    dropdownDecoratorProps:
                                        DropDownDecoratorProps(
                                      dropdownSearchDecoration: InputDecoration(
                                        labelText: "Select a Device",
                                        hintText: "Select a Device",
                                        border: new OutlineInputBorder(
                                          borderSide: new BorderSide(
                                              color: Colors.black),
                                          borderRadius:
                                              BorderRadius.circular(5.0),
                                        ),
                                      ),
                                    ),
                                    items: totDevices,
                                    // asyncItems: (String filter) =>
                                    //     filterdata(filter),
                                    onChanged: (VehicleDropNew? data) async {
                                      if (data != null) {
                                        setState(() {
                                          // print("newvalue${vehicleNameselected!.id}");
                                          vehicleNameselected = data;
                                          deviceIMEIController.text =
                                              vehicleNameselected!.imei;
                                          print(
                                              "newvalue:${vehicleNameselected?.id}");
                                          // EasyLoading.show(status: "Loading");
                                        });
                                        // await getdata();
                                      }
                                    },
                                  )),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.device_hub,
                              size: iconSize,
                              color: blueColor,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                // width: MediaQuery.of(context).size.width * .8 ,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    readOnly: true,
                                    controller: deviceIMEIController,
                                    keyboardType: TextInputType.number,
                                    // autofocus: false,
                                    // autovalidateMode:
                                    //     AutovalidateMode.onUserInteraction,
                                    // validator: (value) {
                                    //   if (value!.isEmpty) {
                                    //     return 'Model Name can not be empty';
                                    //   } else {
                                    //     return null;
                                    //   }
                                    // },
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("Device IMEI number"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          // const Text('*',
                                          //     style:
                                          //         TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "Device IMEI number",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_view_day_rounded,
                              size: iconSize,
                              color: blueColor,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                // width: MediaQuery.of(context).size.width * .8 ,
                                child: DropdownButtonFormField<dynamic>(
                                  hint: Text(
                                    'Select Vehicle manufacturer',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: manufactureIs,
                                  elevation: 16,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  isDense: true,
                                  decoration: InputDecoration(
                                    label: Row(
                                      children: [
                                        Text("Select Vehicle manufacturer "),
                                        Padding(
                                          padding: EdgeInsets.all(3.0),
                                        ),
                                        const Text('*',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                    // labelText: 'Choose a Category',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      // borderSide: const BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  onChanged: (dynamic newValue) async {
                                    // if (newValue != null) {
                                    if (manufactureIs.toString().isNotEmpty) {
                                      manufactureIs = null;
                                      manufactureIs = newValue;
                                    } else if (manufactureIs
                                        .toString()
                                        .isEmpty) {
                                      manufactureIs = newValue;
                                    }

                                    setState(() {
                                      vehiclemodels = [];
                                      vehicleType = null;
                                      print(
                                          "manu fff isss selcted:$manufactureIs");
                                      print(newValue);
                                    });
                                    await getvehicleTypes();
                                    // }
                                  },
                                  items: manufactures.map((dynamic value) {
                                    return DropdownMenuItem<dynamic>(
                                      value: value['manufacturerId'],
                                      child: Text(
                                          value['manufacturerName'].toString()),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_view_day_rounded,
                              size: iconSize,
                              color: blueColor,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                // width: MediaQuery.of(context).size.width * .8 ,
                                child: DropdownButtonFormField<dynamic>(
                                  hint: Text(
                                    'Select Vehicle Type',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: vehicleType,
                                  elevation: 16,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  isDense: true,
                                  decoration: InputDecoration(
                                    label: Row(
                                      children: [
                                        Text("Select Vehicle Type"),
                                        Padding(
                                          padding: EdgeInsets.all(3.0),
                                        ),
                                        const Text('*',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                    // labelText: 'Choose a Category',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      // borderSide: const BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  onChanged: (dynamic newValue) async {
                                    print(vehicleTypes.length);
                                    if (vehicleType.toString().isNotEmpty) {
                                      vehicleType = null;
                                      vehiclemodelsIs = null;
                                      setState(() {
                                        vehicleType = newValue;
                                        print("vehicle type is: $vehicleType");
                                        print(newValue);
                                      });
                                    } else if (vehicleType.toString().isEmpty) {
                                      // vehicleType=null;
                                      setState(() {
                                        vehicleType = newValue;
                                        print("vehicle type is: $vehicleType");
                                        print(newValue);
                                      });
                                    }
                                    print("vehicle type is: $vehicleType");
                                    await getvehiclemodels();
                                    // }
                                  },
                                  items:
                                      getVehicleTypesNew.map((dynamic value) {
                                    return DropdownMenuItem<dynamic>(
                                      value: value['typeId'],
                                      child: Text(value['typeName'].toString()),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),

                        Row(
                          children: [
                            Icon(
                              Icons.calendar_view_day_rounded,
                              size: iconSize,
                              color: blueColor,
                            ),
                            Expanded(
                              child: Container(
                                margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                // width: MediaQuery.of(context).size.width * .8 ,
                                child: DropdownButtonFormField<dynamic>(
                                  hint: Text(
                                    'Select Vehicle Model',
                                    style: TextStyle(fontSize: 12),
                                  ),
                                  value: vehiclemodelsIs,
                                  elevation: 16,
                                  icon: const Icon(Icons.arrow_drop_down),
                                  isDense: true,
                                  decoration: InputDecoration(
                                    label: Row(
                                      children: [
                                        Text("Select Vehicle Model "),
                                        Padding(
                                          padding: EdgeInsets.all(3.0),
                                        ),
                                        const Text('*',
                                            style:
                                                TextStyle(color: Colors.red)),
                                      ],
                                    ),
                                    // labelText: 'Choose a Category',
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      // borderSide: const BorderSide(color: Colors.green),
                                    ),
                                  ),
                                  onChanged: (dynamic newValue) async {
                                    // if (newValue != null) {
                                    if (vehiclemodelsIs.toString().isNotEmpty) {
                                      vehiclemodelsIs = null;
                                      setState(() {
                                        vehiclemodelsIs = newValue;
                                        print(
                                            "vehiclemodelsIs fff isss selcted:$vehiclemodelsIs");
                                        print(newValue);
                                      });
                                    }
                                    if (vehiclemodelsIs.toString().isEmpty) {
                                      setState(() {
                                        vehiclemodelsIs = newValue;
                                        print(
                                            "vehiclemodelsIs fff isss selcted:$vehiclemodelsIs");
                                        print(newValue);
                                      });
                                    }
                                    for (var i in vehiclemodels) {
                                      if (vehiclemodelsIs == i['modelId']) {
                                        selectedmodelis = i['modelName'];
                                      }
                                    }
                                    print(
                                        "modelName fff modelName selcted:$selectedmodelis");
                                    // await getvehiclemodels();

                                    // }
                                  },
                                  items: vehiclemodels.map((dynamic value) {
                                    // selectedmodelis = value['modelName'];
                                    return DropdownMenuItem<dynamic>(
                                      value: value['modelId'],
                                      child:
                                          Text(value['modelName'].toString()),
                                    );
                                  }).toList(),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(
                        //   height: MediaQuery.of(context).size.height * .02,
                        // ),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.call_to_action_rounded,
                        //       size: iconSize,
                        //       color: blueColor,
                        //     ),
                        //     Expanded(
                        //       child: Container(
                        //         margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                        //         padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                        //         // width: MediaQuery.of(context).size.width * .8 ,
                        //         decoration: BoxDecoration(
                        //             borderRadius:
                        //                 BorderRadius.all(Radius.circular(10))),
                        //         child: Center(
                        //           child: TextFormField(
                        //             controller: modelNameController,
                        //             keyboardType: TextInputType.streetAddress,
                        //             autofocus: false,
                        //             autovalidateMode:
                        //                 AutovalidateMode.onUserInteraction,
                        //             validator: (value) {
                        //               if (value!.isEmpty) {
                        //                 return 'Model Name cannot be empty';
                        //               } else {
                        //                 return null;
                        //               }
                        //             },
                        //             decoration: InputDecoration(
                        //               label: Row(
                        //                 children: [
                        //                   Text("Model Name"),
                        //                   Padding(
                        //                     padding: EdgeInsets.all(3.0),
                        //                   ),
                        //                   const Text('*',
                        //                       style:
                        //                           TextStyle(color: Colors.red)),
                        //                 ],
                        //               ),
                        //               hintText: "Model Name",
                        //               border: new OutlineInputBorder(
                        //                 borderSide:
                        //                     new BorderSide(color: Colors.black),
                        //                 borderRadius:
                        //                     BorderRadius.circular(5.0),
                        //               ),
                        //               hintStyle: TextStyle(
                        //                   fontSize: 15,
                        //                   color: Colors.black,
                        //                   fontWeight: FontWeight.w400),
                        //               errorBorder: UnderlineInputBorder(
                        //                 borderRadius:
                        //                     BorderRadius.circular(7.0),
                        //                 borderSide: BorderSide(
                        //                   color: Colors.red,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),
                        // Row(
                        //   children: [
                        //     Icon(
                        //       Icons.precision_manufacturing_outlined,
                        //       size: iconSize,
                        //       color: blueColor,
                        //     ),
                        //     Expanded(
                        //       child: Container(
                        //         margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                        //         padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                        //         // width: MediaQuery.of(context).size.width * .8 ,
                        //         decoration: BoxDecoration(
                        //             borderRadius:
                        //             BorderRadius.all(Radius.circular(10))),
                        //         child: Center(
                        //           child: TextFormField(
                        //             controller: manufacturerController,
                        //             keyboardType: TextInputType.streetAddress,
                        //             autofocus: false,
                        //             autovalidateMode:
                        //             AutovalidateMode.onUserInteraction,
                        //             validator: (value) {
                        //               if (value!.isEmpty) {
                        //                 return 'Manufacturer Name can not be empty';
                        //               } else {
                        //                 return null;
                        //               }
                        //             },
                        //             decoration: InputDecoration(
                        //               label: Row(
                        //                 children: [
                        //                   Text("Manufacturer Name"),
                        //                   Padding(
                        //                     padding: EdgeInsets.all(3.0),
                        //                   ),
                        //                   const Text('*',
                        //                       style: TextStyle(color: Colors.red)),
                        //                 ],
                        //               ),
                        //               hintText: "Manufacturer Name",
                        //               border: new OutlineInputBorder(
                        //                 borderSide:
                        //                 new BorderSide(color: Colors.black),
                        //                 borderRadius: BorderRadius.circular(5.0),
                        //               ),
                        //               hintStyle: TextStyle(
                        //                   fontSize: 15,
                        //                   color: Colors.black,
                        //                   fontWeight: FontWeight.w400),
                        //               errorBorder: UnderlineInputBorder(
                        //                 borderRadius: BorderRadius.circular(7.0),
                        //                 borderSide: BorderSide(
                        //                   color: Colors.red,
                        //                 ),
                        //               ),
                        //             ),
                        //           ),
                        //         ),
                        //       ),
                        //     ),
                        //   ],
                        // ),
                        // SizedBox(
                        //   height: MediaQuery.of(context).size.height * .02,
                        // ),
                        Row(
                          children: [
                            Icon(
                              Icons.verified_user_rounded,
                              size: iconSize,
                              color: blueColor,
                            ),
                            Expanded(
                              child: Container(
                                // height: MediaQuery.of(context).size.height * .07,
                                margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                // width: MediaQuery.of(context).size.width * .8 ,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    controller: insuranceNumberController,
                                    keyboardType: TextInputType.streetAddress,
                                    autofocus: false,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return 'Insurance number can not be empty';
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("Insurance Number"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "Insurance Number",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .02,
                        ),
                        Row(
                          children: [
                            Icon(
                              Icons.calendar_month,
                              size: iconSize,
                              color: blueColor,
                            ),
                            Expanded(
                              child: Container(
                                height:
                                    MediaQuery.of(context).size.height * .07,
                                margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                                padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                                // width: MediaQuery.of(context).size.width * .8 ,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.all(Radius.circular(10))),
                                child: Center(
                                  child: TextFormField(
                                    onTap: () async {
                                      final now = DateTime.now();

                                      DateTime? pickedDate =
                                          await showDatePicker(
                                        context: context,
                                        initialDate: DateTime(
                                            now.year, now.month, now.day),
                                        firstDate: DateTime(
                                            now.year, now.month, now.day),
                                        lastDate: DateTime(2060),
                                      );
                                      if (pickedDate != null) {
                                        print("timeStamp:");
                                        print(
                                            pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
                                        String formattedDate =
                                            DateFormat('yyyy-MM-dd')
                                                .format(pickedDate);
                                        print(formattedDate);
                                        setState(() {
                                          insuranceValidity =
                                              formattedDate.toString();
                                          print(
                                              "this is the new insurance validity${insuranceValidity}");
                                          insuranceValidityController.text =
                                              formattedDate.toString();
                                          print(
                                              "this is the ${insuranceValidityController.text}");
                                        });
                                      } else {
                                        print(
                                            "Insurance Validity is not selected");
                                      }
                                    },
                                    onChanged: (value) {
                                      setState(() {
                                        insuranceValidity = value;
                                        print(
                                            "this is the new insurance validity${insuranceValidity}");
                                        insuranceValidityController.text =
                                            value;
                                        print(insuranceValidityController.text);
                                      });
                                    },
                                    controller: insuranceValidityController,
                                    keyboardType: TextInputType.text,
                                    autofocus: false,
                                    readOnly: true,
                                    autovalidateMode:
                                        AutovalidateMode.onUserInteraction,
                                    validator: (value) {
                                      if (value.toString().isEmpty) {
                                        return 'Insurance validity can not be empty';
                                      } else {
                                        return null;
                                      }
                                    },
                                    decoration: InputDecoration(
                                      label: Row(
                                        children: [
                                          Text("Insurance Validity"),
                                          Padding(
                                            padding: EdgeInsets.all(3.0),
                                          ),
                                          const Text('*',
                                              style:
                                                  TextStyle(color: Colors.red)),
                                        ],
                                      ),
                                      hintText: "Insurance Validity",
                                      border: new OutlineInputBorder(
                                        borderSide:
                                            new BorderSide(color: Colors.black),
                                        borderRadius:
                                            BorderRadius.circular(5.0),
                                      ),
                                      hintStyle: TextStyle(
                                          fontSize: 15,
                                          color: Colors.black,
                                          fontWeight: FontWeight.w400),
                                      errorBorder: UnderlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(7.0),
                                        borderSide: BorderSide(
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .05,
                        ),
                        // errormessage!.toString().isNotEmpty ?
                        // Container(
                        //   margin: EdgeInsets.fromLTRB(10, 0, 10, 15),
                        //   child: Center(
                        //     child: Text(errormessage!,
                        //       textAlign: TextAlign.center,
                        //       style: TextStyle(color: offlineColor),
                        //     ),
                        //   ),
                        // ): Text(''),
                        submitbutton
                            ? Center(
                                child: CircularProgressIndicator(
                                  color: colorBlue2,
                                ),
                              )
                            : CustomButton(
                                buttontext: "Submit",
                                onpress: () async {
                                  print('Submit');
                                  print(vehicleNameController.text);
                                  print(vehicleType);
                                  print(LicensePlateController.text);
                                  print(vinController.text);
                                  print(modelNameController.text);
                                  print(insuranceNumberController.text);
                                  print(insuranceValidity);
                                  print(vehicleNameselected?.id);
                                  print(widget.vehicleList);

                                  print(
                                      "vehicle list are:${widget.vehicleList}");
                                  print(
                                      "license plate controller:${LicensePlateController.text}");
                                  //
                                  for (var i = 0;
                                      i < widget.vehicleList.length;
                                      i++) {
                                    if (widget.vehicleList[i]['licensePlate'] ==
                                        LicensePlateController.text) {
                                      print("matched licensePLate");
                                      setState(() {
                                        licenseplatematch = true;
                                      });
                                      print(widget.vehicleList[i]
                                          ['licensePlate']);
                                    } else if (widget.vehicleList[i]['vin'] ==
                                        vinController.text) {
                                      print("matched vin");
                                      setState(() {
                                        vinmatch = true;
                                      });
                                      print(widget.vehicleList[i]['vin']);
                                    } else {
                                      // print('not matching');
                                    }
                                  }
                                  if (_formKey.currentState!.validate()) {
                                    print(
                                        "vehcl ei tryoe in iss :$vehicleType");
                                    var add = await createVehicleDetails(
                                      vehicleNameController.text,
                                      vehicleType,
                                      LicensePlateController.text,
                                      vinController.text,
                                      orgId,
                                      vehicleNameselected?.id,
                                      modelNameController.text,
                                      insuranceNumberController.text,
                                      insuranceValidity,
                                    );
                                    print("Value in Add: ${add} ");

                                    if (vehicleadded == true) {
                                      final vehicledetails =
                                          await getVehiclesDetails();
                                      final devicedetails =
                                          await getDeviceCurrentLocation();
                                      setState(() {
                                        submitbutton = false;
                                      });
                                      print(
                                          "vehicle deatils for the the manage vehicle screens are: ${vehicledetails}");
                                      print(
                                          "vehicle location deatils for the the manage vehicle screens are: ${devicedetails}");
                                      print("data added");

                                      Navigator.pushReplacement(
                                        context,
                                        MaterialPageRoute(
                                            builder: (context) =>
                                                ManageVehicleScreen(
                                                  vehicleList: vehicledetails,
                                                  deviceLocationList:
                                                      devicedetails,
                                                )),
                                      );
                                    }
                                  } else {
                                    print('data not added');
                                  }
                                }),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .025,
                        ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomRight,
                        colors: [Colors.white54, Colors.white54]),
                    // color:
                    // // Colors.white,
                    // Color(0xFF2196F3),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                    // borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Colors.black.withOpacity(0.2),
                      ),
                    ],
                  ),

                  // color: Color(0xFF0190D7),
                ),
              ],
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

class VehicleDrop {
  var name;
  var id;
  VehicleDrop(this.id, this.name);

  @override
  String toString() {
    return '${this.name}';
  }
}

class VehicleDropNew {
  var name;
  var id;
  var imei;
  VehicleDropNew(this.id, this.name, this.imei);

  @override
  String toString() {
    return '${this.name}';
  }
}

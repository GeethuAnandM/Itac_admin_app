import 'dart:async';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/sidebar.dart';
import 'package:dio/dio.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../languges/language_constants.dart';
import '../utils/vehicle_list_normalizer.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'custom_widget.dart';
import 'managevehiclescreen.dart';

class EditVehicleScreen extends StatefulWidget {
  EditVehicleScreen(
      {required this.vehicleCurrentDeviceId,
      required this.deviceId,
      required this.getVehicleTypes,
      required this.data,
      required this.vehicleTypeId,
      required this.vehicleid,
      required this.deviceName,
      required this.vehicleName,
      required this.vehicleType,
      required this.insuranceValidity,
      required this.maintenanceDueDate,
      required this.insuranceNumber,
      required this.VehicleModel,
      required this.manufacturer,
      required this.deviceIMEI,
      required this.maintenanceName,
      required this.vehicleLicensePlate,
      required this.vin,
      required this.detailsforedit});

  var vehicleCurrentDeviceId;
  var getVehicleTypes = [];
  var deviceId = [];
  List<dynamic> data = [];
  Map<dynamic, dynamic> detailsforedit = {};
  var vehicleid;
  var vehicleName;
  var vehicleType;
  var vehicleTypeId;
  var vehicleLicensePlate;
  var vin;
  var deviceIMEI;
  var manufacturer;
  var VehicleModel;
  var insuranceNumber;
  var insuranceValidity;
  var maintenanceName;
  var maintenanceDueDate;
  var deviceName;

  @override
  State<EditVehicleScreen> createState() => _EditVehicleScreenState();
}

class _EditVehicleScreenState extends State<EditVehicleScreen> {
  bool _isObscure = true;
  bool _isObscure2 = true;

  List getVehicleData = [];
  // getdatas() async {
  //   final prefs = await SharedPreferences.getInstance();
  //   var userId = prefs.getString("user_id");
  //   try {
  //     print("in list vehicles api");
  //     final url = "$baseUrl:11018/api/list-vehicles/$userId";
  //     var dio = Dio();
  //     final response2 = await dio.get(url);
  //     List<dynamic> newList = response2.data;
  //     print(" data is here $newList");
  //     for(var i in newList ){
  //       if(widget.vehicleid == i['vehicleId']){
  //         print("the vehicle is mathicng $i");
  //       }
  //     }
  //     // print(newList.runtimeType);
  //   } catch (e) {
  //     print("error from getdata: $e");
  //   }
  // }

  List<ManageVehicles> TotalVehicle = [];
  var submitbutton = false;
  var errormessage = '';
  var vehicleadded = false;
  var statuscode;

  Future<dynamic> editVehicleDetails(
      var vehicleId,
      deviceid,
      vehicleName,
      vehicleType,
      licensePlateNumber,
      vin,
      modelName,
      insuranceNumber,
      insuranceValidity) async {
    setState(() {
      submitbutton = true;
    });
    final prefs = await SharedPreferences.getInstance();

    var userId = prefs.getString("user_id");
    var orgId = prefs.getString("org_id");
    print(orgId);
    print(insuranceValidity);

    print("all device11111 ids from getDeviceCurrentLocation: ${vehicleId}");
    print("all device ids from getDeviceCurrentLocation: ${vehicleName}");
    print(
        "all device ids from getDeviceCurrentLocation: ${licensePlateNumber}");
    print("all device ids from getDeviceCurrentLocation: ${modelName}");
    print("all device ids from getDeviceCurrentLocation: ${vehicleType}");
    print("all device ids from getDeviceCurrentLocation: ${vin}");
    print("all device ids onlyyy from getDeviceCurrentLocation: ${deviceid}");
    print(
        "all device ids from deviceIMEIController.text: ${deviceIMEIController.text}");

    var data = {
      "vehicleId": vehicleId,
      "vehicleName": vehicleNameController.text,
      "licensePlate": licensePlateController.text,
      "vehicleTypeId": vehicleType ?? widget.detailsforedit['vehicleTypeId'],
      "vin": vinController.text,
      "deviceId": deviceid ?? widget.detailsforedit['deviceId'],
      "orgId": orgId,
      "model": vehiclemodelsIs == 1077979889
          ? null
          : selectedmodelis ?? widget.detailsforedit['VehicleModel'],
      "manufacturerId":
          manufactureIs ?? widget.detailsforedit['manufacturerId'],
      "modelId": vehiclemodelsIs == 1077979889
          ? null
          : vehiclemodelsIs ?? widget.detailsforedit['modelId'],
      "deviceImei": deviceIMEIController.text,
      "insurances": [
        {
          "insuranceName": insuranceNumberController.text,
          "insuranceExpiry": insuranceValidityController.text
        }
      ]
    };
    // {
    //   "insurances": [
    //     {
    //       "insuranceName": insuranceNumber,
    //       "insuranceExpiry": insuranceValidity
    //     }
    //   ],
    //   "vehicleId": vehicleId,
    //   "vehicleName": vehicleName,
    //   "vehicleTypeId": vehicleType,
    //   "orgId": 1,
    //   // userId,
    //   "licensePlate": licensePlateNumber,
    //   "vin": vin,
    //   "model": modelName
    // };
    final url2 = "${baseUrl}api/update-vehicle";
    var vehLocationList = [];
    try {
      print("in try section");
      var dio = Dio();
      final response = await dio.put(url2, data: data);
      print("Response is:$response");
      print(response.statusCode);
      print(response.data);
      print(response.statusCode);
      // vehLocationList =  response.data;
      // await startTimer();
      print("in get getDeviceCurrentLocation");
      // print(": ${vehLocationList}");
      setState(() {
        // submitbutton= false;
        statuscode = response.statusCode;
        errormessage = "Data added Succesfully";
        vehicleadded = true;
      });
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
      // await startTimer();

      setState(() {
        submitbutton = false;
        errormessage = "Please verify all the fields before submitting";
      });
    }
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

  final TextEditingController vehicleNameController = TextEditingController();
  final TextEditingController vehicleTypeController = TextEditingController();
  final licensePlateController = TextEditingController();
  final vinController = TextEditingController();
  final deviceIMEIController = TextEditingController();
  final manufacturerController = TextEditingController();
  final modelNameController = TextEditingController();
  final insuranceNumberController = TextEditingController();
  final insuranceValidityController = TextEditingController();
  final maintenanceNameController = TextEditingController();
  final maintenanceDueDateController = TextEditingController();

  Future<List<VehicleDropNew>> filterdata(filter) async {
    var res =
        totDevices.where((element) => element.name.contains(filter)).toList();
    return res;
  }

  VehicleDropNew? vehicleNameselected;
  List<VehicleDropNew> totDevices = [];
  var selectedDeviceIdFromApi;
  List<Widget> AddDevices() {
    print("devices total length is:${widget.deviceId.length}");
    print("devices total length is:${widget.deviceId}");
    for (var i = 0; i < widget.deviceId.length; i++) {
      var deviceId = widget.deviceId[i]['deviceId'];
      var deviceName = widget.deviceId[i]['deviceName'];
      var deviceImei = widget.deviceId[i]['uid'];

      // Check if the device already exists in the list
      // bool deviceExists = totDevices.any((device) => device.id == deviceId);
      // If the device doesn't exist, add it to the list
      // if (!deviceExists) {
      print("valid devices id are:${deviceId}");

      totDevices.add(VehicleDropNew(deviceId, deviceName, deviceImei));
      // }
      // else {
      //   print("other devices id are:${deviceId}");
      // }
    }
    print("devices added to the class is:${totDevices}");
    List<Widget> Demo = [];
    return Demo;
  }

  var totVehicleList = [];

  var vehLocationList = [];
  List<dynamic> allids = [];
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
      }
      print(allids);
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
    final url2 = "${baseUrl}location/getDeviceCurrentLocation";
    try {
      final response = await dio.post(url2, data: data);
      vehLocationList = await response.data;
      print("in get getDeviceCurrentLocation");
      setState(() {
        loader = false;
        editcompleted = false;
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

  List manufactures = [];
  var manufacturesId = [];
  var manufactureIs;
  Future getmanufactures() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      var userId = prefs.getString("user_id");
      final url = "${baseUrl}api/manufacturer/439";
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
    } catch (e) {
      print("manufacturer error: $e");
      ScaffoldMessenger.of(context).clearSnackBars();
    }
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
      print("getvehicleTypes error: $e");
      ScaffoldMessenger.of(context).clearSnackBars();
    }
  }

  List vehiclemodels = [];
  var vehiclemodelsId = [];
  var vehiclemodelsIs;
  var modelisloaded = false;
  var selectedmodelis;
  Future getvehiclemodels() async {
    const url = "${baseUrl}api/vehicle-model";
    //show error message try catch
    try {
      print("vehicle vehicleType areaaa 3333are $manufactureIs");
      print("vehicle vehicleType areaaa 3333are $vehicleType");

      var dio = Dio();
      final response = await dio.post(url, data: {
        "manufacturerids": [manufactureIs],
        "typeids": [vehicleType ?? widget.vehicleTypeId]
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
      print(e);
      vehiclemodels = [
        {
          "manufacturerId": manufactureIs,
          "modelId": 1077979889,
          "modelName": "No Models Found",
          "typeId": vehicleType ?? widget.vehicleTypeId
        }
      ];
      setState(() {});
      print("vehicle modelsss in catrch areaaa are $vehiclemodels");
    }
    print('length of total vehicle list: ${manufactures.length}');
    print("inside getvehiclesdetails: ${manufactures} ");
    print(manufacturesId);
  }

  GlobalKey<ScaffoldState> _key = GlobalKey();

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: const BorderRadius.all(const Radius.circular(13)),
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

  var vehicleType;
  var deviceIdSelected;
  var editcompleted;
  var insuranceValiditySelected;
  String? formattedDate;

  List<Map<dynamic, dynamic>> excludedDeviceNames = [];
  var addedDeviceid;
  getDeviceLists() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    final url = "${baseUrl}device/getDevices/$userId";
    print("URL: ${url}");
    try {
      var dio = Dio();
      final response = await dio.get(url);
      print(response.data['list']);
      print("get debviceeeeee sisss :${response.data}");
      print("get debviceeeeee sisss :${widget.detailsforedit['deviceName']}");
      print("added devices detauls are sisss :${widget.detailsforedit}");

      // print("device data are:${response.data}");
      for (var i in response.data['list']) {
        // print("device details: ${i["deviceId"]}");
        if (i["deviceName"] == widget.detailsforedit['deviceName']) {
          addedDeviceid = i['uid'];
        }
        if (i["deviceName"] != widget.detailsforedit['deviceName']) {
          print("devicexssssss are $i");
          excludedDeviceNames.add({
            "id": i['deviceId'],
            "name": i['deviceName'],
            "uid": i['uid'],
          });
        }
      }
      print("device data are:${excludedDeviceNames}");
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    () async {
      await getDeviceLists();
      print("new details for the edits is: ${widget.detailsforedit}");
      vehicleNameController.text = widget.vehicleName;
      // vehicleType = widget.vehicleType;
      licensePlateController.text = widget.vehicleLicensePlate;
      vinController.text = widget.vin;
      // modelNameController.text= widget.VehicleModel;
      insuranceNumberController.text = widget.insuranceNumber;
      insuranceValidityController.text =
          widget.detailsforedit['insuranceValidity'];
      if (addedDeviceid.toString().isNotEmpty) {
        deviceIMEIController.text = addedDeviceid;
      }
      // manufactureIs=widget.detailsforedit['manufacturer'];
      // vehiclemodelsIs= widget.detailsforedit['VehicleModel'];
      // vehicleType= widget.vehicleTypeId;
      // vehicleNameController.text= widget.vehicleName;
      // vehicleNameController.text= widget.vehicleName;

      // VehicleDrop vehicleNameselected;
      print("new:${widget.insuranceValidity}");
      var insurance = widget.insuranceValidity;
      // DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(insurance);
      DateTime dateTime = DateTime.parse(insurance);
      formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
      print("new date is:$formattedDate");
      await AddDevices();
      await getmanufactures();

      // await gettrips();
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
    List<Widget> Addvehicles() {
      print(widget.data.length);
      print(widget.data);
      print(widget.vehicleid);
      // print(widget.data[0]['vehicleName']);
      for (var i = 0; i < widget.data.length; i++) {
        if (widget.data[i]['vehicleId'] == widget.vehicleid) {
          TotalVehicle.add(ManageVehicles(
              deviceIMEI: widget.data[i]['vehicleName'],
              VehicleModel: widget.data[i]['model'],
              LastReportedTime: widget.data[i]['Notdatetime'],
              VehicleName: widget.data[i]['vehicleName'],
              VehicleType: widget.data[i]['vehicleTypeName'],
              manufacturer: widget.data[i]['manufacturer'],
              VIN: widget.data[i]['vin'],
              VehicleLicensePlate: widget.data[i]['licensePlate'],
              insuranceNumber: widget.data[i]['insurances'][0]['insuranceName'],
              maintenanceNameDueDate: null,
              vehicleMovementStatus: widget.data[i]['vehicleStatus'],
              vehicleStatus: widget.data[i]['vehicleStatus'],
              insuranceValidity: widget.data[i]['insurances'][0]
                  ['insuranceExpiry']));
        } else {
          print('all datas are added ');
        }
      }

      List<Widget> Demo = [];
      return Demo;
    }

    final vehiclenameController = TextEditingController();
    print(widget.data.length);
    print(TotalVehicle.length);
    Addvehicles();
    double iconSize = 35;

    return Scaffold(
      key: _key,
      drawer: const NavBar(),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
            centerTitle: true,
            leading: Padding(
                padding: const EdgeInsets.only(top: 15), child: _appBar()),
            title: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(translation(context).editVehicles)),
            elevation: 0,
          )),
      body: SingleChildScrollView(
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Container(
                  // margin: EdgeInsets.all(5),
                  // height: 300,
                  //   width: 300,
                  child: Lottie.asset('images/106415-vehicles.json',
                      height: 130, fit: BoxFit.cover)),
            ),
            Container(
              margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
              // height: MediaQuery.of(context).size.height * .865,
              // width: MediaQuery.of(context).size.width * .96,
              padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomRight,
                    colors: [Colors.white54, Colors.white54]),
                // color:
                // // Colors.white,
                // Color(0xFF2196F3),
                borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                // borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 1),
                    blurRadius: 4,
                    color: Colors.black.withOpacity(0.2),
                  ),
                ],
              ),
              child: Center(
                child: Column(
                  // mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .02,
                    ),
                    Center(
                      child: Text(
                        "Edit Vehicle",
                        // style: blueColouredTextStyle,
                      ),
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .06,
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
                            height: MediaQuery.of(context).size.height * .07,
                            margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                            padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            // width: MediaQuery.of(context).size.width * .8 ,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Center(
                              child: TextFormField(
                                controller: vehicleNameController,
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Vehicle name can not be empty';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  label: Row(
                                    children: [
                                      const Text('*',
                                          style: TextStyle(color: Colors.red)),
                                      Padding(
                                        padding: EdgeInsets.all(3.0),
                                      ),
                                      Text("Vehicle Name")
                                    ],
                                  ),
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                  errorBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
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
                            height: MediaQuery.of(context).size.height * .07,
                            margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                            padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            // width: MediaQuery.of(context).size.width * .8 ,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Center(
                              child: TextFormField(
                                controller: licensePlateController.text == ""
                                    ? TextEditingController(
                                        text: widget.vehicleLicensePlate
                                            .toString())
                                    : licensePlateController,
                                onChanged: (text) {
                                  licensePlateController.text = text;
                                  print('${licensePlateController.text}');
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.streetAddress,
                                autofocus: false,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'License Plate Number can not be empty';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  label: Row(
                                    children: [
                                      const Text('*',
                                          style:
                                              TextStyle(color: offlineColor)),
                                      Padding(
                                        padding: EdgeInsets.all(3.0),
                                      ),
                                      Text("License Plate Number")
                                    ],
                                  ),
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                  errorBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
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
                            height: MediaQuery.of(context).size.height * .07,
                            margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                            padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            // width: MediaQuery.of(context).size.width * .8 ,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Center(
                              child: TextFormField(
                                controller: vinController.text == ""
                                    ? TextEditingController(
                                        text: widget.vin.toString())
                                    : vinController,
                                onChanged: (text) {
                                  vinController.text = text;
                                  print(
                                      'dmeo contit ffff ${vinController.text}');
                                },
                                // autovalidateMode:AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Your Password';
                                  } else if (value.length < 8) {
                                    return "Your Password must contain 8 characters atleast";
                                  } else {
                                    return null;
                                  }
                                },

                                decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  label: Row(
                                    children: [
                                      const Text('*',
                                          style:
                                              TextStyle(color: offlineColor)),
                                      Padding(
                                        padding: EdgeInsets.all(3.0),
                                      ),
                                      Text("VIN")
                                    ],
                                  ),
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                  errorBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
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
                                compareFn: (item1, item2) =>
                                    item1.id == item2.id,
                                popupProps: PopupProps.bottomSheet(
                                    showSearchBox: true,
                                    searchFieldProps: TextFieldProps(
                                        decoration: InputDecoration(
                                            hintText: "Search device name"))),
                                decoratorProps: DropDownDecoratorProps(
                                  decoration: InputDecoration(
                                    labelText:
                                        widget.detailsforedit['deviceName'] ??
                                            "Select A Device",
                                    hintText:
                                        widget.detailsforedit['deviceName'] ??
                                            "Select A Device",
                                    border: new OutlineInputBorder(
                                      borderSide:
                                          new BorderSide(color: Colors.black),
                                      borderRadius: BorderRadius.circular(5.0),
                                    ),
                                  ),
                                ),
                                items: (filter, loadProps) => totDevices.isEmpty
                                    ? <VehicleDropNew>[]
                                    : totDevices,
                                // asyncItems: (String filter) =>
                                //     filterdata(filter),
                                onSelected: (VehicleDropNew? data) async {
                                  if (data != null) {
                                    setState(() {
                                      // print("newvalue${vehicleNameselected!.id}");
                                      vehicleNameselected = data;
                                      deviceIMEIController.text =
                                          vehicleNameselected!.imei;
                                      print(
                                          "newvalue${vehicleNameselected?.id}");

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
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                  errorBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
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
                                widget.detailsforedit['manufacturer'] ??
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
                                        style: TextStyle(color: Colors.red)),
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
                                } else if (manufactureIs.toString().isEmpty) {
                                  manufactureIs = newValue;
                                }
                                setState(() {
                                  vehiclemodels = [];
                                  vehicleType = null;
                                  print("manu fff isss selcted:$manufactureIs");
                                  print(newValue);
                                });
                                await getvehicleTypes();
                                // manufactureIs = newValue;
                                // await getvehiclemodels();
                                // setState(() {
                                //   print(
                                //       "manu fff isss selcted:$manufactureIs");
                                //   print(newValue);
                                // });
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
                                widget.vehicleType,
                                style: TextStyle(fontSize: 12),
                              ),
                              value: vehicleType,
                              elevation: 16,
                              icon: const Icon(Icons.arrow_drop_down),
                              isDense: true,
                              decoration: InputDecoration(
                                label: Row(
                                  children: [
                                    const Text('*',
                                        style: TextStyle(color: Colors.red)),
                                    Padding(
                                      padding: EdgeInsets.all(3.0),
                                    ),
                                    Text("Select Vehicle Type")
                                  ],
                                ),
                                // labelText: 'Choose a Category',
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                  // borderSide: const BorderSide(color: Colors.green),
                                ),
                              ),
                              onChanged: (dynamic newValue) async {
                                // print(vehicleTypes.length);
                                // if (newValue != null) {
                                // setState(() {
                                //   vehicleType = newValue;
                                //   print(" vehicle type is:${vehicleType}");
                                //   print(newValue);
                                // });
                                // }

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
                              },
                              items: getVehicleTypesNew.map((dynamic value) {
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
                                widget.detailsforedit['VehicleModel'] == "--"
                                    ? "Select Vehicle Model"
                                    : widget.detailsforedit['VehicleModel'] ??
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
                                        style: TextStyle(color: Colors.red)),
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
                                // vehiclemodelsIs = newValue;
                                // // await getvehiclemodels();
                                // setState(() {
                                //   print(
                                //       "vehiclemodelsIs fff isss selcted:$vehiclemodelsIs");
                                //   print(newValue);
                                // });
                                // }
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
                              },
                              items: vehiclemodels.map((dynamic value) {
                                // print("modelName fff modelName selcted:$selectedmodelis");
                                return DropdownMenuItem<dynamic>(
                                  value: value['modelId'],
                                  child: Text(value['modelName'].toString()),
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
                          Icons.verified_user_rounded,
                          size: iconSize,
                          color: blueColor,
                        ),
                        Expanded(
                          child: Container(
                            height: MediaQuery.of(context).size.height * .07,
                            margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                            padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            // width: MediaQuery.of(context).size.width * .8 ,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Center(
                              child: TextFormField(
                                controller: insuranceNumberController.text == ""
                                    ? TextEditingController(
                                        text: widget.insuranceNumber.toString())
                                    : insuranceNumberController,
                                onChanged: (text) {
                                  insuranceNumberController.text = text;
                                  print(
                                      'dmeo contit ffff ${insuranceNumberController.text}');
                                },
                                autovalidateMode:
                                    AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Insurance Number can not be empty';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  label: Row(
                                    children: [
                                      const Text('*',
                                          style:
                                              TextStyle(color: offlineColor)),
                                      Padding(
                                        padding: EdgeInsets.all(3.0),
                                      ),
                                      Text("Insurance Number")
                                    ],
                                  ),
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                  errorBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
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
                            height: MediaQuery.of(context).size.height * .07,
                            margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                            padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                            // width: MediaQuery.of(context).size.width * .8 ,
                            decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(10))),
                            child: Center(
                              child: TextFormField(
                                controller: insuranceValiditySelected == null
                                    ? TextEditingController(
                                        text: formattedDate.toString())
                                    : insuranceValidityController,
                                onTap: () async {
                                  final now = DateTime.now();

                                  DateTime? pickedDate = await showDatePicker(
                                    context: context,
                                    initialDate: DateTime(
                                        now.year, now.month, now.day + 1),
                                    firstDate: DateTime(
                                        now.year, now.month, now.day + 1),
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
                                      insuranceValiditySelected =
                                          formattedDate.toString();
                                      insuranceValidityController.text =
                                          formattedDate.toString();
                                      print(
                                          "this is the new insurance validity${insuranceValidityController.text}");
                                      // insuranceValidityController.text = formattedDate.toString();
                                      print(
                                          "this is the ${insuranceValidityController.text}");
                                    });
                                  } else {
                                    print("Insurance Validity is not selected");
                                  }
                                },
                                onChanged: (text) {
                                  setState(() {
                                    insuranceValidityController.text = text;
                                  });
                                  print(
                                      'insurance validity:${insuranceValidityController.text}');
                                },
                                // autovalidateMode:AutovalidateMode.onUserInteraction,
                                keyboardType: TextInputType.text,
                                autofocus: false,
                                readOnly: true,
                                validator: (value) {
                                  if (value!.isEmpty) {
                                    return 'Enter Your Password';
                                  } else {
                                    return null;
                                  }
                                },
                                decoration: InputDecoration(
                                  border: new OutlineInputBorder(
                                    borderSide:
                                        new BorderSide(color: Colors.black),
                                    borderRadius: BorderRadius.circular(5.0),
                                  ),
                                  label: Row(
                                    children: [
                                      const Text('*',
                                          style:
                                              TextStyle(color: offlineColor)),
                                      Padding(
                                        padding: EdgeInsets.all(3.0),
                                      ),
                                      Text("Insurance Validity")
                                    ],
                                  ),
                                  hintStyle: TextStyle(
                                      fontSize: 15,
                                      color: Colors.black,
                                      fontWeight: FontWeight.w400),
                                  errorBorder: UnderlineInputBorder(
                                    borderRadius: BorderRadius.circular(7.0),
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
                    // Row(
                    //   children: [
                    //     Icon(
                    //       Icons.settings,
                    //       size: iconSize,
                    //       color: blueColor,
                    //     ),
                    //     Container(
                    //       height: MediaQuery.of(context).size.height * .07 ,
                    //       margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                    //       padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                    //       width: MediaQuery.of(context).size.width * .8 ,
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.all(Radius.circular(10))
                    //       ),
                    //       child: Center(
                    //         child: TextFormField(
                    //           controller: maintenanceNameController.text == ''?
                    //           TextEditingController(text: widget.maintenanceName.toString()):
                    //           maintenanceNameController,
                    //           onChanged: (text) {
                    //             maintenanceNameController.text = text;
                    //             print('dmeo contit ffff ${maintenanceNameController.text}');
                    //           },
                    //           // autovalidateMode:AutovalidateMode.onUserInteraction,
                    //           keyboardType: TextInputType.text,
                    //           autofocus: false,
                    //           validator: (value) {
                    //             if (value!.isEmpty) {
                    //               return 'Enter Your Password';
                    //             } else if (value.length < 8) {
                    //               return "Your Password must contain 8 characters atleast";
                    //             } else {
                    //               return null;
                    //             }
                    //           },
                    //
                    //           decoration: InputDecoration(
                    //             border: new OutlineInputBorder(
                    //               borderSide:
                    //               new BorderSide(color: Colors.black),
                    //               borderRadius: BorderRadius.circular(5.0),
                    //             ),
                    //             label: Row(
                    //               children: [
                    //                 const Text('*', style: TextStyle(color: offlineColor)),
                    //                 Padding(
                    //                   padding: EdgeInsets.all(3.0),
                    //                 ),
                    //                 Text("Maintenance Name")
                    //               ],
                    //             ),
                    //             hintStyle: TextStyle(
                    //                 fontSize: 15,
                    //                 color: Colors.black,
                    //                 fontWeight: FontWeight.w400),
                    //             errorBorder: UnderlineInputBorder(
                    //               borderRadius: BorderRadius.circular(7.0),
                    //               borderSide: BorderSide(
                    //                 color: Colors.red,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    // SizedBox(
                    //   height:  MediaQuery.of(context).size.height * .02 ,
                    // ),
                    // Row(
                    //   children: [
                    //     Icon(
                    //       Icons.calendar_month,
                    //       size: iconSize,
                    //       color: blueColor,
                    //     ),
                    //     Container(
                    //       height: MediaQuery.of(context).size.height * .07 ,
                    //       margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
                    //       padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
                    //       width: MediaQuery.of(context).size.width * .8 ,
                    //       decoration: BoxDecoration(
                    //           borderRadius: BorderRadius.all(Radius.circular(10))
                    //       ),
                    //       child: Center(
                    //         child: TextFormField(
                    //           controller: maintenanceDueDateController.text == ""?
                    //           TextEditingController(text: widget.maintenanceDueDate.toString()):
                    //           maintenanceDueDateController,
                    //           onChanged: (text) {
                    //             maintenanceDueDateController.text = text;
                    //             print(' ${maintenanceDueDateController.text}');
                    //           },
                    //           // autovalidateMode:AutovalidateMode.onUserInteraction,
                    //           keyboardType: TextInputType.text,
                    //           autofocus: false,
                    //           validator: (value) {
                    //             if (value!.isEmpty) {
                    //               return 'Enter Your Password';
                    //             } else if (value.length < 8) {
                    //               return "Your Password must contain 8 characters atleast";
                    //             } else {
                    //               return null;
                    //             }
                    //           },
                    //
                    //           decoration: InputDecoration(
                    //             border: new OutlineInputBorder(
                    //               borderSide:
                    //               new BorderSide(color: Colors.black),
                    //               borderRadius: BorderRadius.circular(5.0),
                    //             ),
                    //             label: Row(
                    //               children: [
                    //                 const Text('*', style: TextStyle(color: offlineColor)),
                    //                 Padding(
                    //                   padding: EdgeInsets.all(3.0),
                    //                 ),
                    //                 Text("Maintenance Due Date")
                    //               ],
                    //             ),
                    //             hintStyle: TextStyle(
                    //                 fontSize: 15,
                    //                 color: Colors.black,
                    //                 fontWeight: FontWeight.w400),
                    //             errorBorder: UnderlineInputBorder(
                    //               borderRadius: BorderRadius.circular(7.0),
                    //               borderSide: BorderSide(
                    //                 color: Colors.red,
                    //               ),
                    //             ),
                    //           ),
                    //         ),
                    //       ),
                    //     ),
                    //   ],
                    // ),
                    errormessage.toString().isNotEmpty
                        ? Container(
                            margin: EdgeInsets.fromLTRB(5, 15, 5, 0),
                            child: Center(
                              child: Text(
                                errormessage,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    color:
                                        errormessage == "Data added Succesfully"
                                            ? movingColor
                                            : offlineColor),
                              ),
                            ),
                          )
                        : Text(''),

                    SizedBox(
                      height: MediaQuery.of(context).size.height * .05,
                    ),

                    Container(
                        child: CustomButton(
                            // loader: editcompleted == true ?
                            // CircularProgressIndicator(): null,
                            buttontext: "Submit",
                            onpress: () async {
                              var Manufacturer;
                              dynamic vehicleName;
                              if (vehicleNameController.text != '') {
                                var vehicleName2 = vehicleNameController.text;
                                vehicleName = vehicleName2;
                                print(vehicleNameController.text);
                                print('edited vehicle name');
                                print(vehicleName2);
                              } else {
                                print('not edted vehicle name');
                                var vehicleName2 = widget.vehicleName;
                                vehicleName = vehicleName2;
                                print(vehicleName2);
                              }

                              dynamic vehicleTypeSubmit;
                              if (vehicleType != null && vehicleType != "") {
                                print(vehicleType);
                                var vehicleTypeFinal = vehicleType;
                                vehicleTypeSubmit = vehicleTypeFinal;
                                print(vehicleType);
                                print(widget.vehicleTypeId);
                                print('vtype is:');
                                print(vehicleTypeFinal);
                              } else {
                                print('vtype not edted');
                                var vehicleTypeFinal = widget.vehicleTypeId;
                                vehicleTypeSubmit = vehicleTypeFinal;
                                print(widget.vehicleTypeId);
                                print(vehicleTypeFinal);
                              }

                              dynamic licensePlateNumber;
                              if (licensePlateController.text != '') {
                                var licensePlateNumberFinal =
                                    licensePlateController.text;
                                licensePlateNumber = licensePlateNumberFinal;
                                print('edited');
                                print(licensePlateNumberFinal);
                              } else {
                                print('not edted');
                                var licensePlateNumberFinal =
                                    widget.vehicleLicensePlate;
                                licensePlateNumber = licensePlateNumberFinal;
                                print(licensePlateNumberFinal);
                              }

                              dynamic vin;
                              if (vinController.text != '') {
                                var vinFinal = vinController.text;
                                vin = vinFinal;
                                print('edited');
                                print(vinFinal);
                              } else {
                                print('not edted');
                                var vinFinal = widget.vin;
                                vin = vinFinal;
                                print(vinFinal);
                              }

                              dynamic modelName;
                              if (modelNameController.text != '') {
                                var modelNameFinal = modelNameController.text;
                                modelName = modelNameFinal;
                                print('edited');
                                print(modelNameFinal);
                              } else {
                                print('not edted');
                                var modelNameFinal = widget.VehicleModel;
                                modelName = modelNameFinal;
                                print(modelNameFinal);
                              }

                              dynamic insuranceNumber;
                              if (insuranceNumberController.text != '') {
                                var insuranceNumberFinal =
                                    insuranceNumberController.text;
                                insuranceNumber = insuranceNumberFinal;
                                print('edited');
                                print(insuranceNumberFinal);
                              } else {
                                print('not edted');
                                var insuranceNumberFinal =
                                    widget.insuranceNumber;
                                insuranceNumber = insuranceNumberFinal;
                                print(insuranceNumberFinal);
                              }

                              dynamic InsuranceValidity;
                              print(
                                  "insurance validity is:$insuranceValiditySelected");
                              if (insuranceValiditySelected != null) {
                                print(insuranceValiditySelected);
                                var insuranceValidityFinal =
                                    insuranceValiditySelected;
                                InsuranceValidity = insuranceValidityFinal;
                                print(InsuranceValidity.runtimeType);
                                print(InsuranceValidity);
                                print('date edited');
                                print(insuranceValidityFinal);
                              } else {
                                print('date not edited');
                                print(widget.insuranceValidity);
                                setState(() {
                                  var insuranceValidityFinal =
                                      widget.insuranceValidity.toString();
                                  InsuranceValidity = insuranceValidityFinal;
                                  print(InsuranceValidity.runtimeType);
                                  print(InsuranceValidity);
                                  print(insuranceValidityFinal);
                                });
                              }
                              // print("TTTTTT");
                              print(widget.vehicleCurrentDeviceId);
                              dynamic deviceIdFinal;
                              if (vehicleNameselected?.id != '' &&
                                  vehicleNameselected?.id != null) {
                                // print("TTTTTT");
                                print(widget.deviceId);
                                var deviceIdFinal2 = vehicleNameselected?.id;
                                deviceIdFinal = deviceIdFinal2;
                                print('device id edited$deviceIdFinal');
                                print(deviceIdFinal2);
                                print('device id edited');
                                print(deviceIdFinal2);
                              } else {
                                print('not device id edted');
                                var deviceIdFinal2 =
                                    widget.vehicleCurrentDeviceId;
                                print('not device id edted');

                                deviceIdFinal = deviceIdFinal2;
                                print(deviceIdFinal);
                                print(widget.deviceId);

                                print(deviceIdFinal2);
                                print('not device id edted');
                              }
                              print('RRRRR');

                              print(widget.vehicleid);
                              print(
                                  "final device idddddd 25 th is: $deviceIdFinal");
                              print(vehicleName);
                              print(vehicleTypeSubmit);
                              print(licensePlateNumber);
                              print(vin);
                              print(modelName);
                              print(Manufacturer);
                              print(insuranceNumber);
                              print(InsuranceValidity);

                              await editVehicleDetails(
                                  widget.vehicleid,
                                  deviceIdFinal.toString(),
                                  vehicleName,
                                  vehicleTypeSubmit,
                                  licensePlateNumber,
                                  vin,
                                  modelName,
                                  insuranceNumber,
                                  InsuranceValidity
                                  // InsuranceValidity,
                                  );
                              if (statuscode == 200) {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      Future.delayed(Duration(seconds: 5), () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      });
                                      return AlertDialog(
                                        // (context) =>
                                        // AlertDialog(
                                        title: Center(
                                          child: Text(
                                            "Updating your Data",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        content: Container(
                                          // height: 30.h,
                                          // width: 30.w,
                                          margin:
                                              EdgeInsets.fromLTRB(0, 0, 0, 5),
                                          child: Lottie.asset(
                                              'images/123922-update-cogs-loading.json',
                                              // height: ,
                                              fit: BoxFit.fill),
                                        ),
                                        // content: Text('',
                                        //     style: TextStyle(fontSize: 10)),
                                      );
                                    });
                                setState(() {
                                  editcompleted = true;
                                });
                                final vehicledetails =
                                    await getVehiclesDetails();
                                final devicedetails =
                                    await getDeviceCurrentLocation();
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => ManageVehicleScreen(
                                            vehicleList: vehicledetails,
                                            deviceLocationList: devicedetails,
                                          )),
                                );
                                // route() {
                                //   Navigator.pushReplacement(
                                //     context,
                                //     MaterialPageRoute(
                                //         builder: (context) => ManageVehicleScreen(vehicleList: vehicledetails, deviceLocationList: devicedetails,)),
                                //   );
                                //   // Navigator.pop(context);
                                // }
                                // startTimer() async {
                                //   var duration = Duration(seconds: 1);
                                //   return Timer(duration, route);
                                // }
                                // await startTimer();
                              } else {
                                showDialog(
                                    context: context,
                                    builder: (context) {
                                      Future.delayed(Duration(seconds: 5), () {
                                        Navigator.of(context,
                                                rootNavigator: true)
                                            .pop();
                                      });
                                      return AlertDialog(
                                        // (context) =>
                                        // AlertDialog(
                                        title: Center(
                                          child: Text(
                                            "Values are not updated. Some error occured",
                                            style: TextStyle(fontSize: 15),
                                          ),
                                        ),
                                        // content: Text('',
                                        //     style: TextStyle(fontSize: 10)),
                                      );
                                    });
                                print("value not updated  some error occured");
                              }
                            })),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .04,
                    ),
                    CustomButton2(
                      buttontext: "Cancel",
                      onpress: () {
                        Navigator.pop(context);
                      },
                    ),
                    SizedBox(
                      height: MediaQuery.of(context).size.height * .025,
                    ),
                  ],
                ),
              ),

              // color: Color(0xFF0190D7),
            ),
          ],
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
  final dynamic id;
  final String name;
  final dynamic imei;

  VehicleDropNew(this.id, this.name, this.imei);

  @override
  String toString() => name;

  @override
  bool operator ==(Object other) =>
      identical(this, other) || other is VehicleDropNew && other.id == id;

  @override
  int get hashCode => id.hashCode;
}

class ManageVehicles {
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
  var maintenanceNameDueDate;
  var insuranceNumber;
  var insuranceValidity;

  ManageVehicles(
      {required this.deviceIMEI,
      required this.VehicleModel,
      required this.LastReportedTime,
      required this.VehicleName,
      required this.VehicleType,
      required this.manufacturer,
      required this.VIN,
      required this.VehicleLicensePlate,
      required this.insuranceNumber,
      required this.maintenanceNameDueDate,
      required this.vehicleMovementStatus,
      required this.vehicleStatus,
      required this.insuranceValidity});
}

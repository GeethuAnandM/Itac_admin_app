// import 'dart:async';
// import 'package:admin_app/screens/sidebar.dart';
// import 'package:dio/dio.dart';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:intl/intl.dart';
// import 'package:lottie/lottie.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '/screens/themes.dart';
// import 'package:flutter/material.dart';
// import 'custom_widget.dart';
// import 'managevehiclescreen.dart';
//
// class EditVehicleScreen extends StatefulWidget {
//   EditVehicleScreen({
//     required this.vehicleCurrentDeviceId,
//     required this.deviceId, required this.getVehicleTypes,
//     required this.data, required this.vehicleTypeId,
//     required this.vehicleid, required this.deviceName,
//     required this.vehicleName,required this.vehicleType,required this.insuranceValidity,required this.maintenanceDueDate,
//     required this.insuranceNumber,required this.VehicleModel,required this.manufacturer,required this.deviceIMEI,
//     required this.maintenanceName, required this.vehicleLicensePlate, required this.vin
//
//
//   });
//
//   var vehicleCurrentDeviceId;
//   var getVehicleTypes=[];
//   var deviceId=[];
//   List<dynamic> data=[];
//   var vehicleid;
//   var vehicleName;
//   var vehicleType;
//   var vehicleTypeId;
//   var vehicleLicensePlate;
//   var vin;
//   var deviceIMEI;
//   var manufacturer;
//   var VehicleModel;
//   var insuranceNumber;
//   var insuranceValidity;
//   var maintenanceName;
//   var maintenanceDueDate;
//   var deviceName;
//
//   @override
//   State<EditVehicleScreen> createState() => _EditVehicleScreenState();
// }
//
// class _EditVehicleScreenState extends State<EditVehicleScreen> {
//   bool _isObscure = true;
//   bool _isObscure2 = true;
//
//
//
//   List<ManageVehicles> TotalVehicle = [
//   ];
//   var submitbutton= false;
//   var errormessage='';
//   var vehicleadded= false;
//   var statuscode;
//
//
//   Future<dynamic>editVehicleDetails(var vehicleId, deviceid,
//       vehicleName,
//       vehicleType, licensePlateNumber,
//       vin, modelName, insuranceNumber, insuranceValidity ) async {
//     setState(() {
//       submitbutton= true;
//     });
//     final prefs = await SharedPreferences.getInstance();
//
//     var userId= prefs.getString("user_id");
//     print('FFFFFFFF');
//     print(insuranceValidity);
//     print(vehicleType);
//     // print("all device ids from getDeviceCurrentLocation: ${allids}");
//     var data=
//     {"vehicleId": vehicleId,
//       "vehicleName": vehicleName,
//       "licensePlate":licensePlateNumber,
//       "model": modelName ,
//       "vehicleTypeId": vehicleType,
//       "vin": vin,
//       "deviceId": deviceid,
//       "orgId": 1,
//       "insurances":
//       [{
//         "insuranceName": insuranceNumber,
//         "insuranceExpiry": insuranceValidity}]
//     };
//     // {
//     //   "insurances": [
//     //     {
//     //       "insuranceName": insuranceNumber,
//     //       "insuranceExpiry": insuranceValidity
//     //     }
//     //   ],
//     //   "vehicleId": vehicleId,
//     //   "vehicleName": vehicleName,
//     //   "vehicleTypeId": vehicleType,
//     //   "orgId": 1,
//     //   // userId,
//     //   "licensePlate": licensePlateNumber,
//     //   "vin": vin,
//     //   "model": modelName
//     // };
//     final url2 = "http://13.233.175.113:11018/api/update-vehicle";
//     var vehLocationList=[];
//     try{
//       print("in try section");
//       var dio = Dio();
//       print('FFFFFFFF');
//       final response= await dio.put(url2,data: data);
//       print('BBBBBBBBBB');
//
//       print("Response is:$response");
//       print(response.statusCode);
//       print(response.data);
//       print(response.statusCode);
//       // vehLocationList =  response.data;
//       // await startTimer();
//       print("in get getDeviceCurrentLocation");
//       // print(": ${vehLocationList}");
//       setState(() {
//         // submitbutton= false;
//         statuscode= response.statusCode;
//         errormessage= "Data added Succesfully";
//         vehicleadded= true;
//       });
//       return vehLocationList;
//     }
//     catch(e){
//       print(e);
//       print("some error occured");
//       // await startTimer();
//
//       setState(() {
//         submitbutton= false;
//         errormessage= "Please verify all the fields before submitting";
//       });
//     }
//   }
//
//   final TextEditingController vehicleNameController = TextEditingController();
//   final TextEditingController vehicleTypeController = TextEditingController();
//   final  licensePlateController = TextEditingController();
//   final  vinController = TextEditingController();
//   final  deviceIMEIController = TextEditingController();
//   final  manufacturerController = TextEditingController();
//   final  modelNameController = TextEditingController();
//   final  insuranceNumberController = TextEditingController();
//   final  insuranceValidityController = TextEditingController();
//   final  maintenanceNameController = TextEditingController();
//   final  maintenanceDueDateController = TextEditingController();
//
//
//   Future<List<VehicleDrop>> filterdata(filter) async {
//     var res =
//     totDevices.where((element) => element.name.contains(filter)).toList();
//     return res;
//   }
//    VehicleDrop? vehicleNameselected;
//   List<VehicleDrop> totDevices = [];
//
//   List <Widget> AddDevices(){
//     for(var i=0; i < widget.deviceId.length; i++){
//       print("devices id are:${widget.deviceId[i]['id']}");
//       totDevices.add(
//           VehicleDrop( widget.deviceId[i]['id'],widget.deviceId[i]['name'], )
//       );
//     }
//     print("devices added to the class is:${totDevices}");
//     List<Widget> Demo = [];
//     return  Demo;
//   }
//
//
//   var totVehicleList=[];
//
//   var vehLocationList = [];
//   List<dynamic> allids=[];
//   var dio = Dio();
//   var offlineVehicles = 0;
//   var onlineVehicles =0;
//   var loader= false;
//   Future<List<dynamic>> getVehiclesDetails() async {
//     setState(() {
//       loader= true;
//     });
//     var username = "439";
//     final url = "http://13.233.175.113:11018/api/list-vehicles/$username";
//     //show error message try catch
//     var dio = Dio();
//     try{
//       final response = await dio.get(url);
//       totVehicleList = response.data;
//       allids = [];
//       for (var i in totVehicleList) {
//         if (i['deviceId'] != null && i['deviceId'] != "") {
//           allids.add(i['deviceId']);
//         }
//         // print(allids);
//       }
//     }
//     catch (e){
//       print(e);
//       print("Some error occured");
//     }
//
//     print('length of total vehicle list: ${totVehicleList.length}');
//     print("inside getvehiclesdetails: ${totVehicleList} ");
//     return totVehicleList;
//     // newList = [response.data, newList2];
//   }
//
//
//   Future<List<dynamic>>getDeviceCurrentLocation() async {
//     // print("all device ids from getDeviceCurrentLocation: ${allids}");
//     var data= {
//       "deviceIds": allids
//     };
//     final url2 = "http://13.233.175.113:11019/location/getDeviceCurrentLocation";
//     try{
//       final response= await dio.post(url2,data: data);
//       vehLocationList = await response.data;
//       print("in get getDeviceCurrentLocation");
//       setState(() {
//         loader= false;
//         editcompleted= false;
//       });
//     }
//     catch (e){
//       print(e);
//       setState(() {
//         loader= false;
//       });
//       print("Some error occured");
//     }
//     print("online count: ${onlineVehicles}");
//     return vehLocationList;
//   }
//   GlobalKey<ScaffoldState> _key = GlobalKey();
//
//   Widget _icon(IconData icon) {
//     return Container(
//       padding: const EdgeInsets.all(10),
//       decoration: const BoxDecoration(
//         borderRadius: const BorderRadius.all(const Radius.circular(13)),
//         // color: commonTextStyle,
//       ),
//       child: InkWell(
//         onTap: () {
//           _key.currentState?.openDrawer();
//         },
//         child: Icon(
//           icon,
//           size: 30,
//         ),
//       ),
//     );
//   }
//
//   Widget _appBar() {
//     return Container(
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: <Widget>[
//           RotatedBox(
//             quarterTurns: 4,
//             child: _icon(
//               Icons.menu,
//               // color: blueColor,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//
// var vehicleType;
//   var deviceIdSelected;
//   var editcompleted;
//   var insuranceValiditySelected;
//
//   @override
//   void initState() {
//         () async {
//           // VehicleDrop vehicleNameselected;
//     await AddDevices();
//       // await gettrips();
//     }();
//     super.initState();
//   }
//
//
//   @override
//   void setState(fn) {
//     if(mounted) {
//       super.setState(fn);
//     }
//   }
//   Widget build(BuildContext context) {
//     List<Widget> Addvehicles(){
//       print(widget.data.length);
//       print(widget.data);
//       print(widget.vehicleid);
//       // print(widget.data[0]['vehicleName']);
//       print('DDDDDDDDDDDD');
//       for(var i = 0; i < widget.data.length; i++){
//         if(widget.data[i]['vehicleId']==widget.vehicleid){
//           TotalVehicle.add(
//               ManageVehicles(
//                   deviceIMEI: widget.data[i]['vehicleName'],
//                   VehicleModel: widget.data[i]['model'],
//                   LastReportedTime:widget.data[i]['Notdatetime'],
//                   VehicleName: widget.data[i]['vehicleName'],
//                   VehicleType: widget.data[i]['vehicleTypeName'],
//                   manufacturer: widget.data[i]['deviceName'],
//                   VIN: widget.data[i]['vin'],
//                   VehicleLicensePlate: widget.data[i]['licensePlate'],
//                   insuranceNumber: widget.data[i]['insurances'][0]['insuranceName'],
//                   maintenanceNameDueDate: null,
//                   vehicleMovementStatus: widget.data[i]['vehicleStatus'],
//                   vehicleStatus: widget.data[i]['vehicleStatus'],
//                   insuranceValidity: widget.data[i]['insurances'][0]['insuranceExpiry']
//               )
//           );
//         }
//         else {
//           print('all datas are added ');
//         }
//       }
//
//       List<Widget> Demo=[];
//       return Demo;
//     }
//     final  loginIdController = TextEditingController();
//     final  vehiclenameController = TextEditingController();
//     final  confirmpasswordController = TextEditingController();
//     print(widget.data.length);
//     print(TotalVehicle.length);
//     Addvehicles();
//     double iconSize= 35;
//
//     return Scaffold(
//         key: _key,
//         drawer: const NavBar(),
//         appBar: PreferredSize(
//             preferredSize: const Size.fromHeight(60.0),
//             child: AppBar(
//               centerTitle: true,
//               leading: Padding(
//                   padding: const EdgeInsets.only(top: 15), child: _appBar()),
//               title: const Padding(
//                   padding: EdgeInsets.only(top: 20),
//                   child: Text("Edit Vehicles")),
//               elevation: 0,
//             )),
//         body: SingleChildScrollView(
//           child: Column(
//             // mainAxisAlignment: MainAxisAlignment.center,
//             // crossAxisAlignment: CrossAxisAlignment.center,
//             children: [
//               Center(
//                 child:
//                 Container(
//                   // margin: EdgeInsets.all(5),
//                   // height: 300,
//                   //   width: 300,
//                     child: Lottie.asset('images/106415-vehicles.json',height: 130,  fit: BoxFit.cover)),
//               ),
//               Container(
//                 margin: EdgeInsets.fromLTRB(0, 0, 0, 0),
//                 // height: MediaQuery.of(context).size.height * .865,
//                 // width: MediaQuery.of(context).size.width * .96,
//                 padding: EdgeInsets.fromLTRB(10, 10, 10, 20),
//                 decoration: BoxDecoration(
//                   gradient: LinearGradient(
//                       begin: Alignment.topCenter,
//                       end: Alignment.bottomRight,
//                       colors: [
//                         Colors.white,
//                         Colors.white70
//                       ]),
//                   // color:
//                   // // Colors.white,
//                   // Color(0xFF2196F3),
//                   borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
//                   // borderRadius: BorderRadius.circular(10),
//                   boxShadow: [
//                     BoxShadow(
//                       offset: Offset(0, 1),
//                       blurRadius: 4,
//                       color: Colors.black.withOpacity(0.2),
//                     ),
//                   ],
//                 ),
//                 child: Center(
//                   child: Column(
//                     // mainAxisAlignment: MainAxisAlignment.start,
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       SizedBox(
//                         height: MediaQuery.of(context).size.height * .02,
//                       ),
//                       Center(
//                         child: Text("Edit Vehicle",
//                           // style: blueColouredTextStyle,
//                         ),
//                       ),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .06 ,
//                       ),
//                       Row(
//                         children: [
//                           Container(
//                             child: Image.asset(
//                               'images/caricontransparent.png',
//                               width: 35,
//                               height: 35,
//                               fit: BoxFit.fill,
//                             ),
//                             decoration: BoxDecoration(
//                                 color: blueColor,
//                                 borderRadius: BorderRadius.all(Radius.circular(5))
//                             ),
//                           ),
//                           Expanded(
//                             child: Container(
//                               height: MediaQuery.of(context).size.height * .07 ,
//                               margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                               padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                               // width: MediaQuery.of(context).size.width * .8 ,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.all(Radius.circular(10))
//                               ),
//                               child: Center(
//                                 child: TextFormField(
//                                   controller: vehicleNameController.text == '' ?
//                                   TextEditingController(text: widget.vehicleName.toString())
//                                       : vehicleNameController,
//                                   onChanged: (text) {
//                                     vehicleNameController.text = text;
//                                     print('vehicle name is:${vehiclenameController.text}');
//                                   },
//                                   autovalidateMode:AutovalidateMode.onUserInteraction,
//                                   keyboardType: TextInputType.text,
//                                   autofocus: false,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'Vehicle name can not be empty';
//                                     }
//                                     else {
//                                       return null;
//                                     }
//                                   },
//                                   decoration: InputDecoration(
//                                     border: new OutlineInputBorder(
//                                       borderSide:
//                                       new BorderSide(color: Colors.black),
//                                       borderRadius: BorderRadius.circular(5.0),
//                                     ),
//                                     label: Row(
//                                       children: [
//                                         const Text('*', style: TextStyle(color: Colors.red)),
//                                         Padding(
//                                           padding: EdgeInsets.all(3.0),
//                                         ),
//                                         Text("Vehicle Name")
//                                       ],
//                                     ),
//                                     hintStyle: TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w400),
//                                     errorBorder: UnderlineInputBorder(
//                                       borderRadius: BorderRadius.circular(7.0),
//                                       borderSide: BorderSide(
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .02 ,
//                       ),
//
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_view_day_rounded,
//                             size: iconSize,
//                             color: blueColor,
//                           ),
//                           Expanded(
//                             child: Container(
//                               margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                               padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                               // width: MediaQuery.of(context).size.width * .8 ,
//                               child:
//                               DropdownButtonFormField<dynamic>(
//                                 hint: Text(widget.vehicleType, style: TextStyle(fontSize: 12),),
//                                 value: vehicleType,
//                                 elevation: 16,
//                                 icon: const Icon(Icons.arrow_drop_down),
//                                 isDense: true,
//                                 decoration: InputDecoration(
//                                   label: Row(
//                                     children: [
//                                       const Text('*', style: TextStyle(color: Colors.red)),
//                                       Padding(
//                                         padding: EdgeInsets.all(3.0),
//                                       ),
//                                       Text("Select Vehicle Type")
//                                     ],
//                                   ),
//                                   // labelText: 'Choose a Category',
//                                   border: OutlineInputBorder(
//                                     borderRadius: BorderRadius.circular(8),
//                                     // borderSide: const BorderSide(color: Colors.green),
//                                   ),
//
//                                 ),
//                                 onChanged: (dynamic newValue) {
//                                   // print(vehicleTypes.length);
//                                   // if (newValue != null) {
//                                   setState(() {
//                                     vehicleType = newValue;
//                                     print(" vehicle type is:${vehicleType}");
//                                     print(newValue);
//                                   });
//                                   // }
//                                 },
//                                 items: widget.getVehicleTypes.map((dynamic value) {
//                                   return DropdownMenuItem<dynamic>(
//                                     value: value['vehicleTypeId'],
//                                     child: Text(value['name'].toString()),
//                                   );
//                                 }).toList(),
//                               ),
//                             ),
//                           ),
//                           // Container(
//                           //   height: MediaQuery.of(context).size.height * .07 ,
//                           //   margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                           //   padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                           //   width: MediaQuery.of(context).size.width * .8 ,
//                           //   decoration: BoxDecoration(
//                           //       borderRadius: BorderRadius.all(Radius.circular(10))
//                           //   ),
//                           //   child: Center(
//                           //     child: TextFormField(
//                           //       controller: vehicleTypeController.text == ""?
//                           //       TextEditingController(text: widget.vehicleType.toString(),) :
//                           //       vehicleTypeController,
//                           //       onChanged: (text) {
//                           //         vehicleTypeController.text = text;
//                           //         print('dmeo contit ffff ${vehicleTypeController.text}');
//                           //       },
//                           //       // autovalidateMode:AutovalidateMode.onUserInteraction,
//                           //       keyboardType: TextInputType.text,
//                           //       autofocus: false,
//                           //       validator: (value) {
//                           //         if (value!.isEmpty) {
//                           //           return 'Enter Your Password';
//                           //         } else if (value.length < 8) {
//                           //           return "Your Password must contain 8 characters atleast";
//                           //         } else {
//                           //           return null;
//                           //         }
//                           //       },
//                           //
//                           //       decoration: InputDecoration(
//                           //         // suffixIcon: IconButton(
//                           //         //   icon: Icon(_isObscure?
//                           //         //   Icons.visibility : Icons.visibility_off, size: 20,
//                           //         //   ), onPressed: () {
//                           //         //   setState(() {
//                           //         //     _isObscure=!_isObscure;
//                           //         //   });
//                           //         // },
//                           //         // ),
//                           //         // hintText: "New Password",
//                           //         border: new OutlineInputBorder(
//                           //           borderSide:
//                           //           new BorderSide(color: Colors.black),
//                           //           borderRadius: BorderRadius.circular(5.0),
//                           //         ),
//                           //         hintStyle: TextStyle(
//                           //             fontSize: 15,
//                           //             color: Colors.black,
//                           //             fontWeight: FontWeight.w400),
//                           //         errorBorder: UnderlineInputBorder(
//                           //           borderRadius: BorderRadius.circular(7.0),
//                           //           borderSide: BorderSide(
//                           //             color: Colors.red,
//                           //           ),
//                           //         ),
//                           //       ),
//                           //     ),
//                           //   ),
//                           // ),
//                         ],
//                       ),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .02 ,
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.contact_mail_rounded,
//                             size: iconSize,
//                             color: blueColor,
//                           ),
//                           Expanded(
//                             child: Container(
//                               height: MediaQuery.of(context).size.height * .07 ,
//                               margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                               padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                               // width: MediaQuery.of(context).size.width * .8 ,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.all(Radius.circular(10))
//                               ),
//                               child: Center(
//                                 child: TextFormField(
//                                   controller: licensePlateController.text == ""?
//                                   TextEditingController(text: widget.vehicleLicensePlate.toString()) :
//                                   licensePlateController,
//                                   onChanged: (text) {
//                                     licensePlateController.text= text;
//                                     print('${licensePlateController.text}');
//                                   },
//                                   autovalidateMode:AutovalidateMode.onUserInteraction,
//                                   keyboardType: TextInputType.streetAddress,
//                                   autofocus: false,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'License Plate Number can not be empty';
//                                     } else {
//                                       return null;
//                                     }
//                                   },
//
//                                   decoration: InputDecoration(
//                                     border: new OutlineInputBorder(
//                                       borderSide:
//                                       new BorderSide(color: Colors.black),
//                                       borderRadius: BorderRadius.circular(5.0),
//                                     ),
//                                     label: Row(
//                                       children: [
//                                         const Text('*', style: TextStyle(color: offlineColor)),
//                                         Padding(
//                                           padding: EdgeInsets.all(3.0),
//                                         ),
//                                         Text("License Plate Number")
//                                       ],
//                                     ),
//                                     hintStyle: TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w400),
//                                     errorBorder: UnderlineInputBorder(
//                                       borderRadius: BorderRadius.circular(7.0),
//                                       borderSide: BorderSide(
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .02 ,
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.confirmation_num,
//                             size: iconSize,
//                             color: blueColor,
//                           ),
//                           Expanded(
//                             child: Container(
//                               height: MediaQuery.of(context).size.height * .07 ,
//                               margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                               padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                               // width: MediaQuery.of(context).size.width * .8 ,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.all(Radius.circular(10))
//                               ),
//                               child: Center(
//                                 child: TextFormField(
//                                   controller: vinController.text== "" ?
//                                   TextEditingController(text: widget.vin.toString()) :
//                                   vinController,
//                                   onChanged: (text) {
//                                     vinController.text= text;
//                                     print('dmeo contit ffff ${vinController.text}');
//                                   },
//                                   // autovalidateMode:AutovalidateMode.onUserInteraction,
//                                   keyboardType: TextInputType.text,
//                                   autofocus: false,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'Enter Your Password';
//                                     } else if (value.length < 8) {
//                                       return "Your Password must contain 8 characters atleast";
//                                     } else {
//                                       return null;
//                                     }
//                                   },
//
//                                   decoration: InputDecoration(
//                                     border: new OutlineInputBorder(
//                                       borderSide:
//                                       new BorderSide(color: Colors.black),
//                                       borderRadius: BorderRadius.circular(5.0),
//                                     ),
//                                     label: Row(
//                                       children: [
//                                         const Text('*', style: TextStyle(color: offlineColor)),
//                                         Padding(
//                                           padding: EdgeInsets.all(3.0),
//                                         ),
//                                         Text("VIN")
//                                       ],
//                                     ),
//                                     hintStyle: TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w400),
//                                     errorBorder: UnderlineInputBorder(
//                                       borderRadius: BorderRadius.circular(7.0),
//                                       borderSide: BorderSide(
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .02 ,
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.gps_fixed,
//                             size: iconSize,
//                             color: blueColor,
//                           ),
//                           Expanded(
//                             child: Container(
//                                 margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                                 padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                                 // width: MediaQuery.of(context).size.width * .8 ,
//                                 child:
//                                 DropdownSearch<VehicleDrop>(
//                                   popupProps: PopupProps.bottomSheet(
//                                       showSearchBox: true
//                                   ),
//                                   dropdownDecoratorProps: DropDownDecoratorProps(
//                                     dropdownSearchDecoration: InputDecoration(
//                                       labelText: widget.deviceName != null ? widget.deviceName: "Select a Device2",
//                                       hintText: "Select a Device",
//                                       border: new OutlineInputBorder(
//                                         borderSide:
//                                         new BorderSide(color: Colors.black),
//                                         borderRadius: BorderRadius.circular(5.0),
//                                       ),
//                                     ),
//                                   ),
//
//                                   items: totDevices,
//                                   asyncItems: (String filter) =>filterdata(filter),
//                                   onChanged: (VehicleDrop? data) async {
//                                     if (data != null) {
//                                       setState(() {
//                                         // print("newvalue${vehicleNameselected!.id}");
//                                         vehicleNameselected = data;
//                                         print("newvalue${vehicleNameselected?.id}");
//
//                                         // EasyLoading.show(status: "Loading");
//                                       });
//                                       // await getdata();
//
//                                     }
//                                   },
//                                 )
//
//
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .02 ,
//                       ),
//                       // Row(
//                       //   children: [
//                       //     Icon(
//                       //       Icons.gps_fixed,
//                       //       size: iconSize,
//                       //       color: blueColor,
//                       //     ),
//                       //     Expanded(
//                       //       child: Container(
//                       //         margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                       //         padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                       //         // width: MediaQuery.of(context).size.width * .8 ,
//                       //         child: DropdownButtonFormField<dynamic>(
//                       //           hint: Text(widget.deviceName.toString(), style: TextStyle(fontSize: 12),),
//                       //           value: deviceIdSelected,
//                       //           elevation: 16,
//                       //           icon: const Icon(Icons.arrow_drop_down),
//                       //           isDense: true,
//                       //           decoration: InputDecoration(
//                       //             label: Row(
//                       //               children: [
//                       //                 const Text('*', style: TextStyle(color: Colors.red)),
//                       //                 Padding(
//                       //                   padding: EdgeInsets.all(3.0),
//                       //                 ),
//                       //                 Text("Select a Device")
//                       //               ],
//                       //             ),
//                       //             // labelText: 'Choose a Category',
//                       //             border: OutlineInputBorder(
//                       //               borderRadius: BorderRadius.circular(8),
//                       //               // borderSide: const BorderSide(color: Colors.green),
//                       //             ),
//                       //
//                       //           ),
//                       //           onChanged: (dynamic newValue) {
//                       //             // print(vehicleTypes.length);
//                       //             // if (newValue != null) {
//                       //             setState(() {
//                       //               deviceIdSelected = newValue;
//                       //               print('GGGGGGGGGGG');
//                       //               print(deviceIdSelected);
//                       //               print(newValue);
//                       //             });
//                       //             // }
//                       //           },
//                       //           items: widget.deviceId.map((dynamic value) {
//                       //             // print(value);
//                       //             return DropdownMenuItem<dynamic>(
//                       //               value: value['id'],
//                       //               child: Text(value['name'].toString()),
//                       //             );
//                       //           }).toList(),
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                       // SizedBox(
//                       //   height:  MediaQuery.of(context).size.height * .02 ,
//                       // ),
//                       // Row(
//                       //   children: [
//                       //     Icon(
//                       //       Icons.perm_device_information_outlined,
//                       //       size: iconSize,
//                       //       color: blueColor,
//                       //     ),
//                       //     Container(
//                       //       height: MediaQuery.of(context).size.height * .07 ,
//                       //       margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                       //       padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                       //       width: MediaQuery.of(context).size.width * .8 ,
//                       //       decoration: BoxDecoration(
//                       //           borderRadius: BorderRadius.all(Radius.circular(10))
//                       //       ),
//                       //       child: Center(
//                       //         child: TextFormField(
//                       //           controller: deviceIMEIController.text == ''?
//                       //           TextEditingController(text: widget.deviceIMEI.toString(),) :
//                       //           deviceIMEIController,
//                       //           onChanged: (text) {
//                       //             deviceIMEIController.text = text;
//                       //             print('dmeo contit ffff ${deviceIMEIController.text}');
//                       //           },
//                       //           // autovalidateMode:AutovalidateMode.onUserInteraction,
//                       //           keyboardType: TextInputType.text,
//                       //           autofocus: false,
//                       //           validator: (value) {
//                       //             if (value!.isEmpty) {
//                       //               return 'Enter Your Password';
//                       //             } else if (value.length < 8) {
//                       //               return "Your Password must contain 8 characters atleast";
//                       //             } else {
//                       //               return null;
//                       //             }
//                       //           },
//                       //
//                       //           decoration: InputDecoration(
//                       //             border: new OutlineInputBorder(
//                       //               borderSide:
//                       //               new BorderSide(color: Colors.black),
//                       //               borderRadius: BorderRadius.circular(5.0),
//                       //             ),
//                       //             label: Row(
//                       //               children: [
//                       //                 // const Text('*', style: TextStyle(color: offlineColor)),
//                       //                 Padding(
//                       //                   padding: EdgeInsets.all(3.0),
//                       //                 ),
//                       //                 Text("Device IMEI Number")
//                       //               ],
//                       //             ),
//                       //             hintStyle: TextStyle(
//                       //                 fontSize: 15,
//                       //                 color: Colors.black,
//                       //                 fontWeight: FontWeight.w400),
//                       //             errorBorder: UnderlineInputBorder(
//                       //               borderRadius: BorderRadius.circular(7.0),
//                       //               borderSide: BorderSide(
//                       //                 color: Colors.red,
//                       //               ),
//                       //             ),
//                       //           ),
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                       // SizedBox(
//                       //   height:  MediaQuery.of(context).size.height * .02 ,
//                       // ),
//                       // Row(
//                       //   children: [
//                       //     Icon(
//                       //       Icons.precision_manufacturing,
//                       //       size: iconSize,
//                       //       color: blueColor,
//                       //     ),
//                       //     Container(
//                       //       height: MediaQuery.of(context).size.height * .07 ,
//                       //       margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                       //       padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                       //       width: MediaQuery.of(context).size.width * .8 ,
//                       //       decoration: BoxDecoration(
//                       //           borderRadius: BorderRadius.all(Radius.circular(10))
//                       //       ),
//                       //       child: Center(
//                       //         child: TextFormField(
//                       //           controller: manufacturerController.text == ''?
//                       //           TextEditingController(text: widget.manufacturer.toString()) :
//                       //           manufacturerController,
//                       //           onChanged: (text) {
//                       //             manufacturerController.text = text;
//                       //             print('dmeo contit ffff ${manufacturerController.text}');
//                       //           },
//                       //           // autovalidateMode:AutovalidateMode.onUserInteraction,
//                       //           keyboardType: TextInputType.text,
//                       //           autofocus: false,
//                       //           validator: (value) {
//                       //             if (value!.isEmpty) {
//                       //               return 'Enter Your Password';
//                       //             } else if (value.length < 8) {
//                       //               return "Your Password must contain 8 characters atleast";
//                       //             } else {
//                       //               return null;
//                       //             }
//                       //           },
//                       //
//                       //           decoration: InputDecoration(
//                       //             label: Row(
//                       //               children: [
//                       //                 const Text('*', style: TextStyle(color: offlineColor)),
//                       //                 Padding(
//                       //                   padding: EdgeInsets.all(3.0),
//                       //                 ),
//                       //                 Text("Manufacturer")
//                       //               ],
//                       //             ),
//                       //             border: new OutlineInputBorder(
//                       //               borderSide:
//                       //               new BorderSide(color: Colors.black),
//                       //               borderRadius: BorderRadius.circular(5.0),
//                       //             ),
//                       //             hintStyle: TextStyle(
//                       //                 fontSize: 15,
//                       //                 color: Colors.black,
//                       //                 fontWeight: FontWeight.w400),
//                       //             errorBorder: UnderlineInputBorder(
//                       //               borderRadius: BorderRadius.circular(7.0),
//                       //               borderSide: BorderSide(
//                       //                 color: Colors.red,
//                       //               ),
//                       //             ),
//                       //           ),
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                       // SizedBox(
//                       //   height:  MediaQuery.of(context).size.height * .02 ,
//                       // ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.call_to_action_rounded,
//                             size: iconSize,
//                             color: blueColor,
//                           ),
//                           Expanded(
//                             child: Container(
//                               height: MediaQuery.of(context).size.height * .07 ,
//                               margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                               padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                               // width: MediaQuery.of(context).size.width * .8 ,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.all(Radius.circular(10))
//                               ),
//                               child: Center(
//                                 child: TextFormField(
//                                   controller: modelNameController.text ==''?
//                                   TextEditingController(text: widget.VehicleModel.toString()) :
//                                   modelNameController,
//                                   onChanged: (text) {
//                                     modelNameController.text = text;
//                                     print('dmeo contit ffff ${modelNameController.text}');
//                                   },
//                                   autovalidateMode:AutovalidateMode.onUserInteraction,
//                                   keyboardType: TextInputType.text,
//                                   autofocus: false,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'Model name can not be empty';
//                                     }  else {
//                                       return null;
//                                     }
//                                   },
//
//                                   decoration: InputDecoration(
//                                     border: new OutlineInputBorder(
//                                       borderSide:
//                                       new BorderSide(color: Colors.black),
//                                       borderRadius: BorderRadius.circular(5.0),
//                                     ),
//                                     label: Row(
//                                       children: [
//                                         const Text('*', style: TextStyle(color: offlineColor)),
//                                         Padding(
//                                           padding: EdgeInsets.all(3.0),
//                                         ),
//                                         Text("Model Name")
//                                       ],
//                                     ),
//                                     hintStyle: TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w400),
//                                     errorBorder: UnderlineInputBorder(
//                                       borderRadius: BorderRadius.circular(7.0),
//                                       borderSide: BorderSide(
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .02 ,
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.verified_user_rounded,
//                             size: iconSize,
//                             color: blueColor,
//                           ),
//                           Expanded(
//                             child: Container(
//                               height: MediaQuery.of(context).size.height * .07 ,
//                               margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                               padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                               // width: MediaQuery.of(context).size.width * .8 ,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.all(Radius.circular(10))
//                               ),
//                               child: Center(
//                                 child: TextFormField(
//                                   controller: insuranceNumberController.text == ""?
//                                   TextEditingController(text: widget.insuranceNumber.toString()):
//                                   insuranceNumberController,
//                                   onChanged: (text) {
//                                     insuranceNumberController.text = text;
//                                     print('dmeo contit ffff ${insuranceNumberController.text}');
//                                   },
//                                   autovalidateMode:AutovalidateMode.onUserInteraction,
//                                   keyboardType: TextInputType.text,
//                                   autofocus: false,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'Insurance Number can not be empty';
//                                     } else {
//                                       return null;
//                                     }
//                                   },
//
//                                   decoration: InputDecoration(
//                                     border: new OutlineInputBorder(
//                                       borderSide:
//                                       new BorderSide(color: Colors.black),
//                                       borderRadius: BorderRadius.circular(5.0),
//                                     ),
//                                     label: Row(
//                                       children: [
//                                         const Text('*', style: TextStyle(color: offlineColor)),
//                                         Padding(
//                                           padding: EdgeInsets.all(3.0),
//                                         ),
//                                         Text("Insurance Number")
//                                       ],
//                                     ),
//                                     hintStyle: TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w400),
//                                     errorBorder: UnderlineInputBorder(
//                                       borderRadius: BorderRadius.circular(7.0),
//                                       borderSide: BorderSide(
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .02 ,
//                       ),
//                       Row(
//                         children: [
//                           Icon(
//                             Icons.calendar_month,
//                             size: iconSize,
//                             color: blueColor,
//                           ),
//                           Expanded(
//                             child: Container(
//                               height: MediaQuery.of(context).size.height * .07 ,
//                               margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                               padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                               // width: MediaQuery.of(context).size.width * .8 ,
//                               decoration: BoxDecoration(
//                                   borderRadius: BorderRadius.all(Radius.circular(10))
//                               ),
//                               child: Center(
//                                 child: TextFormField(
//                                   controller: insuranceValiditySelected == null?
//                                   TextEditingController(text: widget.insuranceValidity.toString()):
//                                   insuranceValidityController,
//                                   onTap: () async {
//                                     final now = DateTime.now();
//
//                                     DateTime? pickedDate = await showDatePicker(
//                                       context: context,
//                                       initialDate: DateTime(now.year, now.month, now.day + 1),
//                                       firstDate: DateTime(now.year, now.month, now.day + 1),
//
//                                       lastDate: DateTime(2060),
//                                     );
//                                     if (pickedDate != null) {
//                                       print("timeStamp:");
//                                       print(pickedDate); //pickedDate output format => 2021-03-10 00:00:00.000
//                                       String formattedDate =
//                                       DateFormat('yyyy-MM-dd')
//                                           .format(pickedDate);
//                                       print(formattedDate);
//                                       setState(() {
//                                         insuranceValiditySelected = formattedDate.toString();
//                                         insuranceValidityController.text= formattedDate.toString();
//                                         print("this is the new insurance validity${insuranceValidityController.text}");
//                                         // insuranceValidityController.text = formattedDate.toString();
//                                         print("this is the ${insuranceValidityController.text}");
//                                       });
//                                     } else {
//                                       print("Insurance Validity is not selected");
//                                     }
//                                   },
//                                   onChanged: (text) {
//                                     setState(() {
//                                       insuranceValidityController.text = text;
//                                     });
//                                     print('insurance validity:${insuranceValidityController.text}');
//                                   },
//                                   // autovalidateMode:AutovalidateMode.onUserInteraction,
//                                   keyboardType: TextInputType.text,
//                                   autofocus: false,
//                                   readOnly: true,
//                                   validator: (value) {
//                                     if (value!.isEmpty) {
//                                       return 'Enter Your Password';
//                                     }else {
//                                       return null;
//                                     }
//                                   },
//                                   decoration: InputDecoration(
//                                     border: new OutlineInputBorder(
//                                       borderSide:
//                                       new BorderSide(color: Colors.black),
//                                       borderRadius: BorderRadius.circular(5.0),
//                                     ),
//                                     label: Row(
//                                       children: [
//                                         const Text('*', style: TextStyle(color: offlineColor)),
//                                         Padding(
//                                           padding: EdgeInsets.all(3.0),
//                                         ),
//                                         Text("Insurance Validity")
//                                       ],
//                                     ),
//                                     hintStyle: TextStyle(
//                                         fontSize: 15,
//                                         color: Colors.black,
//                                         fontWeight: FontWeight.w400),
//                                     errorBorder: UnderlineInputBorder(
//                                       borderRadius: BorderRadius.circular(7.0),
//                                       borderSide: BorderSide(
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ),
//                               ),
//                             ),
//                           ),
//                         ],
//                       ),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .02 ,
//                       ),
//                       // Row(
//                       //   children: [
//                       //     Icon(
//                       //       Icons.settings,
//                       //       size: iconSize,
//                       //       color: blueColor,
//                       //     ),
//                       //     Container(
//                       //       height: MediaQuery.of(context).size.height * .07 ,
//                       //       margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                       //       padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                       //       width: MediaQuery.of(context).size.width * .8 ,
//                       //       decoration: BoxDecoration(
//                       //           borderRadius: BorderRadius.all(Radius.circular(10))
//                       //       ),
//                       //       child: Center(
//                       //         child: TextFormField(
//                       //           controller: maintenanceNameController.text == ''?
//                       //           TextEditingController(text: widget.maintenanceName.toString()):
//                       //           maintenanceNameController,
//                       //           onChanged: (text) {
//                       //             maintenanceNameController.text = text;
//                       //             print('dmeo contit ffff ${maintenanceNameController.text}');
//                       //           },
//                       //           // autovalidateMode:AutovalidateMode.onUserInteraction,
//                       //           keyboardType: TextInputType.text,
//                       //           autofocus: false,
//                       //           validator: (value) {
//                       //             if (value!.isEmpty) {
//                       //               return 'Enter Your Password';
//                       //             } else if (value.length < 8) {
//                       //               return "Your Password must contain 8 characters atleast";
//                       //             } else {
//                       //               return null;
//                       //             }
//                       //           },
//                       //
//                       //           decoration: InputDecoration(
//                       //             border: new OutlineInputBorder(
//                       //               borderSide:
//                       //               new BorderSide(color: Colors.black),
//                       //               borderRadius: BorderRadius.circular(5.0),
//                       //             ),
//                       //             label: Row(
//                       //               children: [
//                       //                 const Text('*', style: TextStyle(color: offlineColor)),
//                       //                 Padding(
//                       //                   padding: EdgeInsets.all(3.0),
//                       //                 ),
//                       //                 Text("Maintenance Name")
//                       //               ],
//                       //             ),
//                       //             hintStyle: TextStyle(
//                       //                 fontSize: 15,
//                       //                 color: Colors.black,
//                       //                 fontWeight: FontWeight.w400),
//                       //             errorBorder: UnderlineInputBorder(
//                       //               borderRadius: BorderRadius.circular(7.0),
//                       //               borderSide: BorderSide(
//                       //                 color: Colors.red,
//                       //               ),
//                       //             ),
//                       //           ),
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                       // SizedBox(
//                       //   height:  MediaQuery.of(context).size.height * .02 ,
//                       // ),
//                       // Row(
//                       //   children: [
//                       //     Icon(
//                       //       Icons.calendar_month,
//                       //       size: iconSize,
//                       //       color: blueColor,
//                       //     ),
//                       //     Container(
//                       //       height: MediaQuery.of(context).size.height * .07 ,
//                       //       margin: EdgeInsets.fromLTRB(8, 0, 3, 0),
//                       //       padding: EdgeInsets.fromLTRB(10, 0, 5, 0),
//                       //       width: MediaQuery.of(context).size.width * .8 ,
//                       //       decoration: BoxDecoration(
//                       //           borderRadius: BorderRadius.all(Radius.circular(10))
//                       //       ),
//                       //       child: Center(
//                       //         child: TextFormField(
//                       //           controller: maintenanceDueDateController.text == ""?
//                       //           TextEditingController(text: widget.maintenanceDueDate.toString()):
//                       //           maintenanceDueDateController,
//                       //           onChanged: (text) {
//                       //             maintenanceDueDateController.text = text;
//                       //             print(' ${maintenanceDueDateController.text}');
//                       //           },
//                       //           // autovalidateMode:AutovalidateMode.onUserInteraction,
//                       //           keyboardType: TextInputType.text,
//                       //           autofocus: false,
//                       //           validator: (value) {
//                       //             if (value!.isEmpty) {
//                       //               return 'Enter Your Password';
//                       //             } else if (value.length < 8) {
//                       //               return "Your Password must contain 8 characters atleast";
//                       //             } else {
//                       //               return null;
//                       //             }
//                       //           },
//                       //
//                       //           decoration: InputDecoration(
//                       //             border: new OutlineInputBorder(
//                       //               borderSide:
//                       //               new BorderSide(color: Colors.black),
//                       //               borderRadius: BorderRadius.circular(5.0),
//                       //             ),
//                       //             label: Row(
//                       //               children: [
//                       //                 const Text('*', style: TextStyle(color: offlineColor)),
//                       //                 Padding(
//                       //                   padding: EdgeInsets.all(3.0),
//                       //                 ),
//                       //                 Text("Maintenance Due Date")
//                       //               ],
//                       //             ),
//                       //             hintStyle: TextStyle(
//                       //                 fontSize: 15,
//                       //                 color: Colors.black,
//                       //                 fontWeight: FontWeight.w400),
//                       //             errorBorder: UnderlineInputBorder(
//                       //               borderRadius: BorderRadius.circular(7.0),
//                       //               borderSide: BorderSide(
//                       //                 color: Colors.red,
//                       //               ),
//                       //             ),
//                       //           ),
//                       //         ),
//                       //       ),
//                       //     ),
//                       //   ],
//                       // ),
//                       errormessage!.toString().isNotEmpty ?
//                       Container(
//                         margin: EdgeInsets.fromLTRB(5, 15, 5, 0),
//                         child: Center(
//                           child: Text(errormessage!,
//                             textAlign: TextAlign.center,
//                             style: TextStyle(color: errormessage == "Data added Succesfully" ? movingColor: offlineColor),
//                           ),
//                         ),
//                       ): Text(''),
//
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .05 ,
//                       ),
//
//                       CustomButton(
//                         // loader: editcompleted == true ?
//                         // CircularProgressIndicator(): null,
//                           buttontext:  "Submit",
//                           onpress: () async {
//
//                             dynamic vehicleName;
//                             if(vehicleNameController.text != ''){
//                               var vehicleName2 = vehicleNameController.text;
//                               vehicleName= vehicleName2;
//                               print(vehicleNameController.text);
//                               print('edited vehicle name');
//                               print(vehicleName2);
//                             }
//                             else{
//                               print('not edted vehicle name');
//                               var vehicleName2 = widget.vehicleName;
//                               vehicleName= vehicleName2;
//                               print(vehicleName2);
//                             }
//
//                             dynamic vehicleTypeSubmit;
//                             if(vehicleType != null && vehicleType != ""){
//                               print(vehicleType);
//                               var vehicleTypeFinal = vehicleType;
//                               vehicleTypeSubmit= vehicleTypeFinal;
//                               print(vehicleType);
//                               print(widget.vehicleTypeId);
//                               print('vtype is:');
//                               print(vehicleTypeFinal);
//                             }
//                             else{
//                               print('vtype not edted');
//                               var vehicleTypeFinal = widget.vehicleTypeId;
//                               vehicleTypeSubmit= vehicleTypeFinal;
//                               print(widget.vehicleTypeId);
//                               print(vehicleTypeFinal);
//                             }
//
//                             dynamic licensePlateNumber;
//                             if(licensePlateController.text != ''){
//                               var licensePlateNumberFinal = licensePlateController.text;
//                               licensePlateNumber= licensePlateNumberFinal;
//                               print('edited');
//                               print(licensePlateNumberFinal);
//                             }
//                             else{
//                               print('not edted');
//                               var licensePlateNumberFinal = widget.vehicleLicensePlate;
//                               licensePlateNumber= licensePlateNumberFinal;
//                               print(licensePlateNumberFinal);
//                             }
//
//
//                             dynamic vin;
//                             if(vinController.text != ''){
//                               var vinFinal = vinController.text;
//                               vin= vinFinal;
//                               print('edited');
//                               print(vinFinal);
//                             }
//                             else{
//                               print('not edted');
//                               var vinFinal = widget.vin;
//                               vin= vinFinal;
//                               print(vinFinal);
//                             }
//
//
//
//                             dynamic modelName;
//                             if(modelNameController.text != ''){
//                               var modelNameFinal = modelNameController.text;
//                               modelName= modelNameFinal;
//                               print('edited');
//                               print(modelNameFinal);
//                             }
//                             else{
//                               print('not edted');
//                               var modelNameFinal = widget.VehicleModel;
//                               modelName= modelNameFinal;
//                               print(modelNameFinal);
//                             }
//
//
//                             dynamic insuranceNumber;
//                             if(insuranceNumberController.text != ''){
//                               var insuranceNumberFinal = insuranceNumberController.text;
//                               insuranceNumber= insuranceNumberFinal;
//                               print('edited');
//                               print(insuranceNumberFinal);
//                             }
//                             else{
//                               print('not edted');
//                               var insuranceNumberFinal = widget.insuranceNumber;
//                               insuranceNumber= insuranceNumberFinal;
//                               print(insuranceNumberFinal);
//                             }
//
//
//                             dynamic InsuranceValidity;
//                             print("insurance validity is:$insuranceValiditySelected");
//                             if(insuranceValiditySelected != null){
//                               print(insuranceValiditySelected);
//                               var insuranceValidityFinal = insuranceValiditySelected;
//                               InsuranceValidity= insuranceValidityFinal;
//                               print(InsuranceValidity.runtimeType);
//                               print(InsuranceValidity);
//                               print('date edited');
//                               print(insuranceValidityFinal);
//                             }
//                             else{
//                               print('date not edited');
//                               print(widget.insuranceValidity);
//                               setState(() {
//                                 var insuranceValidityFinal = widget.insuranceValidity.toString();
//                                 InsuranceValidity= insuranceValidityFinal;
//                                 print(InsuranceValidity.runtimeType);
//                                 print(InsuranceValidity);
//                                 print(insuranceValidityFinal);
//                               });
//
//                             }
//                             // print("TTTTTT");
//                             print(widget.vehicleCurrentDeviceId);
//                             dynamic deviceIdFinal;
//                             if(vehicleNameselected?.id != '' && vehicleNameselected?.id != null){
//                               // print("TTTTTT");
//                               print(widget.deviceId);
//                               var deviceIdFinal2 = vehicleNameselected?.id;
//                               deviceIdFinal= deviceIdFinal2;
//                               print('device id edited$deviceIdFinal');
//                               print(deviceIdFinal2);
//                               print('device id edited');
//                               print(deviceIdFinal2);
//                             }
//                             else{
//                               print('not device id edted');
//                               var deviceIdFinal2 = widget.vehicleCurrentDeviceId;
//                               print('not device id edted');
//
//                               deviceIdFinal= deviceIdFinal2;
//                               print(deviceIdFinal);
//                               print(widget.deviceId);
//
//                               print(deviceIdFinal2);
//                               print('not device id edted');
//
//                             }
//                             print('RRRRR');
//
//                             print(widget.vehicleid);
//                             print(deviceIdFinal);
//                             print(vehicleName);
//                             print(vehicleTypeSubmit);
//                             print(licensePlateNumber);
//                             print(vin);
//                             print(modelName);
//                             print(insuranceNumber);
//                             print(InsuranceValidity);
//
//                             await editVehicleDetails(widget.vehicleid,deviceIdFinal,
//                                 vehicleName,vehicleTypeSubmit, licensePlateNumber,
//                                 vin, modelName, insuranceNumber, InsuranceValidity
//                               // InsuranceValidity,
//                             );
//                             if (statuscode == 200){
//                               showDialog(
//                                   context: context,
//                                   builder:
//                                       (context) {
//                                     Future.delayed(
//                                         Duration(
//                                             seconds: 5), () {
//                                       Navigator.of(context, rootNavigator: true).pop();
//                                     }
//                                     );
//                                     return
//                                       AlertDialog(
//                                         // (context) =>
//                                         // AlertDialog(
//                                         title: Center(
//                                           child: Text("Updating your Data",
//                                             style: TextStyle(
//                                                 fontSize: 15),
//                                           ),
//                                         ),
//                                         content: Container(
//                                           // height: 30.h,
//                                           // width: 30.w,
//                                           margin: EdgeInsets.fromLTRB(0, 0, 0, 5),
//                                           child: Lottie.asset('images/123922-update-cogs-loading.json',
//                                               // height: ,
//                                               fit: BoxFit.fill
//                                           ),
//                                         ),
//                                         // content: Text('',
//                                         //     style: TextStyle(fontSize: 10)),
//
//                                       );
//
//                                   }
//                               );
//                               setState(() {
//                                 editcompleted= true;
//                               });
//                               final vehicledetails= await getVehiclesDetails();
//                               final devicedetails= await getDeviceCurrentLocation();
//                               Navigator.pushReplacement(
//                                 context,
//                                 MaterialPageRoute(
//                                     builder: (context) => ManageVehicleScreen(vehicleList: vehicledetails, deviceLocationList: devicedetails,)),
//                               );
//                               // route() {
//                               //   Navigator.pushReplacement(
//                               //     context,
//                               //     MaterialPageRoute(
//                               //         builder: (context) => ManageVehicleScreen(vehicleList: vehicledetails, deviceLocationList: devicedetails,)),
//                               //   );
//                               //   // Navigator.pop(context);
//                               // }
//                               // startTimer() async {
//                               //   var duration = Duration(seconds: 1);
//                               //   return Timer(duration, route);
//                               // }
//                               // await startTimer();
//
//                             }
//                             else {
//                               showDialog(
//                                   context: context,
//                                   builder:
//                                       (context) {
//                                     Future.delayed(
//                                         Duration(
//                                             seconds: 5), () {
//                                       Navigator.of(context, rootNavigator: true).pop();
//                                     }
//                                     );
//                                     return
//                                       AlertDialog(
//                                         // (context) =>
//                                         // AlertDialog(
//                                         title: Center(
//                                           child: Text("Values are not updated. Some error occured",
//                                             style: TextStyle(
//                                                 fontSize: 15),
//                                           ),
//                                         ),
//                                         // content: Text('',
//                                         //     style: TextStyle(fontSize: 10)),
//
//                                       );
//
//                                   }
//                               );
//                               print("value not updated  some error occured");
//                             }
//                           }),
//                       SizedBox(
//                         height:  MediaQuery.of(context).size.height * .025 ,
//                       ),
//                     ],
//                   ),
//                 ),
//
//                 // color: Color(0xFF0190D7),
//               ),
//
//             ],
//           ),
//         ),
//     );
//   }
// }
//
//
// class VehicleDrop {
//   var name;
//   var id;
//   VehicleDrop(this.id,  this.name);
//   @override
//   String toString() {
//     return '${this.name}';
//   }
// }
//
//
// class ManageVehicles{
//   var VehicleName;
//   var VehicleLicensePlate;
//   var vehicleStatus;
//   var vehicleMovementStatus;
//   var LastReportedTime;
//   var VehicleType;
//   var VehicleModel;
//   var VIN;
//   var deviceIMEI;
//   var manufacturer;
//   var maintenanceNameDueDate;
//   var insuranceNumber;
//   var insuranceValidity;
//
//
//   ManageVehicles({required this.deviceIMEI, required this.VehicleModel, required this.LastReportedTime,
//     required this.VehicleName, required this.VehicleType,required this.manufacturer,
//     required this.VIN, required this.VehicleLicensePlate, required this.insuranceNumber,
//     required this.maintenanceNameDueDate,required this.vehicleMovementStatus, required this.vehicleStatus,
//     required this.insuranceValidity
//
//   });
// }
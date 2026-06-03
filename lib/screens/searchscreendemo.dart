import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

class SearchDemo extends StatefulWidget {
  const SearchDemo({Key? key}) : super(key: key);
  @override
  State<SearchDemo> createState() => _SearchDemoState();
}

class _SearchDemoState extends State<SearchDemo> {
  var totVehicleList = [];
  var vehLocationList = [];
  List<dynamic> allids=[];
  var dio = Dio();
  var offlineVehicles = 0;
  var onlineVehicles =0;
  var loader= false;
  Future<List<dynamic>> getVehiclesDetails() async {
    setState(() {
      loader= true;
    });
    var username = "439";
    final url = "http://13.233.175.113:11018/api/list-vehicles/$username";
    //show error message try catch
    var dio = Dio();
    try{
      final response = await dio.get(url);
      totVehicleList = response.data;
      allids = [];
      for (var i in totVehicleList) {
        if (i['deviceId'] != null && i['deviceId'] != "") {
          allids.add(i['deviceId']);
        }
        // print(allids);
      }
    }
    catch (e){
      print(e);
      print("Some error occured");
    }

    print('length of total vehicle list: ${totVehicleList.length}');
    print("inside getvehiclesdetails: ${totVehicleList} ");
    return totVehicleList;
    // newList = [response.data, newList2];
  }


  Future<List<dynamic>>getDeviceCurrentLocation() async {
    // print("all device ids from getDeviceCurrentLocation: ${allids}");
    var data= {
      "deviceIds": allids
    };
    final url2 = "http://13.233.175.113:11019/location/getDeviceCurrentLocation";
    try{
      final response= await dio.post(url2,data: data);
      vehLocationList = await response.data;
      print("in get getDeviceCurrentLocation");
      setState(() {
        loader= false;
      });
    }
    catch (e){
      print(e);
      setState(() {
        loader= false;
      });
      print("Some error occured");
    }
    print("online count: ${onlineVehicles}");
    return vehLocationList;
  }


  List<Map<dynamic, dynamic>> ListVehicles=[];

  List<Widget> Addvehicles() {
    // if (widget.vehicleList.length >= Lists.length) {
    for (var i = 0; i < 10; i++) {
      print(i);
      // ListVehicles.add(
      //     { "deviceIMEI": totVehicleList[i]['Nostatusisnotavailable'],
      //       "VehicleModel": totVehicleList[i]['model'],
      //       "LastReportedTime": totVehicleList[i]['packetTime'],
      //       "VehicleName": widget.totVehicleList[i]['vehicleName'],
      //       "VehicleType": widget.vehicleList[i]['vehicleTypeName'],
      //       "manufacturer": widget.vehicleList[i]['deviceName'],
      //       "VIN": widget.vehicleList[i]['vin'],
      //       "VehicleLicensePlate": widget.vehicleList[i]['licensePlate'],
      //       "insuranceNumber": widget.vehicleList[i]['insurances'][0]['insuranceName'],
      //       "maintenanceName": null,
      //       "maintenanceDueDate": null,
      //       "vehicleMovementStatus":
      //       widget.deviceLocationList[i]['speed'],
      //       "vehicleStatus":
      //       widget.deviceLocationList[i]['vehicleStatus'],
      //       "insuranceValidity": widget.vehicleList[i]['insurances'][0]['insuranceExpiry'],
      //       "VehicleId": widget.vehicleList[i]['vehicleId']}
      // );

      // Lists.add(ManageVehicles(
      //     deviceIMEI: widget.vehicleList[i]['Nostatusisnotavailable'],
      //     VehicleModel: widget.vehicleList[i]['model'],
      //     LastReportedTime: null,
      //     // widget.deviceLocationList[i]['packetTime'],
      //     VehicleName: widget.vehicleList[i]['vehicleName'],
      //     VehicleType: widget.vehicleList[i]['vehicleTypeName'],
      //     manufacturer: widget.vehicleList[i]['deviceName'],
      //     VIN: widget.vehicleList[i]['vin'],
      //     VehicleLicensePlate: widget.vehicleList[i]['licensePlate'],
      //     insuranceNumber: widget.vehicleList[i]['insurances'][0]['insuranceName'],
      //     maintenanceName: null,
      //     maintenanceDueDate: null,
      //     vehicleMovementStatus:
      //     null,
      //     // widget.deviceLocationList[i]['speed'],
      //     vehicleStatus:
      //     null,
      //     // widget.deviceLocationList[i]['vehicleStatus'],
      //     insuranceValidity: widget.vehicleList[i]['insurances'][0]['insuranceExpiry'],
      //     VehicleId: widget.vehicleList[i]['vehicleId']));
    }
    print(ListVehicles);
    // }
    // else if (widget.vehicleList.length < Lists.length) {
    //   print('all datas are added ');
    // } else {
    //   print('all datas are added ');
    // }
    setState(() {
      // Lists = Lists;
      ListVehicles= ListVehicles;

    });

    List<Widget> Demo = [];
    return Demo;
  }


  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:  () async {
        final vehicledetails= await getVehiclesDetails();
        final devicedetails= await getDeviceCurrentLocation();
        print("vehicle deatils for the the manage vehicle screens are: ${vehicledetails}");
        print("vehicle location deatils for the the manage vehicle screens are: ${devicedetails}");
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => HomePage(vehicleList: vehicledetails, deviceLocationList: devicedetails,)),
        );
      },
      child: Container(
        color: Colors.red,
        height: 300,
        width: 100,

      ),
    );
  }
}




class HomePage extends StatefulWidget {
  HomePage(
      {required this.vehicleList, required this.deviceLocationList});
  List<dynamic> vehicleList = [];
  var deviceLocationList = [];
  @override
  _HomePageState createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final List<Map<String, dynamic>> persons = [
  ];
  List<Map<dynamic, dynamic>> filterList = [];
  List<Map<dynamic, dynamic>> ListVehicles=[];

  List<Widget> Addvehicles() {
    // if (widget.vehicleList.length >= Lists.length) {
    for (var i = 0; i < widget.deviceLocationList.length; i++) {
      print(i);
      ListVehicles.add(
          { "deviceIMEI": widget.vehicleList[i]['Nostatusisnotavailable'],
            "VehicleModel": widget.vehicleList[i]['model'],
            "LastReportedTime":
            widget.deviceLocationList[i]['packetTime'],
            "VehicleName": widget.vehicleList[i]['vehicleName'],
            "VehicleType": widget.vehicleList[i]['vehicleTypeName'],
            "manufacturer": widget.vehicleList[i]['deviceName'],
            "VIN": widget.vehicleList[i]['vin'],
            "VehicleLicensePlate": widget.vehicleList[i]['licensePlate'],
            "insuranceNumber": widget.vehicleList[i]['insurances'][0]['insuranceName'],
            "maintenanceName": null,
            "maintenanceDueDate": null,
            "vehicleMovementStatus":
            widget.deviceLocationList[i]['speed'],
            "vehicleStatus":
            widget.deviceLocationList[i]['vehicleStatus'],
            "insuranceValidity": widget.vehicleList[i]['insurances'][0]['insuranceExpiry'],
            "VehicleId": widget.vehicleList[i]['vehicleId']}
      );
    }
    print(ListVehicles);
    // }
    // else if (widget.vehicleList.length < Lists.length) {
    //   print('all datas are added ');
    // } else {
    //   print('all datas are added ');
    // }
    setState(() {
      // Lists = Lists;
      ListVehicles= ListVehicles;

    });

    List<Widget> Demo = [];
    return Demo;
  }


  // This function is called whenever the text field changes
  void _runFilter(dynamic enteredKeyword) {
    List<Map<dynamic, dynamic>> results = [];
    if (enteredKeyword.isEmpty) {
      setState(() {
        results = ListVehicles;
      });
      // if the search field is empty or only contains white-space, we'll display all users
    } else {
      results = ListVehicles
          .where((person) => person["VehicleName"]
          .toLowerCase()
          .contains(enteredKeyword.toLowerCase()))
          .toList();
      // we use the toLowerCase() method to make it case-insensitive
    }
    // Refresh the UI
    setState(() {
      filterList = results;
    });
  }

  @override
  void initState() {
        () async {

      Addvehicles();
      setState(() {
        filterList= ListVehicles;
      });
    }();
    super.initState();
  }

  // @override
  // initState() {
  //   // at the beginning, all users are shown
  //   _foundPersons = persons;
  //   super.initState();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('List Search App')),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          children: [
            const SizedBox(
              height: 20,
            ),
            TextField(
              onChanged: (value) async =>   _runFilter(value),
              decoration: const InputDecoration(
                  labelText: 'Search', suffixIcon: Icon(Icons.search)),
            ),
            const SizedBox(
              height: 20,
            ),
            Expanded(
              child: filterList.isNotEmpty
                  ? ListView.builder(
                itemCount: filterList.length,
                itemBuilder: (context, index) => Card(
                  // key: ValueKey(filterList[index]["VehicleName"]),
                  color: Colors.purpleAccent,
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    leading: Text(
                      filterList[index]["VehicleName"].toString(),
                      style: const TextStyle(fontSize: 24),
                    ),
                    // title: Text(_foundPersons[index]['VehicleModel']),
                    // subtitle: Text(
                    //     '${_foundPersons[index]["VehicleName"].toString()} years old'),
                  ),
                ),
              )
                  : const Text(
                'No results found',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
import 'package:admin_app/api/api.dart';
import 'package:admin_app/languges/language_model.dart';
import 'package:admin_app/main.dart';
import 'package:admin_app/screens/reportsscreen.dart';
import 'package:admin_app/screens/tracking_screen/track_trip_screen.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../languges/language_constants.dart';
import '/screens/adminlogin.dart';
import '/screens/profilescreen.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'package:group_radio_button/group_radio_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'color.dart';
import 'manageDriverScreen.dart';
import 'tripScreens/managetripscreen.dart';
import 'managevehiclescreen.dart';
import 'notificationscreen.dart';
import 'themenotifier.dart';
import 'dashboardScreen.dart';

class NavBar extends StatefulWidget {
  const NavBar({Key? key}) : super(key: key);

  @override
  State<NavBar> createState() => _NavBarState();
}

class _NavBarState extends State<NavBar> {
  final storage = FlutterSecureStorage();
  String _selectedColor = themecolruserselected;
  String _selectedlanguage = languageuserselected;
  List<String> _colors = [
    "Blue And Indigo",
    "Deep Purple And Amber",
    "Pink And Blue Grey",
    "Indigo And Pink"
  ];

  void onThemeChange(String value, ThemeNotifier themeNotifier) async {
    final pref = await SharedPreferences.getInstance();
    if (value == "Blue And Indigo") {
      themeNotifier = themeNotifier.setTheme(blueAndIndigoTheme);
    } else if (value == "Deep Purple And Amber") {
      themeNotifier = themeNotifier.setTheme(deepPurpleAndAmberTheme);
    } else if (value == "Pink And Blue Grey") {
      themeNotifier = themeNotifier.setTheme(pinkAndBlueGreyTheme);
    } else {
      themeNotifier = themeNotifier.setTheme(indigoAndPinkTheme);
    }
    print("value from theme change is $value");
    await pref.setString("ThemeMode", value);
    setState(() {
      themecolruserselected = value;
    });
  }

  List<dynamic> vehicleList = [];
  List<Map<String, dynamic>> vehicleNames = [];
  var reportspageclicked = false;
  Future<void> getVehiclesNames() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    final url = "${baseUrl}api/list-vehicles/$userId";
    //show error message try catch
    try {
      var dio = Dio();
      final response = await dio.get(url);
      vehicleList = response.data;
      print("length of Vehicle list is:${vehicleList.length}");
      vehicleNames = [];
      for (var i in vehicleList) {
        vehicleNames.add({
          "name": i['vehicleName'],
          "id": i['vehicleId'],
          "deviceId": i['deviceId']
        });
      }
      setState(() {
        reportspageclicked = false;
      });
      print(vehicleNames);
    } catch (e) {
      print(e);
    }
    print("all names and id's:${vehicleNames}");
  }

  //profile info

  List<dynamic> profileInformation = [];
  Future<void> profileInfo() async {
    final prefs = await SharedPreferences.getInstance();
    var keycloakUserId = prefs.getString("keycloak_user");
    print('values are');
    print(keycloakUserId);
    final url = "${baseUrl}api/user-detail/$keycloakUserId";
    //show error message try catch
    try {
      var dio = Dio();
      final response = await dio.get(url);
      setState(() {
        profileInformation = [response.data];
      });

      print("length of Vehicle list is:${vehicleList.length}");
      print(profileInformation);
    } catch (e) {
      print(e);
    }
    print("profile names and id's:${profileInformation}");
  }

  var totVehicleList = [];
  var vehLocationList = [];
  List<dynamic> allids = [];
  var dio = Dio();
  var offlineVehicles = 0;
  var onlineVehicles = 0;
  var loader = false;
  var loaderforreports = false;

  Future<List<dynamic>> getVehiclesDetails() async {
    setState(() {
      loader = true;
    });
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    print("useriddd passing is: $userId");
    final url = "${baseUrl}api/list-vehicles/$userId";
    //show error message try catch
    var dio = Dio();
    try {
      final response = await dio.get(url);
      totVehicleList = response.data;
      allids = [];
      for (var i in totVehicleList) {
        if (i['deviceId'] != null && i['deviceId'] != "") {
          allids.add(i['deviceId']);
        }
      }
      print("useriddd passing is: $allids");
      print("allids passing is: ${allids.length}");
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
    print("allids lenght iss passing is: ${allids.length}");
    // print("all device ids from getDeviceCurrentLocation: ${allids}");
    var data = {"deviceIds": allids};
    print('data${data}');
    const url2 = "${baseUrl}location/getDeviceCurrentLocation";
    try {
      final response = await dio.post(url2, data: data);
      vehLocationList = await response.data;
      print("in get getDeviceCurrentLocation");
      print("vehLocationList lenght iss passing is: ${vehLocationList.length}");
      print("vehLocationList lenght iss passing is: ${vehLocationList}");

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

  @override
  Widget build(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    themeNotifier.getTheme;
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset(
                  'images/adminimage3.png',
                  width: 60,
                  height: 120,
                ),
              ),
              // backgroundColor: Colors.transparent,
            ),
            accountName: null,
            accountEmail: null,
          ),
          ListTile(
            leading: Icon(
              Icons.dashboard,
              color: blackColor,
            ),
            title: Text(
              translation(context).dashBoard,
              // "Dashboard",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            onTap: () => {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Dashboard()),
              )
            },
          ),
          ListTile(
            leading: Icon(
              Icons.trending_up,
              color: blackColor,
            ),
            title: Text(
              translation(context).tracking,
              // "Tracking",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TrackTripScreen()),
              );
            },
          ),
          ListTile(
              leading: Icon(
                Icons.trip_origin,
                color: blackColor,
              ),
              title: Text(
                translation(context).trips,
                // "Trips",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => manageTripScreen()),
                );
              }),
          ListTile(
              leading: Icon(
                Icons.directions_bus,
                color: blackColor,
              ),
              title: Text(
                translation(context).vehicles,
                // "Vehicles",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              trailing: loader ? CircularProgressIndicator() : Text(""),
              onTap: () async {
                final vehicledetails = await getVehiclesDetails();
                final devicedetails = await getDeviceCurrentLocation();
                print(
                    "devicedetails device passing to apge lenght iss passing is: ${devicedetails.length}");
                print(
                    "vehLocationList lenght iss passing is: ${devicedetails}");

                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ManageVehicleScreen(
                            vehicleList: vehicledetails,
                            deviceLocationList: devicedetails,
                          )),
                );
              }),
          ListTile(
              leading: Icon(
                Icons.person,
                color: blackColor,
              ),
              title: Text(
                translation(context).driver,
                // "Driver",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ManageDriverScreen()),
                );
              }),
          ListTile(
              title: Text(
                translation(context).reports,
                // "Reports",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              leading: Icon(
                Icons.report,
                color: blackColor,
              ),
              trailing:
                  reportspageclicked ? CircularProgressIndicator() : Text(""),
              onTap: () async {
                setState(() {
                  reportspageclicked = true;
                });
                await getVehiclesNames();

                // await getVehiclesDetails();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ReportsScreen(
                            vehicleList: vehicleNames,
                            vehicleDetailslist: vehicleList,
                          )),
                );
              }),
          ListTile(
            leading: Icon(
              Icons.notifications,
              color: blackColor,
            ),
            title: Text(
              translation(context).notification,
              // "Notifications",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const NotificationScreen()),
              );
            },
          ),
          ListTile(
              leading: Icon(
                Icons.account_circle_rounded,
                color: blackColor,
              ),
              title: Text(
                translation(context).profile,
                // "Profile",
                style: TextStyle(fontWeight: FontWeight.w900),
              ),
              onTap: () async {
                await profileInfo();
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => ProfileScreen(
                            profileInformation: profileInformation,
                          )),
                );
              }),
          ListTile(
            leading: Icon(
              Icons.format_paint_sharp,
              color: blackColor,
            ),
            title: Text(
              translation(context).theme,
              // "Theme",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            onTap: () => themeChangeDialog(themeNotifier),
          ),
          ListTile(
            leading: Icon(
              Icons.language_rounded,
              color: blackColor,
            ),
            title: Text(
              translation(context).language,
              // "Language",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            onTap: () => LanguageChangeDialog(),
          ),
          ListTile(
            title: Text(
              translation(context).logout,
              // "Logout",
              style: TextStyle(fontWeight: FontWeight.w900),
            ),
            leading: Icon(
              Icons.exit_to_app,
              color: blackColor,
            ),
            onTap: () async {
              final prefs = await SharedPreferences.getInstance();
              //
              prefs.setBool("status", false);
              // await prefs.clear();
              // await storage.deleteAll();

              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) => AdminLogin(),
                ),
                // (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  themeChangeDialog(ThemeNotifier themeNotifier) {
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                content: Container(
                  // color: Colors.white,
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RadioGroup.builder(
                        groupValue: _selectedColor,
                        onChanged: (val) {
                          setState(() {
                            _selectedColor = val!;
                          });
                          onThemeChange(_selectedColor, themeNotifier);
                          print(_selectedColor);
                        },
                        items: _colors,
                        itemBuilder: (item) => RadioButtonBuilder(item),
                      )
                    ],
                  ),
                ),
                actions: [
                  MaterialButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      })
                ],
              );
            }));
  }

  LanguageChangeDialog() {
    showDialog(
        context: context,
        builder: (_) => StatefulBuilder(
                builder: (BuildContext context, StateSetter setState) {
              return AlertDialog(
                content: Container(
                  // color: Colors.white,
                  height: 200,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      RadioGroup<String>.builder(
                        groupValue: languageuserselected,
                        onChanged: (val) {
                          if (val != null) {
                            var selected = Language.languageList()
                                .where((element) => element.name == val);
                            setState(() {
                              languageuserselected = selected.first.name;
                            });
                            AdminApp.setLocale(context,
                                Locale(selected.first.languageCode, ""));
                          }
                        },
                        items: Language.languageList().map((e) {
                          return e.name;
                        }).toList(),
                        itemBuilder: (item) => RadioButtonBuilder(item),
                      )
                    ],
                  ),
                ),
                actions: [
                  MaterialButton(
                      child: Text("Close"),
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      })
                ],
              );
            }));
  }
}

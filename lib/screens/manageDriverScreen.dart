import 'dart:io';
import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/sidebar.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../languges/language_constants.dart';
import 'themes.dart';

List<dynamic> newList = [];
List<Map<dynamic, dynamic>> driverlist = [];

class ManageDriverScreen extends StatefulWidget {
  @override
  State<ManageDriverScreen> createState() => _ManageDriverScreenState();
}

class _ManageDriverScreenState extends State<ManageDriverScreen> {
  var errormessage;
  bool isError = false;
  bool isLoading = false;
  List<Map<dynamic, dynamic>> driverdata = [];
  List<Map<dynamic, dynamic>> finaldata = [];
  List<Map<dynamic, dynamic>> sorteddata = [];
  var searchController = TextEditingController();
  String _searchResult = '';
  var loader = false;
  bool isHomePageSelected = true;
  GlobalKey<ScaffoldState> _key = GlobalKey();
  String? dropDownselected = "All";
  Widget _icon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(13)),
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
            ),
          ),
        ],
      ),
    );
  }

  getdata() async {
    final prefs = await SharedPreferences.getInstance();
    var userId = prefs.getString("user_id");
    var orgId = prefs.getString("org_id");
    print("org id is $orgId");
    try {
      final url = "${baseUrl}api/list-driver/$orgId";
      var dio = Dio();
      final response = await dio.get(url);
      driverlist.clear();
      print("res${response.data}");
      for (var i = 0; i < response.data.length; i++) {
        driverlist.add(response.data[i]);
        if (response.data[i]["firstName"] == "Gokul") {
          print("gokuls data is ${response.data[i]}");
        }
      }
      // print(" data is here $driverlist");
      // print('length:${driverlist.length}');
      print(driverlist.runtimeType);
      return driverlist;
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print("error from getdata: $e");
    }
  }

  List<Map<String, dynamic>> ListDrivers = [];
  List<Widget> Drivers() {
    print("length of the list is:${driverlist.length}");
    var fullname;
    for (var i = 0; i < driverlist.length; i++) {
      driverlist[i]['firstName'] == null || driverlist[i]['firstName'] == ''
          ? fullname = ""
          : fullname = driverlist[i]['firstName'];
      driverlist[i]['middleName'] == null || driverlist[i]['middleName'] == ''
          ? fullname = fullname + ""
          : fullname = fullname + " " + driverlist[i]['middleName'];
      driverlist[i]['lastName'] == null || driverlist[i]['lastName'] == ''
          ? fullname = fullname + ""
          : fullname = fullname + " " + driverlist[i]['lastName'];
      print(fullname);
      ListDrivers.add(
        {
          "driverId": driverlist[i]['driverId'] ?? "---",
          "driverImage": driverlist[i]["image"],
          "TripName": driverlist[i]['tripName'] ?? "---",
          "vehicleName": driverlist[i]['vehicleName'] ?? "---",
          "driverName": fullname,
          "status": driverlist[i]['status'] ?? "---",
          "category": driverlist[i]['category'] ?? "---",
          "licenseNumber": driverlist[i]['licenseNumber'] ?? "---",
          "licenseExpirationDate":
              driverlist[i]['licenseExpirationDate'] ?? "---",
          "tripStatus": driverlist[i]['tripStatus'] ?? "---"
        },
      );
    }
    setState(() {
      ListDrivers = ListDrivers;
    });
    List<Widget> Demo = [];
    return Demo;
  }

  @override
  void initState() {
    () async {
      await getdata();
      await Drivers();
      setState(() {
        driverlist = driverlist;
        driverdata = ListDrivers;
        isLoading = false;
        finaldata = driverdata;
      });
    }();
    super.initState();
  }

  void searchFun(String enteredKeyword) {
    List<Map<dynamic, dynamic>> results = [];
    List<Map<dynamic, dynamic>> tempdata = [];
    if (enteredKeyword.isEmpty) {
      // if the search field is empty or only contains white-space, we'll display all users
      if (dropDownselected == "All") {
        setState(() {
          results = ListDrivers;
          // usersFiltered = results;
        });
      } else {
        setState(() {
          results = sorteddata;
        });
      }
    } else {
      // print("list trip $ListDrivers");
      // print("tripName ${ListTrip.where((trip) => trip["tripName"].toBool())}");
      if (dropDownselected == "All") {
        tempdata = ListDrivers;
        print("In search all");
      } else {
        print("In search sorted");
        tempdata = sorteddata;
      }
      results = tempdata
          .where((person) =>
              person["driverName"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["vehicleName"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["status"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["licenseNumber"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["driverId"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")) ||
              person["tripStatus"]
                  .toString()
                  .toLowerCase()
                  .replaceAll(" ", "")
                  .contains(enteredKeyword.toLowerCase().replaceAll(" ", "")))
          .toList();
      if (results.isEmpty) {
        setState(() {
          loader = true;
        });
      } else {
        setState(() {
          loader = false;
        });
      }
    }
    // print("results ${results}");
    // // Refresh the UI
    setState(() {
      // driverdata = results;
      finaldata = results;
    });
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    return GestureDetector(
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
                      padding: EdgeInsets.only(top: 20),
                      child: Text(translation(context).drivers)),
                  elevation: 0,
                )),
            body: SingleChildScrollView(
                physics: AlwaysScrollableScrollPhysics(),
                child: Column(children: [
                  Container(
                    height: MediaQuery.of(context).size.height * .09,
                    // color: Colors.indigo,
                    color: buttonColourBlue,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: MediaQuery.of(context).size.height * .06,
                              width: MediaQuery.of(context).size.width * .96,
                              // padding: EdgeInsets.fromLTRB(10, 5, 10, 5),
                              decoration: BoxDecoration(
                                color: searchBoxColorWhite,
                                borderRadius:
                                BorderRadius.all(Radius.circular(5)),
                              ),
                              child: GestureDetector(
                                child: Row(
                                  mainAxisAlignment:
                                  MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      height: 100,
                                      width: 340,
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
                                                    finaldata = driverdata;
                                                  });
                                                },
                                                child: Icon(
                                                  Icons.cancel,
                                                  color: Colors.black,
                                                )),
                                            hintText: 'Search',
                                            hintStyle:
                                            TextStyle(color: Colors.black),
                                            border: InputBorder.none),
                                        onChanged: (value) async =>
                                            searchFun(value),
                                      ),
                                    ),
                                    // Text('Search', style: manageVehiclePageSearchTextStyle,),
                                    // searchIcon
                                  ],),
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                  isError == true
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
                      : driverdata.isNotEmpty
                          ? ListView.builder(
                              // scrollDirection: Axis.vertical,
                              physics: NeverScrollableScrollPhysics(),
                              shrinkWrap: true,
                              itemCount: finaldata.length,
                              itemBuilder: (context, index) {
                                print(finaldata.length);
                                print(
                                    'list view :${finaldata[index]['status']}');
                                return Column(children: [

                                  Container(
                                      margin: EdgeInsets.fromLTRB(0, 15, 0, 13),
                                      width: MediaQuery.of(context).size.width *
                                          .93,
                                      decoration: BoxDecoration(
                                        color: Color(0xFFFFFFFF),
                                      ),
                                      child: Column(
                                        children: [
                                      Container(
                                      decoration: BoxDecoration(
                                      border: Border.all(
                                        color: Colors.black38,
                                        width: 2.0,
                                      ),
                                      borderRadius: BorderRadius.circular(12)
                                  ),
                                        child: Column(
                                          children: [
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Driver Profile'),
                                                  ),
                                                ),
                                                finaldata[index]['driverImage'] == " "
                                                    ? Center(
                                                  child: Padding(
                                                      padding: EdgeInsets.only(
                                                          left: 0),
                                                      child: IconButton(
                                                        icon: Icon(Icons
                                                            .account_circle_rounded),
                                                        onPressed: () {},
                                                      )),
                                                )
                                                    : Center(
                                                  child: Padding(
                                                    padding: EdgeInsets.only(
                                                        left: 1, bottom: 10),
                                                    child: Image.network(
                                                      "${finaldata[index]['driverImage']}",
                                                      errorBuilder: (context,
                                                          error, stackTrace) {
                                                        return Container(
                                                            width: 125,
                                                            height: 90,
                                                            child: IconButton(
                                                              icon: Icon(
                                                                Icons
                                                                    .account_circle_rounded,
                                                                size: 80,
                                                                color:
                                                                Colors.grey,
                                                              ),
                                                              onPressed: () {},
                                                            ));
                                                      },
                                                      width: 120,
                                                      height: 150,
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
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Driver Name'),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text(
                                                      finaldata[index]["driverName"] != null ?
                                                      finaldata[index]["driverName"].toString() : "--",
                                                      style: vehiclePageCardTextSubHeadStyle,),
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
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Status'),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text(
                                                      finaldata[index]["status"] != null ?
                                                      finaldata[index]["status"].toString() : "--",
                                                      style: vehiclePageCardTextSubHeadStyle,),
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
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Driver Availability'),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text(
                                                      finaldata[index]["tripStatus"] != null ?
                                                      finaldata[index]["tripStatus"].toString() : "--",
                                                      style: vehiclePageCardTextSubHeadStyle,),
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
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('License Number'),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text(
                                                      finaldata[index]["licenseNumber"] != null ?
                                                      finaldata[index]["licenseNumber"].toString() : "--",
                                                      style: vehiclePageCardTextSubHeadStyle,),
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
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('License Expiry'),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text(
                                                      finaldata[index]["licenseExpirationDate"] != null ?
                                                      finaldata[index]["licenseExpirationDate"].toString() : "--",
                                                      style: vehiclePageCardTextSubHeadStyle,),
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
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text('Assigned Vehicle'),
                                                  ),
                                                ),
                                                Expanded(
                                                  child: Padding(
                                                    padding: EdgeInsets.all(8.0),
                                                    child: Text(
                                                      finaldata[index]["vehicleName"] != null ?
                                                      finaldata[index]["vehicleName"].toString() : "--",
                                                      style: vehiclePageCardTextSubHeadStyle,),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            SizedBox(
                                              height: 10,
                                            )
                                          ],
                                        ),
                                )
                                ]
                                      )
                                  ),
                                  // Card(
                                  //   elevation: 8,
                                  //   margin: EdgeInsets.all(10),
                                  //   child: Container(
                                  //     height: 195,
                                  //     color: Colors.white,
                                  //     child: Row(
                                  //       children: [
                                  //         finaldata[index]['driverImage'] == " "
                                  //             ? Center(
                                  //                 child: Padding(
                                  //                     padding: EdgeInsets.only(
                                  //                         left: 0),
                                  //                     child: IconButton(
                                  //                       icon: Icon(Icons
                                  //                           .account_circle_rounded),
                                  //                       onPressed: () {},
                                  //                     )),
                                  //               )
                                  //             : Center(
                                  //                 child: Padding(
                                  //                   padding: EdgeInsets.only(
                                  //                       left: 1, bottom: 10),
                                  //                   child: Image.network(
                                  //                     "${finaldata[index]['driverImage']}",
                                  //                     errorBuilder: (context,
                                  //                         error, stackTrace) {
                                  //                       return Container(
                                  //                           width: 125,
                                  //                           height: 90,
                                  //                           child: IconButton(
                                  //                             icon: Icon(
                                  //                               Icons
                                  //                                   .account_circle_rounded,
                                  //                               size: 80,
                                  //                               color:
                                  //                                   Colors.grey,
                                  //                             ),
                                  //                             onPressed: () {},
                                  //                           ));
                                  //                     },
                                  //                     width: 120,
                                  //                     height: 200,
                                  //                   ),
                                  //                 ),
                                  //               ),
                                  //         Expanded(
                                  //           flex: 8,
                                  //           child: Container(
                                  //             alignment: Alignment.topLeft,
                                  //             child: Column(
                                  //               crossAxisAlignment:
                                  //                   CrossAxisAlignment.start,
                                  //               children: [
                                  //                 Expanded(
                                  //                   child: ListTile(
                                  //                     title: Container(
                                  //                         child: Text(
                                  //                             "${finaldata[index]['driverName'].toString()} | ${finaldata[index]['driverId'].toString()}")),
                                  //                     subtitle: finaldata[index]
                                  //                                     ['status']
                                  //                                 .toString()
                                  //                                 .toLowerCase()
                                  //                                 .trim() ==
                                  //                             "inactive"
                                  //                         ? Text(
                                  //                                 "Status: Inactive")
                                  //                         : Text(
                                  //                                 "Status: Active")),
                                  //                   ),
                                  //                 SizedBox(
                                  //                   height: 20,
                                  //                 ),
                                  //                 Expanded(
                                  //                     child: Row(
                                  //                         crossAxisAlignment:
                                  //                             CrossAxisAlignment
                                  //                                 .center,
                                  //                         children: [
                                  //                       Padding(
                                  //                           padding:
                                  //                               EdgeInsets.only(
                                  //                                   top: 8)),
                                  //                       SizedBox(
                                  //                         width: 8,
                                  //                         height: 8,
                                  //                       ),
                                  //                       Text(
                                  //                           "  Driver Availability:  ${finaldata[index]['tripStatus'].toString()}"),
                                  //                     ])),
                                  //                 Expanded(
                                  //                   child: Row(
                                  //                     children: [
                                  //                       Padding(
                                  //                           padding:
                                  //                           EdgeInsets.only(
                                  //                               top: 8)),
                                  //                       SizedBox(
                                  //                         width: 8,
                                  //                       ),
                                  //                       Text("  License No: " +
                                  //                           finaldata[index][
                                  //                           'licenseNumber']
                                  //                               .toString()),
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //                 Expanded(
                                  //                     child: Row(
                                  //                         crossAxisAlignment:
                                  //                             CrossAxisAlignment
                                  //                                 .center,
                                  //                         children: [
                                  //                       SizedBox(
                                  //                         width: 8,
                                  //                       ),
                                  //                       Text(
                                  //                           "  License Expiry:  ${finaldata[index]['licenseExpirationDate'].toString()}"),
                                  //                     ])),
                                  //
                                  //
                                  //
                                  //                 Expanded(
                                  //                   child: Row(
                                  //
                                  //                     children: [
                                  //                       Padding(
                                  //                           padding:
                                  //                               EdgeInsets.only(
                                  //                                   top: 8)),
                                  //                       SizedBox(
                                  //                         width: 15,
                                  //                       ),
                                  //                       finaldata[index][
                                  //                                   'vehicleName'] ==
                                  //                               null
                                  //                           ? Text(
                                  //                               "Assigned Vehicle: ---")
                                  //                           : Flexible(child: Text(
                                  //                               "Assigned Vehicle: ${finaldata[index]['vehicleName'].toString()}",overflow: TextOverflow.visible,)),
                                  //                     ],
                                  //                   ),
                                  //                 ),
                                  //               ],
                                  //             ),
                                  //           ),
                                  //         ),
                                  //       ],
                                  //     ),
                                  //   ),
                                  // ),
                                ]);
                              })
                          : loader
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
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
                                )
                              : Center(
                                  child: CircularProgressIndicator(),
                                )
                  // : Center(
                  //     child: Column(
                  //       mainAxisAlignment: MainAxisAlignment.center,
                  //       crossAxisAlignment:
                  //           CrossAxisAlignment.center,
                  //       children: [
                  //         LottieBuilder.asset(
                  //             "images/no-data-found.json"),
                  //         const Text("No Data available"),
                  //         const SizedBox(
                  //           height: 20,
                  //         ),
                  //       ],
                  //     ),
                  //   )
                ]))));
  }

  Future<void> ondropdownchange(String value) async {
    switch (value) {
      case "Offline":
        await sortonlineoffline("Offline");
        print("OFFLINE");
        break;
      case "Online":
        await sortonlineoffline("Online");
        break;
      default:
        setState(() {
          finaldata = driverdata;
        });
    }
  }

  Future<void> sortonlineoffline(String val) async {
    if (val == "Online") {
      sorteddata.clear();
      for (int i = 0; i < driverdata.length; i++) {
        print(driverdata[i]);
        if (driverdata[i]["status"].toString().trim().toLowerCase() ==
            "active") {
          sorteddata.add(driverdata[i]);
        }
      }
      setState(() {
        finaldata = sorteddata;
      });
    } else if (val == "Offline") {
      sorteddata.clear();
      for (int i = 0; i < driverdata.length; i++) {
        if (driverdata[i]["status"].toString().trim().toLowerCase() ==
            "inactive") {
          print("offline ${driverdata[i]}");
          sorteddata.add(driverdata[i]);
        }
      }
      setState(() {
        finaldata = sorteddata;
        print("sorted data is $finaldata");
      });
    }
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
}

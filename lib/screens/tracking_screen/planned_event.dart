import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PlannedPage extends StatefulWidget {
  const PlannedPage({Key? key}) : super(key: key);

  @override
  State<PlannedPage> createState() => _PlannedPageState();
}

class _PlannedPageState extends State<PlannedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, 1),
                  blurRadius: 5,
                  color: Colors.black.withOpacity(0.2),
                ),
              ],
            ),
            child: Card(
                elevation: 2,
                child: ExpansionTile(
                  backgroundColor: Colors.white,
                  collapsedBackgroundColor: Colors.white,
                  collapsedTextColor: Colors.black,
                  textColor: Colors.black,
                  title: Column(children: [
                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Event Name",
                              ),
                              Text(
                                "eventname",
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Event Priority",
                              ),
                              Text(
                                "eventpriority",
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                "Date and Time",
                              ),
                              Text(
                                "dateandtime",
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ]),
                  children: <Widget>[
                    Column(
                      children: _buildExpandableContent(context),
                    ),
                  ],
                ))));
  }
}

_buildExpandableContent(BuildContext context) {
  List<Widget> columnContent = [];
  columnContent.add(
    Column(
      children: <Widget>[
        Container(
          decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(
                width: 2.0,
                color: Colors.blue.shade100,
              )),
          child:  Padding(padding: EdgeInsets.only(left: 10,top: 5),
            child:Column(
              children: [
                SizedBox(height: 10),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.trending_up),
                    SizedBox(width: 3),
                    Text(
                      "TripName/ID: " ,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding:EdgeInsets.only(left: 160),child:Text(
                      "Tripname/ID",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.track_changes_sharp),
                    SizedBox(width: 3),
                    Text(
                      "TripStatus: " ,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding:EdgeInsets.only(left: 180),child:Text(
                      "TripStatus",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.drive_eta_rounded),
                    SizedBox(width: 3),
                    Text(
                      "Vehicle Name: " ,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding:EdgeInsets.only(left: 150),child:Text(
                      "Vehicle Name",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.recent_actors_outlined),
                    SizedBox(width: 3),
                    Text(
                      "Driver Name: " ,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding:EdgeInsets.only(left: 160),child:Text(
                      "Driver Name",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.phone),
                    SizedBox(width: 3),
                    Text(
                      "Contact Number: " ,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding:EdgeInsets.only(left: 120),child:Text(
                      "Contact Number",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.location_pin),
                    SizedBox(width: 3),
                    Text(
                      "Location: " ,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding:EdgeInsets.only(left: 180),child:Text(
                      "Location",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),)
                  ],
                ),
                SizedBox(height: 10),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.date_range_sharp),
                    SizedBox(width: 3),
                    Text(
                      "Date and Time: ",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding:EdgeInsets.only(left: 140),child:Text(
                      "Date and Time",
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),),
                  ],
                ),
                const Divider(
                  thickness: 2,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                        style: ButtonStyle(
                            elevation: MaterialStateProperty.all(2),
                            backgroundColor:
                            MaterialStateProperty.all(Colors.blue)),
                        onPressed: () async {},
                        child: Row(
                          children: const [
                            Image(
                                height: 30,
                                image: AssetImage("images/livelocation.png")),
                            Text(
                              "Live Location",
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ],
                        )),
                  ],
                )
              ],
            ),),
        ),
      ],
    ),
  );
  return columnContent;
}

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class UnPlannedPage extends StatefulWidget {
  const UnPlannedPage({Key? key}) : super(key: key);

  @override
  State<UnPlannedPage> createState() => _UnPlannedPageState();
}

class _UnPlannedPageState extends State<UnPlannedPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body: Card(
            elevation: 2,
            child: ExpansionTile(
              backgroundColor: Colors.white,
              collapsedBackgroundColor: Colors.white,
              collapsedTextColor: Colors.black,
              textColor: Colors.black,
              title: Column(children: [
                Padding(
                  padding: const EdgeInsets.only(left: 5, top: 10),
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
                      // const Divider(
                      //   thickness: 2,
                      // ),
                      const SizedBox(
                        height: 10,
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
            )));
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
          child: Padding(padding: EdgeInsets.only(left: 10,top: 5),
            child:Column(
              children: [
                SizedBox(height: 10),
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Icon(Icons.trending_up),
                    SizedBox(width: 3),
                    Text(
                      "Trip ID: " ,
                      style: TextStyle(
                        fontSize: 12.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Padding(padding:EdgeInsets.only(left: 200),child:Text(
                      "ID",
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

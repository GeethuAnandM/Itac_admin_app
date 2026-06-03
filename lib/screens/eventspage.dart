import 'package:contained_tab_bar_view/contained_tab_bar_view.dart';
import 'package:flutter/material.dart';
import 'dart:core';
import 'package:http/http.dart' as http;
import '../languges/language_constants.dart';
import 'themes.dart';
import 'eventsscreen.dart';

class PageEvent extends StatefulWidget {
  @override
  State<PageEvent> createState() => _PageEventState();
}

class _PageEventState extends State<PageEvent> {
  // static Stream<dynamic> getPrice() {
  //   print("entered inside getprice");
  //
  //   return
  //     Stream.periodic(Duration(seconds: 1)).asyncMap((_) {
  //       var i =0;
  //       i++;
  //       var c= i +1;
  //       print(c);
  //       // print(i);
  //       return c;
  //     } );
  //
  // }
  final events = EventApi.event;
  Stream<double> getValuesforStream(){
    print(   EventApi.getdatasfromapi().toString());
    print("value is here");
    return Stream<double>.periodic(
      Duration(seconds: 1),
          (count) => events + count * 5,

    );
  }


  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          backgroundColor: Colors.white,
          title:  Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Container(
                height: 40,
                width: 60,
                child: Image.asset(
                  'images/logo.png',
                  // width: 60,
                  // height: 40,
                  fit: BoxFit.fill,
                ),
              ),
              SizedBox(
                width:  MediaQuery.of(context).size.width * .2 ,
              ),
          Text(translation(context).events,style: appBarTextStyle,)

            ],
          ),
        ),
        body:
        StreamBuilder<dynamic>(
          initialData: events,
          stream: EventApi.getdatasfromapi(),
          builder: (context, snapshot) {
            switch (snapshot.connectionState) {
              case ConnectionState.waiting:
                return Center(child: CircularProgressIndicator());
              default:
                if (snapshot.hasError) {
                  return Center(child: Text('Some error occurred!'));
                } else {
                  final List<dynamic> getdata = snapshot.data;
                  return Container(
                    height: 700,
                    child:
                    ContainedTabBarView(

                      tabBarProperties: TabBarProperties(
                        indicatorColor: Colors.white,
                        labelColor: Colors.red,
                        unselectedLabelColor: Colors.orange,
                        background: Container(
                          color: Colors.blue,
                        )
                      ),
                      tabs: [
                        Container(
                            height: 50,
                            child: Center(child: Text('Planned',
                            ))),
                        Container(
                            height: 50,
                            color: Colors.white,
                            child: Center(child: Text('Unplanned',
                            ))),
                      ],
                      views: [
                        ScreenEvents(),
                        ScreenEvents(),
                      ],
                      onChange: (index) => print(index),
                    ),
                  );
                }}
          },
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


class EventApi {
  static final dynamic event = 32000;
  static final _key = '4fe49fbf4baf5a7b866ecbbc5622f468';

  static Stream <List<dynamic>> getdatasfromapi() =>
      Stream.periodic(Duration(seconds: 1)).asyncMap((_) => getdatas());

  static Future <List<dynamic>> getdatas() async {
    final url =
        'https://api.nomics.com/v1/currencies/ticker?key=$_key&ids=BTC&interval=1d';
    final response = await http.get(Uri.parse('http://gspedia.com/projects/survey-app/api/getallcustomerdetails'));
    List <dynamic> newList = [response.body];
    print(newList);
    print(' data type is ${response.runtimeType}');
    var finaldata= newList;
    print(finaldata);
    return finaldata;
  }
}
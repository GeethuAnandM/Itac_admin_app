import 'package:admin_app/screens/tracking_screen/planned_event.dart';
import 'package:admin_app/screens/tracking_screen/unplanned_event.dart';
import 'package:flutter/material.dart';

int selectedTab = 0;

class EventListPage extends StatefulWidget {
  @override
  _EventListPageState createState() => _EventListPageState();
}

class _EventListPageState extends State<EventListPage> with TickerProviderStateMixin{
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
    super.initState();
    //load planned events and unplanned events from database or API
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        body:
          DefaultTabController(
            length: 2,
            child: Column(
              children: <Widget>[
                Material(
                  // color: Colors.blue,
                  child: TabBar(
                    unselectedLabelColor: Colors.grey,
                    labelColor: Colors.blue,
                    indicatorColor: Colors.white,
                    controller: _tabController,
                    labelPadding: const EdgeInsets.all(0.0),
                    tabs: [
                      _getTab(
                          0,
                          const Center(
                              child: Text(
                                "Planned",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900),
                              ))),
                      _getTab(
                          1,
                          const Center(
                              child: Text(
                                "UnPlanned",
                                style: TextStyle(
                                    fontSize: 20, fontWeight: FontWeight.w900),
                              ))),
                    ],
                  ),
                ),
                Expanded(
                    child: TabBarView(
                        physics: const NeverScrollableScrollPhysics(),
                        controller: _tabController,
                        children: [
                          Container(
                            child: PlannedPage(),
                          ),
                          Container(
                            child:  UnPlannedPage(),
                          )
                        ]))
              ],
            )),
        );
  }
}
_getTab(index, child) {
  return Tab(
    child: Container(
      child: child,
      decoration: BoxDecoration(
          color:
          (selectedTab == index ? Colors.white : Colors.grey.shade300),
          borderRadius: _generateBorderRadius(index)),
    ),
  );
}

_generateBorderRadius(index) {
  if ((index + 0) == selectedTab)
    return const BorderRadius.only(bottomRight: Radius.circular(10.0));
  else if ((index - 0) == selectedTab)
    return const BorderRadius.only(bottomLeft: Radius.circular(10.0));
  else
    return BorderRadius.zero;
}

class Event {
  final String name;
  final String date;
  final String priority;

  Event(this.name, this.date, this.priority);
}
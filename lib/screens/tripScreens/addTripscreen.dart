import 'package:admin_app/screens/tripScreens/roundTripPage.dart';
import 'package:admin_app/screens/sidebar.dart';
import 'package:flutter/material.dart';
import '../../../languges/language_constants.dart';
import 'oneWayPage.dart';

class AddTripScreen extends StatefulWidget {
  @override
  State<AddTripScreen> createState() => _AddTripScreenState();
}

class _AddTripScreenState extends State<AddTripScreen>
    with TickerProviderStateMixin {
  GlobalKey<ScaffoldState> scaffoldKey = GlobalKey();

  bool isHomePageSelected = true;

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
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

  var vehiclestatus;
  var vehiclemovementstatus;

  late TabController _tabController;

  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(vsync: this, length: 2);

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        setState(() {
          _selectedTab = _tabController.index;
        });
      }
    });
  }

  bool _value = false;

  @override
  void setState(fn) {
    if(mounted) {
      super.setState(fn);
    }
  }
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      drawer: const NavBar(),
      appBar: PreferredSize(
          preferredSize: const Size.fromHeight(60.0),
          child: AppBar(
              centerTitle: true,
              leading: Padding(
                  padding: const EdgeInsets.only(top: 15), child: _appBar()),
              elevation: 0,
              title:  Padding(
                padding: EdgeInsets.only(top: 20),
                child:Text(translation(context).addTrips),
              ))),
      body: DefaultTabController(
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
                              "One Way Trip",
                              style: TextStyle(
                                  fontSize: 20, fontWeight: FontWeight.w900),
                            ))),
                    _getTab(
                        1,
                        const Center(
                            child: Text(
                              "Round Trip ",
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
                          child: OneWay(),
                        ),
                        Container(
                          child: RoundTrip(),
                        )
                      ]))
            ],
          )),
    );
  }

  _getTab(index, child) {
    return Tab(
      child: Container(
        child: child,
        decoration: BoxDecoration(
            color:
            (_selectedTab == index ? Colors.white : Colors.grey.shade300),
            borderRadius: _generateBorderRadius(index)),
      ),
    );
  }

  _generateBorderRadius(index) {
    if ((index + 0) == _selectedTab)
      return const BorderRadius.only(bottomRight: Radius.circular(10.0));
    else if ((index - 0) == _selectedTab)
      return const BorderRadius.only(bottomLeft: Radius.circular(10.0));
    else
      return BorderRadius.zero;
  }

  @override
  void dispose() {
    print("dispose");
    super.dispose();
  }
}

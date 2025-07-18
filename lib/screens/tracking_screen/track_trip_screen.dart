import 'package:admin_app/screens/sidebar.dart';
import 'package:admin_app/screens/tracking_screen/track_trip_view.dart';
import 'package:admin_app/screens/tracking_screen/dummy.dart';
import 'package:admin_app/screens/tracking_screen/vehicle_live_location.dart';
import 'package:flutter/material.dart';
import '../../languges/language_constants.dart';
import 'event_screen_in_tracking.dart';

class TrackTripScreen extends StatefulWidget {
  const TrackTripScreen({super.key});

  @override
  State<TrackTripScreen> createState() => _TrackTripScreenState();
}

class _TrackTripScreenState extends State<TrackTripScreen>
    with TickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _key = GlobalKey();
  late TabController _tabController;

  @override
  void initState() {
    _tabController = TabController(length: 2, vsync: this);
    super.initState();
  }

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.all(Radius.circular(13)),
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
    return Row(
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
    );
  }

  @override
  Widget build(BuildContext context) {
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
                child: Text(translation(context).tracking)),
            elevation: 0,
          )),
      body: Column(
        children: [
          TabBar(
              physics: NeverScrollableScrollPhysics(),
              controller: _tabController,
              labelColor: Colors.black,
              indicatorWeight: 0.1,
              tabs: [
                Tab(
                  text: "Trips",
                  icon: Image(
                      height: 30, image: AssetImage("images/livelocation.png")),
                ),
                // Tab(
                //   text: "Events",
                //   icon: Image(
                //       height: 30, image: AssetImage("images/eventsicons.png")),
                // ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => VehicleLocationMap()),
                    );
                  },
                  child: Tab(
                    text: "Location",
                    icon:
                        Image(height: 30, image: AssetImage("images/map.png")),
                  ),
                ),
              ]),
          Expanded(
            child: TabBarView(
                physics: const NeverScrollableScrollPhysics(),
                controller: _tabController,
                children: [
                  TrackListScreen(),
                  // EventListPage(),
                  // VehicleLocationMap()
                ]),
          )
        ],
      ),
    );
  }
}

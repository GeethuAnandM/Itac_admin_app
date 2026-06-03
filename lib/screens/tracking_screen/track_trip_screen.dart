import 'package:admin_app/screens/sidebar.dart';
import 'package:admin_app/screens/tracking_screen/vehicle_live_location.dart';
import 'package:flutter/material.dart';

import '../../languges/language_constants.dart';

class TrackTripScreen extends StatefulWidget {
  const TrackTripScreen({super.key});

  @override
  State<TrackTripScreen> createState() => _TrackTripScreenState();
}

class _TrackTripScreenState extends State<TrackTripScreen> {
  final GlobalKey<ScaffoldState> _key = GlobalKey();

  Widget _icon(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: const BoxDecoration(
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        RotatedBox(
          quarterTurns: 4,
          child: _icon(Icons.menu),
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
            padding: const EdgeInsets.only(top: 15),
            child: _appBar(),
          ),
          title: Padding(
            padding: const EdgeInsets.only(top: 20),
            child: Text(translation(context).tracking),
          ),
          elevation: 0,
        ),
      ),
      body: const VehicleLocationMap(showScaffold: false),
    );
  }
}

import 'package:admin_app/screens/sidebar.dart';
import '../languges/language_constants.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'adminlogin.dart';
import 'createnewpassword.dart';
import 'custom_widget.dart';
import 'forgotpassword.dart';

class ProfileScreen extends StatefulWidget {
  ProfileScreen({required this.profileInformation});
  List<dynamic> profileInformation = [];

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool isHomePageSelected = true;
  GlobalKey<ScaffoldState> _key = GlobalKey();

  Widget _icon(IconData icon) {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
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

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    print(widget.profileInformation);
    return Scaffold(
      key: _key,
      drawer: NavBar(),
      appBar: PreferredSize(
          preferredSize: Size.fromHeight(60.0),
          child: AppBar(
            centerTitle: true,
            leading:
                Padding(padding: EdgeInsets.only(top: 15), child: _appBar()),
            title: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Text(translation(context).profile)),
            elevation: 0,
          )),
      body: Container(
        height: 800,
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Center(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 20, 0, 15),
                  height: 120,
                  width: 120,
                  child: widget.profileInformation[0]['img_path'] != null
                      ? Image.network(
                          "${widget.profileInformation[0]['img_path']}",
                          // width: 60,
                          // height: 40,
                          fit: BoxFit.cover,
                        )
                      : Image.asset("images/person.jpg"),
                ),
                Text(
                  widget.profileInformation.isNotEmpty
                      ? "${widget.profileInformation[0]['first_name'].toString()} "
                          "${widget.profileInformation[0]['middle_name'].toString()}"
                          " ${widget.profileInformation[0]['last_name'].toString()}"
                      : "--",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      height: 1),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .01,
                ),
                Text(
                  widget.profileInformation.isNotEmpty
                      ? "(${widget.profileInformation[0]['user_id'].toString()})"
                      : "--",
                  style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.grey,
                      height: 1),
                ),
                SizedBox(
                  height: MediaQuery.of(context).size.height * .02,
                ),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Text(
                    //   "Status",
                    //   style: vehiclePageCardTextNormalTextStyle,
                    // ),
                    Container(
                      decoration: BoxDecoration(
                          color: greenColor,
                          borderRadius: BorderRadius.circular(6)),
                      margin: EdgeInsets.fromLTRB(10, 0, 0, 0),
                      padding: EdgeInsets.fromLTRB(10, 8, 10, 8),
                      child: Text(
                        "Online",
                        style: vehiclePageCardTextNormalWhiteStyle,
                      ),
                    )
                  ],
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 25),
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                  width: MediaQuery.of(context).size.width * .89,
                  height: MediaQuery.of(context).size.height * .39,
                  decoration: BoxDecoration(
                    color: Color(0xFFFFFFFF),
                    borderRadius: BorderRadius.all(Radius.circular(10)),
                    // border: Border.all(
                    //   width: 1,
                    //   color: Color(0xFF000000).withOpacity(0.3),
                    // )
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 1,
                        color: Colors.black.withOpacity(0.3),
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 8),
                        width: 300,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 1,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Organization name",
                              style: vehiclePageCardTextSubHeadStyle,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.profileInformation[0]['org_name'] != null
                                  ? "${widget.profileInformation[0]['org_name'].toString()}"
                                  : " ---",
                              style: vehiclePageCardTextNormalTextBlueStyle,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 8),
                        width: 300,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 1,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Email address",
                              style: vehiclePageCardTextSubHeadStyle,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.profileInformation.isNotEmpty
                                  ? "${widget.profileInformation[0]['email'].toString()}"
                                  : "--",
                              style: vehiclePageCardTextNormalTextBlueStyle,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 15, 10, 0),
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 8),
                        width: 300,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 1,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Phone Number",
                              style: vehiclePageCardTextSubHeadStyle,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              widget.profileInformation.isNotEmpty
                                  ? "${widget.profileInformation[0]['primary_phone'].toString()}"
                                  : "--",
                              style: vehiclePageCardTextNormalTextBlueStyle,
                            ),
                          ],
                        ),
                      ),
                      Container(
                        height: 70,
                        margin: EdgeInsets.fromLTRB(10, 10, 10, 0),
                        padding: EdgeInsets.fromLTRB(10, 5, 10, 8),
                        width: 300,
                        decoration: BoxDecoration(
                          color: Color(0xFFFFFFFF),
                          borderRadius: BorderRadius.all(Radius.circular(5)),
                          boxShadow: [
                            BoxShadow(
                              offset: Offset(0, 1),
                              blurRadius: 1,
                              color: Colors.black.withOpacity(0.1),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Contact Us ",
                              style: vehiclePageCardTextSubHeadStyle,
                            ),
                            SizedBox(
                              height: 10,
                            ),
                            Text(
                              "Support Email : supportteama@ii2mail.com\n"
                              "Phone number : 9995111953",
                              style: vehiclePageCardTextNormalTextBlueStyle,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                CustomButton(
                    buttontext: "Change Password",
                    onpress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => CreatenewPassword(
                                userid: widget.profileInformation[0]['user_id'],
                                useremail: widget.profileInformation[0]
                                    ['email'])),
                      );
                    }),
                SizedBox(
                  height: 20,
                ),
                Container(
                  margin: EdgeInsets.fromLTRB(1, 3, 15, 0),
                  child: Center(
                    child: GestureDetector(
                        onTap: () async {
                          Navigator.of(context)
                              .pushReplacement(MaterialPageRoute(
                            builder: (BuildContext context) => AdminLogin(),
                          ));
                          //   // (route) => false,
                          // );
                          // Navigator.pop(context);
                        },
                        child: Text("Back to Signin?",
                            textAlign: TextAlign.center,
                            style: blueColouredTextStyle)),
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text(
                  "All rights reserved © 2022 cogniphi.com",
                  style: TextStyle(
                    color: Color(0xFF848282),
                  ),
                )
                //
                // SizedBox(
                //   height: 20,
                // ),
              ],
            ),
          ),
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

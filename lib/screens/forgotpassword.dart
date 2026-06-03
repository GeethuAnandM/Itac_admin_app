import 'dart:async';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '../api/api.dart';
import '/screens/phonenumberotp.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'adminlogin.dart';
import 'custom_widget.dart';

class ForgotPassword extends StatefulWidget {
  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

final emailphonenumberController = TextEditingController();

class _ForgotPasswordState extends State<ForgotPassword> {
  var useridverified;
  Map<String, dynamic> responsedata = {};
  Future<dynamic> forgotPassword(var emailorphonenumber) async {
    final dataBody = {};
    print(emailorphonenumber.runtimeType);
    if (emailorphonenumber.contains(RegExp(r'^[0-9]*$')) == true) {
      var data = {"mobile": emailorphonenumber};
      dataBody.addAll(data);
      print(dataBody);
    } else {
      var data = {"email_address": emailorphonenumber};
      dataBody.addAll(data);
      print(dataBody);
    }
    const url2 = "${baseUrl}api/execute-forgot-password";
    var dio = Dio();
    try {
      final response = await dio.post(url2, data: dataBody);
      setState(() {
        responsedata = response.data;
        useridverified = response.statusCode;
        print(useridverified);
      });
      print(response.data);
    } catch (e) {
      setState(() {
        useridverified = 400;
        buttonClicked = false;
        print(useridverified);
      });
    }
    return responsedata;
  }

  var errormessage = '';
  var buttonClicked = false;
  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 20, 0, 10),
                // height: 80,
                // width: 80,
                child: Image.asset(
                  'images/logo.png',
                  height: 8.7.h,
                  width: 25.w,
                  fit: BoxFit.fill,
                ),
              ),
              Center(
                child: Container(
                  margin: EdgeInsets.fromLTRB(0, 15, 0, 15),
                  child: Image.asset(
                    'images/forgotpasswordimage.png',
                    // height: 20.h,
                    // width: 40.w,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                // height: 57.5.h,
                margin: EdgeInsets.fromLTRB(0, 5, 0, 0),
                // height: MediaQuery.of(context).size.height * .525,
                padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 1.h),
                // padding: EdgeInsets.fromLTRB(10, 10, 10, 50),
                child: Center(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .01,
                      ),
                      Center(
                        child: Text(
                          "Forgot Password",
                          style: subHeadTextStyle,
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .01,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Center(
                          child: Text(
                            "Please enter your mobile number/email address. We'll send you a confirmation code. We use to ensure the security of our users.",
                            textAlign: TextAlign.justify,
                            style: blackTextStyle,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .01,
                      ),
                      errormessage!.toString().isNotEmpty
                          ? Container(
                              margin: EdgeInsets.fromLTRB(10, 8, 10, 9),
                              child: Center(
                                child: Text(
                                  errormessage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: offlineColor),
                                ),
                              ),
                            )
                          : Text(""),
                      Container(
                        height: MediaQuery.of(context).size.height * .12,
                        margin: EdgeInsets.fromLTRB(15, 10, 15, 0),
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: TextFormField(
                            controller: emailphonenumberController,
                            keyboardType: TextInputType.streetAddress,
                            // autofocus: false,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter your email/mobile number';
                              } else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              hintText: "Enter your email or mobile number",
                              border: new OutlineInputBorder(
                                borderSide: new BorderSide(color: Colors.black),
                                borderRadius: BorderRadius.circular(5.0),
                              ),
                              hintStyle: TextStyle(
                                  fontSize: 15,
                                  color: Colors.black,
                                  fontWeight: FontWeight.w400),
                              errorBorder: UnderlineInputBorder(
                                borderRadius: BorderRadius.circular(7.0),
                                borderSide: BorderSide(
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 1.h,
                      ),
                      buttonClicked == true
                          ? Center(
                              child: CircularProgressIndicator(
                                color: colorBlue2,
                              ),
                            )
                          : Container(
                              child: CustomButton(
                              buttontext: 'Continue',
                              onpress: () async {
                                setState(() {
                                  buttonClicked = true;
                                });
                                Map<String, dynamic> otpvalue =
                                    await forgotPassword(
                                        emailphonenumberController.text);
                                print(otpvalue["otp"]);
                                if (useridverified == 200) {
                                  setState(() {
                                    errormessage = "Otp sent successfully";
                                    buttonClicked = false;
                                  });
                                  route() async {
                                    setState(() {
                                      errormessage = "";
                                    });
                                    var finaluserid =
                                        emailphonenumberController.text;
                                    print(finaluserid);
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => OTPverification(
                                                otpvalue: otpvalue["otp"],
                                                username: finaluserid,
                                              )),
                                    );
                                    emailphonenumberController.clear();
                                  }

                                  startTimer() async {
                                    var duration = Duration(seconds: 2);
                                    return Timer(duration, route);
                                  }

                                  startTimer();
                                } else {
                                  setState(() {
                                    if (emailphonenumberController
                                        .text.isEmpty) {
                                      errormessage =
                                          "Enter your email address or mobile number";
                                    } else {
                                      errormessage =
                                          "Invalid email address or mobile number";
                                    }
                                    // EasyLoading.dismiss();
                                  });
                                }
                              },
                            )),
                      Container(
                        margin: EdgeInsets.fromLTRB(15, 35, 15, 0),
                        child: Center(
                          child: GestureDetector(
                              onTap: () async {
                                final prefs =
                                    await SharedPreferences.getInstance();
                                prefs.setBool("status", false);
                                emailphonenumberController.clear();
                                // showSnackBar("Password Changed Successfully");
                                Navigator.of(context)
                                    .pushReplacement(MaterialPageRoute(
                                  builder: (BuildContext context) =>
                                      AdminLogin(),
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
                      // SizedBox(
                      //   height: MediaQuery.of(context).size.height * .03,
                      // ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.white70]),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void showSnackBar(String title) {
    final snackBar = SnackBar(
      content: Text(title),
      margin: EdgeInsets.only(
        bottom: 450,
        right: 20,
        left: 20,
      ),
      backgroundColor: Colors.blue,
      behavior: SnackBarBehavior.floating,
      action: SnackBarAction(
        label: '',
        disabledTextColor: Colors.white,
        textColor: Colors.yellow,
        onPressed: () {
          //Do whatever you want
        },
      ),
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}

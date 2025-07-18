import 'package:admin_app/api/api.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sizer/sizer.dart';

import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'adminlogin.dart';
import 'custom_widget.dart';

class CreatenewPassword extends StatefulWidget {
  CreatenewPassword({required this.userid, required this.useremail});
  var userid;
  var useremail;
  @override
  State<CreatenewPassword> createState() => _CreatenewPasswordState();
}

class _CreatenewPasswordState extends State<CreatenewPassword> {
  bool _isObscure = true;
  bool _isObscure2 = true;

  final TextEditingController loginIdController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmpasswordController =
      TextEditingController();

  var useridverified;
  Map<String, dynamic> responsedata = {};
  Future<dynamic> resetPassword(var password) async {
    print("userid:${widget.userid}");
    var data = {"email_address": widget.useremail, "password": password};
    const url2 = "${baseUrl}api/update-password";
    var dio = Dio();
    try {
      final response = await dio.post(url2, data: data);
      print("data:${data}");
      setState(() {
        responsedata = response.data;
        print(responsedata);
        print(response.data['code']);
        print("reponse code is: ${response.statusCode}");
        useridverified = response.data['code'];
        print(useridverified);
      });
      print(response.data);
    } catch (e) {
      setState(() {
        useridverified = {"data": 400};

        print(useridverified);
      });
    }

    return responsedata;
  }

  var passworderrormesage = '';
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: SingleChildScrollView(
          child: Column(
            // mainAxisAlignment: MainAxisAlignment.center,
            // crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                margin: EdgeInsets.fromLTRB(0, 4, 0, 0),
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
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 1),
                  child: Image.asset(
                    'images/forgotpasswordimage.png',
                    // height: 40.h,
                    // width: 40.w,
                    fit: BoxFit.fill,
                  ),
                ),
              ),
              Container(
                // height: 40.h,
                // height: MediaQuery.of(context).size.height * .765,
                // width: MediaQuery.of(context).size.width * .96,
                padding: EdgeInsets.fromLTRB(3.w, 2.5.h, 3.w, 1.2.h),
                child: Center(
                  child: Column(
                    // mainAxisAlignment: MainAxisAlignment.start,
                    // crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Text(
                          "Reset Password",
                          style: subHeadTextStyle,
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                        // height: MediaQuery.of(context).size.height * .06,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        child: Center(
                          child: Text(
                            "Your password must be at least 8 characters including letters, and numbers",
                            textAlign: TextAlign.justify,
                            // textScaleFactor: 2,
                            style: blackTextStyle,
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 3.h,
                      ),

                      passworderrormesage!.toString().isNotEmpty
                          ? Container(
                              margin: EdgeInsets.fromLTRB(10, 0, 10, 15),
                              child: Center(
                                child: Text(
                                  passworderrormesage!,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: offlineColor),
                                ),
                              ),
                            )
                          : Container(),
                      Container(
                        height: 10.h,
                        margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: TextFormField(
                            controller: passwordController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText:
                                // true,
                                _isObscure,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter Your Password';
                              } else if (!RegExp("[0-9]").hasMatch(value)) {
                                return 'Your Password must contain atleast one number';
                              } else if (value.length < 8) {
                                return "Your Password must contain 8 characters atleast";
                              }
                              // else if (value.contains(RegExp(r'^[0-9]'))== true) {
                              //   return "Your Password must contain numbers";
                              // }
                              else {
                                return null;
                              }
                            },
                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                color: buttonColor,
                                icon: Icon(
                                  _isObscure
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure = !_isObscure;
                                  });
                                },
                              ),
                              hintText: "New Password",
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
                      Container(
                        height: 10.h,
                        margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                        padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        decoration: BoxDecoration(
                            // color: Colors.white,
                            // Theme.of(context).dividerColor,
                            borderRadius:
                                BorderRadius.all(Radius.circular(10))),
                        child: Center(
                          child: TextFormField(
                            controller: confirmpasswordController,
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            obscureText:
                                // true,
                                _isObscure2,
                            // controller: confirmpasswordController,
                            keyboardType: TextInputType.text,
                            autofocus: false,
                            validator: (value) {
                              if (value!.isEmpty) {
                                return 'Enter Your Password';
                              } else if (value.length < 8) {
                                return "Your Password must contain 8 characters atleast";
                              } else if (passwordController.text !=
                                  confirmpasswordController.text) {
                                return "Your Password doesn't match";
                              } else {
                                return null;
                              }
                            },

                            decoration: InputDecoration(
                              suffixIcon: IconButton(
                                color: buttonColor,
                                icon: Icon(
                                  _isObscure2
                                      ? Icons.visibility_off
                                      : Icons.visibility,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _isObscure2 = !_isObscure2;
                                  });
                                },
                              ),
                              hintText: "Confirm Password",
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
                        height: MediaQuery.of(context).size.height * .03,
                      ),
                      Container(
                          child: CustomButton(
                              buttontext: "Continue",
                              onpress: () async {
                                setState(() {
                                  EasyLoading.show(
                                      status: "Verifying password");
                                });
                                if (passwordController.text ==
                                    confirmpasswordController.text) {
                                  await resetPassword(
                                      confirmpasswordController.text);
                                  if (useridverified == 200) {
                                    setState(() {
                                      EasyLoading.dismiss();
                                    });
                                    showSnackBar(
                                        "Password Changed Successfully");
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => AdminLogin()),
                                    );
                                  } else {
                                    setState(() {
                                      EasyLoading.dismiss();
                                      passworderrormesage =
                                          "Password does not match the minimum specifications";
                                      print("some error occured");
                                    });
                                  }
                                } else {
                                  setState(() {
                                    EasyLoading.dismiss();
                                    passworderrormesage =
                                        "Password does not match the minimum specifications";
                                  });
                                  print(
                                      'Password does not match the minimum specifications');
                                }
                              })),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * .02,
                      ),
                      Container(
                        margin: EdgeInsets.fromLTRB(1, 3, 15, 0),
                        child: Center(
                          child: GestureDetector(
                              onTap: () async {
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
                      //   height: MediaQuery.of(context).size.height * .025,
                      // ),
                      // Container(
                      //   margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                      //   child: Center(
                      //     child: Text("Back to Signin?",
                      //         textAlign: TextAlign.center,
                      //         style: blueColouredTextStyle),
                      //   ),
                      // ),
                    ],
                  ),
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Colors.white70]),
                  // color:
                  // Colors.white,
                  // Color(0xFF2196F3),
                  borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
                  // borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.2),
                    ),
                  ],
                ),

                // color: Color(0xFF0190D7),
              ),
            ],
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

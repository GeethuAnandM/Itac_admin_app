import 'package:admin_app/api/api.dart';
import 'package:admin_app/screens/forgotpassword.dart';
import 'package:dio/dio.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:sizer/sizer.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'package:pin_code_fields/pin_code_fields.dart' as pin_code;
import 'package:pin_code_fields/pin_code_fields.dart';
import 'adminlogin.dart';
import 'createnewpassword.dart';
import 'custom_widget.dart';
import "package:pin_code_fields/pin_code_fields.dart";

class OTPverification extends StatefulWidget {
  OTPverification({required this.otpvalue, required this.username});

  var otpvalue;
  var username;
  @override
  State<OTPverification> createState() => _OTPverificationState();
}

class _OTPverificationState extends State<OTPverification> {
  final TextEditingController otpController = TextEditingController();
  final pinController = PinInputController();
  var errormessage = '';
  var userEnteredValue = '';

  var useridverified;
  Map<String, dynamic> responsedata = {};
  Future<dynamic> forgotPassword(var emailorphonenumber) async {
    var data = {
      "email_address": emailorphonenumber,
      "mobile": emailorphonenumber
    };
    final url2 = "${baseUrl}api/execute-forgot-password";
    var dio = Dio();
    try {
      final response = await dio.post(url2, data: data);
      setState(() {
        responsedata = response.data;
        useridverified = response.statusCode;
        print(useridverified);
      });
      print(response.data);
    } catch (e) {
      setState(() {
        useridverified = 400;
        print(useridverified);
      });
    }
    return responsedata;
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    print(widget.otpvalue);
    return MaterialApp(
      builder: EasyLoading.init(),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Container(
          // height: 100.h,
          child: SingleChildScrollView(
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  margin: EdgeInsets.fromLTRB(0, 10, 0, 0),
                  // height: 80,
                  // width: 80,
                  child: Image.asset(
                    'images/logo.png',
                    height: 6.7.h,
                    width: 20.w,
                    fit: BoxFit.fill,
                  ),
                ),
                Center(
                  child: Container(
                    margin: EdgeInsets.fromLTRB(0, 30, 0, 10),
                    child: Image.asset(
                      'images/forgotpasswordimage.png',
                      // height: 40.h,
                      // width: 40.w,
                      fit: BoxFit.fill,
                    ),
                  ),
                ),
                Container(
                  // height: 78.h,
                  margin: EdgeInsets.fromLTRB(0, 11, 0, 0),
                  // height: MediaQuery.of(context).size.height * .625,
                  // width: MediaQuery.of(context).size.width * .96,
                  padding: EdgeInsets.fromLTRB(3.w, 1.h, 3.w, 3.h),
                  child: Center(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .01,
                        ),
                        Center(
                          child:
                              Text("Forgot Password", style: subHeadTextStyle),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .04,
                        ),
                        // Container(
                        //   margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                        //   child: Row(
                        //     children: [
                        //       Expanded(
                        //         child: Text(
                        //            'Enter the 6 digit verification code that has been sent to',
                        //           style: blackTextStyle,
                        //         ),
                        //       ),
                        //       Text(
                        //         "  ${widget.username.toString()}  ",
                        //         style: blueColouredTextStyle,
                        //       ),
                        //       Expanded(
                        //         child: Text(
                        //           "to reset your password",
                        //           style: blackTextStyle,
                        //         ),
                        //       ),
                        //     ],
                        //   ),
                        // ),
                        Container(
                          margin: EdgeInsets.fromLTRB(10, 0, 10, 0),
                          child: Center(
                            child: Column(
                              children: [
                                RichText(
                                  textAlign: TextAlign.left,
                                  text: TextSpan(
                                    children: <TextSpan>[
                                      TextSpan(
                                        text:
                                            'Enter the 6 digit verification code that has been sent to',
                                        style: blackTextStyle,
                                      ),
                                      TextSpan(
                                          text:
                                              "  ${widget.username.toString()}  ",
                                          style: blueColouredTextStyle),
                                      TextSpan(
                                          text: 'to reset your password',
                                          style: blackTextStyle),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .01,
                        ),
                        errormessage!.toString().isNotEmpty
                            ? Container(
                                margin: EdgeInsets.fromLTRB(10, 0, 8, 11),
                                child: Center(
                                  child: Text(
                                    errormessage!,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(color: offlineColor),
                                  ),
                                ),
                              )
                            : Text(''),

                        SizedBox(
                          height: MediaQuery.of(context).size.height * .01,
                        ),
                        // PinCodeTextField(
                        //   controller: otpController,
                        //   mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //   length: 6,
                        //   obscureText: false,
                        //  // animationType: AnimationType.none,
                        //   pinTheme: PinTheme(
                        //     shape: PinCodeFieldShape.box,
                        //     borderRadius: BorderRadius.circular(5),
                        //     fieldHeight: 50,
                        //     fieldWidth: 40,
                        //     activeColor: Colors.black12,
                        //     inactiveColor: Colors.black26,
                        //     disabledColor: Colors.white,
                        //     selectedFillColor: Colors.white,
                        //     selectedColor: Colors.black26,
                        //     activeFillColor: Colors.white,
                        //     inactiveFillColor: Colors.white,
                        //     errorBorderColor: Colors.white,
                        //   ),
                        //   animationDuration: Duration(milliseconds: 300),
                        //   enableActiveFill: true,
                        //   onCompleted: (v) {
                        //     print("Completed");
                        //   },
                        //   onChanged: (value) {
                        //     print(value);
                        //     print("value is here $value");
                        //     // setState(() {
                        //     //   userEnteredValue = value;
                        //     // });
                        //   },
                        //   beforeTextPaste: (text) {
                        //     print("Allowing to paste $text");
                        //     return true;
                        //   },
                        // ),
                        MaterialPinField(
                          length: 6,
                          pinController: pinController,
                          theme: MaterialPinTheme(
                            shape: MaterialPinShape.outlined,
                            cellSize: const Size(40, 50),
                          ),
                          onChanged: (value) {
                            otpController.text = value;
                          },
                          onCompleted: (value) {
                            otpController.text = value;
                            print("Completed: $value");
                          },
                        ),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .01,
                        ),
                        Container(
                            child: CustomButton(
                                buttontext: 'Continue',
                                onpress: () async {
                                  setState(() {
                                    EasyLoading.show(status: "Verifying OTP");
                                  });
                                  print(userEnteredValue);
                                  print(otpController.text);
                                  if (otpController.text == widget.otpvalue) {
                                    setState(() {
                                      errormessage = "";
                                      otpController.clear();
                                      EasyLoading.dismiss();
                                    });
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) =>
                                              CreatenewPassword(
                                                  userid: widget.username,
                                                  useremail: widget.username)),
                                    );
                                  } else {
                                    setState(() {
                                      if (otpController.text.isEmpty) {
                                        EasyLoading.dismiss();
                                        errormessage = "Enter the OTP";
                                      } else {
                                        EasyLoading.dismiss();
                                        errormessage = "OTP is not matching";
                                      }
                                      // otpController.clear();
                                    });
                                  }
                                })),
                        SizedBox(
                          height: MediaQuery.of(context).size.height * .052,
                        ),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) => ForgotPassword()),
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
                                  child: Center(
                                    child: Text("Change Number?",
                                        textAlign: TextAlign.center,
                                        style: blueColouredTextStyle),
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () async {
                                  setState(() {
                                    EasyLoading.show(status: "Resending OTP");
                                  });
                                  Map<String, dynamic> otpvalue =
                                      await forgotPassword(widget.username);
                                  print(otpvalue["otp"]);
                                  setState(() {
                                    widget.otpvalue = otpvalue["otp"];
                                    print(widget.otpvalue);
                                    EasyLoading.dismiss();
                                  });
                                },
                                child: Center(
                                  child: Text("Resend code",
                                      overflow: TextOverflow.visible,
                                      textAlign: TextAlign.center,
                                      style: blueColouredTextStyle),
                                ),
                              ),
                            ),
                          ],
                        ),
                        // SizedBox(
                        //   height: MediaQuery.of(context).size.height * .04,
                        // ),
                      ],
                    ),
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomRight,
                        colors: [
                          Colors.white,
                          Colors.white70
                          // Color(0xFF0DC200),
                          // Color(0xFF129903),
                        ]),
                    borderRadius:
                        BorderRadius.vertical(top: Radius.circular(30)),
                    boxShadow: [
                      BoxShadow(
                        offset: Offset(0, 1),
                        blurRadius: 4,
                        color: Colors.black.withValues(alpha: 0.2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

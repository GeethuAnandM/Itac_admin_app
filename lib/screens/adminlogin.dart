import 'dart:io';
import 'package:flutter/services.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sizer/sizer.dart';
import '/screens/themes.dart';
import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'custom_widget.dart';
import 'dashboardScreen.dart';
import 'forgotpassword.dart';
import "package:admin_app/api/api.dart";
import 'package:admin_app/utils/gcm_service.dart';

GlobalKey<FormState> LoginFormKey = GlobalKey<FormState>();
var message = "";
bool _isObscure = true;
bool _isChecked = false;
List<dynamic> vehicleList = [];
var deviceLocationList = [];

class AdminLogin extends StatefulWidget {
  @override
  State<AdminLogin> createState() => _AdminLoginState();
}

class _AdminLoginState extends State<AdminLogin> {
  var errormessage;
  bool isError = false;
  bool isLoading = false;
  String? value;
  bool rememberme = false;
  final storage = FlutterSecureStorage();
  final fieldController = TextEditingController();
  final passwordController = TextEditingController();
  var loading;
  Future<String?> loginUsers(
      {username = null, mobile_number = null, password}) async {
    final prefs = await SharedPreferences.getInstance();
    // var orgId= prefs.getString("org_id");
    var dio = Dio();
    final dataBody = {};
    print(username);
    print(mobile_number);
    if (username == null) {
      var data = {"mobile": mobile_number, "password": password};
      dataBody.addAll(data);
    } else {
      var data = {"user_name": username, "password": password};
      dataBody.addAll(data);
    }
    print(dataBody);
    print('${baseUrl}api/update-fcm');
    try {
      final response =
          await dio.post('${baseUrl}api/update-fcm', data: dataBody);
      print("Response code: ${response.statusCode}");
      print("Login Stats: ${response.data['message']}");
      print("Login Stats: ${response.data['user_id']}");
      print("Login Stats: ${response.data}");

      if (response.statusCode == 200) {
        await prefs.setString('org_id', response.data['org_ids'][0].toString());
        await prefs.setString(
            'keycloak_user', response.data['keycloak_user'].toString());
        var keycloakUserId = prefs.getString("keycloak_user");
        print("keyloak user is strored is $keycloakUserId");
        var orgId = prefs.getString("org_id");
        print("user is strored is $orgId");
        if (response.data['message'] == "Successfully logged in") {
          await prefs.setString('user_id', response.data['user_id'].toString());
          var userId = prefs.getString("user_id");
          print("user is strored is $userId");

          await prefs.setString('user_id', response.data['user_id'].toString());
          final int userIdInt = response.data['user_id']; // ← get as int
          // ✅ NEW — Save GCM token to backend
          await GcmService.saveGcmDetails(userId: userIdInt);

          if (_isChecked == true) {
            await prefs.setBool('status', true);
            print(response.data['org_ids'][0]);
            await storage.write(
                key: "org_ids", value: response.data['org_ids'][0].toString());
            // await prefs.setInt('OrgId', response.data['org_ids'][0]);
            value = await storage.read(key: "org_ids");
            print(value);
          } else {
            await storage.write(
                key: "temp_org_ids",
                value: response.data['org_ids'][0].toString());
          }

          return "Successfully logged in";
        } else {
          setState(() {
            message = "'Invalid email/mobile or password'";
          });
          print("else");
          return null;
        }
      } else {
        setState(() {
          message = "'Invalid email/mobile or password'";
        });
      }
      setState(() {
        loading = false;
      });
    } on SocketException {
      setState(() {
        isLoading = false;
        errormessage = 'No Internet connection';
        isError = true;
      });
    } catch (e) {
      print(e);
      setState(() {
        loading = false;
        message = "Invalid Details";
      });
      final String? responseString = "Error";
      return responseString;
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }

  String? validatepassword(value) {
    if (value.isEmpty) {
      return "Enter Password";
    } else if (value.length < 5) {
      return "Should Be Atleast 5 Characters";
    } else if (value.length > 20) {
      return "Should Not Be More Than 20 Characters";
    }
  }

  void _handleRemeberme(bool value) {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setBool("remember_me", value);
    });

    setState(() {
      _isChecked = value;
    });
  }

  void _loadUserEmailPassword() async {
    print("Load Email");
    try {
      SharedPreferences _prefs = await SharedPreferences.getInstance();
      var _email = _prefs.getString("email") ?? "";
      var _password = _prefs.getString("password") ?? "";
      var _remeberMe = _prefs.getBool("remember_me") ?? false;

      print(_remeberMe);
      print(_email);
      print(_password);
      if (_remeberMe) {
        setState(() {
          _isChecked = true;
        });
        fieldController.text = _email ?? "";
        passwordController.text = _password ?? "";
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  void initState() {
    () async {
      _loadUserEmailPassword();
      final prefs = await SharedPreferences.getInstance();
      bool? status = prefs.getBool("status");
      if (status == false || status == null) {
        return;
      } else {
        Navigator.of(context)
            .pushReplacement(MaterialPageRoute(builder: (BuildContext context) {
          return Dashboard();
        }));
      }
    }();
    super.initState();
  }

  Future<bool> _onwillscope(BuildContext context) async {
    return false;
  }

  @override
  void setState(fn) {
    if (mounted) {
      super.setState(fn);
    }
  }

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.manual, overlays: []);
    String user = "";
    String mobileNumber = "";
    return Sizer(builder: (BuildContext context, Orientation, DeviceType) {
      return WillPopScope(
          onWillPop: () => _onwillscope(context),
          child: isError == true
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      LottieBuilder.asset(
                        "images/82529-no-network.json",
                      ),
                      Text(errormessage ?? "No Internet connection"),
                    ],
                  ),
                )
              : loading == true
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : Scaffold(
                      resizeToAvoidBottomInset: false,
                      backgroundColor: Color(0xFFFAF8F8),
                      body: SafeArea(
                        child: SingleChildScrollView(
                          child: Column(children: [
                            // SizedBox(
                            //   height: 3.h,
                            // ),
                            Text("Welcome  to",
                                style: TextStyle(
                                    color: blackColor,
                                    fontSize: 20,
                                    fontWeight: FontWeight.w600)),
                            // SizedBox(
                            //   height: 2.h,
                            // ),
                            Container(
                              color: Color(0xFFFAF8F8),
                              margin: EdgeInsets.fromLTRB(0, 0, 0, 10),
                              // height: 80,
                              // width: 80,
                              child: Image.asset(
                                'images/logo.png',
                                height: 8.4.h,
                                width: 25.w,
                                fit: BoxFit.fill,
                              ),
                            ),
                            Container(
                              height:
                                  MediaQuery.of(context).viewInsets.bottom == 0
                                      ? size.height * 0.39
                                      : size.height * 0.2,
                              width:
                                  MediaQuery.of(context).viewInsets.bottom == 0
                                      ? size.width * 8
                                      : size.width * 0.5,
                              decoration: const BoxDecoration(
                                color: Color(0xFFFAF8F8),
                                image: DecorationImage(
                                  fit: BoxFit.fitWidth,
                                  opacity: 1,
                                  image: AssetImage(
                                    "images/adminimage2.png",
                                  ),
                                ),
                              ),
                            ),
                            Container(
                                child: SingleChildScrollView(
                                    reverse: true,
                                    child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          // SizedBox(
                                          //   height: 285,
                                          //   child: Container(
                                          //       child: Image(
                                          //     image: AssetImage("images/adminimage2.png"),
                                          //     width: 500,
                                          //     height: 100,
                                          //   )),
                                          // ),
                                          Material(
                                              shape:
                                                  const RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.only(
                                                topLeft: Radius.circular(30),
                                                topRight: Radius.circular(30),
                                              )),
                                              child: Container(
                                                  height: message == ""
                                                      ? 44.h
                                                      : 48.h,
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topLeft:
                                                          Radius.circular(30),
                                                      topRight:
                                                          Radius.circular(30),
                                                    ),
                                                    color: commonTextStyle,
                                                  ),
                                                  child: Padding(
                                                      padding:
                                                          EdgeInsets.fromLTRB(
                                                              4.w,
                                                              04.h,
                                                              4.w,
                                                              0.h),
                                                      child: Center(
                                                          child: Column(
                                                              mainAxisAlignment:
                                                                  MainAxisAlignment
                                                                      .start,
                                                              children: [
                                                            Form(
                                                                key:
                                                                    LoginFormKey,
                                                                child: Column(
                                                                    children: <Widget>[
                                                                      TextFormField(
                                                                        // autovalidateMode:
                                                                        //     AutovalidateMode
                                                                        //         .onUserInteraction,
                                                                        controller:
                                                                            fieldController,
                                                                        keyboardType:
                                                                            TextInputType.text,
                                                                        autofocus:
                                                                            false,
                                                                        validator:
                                                                            (value) {
                                                                          final bool
                                                                              emailValid =
                                                                              RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!);
                                                                          if (emailValid == false &&
                                                                              value.contains('@') ==
                                                                                  false) {
                                                                            if (value.contains(RegExp(r'^[0-9]*$')) ==
                                                                                false) {
                                                                              if (value.isEmpty || !RegExp(r'^[+]*[(]{0,1}[0-9]{1,4}[)]{0,1}[-\s\./0-9]*$').hasMatch(value)) {
                                                                                return null;
                                                                              } else {
                                                                                return 'Enter Your Username/ Email / Mobile No';
                                                                              }
                                                                            } else {
                                                                              if (value.isEmpty || value.length != 10) {
                                                                                return 'Enter Your Username/ Email / Mobile No';
                                                                              } else {
                                                                                return null;
                                                                              }
                                                                            }
                                                                          } else if (emailValid ==
                                                                              true) {
                                                                            return null;
                                                                          } else {
                                                                            return 'Enter Your Username/ Email / Mobile No';
                                                                          }
                                                                        },
                                                                        decoration:
                                                                            InputDecoration(
                                                                          floatingLabelBehavior:
                                                                              FloatingLabelBehavior.always,
                                                                          label:
                                                                              Row(
                                                                            children: const [
                                                                              Text('*', style: TextStyle(color: redColor)),
                                                                              Padding(
                                                                                padding: EdgeInsets.all(3.0),
                                                                              ),
                                                                              Text(
                                                                                "Email Id / Mobile Number",
                                                                                style: TextStyle(color: blackColor, fontWeight: FontWeight.w700),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          hintText:
                                                                              "Email Id/Mobile Number",
                                                                          border:
                                                                              new OutlineInputBorder(
                                                                            borderSide:
                                                                                new BorderSide(color: blackColor),
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                          hintStyle: TextStyle(
                                                                              fontSize: 15,
                                                                              color: blackColor,
                                                                              fontWeight: FontWeight.w300),
                                                                          errorBorder:
                                                                              UnderlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(6.0),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: redColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      SizedBox(
                                                                          height:
                                                                              3.h),
                                                                      TextFormField(
                                                                        controller:
                                                                            passwordController,
                                                                        autofocus:
                                                                            false,
                                                                        validator:
                                                                            validatepassword,
                                                                        obscureText:
                                                                            _isObscure,
                                                                        keyboardType:
                                                                            TextInputType.text,
                                                                        decoration:
                                                                            InputDecoration(
                                                                          floatingLabelBehavior:
                                                                              FloatingLabelBehavior.always,
                                                                          suffixIcon:
                                                                              IconButton(
                                                                            color:
                                                                                buttonColor,
                                                                            icon:
                                                                                Icon(
                                                                              _isObscure ? Icons.visibility_off : Icons.visibility,
                                                                              size: 20,
                                                                            ),
                                                                            onPressed:
                                                                                () {
                                                                              setState(() {
                                                                                _isObscure = !_isObscure;
                                                                              });
                                                                            },
                                                                          ),
                                                                          label:
                                                                              Row(
                                                                            children: [
                                                                              const Text('*', style: TextStyle(color: redColor)),
                                                                              Padding(
                                                                                padding: EdgeInsets.all(3.0),
                                                                              ),
                                                                              Text(
                                                                                "Password",
                                                                                style: TextStyle(color: blackColor, fontWeight: FontWeight.w700),
                                                                              )
                                                                            ],
                                                                          ),
                                                                          hintText:
                                                                              "Enter Password",
                                                                          border:
                                                                              new OutlineInputBorder(
                                                                            borderSide:
                                                                                new BorderSide(color: blackColor),
                                                                            borderRadius:
                                                                                BorderRadius.circular(10.0),
                                                                          ),
                                                                          hintStyle: TextStyle(
                                                                              fontSize: 15,
                                                                              color: blackColor,
                                                                              fontWeight: FontWeight.w300),
                                                                          errorBorder:
                                                                              UnderlineInputBorder(
                                                                            borderRadius:
                                                                                BorderRadius.circular(6.0),
                                                                            borderSide:
                                                                                BorderSide(
                                                                              color: redColor,
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      // SizedBox(
                                                                      //   height: 2.h,
                                                                      // ),
                                                                      message.isNotEmpty
                                                                          ? Container(
                                                                              margin: EdgeInsets.fromLTRB(0, 1.h, 0, 1.h),
                                                                              // height: 20,
                                                                              child: Text(
                                                                                message,
                                                                                style: TextStyle(color: Colors.red, fontSize: 20),
                                                                              ),
                                                                            )
                                                                          : SizedBox(),
                                                                      Row(
                                                                          mainAxisAlignment:
                                                                              MainAxisAlignment.spaceBetween,
                                                                          children: [
                                                                            Row(
                                                                              children: [
                                                                                Checkbox(
                                                                                  activeColor: Color(0xff00C8E8),
                                                                                  value: _isChecked,
                                                                                  onChanged: (val) {
                                                                                    _handleRemeberme(val!);
                                                                                  },
                                                                                ),
                                                                                const Text("Remember Me")
                                                                              ],
                                                                            ),
                                                                            Container(
                                                                                child: TextButton(
                                                                                    style: ButtonStyle(backgroundColor: MaterialStateProperty.all<Color>(commonTextStyle)),
                                                                                    onPressed: () {
                                                                                      Navigator.pushReplacement(
                                                                                        context,
                                                                                        MaterialPageRoute(builder: (context) => ForgotPassword()),
                                                                                      );
                                                                                    },
                                                                                    child: Text(
                                                                                      "Forgot Password?",
                                                                                      style: normalColorTextStyle,
                                                                                    ))),
                                                                          ]),
                                                                      SizedBox(
                                                                        height:
                                                                            4.h,
                                                                      ),
                                                                      Container(
                                                                          child:
                                                                              CustomButton(
                                                                        buttontext:
                                                                            'Login',
                                                                        onpress:
                                                                            () async {
                                                                          var response;
                                                                          message =
                                                                              "";
                                                                          LoginFormKey
                                                                              .currentState
                                                                              ?.validate();
                                                                          if (fieldController.text.contains(RegExp(r'^[0-9]*$')) ==
                                                                              true) {
                                                                            mobileNumber =
                                                                                fieldController.text;
                                                                            response =
                                                                                await loginUsers(password: passwordController.text, mobile_number: mobileNumber);
                                                                          } else {
                                                                            user =
                                                                                fieldController.text;
                                                                            response =
                                                                                await loginUsers(password: passwordController.text, username: user);
                                                                          }
                                                                          if (response ==
                                                                              "Successfully logged in") {
                                                                            message =
                                                                                " ";
                                                                            if (_isChecked) {
                                                                              final prefs = await SharedPreferences.getInstance();

                                                                              await prefs.setString(
                                                                                "email",
                                                                                fieldController.text.trim(),
                                                                              );

                                                                              await prefs.setString(
                                                                                "password",
                                                                                passwordController.text,
                                                                              );

                                                                              await prefs.setBool(
                                                                                "remember_me",
                                                                                true,
                                                                              );
                                                                            }
                                                                            Navigator.pushReplacement(
                                                                              context,
                                                                              MaterialPageRoute(builder: (context) => Dashboard()),
                                                                            );
                                                                          } else {
                                                                            if (fieldController.text.isEmpty) {
                                                                              message = " ";
                                                                            } else {
                                                                              // setState(() {
                                                                              //   message =
                                                                              //   "Invalid Username/Password!";
                                                                              // });
                                                                            }
                                                                          }
                                                                        },
                                                                      )),
                                                                      SizedBox(
                                                                        height:
                                                                            8,
                                                                      ),
                                                                      Text(
                                                                        "All rights reserved © ${DateTime.now().year} cogniphi.com",
                                                                        style:
                                                                            TextStyle(
                                                                          color:
                                                                              Color(0xFF848282),
                                                                        ),
                                                                      )
                                                                    ]))
                                                          ])))))
                                        ])))
                          ]),
                        ),
                      )));
    });
  }
}

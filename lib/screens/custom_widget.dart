import '/screens/themes.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';


class CustomButton extends StatelessWidget {
  CustomButton({
    required this.buttontext, this.loader,
    required this.onpress
  });
  var buttontext;
  var onpress;
  Widget? loader;

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: MediaQuery.of(context).size.height * .055 ,
      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      width: MediaQuery.of(context).size.width * .99,
      child: FloatingActionButton(
        heroTag: "f2",
        backgroundColor: buttonColor,
        onPressed: onpress,
        elevation: 0,
        // padding: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
        ),
        child: Center(child: Text(buttontext, style:TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)  ,)),
      ),
    );
  }
}



class CustomButton2 extends StatelessWidget {
  CustomButton2({
    required this.buttontext, this.loader,
    required this.onpress
  });
  var buttontext;
  var onpress;
  Widget? loader;

  @override
  Widget build(BuildContext context) {
    return  Container(
      height: MediaQuery.of(context).size.height * .055 ,
      margin: EdgeInsets.fromLTRB(15, 0, 15, 0),
      padding: EdgeInsets.fromLTRB(10, 0, 10, 0),
      width: MediaQuery.of(context).size.width * .99,
      child: FloatingActionButton(
        heroTag: "f1",
        backgroundColor: redButtonColor,
        onPressed: onpress,
        elevation: 0,
        // padding: EdgeInsets.all(18),
        shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30)
        ),
        child: Center(child: Text(buttontext, style:TextStyle(fontWeight: FontWeight.bold, fontSize: 19, color: Colors.white)  ,)),
      ),
    );
  }
}
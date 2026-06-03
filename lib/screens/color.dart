import 'package:flutter/material.dart';


ThemeData? activeTheme;

final blueAndIndigoTheme = ThemeData(
  floatingActionButtonTheme:FloatingActionButtonThemeData(
      backgroundColor:Colors.indigo
  ) ,
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.indigo,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
  )),
  // scaffoldBackgroundColor: Colors.blue,
  iconTheme: IconThemeData(color: Colors.blue),
  primaryColor: Colors.blue,
  primarySwatch:Colors.blue,
  brightness: Brightness.light,
  backgroundColor: Colors.blue,
  // shadowColor: Colors.indigo,
  // cardColor: Colors.indigo,
  textTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Colors.black),
      headline1: TextStyle(color: Colors.black),
      headline2: TextStyle(color: Colors.black),
      headline3: TextStyle(color: Colors.black),
      headline4: TextStyle(color: Colors.black),
      headline5: TextStyle(color: Colors.black),
      headline6: TextStyle(color: Colors.black),
      subtitle1: TextStyle(color: Colors.black),
      button: TextStyle(color:Colors.indigo),
      caption: TextStyle(color: Colors.black)),
);

final deepPurpleAndAmberTheme = ThemeData(
  floatingActionButtonTheme:FloatingActionButtonThemeData(
      backgroundColor:Colors.amber,
  ) ,
  backgroundColor: Colors.deepPurple,
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.amber,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
  )),
  // scaffoldBackgroundColor: Colors.amberAccent,
  primarySwatch: Colors.deepPurple,
  accentColor: Colors.deepPurple,
  brightness: Brightness.light,
  textTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Colors.black),
      headline1: TextStyle(color: Colors.black),
      headline2: TextStyle(color: Colors.black),
      headline3: TextStyle(color: Colors.black),
      headline4: TextStyle(color: Colors.black),
      headline5: TextStyle(color: Colors.black),
      headline6: TextStyle(color: Colors.black),
      subtitle1: TextStyle(color: Colors.black),
      button: TextStyle(color:Colors.amber),
      caption: TextStyle(color: Colors.black)),
);

final pinkAndBlueGreyTheme = ThemeData(
  appBarTheme: AppBarTheme(
    backgroundColor:Colors.pink
  ),
  floatingActionButtonTheme:FloatingActionButtonThemeData(
    backgroundColor:Colors.grey,
  ) ,
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.grey,
  ),
  iconTheme: IconThemeData(color:Colors.white),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
  )),
  backgroundColor: Colors.pink,
  accentColor:Colors.pink,
  primaryColor: Colors.pink,
  // scaffoldBackgroundColor: Colors.pink,
  primarySwatch: Colors.pink,
  brightness: Brightness.dark,
  textTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.white),
      bodyText2: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Colors.white),
      headline1: TextStyle(color: Colors.black),
      headline2: TextStyle(color: Colors.black),
      headline3: TextStyle(color: Colors.black),
      headline4: TextStyle(color: Colors.black),
      headline5: TextStyle(color: Colors.black),
      headline6: TextStyle(color: Colors.black),
      subtitle1: TextStyle(color: Colors.black),
      button: TextStyle(color:Colors.grey,),
      caption: TextStyle(color: Colors.black)),
);

final indigoAndPinkTheme = ThemeData(
  floatingActionButtonTheme:FloatingActionButtonThemeData(
    backgroundColor:Colors.pink,
  ) ,
  buttonTheme: ButtonThemeData(
    buttonColor: Colors.pink,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
      style: TextButton.styleFrom(
    backgroundColor: Colors.white,
    foregroundColor: Colors.black,
  )),
  backgroundColor: Colors.indigo,
  accentColor:Colors.indigo,
  // scaffoldBackgroundColor: Colors.pinkAccent,
  primarySwatch: Colors.indigo,
  primaryColor: Colors.indigo,
  brightness: Brightness.light,
  textTheme: TextTheme(
      bodyText1: TextStyle(color: Colors.black),
      bodyText2: TextStyle(color: Colors.black),
      subtitle2: TextStyle(color: Colors.black),
      headline1: TextStyle(color: Colors.black),
      headline2: TextStyle(color: Colors.black),
      headline3: TextStyle(color: Colors.black),
      headline4: TextStyle(color: Colors.black),
      headline5: TextStyle(color: Colors.black),
      button: TextStyle(color:Colors.pink),
      headline6: TextStyle(color: Colors.black),
      subtitle1: TextStyle(color: Colors.black),
      caption: TextStyle(color: Colors.black)),
);



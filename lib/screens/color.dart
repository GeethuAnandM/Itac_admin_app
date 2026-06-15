import 'package:flutter/material.dart';

ThemeData? activeTheme;

final blueAndIndigoTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.blue,
    iconTheme: IconThemeData(color: Colors.white),
    foregroundColor: Colors.white,
  ),
  secondaryHeaderColor: Colors.white,
  canvasColor: Colors.white,
  cardColor: Colors.white,
  floatingActionButtonTheme:
      FloatingActionButtonThemeData(backgroundColor: Colors.indigo),
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
  primarySwatch: Colors.blue,
  brightness: Brightness.light,
  scaffoldBackgroundColor: Colors.white,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    titleSmall: TextStyle(color: Colors.black),
    displayLarge: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.black),
    displaySmall: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(color: Colors.black),
    headlineSmall: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: Colors.black),
    labelLarge: TextStyle(color: Colors.indigo),
    bodySmall: TextStyle(color: Colors.black),
  ),
);

final deepPurpleAndAmberTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.deepPurple,
    iconTheme: IconThemeData(color: Colors.white),
    foregroundColor: Colors.white,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.deepPurple,
    primary: Colors.deepPurple,
    secondary: Colors.amber,
    brightness: Brightness.light,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.amber,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  ),
  scaffoldBackgroundColor: Colors.white,
  primaryColor: Colors.deepPurple,
  brightness: Brightness.light,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    titleSmall: TextStyle(color: Colors.black),
    displayLarge: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.black),
    displaySmall: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(color: Colors.black),
    headlineSmall: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: Colors.black),
    labelLarge: TextStyle(color: Colors.amber),
    bodySmall: TextStyle(color: Colors.black),
  ),
);

final pinkAndBlueGreyTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.pink,
    primary: Colors.pink,
    secondary: Colors.grey,
    brightness: Brightness.dark,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: Colors.pink,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.grey,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  ),
  iconTheme: IconThemeData(color: Colors.white),
  scaffoldBackgroundColor: Colors.grey,
  primaryColor: Colors.pink,
  brightness: Brightness.dark,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.white),
    bodyMedium: TextStyle(color: Colors.black),
    titleSmall: TextStyle(color: Colors.white),
    displayLarge: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.black),
    displaySmall: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(color: Colors.black),
    headlineSmall: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: Colors.black),
    labelLarge: TextStyle(color: Colors.grey),
    bodySmall: TextStyle(color: Colors.black),
  ),
);

final indigoAndPinkTheme = ThemeData(
  appBarTheme: const AppBarTheme(
    backgroundColor: Colors.indigo,
    iconTheme: IconThemeData(color: Colors.white),
    //foregroundColor: Colors.white,
  ),
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.indigo,
    primary: Colors.indigo,
    secondary: Colors.pink,
    brightness: Brightness.light,
  ),
  floatingActionButtonTheme: FloatingActionButtonThemeData(
    backgroundColor: Colors.pink,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
    ),
  ),
  scaffoldBackgroundColor: Colors.white,
  primaryColor: Colors.indigo,
  brightness: Brightness.light,
  textTheme: TextTheme(
    bodyLarge: TextStyle(color: Colors.black),
    bodyMedium: TextStyle(color: Colors.black),
    titleSmall: TextStyle(color: Colors.black),
    displayLarge: TextStyle(color: Colors.black),
    displayMedium: TextStyle(color: Colors.black),
    displaySmall: TextStyle(color: Colors.black),
    headlineMedium: TextStyle(color: Colors.black),
    headlineSmall: TextStyle(color: Colors.black),
    titleLarge: TextStyle(color: Colors.black),
    titleMedium: TextStyle(color: Colors.black),
    labelLarge: TextStyle(color: Colors.pink),
    bodySmall: TextStyle(color: Colors.black),
  ),
);

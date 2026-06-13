import 'package:flutter/material.dart';
import 'package:sizer/sizer.dart';
import 'dart:io';

double get iosFontAdjustment => Platform.isIOS ? 6.0 : 0.0;
final subHeadTextStyle =
    TextStyle(fontSize: 23.sp, fontWeight: FontWeight.w500, color: blueColor);
const normalTextStyle =
    TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: black87Color);
const normalColorTextStyle =
    TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: blueColor);
const manageVehiclePageSearchTextStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w400, color: searchPageColor);

const black87Color = Colors.black87;
const buttonColor = Color(0xFF02B3FC);
const redButtonColor = Color(0xFFE51818);

const blueColor = Color(0xFF2196F3);
const greenColor = Color(0xFF40C946);
const commonTextStyle = Color(0xFFFFFFFF);
const blackColor = Color(0xFF000000);
const redColor = Color(0xFFFF0000);
const greyColor = Color(0xFFEEEEEE);
const darkgreyColor = Color(0xFFA1A1A1);
const lightblueColor = Color(0xFFE0EAFF);
const creamColor = Color(0xFFFFF1F1);

const colorBlue2 = Color(0xFF0F65E7);
const colorBlack = Colors.black87;
const colorOrange = Color(0xFFF28017);

const colorWhite = Colors.white;
const onlineColor = Color(0xFF009E06);
const offlineColor = Color(0xFFE02C2C);
const stoppedColor = Color(0xFF0F65E7);
const offlineOrangeColor = Color(0xFFF28017);
const searchPageColor = Colors.grey;
const iconColourGreen = Color(0xFF009E06);
const movingColor = Color(0xFF009E06);
const iconColourRed = Color(0xFFE02C2C);
const iconColourWhite = Color(0xFFFFFFFF);
const buttonColourBlue = Color(0xFF2196F3);
const buttonTextColourWhite = Colors.white;
const normalTextBlackColour = Colors.black87;
const textColourBlue = Color(0xFF2196F3);
const borderColourBlack = Colors.black87;
const searchBoxColorWhite = Colors.white;

const appBarTextStyle = TextStyle(
    fontSize: 22, fontWeight: FontWeight.w600, color: normalTextBlackColour);
const subHeadTextStyleSmallFont =
    TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: textColourBlue);
final blackTextStyle = TextStyle(
    fontSize: 12.sp + iosFontAdjustment,
    fontWeight: FontWeight.w400,
    color: normalTextBlackColour,
    height: 1.5);
final blueColouredTextStyle = TextStyle(
    fontSize: 11.sp + iosFontAdjustment, fontWeight: FontWeight.w700, color: textColourBlue);
const buttonTextStyle = TextStyle(
    fontWeight: FontWeight.bold, fontSize: 19, color: buttonTextColourWhite);
const whiteTextStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w400, color: buttonTextColourWhite);

//vehicle page
const vehiclePageCardTextNormalLowSizeTextStyle = TextStyle(
    fontSize: 11, fontWeight: FontWeight.w500, color: normalTextBlackColour);
const vehiclePageCardTextStyle =
    TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: textColourBlue);
const vehiclePageCardTextSubHeadRedStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: offlineColor,
    height: 1.5);
const vehiclePageCardTextSubHeadOrangeStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w500, color: colorOrange, height: 1.5);

const vehiclePageCardTextSubHeadStyle = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: normalTextBlackColour,
    height: 1);
const TripsPageTextSubHeadStyle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w400,
    color: normalTextBlackColour,
    height: 1);

// const vehiclePageCardTextSubHeadStyle = TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: normalTextBlackColour, height: 1.5 );
final vehiclePageCardTextSubHeadAutoStyle = TextStyle(
    fontSize: 12.sp,
    fontWeight: FontWeight.w500,
    color: normalTextBlackColour,
    height: 1.5);
const vehiclePageCardTextNormalTextStyle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500, color: normalTextBlackColour);
const vehiclePageCardTextNormalTextRedStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500, color: vehiclePageCardTextColor);
const vehiclePageCardTextNormalWhiteStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500, color: buttonTextColourWhite);
const vehiclePageCardTextColor = Color(0xFFE02C2C);
const eventsPageCardHeadTextStyle = TextStyle(
    fontSize: 16, fontWeight: FontWeight.w600, color: vehiclePageCardTextColor);
const eventsPageCardTextNormalTextStyle = TextStyle(
    fontSize: 13, fontWeight: FontWeight.w500, color: normalTextBlackColour);

//icons
final signalIconRed = Icon(
  Icons.signal_cellular_alt,
  size: 25,
  color: iconColourRed,
);
final signalIconGreen = Icon(
  Icons.signal_cellular_alt,
  size: 25,
  color: iconColourGreen,
);
final keyIconRed = Icon(Icons.key_off, size: 25, color: iconColourRed);
final keyIconGreen = Icon(
  Icons.key_sharp,
  size: 25,
  color: iconColourGreen,
);
final highPriorityIcon = Icon(
  Icons.priority_high,
  size: 25,
  color: iconColourWhite,
);
final criticalPriorityIcon = Icon(
  Icons.priority_high,
  size: 25,
  color: iconColourWhite,
);
final mediumPriorityIcon = Icon(
  Icons.priority_high,
  size: 25,
  color: iconColourWhite,
);
final lowPriorityIcon = Icon(
  Icons.priority_high,
  size: 25,
  color: iconColourWhite,
);
final locationIconRed = Icon(
  Icons.location_on,
  size: 25,
  color: iconColourWhite,
);
final searchIcon = Icon(
  Icons.search,
  size: 25,
  color: searchPageColor,
);
final editIcon = Icon(
  Icons.edit_note,
  size: 25,
  color: colorWhite,
);
final deleteIcon = Icon(
  Icons.delete_outline_rounded,
  size: 25,
  color: colorWhite,
);
final onlineIcon = Icon(
  Icons.radar,
  size: 25,
  color: movingColor,
);
final offlineIcon = Icon(
  Icons.radar,
  size: 25,
  color: stoppedColor,
);

final calendarIcon = Icon(
  Icons.calendar_month,
  size: 25,
  color: colorOrange,
);

final keyIconOrange =
    Icon(Icons.calendar_view_day_rounded, size: 25, color: colorOrange);
final carIconOrange =
    Icon(Icons.call_to_action_rounded, size: 25, color: colorOrange);
final vinIconOrange =
    Icon(Icons.confirmation_num, size: 25, color: colorOrange);
final gpsIconOrange = Icon(Icons.gps_fixed_sharp, size: 25, color: colorOrange);
final manufacturerIconOrange =
    Icon(Icons.precision_manufacturing, size: 25, color: colorOrange);

const colorBlue3 = Color(0xFF3779DC);
const vehiclePageCardTextNormalTextWhiteStyle =
    TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: colorWhite);
const vehiclePageCardTextNormalTextBlueStyle =
    TextStyle(fontSize: 13, fontWeight: FontWeight.w500, color: blueColor);
const vehiclePageCardTextNormalTextGreenStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.w500, color: iconColourGreen);
final keyIconOrangeColor = Icon(Icons.key_off, size: 25, color: colorOrange);
const OfflineColor = Color(0xFF0F65E7);

// COLORS FOR TRIPSTATUS
const NotStartedBackgroundColor = Color(0xFFDAD0EB);
const unplannedBackgroundColor = Color(0xFFF8F5F5);
const unplannedTextColor = Color(0xFF241538);
const NotStartedTextColor = Color(0xFF5D438A);
const CompletedBackgroundColor = Color(0xFFCDFFCD);
const CompletedTextColor = Colors.black;
const InprogressBackgroundColor = Color(0xFFADCDF2);
const InprogressTextColor = Color(0xFF0063D6);
const CancelledBackgroundColor = Color(0xFFFFE0E0);
const CancelledTextColor = Color(0xFFD30000);
const InprogressTextStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.bold, color: InprogressTextColor);
const NotStartedTextStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.bold, color: NotStartedTextColor);
const CancelledTextStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.bold, color: CancelledTextColor);
const CompletedTextStyle = TextStyle(
    fontSize: 14, fontWeight: FontWeight.bold, color: CompletedTextColor);

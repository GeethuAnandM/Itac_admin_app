import 'package:intl/intl.dart';

var deviceID;
var vehSpeed = 0;
// var singleOrCluster = "Cluster";
var SelectedVehCoords;
var vehicleName = "";
var deviceName = "";
var tripList = [];
var vehName;
var urlList2;

dateFormatter(date) {
  // print("passed date: ${date}");
  var formattedDate;

  var dateFormat1 = DateFormat("yyyy-MM-dd hh:mm:ss a");
  if (date != null) {
    DateTime date1 = DateFormat("yyyy-MM-dd hh:mm:ss")
        .parse(date.toString().replaceAll('T', ' '));
    formattedDate = dateFormat1.format(date1);
  } else {
    date = DateTime.parse("1970-01-01 01:01:01");
    DateTime date1 = DateFormat("yyyy-MM-dd hh:mm:ss").parse(date).toLocal();
    formattedDate = dateFormat1.format(date1);
  }
  return formattedDate;
}

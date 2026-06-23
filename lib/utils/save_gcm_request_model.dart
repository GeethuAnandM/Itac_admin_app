class SaveGcmRequestModel {
  final String imei;
  final String gcm;
  final String type;
  final String deviceType;
  final String appVersion;
  final String osVersion;
  final String loginTime;
  final String appCode;
  final int userId;

  SaveGcmRequestModel({
    required this.imei,
    required this.gcm,
    required this.type,
    required this.deviceType,
    required this.appVersion,
    required this.osVersion,
    required this.loginTime,
    required this.appCode,
    required this.userId,
  });

  Map<String, dynamic> toJson() {
    return {
      "imei": imei,
      "gcm": gcm,
      "type": type,
      "deviceType": deviceType,
      "appVersion": appVersion,
      "osVersion": osVersion,
      "loginTime": loginTime,
      "appCode": appCode,
      "userId": userId,
    };
  }
}
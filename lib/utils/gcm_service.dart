import 'dart:io';
import 'package:admin_app/utils/save_gcm_request_model.dart';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:admin_app/api/api.dart';

class GcmService {
  static Future<void> saveGcmDetails({required int userId}) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Read cached FCM token
      final String? fcmToken = prefs.getString('fcm_token');
      if (fcmToken == null || fcmToken.isEmpty) {
        print('⚠️ GcmService: FCM token not found in cache. Skipping saveGcmDetails.');
        return;
      }

      // Get app version dynamically
      final PackageInfo packageInfo = await PackageInfo.fromPlatform();
      final String appVersion = packageInfo.version;

      // Get OS version and device type
      final String deviceType = Platform.isIOS ? 'iOS' : 'Android';
      final String osVersion = Platform.operatingSystemVersion;
      print('📤 GcmService: ${DateTime.now().toIso8601String()}');
      

      // Build request model
      final SaveGcmRequestModel requestBody = SaveGcmRequestModel(
        imei: fcmToken,               // IMEI not available on modern iOS; using FCM token as a placeholder
        gcm: fcmToken,
        type: 'FCM',
        deviceType: deviceType,
        appVersion: appVersion,
        osVersion: osVersion,
        loginTime: DateTime.now().toIso8601String(),
        appCode: 'AdminApp',
        userId: userId,
      );

      print('📤 GcmService: Sending saveGcmDetails request to ${baseUrl}saveGcmDetails');
      print('📤 GcmService: Request body: ${requestBody.toJson()}');

      final dio = Dio();
      final response = await dio.post(
        '${baseUrl}saveGcmDetails',
        data: requestBody.toJson(),
        options: Options(
          headers: {'Content-Type': 'application/json'},
          receiveDataWhenStatusError: true,
        ),
      );

      print('✅ GcmService: saveGcmDetails success | Status: ${response.statusCode}');
      print('✅ GcmService: Response data: ${response.data}');

    } on DioError catch (e) {
      print('❌ GcmService: DioException in saveGcmDetails');
      print('❌ Status code: ${e.response?.statusCode}');
      print('❌ Response data: ${e.response?.data}');
      print('❌ Error message: ${e.message}');
    } catch (e) {
      print('❌ GcmService: Unexpected error in saveGcmDetails: $e');
    }
  }
}
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:convert';

class VersionCheckResult {
  final bool forceUpdate;
  final String latestVersionName;
  final int latestVersionCode;
  final int minSupportedVersionCode;
  final String releaseNotes;

  VersionCheckResult({
    required this.forceUpdate,
    required this.latestVersionName,
    required this.latestVersionCode,
    required this.minSupportedVersionCode,
    required this.releaseNotes,
  });

  // Parse from the nested "data" object, not the root
  factory VersionCheckResult.fromJson(Map<String, dynamic> data) {
    return VersionCheckResult(
      forceUpdate: data['forceUpdate'] ?? false,
      latestVersionName: data['latestVersionName'] ?? '',
      latestVersionCode: data['latestVersionCode'] ?? 0,
      minSupportedVersionCode: data['minSupportedVersionCode'] ?? 0,
      releaseNotes:
          data['releaseNotes'] ?? 'Please update the app to continue.',
    );
  }
}

class ForceUpdateService {
  static const String _baseVersionUrl =
      'http://13.233.175.113:8081/gateway/api/version';

  static const String _baseVersionUrlMock =
      'https://3c82e324-13fc-4203-9502-56fb288e1bc6.mock.pstmn.io/getVersion';

  static const String _appType = 'adminapp';

  static Future<VersionCheckResult?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();

      // buildNumber = versionCode on Android, CFBundleVersion on iOS
      final int currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
      print("packageInfo Version: ${packageInfo.version}");
      print("packageInfo Build Number: ${packageInfo.buildNumber}");
      final String platform = Platform.isIOS ? 'ios' : 'android';

      print(
          'ForceUpdate: currentVersionCode = $currentVersionCode, platform = $platform');

      final dio = Dio();
      dio.options.connectTimeout = 5000; // 5 seconds
      dio.options.receiveTimeout = 5000; // 5 seconds

      final response = await dio.get(
        _baseVersionUrlMock,
        // queryParameters: {
        //   'platform': platform,
        //   'appType': _appType,
        // },
      );

      // Response structure:
      // { "statusCode": 200, "success": true, "data": { ... }, "timestamp": "..." }
      dynamic responseData = response.data;

      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }

      if (response.statusCode == 200 &&
          responseData != null &&
          responseData['success'] == true) {
        final data = response.data['data'] as Map<String, dynamic>;
        final result = VersionCheckResult.fromJson(data);

        print('ForceUpdate: latestVersionName   = ${result.latestVersionName}');
        print(
            'ForceUpdate: minSupportedCode    = ${result.minSupportedVersionCode}');
        print('ForceUpdate: forceUpdate flag    = ${result.forceUpdate}');

        // Force update if server flag is true OR current build is below minimum
        final isBehind = currentVersionCode < result.minSupportedVersionCode;

        if (result.forceUpdate || isBehind) {
          print('ForceUpdate: update required!');
          return result;
        }

        print('ForceUpdate: app is up to date');
      }
    } on SocketException {
      print('ForceUpdate: no internet — skipping check');
    } catch (e) {
      print('ForceUpdate: check failed — $e');
    }
    return null;
  }
}

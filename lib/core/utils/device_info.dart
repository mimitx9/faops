import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';

class DeviceInfo {
  static String _osType = '';
  static String _deviceName = '';
  static String _osVersion = '';
  static String _buildNumber = '';
  static String _buildVersion = '';

  static Future<void> init() async {
    if (Platform.isAndroid) {
      _osType = 'android';
      _deviceName = 'android_device';
      _osVersion = Platform.operatingSystemVersion;
    } else if (Platform.isIOS) {
      _osType = 'ios';
      _deviceName = 'ios_device';
      _osVersion = Platform.operatingSystemVersion;
    } else {
      _osType = 'unknown';
      _deviceName = 'unknown';
      _osVersion = 'unknown';
    }

    try {
      final packageInfo = await PackageInfo.fromPlatform();
      _buildNumber = packageInfo.buildNumber;
      _buildVersion = packageInfo.version;
    } catch (e) {
      _buildNumber = '1';
      _buildVersion = '1.0.0';
    }
  }

  static String get osType => _osType;
  static String get deviceName => _deviceName;
  static String get osVersion => _osVersion;
  static String get buildNumber => _buildNumber;
  static String get buildVersion => _buildVersion;
}






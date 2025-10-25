import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../config/app_config.dart';
import '../../features/auth/data/models/user_model.dart';

class StorageService {
  static late SharedPreferences _prefs;
  static late FlutterSecureStorage _secureStorage;
  static late Box _userBox;
  static late Box _cacheBox;

  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _secureStorage = const FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );

    _userBox = await Hive.openBox(AppConfig.userBoxName);
    _cacheBox = await Hive.openBox(AppConfig.cacheBoxName);
  }

  // Token Management
  static Future<void> setAccessToken(String token) async {
    await _secureStorage.write(key: AppConfig.accessTokenKey, value: token);
  }

  static Future<String?> getAccessToken() async {
    return await _secureStorage.read(key: AppConfig.accessTokenKey);
  }

  static Future<void> setRefreshToken(String token) async {
    await _secureStorage.write(key: AppConfig.refreshTokenKey, value: token);
  }

  static Future<String?> getRefreshToken() async {
    return await _secureStorage.read(key: AppConfig.refreshTokenKey);
  }

  static Future<void> clearTokens() async {
    await _secureStorage.delete(key: AppConfig.accessTokenKey);
    await _secureStorage.delete(key: AppConfig.refreshTokenKey);
  }

  // User Data Management
  static Future<void> setUserData(UserModel user) async {
    await _userBox.put(AppConfig.userDataKey, user);
  }

  static UserModel? getUserData() {
    return _userBox.get(AppConfig.userDataKey);
  }

  static Future<void> clearUserData() async {
    await _userBox.delete(AppConfig.userDataKey);
  }

  // Onboarding
  static Future<void> setOnboardingCompleted(bool completed) async {
    await _prefs.setBool(AppConfig.onboardingKey, completed);
  }

  static bool isOnboardingCompleted() {
    return _prefs.getBool(AppConfig.onboardingKey) ?? false;
  }

  // Remember Me functionality
  static Future<void> setRememberMe(bool remember) async {
    await _prefs.setBool('remember_me', remember);
  }

  static bool getRememberMe() {
    return _prefs.getBool('remember_me') ?? false;
  }

  static Future<void> setRememberMeCredentials(String email, String password) async {
    if (getRememberMe()) {
      await _secureStorage.write(key: 'remembered_email', value: email);
      await _secureStorage.write(key: 'remembered_password', value: password);
    }
  }

  static Future<Map<String, String?>> getRememberedCredentials() async {
    if (getRememberMe()) {
      final email = await _secureStorage.read(key: 'remembered_email');
      final password = await _secureStorage.read(key: 'remembered_password');
      return {'email': email, 'password': password};
    }
    return {'email': null, 'password': null};
  }

  static Future<void> clearRememberedCredentials() async {
    await _secureStorage.delete(key: 'remembered_email');
    await _secureStorage.delete(key: 'remembered_password');
  }

  // Cache Management
  static Future<void> setCacheData(
    String key,
    Map<String, dynamic> data,
  ) async {
    await _cacheBox.put(key, data);
  }

  static Map<String, dynamic>? getCacheData(String key) {
    final data = _cacheBox.get(key);
    return data is Map<String, dynamic> ? data : null;
  }

  static Future<void> clearCache() async {
    await _cacheBox.clear();
  }

  // Generic Storage
  static Future<void> setString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  static String? getString(String key) {
    return _prefs.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  static bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  static int? getInt(String key) {
    return _prefs.getInt(key);
  }

  static Future<void> setDouble(String key, double value) async {
    await _prefs.setDouble(key, value);
  }

  static double? getDouble(String key) {
    return _prefs.getDouble(key);
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _prefs.setStringList(key, value);
  }

  static List<String>? getStringList(String key) {
    return _prefs.getStringList(key);
  }

  static Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  static Future<void> clear() async {
    await _prefs.clear();
    await _secureStorage.deleteAll();
    await _userBox.clear();
    await _cacheBox.clear();
  }

  // Secure Storage for sensitive data
  static Future<void> setSecureData(String key, String value) async {
    await _secureStorage.write(key: key, value: value);
  }

  static Future<String?> getSecureData(String key) async {
    return await _secureStorage.read(key: key);
  }

  static Future<void> removeSecureData(String key) async {
    await _secureStorage.delete(key: key);
  }

  // JSON Storage
  static Future<void> setJsonData(String key, Map<String, dynamic> data) async {
    await _prefs.setString(key, jsonEncode(data));
  }

  static Map<String, dynamic>? getJsonData(String key) {
    final jsonString = _prefs.getString(key);
    if (jsonString != null) {
      try {
        return jsonDecode(jsonString) as Map<String, dynamic>;
      } catch (e) {
        return null;
      }
    }
    return null;
  }
}

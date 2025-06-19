import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/errors/exceptions.dart';
import '../models/user_model.dart';

abstract class AuthLocalDataSource {
  Future<UserModel?> getCachedUser();
  Future<void> cacheUser(UserModel user);
  Future<void> clearCache();
  Future<bool> isUserLoggedIn();
  Future<void> cacheAuthToken(String token);
  Future<String?> getCachedAuthToken();
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SharedPreferences sharedPreferences;

  static const String _cachedUserKey = 'CACHED_USER';
  static const String _authTokenKey = 'AUTH_TOKEN';
  static const String _isLoggedInKey = 'IS_LOGGED_IN';

  AuthLocalDataSourceImpl({required this.sharedPreferences});

  @override
  Future<UserModel?> getCachedUser() async {
    try {
      final jsonString = sharedPreferences.getString(_cachedUserKey);
      if (jsonString != null) {
        final jsonMap = json.decode(jsonString);
        return UserModel.fromJson(jsonMap);
      }
      return null;
    } catch (e) {
      throw CacheException('Failed to get cached user: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheUser(UserModel user) async {
    try {
      final jsonString = json.encode(user.toJson());
      await sharedPreferences.setString(_cachedUserKey, jsonString);
      await sharedPreferences.setBool(_isLoggedInKey, true);
    } catch (e) {
      throw CacheException('Failed to cache user: ${e.toString()}');
    }
  }

  @override
  Future<void> clearCache() async {
    try {
      await sharedPreferences.remove(_cachedUserKey);
      await sharedPreferences.remove(_authTokenKey);
      await sharedPreferences.setBool(_isLoggedInKey, false);
    } catch (e) {
      throw CacheException('Failed to clear cache: ${e.toString()}');
    }
  }

  @override
  Future<bool> isUserLoggedIn() async {
    try {
      return sharedPreferences.getBool(_isLoggedInKey) ?? false;
    } catch (e) {
      throw CacheException('Failed to check login status: ${e.toString()}');
    }
  }

  @override
  Future<void> cacheAuthToken(String token) async {
    try {
      await sharedPreferences.setString(_authTokenKey, token);
    } catch (e) {
      throw CacheException('Failed to cache auth token: ${e.toString()}');
    }
  }

  @override
  Future<String?> getCachedAuthToken() async {
    try {
      return sharedPreferences.getString(_authTokenKey);
    } catch (e) {
      throw CacheException('Failed to get cached auth token: ${e.toString()}');
    }
  }
}

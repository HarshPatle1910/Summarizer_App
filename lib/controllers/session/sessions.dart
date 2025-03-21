import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SessionManager {
  static const String _keyUserToken = "user_token";
  static const String _keyLastActivity = "last_activity";
  static const int sessionTimeoutMinutes = 60; // Session expires after 60 mins

  final FlutterSecureStorage secureStorage = const FlutterSecureStorage();

  /// ************** SAVE SESSION **************
  Future<void> saveSession(String userId) async {
    await secureStorage.write(key: _keyUserToken, value: userId);
    await _updateLastActivity();
  }

  /// ************** CHECK SESSION **************
  Future<bool> isSessionActive() async {
    String? userId = await secureStorage.read(key: _keyUserToken);
    if (userId == null) return false;

    int? lastActivity = await _getLastActivity();
    if (lastActivity == null) return false;

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedMinutes = (currentTime - lastActivity) ~/ (1000 * 60);

    return elapsedMinutes < sessionTimeoutMinutes;
  }

  /// ************** AUTO LOGIN **************
  Future<String?> getUserToken() async {
    return await secureStorage.read(key: _keyUserToken);
  }

  /// ************** RESET INACTIVITY TIMER **************
  Future<void> resetInactivityTimer() async {
    await _updateLastActivity();
  }

  /// ************** UPDATE LAST ACTIVITY TIME **************
  Future<void> _updateLastActivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyLastActivity, DateTime.now().millisecondsSinceEpoch);
  }

  /// ************** GET LAST ACTIVITY **************
  Future<int?> _getLastActivity() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyLastActivity);
  }

  /// ************** SIGN OUT **************
  Future<void> clearSession() async {
    await secureStorage.delete(key: _keyUserToken);
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyLastActivity);
  }

  /// ************** GET REMAINING SESSION TIME **************
  Future<int> getRemainingSessionTime() async {
    int? lastActivity = await _getLastActivity();
    if (lastActivity == null) return 0;

    int currentTime = DateTime.now().millisecondsSinceEpoch;
    int elapsedMinutes = (currentTime - lastActivity) ~/ (1000 * 60);
    return (sessionTimeoutMinutes - elapsedMinutes).clamp(
      0,
      sessionTimeoutMinutes,
    );
  }
}

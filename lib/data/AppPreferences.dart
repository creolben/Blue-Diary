
import 'package:preferences/preference_service.dart';

class AppPreferences {
  static const String KEY_USER_PASSWORD = 'user.password';
  // should keep using 'default.lock' key to be compatible with users' previous settings
  static const String KEY_USE_LOCK_SCREEN = 'default.lock';
  static const String KEY_RECOVERY_EMAIL = 'recovery.email';
  static const String KEY_USER_CHECKED_TO_DO_BEFORE = 'user.checked.to.do.before';

  Future<String> getUserPassword() async {
    return PrefService.getString(KEY_USER_PASSWORD) ?? '';
  }

  Future<void> setUserPassword(String password) {
    return PrefService.setString(KEY_USER_PASSWORD, password);
  }

  Future<bool> getUseLockScreen() async {
    return PrefService.getBool(KEY_USE_LOCK_SCREEN) ?? false;
  }

  Future<void> setUseLockScreen(bool value) {
    return PrefService.setBool(KEY_USE_LOCK_SCREEN, value);
  }

  Future<String> getRecoveryEmail() async {
    return PrefService.getString(KEY_RECOVERY_EMAIL) ?? '';
  }

  Future<bool> getUserCheckedToDoBefore() async {
    return PrefService.getBool(KEY_USER_CHECKED_TO_DO_BEFORE) ?? false;
  }

  void setUserCheckedToDoBefore() {
    PrefService.setBool(KEY_USER_CHECKED_TO_DO_BEFORE, true);
  }
}
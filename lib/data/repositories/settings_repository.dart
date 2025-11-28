import 'package:hive_flutter/hive_flutter.dart';

class SettingsRepository {
  static const String _boxName = 'settings';
  static const String _themeKey = 'theme_mode';

  Box? _box;

  Future<void> init() async {
    if (_box == null || !_box!.isOpen) {
      _box = await Hive.openBox(_boxName);
    }
  }

  Box get box {
    if (_box == null || !_box!.isOpen) {
      throw HiveError('Settings box is not open');
    }
    return _box!;
  }

  String getThemeMode() {
    return box.get(_themeKey, defaultValue: 'system');
  }

  Future<void> setThemeMode(String mode) async {
    await box.put(_themeKey, mode);
  }
}

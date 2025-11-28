import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:contact_assistant/data/repositories/settings_repository.dart';

part 'theme_provider.g.dart';

@riverpod
class ThemeNotifier extends _$ThemeNotifier {
  late final SettingsRepository _repository;

  @override
  ThemeMode build() {
    _repository = SettingsRepository();

    try {
      final modeStr =
          Hive.box('settings').get('theme_mode', defaultValue: 'system');
      return _parseThemeMode(modeStr);
    } catch (e) {
      return ThemeMode.system;
    }
  }

  ThemeMode _parseThemeMode(String mode) {
    switch (mode) {
      case 'light':
        return ThemeMode.light;
      case 'dark':
        return ThemeMode.dark;
      case 'system':
      default:
        return ThemeMode.system;
    }
  }

  String _themeModeToString(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'light';
      case ThemeMode.dark:
        return 'dark';
      case ThemeMode.system:
        return 'system';
    }
  }

  Future<void> setTheme(ThemeMode mode) async {
    state = mode;
    await _repository.init();
    await _repository.setThemeMode(_themeModeToString(mode));
  }
}

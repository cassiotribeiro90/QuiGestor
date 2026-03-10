import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_state.dart';

class ThemeCubit extends Cubit<ThemeState> {
  late final SharedPreferences _prefs;
  static const String _themeKey = 'theme_mode';

  ThemeCubit() : super(ThemeState.initial()) {
    _init();
  }

  Future<void> _init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadTheme();
  }

  Future<void> _loadTheme() async {
    final savedTheme = _prefs.getString(_themeKey);
    if (savedTheme == 'dark') {
      emit(state.copyWith(themeMode: ThemeMode.dark));
    } else if (savedTheme == 'light') {
      emit(state.copyWith(themeMode: ThemeMode.light));
    } else {
      emit(state.copyWith(themeMode: ThemeMode.system));
    }
  }

  Future<void> toggleTheme() async {
    final newMode = state.themeMode == ThemeMode.light 
        ? ThemeMode.dark 
        : ThemeMode.light;
    
    await _prefs.setString(_themeKey, newMode == ThemeMode.dark ? 'dark' : 'light');
    emit(state.copyWith(themeMode: newMode));
  }

  Future<void> setTheme(ThemeMode mode) async {
    final themeString = mode == ThemeMode.dark 
        ? 'dark' 
        : mode == ThemeMode.light ? 'light' : 'system';
    
    await _prefs.setString(_themeKey, themeString);
    emit(state.copyWith(themeMode: mode));
  }
}

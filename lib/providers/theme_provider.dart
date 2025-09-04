import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:flutter/material.dart';

final appThemeStateNotifier = ChangeNotifierProvider(
  (ref) => AppThemeState()
);

class AppThemeState extends ChangeNotifier{
  var isDarkModeEnabled = false;

  void setLightTheme(){
    isDarkModeEnabled =false;
    notifyListeners();
  } 

  void setDarkTheme(){
    isDarkModeEnabled = true;
    notifyListeners();
  }
}
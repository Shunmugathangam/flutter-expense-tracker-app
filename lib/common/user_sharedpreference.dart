import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';


void setUserSharedPreference(String val) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("username", val);
}

Future<String> getUserSharedPreference() async {
    final prefs = await SharedPreferences.getInstance();
    String str = prefs.getString("username");
    return  str;
}

void clearSharedPreference() async {
  final pref = await SharedPreferences.getInstance();
  pref.clear();
}

void logoutClearSharedPreference() async {
  final pref = await SharedPreferences.getInstance();
  pref.remove("username");
}
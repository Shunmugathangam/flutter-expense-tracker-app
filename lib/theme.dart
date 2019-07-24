import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<ThemeData> initappTheme() async {
   String mode = await getSharedPreference(ThemeSharedPreferenceKey.mode.index.toString());
   print(mode);
   if(mode == "dark")
      return appDarkTheme();
    else
      return appTheme();
}

ThemeData appTheme({Color color}) {
  TextTheme _textTheme(TextTheme base) {
        return base.copyWith(
          headline: base.headline.copyWith(
            color: Colors.black
          ),
          title: base.title.copyWith(
            color: Colors.black
          ),
          display1: base.display1.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
          display2: base.display2.copyWith(
            color: Colors.black
          ),
          display3: base.display3.copyWith(
            color: Colors.black
          ),
          display4: base.display4.copyWith(
            color: Colors.black
          )
        );
  }
  final ThemeData base = ThemeData.light();
  return base.copyWith(
    textTheme: _textTheme(base.textTheme),
    primaryColor: color != null ? color : Colors.blue
  );
}

ThemeData appDarkTheme({Color color}) {
  TextTheme _textTheme(TextTheme base) {
        return base.copyWith(
          headline: base.headline.copyWith(
            color: Colors.black
          ),
          title: base.title.copyWith(
            color: Colors.black
          ),
          display1: base.display1.copyWith(
            color: Colors.white,
            fontSize: 20,
          ),
          display2: base.display2.copyWith(
            color: Colors.black
          ),
          display3: base.display3.copyWith(
            color: Colors.black
          ),
          display4: base.display4.copyWith(
            color: Colors.black
          )
        );
  }
  final ThemeData base = ThemeData.dark();
  return base.copyWith(
    textTheme: _textTheme(base.textTheme),
    primaryColor: color != null ? color : Colors.black
  );
}

void setSharedPreference(String key, String theme) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("theme" + key, theme);
}

Future<String> getSharedPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String str = prefs.getString("theme" + key);
    return  str;
}

enum ThemeSharedPreferenceKey { 
   mode, // dark, light
   tab, // box, normal
   color // app color
}
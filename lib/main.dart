import 'package:expensetracker/bloc/theme_provider.dart';
import 'package:expensetracker/theme.dart';
import 'package:expensetracker/common/user_sharedpreference.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/routes.dart';
import 'package:provider/provider.dart';

main() async {
  WidgetsFlutterBinding.ensureInitialized(); 
  String mode =  await getSharedPreference(ThemeSharedPreferenceKey.mode.index.toString());
  String color =  await getSharedPreference(ThemeSharedPreferenceKey.color.index.toString());
  ThemeData theme = ThemeData.light(); // get theme from prefs
  String user = await getUserSharedPreference();
  
  if(mode == "dark") {
     if(color != null) {
        Color col = Color(int.parse(color));
        theme = appDarkTheme(color: col);
     }
     else {
        theme = appDarkTheme();
     }
        
  }
  else {
    if(color != null) {
        Color col = Color(int.parse(color));
        theme = appTheme(color: col);
     }
     else {
        theme = appTheme();
     }
  }

  runApp(AppEntry(
    theme: theme,
    isLoggedIn: user != null ? true : false,
  ));
}

class AppEntry extends StatelessWidget {
  // This widget is the root of your application.

  final ThemeData theme;
  final bool isLoggedIn;

  const AppEntry({Key key, @required this.theme, this.isLoggedIn}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    
    return ChangeNotifierProvider<ThemeChanger>(
      create: (context) => ThemeChanger(theme),
      child: TrakerApp(isLoggedIn));
  }

}

class TrakerApp extends StatelessWidget {

  final bool isLoggedIn;
  TrakerApp(this.isLoggedIn);

  @override
  Widget build(BuildContext context) {
    final theme = Provider.of<ThemeChanger>(context);
    
    return MaterialApp(
      title: 'Flutter Demo',
      // theme: ThemeData(
      //   // This is the theme of your application.
      //   //
      //   // Try running your application with "flutter run". You'll see the
      //   // application has a blue toolbar. Then, without quitting the app, try
      //   // changing the primarySwatch below to Colors.green and then invoke
      //   // "hot reload" (press "r" in the console where you ran "flutter run",
      //   // or simply save your changes to "hot reload" in a Flutter IDE).
      //   // Notice that the counter didn't reset back to zero; the application
      //   // is not restarted.
      //   primarySwatch: Colors.blue,
      // ),
      theme: theme.getTheme(),
      //home: HomePage(title: 'Flutter Demo Home Page'),
      initialRoute: isLoggedIn ? '/' : '/login',
      routes: routes,
    );
  }
}



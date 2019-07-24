import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:expensetracker/sidedrawer.dart';
import 'package:expensetracker/bloc/theme_provider.dart';
import 'package:expensetracker/theme.dart';

class SettingsPage extends StatefulWidget {

  SettingsPage();

  @override
  SettingsPageState createState() => SettingsPageState();

}

class SettingsPageState extends State<SettingsPage> {

   SettingsPageState();

   bool _darkMode = false;
   bool _lightMode = true;
   bool _coloredTabMode = false;

   @override
  void initState() {
    super.initState();
    initThemeSettings();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    
    ThemeChanger _themeChanger = Provider.of<ThemeChanger>(context);

    return Scaffold(
        appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
                  icon: new Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
          ),
          title: Text('Settings'),
          centerTitle: true,
          actions: <Widget>[
            Icon(Icons.settings),
            Padding(padding: EdgeInsets.only(right: 10.0),)
          ],
        ),
        drawer: sideDrawer(context),
        body: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Text("Light Mode"),
                      Switch(
                        value: _lightMode,
                        onChanged: (bool val) {
                          setAppTheme(_themeChanger, val ? false : true);
                          setModeState(val, val ? false : true);
                        },
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Text("Dark Mode"),
                      Switch(
                        value: _darkMode,
                        onChanged: (bool val) {
                            setAppTheme(_themeChanger, val);
                            setModeState(val ? false : true, val);
                        },
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      SizedBox(width: 20,),
                      Text("Colored Tab Mode"),
                      Switch(
                        value: _coloredTabMode,
                        onChanged: (bool val) {
                            setTabState(val);
                        },
                      )
                    ],
                  ),
                  Row(
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          MaterialColorPicker(
                              onColorChange: (Color color) {
                                  // Handle color changes
                                 setColorState(color);
                              },
                          ),
                          blackColorOptions(),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    children: <Widget>[
                        SizedBox(width: 20,),
                        Text("Selected App Color: "),
                        FutureBuilder(future: getAssignedColor(),
                          initialData: Colors.blue.value,
                          builder:  (BuildContext context, AsyncSnapshot<int> colorValue) {
                            if(colorValue != null) {
                                return Container(color: Color(colorValue.data), child: SizedBox(width: 60, height: 20,),);
                            }
                            else {
                                return Text("");
                            }
                        }),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Center(
                        child: RaisedButton(child: Text("Change App Color"), onPressed: () {
                              assignAppColor(_themeChanger);
                        },),
                      )
                    ],
                  )
                ],
              ),
            ),
        ),
        );
  }

  Widget blackColorOptions() {
      ColorSwatch blackColors = new ColorSwatch(
        Colors.black.value,
        {
              500: Colors.black,
        },
      );

      return  MaterialColorPicker (
          onColorChange: (Color color) {
              setColorState(color);
          },
          selectedColor: Colors.black,
          colors: [
              blackColors,
          ],
      );
  }

  void initThemeSettings() {
      getSharedPreference(ThemeSharedPreferenceKey.tab.index.toString()).then((onValue) {
        if(onValue == "box") {
           setTabState(true);
        }
        else {
          setTabState(false);
        }
      });

      getSharedPreference(ThemeSharedPreferenceKey.mode.index.toString()).then((onValue) {
        if(onValue == "dark") {
          setModeState(false, true);
        }
        else {
          setModeState(true, false);
        }
      });
  }

  void setAppTheme(ThemeChanger themeChanger, bool isDarkMode) async {
      String colorVal = await getSharedPreference(ThemeSharedPreferenceKey.color.index.toString());
      if(colorVal != null) {
          Color color = Color(int.parse(colorVal));
          if(isDarkMode == true) {
            themeChanger.setTheme(appDarkTheme(color: color));
            setSharedPreference(ThemeSharedPreferenceKey.mode.index.toString(), "dark");
          }
          else {
            themeChanger.setTheme(appTheme(color: color));
            setSharedPreference(ThemeSharedPreferenceKey.mode.index.toString(), "light");
          }
      }
      else {
          if(isDarkMode == true) {
            themeChanger.setTheme(appDarkTheme());
            setSharedPreference(ThemeSharedPreferenceKey.mode.index.toString(), "dark");
          }
          else {
            themeChanger.setTheme(appTheme());
            setSharedPreference(ThemeSharedPreferenceKey.mode.index.toString(), "light");
          }
      }
         
  }

  void setModeState(bool lightMode, bool darkMode) {
      setState(() {
            _darkMode = darkMode;
            _lightMode = lightMode;
      });
  }

  void setTabState(bool tabMode) {
      if(tabMode == true)
         setSharedPreference(ThemeSharedPreferenceKey.tab.index.toString(), "box");
      else
        setSharedPreference(ThemeSharedPreferenceKey.tab.index.toString(), "normal");

      setState(() {
          _coloredTabMode = tabMode;
      });
  }

  void setColorState(Color color) {
     setSharedPreference(ThemeSharedPreferenceKey.color.index.toString(), color.value.toString());
  }

  void assignAppColor(ThemeChanger themeChanger) async {
      String mode = await getSharedPreference(ThemeSharedPreferenceKey.mode.index.toString());
      String colorVal = await getSharedPreference(ThemeSharedPreferenceKey.color.index.toString());
      if(colorVal != null) {
          Color color = Color(int.parse(colorVal));
          if(mode == "dark") {
              themeChanger.setTheme(appDarkTheme(color: color));
          }
          else {
              themeChanger.setTheme(appTheme(color: color));
          }
      }
  }

  Future<int> getAssignedColor() async {

    String colorVal = await getSharedPreference(ThemeSharedPreferenceKey.color.index.toString());
    if(colorVal != null){
      return int.parse(colorVal);
    }
    else {
      return Colors.blue.value;
    }
  }

}

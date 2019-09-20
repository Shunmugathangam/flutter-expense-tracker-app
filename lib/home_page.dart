import 'package:expensetracker/sidedrawer.dart';
import 'package:expensetracker/common/user_sharedpreference.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/track_list_page.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/theme.dart';

class HomePage extends StatefulWidget {

  final BuildContext context;

  HomePage(this.context);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  bool _coloredTabMode = false;

  @override
  void initState() {
    super.initState();
    initTabMode();
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _select(Choice choice) {
    if(choice.key == "Logout") {
      logoutClearSharedPreference();
      Navigator.of(context).pushNamedAndRemoveUntil("/login", (Route<dynamic> route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {

    return DefaultTabController(
      length: 3,
      child: Scaffold(
      drawer: sideDrawer(context),
      appBar: AppBar(
            bottom: TabBar(
              indicatorColor: Theme.of(context).primaryColor,
              tabs: tabList(),
            ),
            title: Text('Tracker'),
            actions: <Widget>[
              PopupMenuButton<Choice>(
              onSelected: _select,
              itemBuilder: (BuildContext context) {
                return choices.map((Choice choice) {
                  return PopupMenuItem<Choice>(
                    value: choice,
                    child: Text(choice.title),
                  );
                }).toList();
              },
            ),
            ],
            centerTitle: true,
          ),
          body: TabBarView(
            children: [
              TrackList(CategoryType.expense),
              TrackList(CategoryType.income),
              TrackList(CategoryType.budget),
            ],
          ),
    ),
    ); 
  }

  List<Widget> tabList() {

     if(_coloredTabMode == true)
     {
        double width = MediaQuery.of(context).size.width;
        double tabWidth = width  / 3;
        return  [
                  ClipRRect(borderRadius: BorderRadius.circular(40.0),child: Container(width: tabWidth,height: 40.0,color: Colors.red,child: Center(child: new Text("EXPENSES"),),),),
                  ClipRRect(borderRadius: BorderRadius.circular(40.0),child: Container(width: tabWidth,height: 40.0,color: Colors.green,child: Center(child: new Text("INCOMES"),),),),
                  ClipRRect(borderRadius: BorderRadius.circular(40.0),child: Container(width: tabWidth,height: 40.0,color: Colors.orange,child: Center(child: new Text("BUDGET"),),),),
                ];
     }
     else
     {
       return  [
                 Tab(text: "EXPENSES",),
                 Tab(text: "INCOMES",),
                 Tab(text: "BUDGET",),
                ];
     }           
  }

  void initTabMode() {
    getSharedPreference(ThemeSharedPreferenceKey.tab.index.toString()).then((onValue) {
        if(onValue == "box") {
          setTabMode(true);
        }
        else {
          setTabMode(false);
        }
      });
  }
 
  void setTabMode(bool tabMode) {
      setState(() {
         _coloredTabMode = tabMode;
      });
  }

}


class Choice {
  const Choice({this.key, this.title, this.icon});

  final String key;
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(key: 'Logout', title: 'Logout', icon: Icons.keyboard_arrow_left)
];
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/common/user_sharedpreference.dart';
import 'dart:async';

Drawer sideDrawer(BuildContext context) {

  Future<String> _getUserName() async {
    String userName = await getUserSharedPreference();
    return userName;
  }

  Widget buildTitle() {
    return FutureBuilder(
      initialData: "Hello,",
      future: _getUserName(),
      builder: (BuildContext context, AsyncSnapshot<String> userName) {
          if (userName.hasError) {
                return Text('Error: ${userName.error}');
              }
              switch (userName.connectionState) {
                case ConnectionState.waiting:
                  return Text("");
                default:
                  if(userName.data != null) {
                    return Text("Hello, " + userName.data, style: TextStyle(
                      color: Theme.of(context).textTheme.display1.color,
                      fontSize: Theme.of(context).textTheme.display1.fontSize
                      ));
                  }
                  else {
                    return Text("");
                  }
              }   
      }
    );
  }

  ListView _lstView() {
        
        return ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            Container(height: 90.0,
            child: DrawerHeader(
                    child: Row(children: <Widget>[
                      Icon(Icons.account_circle, color: Theme.of(context).textTheme.display1.color,),
                      SizedBox(width: 10,),
                      buildTitle(),
                    ],),
                    decoration: BoxDecoration(
                       color: Theme.of(context).primaryColor
                    ),
                    padding: EdgeInsets.all(10.0)
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
              title: Text('Home'),
              onTap: () {
                Navigator.of(context).pushNamedAndRemoveUntil("/", (Route<dynamic> route) => false);
              },
              trailing: Icon(Icons.home),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
              title: Text('Category'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/categories");
              },
              trailing: Icon(Icons.category),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
              title: Text('Chart'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/charts");
              },
              trailing: Icon(Icons.pie_chart),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
              title: Text('Summary'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/summary");
              },
              trailing: Icon(Icons.chevron_right),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
              title: Text('Search'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/searchpage");
              },
              trailing: Icon(Icons.search),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
              title: Text('Map Budget'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/budgetexpensemap");
              },
              trailing: Icon(Icons.map),
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
              title: Text('Reports'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/report");
              },
              trailing: Icon(Icons.present_to_all),
            ),
            Divider(
              color: Theme.of(context).textTheme.display2.color,
            ),
            ListTile(
              contentPadding: EdgeInsets.symmetric(horizontal: 40.0),
              title: Text('Settings'),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).pushNamed("/settings");
              },
              trailing: Icon(Icons.settings),
            ),
          ],
        );
  }

  return Drawer(child: _lstView(),);
}

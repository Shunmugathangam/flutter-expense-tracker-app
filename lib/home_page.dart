import 'package:flutter/material.dart';
import 'package:expensetracker/track_list_page.dart';
import 'package:expensetracker/model/category_model.dart';

class HomePage extends StatefulWidget {

  final BuildContext context;

  HomePage(this.context);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  void _select(Choice choice) {
    if(choice.key == "Category"){
      Navigator.pushNamed(context, "/categories");
    }
  }

  @override
  Widget build(BuildContext context) {
   
    return DefaultTabController(
      length: 3,
      child: Scaffold(
      appBar: AppBar(
            backgroundColor: Colors.blue,
            bottom: TabBar(
              tabs: [
                Tab(text: "Expenses"),
                Tab(text: "Incomes"),
              ],
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
            ],
          ),
    ),
    ); 
  }
}


class Choice {
  const Choice({this.key, this.title, this.icon});

  final String key;
  final String title;
  final IconData icon;
}

const List<Choice> choices = const <Choice>[
  const Choice(key: 'Category', title: 'Category', icon: Icons.settings),
  const Choice(key: 'Chart', title: 'View Chart', icon: Icons.pie_chart_outlined),
];
import 'package:flutter/material.dart';
import 'package:expensetracker/track_entry_page.dart';

import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/bloc/track_bloc.dart';
import 'package:expensetracker/model/track_model.dart';

class TrackList extends StatefulWidget {

  TrackList(this.categoryType);
  final CategoryType categoryType;

  @override
  TrackListState createState() => new TrackListState(categoryType);

}

class TrackListState extends State<TrackList> {

  TrackListState(this.categoryType);
  final CategoryType categoryType;

  final _trackBloc = TrackBloc();

  @override
  void initState() {
    super.initState();
    _trackBloc.getTrackDetailsList(this.categoryType);
  }

  @override
  void dispose() {
    super.dispose();
    _trackBloc.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
      children: <Widget>[
        //Text(""),
        Expanded(child: Container(
            padding: EdgeInsets.all(5.0),
            child:  buildTrackList(),
            ),),
      ]),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        onPressed: () {
          _addTrackEntryDialog(context, this.categoryType.index);
        },
        tooltip: '',
        child: Icon(Icons.add),
      ),
    );
  }

  Widget buildTrackList() {
    return StreamBuilder<List<TrackDetailsModel>>(
            stream: _trackBloc.outTrackDetails,
            builder: (BuildContext context, AsyncSnapshot<List<TrackDetailsModel>> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              //print(snapshot.connectionState);
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  //return const Text('Loading...');
                  return Center(child: CircularProgressIndicator());
                default:
                  if (snapshot.data.isEmpty) {
                    //return const NoContent();
                    return Center(child: Text('No Records Found.'));
                  }
                  else if(snapshot.data != null && snapshot.data[0].categoryId == null){
                      return Center(child: Text('No Records Found.'));
                  }
                  
                  return _trackList(snapshot.data);
              }
            },
          );
  }

  ListView _trackList(List<TrackDetailsModel> snapshot) {
    return ListView.builder(
      // Must have an item count equal to the number of items!
      itemCount: snapshot.length,
      // A callback that will return a widget.
      itemBuilder: (BuildContext context, int idx) {
        // In our case, a DogCard for each doggo.
        return Card(
                child: Column(children: <Widget>[
                    ListTile(
                      title: Text(snapshot[idx].description),
                      //leading: Icon(Icons.inbox, color: Colors.blue, size: 26.0),
                      leading: ClipOval(
                        child: Container(
                                  color: this.categoryType.index == 1 ? Colors.grey : Colors.grey,
                                  height: 40.0, // height of the button
                                  width: 40.0, // width of the button
                                  child: Center(child: 
                                  Text(
                                    this.categoryType.index == 1 ? 'I' : "E", 
                                    style: TextStyle(color: Colors.white),)),
                                )
                      ),
                      subtitle: Text(snapshot[idx].categoryName + " | " + (this.categoryType.index == 1 ? "Income": "Expense")),
                      trailing: Text(snapshot[idx].amount.toString()),
                      onTap: () {
                        _updateTrackEntryDialog(context, idx, this.categoryType.index, snapshot[idx]);
                      },
                    )
                ],),
              );
      },
    );
  }

  void _addTrackEntryDialog(BuildContext context, int categoryType) {
      Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return new TrackEntryDialog(categoryType: categoryType == 1 ? CategoryType.income: CategoryType.expense);
          },
        fullscreenDialog: true
      )).then((val) => _trackBloc.getTrackDetailsList(this.categoryType));
  }

  void _updateTrackEntryDialog(BuildContext context, int rowIndex, int categoryType, TrackDetailsModel trackDetailsModel) {
      Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return new TrackEntryDialog(categoryType: categoryType == 1 ? CategoryType.income: CategoryType.expense, trackIndex: rowIndex, trackDetailsModel: trackDetailsModel);
          },
        fullscreenDialog: true
      )).then((val) => _trackBloc.getTrackDetailsList(this.categoryType));
  }

}



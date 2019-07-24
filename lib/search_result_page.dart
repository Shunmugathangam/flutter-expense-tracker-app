import 'package:flutter/material.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/model/track_model.dart';
import 'package:expensetracker/bloc/datetime_bloc.dart';
import 'package:expensetracker/common/money_formatter.dart';

class SearchResultPage extends StatefulWidget {

  SearchResultPage({this.lstTrackDetailsModel, this.categoryType, this.totalAmount});
  final List<TrackDetailsModel> lstTrackDetailsModel;
  final CategoryType categoryType;
  final int totalAmount;

  @override
  SearchResultPageState createState() => SearchResultPageState(categoryType: categoryType, lstTrackDetailsModel: lstTrackDetailsModel, totalAmount: totalAmount);
}

class SearchResultPageState extends State<SearchResultPage> {

  SearchResultPageState({this.lstTrackDetailsModel, this.categoryType, this.totalAmount});
  final List<TrackDetailsModel> lstTrackDetailsModel;
  final CategoryType categoryType;
  final int totalAmount;

  @override
  void initState() {
    super.initState(); 
    print(1);
    print(lstTrackDetailsModel.length);
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
          title: Text("Search Result"),
          centerTitle: true,
      ),
      body: Column(
      children: <Widget>[
        Padding(padding: EdgeInsets.only(top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
             Expanded(
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[Text("Total: " + currencyFormatWithSymbol(double.tryParse(totalAmount.toString())), style: TextStyle(fontWeight: FontWeight.bold),), SizedBox(width: 20,)],)
              ),
        ],)),
        Expanded(child: Container(
            padding: EdgeInsets.all(5.0),
            child: (lstTrackDetailsModel != null && lstTrackDetailsModel.length > 0) ?  _trackList(lstTrackDetailsModel) : Center(child: Text("No Records Found"),),
            ),),
      ]),
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
                                  color: Colors.grey,
                                  height: 40.0, // height of the button
                                  width: 40.0, // width of the button
                                  child: Center(child: 
                                  Text(
                                    getCategoryTypeName(categoryType)[0], 
                                    style: TextStyle(color: Colors.white),)),
                                )
                      ),
                      subtitle: Text(snapshot[idx].categoryName),
                      trailing: Column(children: <Widget>[
                        Text(DateTimeBloc().formatDate(snapshot[idx].trackDate), style: TextStyle(fontSize: 12, color: Colors.grey),),
                        SizedBox(height: 5,),
                        Text(currencyFormatWithSymbol(double.tryParse(snapshot[idx].amount.toString()))),
                      ],),
                      onTap: () {
                        
                      },
                    )
                ],),
              );
      },
    );
  }

  String getCategoryTypeName(CategoryType categoryType) {
      List<String> cName = categoryType.toString().split(".");
      String categoryTypeName = cName[1];
      return categoryTypeName[0].toUpperCase() + categoryTypeName.substring(1);
  }

}
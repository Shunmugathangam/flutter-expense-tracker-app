import 'package:flutter/material.dart';
import 'package:expensetracker/track_entry_page.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/bloc/track_bloc.dart';
import 'package:expensetracker/model/track_model.dart';
import 'package:expensetracker/bloc/datetime_bloc.dart';
import 'package:expensetracker/common/color.dart';
import 'package:expensetracker/common/money_formatter.dart';
import 'package:expensetracker/pdfviewer_page.dart';

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
  final _dateTimeBloc = DateTimeBloc();
  int totalAmount = 0;
  String monthName = "";
  String _fromMonth = "--From--";
  String _toMonth = "--To--";

  String _selectedFromMonth = "";
  String _selectedFromYear = "";
  String _selectedtoMonth = "";
  String _selectedtoYear = "";
  String _newDate = "";

  List<TrackDetailsModel> lstTrackDetails;
  String totalAmt;

  @override
  void initState() {
    super.initState();
    initMonthName();
  }

  @override
  void dispose() {
    super.dispose();
    _trackBloc.dispose();
    _dateTimeBloc.dispose();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return Scaffold(
      body: Column(
      children: <Widget>[
        Padding(padding: const EdgeInsets.only(top: 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Expanded(
                flex: 5, // 50%
                child: Row(mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[
                                    IconButton(
                                                  icon: Icon(Icons.arrow_left),
                                                  onPressed: (){
                                                    prevMonth();
                                                  },
                                                ),
                                    getMonthName(),
                                    IconButton(
                                      icon: Icon(Icons.arrow_right),
                                      onPressed: (){
                                        nextMonth();
                                      },
                                    ),
                              ],)),
             Expanded(
                flex: 5, // 50%
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[getTrackTotal(), SizedBox(width: 20,)],)
              ),
        ],),),
        Expanded(child: Container(
            padding: EdgeInsets.all(5.0),
            child:  buildTrackList(),
            ),),
      ]),
      floatingActionButton: buildFloatingActionButton()
    );
  }

  Widget buildFloatingActionButton() { 
    if(CategoryType.budget == categoryType) {
        return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    buildShareFloatingActionButton(categoryType.index.toString() + "share"),
                    SizedBox(height: 5,),
                    buildCopyBudgetFloatingActionButton(),
                    SizedBox(height: 5,),
                    buildAddFloatingActionButton()
              ],);
    }
    else {
        return Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                    buildShareFloatingActionButton(categoryType.index.toString() + "share"),
                    SizedBox(height: 5,),
                    buildAddFloatingActionButton()
              ],);
    }  
  }

  Widget buildCopyBudgetFloatingActionButton() {

      // return FloatingActionButton.extended(
      //     label: Text("Copy"),
      //     icon: Icon(Icons.content_copy),
      //     backgroundColor: Theme.of(context).primaryColor,
      //     onPressed: () async {
      //           final String response = await _asyncInputDialog(context);
      //           print("$response");
      //     },
      //   );

        return FloatingActionButton(
              heroTag: categoryType.index.toString() + "copy",
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).textTheme.display1.color,
              onPressed: () async {
                await _asyncInputDialog(context);
                //final String response = await _asyncInputDialog(context);
                //print("$response");
              },
              tooltip: '',
              child: Icon(Icons.content_copy),
          );

  }

  Widget buildShareFloatingActionButton(String heroTag) {
        return FloatingActionButton(
              heroTag: heroTag,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).textTheme.display1.color,
              onPressed: () async {
                //Navigator.of(context).pushNamed('/pdfviewer');
                Navigator.of(context).push(MaterialPageRoute<Null>(
                    builder: (BuildContext context) {
                      return PdfViewerPage(categoryType: categoryType, lstTrackDetails: this.lstTrackDetails, totalAmt: this.totalAmt);
                    },
                )).then((val) => {});

                //FlutterShareMe().shareToWhatsApp(msg:'hello,test app');
              },
              tooltip: '',
              child: Icon(Icons.picture_as_pdf),
          );
  }

  Widget buildAddFloatingActionButton() {
      return FloatingActionButton(
              heroTag: categoryType,
              backgroundColor: Theme.of(context).primaryColor,
              foregroundColor: Theme.of(context).textTheme.display1.color,
              onPressed: () {
                _addTrackEntryDialog(context, categoryType);
              },
              tooltip: '',
              child: Icon(Icons.add),
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
                    return Center(child: Text('No Records Found'));
                  }
                  else if(snapshot.data != null && snapshot.data[0].categoryId == null){
                      return Center(child: Text('No Records Found'));
                  }
                  
                  return _trackList(snapshot.data);
              }
            },
          );
  }

  Widget getTrackTotal() {
    return StreamBuilder<int>(
            stream: _trackBloc.outTrackTAmount,
            builder: (BuildContext context, AsyncSnapshot<int> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Text("");
                default:
                  totalAmount = snapshot.data;
                  String amt = currencyFormatWithSymbol(double.tryParse(snapshot.data.toString()));
                  totalAmt = amt;
                  return Text(amt);
              }
            },
          );
  }

  Widget getMonthName() {
    return StreamBuilder<String>(
            stream: _dateTimeBloc.outMonthName,
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }
              switch (snapshot.connectionState) {
                case ConnectionState.waiting:
                  return Text("        ");
                default:
                  monthName = snapshot.data;
                  _dateTimeBloc.setSharedPreference(SharedPreferenceKey.monthName.index.toString(), monthName);
                  return Text(snapshot.data);
              }
            },
          );
  }

  ListView _trackList(List<TrackDetailsModel> snapshot) {
    this.lstTrackDetails = snapshot;
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
                                  color: getCategoryColor(snapshot[idx].color),
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
                        _updateTrackEntryDialog(context, idx, categoryType, snapshot[idx]);
                      },
                    )
                ],),
              );
      },
    );
  }

  Future<String> _asyncInputDialog(BuildContext context) async {
      List<Map<String, dynamic>> data = await _trackBloc.getbudgetedMonths();
      List<String> fMonths = new List<String>();
      String _month = "";
      fMonths.add("--From--");
      data.forEach((v){
          _month = "";
          v.forEach((k,v){
              _month += "-" + v;
          });
          fMonths.add(_month.substring(1, _month.length));
      });

      return showDialog<String>(
        context: context,
        barrierDismissible: false, // dialog is dismissible with a tap on the barrier
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select the month which you want to copy'),
            content: Row(
              children: <Widget>[
                Expanded(
                child: 
                DropdownButton<String>(
                  value: _fromMonth,
                  items: fMonths.map((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                  onChanged: (value) 
                  {
                    setState(() {
                      _fromMonth = value;
                    });
                    _asyncInputDialog(context);
                    Navigator.of(context).pop();
                  },
                  hint: Text("From"),
                  ),
                ),
                Expanded(child: DropdownButton<String>(
                  value: _toMonth,
                  items: <String>['--To--', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'].map((String value) {
                  return new DropdownMenuItem<String>(
                    value: value,
                    child: new Text(value),
                  );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _toMonth = value;
                    });
                    _asyncInputDialog(context);
                    Navigator.of(context).pop();
                  },
                  hint: Text("To"),
                ),),
              ],
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                textColor: Theme.of(context).primaryColor,
                onPressed: () {

                  if(_fromMonth != "--From--" && _toMonth != "--To--") {
                       _selectedFromYear = _fromMonth.split("-")[0];
                      _selectedFromMonth = _fromMonth.split("-")[1];

                      _selectedtoYear = DateTime.now().year.toString();
                      _selectedtoMonth = (_dateTimeBloc.getMonthValue(_toMonth) < 10 ? '0' + _dateTimeBloc.getMonthValue(_toMonth).toString() : _dateTimeBloc.getMonthValue(_toMonth).toString());

                      DateTime dt = DateTime.parse(DateTime.now().year.toString() + "-" + _selectedtoMonth + "-01");
                      _newDate = dt.toString();

                      _trackBloc.copyBudget(_selectedFromYear, _selectedFromMonth, _selectedtoYear,_selectedtoMonth, _newDate).then((onValue){
                        setState(() {
                          initMonthName(); 
                        });
                      });
                  }

                  setState(() {
                    _fromMonth = "--From--";
                    _toMonth = "--To--";
                  });
                  Navigator.of(context).pop("Ok");
                },
              ),
            ],
          );
        },
      );
  }

  String getCategoryTypeName(CategoryType categoryType) {
      List<String> cName = categoryType.toString().split(".");
      String categoryTypeName = cName[1];
      return categoryTypeName[0].toUpperCase() + categoryTypeName.substring(1);
  }

  void _addTrackEntryDialog(BuildContext context, CategoryType categoryType) {
      Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return new TrackEntryDialog(categoryType: categoryType);
          },
        fullscreenDialog: true
      )).then((val) => currentMonth());
  }

  void _updateTrackEntryDialog(BuildContext context, int rowIndex, CategoryType categoryType, TrackDetailsModel trackDetailsModel) {
      Navigator.of(context).push(new MaterialPageRoute<Null>(
          builder: (BuildContext context) {
            return new TrackEntryDialog(categoryType: categoryType, trackIndex: rowIndex, trackDetailsModel: trackDetailsModel);
          },
        fullscreenDialog: true
      )).then((val) => currentMonth());
  }

  void getTrackDetails(DateTime dt){
    _trackBloc.getTrackDetailsList(categoryType, _dateTimeBloc.getFirstDateOftheMonth(year: dt.year, month: dt.month), _dateTimeBloc.getLastDateOftheMonth(year: dt.year, month: dt.month));
    _trackBloc.getTrackTotalAmt(categoryType, _dateTimeBloc.getFirstDateOftheMonth(year: dt.year, month: dt.month), _dateTimeBloc.getLastDateOftheMonth(year: dt.year, month: dt.month));
  }

  void currentMonth() {
      DateTime dt = _dateTimeBloc.currentMonth(monthName);
      getTrackDetails(dt);
  }

  void nextMonth() {
      DateTime dt = _dateTimeBloc.nextMonth(monthName);
      getTrackDetails(dt);
  }

  void prevMonth() {
      DateTime dt = _dateTimeBloc.prevMonth(monthName);
      getTrackDetails(dt);
  }

  void initMonthName() {
    _dateTimeBloc.getSharedPreference(SharedPreferenceKey.monthName.index.toString()).then((mName){
        if(mName != null){
            monthName = mName;
        }
        else{
           monthName = _dateTimeBloc.getCurrentMonthName();
        }

        currentMonth();
    });
  }

}



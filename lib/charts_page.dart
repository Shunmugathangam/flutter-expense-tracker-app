import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:expensetracker/bloc/charts_bloc.dart';
import 'package:expensetracker/bloc/datetime_bloc.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/bloc/category_bloc.dart';
import 'package:expensetracker/common/color.dart';
import 'package:expensetracker/common/money_formatter.dart';

class ChartScreen extends StatefulWidget {
  ChartScreen();
  @override
  State<StatefulWidget> createState() => ChartState();
}

class ChartState extends State<ChartScreen> {
  final _chartBloc = ChartBloc();
  final _dateTimeBloc = DateTimeBloc();
  final _categoryBloc = CategoryBloc();

  int totalAmount = 0;
  String monthName = "";
  List<CategoryModel> lstCategory;

  @override
  void initState() {
    super.initState();
    initMonthName();
    getCategoryList();
  }

  @override
  void dispose() {
    super.dispose();
    _dateTimeBloc.dispose();
    _chartBloc.dispose();
    _categoryBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chart'),
        centerTitle: true,
      ),
      body: Padding(
        padding: EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(Icons.search),
                SizedBox(
                  width: 10,
                ),
                Text("Month: "),
                IconButton(
                  icon: Icon(Icons.arrow_left),
                  onPressed: () {
                    prevMonth();
                  },
                ),
                getMonthName(),
                IconButton(
                  icon: Icon(Icons.arrow_right),
                  onPressed: () {
                    nextMonth();
                  },
                ),
              ],
            ),
            Text("Expenses by category"),
            expenseChart()
          ],
        ),
      ),
    );
  }

  Material chartContainer(dynamic chart) {
    return Material(
        color: Colors.white,
        elevation: 14.0,
        shadowColor: Color(0x802196F3),
        borderRadius: BorderRadius.circular(24.0),
        child: chart);
  }

  Widget expenseChart() {
    return StreamBuilder<Map<String, double>>(
      stream: _chartBloc.expenseChartValue,
      builder:
          (BuildContext context, AsyncSnapshot<Map<String, double>> snapshot) {
        if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        }
        switch (snapshot.connectionState) {
          case ConnectionState.waiting:
            return Text(
              "",
              style: TextStyle(color: Colors.blue),
            );
          default:
            if (snapshot.data.length > 0) {
              List<ExpenseData> chartData = List<ExpenseData>();
              
              chartData.clear();
              snapshot.data.forEach((k, v) {
                chartData.add(ExpenseData(k, v, getCategoryColor(k, defaultColorCode())));
              });

              var series = [
                charts.Series(
                    data: chartData,
                    domainFn: (ExpenseData expenseData, _) =>
                        expenseData.categoryName,
                    measureFn: (ExpenseData expenseData, _) => expenseData.amt,
                    colorFn: (ExpenseData expenseData, _) => expenseData.color,
                    id: 'Expense',
                    labelAccessorFn: (ExpenseData expenseData, _) =>
                        '${expenseData.categoryName}: ${currencyFormatWithoutSymbol(expenseData.amt)}')
              ];

              var chart = charts.PieChart(
                series,
                defaultRenderer: charts.ArcRendererConfig(
                    arcRendererDecorators: [charts.ArcLabelDecorator()],
                    arcWidth: 100),
                animate: true,
              );

              var lstView = ListView.builder(
                scrollDirection: Axis.vertical,
                shrinkWrap: true,
                // Must have an item count equal to the number of items!
                itemCount: chartData.length,
                // A callback that will return a widget.
                itemBuilder: (BuildContext context, int idx) {
                  // In our case, a DogCard for each doggo.
                  if (idx == 0) {
                    return Column(
                      children: <Widget>[
                        SizedBox(height: 400, child: chartContainer(chart)),
                        ListTile(
                          title: Text(chartData[idx].categoryName),
                          //leading: Icon(Icons.inbox, color: Colors.blue, size: 26.0),
                          leading: ClipOval(
                            child: Container(
                                color: getCategoryColor(chartData[idx].categoryName, defaultColorCode()),
                                height: 40.0, // height of the button
                                width: 40.0, // width of the button
                                child: Center(
                                  child: Text("E"),
                                )),
                          ),
                          trailing: Text(currencyFormatWithSymbol(chartData[idx].amt)),
                        )
                      ],
                    );
                  } else {
                    return ListTile(
                      title: Text(chartData[idx].categoryName),
                      //leading: Icon(Icons.inbox, color: Colors.blue, size: 26.0),
                      leading: ClipOval(
                        child: Container(
                            color: getCategoryColor(chartData[idx].categoryName, defaultColorCode()),
                            height: 40.0, // height of the button
                            width: 40.0, // width of the button
                            child: Center(
                              child: Text("E"),
                            )),
                      ),
                      trailing: Text(currencyFormatWithSymbol(chartData[idx].amt)),
                    );
                  }
                },
              );

              return Expanded(
                child: Container(
                  padding: EdgeInsets.all(5.0),
                  child: lstView,
                ),
              );
            } else {
              return Text("No Records Found");
            }
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
            _dateTimeBloc.setSharedPreference(
                SharedPreferenceKey.monthName.index.toString(), monthName);
            return Text(snapshot.data);
        }
      },
    );
  }

  void cData(DateTime dt) {
    _chartBloc.getCategoryBasedTrackAmount(
        CategoryType.expense,
        _dateTimeBloc.getFirstDateOftheMonth(year: dt.year, month: dt.month),
        _dateTimeBloc.getLastDateOftheMonth(year: dt.year, month: dt.month));
  }

  void currentMonth() {
    DateTime dt = _dateTimeBloc.currentMonth(monthName);
    cData(dt);
  }

  void nextMonth() {
    DateTime dt = _dateTimeBloc.nextMonth(monthName);
    cData(dt);
  }

  void prevMonth() {
    DateTime dt = _dateTimeBloc.prevMonth(monthName);
    cData(dt);
  }

  void initMonthName() {
    _dateTimeBloc
        .getSharedPreference(SharedPreferenceKey.monthName.index.toString())
        .then((mName) {
      if (mName != null) {
        monthName = mName;
      } else {
        monthName = _dateTimeBloc.getCurrentMonthName();
      }
      currentMonth();
    });
  }

  void getCategoryList() async {
    lstCategory = await _categoryBloc.getActiveCategoryListByType(CategoryType.expense);
  }

  Color getCategoryColor(String categoryName, int defaultColorCode) {
    int colorCode = defaultColorCode;
    if (lstCategory != null) {
      colorCode = lstCategory.singleWhere((item) => item.categoryName == categoryName).color;
      if(colorCode == null) {
        colorCode = defaultColorCode;
      }   
    } else {
      colorCode = defaultColorCode;
    }
    return Color(colorCode);
  }
}

class ExpenseData {
  final String categoryName;
  final double amt;
  final charts.Color color;

  ExpenseData(this.categoryName, this.amt, Color color)
      : this.color = charts.Color(
            r: color.red, g: color.green, b: color.blue, a: color.alpha);
}

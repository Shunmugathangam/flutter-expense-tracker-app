import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/bloc/track_bloc.dart';
import 'package:expensetracker/bloc/datetime_bloc.dart';
import 'package:expensetracker/common/money_formatter.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_share/simple_share.dart';

class SummaryScreen extends StatefulWidget {

  SummaryScreen();

  @override
  SummaryScreenState createState() => new SummaryScreenState();

}

class SummaryScreenState extends State<SummaryScreen> {

  SummaryScreenState();

  final _trackBloc = TrackBloc();
  final _dateTimeBloc = DateTimeBloc();

  @override
  void initState() {
    super.initState();
    totalSavings();
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
      appBar: AppBar(
        title: Text('Summary'),
        centerTitle: true,
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share), 
              onPressed: () async {
                  String filePath = await generateDocument();
                  if(filePath != "") {
                      final uri = Uri.file(filePath);
                      shareFile(uri.toString());
                  }
              }
              ),
            Padding(padding: EdgeInsets.only(right: 10.0),)
        ],
      ),
      body: Column(
      children: <Widget>[
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
          Text("Total Savings: ", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 ),),
          getTrackTotal(),
        ],),
        SizedBox(height: 20),
        FutureBuilder(future: _asyncMonthWiseTrackAmount(),
          builder:  (BuildContext context, AsyncSnapshot<List<Map<String, dynamic>>> dt) {
            return SingleChildScrollView( 
              scrollDirection: Axis.horizontal,
              child: buildMonthWiseTotalAmountTable(dt.data),);
        }),
      ]),
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
                  return Text(currencyFormatWithSymbol(double.tryParse(snapshot.data.toString())), style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15 ),);
              }
            },
          );
  }

  Future<List<Map<String, dynamic>>> _asyncMonthWiseTrackAmount() async {
     List<Map<String, dynamic>> monthWiseIncomeTotalAmountlst =  await _trackBloc.getMonthWiseAmount(CategoryType.income);
    
     List<Map<String, dynamic>> lst = new List<Map<String, dynamic>>();

     monthWiseIncomeTotalAmountlst.forEach((data){
          lst.add({"Year": data["Year"], "Month": data["Month"], "Income": data["TotalAmount"], "Expense": 0});
     });

     List<Map<String, dynamic>> monthWiseExpenseTotalAmountlst =  await _trackBloc.getMonthWiseAmount(CategoryType.expense);

     monthWiseExpenseTotalAmountlst.forEach((data){
        if (lst.where((m) => m["Year"] == data["Year"] && m["Month"] == data["Month"]).toList().length == 1) {
            int idx = lst.indexWhere((m) => m["Year"] == data["Year"] && m["Month"] == data["Month"]);
            lst[idx]["Expense"] = data["TotalAmount"];
        }
        else{
          lst.add({"Year": data["Year"], "Month": data["Month"], "Income": 0, "Expense": data["TotalAmount"]});
        }
     });

     return lst;
  }


  Widget buildMonthWiseTotalAmountTable(List<Map<String, dynamic>> snapshot) {
    if(snapshot != null && snapshot.length > 0) {
        return DataTable(columns: <DataColumn>[
                DataColumn(
                  label: Text("Month"),
                  numeric: false,
                  onSort: (i, b) {},
                  tooltip: "Month",
                ),
                DataColumn(
                  label: Text("Income"),
                  numeric: true,
                  onSort: (i, b) {},
                  tooltip: "Income",
                ),
                DataColumn(
                  label: Text("Expense"),
                  numeric: true,
                  onSort: (i, b) {},
                  tooltip: "Expense",
                ),
                DataColumn(
                  label: Text("Savings"),
                  numeric: true,
                  onSort: (i, b) {},
                  tooltip: "Savings",
                ),
              ], rows: _createRows(snapshot));
    }
    else {
        return Text("");
    }
    
  }

  List<DataRow> _createRows(List<Map<String, dynamic>> snapshot) {
    int idx = -1;
        List<DataRow> newList = snapshot.map((Map<String, dynamic> model) {
          idx++;
          return new DataRow(
            cells: <DataCell>[
              _createCellsForElement(idx, model["Year"].toString() + "-" + model["Month"].toString()),
              _createCellsForElement(idx, currencyFormatWithoutSymbol(double.tryParse(model["Income"].toString()))),
              _createCellsForElement(idx, currencyFormatWithoutSymbol(double.tryParse(model["Expense"].toString()))),
              _createCellsForElement(idx, calculateSavings(model["Income"], model["Expense"])),
            ],
          );
        }).toList();
        return newList;
  }

  String calculateSavings(int income, int expense) {
      int savings = income - expense;
      String sav = currencyFormatWithoutSymbol(double.tryParse(savings.toString()));
      return sav;
  }

  DataCell _createCellsForElement(int idx, String cellData) {
    return DataCell(Text(cellData),
      showEditIcon: false,
      placeholder: false,
      onTap: () {
        
      },
    );
  }

  String getCategoryTypeName(CategoryType categoryType) {
      List<String> cName = categoryType.toString().split(".");
      String categoryTypeName = cName[1];
      return categoryTypeName[0].toUpperCase() + categoryTypeName.substring(1);
  }

  String generateMonthWiseTrackAmountRow(List<Map<String, dynamic>> lst) {
      String dataRow = "";
      lst.forEach((model) {
          dataRow += "<tr><td>" + model["Year"].toString() + "-" + model["Month"].toString() + "</td><td>" + currencyFormatWithoutSymbol(double.tryParse(model["Income"].toString())) + "</td><td>" + currencyFormatWithoutSymbol(double.tryParse(model["Expense"].toString())) + "</td><td> ₹ " + calculateSavings(model["Income"], model["Expense"]) + "</td></tr>";
      });

      if(lst.length == 0) {
        dataRow += "<tr><td colspan='4'></td></tr>";
      }

      return dataRow;
  }

  String generatedPdfFilePath;

  Future<String> generateDocument() async {

    generatedPdfFilePath = "";

    List<Map<String, dynamic>> lst = await _asyncMonthWiseTrackAmount();
    int savingsAmt = await gettotalSavings();
    
    var htmlContent = """
    <!DOCTYPE html>
    <html>
    <head>
        <style>
        table, th, td {
          border: 1px solid black;
          border-collapse: collapse;
        }
        td, p {
          padding: 5px;
          text-align: left;
        }
        th {
          padding-top: 12px;
          padding-bottom: 12px;
          padding-left: 5px;
          background-color: #4CAF50;
          text-align: left;
        }
        table tr:nth-child(even){background-color: #f2f2f2;}
        table tr:hover {background-color: #ddd;}
        </style>
      </head>
      <body>
        <p><b>Date: """ + DateTime.now().toString() + """</b></p>
        <h2>Summary Report</h2>
        <h3>Total Savings: """ + savingsAmt.toString() + """</h3>

        <table id="expenseTable" style="width:100%">
          <caption></caption>
          <tr>
            <th>Month</th>
            <th>Income</th>
            <th>Expense</th>
            <th>Savings</th>
          </tr>

          """ + generateMonthWiseTrackAmountRow(lst) + """
          
        </table>

      </body>
    </html>

    """;

    //Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory appDocDir = await getTemporaryDirectory();
    var targetPath = appDocDir.path;
    var targetFileName =  "Summary_Report";
    var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, targetPath, targetFileName);
    generatedPdfFilePath = generatedPdfFile.path;

    return generatedPdfFilePath;
  }

  void shareFile(String filePath) async {
     SimpleShare.share(
                uri: filePath,
                title: "Monthly Report",
                subject: "Summary Report",
                msg: "Please find the attached Summary Report");
  }

  void totalSavings(){
    _trackBloc.totalSavings();
  }

  Future<int> gettotalSavings() async {
      int amt = await _trackBloc.totalSavingsAmount();
      return amt;
  }

}



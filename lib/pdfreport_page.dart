import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_pdf_renderer/flutter_pdf_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:simple_share/simple_share.dart';

import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/model/budgetexpensemap_model.dart';
import 'package:expensetracker/common/date.dart';
import 'package:expensetracker/bloc/budgetexpensemap_bloc.dart';
import 'package:expensetracker/bloc/datetime_bloc.dart';
import 'package:expensetracker/bloc/track_bloc.dart';
import 'package:expensetracker/model/track_model.dart';

class PdfReportPage extends StatefulWidget {
  
  PdfReportPage();

  @override
  _PdfReportPageState createState() => _PdfReportPageState();
}

class _PdfReportPageState extends State<PdfReportPage> {

  _PdfReportPageState();

  final _dateTimeBloc = DateTimeBloc();
  String monthName = "";
  String fromDate;
  String toDate;
  List<BudgetExpenseAmoutModel> tablelst = new List<BudgetExpenseAmoutModel>();

  final _budgetExpenseMapBloc = BudgetExpenseMapBloc();
  final _trackBloc = TrackBloc();

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

  String generatedPdfFilePath;

  Future<String> generateDocument() async {

    generatedPdfFilePath = "";

    List<BudgetExpenseAmoutModel> lst = await categoryBasedAmount();
    List<TrackDetailsModel> expenselst = await expenseList();
    
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
        <h2>""" + "Report for the Month " + formatDateMMMyyyy(fromDate) + """</h2>
        <h3>Budget Expense Comparison Report:</h3>

        <table id="trackTable" style="width:100%">
          <caption></caption>
          <tr>
            <th>Category</th>
            <th>Budgeted Amount</th>
            <th>Actual Amount</th>
            <th>Difference</th>
          </tr>

          """ + generateRow(lst) + """ 
          
        </table>

        <h3>Expense breakup Report:</h3>

        <table id="expenseTable" style="width:100%">
          <caption></caption>
          <tr>
            <th>Category</th>
            <th>Date</th>
            <th>Description</th>
            <th>Amount</th>
          </tr>

          """ + generateExpensesRow(expenselst) + """
          
        </table>

      </body>
    </html>

    """;

    //Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory appDocDir = await getTemporaryDirectory();
    var targetPath = appDocDir.path;
    var targetFileName =  "Budget_Expense_Comparison_" + formatDateMMMyyyy(fromDate);
    var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, targetPath, targetFileName);
    generatedPdfFilePath = generatedPdfFile.path;

    return generatedPdfFilePath;
  }

  String getCategoryTypeName(CategoryType categoryType) {
      List<String> cName = categoryType.toString().split(".");
      String categoryTypeName = cName[1];
      return categoryTypeName[0].toUpperCase() + categoryTypeName.substring(1);
  }


  String generateRow(List<BudgetExpenseAmoutModel> lst) {
      String dataRow = "";
      int dataFlag = 0;
      lst.forEach((val) {
        if(val.budgetAmount != 0 || val.expenseAmount != 0) {
            if(val.categoryName == "Total:") {
              dataRow += "<tr style='background-color: #696969; color: #ffffff;'><td><b>" + val.categoryName + "</b></td><td><b> ₹ " + val.budgetAmount.toString() + "</b></td><td><b> ₹ " + val.expenseAmount.toString() + "</b></td><td><b> ₹ " + (val.budgetAmount - val.expenseAmount).toString() + "</b></td></tr>";
            }
            else {
              dataRow += "<tr><td>" + val.categoryName + "</td><td> ₹ " + val.budgetAmount.toString() + "</td><td> ₹ " + val.expenseAmount.toString() + "</td><td> ₹ " + (val.budgetAmount - val.expenseAmount).toString() + "</td></tr>";
            }
            dataFlag = 1;
        }
      });

      if(dataFlag == 0) {
        dataRow += "<tr><td colspan='4' style='text-align: center;'>No Records Found</td></tr>";
      }

      return dataRow;
  }

  Future<List<BudgetExpenseAmoutModel>> categoryBasedAmount() async {

      List<BudgetExpenseCategoryIdNameModel> lst = await _budgetExpenseMapBloc.selectBudgetExpenseCategoryNameAndId();

      List<CategoryTotalAmoutModel> categoryTotalAmoutModel = await _budgetExpenseMapBloc.lstCategoryTotalAmout(fromDate, toDate);

      List<BudgetExpenseAmoutModel> categoryData = List<BudgetExpenseAmoutModel>();

      categoryData.clear();

      int budgetAmount = 0;
      int expenseAmount = 0;

      int budgetTotalAmount = 0;
      int expenseTotalAmount = 0;

      lst.forEach((val) {

        budgetAmount = categoryTotalAmoutModel.where((item) => item.categoryId == val.budgetCategoryId).length > 0 ? categoryTotalAmoutModel.where((item) => item.categoryId == val.budgetCategoryId).take(1).first.totalamount : 0;
        expenseAmount = categoryTotalAmoutModel.where((item) => item.categoryId == val.expenseCategoryId).length > 0 ? categoryTotalAmoutModel.where((item) => item.categoryId == val.expenseCategoryId).take(1).first.totalamount : 0;

        budgetTotalAmount += budgetAmount;
        expenseTotalAmount += expenseAmount;

        categoryData.add(BudgetExpenseAmoutModel(categoryName: val.expenseCategoryName, 
                                                  expenseAmount: expenseAmount,
                                                  budgetAmount: budgetAmount));
    
      });

      categoryData.add(BudgetExpenseAmoutModel(categoryName: "Total:", 
                                                  expenseAmount: expenseTotalAmount,
                                                  budgetAmount: budgetTotalAmount));
      
      return categoryData;
  }


  Future<List<TrackDetailsModel>> expenseList() async {
    List<TrackDetailsModel> lst = await _trackBloc.getTrackDetailsLst(CategoryType.expense, fromDate, toDate);
    return lst;
  }

  String generateExpensesRow(List<TrackDetailsModel> lst) {
      String dataRow = "";
      lst.forEach((val) {
          dataRow += "<tr><td>" + val.categoryName + "</td><td>" + formatDate(val.trackDate) + "</td><td>" + val.description + "</td><td> ₹ " + val.amount.toString() + "</td></tr>";
      });

      if(lst.length == 0) {
        dataRow += "<tr><td colspan='4' style='text-align: center;'>No Records Found</td></tr>";
      }

      return dataRow;
  }


  void shareFile(String filePath) async {
     SimpleShare.share(
                uri: filePath,
                title: "Monthly Report",
                subject: formatDateMMMyyyy(fromDate) + "  Report",
                msg: "Please find the attached report for the month " + formatDateMMMyyyy(fromDate));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Report'),
        centerTitle: true,
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share), 
              onPressed: () async {
                  if(generatedPdfFilePath != "") {
                      final uri = Uri.file(generatedPdfFilePath);
                      shareFile(uri.toString());
                  }
              }
              ),
            Padding(padding: EdgeInsets.only(right: 10.0),)
        ],
      ),
      body: Column(children: <Widget>[

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
                child: Row(mainAxisAlignment: MainAxisAlignment.end, children: <Widget>[Text(""), SizedBox(width: 20,)],)
              ),
        ],),),

        FutureBuilder<String>(
            future: generateDocument(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              Text text = Text('');
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  text = Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  text = Text(snapshot.data);
                  if(snapshot.data == "No Records Found"){
                      return Center(child: text);
                  }
                  else{
                      return PdfRenderer(pdfFile: snapshot.data, width: 500.0);
                  }
                  
                  
                } else {
                  text = Text('Unavailable');
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                text = Text('Downloading PDF File...');
              } else {
                text = Text('Please load a PDF file.');
              }
              return Container(
                child: Center(child: text)
              );
            },
          ),

      ],)
      
      
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

  setFromAndTodate(DateTime dt){
    setState(() {
      fromDate = _dateTimeBloc.getFirstDateOftheMonth(year: dt.year, month: dt.month);
      toDate =  _dateTimeBloc.getLastDateOftheMonth(year: dt.year, month: dt.month);
    });
  }

  void currentMonth() {
      DateTime dt = _dateTimeBloc.currentMonth(monthName);
      setFromAndTodate(dt);
  }

  void nextMonth() {
      DateTime dt = _dateTimeBloc.nextMonth(monthName);
      setFromAndTodate(dt);
  }

  void prevMonth() {
      DateTime dt = _dateTimeBloc.prevMonth(monthName);
      setFromAndTodate(dt);
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
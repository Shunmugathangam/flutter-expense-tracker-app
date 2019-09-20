import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_pdf_renderer/flutter_pdf_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/services.dart';
import 'package:simple_share/simple_share.dart';
import "package:collection/collection.dart";

import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/model/track_model.dart';
import 'package:expensetracker/common/date.dart';

class PdfViewerPage extends StatefulWidget {
  
  final CategoryType categoryType;
  final List<TrackDetailsModel> lstTrackDetails;
  final String totalAmt;

  PdfViewerPage({this.categoryType, this.lstTrackDetails, this.totalAmt});

  @override
  _PdfViewerPageState createState() => _PdfViewerPageState(
    categoryType: this.categoryType,
    lstTrackDetails: this.lstTrackDetails,
    totalAmt: this.totalAmt
  );
}

class _PdfViewerPageState extends State<PdfViewerPage> {

  final CategoryType categoryType;
  final List<TrackDetailsModel> lstTrackDetails;
  final String totalAmt;

  _PdfViewerPageState({this.categoryType, this.lstTrackDetails, this.totalAmt});

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  String generatedPdfFilePath;

  Future<String> generateDocument(List<TrackDetailsModel> lst) async {

    generatedPdfFilePath = "";
    
    if(lst == null) {
        return "No Records Found";
    }
    else if(lst != null && lst.length == 1 && lst[0].categoryName == null){
      return "No Records Found";
    }

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
        <h2>""" + getCategoryTypeName(categoryType) + " of " + formatDateMMMyyyy(lst[0].trackDate) + """</h2>

        <table id="trackTable" style="width:100%">
          <caption></caption>
          <tr>
            <th>Date</th>
            <th>Category</th>
            <th>Description</th>
            <th>Amount</th>
          </tr>

          """ + generateRow(lst) + """
          
        </table>

        <p><b>Total:""" + totalAmt + """</b></p>

        <h2>Category Based Amount</h2>

        <table id="categoryTable" style="width:100%">
          <caption></caption>
          <tr>
            <th>Category</th>
            <th>Amount</th>
          </tr>

          """ + generateCategoryRow(lst) + """
          
        </table>

      </body>
    </html>

    """;

    //Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory appDocDir = await getTemporaryDirectory();
    var targetPath = appDocDir.path;
    var targetFileName = getCategoryTypeName(categoryType) + "_" + formatDateMMMyyyy(lst[0].trackDate);
    print(targetFileName);
    var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, targetPath, targetFileName);
    generatedPdfFilePath = generatedPdfFile.path;

    return generatedPdfFilePath;
  }

  String generateRow(List<TrackDetailsModel> lst) {
      String dataRow = "";
      lst.forEach((val) {
          dataRow += "<tr><td>" + formatDate(val.trackDate) + "</td><td>" + val.categoryName + "</td><td>" + val.description + "</td><td> ₹ " + val.amount.toString() + "</td></tr>";
      });
      return dataRow;
  }

  String getCategoryTypeName(CategoryType categoryType) {
      List<String> cName = categoryType.toString().split(".");
      String categoryTypeName = cName[1];
      return categoryTypeName[0].toUpperCase() + categoryTypeName.substring(1);
  }

  String generateCategoryRow(List<TrackDetailsModel> lst) {
      List<CategoryBasedAmountModel> categoryData = categoryBasedAmount(lst);
      String dataRow = "";
      categoryData.forEach((val) {
          dataRow += "<tr><td>" + val.categoryName + "</td><td> ₹ " + val.totalAmount.toString() + "</td></tr>";
      });
      return dataRow;
  }

  List<CategoryBasedAmountModel> categoryBasedAmount(List<TrackDetailsModel> lst) {
      var categoryGroup = groupBy(lst, (obj) => obj.categoryName);
      List<CategoryBasedAmountModel> categoryData = List<CategoryBasedAmountModel>();

      categoryData.clear();
      int amt;
      categoryGroup.forEach((k, v) {
        amt = 0;
        v.forEach((val) {
          amt += val.amount;
        });

        categoryData.add(CategoryBasedAmountModel(categoryName: k, totalAmount: amt));
      });

      return categoryData;
  }
  

  void shareFile(String filePath) async {
     SimpleShare.share(
                uri: filePath,
                title: "Monthly Report",
                subject: formatDateMMMyyyy(this.lstTrackDetails[0].trackDate) + " " + getCategoryTypeName(categoryType) + " Report",
                msg: "Please find the attached " + getCategoryTypeName(categoryType) + " report for the month " + formatDateMMMyyyy(this.lstTrackDetails[0].trackDate));
  }

  Future<String> getFilePath() async {
    try {
      String filePath = await FilePicker.getFilePath(type: FileType.ANY);
      if (filePath == '') {
        return "";
      }
      print("File path: " + filePath);
      return filePath;
    } on PlatformException catch (e) {
      print("Error while picking the file: " + e.toString());
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Pdf Report'),
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
      body: FutureBuilder<String>(
            future: generateDocument(this.lstTrackDetails),
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
    );
  }
}
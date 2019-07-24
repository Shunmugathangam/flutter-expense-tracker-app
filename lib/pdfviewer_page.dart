import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
import 'package:flutter_pdf_renderer/flutter_pdf_renderer.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share/share.dart';
import 'package:share_extend/share_extend.dart';
import 'package:simple_share/simple_share.dart';

class PdfViewerPage extends StatefulWidget {
  @override
  _PdfViewerPageState createState() => _PdfViewerPageState();
}

class _PdfViewerPageState extends State<PdfViewerPage> {
  String generatedPdfFilePath;

  Future<String> generateExampleDocument() async {
    var htmlContent = """
    <!DOCTYPE html>
    <html>
    <head>
        <style>
        table, th, td {
          border: 1px solid black;
          border-collapse: collapse;
        }
        th, td, p {
          padding: 5px;
          text-align: left;
        }
        </style>
      </head>
      <body>
        <h2>PDF Generated with flutter_html_to_pdf plugin</h2>

        <table style="width:100%">
          <caption>Sample HTML Table</caption>
          <tr>
            <th>Month</th>
            <th>Savings</th>
          </tr>
          <tr>
            <td>January</td>
            <td>100</td>
          </tr>
          <tr>
            <td>February</td>
            <td>50</td>
          </tr>
        </table>

        <p>Image loaded from web</p>
        <img src="https://i.imgur.com/wxaJsXF.png" alt="web-img">
      </body>
    </html>
    """;

    Directory appDocDir = await getApplicationDocumentsDirectory();
    var targetPath = appDocDir.path;
    var targetFileName = "example-pdf";

    var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
        htmlContent, targetPath, targetFileName);
    generatedPdfFilePath = generatedPdfFile.path;

    return generatedPdfFilePath;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
      appBar: AppBar(
        title: Text('Pdf Report'),
        centerTitle: true,
        actions: <Widget>[
            IconButton(
              icon: Icon(Icons.share), 
              onPressed: () {
                  //Share.share('Report ' + uri.toString());


                  // SimpleShare.share(
                  //     uri: generatedPdfFilePath,
                  //     title: "Expense Details",
                  //     msg: "Expense data");

              },
              ),
            Padding(padding: EdgeInsets.only(right: 10.0),)
        ],
      ),
      body: FutureBuilder<String>(
            future: generateExampleDocument(),
            builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
              Text text = Text('');
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  text = Text('Error: ${snapshot.error}');
                } else if (snapshot.hasData) {
                  text = Text('Data: ${snapshot.data}');
                  return PdfRenderer(pdfFile: snapshot.data, width: 500.0);
                } else {
                  text = Text('Unavailable');
                }
              } else if (snapshot.connectionState == ConnectionState.waiting) {
                text = Text('Downloading PDF File...');
              } else {
                text = Text('Please load a PDF file.');
              }
              return Container(
                child: text,
              );
            },
          ),
    ));
  }
}
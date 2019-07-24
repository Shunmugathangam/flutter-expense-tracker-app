// import 'dart:async';
// import 'dart:io';
// import 'package:flutter_full_pdf_viewer/flutter_full_pdf_viewer.dart';
// import 'package:flutter_html_to_pdf/flutter_html_to_pdf.dart';
// import 'package:path_provider/path_provider.dart';

// Future<String> generatePdfDocument(String fileName, String htmlContent) async {
//     Directory appDocDir = await getApplicationDocumentsDirectory();
//     var targetPath = appDocDir.path;
//     var targetFileName = fileName;

//     var generatedPdfFile = await FlutterHtmlToPdf.convertFromHtmlContent(
//         htmlContent, targetPath, targetFileName);
//      return generatedPdfFile.path;
//   }
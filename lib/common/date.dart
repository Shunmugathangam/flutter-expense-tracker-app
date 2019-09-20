import 'package:intl/intl.dart';

String formatDate(String date) {
      DateTime todayDate = DateTime.parse(date);
      DateFormat formatter = new DateFormat('dd/MMM/yyyy');
      String formatted = formatter.format(todayDate);
      return formatted;
}

String formatDateMMMyyyy(String date) {
      DateTime todayDate = DateTime.parse(date);
      DateFormat formatter = new DateFormat('MMM yyyy');
      String formatted = formatter.format(todayDate);
      return formatted;
}
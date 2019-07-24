import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'dart:async';

import 'package:expensetracker/bloc/datetime_event.dart';

class DateTimeBloc {

  DateTimeBloc() {
      _monthNameEventController.stream.listen(_mapEventToState);
  }


  String monthName = "";
  
  final _monthNameStateController = StreamController<String>();

  StreamSink<String> get _inMonthName => _monthNameStateController.sink;

  Stream<String> get outMonthName => _monthNameStateController.stream;

  final _monthNameEventController = StreamController<DateTimeEvent>();

  Sink<DateTimeEvent> get monthNameEvent => _monthNameEventController.sink;

  void _mapEventToState(DateTimeEvent event){
      if(event is OnDateChangeEvent){
        monthName = getMonthName(event.dateTime);
      }
      _inMonthName.add(monthName);
  }

  void dispose() {
    _monthNameStateController.close();
    _monthNameEventController.close();
  }

  String getCurrentMonthName() {
      DateTime now = new DateTime.now();
      DateFormat formatter = new DateFormat('MMM yyyy');
      String formatted = formatter.format(now);
      return formatted;
  }

  String getMonthName(DateTime date) {
      DateFormat formatter = new DateFormat('MMM yyyy');
      String formatted = formatter.format(date);
      return formatted;
  }

  int getMonthValue(String monthName) {

    switch(monthName) {
          case "Jan": { 
            return 1;
          } 
          break; 
          
          case "Feb": { 
              return 2;
          } 
          break; 

          case "Mar": { 
              return 3;
          } 
          break; 

          case "Apr": { 
             return 4;
          } 
          break; 
          
          case "May": { 
              return 5; 
          } 
          break; 

          case "Jun": { 
              return 6; 
          } 
          break; 
          case "Jul": { 
             return 7; 
          } 
          break; 
          
          case "Aug": { 
              return 8; 
          } 
          break; 

          case "Sep": { 
              return 9;
          } 
          break; 
          case "Oct": { 
            return 10;
          } 
          break; 
          
          case "Nov": { 
              return 11;
          } 
          break; 

          case "Dec": { 
              return 12;
          } 
          break; 
              
          default: { 
              return 0;  
          }
          break; 
    }

  }
  
  void monthNameEvt(DateTime date) {
      monthNameEvent.add(OnDateChangeEvent(date));
  }

  String getFirstDateOftheCurrentMonth() {
      DateTime now = new DateTime.now();
      return firstDate(now);
  }

  String getLastDateOftheCurrentMonth() {
      DateTime now = new DateTime.now();
      return lastDate(now);
  }


  String getFirstDateOftheMonth({int year, int month}) {
      DateTime date = getDateTime(year: year, month: month);
      return firstDate(date);
  }

  String getLastDateOftheMonth({int year, int month}) {
      DateTime date = getDateTime(year: year, month: month);
      return lastDate(date);
  }

  DateTime getDateTime({int year, int month}){
      int y = year != null ? year : DateTime.now().year;
      int m = month != null ? month : DateTime.now().month;
      
      DateTime date = DateTime.parse(y.toString() + "-" + (m < 10 ? '0' + m.toString(): m.toString()) + "-01");
      return date;
  }

  String firstDate(DateTime date){
      DateFormat formatter = new DateFormat('yyyy-MM');
      String formatted = formatter.format(date);
      String firstDate = formatted + "-01";
      return firstDate;
  }

  String lastDate(DateTime date){
      // Find the last day of the month.
      DateTime beginningNextMonth = (date.month < 12) ? new DateTime(date.year, date.month + 1, 1) : new DateTime(date.year + 1, 1, 1);
      int lastDay = beginningNextMonth.subtract(new Duration(days: 1)).day;

      DateFormat formatter = new DateFormat('yyyy-MM');
      String formatted = formatter.format(date);
      String lastDate = formatted + "-" + lastDay.toString(); 
      return lastDate;
  }

  String formatDate(String date) {
      DateTime todayDate = DateTime.parse(date);
      DateFormat formatter = new DateFormat('dd/MMM/yyyy');
      String formatted = formatter.format(todayDate);
      return formatted;
  }

  DateTime nextMonth(String monthName) {
      List<String> lst = monthName.split(" ");
      int monthVal = getMonthValue(lst[0]);
      if(monthVal == 12){
        monthVal = 1;
      }
      else{
        monthVal = monthVal + 1;
      }
      DateTime dt = DateTime.parse((monthVal == 1 ? (int.parse(lst[1]) + 1) : int.parse(lst[1])).toString() + "-" + (monthVal < 10 ? '0' + monthVal.toString():monthVal.toString()) + "-01");
      monthNameEvt(dt);
      return dt;
  }

  DateTime prevMonth(String monthName) {
      List<String> lst = monthName.split(" ");
      int monthVal = getMonthValue(lst[0]);
      if(monthVal == 1){
        monthVal = 12;
      }
      else{
        monthVal = monthVal - 1;
      }
      DateTime dt = DateTime.parse((monthVal == 12 ? (int.parse(lst[1]) - 1) : int.parse(lst[1])).toString() + "-" + (monthVal < 10 ? '0' + monthVal.toString():monthVal.toString()) + "-01");
      monthNameEvt(dt);
      return dt;
  }

  DateTime currentMonth(String monthName) {
      List<String> lst = monthName.split(" ");
      int monthVal = getMonthValue(lst[0]);
      DateTime dt = DateTime.parse(lst[1] + "-" + (monthVal < 10 ? '0' + monthVal.toString() : monthVal.toString()) + "-01");
      monthNameEvt(dt);
      return dt;
  }

  void setSharedPreference(String key, String monthName) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString("datetimebloc" + key, monthName);
  }

  Future<String> getSharedPreference(String key) async {
    final prefs = await SharedPreferences.getInstance();
    String str = prefs.getString("datetimebloc" + key);
    return  str;
  }

}


enum SharedPreferenceKey { 
   monthName
}
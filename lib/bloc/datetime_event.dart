import 'package:expensetracker/model/track_model.dart';

abstract class DateTimeEvent { }

class OnDateChangeEvent extends DateTimeEvent {
  final DateTime dateTime;
  OnDateChangeEvent(this.dateTime);
}

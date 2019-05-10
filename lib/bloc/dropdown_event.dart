import 'package:expensetracker/model/dropdown_model.dart';

abstract class DropdownEvent { }

class OnSelectedEvent extends DropdownEvent {
  final DropdownModel selectedValue;

  OnSelectedEvent(this.selectedValue);
}
import 'dart:async';
import 'package:expensetracker/model/dropdown_model.dart';
import 'package:expensetracker/bloc/dropdown_event.dart';

class  DropdownBloc {

  DropdownModel selectedVal;
  
  final _dropdownStateController = StreamController<DropdownModel>();

  StreamSink<DropdownModel> get _inSelectedValue => _dropdownStateController.sink;

  Stream<DropdownModel> get selectedValue => _dropdownStateController.stream;

  final _dropdownEventController = StreamController<DropdownEvent>();

  Sink<DropdownEvent> get dropdownEvent => _dropdownEventController.sink;

  DropdownBloc() {
      _dropdownEventController.stream.listen(_mapEventToState);
  }

  void _mapEventToState(DropdownEvent event){
      if(event is OnSelectedEvent){
        selectedVal = event.selectedValue;
      }

      _inSelectedValue.add(selectedVal);
  }

  void dispose(){
    _dropdownStateController.close();
    _dropdownEventController.close();
  }
  
}
import 'dart:async';
import "package:collection/collection.dart";
import 'package:expensetracker/repository/track_repository.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/bloc/charts_event.dart';

class ChartBloc {

  ChartBloc() {
     _chartEventController.stream.listen(_mapEventToState);
  }

  Map<String, double> chartModelList = new Map<String, double>();
  
  final _chartStateController = StreamController<Map<String, double>>();

  StreamSink<Map<String, double>> get _inExpenseChartValue => _chartStateController.sink;

  Stream<Map<String, double>> get expenseChartValue => _chartStateController.stream;

  final _chartEventController = StreamController<ChartEvent>();

  Sink<ChartEvent> get chartEvent => _chartEventController.sink;

  void _mapEventToState(ChartEvent event){
      if(event is OnChartExpenseDataLoadEvent){
        chartModelList = event.lst;
      }
      _inExpenseChartValue.add(chartModelList);
  }

  Future<Map<String, dynamic>> getCategoryBasedTrackAmount(CategoryType categoryType, String fromDate, String toDate) async {
    Map<String, double> trackDataMap = new Map<String, double>();
    final rows = await trackRepository.getCategoryBasedTrackAmount(
        categoryType, fromDate, toDate);

    if (rows.length > 0) {
      var categoryGroup = groupBy(rows, (obj) => obj['categoryName']);
      
      double amt;
      categoryGroup.forEach((k, v) {
        amt = 0;
        v.forEach((val) {
          amt += double.parse(val["totalAmount"].toString());
        });

        trackDataMap.putIfAbsent(k, () => amt);
      });
    }

    chartEvent.add(OnChartExpenseDataLoadEvent(trackDataMap));

    return trackDataMap;
  }

  void dispose() {
    _chartStateController.close();
    _chartEventController.close();
  }
}

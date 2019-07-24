import 'dart:async';
import 'package:expensetracker/repository/track_repository.dart';
import 'package:expensetracker/bloc/track_event.dart';
import 'package:expensetracker/model/track_model.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/model/search_model.dart';

class  TrackBloc {

  TrackBloc() {
      _trackEventController.stream.listen(_mapEventToState);
       _trackDetailsEventController.stream.listen(_mapTrackDetailsEventToState);
       _trackTAmountEventController.stream.listen(_mapTrackTAmountEventToState);
  }

  List<TrackModel> trackModelList = new List<TrackModel>();
  
  final _trackStateController = StreamController<List<TrackModel>>();

  StreamSink<List<TrackModel>> get _inTrack => _trackStateController.sink;

  Stream<List<TrackModel>> get outTrack => _trackStateController.stream;

  final _trackEventController = StreamController<TrackEvent>();

  Sink<TrackEvent> get trackEvent => _trackEventController.sink;

  void _mapEventToState(TrackEvent event){
      if(event is OnAddTrackEvent){
        trackModelList.add(event.trackModel);
      }
      if(event is OnUpdateTrackEvent){
        trackModelList[event.idx] = event.trackModel;
      }
      if(event is OnDeleteTrackEvent){
        trackModelList.removeAt(event.idx);
      }
      _inTrack.add(trackModelList);
  }

  List<TrackDetailsModel> trackDetailsModelList = new List<TrackDetailsModel>();
  
  final _trackDetailsStateController = StreamController<List<TrackDetailsModel>>();

  StreamSink<List<TrackDetailsModel>> get _inTrackDetails => _trackDetailsStateController.sink;

  Stream<List<TrackDetailsModel>> get outTrackDetails => _trackDetailsStateController.stream;

  final _trackDetailsEventController = StreamController<TrackEvent>();

  Sink<TrackEvent> get trackDetailsEvent => _trackDetailsEventController.sink;

  void _mapTrackDetailsEventToState(TrackEvent event){
      if(event is OnAddTrackDetailsEvent){
        trackDetailsModelList.add(event.trackDetailsModel);
      }
      if(event is OnUpdateTrackDetailsEvent){
        trackDetailsModelList[event.idx] = event.trackDetailsModel;
      }
      if(event is OnDeleteTrackDetailsEvent){
        trackDetailsModelList.removeAt(event.idx);
      }
      _inTrackDetails.add(trackDetailsModelList);
  }


  int trackTotalAmount = 0;
  
  final _trackTAmountStateController = StreamController<int>();

  StreamSink<int> get _inTrackTAmountDetails => _trackTAmountStateController.sink;

  Stream<int> get outTrackTAmount => _trackTAmountStateController.stream;

  final _trackTAmountEventController = StreamController<TrackEvent>();

  Sink<TrackEvent> get trackTAmountEvent => _trackTAmountEventController.sink;

  void _mapTrackTAmountEventToState(TrackEvent event){
      if(event is OnTrackUpdateAmountEvent){
        trackTotalAmount = event.amount;
      }
      _inTrackTAmountDetails.add(trackTotalAmount);
  }

  void insertTrack(TrackModel trackModel) async {
    await trackRepository.insertTrack(trackModel.toJson());
    //trackEvent.add(OnAddTrackEvent(trackModel));
  }

  void updateTrack(int idx, TrackModel trackModel) async {
    await trackRepository.updateTrack(trackModel.toJson());
    //trackEvent.add(OnUpdateTrackEvent(idx, trackModel));
  }

  void deleteTrack(int idx, int trackId) async {
    await trackRepository.deleteTrack(trackId);
    //trackEvent.add(OnDeleteTrackEvent(idx));
  }

  Future getTrackList(CategoryType categoryType) async {
    final rows = await trackRepository.getTrackList(categoryType);
    trackModelList.clear();
    if(rows.length == 0){
      trackEvent.add(OnAddTrackEvent(new TrackModel()));
    }
    rows.forEach((row) => trackEvent.add(OnAddTrackEvent(TrackModel.fromJson(row))));
    return rows;
  }

  Future getTrackDetailsList(CategoryType categoryType, String fromDate, String toDate) async {
    final rows = await trackRepository.getTrackWithCategoryList(categoryType, fromDate, toDate);
    trackDetailsModelList.clear();
    if(rows.length == 0) {
      trackDetailsEvent.add(OnAddTrackDetailsEvent(new TrackDetailsModel()));
    }
    rows.forEach((row) => trackDetailsEvent.add(OnAddTrackDetailsEvent(TrackDetailsModel.fromJson(row))));
    return rows;
  }

  Future getCategoryBasedTrackAmount(CategoryType categoryType, String fromDate, String toDate) async {
    final rows = await trackRepository.getCategoryBasedTrackAmount(categoryType, fromDate, toDate);
    return rows;
  }

  Future<int> getTrackTotalAmt(CategoryType categoryType, String fromDate, String toDate) async {
    final totalAmount = await trackRepository.getTrackTotalAmt(categoryType, fromDate, toDate);
    int amt = 0;
    if(totalAmount[0]["TotalAmount"] != null) {
      amt = int.tryParse(totalAmount[0]["TotalAmount"].toString());
    }
    trackTAmountEvent.add(OnTrackUpdateAmountEvent(amt));
    return amt;
  }

  Future<int> getTotalAmt(CategoryType categoryType) async {
    final totalAmount = await trackRepository.totalAmount(categoryType);
    int amt = 0;
    if(totalAmount[0]["TotalAmount"] != null) {
      amt = int.tryParse(totalAmount[0]["TotalAmount"].toString());
    }
    trackTAmountEvent.add(OnTrackUpdateAmountEvent(amt));
    return amt;
  }

  Future<int> totalSavings() async {
    final totalIncome = await trackRepository.totalAmount(CategoryType.income);
    final totalExpense = await trackRepository.totalAmount(CategoryType.expense);
    int amt = 0;
    int income = 0;
    int expense = 0;
    if(totalIncome[0]["TotalAmount"] != null) {
      income = int.tryParse(totalIncome[0]["TotalAmount"].toString());
    }
    if(totalExpense[0]["TotalAmount"] != null) {
      expense = int.tryParse(totalExpense[0]["TotalAmount"].toString());
    }
    amt = income - expense;
    trackTAmountEvent.add(OnTrackUpdateAmountEvent(amt));
    return amt;
  }

  Future<List<Map<String, dynamic>>> getbudgetedMonths() async {
    return await trackRepository.getbudgetedMonths();
  }

  Future<int> copyBudget(String fromYear, String fromMonth, String toYear, String toMonth, String newDate) async {
    return await trackRepository.copyBudget(fromYear, fromMonth, toYear, toMonth, newDate);
  }

  Future<List<Map<String, dynamic>>> getMonthWiseAmount(CategoryType categoryType) async {
    return await trackRepository.getMonthWiseAmount(categoryType);
  }

  Future<List<Map<String, dynamic>>> getTrackData(SearchModel searchModel) async {
    return await trackRepository.getTrackData(searchModel);
  }

  Future<int> getTrackDataTotalAmount(SearchModel searchModel) async {
    final totalAmount = await trackRepository.getTrackDataTotalAmount(searchModel);
    int amt = 0;
    if(totalAmount[0]["TotalAmount"] != null) {
      amt = int.tryParse(totalAmount[0]["TotalAmount"].toString());
    }
    trackTAmountEvent.add(OnTrackUpdateAmountEvent(amt));
    return amt;
  }


  void dispose() {
    _trackStateController.close();
    _trackEventController.close();
    _trackDetailsStateController.close();
    _trackDetailsEventController.close();
    _trackTAmountStateController.close();
    _trackTAmountEventController.close();
  }
  
}
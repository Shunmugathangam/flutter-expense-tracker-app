import 'dart:async';

import 'package:expensetracker/repository/track_repository.dart';
import 'package:expensetracker/bloc/track_event.dart';
import 'package:expensetracker/model/track_model.dart';
import 'package:expensetracker/model/category_model.dart';

class  TrackBloc {

  TrackBloc() {
      _trackEventController.stream.listen(_mapEventToState);
       _trackDetailsEventController.stream.listen(_mapTrackDetailsEventToState);
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

  // sqflite

  void insertTrack(TrackModel trackModel) async {
    await trackRepository.insertTrack(trackModel.toJson());
  }

  void updateTrack(int idx, TrackModel trackModel) async {
    await trackRepository.updateTrack(trackModel.toJson());
  }

  void deleteTrack(int idx, int trackId) async {
    await trackRepository.deleteTrack(trackId);
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

  Future getTrackDetailsList(CategoryType categoryType) async {
    final rows = await trackRepository.getTrackWithCategoryList(categoryType);
    trackDetailsModelList.clear();
    if(rows.length == 0){
      trackDetailsEvent.add(OnAddTrackDetailsEvent(new TrackDetailsModel()));
    }
    rows.forEach((row) => trackDetailsEvent.add(OnAddTrackDetailsEvent(TrackDetailsModel.fromJson(row))));
    return rows;
  }

  void dispose() {
    _trackStateController.close();
    _trackEventController.close();
    _trackDetailsStateController.close();
    _trackDetailsEventController.close();
  }
  
}
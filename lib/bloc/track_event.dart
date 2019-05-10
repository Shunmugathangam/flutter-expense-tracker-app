import 'package:expensetracker/model/track_model.dart';

abstract class TrackEvent { }

class OnAddTrackEvent extends TrackEvent {
  final TrackModel trackModel;
  OnAddTrackEvent(this.trackModel);
}

class OnUpdateTrackEvent extends TrackEvent {
  final TrackModel trackModel;
  final int idx;
  OnUpdateTrackEvent(this.idx, this.trackModel);
}

class OnDeleteTrackEvent extends TrackEvent {
  final int idx;
  OnDeleteTrackEvent(this.idx);
}

class OnAddTrackDetailsEvent extends TrackEvent {
  final TrackDetailsModel trackDetailsModel;
  OnAddTrackDetailsEvent(this.trackDetailsModel);
}

class OnUpdateTrackDetailsEvent extends TrackEvent {
  final TrackDetailsModel trackDetailsModel;
  final int idx;
  OnUpdateTrackDetailsEvent(this.idx, this.trackDetailsModel);
}

class OnDeleteTrackDetailsEvent extends TrackEvent {
  final int idx;
  OnDeleteTrackDetailsEvent(this.idx);
}

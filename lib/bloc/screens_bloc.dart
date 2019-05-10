import 'package:rxdart/rxdart.dart';
import 'package:expensetracker/model/screen_model.dart';
import 'package:expensetracker/repository/local_data.dart';

class  ScreensBloc {
  final _screens = LocalDataRepository();
  final _screensFetcher = PublishSubject<List<ScreensModel>>();

  Observable<List<ScreensModel>> get getscreen => _screensFetcher.stream;

    fetchScreens(ScreenType screenType) async {
      List<ScreensModel> screensModel = await _screens.getScreenByType(screenType);
      _screensFetcher.sink.add(screensModel);
    }

    fetchAllScreens() async {
      List<ScreensModel> screensModel = await _screens.getAllScreens();
      _screensFetcher.sink.add(screensModel);
    }

    dispose() async {
      await _screensFetcher.drain();
       _screensFetcher.close();
    }
}

final screensbloc = ScreensBloc();
import 'package:rxdart/rxdart.dart';
import 'package:expensetracker/model/dropdown_model.dart';
import 'package:expensetracker/repository/local_data.dart';

class  CategoryTypesBloc {
  final _categorytypes = LocalDataRepository();
  final _categoryTypesFetcher = PublishSubject<List<DropdownModel>>();

  Observable<List<DropdownModel>> get getCategoryTypes => _categoryTypesFetcher.stream;

    fetchAllCategoryTypes() async {
      List<DropdownModel> categoryTypeModel = await _categorytypes.getAllCategoryTypes();
      _categoryTypesFetcher.sink.add(categoryTypeModel);
    }

    dispose() async {
      await _categoryTypesFetcher.drain();
       _categoryTypesFetcher.close();
    }
}

final categorytypesbloc = CategoryTypesBloc();
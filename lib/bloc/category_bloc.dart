import 'dart:async';
import 'package:expensetracker/repository/category_repository.dart';
import 'package:expensetracker/bloc/category_event.dart';
import 'package:expensetracker/model/category_model.dart';

class  CategoryBloc {

  CategoryBloc() {
      _categoryEventController.stream.listen(_mapEventToState);
  }

  List<CategoryModel> categoryModelList = new List<CategoryModel>();
  
  final _categoryStateController = StreamController<List<CategoryModel>>();

  StreamSink<List<CategoryModel>> get _inCategoryValue => _categoryStateController.sink;

  Stream<List<CategoryModel>> get categoryValue => _categoryStateController.stream;

  final _categoryEventController = StreamController<CategoryEvent>();

  Sink<CategoryEvent> get categoryEvent => _categoryEventController.sink;

  void _mapEventToState(CategoryEvent event){
      if(event is OnAddCategoryEvent){
        categoryModelList.add(event.categoryModel);
      }
      if(event is OnUpdateCategoryEvent){
        categoryModelList[event.idx] = event.categoryModel;
      }
      if(event is OnDeleteCategoryEvent){
        categoryModelList.removeAt(event.idx);
      }
      _inCategoryValue.add(categoryModelList);
  }

  void insertCategory(CategoryModel categoryModel) async {
    await db.insertCategory(categoryModel.toJson());
    categoryEvent.add(OnAddCategoryEvent(categoryModel));
  }

  void updateCategory(int idx, CategoryModel categoryModel) async {
    await db.updateCategory(categoryModel.toJson());
    categoryEvent.add(OnUpdateCategoryEvent(idx, categoryModel));
  }

  void softDeleteCategory(int idx, CategoryModel categoryModel) async {
    await db.updateCategory(categoryModel.toJson());
    categoryEvent.add(OnDeleteCategoryEvent(idx));
  }

  void deleteCategory(int idx, int categoryId) async {
    await db.deleteCategory(categoryId);
    categoryEvent.add(OnDeleteCategoryEvent(idx));
  }

  Future getActiveCategories() async {
    final rows = await db.getActiveCategories();
    rows.forEach((row) => categoryEvent.add(OnAddCategoryEvent(CategoryModel.fromJson(row))));
    return rows;
  }

  Future getActiveCategoriesByType(CategoryType categoryType) async{
      final rows = await db.getActiveCategoriesByType(categoryType);
      rows.forEach((row) => categoryEvent.add(OnAddCategoryEvent(CategoryModel.fromJson(row))));
      return rows;
  }

  Future getCategoriesByType(CategoryType categoryType) async{
      final rows = await db.getActiveCategoriesByType(categoryType);
      if(categoryModelList.length > 0)
        categoryModelList.clear();
      rows.forEach((row) => categoryEvent.add(OnAddCategoryEvent(CategoryModel.fromJson(row))));
      return rows;
  }


  Future<List<CategoryModel>> getActiveCategoryList() async {
    final rows = await db.getActiveCategories();
    List<CategoryModel> lstCategory = new List<CategoryModel>();
    rows.forEach((row) {
       lstCategory.add(CategoryModel.fromJson(row));
    });
    return lstCategory;
  }

  Future<List<CategoryModel>> getActiveCategoryListByType(CategoryType categoryType) async {
    final rows = await db.getActiveCategoriesByType(categoryType);
    List<CategoryModel> lstCategory = new List<CategoryModel>();
    rows.forEach((row) {
       lstCategory.add(CategoryModel.fromJson(row));
    });
    return lstCategory;
  }

  void dispose() {
    _categoryStateController.close();
    _categoryEventController.close();
  }
  
}
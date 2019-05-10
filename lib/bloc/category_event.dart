import 'package:expensetracker/model/category_model.dart';

abstract class CategoryEvent { }

class OnAddCategoryEvent extends CategoryEvent {
  final CategoryModel categoryModel;
  OnAddCategoryEvent(this.categoryModel);
}

class OnUpdateCategoryEvent extends CategoryEvent {
  final CategoryModel categoryModel;
  final int idx;
  OnUpdateCategoryEvent(this.idx, this.categoryModel);
}

class OnDeleteCategoryEvent extends CategoryEvent {
  final int idx;
  OnDeleteCategoryEvent(this.idx);
}

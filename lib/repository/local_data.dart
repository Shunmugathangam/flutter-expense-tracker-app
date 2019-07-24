import 'package:expensetracker/model/dropdown_model.dart';
import 'package:expensetracker/model/screen_model.dart';
import 'package:expensetracker/model/category_model.dart';

class LocalDataRepository {

  getAllCategoryTypes() {
      return [
        DropdownModel(key: CategoryType.none, value: "--Select Type--"),
        DropdownModel(key: CategoryType.income, value: "Income"),
        DropdownModel(key: CategoryType.expense, value: "Expense"),
        DropdownModel(key: CategoryType.budget, value: "Budget"),
      ];
  }

  getScreenByType(ScreenType screenType) {
      List<ScreensModel> allScreen = getAllScreens();
      return allScreen.where((i) => i.screenType == screenType).toList();
  }


  getAllScreens() {

      List<ScreensModel> allScreen = [
        ScreensModel(id: 1, screenName: "Incomes", screenDesc: "Track All Incomes", screenType: ScreenType.actionbar_tabbar, order: 2),
        ScreensModel(id: 2, screenName: "Expenses", screenDesc: "Track All Expenses", screenType: ScreenType.actionbar_tabbar, order: 1),
        ScreensModel(id: 3, screenName: "Add Category", screenDesc: "Add Category", screenType: ScreenType.actionbar_popupmenu, order: 1),
        ScreensModel(id: 4, screenName: "View Chart", screenDesc: "View Chart", screenType: ScreenType.actionbar_popupmenu, order: 2),
      ];

      return allScreen;
  }
  
}
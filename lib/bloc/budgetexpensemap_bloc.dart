import 'dart:async';
import 'package:expensetracker/repository/budgetexpensemap_repository.dart';
import 'package:expensetracker/model/budgetexpensemap_model.dart';

class  BudgetExpenseMapBloc {

  List<BudgetExpenseMapModel> budgetExpenseMapList = new List<BudgetExpenseMapModel>();

  void insert(BudgetExpenseMapModel budgetExpenseMapModel) async {
    await budgetExpensemapRepository.insert(budgetExpenseMapModel.toJson());
  }

  Future<List<BudgetExpenseMapModel>> selectAll() async {
    final rows = await budgetExpensemapRepository.queryAllRows();
    List<BudgetExpenseMapModel> lstBudgetExpenseMap = new List<BudgetExpenseMapModel>();
    rows.forEach((row) {
       lstBudgetExpenseMap.add(BudgetExpenseMapModel.fromJson(row));
    });
    return lstBudgetExpenseMap;
  }

  Future<List<BudgetExpenseMapModel>> select(int budgetCategoryId, int expenseCategoryId) async {
    final rows = await budgetExpensemapRepository.queryRow(budgetCategoryId, expenseCategoryId);
    List<BudgetExpenseMapModel> lstBudgetExpenseMap = new List<BudgetExpenseMapModel>();
    rows.forEach((row) {
       lstBudgetExpenseMap.add(BudgetExpenseMapModel.fromJson(row));
    });
    return lstBudgetExpenseMap;
  }

  Future<List<BudgetExpenseCategoryNameModel>> selectBudgetExpenseMap() async {
    final rows = await budgetExpensemapRepository.selectBudgetExpenseMap();
    List<BudgetExpenseCategoryNameModel> lstBudgetExpenseCategoryName = new List<BudgetExpenseCategoryNameModel>();
    rows.forEach((row) {
       lstBudgetExpenseCategoryName.add(BudgetExpenseCategoryNameModel.fromJson(row));
    });
    return lstBudgetExpenseCategoryName;
  }

  Future<List<BudgetExpenseCategoryIdNameModel>> selectBudgetExpenseCategoryNameAndId() async {
    final rows = await budgetExpensemapRepository.selectBudgetExpenseMap();
    List<BudgetExpenseCategoryIdNameModel> lstBudgetExpenseCategoryName = new List<BudgetExpenseCategoryIdNameModel>();
    rows.forEach((row) {
       lstBudgetExpenseCategoryName.add(BudgetExpenseCategoryIdNameModel.fromJson(row));
    });
    return lstBudgetExpenseCategoryName;
  }

  Future<List<CategoryTotalAmoutModel>> lstCategoryTotalAmout(String fromDate, String toDate) async {
    final rows = await budgetExpensemapRepository.selectCategoryBasedTrackTotalAmount(fromDate, toDate);
    List<CategoryTotalAmoutModel> lstCategoryTotalAmoutModel = new List<CategoryTotalAmoutModel>();
    rows.forEach((row) {
       lstCategoryTotalAmoutModel.add(CategoryTotalAmoutModel.fromJson(row));
    });
    return lstCategoryTotalAmoutModel;
  }

  Future<int> delete(int budgetExpenseMapId) async {
    return await budgetExpensemapRepository.delete(budgetExpenseMapId);
  }
  
}
import 'package:sqflite/sqflite.dart';
import 'package:expensetracker/repository/database.dart';

class BudgetExpensemapRepository {

  final dbHelper = DatabaseHelper.instance;

  static final tblBudgetExpenseMap = 'budgetExpenseMap';

  static final colBudgetExpenseMapId = 'budgetExpenseMapId';
  static final colBudgetCategoryId = 'budgetCategoryId';
  static final colExpenseCategoryId = 'expenseCategoryId';

  static final tblTrackCategories = 'trackcategories';

  static final colCategoryId = 'categoryId';
  static final colIsActive = 'isActive';
  static final colCategoryType = 'categoryType';
  static final colCategoryName = 'categoryName';
  static final colCategoryDesc = 'categoryDesc';

  static final tblTrack = 'track';

  static final colTrackId = 'trackId';
  static final colTrackDate = 'trackDate';
  static final colDescription = 'description';
  static final colAmount = 'amount';
  static final colOther = 'other';
  static final colCategoryActive = 'isActive';
  static final colColor = 'color';

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await dbHelper.database;
    return await db.query(tblBudgetExpenseMap);
  }

  Future<List<Map<String, dynamic>>> queryRow(int budgetCategoryId, int expenseCategoryId) async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT * FROM $tblBudgetExpenseMap WHERE $colBudgetCategoryId = $budgetCategoryId");
  }

  Future<List<Map<String, dynamic>>> selectBudgetExpenseMap() async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT M.$colBudgetExpenseMapId AS budgetExpenseMapId, B.$colCategoryId AS budgetCategoryId, B.$colCategoryName AS budgetCategoryName, E.$colCategoryId AS expenseCategoryId, E.$colCategoryName AS expenseCategoryName FROM $tblBudgetExpenseMap M LEFT OUTER JOIN $tblTrackCategories B ON M.$colBudgetCategoryId = B.$colCategoryId  LEFT OUTER JOIN $tblTrackCategories E ON M.$colExpenseCategoryId = E.$colCategoryId");
  }

  Future<List<Map<String, dynamic>>> selectCategoryBasedTrackTotalAmount(String fromDate, String toDate) async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT $colCategoryId, SUM($colAmount) AS totalamount FROM $tblTrack WHERE $colTrackDate BETWEEN '" + fromDate +" 00:00:00.000' AND '" + toDate + " 00:00:00.000'" + " GROUP BY $colCategoryId");
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await dbHelper.database;
    return await db.insert(tblBudgetExpenseMap, row);
  }

  Future<int> update(Map<String, dynamic> row) async {
    Database db = await dbHelper.database;
    int id = row[colBudgetExpenseMapId];
    return await db.update(tblBudgetExpenseMap, row, where: '$colBudgetExpenseMapId = ?', whereArgs: [id]);
  }

  Future<int> delete(int budgetExpenseMapId) async {
    Database db = await dbHelper.database;
    return await db.delete(tblBudgetExpenseMap, where: '$colBudgetExpenseMapId = ?', whereArgs: [budgetExpenseMapId]);
  }

}

BudgetExpensemapRepository budgetExpensemapRepository = BudgetExpensemapRepository();
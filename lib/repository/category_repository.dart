import 'package:expensetracker/model/category_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expensetracker/repository/database.dart';

class CategoryRepository {

  final dbHelper = DatabaseHelper.instance;

  static final tblTrackCategories = 'trackcategories';
  static final colCategoryId = 'categoryId';
  static final colIsActive = 'isActive';
  static final colCategoryType = 'categoryType';

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await dbHelper.database;
    return await db.query(tblTrackCategories);
  }

  Future<List<Map<String, dynamic>>> getActiveCategories() async {
    Database db = await dbHelper.database;
    return await db.query(tblTrackCategories, where: '$colIsActive = ?', whereArgs: [1]);
  }

  Future<List<Map<String, dynamic>>> getActiveCategoriesByType(CategoryType categoryType) async {
    Database db = await dbHelper.database;
    return await db.query(tblTrackCategories, where: '$colIsActive = ? AND $colCategoryType = ?', whereArgs: [1, categoryType.index]);
  }

  Future<int> insertCategory(Map<String, dynamic> row) async {
    Database db = await dbHelper.database;
    return await db.insert(tblTrackCategories, row);
  }

  Future<int> updateCategory(Map<String, dynamic> row) async {
    Database db = await dbHelper.database;
    int id = row[colCategoryId];
    return await db.update(tblTrackCategories, row, where: '$colCategoryId = ?', whereArgs: [id]);
  }

  Future<int> deleteCategory(int categoryId) async {
    Database db = await dbHelper.database;
    return await db.delete(tblTrackCategories, where: '$colCategoryId = ?', whereArgs: [categoryId]);
  }

}

CategoryRepository db = CategoryRepository();
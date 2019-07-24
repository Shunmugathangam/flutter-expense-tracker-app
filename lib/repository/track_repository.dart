import 'package:expensetracker/model/category_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expensetracker/repository/database.dart';
import 'package:expensetracker/model/search_model.dart';

class TrackRepository {

  final dbHelper = DatabaseHelper.instance;

  
  static final tblTrackCategories = 'trackcategories';
  static final tblTrack = 'track';

  static final colTrackId = 'trackId';
  static final colTrackDate = 'trackDate';
  static final colCategoryId = 'categoryId';
  static final colCategoryType = 'categoryType';
  static final colDescription = 'description';
  static final colAmount = 'amount';
  static final colOther = 'other';
  static final colCategoryName = 'categoryName';
  static final colCategoryDesc = 'categoryDesc';
  static final colCategoryActive = 'isActive';
  static final colColor = 'color';

  Future<List<Map<String, dynamic>>> getTrackList(CategoryType categoryType) async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT T.$colTrackId, T.$colCategoryId, T.$colDescription, T.$colAmount, T.$colTrackDate, T.$colOther  FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString());
  }

  Future<List<Map<String, dynamic>>> getTrackWithCategoryList(CategoryType categoryType, String fromDate, String toDate) async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT T.$colTrackId, T.$colCategoryId, T.$colDescription, T.$colAmount, T.$colTrackDate, T.$colOther, C.$colCategoryName, C.$colCategoryDesc, C.$colCategoryType, C.$colCategoryActive, C.$colColor  FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString() + " AND T.$colTrackDate BETWEEN '" + fromDate +" 00:00:00.000' AND '" + toDate + " 00:00:00.000' ORDER BY T.$colTrackDate DESC");
  }

  Future<List<Map<String, dynamic>>> getTrackTotalAmt(CategoryType categoryType, String fromDate, String toDate) async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT SUM(T.$colAmount) AS TotalAmount FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString() + " AND T.$colTrackDate BETWEEN '" + fromDate +" 00:00:00.000' AND '" + toDate + " 00:00:00.000'");
  }

  Future<List<Map<String, dynamic>>> getCategoryBasedTrackAmount(CategoryType categoryType, String fromDate, String toDate) async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT C.$colCategoryName, T.$colAmount AS totalAmount FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString() + " AND T.$colTrackDate BETWEEN '" + fromDate +" 00:00:00.000' AND '" + toDate + " 00:00:00.000'");
  }

  Future<int> insertTrack(Map<String, dynamic> row) async {
    Database db = await dbHelper.database;
    return await db.insert(tblTrack, row);
  }

  Future<int> updateTrack(Map<String, dynamic> row) async {
    Database db = await dbHelper.database;
    int id = row[colTrackId];
    return await db.update(tblTrack, row, where: '$colTrackId = ?', whereArgs: [id]);
  }

  Future<int> deleteTrack(int trackId) async {
    Database db = await dbHelper.database;
    return await db.delete(tblTrack, where: '$colTrackId = ?', whereArgs: [trackId]);
  }

  Future<List<Map<String, dynamic>>> totalAmount(CategoryType categoryType) async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT SUM(T.$colAmount) AS TotalAmount FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString());
  }

  Future<List<Map<String, dynamic>>> getbudgetedMonths() async {
    Database db = await dbHelper.database;
    CategoryType categoryType = CategoryType.budget;
    return await db.rawQuery("SELECT strftime('%Y',T.$colTrackDate) as Year, strftime('%m',T.$colTrackDate) AS Month FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString() + " GROUP BY strftime('%Y',T.$colTrackDate), strftime('%m',T.$colTrackDate)");
  }

  Future<List<Map<String, dynamic>>> getMonthWiseAmount(CategoryType categoryType) async {
    Database db = await dbHelper.database;
    int ctVal = categoryType.index;
    return await db.rawQuery("SELECT strftime('%Y',T.$colTrackDate) as Year, strftime('%m',T.$colTrackDate) AS Month, '$ctVal' AS CategoryType, SUM(T.$colAmount) AS TotalAmount FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString() + " GROUP BY strftime('%Y',T.$colTrackDate), strftime('%m',T.$colTrackDate) ORDER BY T.$colTrackDate DESC");
  }

  Future<int> copyBudget(String fromYear, String fromMonth, String toYear, String toMonth, String newDate) async {
    Database db = await dbHelper.database;
    CategoryType categoryType = CategoryType.budget;
    var data =  await db.rawQuery("SELECT T.$colCategoryId, T.$colDescription, T.$colAmount, '$newDate', T.$colOther FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString() + " AND strftime('%Y',T.$colTrackDate) = '" + toYear + "' AND strftime('%m',T.$colTrackDate) = '" + toMonth + "'");
    if(data.length > 0) {
      return 0; 
    }
    else {
      await db.rawQuery("INSERT INTO $tblTrack ($colCategoryId, $colDescription, $colAmount, $colTrackDate, $colOther) SELECT T.$colCategoryId, T.$colDescription, T.$colAmount, '$newDate', T.$colOther FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString() + " AND strftime('%Y',T.$colTrackDate) = '" + fromYear + "' AND strftime('%m',T.$colTrackDate) = '" + fromMonth + "'");
      return 1; 
    }
  }

  Future<List<Map<String, dynamic>>> getTrackData(SearchModel searchModel) async {
    Database db = await dbHelper.database;
    if(searchModel.categoryIds != null && searchModel.categoryIds.length > 0){
        String lstCategory = searchModel.categoryIds.join(', ');
        return await db.rawQuery("SELECT T.$colTrackId, T.$colCategoryId, T.$colDescription, T.$colAmount, T.$colTrackDate, T.$colOther, C.$colCategoryName, C.$colCategoryDesc, C.$colCategoryType, C.$colCategoryActive FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + searchModel.categoryType.index.toString() + " AND T.$colTrackDate BETWEEN '" + searchModel.fromDate.toString() +"' AND '" + searchModel.toDate.toString() + "' AND (T.$colDescription LIKE '%${searchModel.description}%' AND T.$colCategoryId IN ($lstCategory)) ORDER BY T.$colTrackDate DESC");
    }
    else {
        return await db.rawQuery("SELECT T.$colTrackId, T.$colCategoryId, T.$colDescription, T.$colAmount, T.$colTrackDate, T.$colOther, C.$colCategoryName, C.$colCategoryDesc, C.$colCategoryType, C.$colCategoryActive FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + searchModel.categoryType.index.toString() + " AND T.$colTrackDate BETWEEN '" + searchModel.fromDate.toString() +"' AND '" + searchModel.toDate.toString() + "' AND (T.$colDescription LIKE '%${searchModel.description}%') ORDER BY T.$colTrackDate DESC");
    }
  }

  Future<List<Map<String, dynamic>>> getTrackDataTotalAmount(SearchModel searchModel) async {
    Database db = await dbHelper.database;
    if(searchModel.categoryIds != null && searchModel.categoryIds.length > 0){
        String lstCategory = searchModel.categoryIds.join(', ');
        return await db.rawQuery("SELECT SUM(T.$colAmount) AS TotalAmount FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + searchModel.categoryType.index.toString() + " AND T.$colTrackDate BETWEEN '" + searchModel.fromDate.toString() +"' AND '" + searchModel.toDate.toString() + "' AND (T.$colDescription LIKE '%${searchModel.description}%' AND T.$colCategoryId IN ($lstCategory)) ORDER BY T.$colTrackDate DESC");
    }
    else {
        return await db.rawQuery("SELECT SUM(T.$colAmount) AS TotalAmount FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + searchModel.categoryType.index.toString() + " AND T.$colTrackDate BETWEEN '" + searchModel.fromDate.toString() +"' AND '" + searchModel.toDate.toString() + "' AND (T.$colDescription LIKE '%${searchModel.description}%') ORDER BY T.$colTrackDate DESC");
    }
  }

}

TrackRepository trackRepository  = TrackRepository();
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:sqflite/sqflite.dart';
import 'package:expensetracker/repository/database.dart';

class TrackRepository {

  final db = Firestore.instance;

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

  // sqflite

  Future<List<Map<String, dynamic>>> getTrackList(CategoryType categoryType) async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT T.$colTrackId, T.$colCategoryId, T.$colDescription, T.$colAmount, T.$colTrackDate, T.$colOther  FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString());
  }

  Future<List<Map<String, dynamic>>> getTrackWithCategoryList(CategoryType categoryType) async {
    Database db = await dbHelper.database;
    return await db.rawQuery("SELECT T.$colTrackId, T.$colCategoryId, T.$colDescription, T.$colAmount, T.$colTrackDate, T.$colOther, C.$colCategoryName, C.$colCategoryDesc, C.$colCategoryType, C.$colCategoryActive  FROM $tblTrack T INNER JOIN $tblTrackCategories C ON T.$colCategoryId = C.$colCategoryId WHERE C.$colCategoryType = " + categoryType.index.toString());
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

  
}

TrackRepository trackRepository  = TrackRepository();
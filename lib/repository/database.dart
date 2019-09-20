import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  
  static final _databaseName = "trackcoin.db";
  static final _databaseVersion = 2;
  static final colIsDataSyncToCloud = 'isDataSyncToCloud';

  static final tblTrackCategories = 'trackcategories';
  
  static final colCategoryId = 'categoryId';
  static final colCategoryName = 'categoryName';
  static final colCategoryDesc = 'categoryDesc';
  static final colCategoryType = 'categoryType';
  static final colOrder = 'orderBy';
  static final colIsActive = 'isActive';
  static final colColor = 'color';
  
  static final tblTrack = 'track';
  
  static final colTrackId = 'trackId';
  static final colTracCategoryId = 'categoryId';
  static final colTrackDescription = 'description';
  static final colAmount = 'amount';
  static final colTrackDate = 'trackDate';
  static final colOther = 'other';

  static final tblBudgetExpenseMap = 'budgetExpenseMap';

  static final colBudgetExpenseMapId = 'budgetExpenseMapId';
  static final colBudgetCategoryId = 'budgetCategoryId';
  static final colExpenseCategoryId = 'expenseCategoryId';


  // make this a singleton class
  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  // only have a single app-wide reference to the database
  static Database _database;
  Future<Database> get database async {
    if (_database != null) return _database;
    
    // lazily instantiate the db the first time it is accessed
    _database = await _initDatabase();
    return _database;
  }
  
  // this opens the database (and creates it if it doesn't exist)
  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion,
        onCreate: _onCreate,
        onUpgrade: _onUpgrade);
  }

  // SQL code to create the database table
  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $tblTrackCategories (
            $colCategoryId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colCategoryName TEXT NOT NULL,
            $colCategoryDesc TEXT NOT NULL,
            $colCategoryType INTEGER NOT NULL,
            $colOrder INTEGER NULL,
            $colIsActive INTEGER NULL,
            $colColor INTEGER NULL,
            $colIsDataSyncToCloud INTEGER NULL
          )
          ''');

    await db.execute('''
          CREATE TABLE $tblTrack (
            $colTrackId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colTracCategoryId INTEGER NOT NULL,
            $colTrackDescription TEXT NOT NULL,
            $colAmount INTEGER NOT NULL,
            $colTrackDate TEXT NOT NULL,
            $colOther TEXT NULL,
            $colIsDataSyncToCloud INTEGER NULL
          )
          ''');


      await db.execute('''
          CREATE TABLE $tblBudgetExpenseMap (
            $colBudgetExpenseMapId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colBudgetCategoryId INTEGER NOT NULL,
            $colExpenseCategoryId INTEGER NOT NULL
          )
          ''');
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {

      if(newVersion > 1) {
        await db.execute('''
          CREATE TABLE IF NOT EXISTS $tblBudgetExpenseMap (
            $colBudgetExpenseMapId INTEGER PRIMARY KEY AUTOINCREMENT,
            $colBudgetCategoryId INTEGER NOT NULL,
            $colExpenseCategoryId INTEGER NOT NULL
          )
          ''');
      }
  }

}
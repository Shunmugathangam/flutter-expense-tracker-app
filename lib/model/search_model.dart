import 'package:expensetracker/model/category_model.dart';

class  SearchModel {
  
  DateTime fromDate;
  DateTime toDate;
  String description;
  CategoryType categoryType;
  List<dynamic> categoryIds;
  
  SearchModel({this.fromDate, this.toDate, this.description, this.categoryType, this.categoryIds});

  SearchModel.fromJson(Map json)
      : fromDate = json['fromDate'],
        toDate = json['toDate'],
        description = json['description'],
        categoryIds = json['categoryIds'];

  Map<String, dynamic> toJson() =>
    {
      'fromDate': fromDate,
      'toDate': toDate,
      'description': description,
      'categoryIds': categoryIds
    };
}

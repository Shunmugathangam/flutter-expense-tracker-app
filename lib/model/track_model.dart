class  TrackModel {
  int trackId;
  int categoryId;
  String description;
  int amount;
  String trackDate;
  String other;
  
  TrackModel({this.trackId, this.categoryId, this.description, this.amount, this.trackDate, this.other});

  TrackModel.fromJson(Map json)
      : trackId = json['trackId'],
        categoryId = json['categoryId'],
        description = json['description'],
        amount = json['amount'],
        trackDate = json['trackDate'],
        other = json['other'];

  Map<String, dynamic> toJson() =>
    {
      'trackId': trackId,
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'trackDate': trackDate.toString(),
      'other': other,
    };
}


class TrackDetailsModel {

  int trackId;
  int categoryId;
  String description;
  int amount;
  String trackDate;
  String other;
  String categoryName;
  String categoryDesc;
  int categoryType;
  int isCategoryActive;
  int color;

  TrackDetailsModel({this.trackId, this.categoryId, this.categoryName, this.categoryDesc, this.categoryType, this.isCategoryActive, this.description, this.amount, this.trackDate, this.other, this.color});

  TrackDetailsModel.fromJson(Map json)
      : trackId = json['trackId'],
        categoryId = json['categoryId'],
        description = json['description'],
        amount = json['amount'],
        trackDate = json['trackDate'],
        other = json['other'],
        categoryName = json['categoryName'],
        categoryDesc = json['categoryDesc'],
        categoryType = json['categoryType'],
        isCategoryActive = json['isActive'],
        color = json['color'];

  Map<String, dynamic> toJson() =>
    {
      'trackId': trackId,
      'categoryId': categoryId,
      'description': description,
      'amount': amount,
      'trackDate': trackDate.toString(),
      'other': other,
      'categoryName': categoryName,
      'categoryDesc': categoryDesc,
      'categoryType': categoryType,
      'isActive': isCategoryActive
    };

}


class  MonthWiseTotalAmountModel {
  int year;
  int month;
  int categoryType;
  int totalAmount;
  // String categoryTypeName;
  // int incomeAmount;
  // int expenseAmount;
  // int budgetAmount;
  
  MonthWiseTotalAmountModel({this.year, this.month, this.categoryType, this.totalAmount});

  MonthWiseTotalAmountModel.fromJson(Map json)
      : year = json['Year'],
        month = json['Month'],
        categoryType = json['CategoryType'],
        totalAmount = json['TotalAmount'];

  Map<String, dynamic> toJson() =>
    {
      'Year': year,
      'Month': month,
      'TotalAmount': totalAmount
    };
}

class  CategoryBasedAmountModel {
  String categoryName;
  int totalAmount;
  CategoryBasedAmountModel({this.categoryName, this.totalAmount});
}

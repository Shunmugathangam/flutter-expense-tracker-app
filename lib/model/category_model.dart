class  CategoryModel {
  int categoryId;
  String categoryName;
  String categoryDesc;
  CategoryType categoryType;
  int orderBy;
  int isActive = 1;

  CategoryModel({this.categoryId, this.categoryName, this.categoryDesc, this.categoryType, this.orderBy, this.isActive});

  CategoryModel.fromJson(Map json)
      : categoryId = json['categoryId'],
        categoryName = json['categoryName'],
        categoryDesc = json['categoryDesc'],
        categoryType = CategoryType.values[json['categoryType']],
        orderBy = json['orderBy'],
        isActive = json['isActive'];

  Map<String, dynamic> toJson() =>
    {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryDesc': categoryDesc,
      'categoryType': categoryType.index,
      'orderBy': orderBy,
      'isActive': isActive,
    };

    Map<String, dynamic> toUpdateJson() =>
    {
      'categoryName': categoryName,
      'categoryDesc': categoryDesc,
      'categoryType': categoryType.index,
      'orderBy': orderBy,
      'isActive': isActive,
    };
}

enum CategoryType {
   none, 
   income, 
   expense
}
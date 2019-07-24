class  CategoryModel {
  int categoryId;
  String categoryName;
  String categoryDesc;
  CategoryType categoryType;
  int orderBy;
  int isActive = 1;
  int color;

  CategoryModel({this.categoryId, this.categoryName, this.categoryDesc, this.categoryType, this.orderBy, this.isActive, this.color});

  CategoryModel.fromJson(Map json)
      : categoryId = json['categoryId'],
        categoryName = json['categoryName'],
        categoryDesc = json['categoryDesc'],
        categoryType = CategoryType.values[json['categoryType']],
        orderBy = json['orderBy'],
        isActive = json['isActive'],
        color = json['color'];

  Map<String, dynamic> toJson() =>
    {
      'categoryId': categoryId,
      'categoryName': categoryName,
      'categoryDesc': categoryDesc,
      'categoryType': categoryType.index,
      'orderBy': orderBy,
      'isActive': isActive,
      'color': color
    };

    Map<String, dynamic> toUpdateJson() =>
    {
      'categoryName': categoryName,
      'categoryDesc': categoryDesc,
      'categoryType': categoryType.index,
      'orderBy': orderBy,
      'isActive': isActive,
      'color': color
    };
}

enum CategoryType {
   none, 
   income, 
   expense,
   budget
}
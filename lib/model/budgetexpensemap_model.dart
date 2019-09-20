class  BudgetExpenseMapModel {
  int budgetExpenseMapId;
  int budgetCategoryId;
  int expenseCategoryId;
  
  BudgetExpenseMapModel({this.budgetExpenseMapId, this.budgetCategoryId, this.expenseCategoryId});

  BudgetExpenseMapModel.fromJson(Map json)
      : budgetExpenseMapId = json['budgetExpenseMapId'],
        budgetCategoryId = json['budgetCategoryId'],
        expenseCategoryId = json['expenseCategoryId'];

  Map<String, dynamic> toJson() =>
    {
      'budgetExpenseMapId': budgetExpenseMapId,
      'budgetCategoryId': budgetCategoryId,
      'expenseCategoryId': expenseCategoryId
    };
}

class  BudgetExpenseCategoryNameModel {
  int budgetExpenseMapId;
  String budgetCategoryName;
  String expenseCategoryName;
  BudgetExpenseCategoryNameModel({this.budgetExpenseMapId, this.budgetCategoryName, this.expenseCategoryName});

  BudgetExpenseCategoryNameModel.fromJson(Map json)
      : budgetExpenseMapId = json['budgetExpenseMapId'],
        budgetCategoryName = json['budgetCategoryName'],
        expenseCategoryName = json['expenseCategoryName'];
}


class  BudgetExpenseCategoryIdNameModel {
  int budgetExpenseMapId;
  int budgetCategoryId;
  int expenseCategoryId;
  String budgetCategoryName;
  String expenseCategoryName;
  BudgetExpenseCategoryIdNameModel({this.budgetExpenseMapId, this.budgetCategoryId, this.budgetCategoryName, this.expenseCategoryName, this.expenseCategoryId});

  BudgetExpenseCategoryIdNameModel.fromJson(Map json)
      : budgetExpenseMapId = json['budgetExpenseMapId'],
        budgetCategoryId = json['budgetCategoryId'],
        budgetCategoryName = json['budgetCategoryName'],
        expenseCategoryName = json['expenseCategoryName'],
        expenseCategoryId = json['expenseCategoryId'];
}


class  BudgetExpenseAmoutModel {
  String categoryName;
  int expenseAmount;
  int budgetAmount;
  BudgetExpenseAmoutModel({this.categoryName, this.expenseAmount, this.budgetAmount});
}

class  CategoryTotalAmoutModel {
  int categoryId;
  int totalamount;
  CategoryTotalAmoutModel({this.categoryId, this.totalamount});

  CategoryTotalAmoutModel.fromJson(Map json)
      : categoryId = json['categoryId'],
        totalamount = json['totalamount'];

}
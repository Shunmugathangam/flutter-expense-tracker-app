import 'dart:async';
import 'package:flutter/material.dart';
import 'package:expensetracker/model/dropdown_model.dart';
import 'package:expensetracker/bloc/dropdown_bloc.dart';
import 'package:expensetracker/bloc/dropdown_event.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/bloc/category_bloc.dart';
import 'package:expensetracker/sidedrawer.dart';
import 'package:expensetracker/model/budgetexpensemap_model.dart';
import 'package:expensetracker/bloc/budgetexpensemap_bloc.dart';


class BudgetExpenseMapScreen extends StatefulWidget {
  final BuildContext context;

  BudgetExpenseMapScreen(this.context);

  @override
  State<StatefulWidget> createState() => BudgetExpenseMapState();
}

class BudgetExpenseMapState extends State<BudgetExpenseMapScreen> {
  final _ddlBloc = DropdownBloc();
  final _categoryBloc = CategoryBloc();
  final _budgetExpenseMapBloc = BudgetExpenseMapBloc();

  DropdownModel ddlSelectedValue = DropdownModel();

  CategoryModel _selectedBudget;
  CategoryModel _selectedExpense;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    loadBudgetExpenseMap();
  }

  @override
  void dispose() {
    super.dispose();
    _ddlBloc.dispose();
    _categoryBloc.dispose();
  }


  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: AppBar(
          leading: Builder(
            builder: (context) => IconButton(
                  icon: new Icon(Icons.menu),
                  onPressed: () => Scaffold.of(context).openDrawer(),
                ),
          ),
          title: Text('Map Budget With Expense'),
          centerTitle: true,
          actions: <Widget>[
            Icon(Icons.map),
            Padding(padding: EdgeInsets.only(right: 10.0),)
          ],
        ),
      drawer: sideDrawer(context),
      body: Form(
        key: _formKey,
        child: Column(children: <Widget>[
          FutureBuilder(future: _asyncShowActiveCategoriesByType(CategoryType.budget),
                        builder:  (BuildContext context, AsyncSnapshot<List<CategoryModel>> lst) {
                          if(lst.data != null){
                            return Padding( padding: const EdgeInsets.only(top: 10, right: 20, left: 20), child: _categoryField(lst.data, CategoryType.budget),);
                          }
                          else{
                            return Center(child: CircularProgressIndicator(),);
                          }
                          
                      }),
          FutureBuilder(future: _asyncShowActiveCategoriesByType(CategoryType.expense),
                        builder:  (BuildContext context, AsyncSnapshot<List<CategoryModel>> lst) {
                          if(lst.data != null){
                            return Padding( padding: const EdgeInsets.only(top: 10, right: 20, left: 20), child: _categoryField(lst.data, CategoryType.expense),);
                          }
                          else{
                            return Center(child: CircularProgressIndicator(),);
                          }
                          
                      }),
          Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: RaisedButton(
                padding: const EdgeInsets.all(8.0),
                textColor: Theme.of(context).textTheme.display1.color,
                color: Theme.of(context).primaryColor,
                onPressed:() {
                  if(_selectedBudget != null && _selectedExpense != null) {
                    if(_selectedBudget.categoryName == _selectedExpense.categoryName) {
                      mapBudget(BudgetExpenseMapModel(budgetCategoryId: _selectedBudget.categoryId, expenseCategoryId: _selectedExpense.categoryId));
                      loadData();
                    }
                    else{
                      showAlert("Alert", "Budget Name and Expense Name Should Match");
                    } 
                  }
                  else{
                    showAlert("Alert", "Please Select Budget and Expense");
                  }
                },
                child: new Text("Add"),
              ),
            )
          ],
        ),
        Expanded(
          child: ListView(
            children: <Widget>[
               FutureBuilder(future: loadBudgetExpenseMap(),
                        builder:  (BuildContext context, AsyncSnapshot<List<BudgetExpenseCategoryNameModel>> lst) {
                          if(lst.data != null){
                            return buildBudgetExpenseMapTable(lst.data);
                          }
                          else{
                            return Center(child: CircularProgressIndicator(),);
                          }
                          
                      })
            ],
          ),
        )
      ]),
    ));
  }


  _categoryField(List<CategoryModel> lstCategoryModel, CategoryType categoryType) {
    return FormField<int>(
      validator: (value) {
        if (value == null) {
          return "Please Select the Category";
        }
      },
      onSaved: (value) {},
      builder: (
        FormFieldState<int> state,
      ) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            new InputDecorator(
              decoration: const InputDecoration(
                //contentPadding: EdgeInsets.all(0.0),
                labelText: '',
              ),
              child: DropdownButtonHideUnderline(
                child: buildCategoryDropdownList(lstCategoryModel, state, categoryType),
              ),
            ),
            Text(
              state.hasError ? state.errorText : '',
              style:
                  TextStyle(color: Colors.redAccent.shade700, fontSize: 12.0),
            ),
          ],
        );
      },
    );
  }



  Widget buildCategoryDropdownList(List<CategoryModel> lstCategoryModel, FormFieldState state, CategoryType categoryType) {

    return DropdownButton<CategoryModel>(
      //value: categoryType == CategoryType.budget ? _selectedBudget : _selectedExpense,
      isExpanded: true,
      items: lstCategoryModel.map((CategoryModel val) {
        return DropdownMenuItem<CategoryModel>(
          value: val,
          child: Text(val.categoryName),
        );
      }).toList(),
      isDense: true,
      onChanged: (value) {
        DropdownModel ddlV = new DropdownModel(key: value.categoryId, value: value.categoryName);
        _ddlBloc.dropdownEvent.add(OnSelectedEvent(ddlV));
        state.didChange(value.categoryId);
        if(categoryType == CategoryType.budget){
            _selectedBudget = value;
        }
        else{
            _selectedExpense = value;
        }
      },
      //hint: categoryType == CategoryType.budget ? Text("Select Budget") : Text("Select Expense"),
      hint:  categoryType == CategoryType.budget ? Text(_selectedBudget != null ?_selectedBudget.categoryName: "Select Budget") :Text(_selectedExpense != null ?_selectedExpense.categoryName: "Select Expense"),
    );
  }
 

  Widget buildBudgetExpenseMapTable(List<BudgetExpenseCategoryNameModel> snapshot) {
    return DataTable(columns: <DataColumn>[
      DataColumn(
        label: Text("Budget"),
        numeric: false,
        onSort: (i, b) {},
        tooltip: "Budget",
      ),
      DataColumn(
        label: Text("Expense"),
        numeric: false,
        onSort: (i, b) {},
        tooltip: "Expense",
      ),
      DataColumn(
        label: Text("Action"),
        numeric: false,
        onSort: (i, b) {},
        tooltip: "Delete",
      ),
    ], rows: _createRows(snapshot));
  }

  List<DataRow> _createRows(List<BudgetExpenseCategoryNameModel> snapshot) {
    int idx = -1;
    List<DataRow> newList = snapshot.map((BudgetExpenseCategoryNameModel categoryModel) {
      idx++;
      return new DataRow(
        cells: <DataCell>[
          _createCellsForElement(idx, categoryModel, categoryModel.budgetCategoryName.length < 20
              ? categoryModel.budgetCategoryName
              : categoryModel.budgetCategoryName.substring(0, 15) + ".."),
           _createCellsForElement(idx, categoryModel, categoryModel.expenseCategoryName.length < 20
              ? categoryModel.expenseCategoryName
              : categoryModel.expenseCategoryName.substring(0, 15) + ".."),
          _createCellsForElement(idx, categoryModel, Icons.close),
        ],
      );
    }).toList();
    return newList;
  }

  DataCell _createCellsForElement(int idx, BudgetExpenseCategoryNameModel categoryModel, Object cellData) {
    return DataCell(
      cellData.runtimeType == String ?  Text(cellData) : iconCloseBtn(cellData, idx, categoryModel),
      showEditIcon: false,
      placeholder: false,
      onTap: () {
        
      },
    );
  }

  Widget iconCloseBtn(IconData iconData, int idx, BudgetExpenseCategoryNameModel categoryModel){
     return IconButton(
            icon: Icon(iconData),
            onPressed: () {

              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Alert"),
                    content: Text("Are you want to delete this mapped data"),
                    actions: <Widget>[
                      FlatButton(
                        child: Text("Yes"),
                        onPressed: () {
                          _budgetExpenseMapBloc.delete(categoryModel.budgetExpenseMapId);
                          loadData();
                          Navigator.of(context).pop();
                        },
                      ),
                      FlatButton(
                        child: Text("No"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                });
            },
          );
  }


  showAlert(String title, String msg){
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text(title),
              content: Text(msg),
              actions: <Widget>[
                FlatButton(
                  child: Text("Close"),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                )
              ],
            );
          });
  }


  Future<List<CategoryModel>> _asyncShowActiveCategoriesByType(CategoryType categoryType) async {
     List<CategoryModel> budgetActiveCategories =  await _categoryBloc.getActiveCategoryListByType(categoryType);
     return budgetActiveCategories;
  }


  mapBudget(BudgetExpenseMapModel budgetExpenseMapModel) {
      _budgetExpenseMapBloc.select(budgetExpenseMapModel.budgetCategoryId, budgetExpenseMapModel.expenseCategoryId).then((onValue) {
          if(onValue.length == 0){
              _budgetExpenseMapBloc.insert(budgetExpenseMapModel);
              showAlert("Alert", "Budget Mapped With Expense");
          }
          else{
            showAlert("Alert", "Budget Already Mapped");
          }
      });
  }

  loadData() {

    loadBudgetExpenseMap().then((onValue) {
                setState(() {
                  buildBudgetExpenseMapTable(onValue);
                }); 
              });

    
  }

  Future<List<BudgetExpenseCategoryNameModel>> loadBudgetExpenseMap() async {
    final rows = await _budgetExpenseMapBloc.selectBudgetExpenseMap();
    return rows;
  }

}

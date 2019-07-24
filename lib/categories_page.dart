import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_material_color_picker/flutter_material_color_picker.dart';
import 'package:expensetracker/model/dropdown_model.dart';
import 'package:expensetracker/bloc/dropdown_bloc.dart';
import 'package:expensetracker/bloc/dropdown_event.dart';
import 'package:expensetracker/bloc/categorytype_bloc.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/bloc/category_bloc.dart';
import 'package:expensetracker/common/color.dart';
import 'package:expensetracker/sidedrawer.dart';


class CategoriesScreen extends StatefulWidget {
  final BuildContext context;

  CategoriesScreen(this.context);

  @override
  State<StatefulWidget> createState() => CategoriesState();
}

class CategoriesState extends State<CategoriesScreen> {
  final _ddlBloc = DropdownBloc();
  final _categoryBloc = CategoryBloc();

  final txtController = TextEditingController();
  DropdownModel ddlSelectedValue = DropdownModel();

  int selectedCategoryId = 0;
  int selectedCategoryIdx;
  String btnSubmit = "Add";
  int colorCode = defaultColorCode();

  @override
  void initState() {
    super.initState();
    _categoryBloc.getActiveCategories();
    categorytypesbloc.fetchAllCategoryTypes();
  }

  @override
  void dispose() {
    categorytypesbloc.dispose();
    txtController.dispose();
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
          title: Text('Categories'),
          centerTitle: true,
          actions: <Widget>[
            Icon(Icons.category),
            Padding(padding: EdgeInsets.only(right: 10.0),)
          ],
        ),
      drawer: sideDrawer(context),
      body: Column(children: <Widget>[
        StreamBuilder(
          stream: categorytypesbloc.getCategoryTypes,
          builder: (context, AsyncSnapshot<List<DropdownModel>> snapshot) {
            if (snapshot.hasData) {
              return buildCategoryTypeDropdownList(snapshot);
            } else if (snapshot.hasError) {
              return Text(snapshot.error.toString());
            }
            return Center(child: CircularProgressIndicator());
          },
        ),
        ListTile(
          title: new TextField(
            controller: txtController,
            decoration: new InputDecoration(
              hintText: "Enter the text",
            ),
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
             Text("Category Color: ", style: TextStyle(color: Color(defaultColorCode())),),
             Container(color: Color(colorCode), child: SizedBox(width: 60, height: 20,),),
             IconButton(icon: Icon(Icons.color_lens), onPressed: () {
                  colorDialog(context);
             },)
          ],
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(right: 20),
              child: RaisedButton(
                padding: const EdgeInsets.all(8.0),
                textColor: Theme.of(context).textTheme.display1.color,
                color: Theme.of(context).primaryColor,
                onPressed: addCategory,
                child: new Text(btnSubmit),
              ),
            )
          ],
        ),
        Expanded(
          child: ListView(
            children: <Widget>[
              buildCategoryList(),
            ],
          ),
        )
      ]),
    );
  }

  Future<String> colorDialog(BuildContext context) async {
      

      return showDialog<String>(
        context: context,
        barrierDismissible: false, // dialog is dismissible with a tap on the barrier
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Select the Color'),
            content: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: <Widget>[
                  MaterialColorPicker(
                     onColorChange: (Color color) {
                         setState(() {
                            colorCode =  color.value;
                         });
                     },
                  ),
                ],
              ),
            ),
            actions: <Widget>[
              FlatButton(
                child: Text('Ok'),
                textColor: Theme.of(context).primaryColor,
                onPressed: () {
                  Navigator.of(context).pop("Ok");
                },
              ),
            ],
          );
        },
      );
  }

  Widget buildCategoryTypeDropdownList(AsyncSnapshot<List<DropdownModel>> snapshot) {
    return DropdownButton<DropdownModel>(
      items: snapshot.data.map((DropdownModel val) {
        return DropdownMenuItem<DropdownModel>(
          value: val,
          child: Text(val.value),
        );
      }).toList(),
      onChanged: (value) {
        _ddlBloc.dropdownEvent.add(OnSelectedEvent(value));
      },
      hint: StreamBuilder(
        stream: _ddlBloc.selectedValue,
        initialData: DropdownModel(key: 0, value: "--Select Type--"),
        builder: (context, AsyncSnapshot<DropdownModel> snapshot) {
          if (snapshot.hasData) {
            ddlSelectedValue = snapshot.data;
            return Text(snapshot.data.value);
          } else if (snapshot.hasError) {
            return Text(snapshot.error.toString());
          }
          return Text("");
        },
      ),
    );
  }

  Widget buildCategoryList() {
    return StreamBuilder(
      stream: _categoryBloc.categoryValue,
      builder: (context, AsyncSnapshot<List<CategoryModel>> snapshot) {
        if (snapshot.hasData) {
          return buildCategoryTable(snapshot);
        } else if (snapshot.hasError) {
          return Text(snapshot.error.toString());
        }
        return Center(child: Text(""));
      },
    );
  }

  Widget buildCategoryTable(AsyncSnapshot<List<CategoryModel>> snapshot) {
    return DataTable(columns: <DataColumn>[
      DataColumn(
        label: Text("Name"),
        numeric: false,
        onSort: (i, b) {},
        tooltip: "Name",
      ),
      DataColumn(
        label: Text("Type"),
        numeric: false,
        onSort: (i, b) {},
        tooltip: "Type",
      ),
      DataColumn(
        label: Text("Action"),
        numeric: false,
        onSort: (i, b) {},
        tooltip: "Delete",
      ),
    ], rows: _createRows(snapshot));
  }

  List<DataRow> _createRows(AsyncSnapshot<List<CategoryModel>> snapshot) {
    int idx = -1;
    List<DataRow> newList = snapshot.data.map((CategoryModel categoryModel) {
      idx++;
      return new DataRow(
        cells: <DataCell>[
          _createCellsForElement(idx, categoryModel, categoryModel.categoryName.length < 20
              ? categoryModel.categoryName
              : categoryModel.categoryName.substring(0, 20) + ".."),
          _createCellsForElement(idx, categoryModel, categoryModel.categoryDesc),
          _createCellsForElement(idx, categoryModel, Icons.close),
        ],
      );
    }).toList();
    return newList;
  }

  DataCell _createCellsForElement(int idx, CategoryModel categoryModel, Object cellData) {
    return DataCell(
      cellData.runtimeType == String ?  Text(cellData, style: TextStyle(color: getCategoryColor(categoryModel.color)),) : iconCloseBtn(cellData, idx, categoryModel),
      showEditIcon: false,
      placeholder: false,
      onTap: () {
        cellData.runtimeType == String ? editCategory(idx, categoryModel) : doNothing();
      },
    );
  }

  Widget iconCloseBtn(IconData iconData, int idx, CategoryModel categoryModel){
     return IconButton(
            icon: Icon(iconData),
            onPressed: () {
              onSoftDeleteCategory(idx, categoryModel);
            },
          );
  }

  onSoftDeleteCategory(int idx, CategoryModel categoryModel){

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text("Alert"),
            content: Text("Are you want to delete this category data"),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  softDeleteCategory(idx, categoryModel);
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

  addCategory() {
    if (txtController.text.trim() == "" || ddlSelectedValue.key == CategoryType.none) {
        showAlert("Category", "Please give the valid inputs");
    } else {
      if(selectedCategoryId == 0){
        if (_categoryBloc.categoryModelList.where((l) => l.categoryName == txtController.text.trim() && l.categoryType == ddlSelectedValue.key).length == 0){
              CategoryModel categoryModel = CategoryModel(categoryName: txtController.text.trim(), 
                                                          categoryDesc: ddlSelectedValue.value, categoryType: ddlSelectedValue.key,
                                                          orderBy: 1, isActive: 1, color: colorCode);

              addCategoryData(categoryModel);
              txtController.clear();
        }
        else{
          showAlert("Add Category", "Category Already Exists");
        }
      }
      else{
        if (_categoryBloc.categoryModelList.where((l) => l.categoryName == txtController.text.trim() && l.categoryType == ddlSelectedValue.key).length == 0){
          updateCategory(selectedCategoryIdx);
        }
        else{
          showAlert("Update Category", "Category Already Exists");
        }
      }
    }
  }

  editCategory(int idx, CategoryModel categoryModel) {
      changeBtnText("Update");
      selectedCategoryIdx = idx;
      DropdownModel ddlSel = new  DropdownModel(key: categoryModel.categoryType, value: categoryModel.categoryDesc);
      _ddlBloc.dropdownEvent.add(OnSelectedEvent(ddlSel));
      txtController.text = categoryModel.categoryName;
      selectedCategoryId = categoryModel.categoryId;
      print(categoryModel.color);
      if(categoryModel.color != null) {
          setState(() {
              colorCode =  categoryModel.color;
          });
      }
      else {
        setState(() {
              colorCode =  defaultColorCode();
        });
      }
  }

  updateCategory(int selectedCategoryIdx) {
      CategoryModel categoryModel = CategoryModel(categoryId: selectedCategoryId, categoryName: txtController.text.trim(), 
                                                          categoryDesc: ddlSelectedValue.value, categoryType: ddlSelectedValue.key,
                                                          orderBy: 1, isActive: 1, color: colorCode);
      updateCategoryData(selectedCategoryIdx, categoryModel);
      clearFields();
  }

  softDeleteCategory(int idx, CategoryModel categoryModel){
         CategoryModel cModel = CategoryModel(categoryId: categoryModel.categoryId, categoryName: categoryModel.categoryName, 
                                                          categoryDesc: categoryModel.categoryDesc, categoryType: categoryModel.categoryType,
                                                          orderBy: 1, isActive: 0);
        softDeleteCategoryData(idx, cModel);
        clearFields();
  }

  clearFields(){
    txtController.clear();
    changeBtnText("Add");
    selectedCategoryId = 0;
  }

  doNothing(){
    //print("doNothing");
  }

  Future<void> addCategoryData(CategoryModel categoryModel) async {
    _categoryBloc.insertCategory(categoryModel);
  }

  Future<void> updateCategoryData(int selectedIdx, CategoryModel categoryModel) async {
    _categoryBloc.updateCategory(selectedIdx, categoryModel);
  }

  Future<void> softDeleteCategoryData(int selectedIdx,CategoryModel categoryModel) async {
    _categoryBloc.softDeleteCategory(selectedIdx, categoryModel);
  }

  changeBtnText(String btnName){
    setState(() { btnSubmit = btnName; });
  }

}

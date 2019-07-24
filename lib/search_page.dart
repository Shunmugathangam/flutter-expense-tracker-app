import 'package:flutter/material.dart';
import 'package:flutter_multiselect/flutter_multiselect.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';
import 'package:expensetracker/model/search_model.dart';

import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/bloc/category_bloc.dart';
import 'package:expensetracker/bloc/track_bloc.dart';
import 'package:expensetracker/model/track_model.dart';
import 'package:expensetracker/search_result_page.dart';

class SearchPage extends StatefulWidget {

  @override
  SearchPageState createState() => SearchPageState();
}

class SearchPageState extends State<SearchPage> {

  final _categoryBloc = CategoryBloc();
  final _trackBloc = TrackBloc();

  final _formKey = GlobalKey<FormState>();

  CategoryType _selectedCategoryType;

  final formats = {
    InputType.date: DateFormat('EEEE, MMMM d, yyyy'),
  };
  InputType inputType = InputType.date;

  bool editable = false;
  DateTime fromDate;
  DateTime toDate;

  SearchModel searchModel;

  @override
  void initState() {
    super.initState();
    searchModel = new SearchModel();
    _selectedCategoryType = CategoryType.expense;
    searchModel.categoryType = _selectedCategoryType;
    _categoryBloc.getCategoriesByType(_selectedCategoryType);
  }

  @override
  void dispose() {
    super.dispose();
     _categoryBloc.dispose();
    _trackBloc.dispose();
  }

  @override
  Widget build(BuildContext context) {
      return Scaffold(
        appBar: AppBar(
          title: Text("Search"),
          centerTitle: true,
          ),
        body: SingleChildScrollView( 
              scrollDirection: Axis.vertical,
              child: Column(children: <Widget>[
          
          Form(key: _formKey,
          child: Padding(padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
          child: Column(
            children: <Widget>[
                DateTimePickerFormField(
                inputType: inputType,
                format: formats[inputType],
                editable: editable,
                initialValue: fromDate,
                decoration: InputDecoration(
                    labelText: 'From Date', hasFloatingPlaceholder: false),
                onChanged: (dt) => setState(() => fromDate = dt),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter the Date';
                  }
                },
                onSaved: (DateTime value) {
                  searchModel.fromDate = value;
                },
              ),
              DateTimePickerFormField(
                inputType: inputType,
                format: formats[inputType],
                editable: editable,
                initialValue: toDate,
                decoration: InputDecoration(
                    labelText: 'To Date', hasFloatingPlaceholder: false),
                onChanged: (dt) => setState(() => toDate = dt),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter the Date';
                  }
                },
                onSaved: (DateTime value) {
                  searchModel.toDate = value;
                },
              ),
              TextFormField(
                // validator: (value) {
                //   if (value.isEmpty) {
                //     return 'Please enter the Description';
                //   }
                // },
                decoration: InputDecoration(
                  hintText: "Enter the Description",
                ),
                onSaved: (String value) {
                  searchModel.description = value;
                },
              ),
              SizedBox(height: 15,),
              Row(mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        new Radio(
                          value: CategoryType.expense,
                          groupValue: _selectedCategoryType,
                          onChanged: selectedCategoryType,
                        ),
                        new Text(
                          'Expense',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                        new Radio(
                          value: CategoryType.income,
                          groupValue: _selectedCategoryType,
                          onChanged: selectedCategoryType,
                        ),
                        new Text(
                          'Income',
                          style: new TextStyle(
                            fontSize: 16.0,
                          ),
                        ),
                        new Radio(
                          value: CategoryType.budget,
                          groupValue: _selectedCategoryType,
                          onChanged: selectedCategoryType,
                        ),
                        new Text(
                          'Budget',
                          style: new TextStyle(fontSize: 16.0),
                        ),
                      ],
              ),
              multiSelectCategories(),
              Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: buildBtn()),
              //SizedBox(height: 15,),
              // MultiSelect( 
              //   autovalidate: false, 
              //   titleText: "Categories", 
              //   validator: (value) { 
              //     if (value == null) { 
              //     return 'Please select one or more option(s)'; 
              //     } 
              //   }, 
              //   errorText: 'Please select one or more option(s)', 
              //   dataSource: [ 
              //     { "display": "Australia", "value": 1, }, 
              //     { "display": "Canada", "value": 2, }, 
              //     { "display": "India", "value": 3, }, 
              //     { "display": "United States", "value": 4, }
              //   ], 
              //   textField: 'display', 
              //   valueField: 'value', 
              //   filterable: true, 
              //   required: true, 
              //   value: null, 
              //   onSaved: (value) { 
              //     print('The value is $value'); 
              //   }),
            ],
          ),
          )
          ),
          
        ],),),
        );
  }

  buildBtn() {
    return <Widget>[
        Padding(
            padding: const EdgeInsets.only(right: 10, top: 20),
            child: RaisedButton(
              padding: const EdgeInsets.all(8.0),
              textColor: Theme.of(context).textTheme.display1.color,
              color: Theme.of(context).primaryColor,
              onPressed: onSearchTrack,
              child: new Text("Search"),
            )),
      ];
  }

  onSearchTrack() async {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      List<TrackDetailsModel> lst = await asyncgetTrackData(searchModel);
      int amt = await asyncgetTrackTotalAmount(searchModel);
      Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => SearchResultPage(categoryType: _selectedCategoryType, lstTrackDetailsModel: lst, totalAmount: amt,),),
            );
    }
  }

  Widget multiSelectCategories() {
     return StreamBuilder(
                  stream: _categoryBloc.categoryValue,
                  builder: (context, AsyncSnapshot<List<CategoryModel>> snapshot) {
                    if (snapshot.hasData) {
                      return buildMultiSelectCategories(snapshot.data);
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    else{
                        return Text("No Category Found");
                    }
                    //return Center(child: CircularProgressIndicator());
                  },
                );
  }

  buildMultiSelectCategories(List<CategoryModel> categories) {

        List<dynamic> lst = new List<dynamic>();
        lst.clear();
        categories.forEach((val) {
            lst.add({ "categoryId" : val.categoryId, "categoryName" : val.categoryName });
        });

        return MultiSelect( 
                autovalidate: false, 
                titleText: "Categories", 
                // validator: (value) { 
                //   if (value == null) { 
                //   return 'Please select one or more option(s)'; 
                //   } 
                // }, 
                // errorText: 'Please select one or more option(s)', 
                dataSource: lst, 
                textField: 'categoryName', 
                valueField: 'categoryId', 
                filterable: true, 
                required: false, 
                value: null, 
                onSaved: (value) { 
                  print('The value is $value'); 
                  searchModel.categoryIds = value;
                  print('categoryIds ${searchModel.categoryIds}'); 
                });
  }

  String getCategoryTypeName(CategoryType categoryType) {
      List<String> cName = categoryType.toString().split(".");
      String categoryTypeName = cName[1];
      return categoryTypeName[0].toUpperCase() + categoryTypeName.substring(1);
  }

  void selectedCategoryType(CategoryType val) {
      setState(() {
        _selectedCategoryType =  val;
      });
      searchModel.categoryType = _selectedCategoryType;
      _categoryBloc.getCategoriesByType(_selectedCategoryType);
  }


  Future<List<TrackDetailsModel>> asyncgetTrackData(SearchModel searchModel) async {
     List<Map<String, dynamic>> lst =  await _trackBloc.getTrackData(searchModel);
     List<TrackDetailsModel> lstTrackDetailsModel = List<TrackDetailsModel>();
     lstTrackDetailsModel.clear();

     lst.forEach((val) {
       lstTrackDetailsModel.add(TrackDetailsModel.fromJson(val));
     });

     return lstTrackDetailsModel;
  }

  Future<int> asyncgetTrackTotalAmount(SearchModel searchModel) async {
     int amt =  await _trackBloc.getTrackDataTotalAmount(searchModel);
     return amt;
  }

}
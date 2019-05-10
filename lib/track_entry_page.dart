import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:datetime_picker_formfield/datetime_picker_formfield.dart';

import 'package:expensetracker/model/dropdown_model.dart';
import 'package:expensetracker/bloc/dropdown_bloc.dart';
import 'package:expensetracker/bloc/dropdown_event.dart';
import 'package:expensetracker/model/category_model.dart';
import 'package:expensetracker/bloc/category_bloc.dart';
import 'package:expensetracker/bloc/track_bloc.dart';
import 'package:expensetracker/model/track_model.dart';

class TrackEntryDialog extends StatefulWidget {
  TrackEntryDialog({this.categoryType, this.trackIndex, this.trackDetailsModel});
  final CategoryType categoryType;
  final TrackDetailsModel trackDetailsModel;
  final int trackIndex;

  @override
  TrackEntryDialogState createState() => new TrackEntryDialogState(
      categoryType: this.categoryType,
      trackIndex: this.trackIndex,
      trackDetailsModel: this.trackDetailsModel);
}

class TrackEntryDialogState extends State<TrackEntryDialog> {
  TrackEntryDialogState({this.categoryType, this.trackIndex, this.trackDetailsModel});
  final CategoryType categoryType;
  final TrackDetailsModel trackDetailsModel;
  final int trackIndex;

  final _ddlBloc = DropdownBloc();
  final _categoryBloc = CategoryBloc();
  final _trackBloc = TrackBloc();

  final _formKey = GlobalKey<FormState>();

  DropdownModel ddlSelectedValue = new DropdownModel();
  TrackModel _data = new TrackModel();

  // final formats = {
  //   InputType.both: DateFormat("EEEE, MMMM d, yyyy 'at' h:mma"),
  //   InputType.date: DateFormat('yyyy-MM-dd'),
  //   InputType.time: DateFormat("HH:mm"),
  // };
  //InputType inputType = InputType.both;

  final TextEditingController _amountController = new TextEditingController();
  final TextEditingController _descriptionController = new TextEditingController();

  final formats = {
    InputType.date: DateFormat('EEEE, MMMM d, yyyy'),
  };
  InputType inputType = InputType.date;

  bool editable = false;
  DateTime trackDate;

  @override
  void initState() {
    super.initState();
    assignFormFieldValues(trackDetailsModel);
    _categoryBloc.getActiveCategoriesByType(categoryType);
  }

  @override
  void dispose() {
    super.dispose();
    _ddlBloc.dispose();
    _categoryBloc.dispose();
    _trackBloc.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: Text(titleText()),
        // actions: [
        //   new FlatButton(
        //       onPressed: () {
        //         final form = _formKey.currentState;
        //         if (form.validate()) {
        //           form.save();
        //           if (this.trackModel != null) {
        //             updateTrack(form);
        //           } else {
        //             addTrack(form);
        //           }
        //         }
        //       },
        //       child: new Text('SAVE',
        //           style: Theme.of(context)
        //               .textTheme
        //               .subhead
        //               .copyWith(color: Colors.white))),
        // ],
      ),
      body: Form(
        key: _formKey,
        child: Padding(
          padding: const EdgeInsets.only(top: 10, right: 20, left: 20),
          child: Column(
            children: <Widget>[
              _categoryField(),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the Amount';
                  }
                },
                controller: _amountController,
                decoration: InputDecoration(
                  hintText: "Enter the Amount",
                ),
                onSaved: (String value) {
                  _data.amount = int.parse(value);
                },
              ),
              TextFormField(
                validator: (value) {
                  if (value.isEmpty) {
                    return 'Please enter the Description';
                  }
                },
                controller: _descriptionController,
                decoration: InputDecoration(
                  hintText: "Enter the Description",
                ),
                onSaved: (String value) {
                  _data.description = value;
                },
              ),
              DateTimePickerFormField(
                inputType: inputType,
                format: formats[inputType],
                editable: editable,
                initialValue: trackDate,
                decoration: InputDecoration(
                    labelText: 'Date/Time', hasFloatingPlaceholder: false),
                onChanged: (dt) => setState(() => trackDate = dt),
                validator: (value) {
                  if (value == null) {
                    return 'Please enter the Date';
                  }
                },
                onSaved: (DateTime value) {
                  _data.trackDate = value.toString();
                },
              ),
              Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: buildBtn()),
            ],
          ),
        ),
      ),
    );
  }

  Widget buildCategoryDropdownList(
      AsyncSnapshot<List<CategoryModel>> snapshot, FormFieldState state) {
    return DropdownButton<CategoryModel>(
      items: snapshot.data.map((CategoryModel val) {
        return DropdownMenuItem<CategoryModel>(
          value: val,
          child: Text(val.categoryName),
        );
      }).toList(),
      isDense: true,
      onChanged: (value) {
        DropdownModel ddlV =
            new DropdownModel(key: value.categoryId, value: value.categoryName);
        _data.categoryId = value.categoryId;
        _ddlBloc.dropdownEvent.add(OnSelectedEvent(ddlV));
        state.didChange(value.categoryId);
      },
      hint: StreamBuilder(
        stream: _ddlBloc.selectedValue,
        initialData: DropdownModel(key: 0, value: "--Select Category--"),
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

  buildBtn() {
    if (trackDetailsModel != null) {
      return <Widget>[
        Padding(
            padding: const EdgeInsets.only(right: 10, top: 20),
            child: RaisedButton(
              padding: const EdgeInsets.all(8.0),
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: onSaveTrack,
              child: new Text("Save"),
            )),
        Padding(
            padding: const EdgeInsets.only(right: 10, top: 20),
            child: RaisedButton(
              padding: const EdgeInsets.all(8.0),
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: onDeleteTrack,
              child: new Text("Delete"),
            )),
      ];
    } else {
      return <Widget>[
        Padding(
            padding: const EdgeInsets.only(right: 10, top: 20),
            child: RaisedButton(
              padding: const EdgeInsets.all(8.0),
              textColor: Colors.white,
              color: Colors.blue,
              onPressed: onSaveTrack,
              child: new Text("Save"),
            )),
      ];
    }
  }

  _categoryField() {
    return FormField<int>(
      validator: (value) {
        if (_data.categoryId == null) {
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
                child: StreamBuilder(
                  stream: _categoryBloc.categoryValue,
                  builder:
                      (context, AsyncSnapshot<List<CategoryModel>> snapshot) {
                    if (snapshot.hasData) {
                      return buildCategoryDropdownList(snapshot, state);
                    } else if (snapshot.hasError) {
                      return Text(snapshot.error.toString());
                    }
                    return DropdownButton(
                      items: [],
                      isDense: true,
                      hint: Text("--Select Category--"),
                      onChanged: (value) => {},
                    );
                    //return Center(child: CircularProgressIndicator());
                  },
                ),
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

  showAlert(String title, String msg) {
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

  String titleText() {
    String title = "";
    if (this.trackDetailsModel != null) {
      title =
          this.categoryType.index == 1 ? "Incomes Details" : "Expense Details";
    } else {
      title = this.categoryType.index == 1 ? "Add Incomes" : "Add Expense";
    }

    return title;
  }

  assignFormFieldValues(TrackDetailsModel trackModel) {
    if (trackModel != null) {
      _amountController.text = trackModel.amount.toString();
      _descriptionController.text = trackModel.description;
      trackDate = DateTime.parse(trackModel.trackDate);
      DropdownModel ddlV =
          new DropdownModel(key: trackModel.categoryId, value: trackModel.categoryName);
      _data.categoryId = trackModel.categoryId;
      _ddlBloc.dropdownEvent.add(OnSelectedEvent(ddlV));
    }
  }

  onSaveTrack() {
    final form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      if (this.trackDetailsModel != null) {
        updateTrack(form);
      } else {
        addTrack(form);
      }
    }
  }

  onDeleteTrack(){

    showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(""),
            content: Text("Are you want to delete this track data"),
            actions: <Widget>[
              FlatButton(
                child: Text("Yes"),
                onPressed: () {
                  deleteTrackData();
                  Navigator.of(context).pop();
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

  addTrack(FormState fs) {
    addTrackData(_data);
    fs.reset();
    _amountController.text = "";
    _descriptionController.text = "";
    showAlert("", "Track Added Successfully");
  }

  updateTrack(FormState fs) {
    _data.trackId = trackDetailsModel.trackId;
    updateTrackData(_data);
    showAlert("", "Track Updated Successfully");
  }

  Future<void> addTrackData(TrackModel trackModel) async {
    _trackBloc.insertTrack(trackModel);
  }

  Future<void> updateTrackData(TrackModel trackModel) async {
    _trackBloc.updateTrack(trackIndex, trackModel);
  }

  Future<void> deleteTrackData() async {
    _trackBloc.deleteTrack(trackIndex, trackDetailsModel.trackId);
  }

}

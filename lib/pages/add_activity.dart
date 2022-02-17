import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:days_since/models/activity.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:intl/intl.dart';

class AddActivity extends StatefulWidget {
  const AddActivity({Key key}) : super(key: key);

  @override
  _AddActivityState createState() => _AddActivityState();
}

class _AddActivityState extends State<AddActivity> {
  Map data = {};
  Database db;
  TextEditingController activityController = new TextEditingController();
  bool isButtonDisabled = true;
  DateTime selectedDate = DateTime.now();

  @override
  void initState() {
    super.initState();
  }

  Future<void> insertActivity(Activity activity) async {
    await db.insert(
      'activity',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: selectedDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedDate)
      setState(() {
        selectedDate = picked;
      });
  }

  @override
  Widget build(BuildContext context) {
    data = data.isNotEmpty ? data : ModalRoute.of(context).settings.arguments;
    db = data['db'];
    final DateFormat dateFormatter = DateFormat('yyyy-MM-dd');
    final String formattedDate = dateFormatter.format(selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: const Text('New Activity'),
      ),
      body: Column(
        children: [
          const Center(
            child: Padding(
              padding: EdgeInsets.fromLTRB(8.0, 16.0, 8.0, 8.0),
              child: Text(
                'Enter an activity:',
                style: TextStyle(fontSize: 24),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: activityController,
              decoration: InputDecoration(
                hintText: 'New activity name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.edit),
              ),
              onChanged: (String value) async {
                setState(() {
                  isButtonDisabled = value.isEmpty;
                });
              },
            ),
          ),
          Text("$formattedDate"),
          RaisedButton(
            onPressed: () => _selectDate(context),
            child: Text('Select date'),
          ),
          RaisedButton(
            padding: const EdgeInsets.all(8.0),
            textColor: Colors.white,
            color: Colors.blue,
            onPressed: isButtonDisabled ? null : () async {
              Uuid uuid = Uuid();
              String v4Uuid = uuid.v4();
              print(v4Uuid);
              print(selectedDate);
              Activity activity = Activity(
                id: v4Uuid,
                name: activityController.text,
                date: selectedDate,
              );

              await insertActivity(activity);
              Navigator.pop(context);
            },
            child: new Text("Submit"),
          ),
        ],
      ),
    );
  }
}

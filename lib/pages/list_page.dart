import 'package:flutter/material.dart';
import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:days_since/models/activity.dart';
import 'package:uuid/uuid.dart';
import 'package:uuid/uuid_util.dart';
import 'package:intl/intl.dart';

class ListPage extends StatefulWidget {
  const ListPage({Key key}) : super(key: key);

  @override
  _ListPageState createState() => _ListPageState();
}

class _ListPageState extends State<ListPage> {
  Database db;
  List<Activity> activities = [];

  @override
  void initState() {
    super.initState();
    asyncInit();
  }

  void asyncInit() async {
    db = await initDb();
    await getInitialActivities();
  }

  Future<void> getInitialActivities() async {
    List<Activity> initialActivities = await getActivities();
    activities = initialActivities;
    if (activities.length == 0) {
      Uuid uuid1 = Uuid();
      String v4Uuid1 = uuid1.v4();
      Activity example1 = Activity(
        id: v4Uuid1,
        name: 'Haircut',
        date: DateTime.now().subtract(Duration(days: 23)),
      );

      Uuid uuid2 = Uuid();
      String v4Uuid2 = uuid2.v4();
      Activity example2 = Activity(
        id: v4Uuid2,
        name: 'Clean room',
        date: DateTime.now().subtract(Duration(days: 7)),
      );

      await insertActivity(example1);
      await insertActivity(example2);

      activities.add(example1);
      activities.add(example2);
    }
    setState(() {});
  }

  Future<Database> initDb() async {
    print('running initDb');
    WidgetsFlutterBinding.ensureInitialized();
    final database = openDatabase(
      join(await getDatabasesPath(), 'activity_database.db'),
      onCreate: (db, version) {
        return db.execute(
          'CREATE TABLE activity(id TEXT PRIMARY KEY, name TEXT, date DATE)',
        );
      },
      version: 1,
    );

    return database;
  }

  Future<void> insertActivity(Activity activity) async {
    await db.insert(
      'activity',
      activity.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateActivity(Activity activity) async {
    await db.update(
      'activity',
      activity.toMap(),
      where: 'id = ?',
      whereArgs: [activity.id],
    );
  }

  Future<void> deleteActivity(String id) async {
    await db.delete(
      'activity',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Activity>> getActivities() async {
    print('running getActivities');
    final List<Map<String, dynamic>> maps = await db.query('activity');

    return List.generate(maps.length, (i) {
      print(maps[i]['date']);
      return Activity(
        id: maps[i]['id'],
        name: maps[i]['name'],
        date: DateTime.parse(maps[i]['date']),
      );
    });
  }

  Future<DateTime> selectDate(BuildContext context) async {
    final DateTime picked = await showDatePicker(
        context: context,
        initialDate: new DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != new DateTime.now()) {
      print(picked);
    }
    return picked;
  }

  Future<void> resetActivity(DateTime newDate, int index) async {
    activities[index].date = newDate;
    await updateActivity(activities[index]);
    List<Activity> newActivities = await getActivities();
    setState(() {
      activities = newActivities;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Days Since...'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.pushNamed(context, '/add', arguments: {
            'db': db,
          });
          List<Activity> newActivities = await getActivities();
          setState(() {
            activities = newActivities;
          });
        },
        tooltip: 'New Item',
        child: Icon(Icons.add),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: activities.length,
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              itemBuilder: (context, index)  {
                DateFormat formatter = DateFormat('yyyy-MM-dd');
                DateTime today = DateTime.now();//.add(Duration(days: 999));
                DateTime activityDate = activities[index].date;
                int difference = today.difference(activityDate).inDays;
                String subtitle = 'This activity last took place on ' + formatter.format(activities[index].date);
                if (difference < 0) {
                  subtitle = 'This activity will take place on ' + formatter.format(activities[index].date);
                }
                return GestureDetector(
                  onLongPress: () => showDialog<String>(
                    context: context,
                    builder: (BuildContext context) => AlertDialog(
                      title: const Text('Reset activity?'),
                      content: const Text('Resetting this event cannot be undone.'),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () => Navigator.pop(context, 'Cancel'),
                          child: const Text('Cancel'),
                        ),
                        TextButton(
                          onPressed: () async {
                            resetActivity(await selectDate(context), index);
                            Navigator.pop(context, 'Reset');
                          },
                          child: const Text('Select Date'),
                        ),
                        TextButton(
                          onPressed: () async {
                            resetActivity(DateTime.now(), index);
                            Navigator.pop(context, 'Reset');
                          },
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  ),
                  child: Card(
                    child: ListTile(
                      leading: Text(difference.toString(),
                        style: TextStyle(
                          fontSize: 30.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      title: Text(activities[index].name),
                      subtitle: Text(subtitle),
                      isThreeLine: false,
                      trailing: GestureDetector(
                        onTap: () async {
                          await deleteActivity(activities[index].id);
                          List<Activity> newActivities = await getActivities();
                          setState(() {
                            activities = newActivities;
                          });
                        },
                        child: Icon(Icons.delete,
                          color: Colors.red,
                        ),
                      ),
                    ),
                  ),
                );
              }
            ),
          ),
        ],
      ),
    );
  }
}

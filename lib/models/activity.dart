import 'package:intl/intl.dart';

class Activity {
  final String id;
  final String name;
  DateTime date;

  Activity({
    this.id,
    this.name,
    this.date,
  });

  // Convert an Activity into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return {
      'id': id,
      'name': name,
      'date': formatter.format(date),
    };
  }

  // Implement toString to make it easier to see information about
  // each Activity when using the print statement.
  @override
  String toString() {
    final DateFormat formatter = DateFormat('yyyy-MM-dd');
    return 'Activity{id: $id, name: $name, date: ${formatter.format(date)}}';
  }
}
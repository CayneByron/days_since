import 'package:days_since/pages/add_activity.dart';
import 'package:days_since/pages/list_page.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
  initialRoute: '/',
  onGenerateRoute: (settings) {
    return null;
  },
  routes: {
    '/': (context) => ListPage(),
    '/add': (context) => AddActivity(),
  },
));
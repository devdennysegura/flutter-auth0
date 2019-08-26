import 'dart:async';

import 'package:flutter/material.dart';
import 'demo.dart';

void main() async {
  runZoned<Future<Null>>(() async {
    runApp(MyApp());
  }, onError: (error, stackTrace) async {
    debugPrint(error.toString());
  });
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Auth0 Demo',
      home: MyHomePage(title: 'Demo'),
    );
  }
}

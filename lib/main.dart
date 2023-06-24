import 'package:code_chart/commons/routes.dart';
import 'package:flutter/material.dart';


void main() {
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    initialRoute: "/home",
    onGenerateRoute: pageRouting,
  ));
}

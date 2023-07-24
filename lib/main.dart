import 'dart:ui';

import 'package:code_chart/commons/routes.dart';
import 'package:flutter/material.dart';

/*
 * TODO: Better approach to this project is to loosely coupled every components
    Currently, many ViewModels, although not all, are tightly coupled to the View
    Refactor the ViewModels to only know about the existence of the Model and exposes its command
    Also, ephemeral states should be stored locally within the View
    Or... maybe not, I don't know, there will be a whole debate on what's appropriate and what's not
    but as far as the project concerns, neither cause any issue nor have any noticeable advantage
 */
// TODO: Remove custom scrollBehavior on Android build
void main() {
  runApp(MaterialApp(
    scrollBehavior: ScrollBehavior().copyWith(dragDevices: <PointerDeviceKind>{PointerDeviceKind.mouse, PointerDeviceKind.touch}),
    debugShowCheckedModeBanner: false,
    initialRoute: "/home",
    onGenerateRoute: pageRouting,
  ));
}

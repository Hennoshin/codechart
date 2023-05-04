import 'package:code_chart/flowchart_editor/screens/flowchart_editor.dart';
import 'package:flutter/material.dart';

Route? pageRouting(RouteSettings settings) {
  switch (settings.name) {
    case "/home":
      return MaterialPageRoute(builder: (context) => FlowchartEditorScreen());
  }
  
  return null;
}
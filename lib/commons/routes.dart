import 'package:code_chart/flowchart_editor/screens/flowchart_editor.dart';
import 'package:flutter/material.dart';

import '../code_converter/screens/code_conversion_screen.dart';
import '../flowchart_editor/screens/function_edit_screen.dart';
import '../flowchart_editor/screens/function_manager.dart';

Route? pageRouting(RouteSettings settings) {
  switch (settings.name) {
    case RouteNames.home:
      return MaterialPageRoute(builder: (context) => FlowchartEditorScreen(settings: settings));

    case RouteNames.functionManager:
      return MaterialPageRoute(builder: (_) => FunctionManagerScreen(settings: settings));
      
    case RouteNames.functionEdit:
      return MaterialPageRoute(builder: (_) => FunctionEditScreen(settings: settings));

    case RouteNames.codeConversion:
      return MaterialPageRoute(builder: (_) => CodeConversionScreen(settings: settings));
  }
  
  return null;
}

class RouteNames {
  static const home = "/home";
  static const functionManager = "/function-manager";
  static const functionEdit = "$functionManager/edit";
  static const codeConversion = "/code-conversion";
}
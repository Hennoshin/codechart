import 'dart:typed_data';

import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/utility/file_io_service.dart';
import 'package:code_chart/utility/flowchart_program_save_file.dart';
import 'package:flutter/material.dart';
import 'package:tuple/tuple.dart';

import '../models/flowchart.dart';

class FlowchartEditorViewModel extends ChangeNotifier {
  FlowchartProgram mainProgram;
  Flowchart _currentFlowchart;
  String _currentFlowchartID;
  String programName;
  bool toggle = true;
  int elementSelectIndex = 0;
  String addElementIndex = "1";

  int _selectedToolsIndex = 1;

  int get selectedToolsIndex => _selectedToolsIndex;
  set selectedToolsIndex(i) {
    _selectedToolsIndex = i;

    notifyListeners();
  }

  FlowchartEditorViewModel(this.mainProgram) :
        _currentFlowchart = mainProgram.mainFlowchart,
        _currentFlowchartID = "main",
        programName = mainProgram.programName;


  void setAddElementSelect(String index) {
    addElementIndex = index;
  }


  void stepRunFlowchart() {
    try {
      mainProgram.stepRunFlowchart();
    }
    catch (e) {
      stopFlowchart();

      rethrow;
    }

    notifyListeners();
  }

  void stopFlowchart() {
    mainProgram.stopFlowchart();

    notifyListeners();
  }

  BaseElement? currentRunElement() {
    return mainProgram.runEnv?.currentElement;
  }

  void setInputBuffer(String input) {
    mainProgram.runEnv?.setInputBuffer(input);

    notifyListeners();
  }

  void setProgramName(String name) {
    mainProgram.programName = name;
    programName = name;

    notifyListeners();
  }

  void setCurrentFlowchart(String identifier) {
    if (identifier == "main") {
      _currentFlowchart = mainProgram.mainFlowchart;
      _currentFlowchartID = "main";
    }
    else {
      var fn = mainProgram.functionTable[identifier];
      _currentFlowchart = fn ?? _currentFlowchart;
      _currentFlowchartID = fn == null ? _currentFlowchartID : identifier;
    }

    notifyListeners();
  }

  Future<void> loadProgram() async {
    FileIOService service = FileIOService.instance;

    Tuple2<String, Uint8List>? result = await service.loadFile();
    if (result == null) throw Exception("Unable to load file");

    var saveFile = FlowchartProgramSaveFile.fromFile(result.item1, result.item2);
    FlowchartProgram newProgram = saveFile.createProgramFromSave();

    mainProgram = newProgram;
    programName = mainProgram.programName;
    _currentFlowchartID = "main";
    _currentFlowchart = newProgram.mainFlowchart;

    notifyListeners();
  }

  Future<void> saveProgram() async {
    FlowchartProgramSaveFile saveFile = FlowchartProgramSaveFile(mainProgram);
    FileIOService service = FileIOService.instance;

    await service.saveToFile(fileName: saveFile.fullProgramName, bytes: saveFile.buffer);
  }

  String get currentFlowchartID => _currentFlowchartID;
  Flowchart get currentFlowchart => _currentFlowchart;
  bool get isFlowchartRunning => mainProgram.isRunning;
}
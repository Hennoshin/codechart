// Test memory.dart

import 'dart:math';

import 'package:test/test.dart';
import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';

void main() {
  late Memory memory;
  setUp(() {
    memory = Memory("testStack");
  });

  test("Add variable", () {
    memory.addNewVariables<int>("testVar");
    expect(memory.variables["testVar"] != null, true);
  });

  test("Add same variable", () {
    String varName = "testVar";
    memory.addNewVariables<int>(varName);
    expect(() => memory.addNewVariables<int>(varName), throwsException);
  });

  test("Get nonexistent variable", () {
    String varName = "testVar";
    expect(() => memory.getData(varName), throwsException);
  });

  test("Get variable", () {
    String varName = "testVar";
    memory.addNewVariables<int>(varName);
    expect(() => memory.getData(varName), returnsNormally);
  });

  test("Assign value to variable", () {
    String varName = "testVar";
    memory.addNewVariables<int>(varName);
    var variable = memory.getData(varName);
    expect(() => memory.assignVariable(variable, 6), returnsNormally);
  });

  test("Assign mismatching variable type", () {
    String varName = "testVar";
    memory.addNewVariables<String>(varName);
    var variable = memory.getData(varName);
    expect(() => memory.assignVariable(variable, 6), throwsException);
  });
  
  test("Assign uninitialized variable to variable", () {
    String varName = "testVar";
    memory.addNewVariables<int>(varName);
    var variable = memory.getData(varName);

    String varName2 = "testVar2";
    memory.addNewVariables<int>(varName2);
    var variable2 = memory.getData(varName2);
    
    expect(() => memory.assignVariable(variable, variable2), throwsException);
  });

  test("Assign variable to variable", () {
    String varName = "testVar";
    memory.addNewVariables<int>(varName);
    var variable = memory.getData(varName);

    const int assignVariable = 5;
    String varName2 = "testVar2";
    memory.addNewVariables<int>(varName2);
    var variable2 = memory.getData(varName2);
    memory.assignVariable(variable2, assignVariable);

    expect(() => memory.assignVariable(variable, variable2), returnsNormally);
    expect(variable.value, assignVariable);
  });
}
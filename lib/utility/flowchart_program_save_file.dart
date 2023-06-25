import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:crypto/crypto.dart';

import '../flowchart_editor/models/function_flowchart.dart';

mixin FlowchartElementsData {
  static const encoder = utf8;
  late Uint8List elementsData;

  void setElementDataFromMap(Map<String, BaseElement> elements) {
    String jsonString = jsonEncode({
      "elements": [
        for (var entry in elements.entries)
          {"index": entry.key, "element": entry.value}
      ]
    });

    elementsData = Uint8List.fromList(encoder.encode(jsonString));
  }
}

class FunctionFlowchartData with FlowchartElementsData {
  Uint32List returnType;
  Uint32List numberOfParams;
  Uint64List startPointer;
  Uint8List functionName;
  Uint8List returnExpression;
  Uint8List params;

  FunctionFlowchartData(FunctionFlowchart functionFlowchart, int absoluteOffset) :
        returnType = Uint32List.fromList([functionFlowchart.returnType?.index ?? 0xffffffff]),
        numberOfParams = Uint32List.fromList([functionFlowchart.argList.length]),
        startPointer = Uint64List(1),
        functionName = ascii.encode("${functionFlowchart.name}\u0000"),
        returnExpression = ascii.encode("${functionFlowchart.returnExpression}\u0000"),
        params = Uint8List.fromList(utf8.encode(
            jsonEncode({
              "parameters": [
                for (var param in functionFlowchart.argList) {
                  "name": param.name,
                  "type": param.type.index,
                  "isArray": param.isArray
                }]
            })
        )) {
    startPointer[0] = absoluteOffset + returnType.buffer.lengthInBytes + numberOfParams.buffer.lengthInBytes +
        startPointer.buffer.lengthInBytes + functionName.buffer.lengthInBytes + returnExpression.lengthInBytes + params.buffer.lengthInBytes;
    setElementDataFromMap(functionFlowchart.elements2);
  }

  Uint8List get combinedData => Uint8List.fromList(
      returnType.buffer.asUint8List() +
      numberOfParams.buffer.asUint8List() +
      startPointer.buffer.asUint8List() +
      functionName +
      returnExpression +
      params +
      elementsData
  );
}

class FlowchartProgramSaveFile with FlowchartElementsData {
  // Null-terminated "CCV" string
  static final Uint8List prefix = ascii.encode("CCV\u0000");
  static const Hash hashFunction = md5;
  static const int hashDigestSize = 16;

  String programName;
  Uint32List functionsCount;
  Uint64List functionsPointers;
  Uint64List mainElementPointer;
  late Digest hashDigest;
  List<FunctionFlowchartData> functionsData = [];

  FlowchartProgramSaveFile(FlowchartProgram program) :
        programName = program.programName,
        functionsCount = Uint32List.fromList([program.functionTable.length]),
        functionsPointers = Uint64List(program.functionTable.length),
        mainElementPointer = Uint64List(1) {
    int offset = prefix.length;
    offset += functionsCount.buffer.lengthInBytes;
    offset += functionsPointers.buffer.lengthInBytes;
    offset += mainElementPointer.buffer.lengthInBytes;

    Uint8List fillerDigest = Uint8List(hashDigestSize);
    offset += fillerDigest.buffer.lengthInBytes;

    // Encode the main flowchart elements to json
    Flowchart main = program.mainFlowchart;

    setElementDataFromMap(main.elements2);
    mainElementPointer[0] = offset;
    offset += elementsData.length;

    int index = 0;
    for (var entry in program.functionTable.entries) {
      functionsPointers[index] = offset;
      var data = FunctionFlowchartData(entry.value, offset);
      offset += data.combinedData.buffer.lengthInBytes;

      functionsData.add(data);
      index += 1;
    }

    hashDigest = hashFunction.convert(prefix +
        functionsCount.buffer.asUint8List() +
        functionsPointers.buffer.asUint8List() +
        mainElementPointer.buffer.asUint8List() +
        fillerDigest.buffer.asUint8List() +
        elementsData +
        functionsData.map<Uint8List>((e) => e.combinedData).reduce((value, element) => Uint8List.fromList(value + element))
    );
  }

  Future<void> saveToFile(File file) async {
    IOSink sink = file.openWrite();

    try {
      sink.add(prefix);
      sink.add(functionsCount.buffer.asUint8List());
      sink.add(functionsPointers.buffer.asUint8List());
      sink.add(mainElementPointer.buffer.asUint8List());
      sink.add(hashDigest.bytes);
      sink.add(elementsData);
      sink.add(functionsData.map<Uint8List>((e) => e.combinedData).reduce((value, element) => Uint8List.fromList(value + element)));

      await sink.flush();
    }
    catch (e) {
      throw Exception("Unexpected error while writing save file, $e");
    }
    finally {
      await sink.close();
    }
  }
}
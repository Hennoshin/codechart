import 'dart:convert';
import 'dart:typed_data';
import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/element_factory.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/utility/file_io_service.dart';
import 'package:crypto/crypto.dart';

import 'package:collection/collection.dart';

import '../flowchart_editor/models/function_flowchart.dart';

mixin FlowchartElementsData {
  static const encoder = utf8;
  late Uint8List elementsData;

  void setElementDataFromBytes(Uint8List data, int offset, [int? sizeInBytes]) {
    elementsData = data.sublist(offset, sizeInBytes == null ? null : offset + sizeInBytes).buffer.asUint8List();
  }

  void setElementDataFromMap(Map<String, BaseElement> elements) {
    String jsonString = jsonEncode({
      "elements": [
        for (var entry in elements.entries)
          {"index": entry.key, "element": entry.value}
      ]
    });

    elementsData = Uint8List.fromList(encoder.encode(jsonString));
  }

  Map<String, BaseElement> getElementsMapObject() {
    ElementFactory factory = ElementFactory.instance;

    String jsonString = encoder.decode(elementsData, allowMalformed: false);
    Map<String, dynamic> json = jsonDecode(jsonString);

    List elements = json["elements"] as List;
    return {
      for (var entry in elements)
        entry["index"]: factory.createElementFromJson(entry["element"] as Map<String, dynamic>)
    };
  }

  Map<String, dynamic> getElementsJson() {
    String jsonString = encoder.decode(elementsData, allowMalformed: false);

    return jsonDecode(jsonString);
  }
}

class FunctionFlowchartData with FlowchartElementsData {
  late Uint32List returnType;
  late Uint32List numberOfParams;
  late Uint64List startPointer;
  late Uint8List functionName;
  late Uint8List returnExpression;
  late Uint8List params;

  FunctionFlowchartData.fromBytes(Uint8List data, int currentOffset, int? sizeInBytes) {
    int originalOffset = currentOffset;

    returnType = data.sublist(currentOffset, currentOffset + 4).buffer.asUint32List();
    currentOffset += returnType.lengthInBytes;

    numberOfParams = data.sublist(currentOffset, currentOffset + 4).buffer.asUint32List();
    currentOffset += numberOfParams.lengthInBytes;

    startPointer = data.sublist(currentOffset, currentOffset + 8).buffer.asUint64List();
    currentOffset += startPointer.lengthInBytes;

    List<int> temp = [];

    while (data[currentOffset] != 0) {
      temp.add(data[currentOffset]);
      currentOffset += 1;
    }
    temp.add(data[currentOffset]);
    currentOffset += 1;

    functionName = Uint8List.fromList(temp);

    temp.clear();
    while (data[currentOffset] != 0) {
      temp.add(data[currentOffset]);
      currentOffset += 1;
    }
    temp.add(data[currentOffset]);
    currentOffset += 1;

    returnExpression = Uint8List.fromList(temp);

    params = data.sublist(currentOffset, startPointer[0]);
    currentOffset += params.lengthInBytes;

    int? size = sizeInBytes == null ? null : sizeInBytes - (currentOffset - originalOffset);
    setElementDataFromBytes(data, currentOffset, size);
  }

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

  FunctionFlowchart createFunctionFlowchartFromSave() {
    String name = ascii.decode(functionName.toList()..removeLast());
    FunctionFlowchart functionFlowchart = FunctionFlowchart(name);

    DataType? type = returnType[0] == 0xffffffff ? null : DataType.values[returnType[0]];
    functionFlowchart.returnType = type;

    functionFlowchart.returnExpression = ascii.decode(returnExpression.toList()..removeLast());

    List<dynamic> jsonParam = jsonDecode(utf8.decode(params, allowMalformed: false))["parameters"];
    for (int i = 0; i < numberOfParams[0]; i += 1) {
      functionFlowchart.addFunctionParameter(jsonParam[i]["name"], DataType.values[jsonParam[i]["type"]], jsonParam[i]["isArray"]);
    }

    functionFlowchart.setElementsMap(getElementsMapObject());

    return functionFlowchart;
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
  static const String fileNamePrefix = ".ccv";
  static final Uint8List prefix = ascii.encode("CCV\u0000");
  static const Hash hashFunction = md5;
  static const int hashDigestSize = 16;

  final String programName;
  late Uint32List functionsCount;
  late Uint64List functionsPointers;
  late Uint64List mainElementPointer;
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
        functionsDataBuffer
    );

  }

  FlowchartProgramSaveFile.fromFile(this.programName, Uint8List data) {
    DeepCollectionEquality equality = const DeepCollectionEquality();

    int offset = 0;
    Uint8List prefixByte = data.buffer.asUint8List(0, 4);
    if (equality.equals(prefix, prefixByte)) throw Exception("Invalid file loaded, signature is missing");
    offset += prefixByte.length;

    functionsCount = data.sublist(offset, offset + 4).buffer.asUint32List();
    offset += functionsCount.lengthInBytes;

    functionsPointers = data.sublist(offset, offset + functionsCount[0] * 8).buffer.asUint64List();
    offset += functionsPointers.lengthInBytes;

    mainElementPointer = data.sublist(offset, offset + 8).buffer.asUint64List();
    offset += mainElementPointer.lengthInBytes;

    hashDigest = Digest(data.sublist(offset, offset + hashDigestSize));
    offset += hashDigestSize;

    int? size = functionsCount[0] > 0 ? functionsPointers[0] - offset : null;
    setElementDataFromBytes(data, offset, size);

    for (int i = 0; i < functionsCount[0]; i += 1) {
      offset = functionsPointers[i];
      size = (i + 1) < functionsCount[0] ? functionsPointers[i + 1] - functionsPointers[i] : null;
      FunctionFlowchartData flowchartData = FunctionFlowchartData.fromBytes(data, offset, size);

      functionsData.add(flowchartData);
    }

  }

  Future<void> saveCurrentProgram() async {
    FileIOService service = FileIOService.instance;
    bool result = await service.saveToFile(fileName: programName + fileNamePrefix, bytes: buffer);

    if (!result) throw Exception("Failed to save file, unknown error");
  }

  FlowchartProgram createProgramFromSave() {
    Flowchart mainFlowchart = Flowchart("Main");
    mainFlowchart.setElementsMap(getElementsMapObject());
    FlowchartProgram program = FlowchartProgram.create(programName, mainFlowchart);

    for (int i = 0; i < functionsCount[0]; i += 1) {
      var function = functionsData[i].createFunctionFlowchartFromSave();
      program.addFunction(function.name, function);
    }

    return program;
  }

  String get fullProgramName => programName + fileNamePrefix;

  Uint8List get buffer => Uint8List.fromList(prefix +
      functionsCount.buffer.asUint8List() +
      functionsPointers.buffer.asUint8List() +
      mainElementPointer.buffer.asUint8List() +
      hashDigest.bytes +
      elementsData +
      functionsDataBuffer
  );

  Uint8List get functionsDataBuffer => functionsData.isNotEmpty ?
  functionsData.map<Uint8List>((e) => e.combinedData).
  reduce((value, element) => Uint8List.fromList(value + element)) :
  Uint8List(0);
}
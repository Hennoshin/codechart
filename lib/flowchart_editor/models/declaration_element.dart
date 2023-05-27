import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/execution_environment/memory.dart';
import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/utility/data_classes.dart';

class DeclarationElement extends BaseElement {
  bool _isArray;
  DataType _type;
  int? arraySize;
  DeclarationElement(super.baseExpr, this._isArray, this._type);

  @override
  BaseElement evaluate(Memory stack, List<ASTNode> exprs) {
    String expr = baseExpr!;
    Function addVar = stack.addNewVariables;

    switch (_type) {
      case DataType.integer:
        addVar<int>(expr, _isArray, arraySize);
        break;

      case DataType.real:
        addVar<double>(expr, _isArray, arraySize);
        break;

      case DataType.boolean:
        addVar<bool>(expr, _isArray, arraySize);
        break;

      case DataType.string:
        addVar<String>(expr, _isArray, arraySize);
        break;

      default:
        assert(false, "Unexpected error when adding variables, this should not happen. Unexpected variable type.");
    }

    return nextElement;
  }

  @override
  List<String?> get exprList => [];
  DataType get varType => _type;
  bool get isArray => _isArray;

  set isArray(arr) => _isArray = arr;
  set varType(tp) => _type = tp;

  /// Set properties for the assignment element
  /// First [properties] accepts [String] as the variable expression
  /// Second [properties] accepts [DataType] as the variable type
  /// Third [properties] accepts [bool] as the flag whether the variable is array or not
  /// Fourth [properties] accepts [int] as the array size, must be present if array
  @override
  void setProperties(List<dynamic> properties) {
    if (properties.length != 3 && properties.length != 4) {
      throw Exception("Unexpected number of properties for this element, expected at least 3 and no more than 4, got ${properties.length} instead");
    }
    if (properties[0] is! String) {
      throw Exception("Expected String for the first properties");
    }
    if (properties[1] is! DataType) {
      throw Exception("Expected DataType for the second properties");
    }
    if (properties[2] is! bool) {
      throw Exception("Expected bool for the third properties");
    }

    baseExpr = properties[0];
    varType = properties[1];
    isArray = properties[2];

    if (!isArray) return;

    if (properties.length != 4) {
      throw Exception("Expected array size properties");
    }
    if (properties[3] is! int) {
      throw Exception("Expected int for array size properties");
    }

    arraySize = properties[3];
  }

  @override
  String toString() {
    return baseExpr ?? "Declaration";
  }
}
import "data_types.dart";

class Memory {
  String stackName;
  Map<String, Wrapper> variables;
  Map<String, dynamic> hiddenVariables;

  Memory(this.stackName) : variables = {}, hiddenVariables = {};

  void addNewVariables<T>(String name, [bool isArray = false, int? size]) {
    if (variables.containsKey(name)) {
      throw Exception("Variable has been declared");
    }

    variables[name] = (isArray ? ListWrapper<T>(size!) : Wrapper<T>()) as Wrapper;
  }

  Wrapper? getData(String name) {
    return variables[name];
  }

  Wrapper getArrayData(String name, int index) {
    Wrapper data = variables[name]!;
    if (data is! ListWrapper) {
      throw Exception("Invalid data type. The variable must be an array");
    }

    return (data.value!)[index];
  }

  /*
  void assignDataByName(String name, Wrapper data) {
    if (!variables.containsKey(name)) {
      throw Exception("Variable does not exist");
    }
    if (variables[name]!.value.runtimeType != data.value.runtimeType) {
      throw Exception("Mismatch in data type");
    }

    variables[name] = data;
  }
   */

  /*
   * Assign data to a variable. The destination must be a Wrapper (variable reference)
   * TODO: Consider changing the source to include exposed variable value (i.e. literals)
   */
  void assignDataByReference(Wrapper dst, Wrapper src) {
    if (src.value == null) {
      throw Exception("Variable source is not initialized");
    }

    dst.value = src.value;
  }

  void assignVariable(Wrapper dst, dynamic src) {
    dynamic value = src;
    if (src is Wrapper) {
      value = src.value;
    }

    if (value == null) {
      throw Exception("Variable assignment source is invalid. Cannot assign variable to uninitialized value");
    }
    if (dst.type != value.runtimeType) {
      throw Exception("Invalid variable assignment. Variable must be the same type. Trying to assign ${value.runtimeType} to ${dst.type}");
    }
    dst.value = value;
  }

  dynamic getHiddenData(String name) {
    return hiddenVariables[name];
  }
  void setHiddenData(String name, dynamic object) {
    hiddenVariables[name] = object;
  }
}
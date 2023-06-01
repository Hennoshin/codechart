import 'package:code_chart/flowchart_editor/execution_environment/execution_environment.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/merging_element.dart';
import 'package:code_chart/flowchart_editor/models/terminal_element.dart';
import "base_element.dart";

class Flowchart {
  List<BaseElement> elements = [];
  Map<String, BaseElement> elements2 = {};

  Flowchart(String? startPlaceholder) {
    BaseElement start = TerminalElement.start(startPlaceholder);
    BaseElement end = TerminalElement.end("End");
    start.nextElement = end;
    end.nextElement = end;

    elements.add(start);
    elements.add(end);

    elements2["0"] = start;
    elements2["1"] = end;
  }

  void fullReindex() {
    var start = elements2["0"]!;
    elements2.clear();
    _reindex(start);
  }

  // TODO: Add support to accept [index] parameter to reindex for that point instead of from the beginning
  void _reindex(BaseElement start, [String prefix = "", MergingElement? mergeBranch]) {
    int index = 0;
    BaseElement currentEl = start;
    BaseElement? prevEl;
    if (prefix != "") {
      index += 1;
    }
    while (prevEl != currentEl && currentEl != mergeBranch) {
      elements2[prefix + index.toString()] = currentEl;

      if (currentEl is BranchingElement) {
        _reindex(currentEl.trueBranchNextElement, "$prefix$index.0.", currentEl.mergePoint);
        _reindex(currentEl.falseBranchNextElement, "$prefix$index.1.", currentEl.mergePoint);
      }

      prevEl = currentEl;
      currentEl = currentEl.nextElement;
      index += 1;
    }
  }

  void addElement2(BaseElement newElement, String targetLocation) {
    List<int> indexes = targetLocation.split(".").map((e) => int.parse(e)).toList();
    int index = indexes.removeLast();
    int prevIndex = index - 1;
    int? branch;
    if (indexes.isNotEmpty) {
      branch = indexes.removeLast();
    }

    // Calculate previous element index before the current target
    String indexString = index.toString();
    String prevIndexString = prevIndex.toString();
    String prevTarget = targetLocation.replaceRange(targetLocation.length - indexString.length, null, prevIndexString);
    if (prevIndex == 0 && targetLocation.contains(".")) {
      prevTarget = prevTarget.substring(0, prevTarget.length - 4);
    }

    BaseElement prevElement = elements2[prevTarget]!;
    if (prevIndex == 0 && targetLocation.contains(".")) {
      if (branch! == 0) {
        newElement.nextElement = (prevElement as BranchingElement).trueBranchNextElement;
        prevElement.trueBranchNextElement = newElement;
      }
      else {
        newElement.nextElement = (prevElement as BranchingElement).falseBranchNextElement;
        prevElement.falseBranchNextElement = newElement;
      }
    }
    else {
      newElement.nextElement = prevElement.nextElement;
      prevElement.nextElement = newElement;
    }

    fullReindex();
  }

  void _shiftElements(BaseElement newElement, String targetLocation) {
    BaseElement? element = newElement;
    String currentTarget = targetLocation;
    int currentTargetLastIndex = currentTarget.length - 1;
    int index = int.parse(currentTarget.substring(currentTargetLastIndex));
    do {
      var tmpElement = elements2[currentTarget];
      elements2[currentTarget] = element!;
      element = tmpElement;

      index += 1;
      currentTarget = targetLocation.replaceRange(currentTargetLastIndex, null, index.toString());
    } while (element != null);
  }

  void removeElement2(String targetLocation) {
    BaseElement currentElement = elements2[targetLocation]!;

    List<int> indexes = targetLocation.split(".").map((e) => int.parse(e)).toList();
    int index = indexes.removeLast();
    int prevIndex = index - 1;
    int? branch;
    if (indexes.isNotEmpty) {
      branch = indexes.removeLast();
    }

    String indexString = index.toString();
    String prevIndexString = prevIndex.toString();
    String prevTarget = targetLocation.replaceRange(targetLocation.length - indexString.length, null, prevIndexString);
    if (prevIndex == 0 && targetLocation.contains(".")) {
      prevTarget = prevTarget.substring(0, prevTarget.length - 4);
    }

    BaseElement prevElement = elements2[prevTarget]!;
    if (prevIndex == 0 && targetLocation.contains(".")) {
      if (branch! == 0) {
        (prevElement as BranchingElement).trueBranchNextElement = currentElement.nextElement;
      }
      else {
        (prevElement as BranchingElement).falseBranchNextElement = currentElement.nextElement;
      }
    }
    else {
      prevElement.nextElement = currentElement.nextElement;
    }

    fullReindex();
  }

  void _shiftRemoveElements(String targetLocation) {
    BaseElement? element;
    String currentTarget = targetLocation;
    int currentTargetLastIndex = currentTarget.length - 1;
    int index = int.parse(currentTarget.substring(currentTargetLastIndex));

    String target2 = currentTarget.replaceRange(currentTargetLastIndex, null, (index + 1).toString());
    element = elements2[target2];
    while (element != null) {
      elements2[currentTarget] = element;

      index += 1;
      currentTarget = targetLocation.replaceRange(currentTargetLastIndex, null, index.toString());
      target2 = currentTarget.replaceRange(currentTargetLastIndex, null, (index + 1).toString());

      element = elements2[target2];
    }
    elements2.remove(currentTarget);
  }

  void _reindexElements(String locationIndex, String newIndex) {
    elements2.map((key, value) {
      if (key.contains(locationIndex)) {
        return MapEntry(key.replaceRange(0, null, newIndex), value);
      }

      return MapEntry(key, value);
    });
  }

  // The location is indexed like a tree, starts from 0 to n.
  // For branching element, the elements inside the branch is considered sub-tree.
  // Example, if-else element at index 2, next trueElement is 2.0.1, and then 2.0.2; falseElement is 2.1.1
  void addElement(BaseElement element, String targetLocation) {
    BaseElement currentElement = elements.first;
    List<int> indexes = targetLocation.split(".").map((e) => int.parse(e)).toList();

    int index = indexes.removeAt(0);
    int? branch;
    while (true) {
      for (int i = 0; i < index - 1; i += 1) {
        currentElement = _iterateNextElement(currentElement, branch);
        branch = null;
      }

      if (indexes.isEmpty) {
        _setNewNextElement(currentElement, element, branch);
        elements.add(element);
        break;
      }

      currentElement = _iterateNextElement(currentElement, branch);
      branch = indexes.removeAt(0);
      index = indexes.removeAt(0);
    }
  }

  // The location is indexed like a tree, starts from 0 to n.
  // For branching element, the elements inside the branch is considered sub-tree.
  // Example, if-else element at index 2, next trueElement is 2.0.1, and then 2.0.2; falseElement is 2.1.1
  void removeElement(String targetLocation) {
    BaseElement currentElement = elements.first;
    List<int> indexes = targetLocation.split(".").map((e) => int.parse(e)).toList();

    int index = indexes.removeAt(0);
    int? branch;

    if (index <= 0) {
      throw Exception("Invalid index, value must be greater than 0, got $index instead");
    }

    BaseElement prevElement = currentElement;
    int? prevBranch;
    while (true) {
      for (int i = 0; i < index; i += 1) {
        prevElement = currentElement;
        prevBranch = branch;

        currentElement = _iterateNextElement(currentElement, branch);
        branch = null;
      }

      if (indexes.isEmpty) {
        break;
      }
      branch = indexes.removeAt(0);
      index = indexes.removeAt(0);
    }

    _rearrangeElement(prevElement, currentElement.nextElement, prevBranch);
  }

  void _rearrangeElement(BaseElement cur, BaseElement nextEl, int? branch) {
    if (branch == null) {
      cur.nextElement = nextEl;

      return;
    }

    cur = cur as BranchingElement;
    if (branch == 0) {
      cur.trueBranchNextElement = nextEl;
    }
    else if (branch == 1) {
      cur.falseBranchNextElement = nextEl;
    }
  }

  void _setNewNextElement(BaseElement cur, BaseElement newEl, int? branch) {
    if (branch == null) {
      var temp = cur.nextElement;
      cur.nextElement = newEl;
      newEl.nextElement = temp;

      return;
    }

    cur = cur as BranchingElement;
    if (branch == 0) {
      var temp = cur.trueBranchNextElement;
      cur.trueBranchNextElement = newEl;
      newEl.nextElement = temp;
    }
    else if (branch == 1) {
      var temp = cur.falseBranchNextElement;
      cur.falseBranchNextElement = newEl;
      newEl.nextElement = temp;
    }
  }

  BaseElement _iterateNextElement(BaseElement cur, int? branch) {
    if (branch == null) {
      var temp = cur.nextElement;

      return temp;
    }

    cur = cur as BranchingElement;
    if (branch == 0) {
      var temp = cur.trueBranchNextElement;
      return temp;
    }
    else {
      var temp = cur.falseBranchNextElement;
      return temp;
    }
  }

  BaseElement get startElement => elements.first;
}
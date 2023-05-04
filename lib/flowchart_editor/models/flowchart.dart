import 'package:code_chart/flowchart_editor/execution_environment/execution_environment.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/terminal_element.dart';
import "base_element.dart";

class Flowchart {
  List<BaseElement> elements = [];

  Flowchart(String? startPlaceholder) {
    BaseElement start = TerminalElement.start(startPlaceholder);
    BaseElement end = TerminalElement.end("End");
    start.nextElement = end;
    end.nextElement = end;

    elements.add(start);
    elements.add(end);
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
import 'branching_element.dart';

class WhileLoopElement extends BranchingElement {
  WhileLoopElement(super.expr);

  @override
  void setDefault() {
    trueBranchNextElement = this;
  }

  @override
  set nextElement(e) {
    super.falseBranchNextElement = e;
    super.nextElement = e;
  }

  @override
  set falseBranchNextElement(e) {
    nextElement = e;
  }
}
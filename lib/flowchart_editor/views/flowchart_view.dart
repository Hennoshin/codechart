import 'package:code_chart/flowchart_editor/models/base_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:code_chart/flowchart_editor/models/while_loop_element.dart';
import 'package:code_chart/flowchart_editor/views/element/element_widget_factory.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tuple/tuple.dart';

import '../models/branching_element.dart';
import '../models/merging_element.dart';
import '../view_models/flowchart_editor_viewmodel.dart';
import '../view_models/flowchart_viewmodel.dart';
import 'element/element_widget.dart';


class _FlowchartLayoutDelegate extends MultiChildLayoutDelegate {
  final Map<String, double> columnsHeight;
  final Map<String, double> relativeOffsets;
  final Map<String, BaseElement> elements;
  final Map<String, ArrowLineType> arrowLines;

  final double elementWidth;
  final double elementHeight;
  final double minArrowHeight;

  _FlowchartLayoutDelegate({
    required this.columnsHeight, required this.relativeOffsets, required this.elements, required this.arrowLines,
    required this.elementHeight, required this.elementWidth, minArrowHeight
  }) : minArrowHeight = minArrowHeight ?? elementHeight;

  Map<String, Offset> getAbsoluteOffsets(Offset absoluteOffset) {
    Map<String, Offset> offsets = {"0": absoluteOffset};

    for (MapEntry entry in relativeOffsets.entries) {
      List<String> lst = entry.key.split(".");
      lst.removeLast();
      lst.removeLast();

      String previousKey = lst.join(".");
      Offset offset = Offset(entry.value + (offsets[previousKey]?.dx ?? absoluteOffset.dx), 0);

      offsets[entry.key] = offset;
    }

    return offsets;
  }

  // TODO: This method has a different recursive method, change it to make it same?
  // TODO: Also refer to [performBranchLayout] recursive method
  @override
  void performLayout(Size size) {
    Offset heightOffset = Offset.zero;
    Offset widthOffsetAnchor = const Offset(500, 0);
    layoutChild("0", BoxConstraints.expand(width: elementWidth, height: elementHeight));
    positionChild("0", heightOffset + widthOffsetAnchor);
    heightOffset += Offset(0, elementHeight);

    Map<String, Offset> absoluteWidthOffsets = getAbsoluteOffsets(widthOffsetAnchor);

    Map<String, ArrowLineType> mainColumnArrows = {
      for (var entry in arrowLines.entries)
        if (entry.key.split(".").length == 1) entry.key: entry.value
    };

    List<String> sortedArrowIndex = mainColumnArrows.keys.toList();
    sortedArrowIndex.sort((index1, index2) => index1.compareTo(index2));
    for (var key in sortedArrowIndex) {
      String currentElementIndex = key.substring(0, key.length - 1);
      layoutChild(key, BoxConstraints.expand(width: elementWidth, height: minArrowHeight));
      positionChild(key, heightOffset + widthOffsetAnchor);
      heightOffset += Offset(0, minArrowHeight);
      
      Size size = performElementLayout(currentElementIndex, heightOffset + widthOffsetAnchor);

      if (elements[currentElementIndex]! is WhileLoopElement) {
        Map<String, ArrowLineType> leftList = {
          for (var entry in arrowLines.entries)
            if (entry.key.startsWith("$currentElementIndex.0")) entry.key: entry.value
        };

        performBranchLayout(
            absoluteWidthOffsets["$currentElementIndex.0"]! + heightOffset,
            Size(relativeOffsets["$currentElementIndex.0"]!.abs(), columnsHeight[currentElementIndex]!),
            leftList,
            "$currentElementIndex.0."
        );
      }
      else if (elements[currentElementIndex]! is BranchingElement) {
        Map<String, ArrowLineType> leftList = {
          for (var entry in arrowLines.entries)
            if (entry.key.startsWith("$currentElementIndex.0")) entry.key: entry.value
        };
        Map<String, ArrowLineType> rigthList = {
          for (var entry in arrowLines.entries)
            if (entry.key.startsWith("$currentElementIndex.1")) entry.key: entry.value
        };

        performBranchLayout(
            absoluteWidthOffsets["$currentElementIndex.0"]! + heightOffset,
            Size(relativeOffsets["$currentElementIndex.0"]!.abs(), columnsHeight[currentElementIndex]!),
            leftList,
            "$currentElementIndex.0."
        );
        performBranchLayout(
            absoluteWidthOffsets["$currentElementIndex.1"]! + heightOffset,
            Size(relativeOffsets["$currentElementIndex.1"]!.abs(), columnsHeight[currentElementIndex]!),
            rigthList,
            "$currentElementIndex.1."
        );
      }

      heightOffset += Offset(0, size.height);
    }

  }

  // The variable branchSize is misleading, the width represents the distance between current branch to its parent
  void performBranchLayout(Offset branchAbsoluteOffset, Size branchSize, Map<String, ArrowLineType> arrowList, String prefix) {
    int branch = int.parse(prefix.substring(prefix.length - 2, prefix.length - 1));
    double heightCounter = 0.0;
    int index = 1;
    String currentElementIndex = prefix + index.toString();
    String currentIndex = "$prefix${index}e";

    Offset rightOffset = Offset.zero;
    if (arrowList[currentIndex] == ArrowLineType.branchEmptyLeft || arrowList[currentIndex] == ArrowLineType.branchEmptyRight) {
      layoutChild(currentIndex, BoxConstraints.expand(width: branchSize.width, height: branchSize.height));
    } else {
      layoutChild(currentIndex, BoxConstraints.expand(width: branchSize.width, height: minArrowHeight));

      if (branch == 1) {
        rightOffset = Offset(branchSize.width - 100, 0);
      }
    }
    positionChild(currentIndex, branchAbsoluteOffset - rightOffset);

    arrowList.remove(currentIndex);
    branchAbsoluteOffset += Offset(0, minArrowHeight);
    heightCounter += minArrowHeight;
    index += 1;

    while (arrowList.isNotEmpty) {
      rightOffset = Offset.zero;

      currentIndex = "$prefix${index}e";
      currentElementIndex = prefix + (index - 1).toString();

      print(arrowList);
      Size size = performElementLayout(currentElementIndex, branchAbsoluteOffset);
      print(currentElementIndex);

      if (elements[currentElementIndex]! is WhileLoopElement) {
        Map<String, ArrowLineType> leftList = {
          for (var entry in arrowList.entries)
            if (entry.key.startsWith("$currentElementIndex.0")) entry.key: entry.value
        };

        performBranchLayout(
            Offset(relativeOffsets["$currentElementIndex.0"]!, 0) + branchAbsoluteOffset,
            Size(relativeOffsets["$currentElementIndex.0"]!.abs(), columnsHeight[currentElementIndex]!),
            leftList,
            "$currentElementIndex.0."
        );

        arrowList.removeWhere((key, value) => key.startsWith("$currentElementIndex."));
      }
      else if (elements[currentElementIndex]! is BranchingElement) {
        Map<String, ArrowLineType> leftList = {
          for (var entry in arrowList.entries)
            if (entry.key.startsWith("$currentElementIndex.0")) entry.key: entry.value
        };
        Map<String, ArrowLineType> rightist = {
          for (var entry in arrowList.entries)
            if (entry.key.startsWith("$currentElementIndex.1")) entry.key: entry.value
        };

        performBranchLayout(
            Offset(relativeOffsets["$currentElementIndex.0"]!, 0) + branchAbsoluteOffset,
            Size(relativeOffsets["$currentElementIndex.0"]!.abs(), columnsHeight[currentElementIndex]!),
            leftList,
            "$currentElementIndex.0."
        );
        performBranchLayout(
            Offset(relativeOffsets["$currentElementIndex.1"]!, 0) + branchAbsoluteOffset,
            Size(relativeOffsets["$currentElementIndex.1"]!.abs(), columnsHeight[currentElementIndex]!),
            rightist,
            "$currentElementIndex.1."
        );

        arrowList.removeWhere((key, value) => key.startsWith("$currentElementIndex."));
      }

      branchAbsoluteOffset += Offset(0, size.height);
      heightCounter += size.height;

      print(index);

      if (arrowList[currentIndex] == ArrowLineType.straight) {
        size = layoutChild(currentIndex, BoxConstraints.expand(width: elementWidth, height: minArrowHeight));
      }
      else {
        double remHeight = branchSize.height - heightCounter;
        size = layoutChild(currentIndex, BoxConstraints.expand(width: branchSize.width, height: remHeight));

        if (branch == 1) {
          rightOffset = Offset(branchSize.width - 100, 0);
        }
      }
      positionChild(currentIndex, branchAbsoluteOffset - rightOffset);

      branchAbsoluteOffset += Offset(0, size.height);
      heightCounter += size.height;
      index += 1;
      arrowList.remove(currentIndex);
    }
  }

  Size performElementLayout(String currentIndex, Offset offset) {
    Size size;

    print(currentIndex);
    print(elements[currentIndex] ?? "Null");

    if (elements[currentIndex]! is! BranchingElement) {
      size = layoutChild(currentIndex, BoxConstraints.expand(width: elementWidth, height: elementHeight));
    }
    else {
      size = layoutChild(currentIndex, BoxConstraints.expand(width: elementWidth, height: columnsHeight[currentIndex]!));
    }

    positionChild(currentIndex, offset);
    return size;
  }
  
  @override
  bool shouldRelayout(covariant MultiChildLayoutDelegate oldDelegate) {
    return false;
  }

}

class FlowchartView extends StatelessWidget {
  static const double elementHeight = 50.0;
  static const double elementWidth = 100.0;
  static const double arrowHeight = 50.0;

  final TransformationController transformationController = TransformationController();

  FlowchartView({Key? key}) : super(key: key);

  // TODO: Change it so that it does not rely on recursive, each element is mapped now, figure something out?
  Widget _createFlowchartColumn(BaseElement startElement, [String current = "", bool isBranch = false, MergingElement? endPoint]) {
    BaseElement element = startElement;
    List<Widget> widgets = [];

    int i = 0;
    if (isBranch) {
      i += 1;

      if (current.substring(current.length - 2, current.length - 1) == "0") {
        widgets.add(
          Expanded(
            child: AddWidgetArrowArea(type: ArrowLineType.branchEmptyLeft, positionIndex: current + i.toString()),
          )
        );
      }
      else {
        widgets.add(
          Expanded(
            child: AddWidgetArrowArea(type: ArrowLineType.branchEmptyRight, positionIndex: current + i.toString()),
          )
        );
      }
    }

    while (element.nextElement != element && element != endPoint) {
      if (element is BranchingElement) {
        widgets.add(IntrinsicHeight(
          child: Transform.translate(
            offset: const Offset(-50, 0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _createFlowchartColumn(element.trueBranchNextElement, "$current$i.0.", true, element.mergePoint),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[ElementWidget(positionIndex: current + i.toString()), Container(width: 100, height: 50, color: Colors.lightGreen,)],
                  ),
                  _createFlowchartColumn(element.falseBranchNextElement, "$current$i.1.", true, element.mergePoint)
                ]
            ),
          ),
        ));

      }
      else {
        widgets.add(ElementWidget(positionIndex: current + i.toString()));
      }

      i += 1;
      widgets.add(AddWidgetArrowArea(type: ArrowLineType.straight, positionIndex: current + i.toString()));

      element = element.nextElement;
    }

    if (!isBranch) {
      widgets.add(ElementWidget(positionIndex: current + i.toString()));
    }

    return IntrinsicWidth(
      child: Column(
        children: widgets,
      )
    );

  }


  Widget _createFlowchartView(Flowchart flowchart) {
    Map<String, double> heights = {};
    Map<String, double> relativeOffsets = {};

    List<String> sortedIndex = flowchart.elements2.keys.toList();
    sortedIndex.sort((index1, index2) => index1.compareTo(index2));

    _calculateFlowchartColumnHeight(flowchart.elements2, sortedIndex.toList(), heights);
    _calculateOffset(flowchart.elements2, sortedIndex.toList(), relativeOffsets);

    List<LayoutId> widgets = sortedIndex.map<LayoutId>((e) =>
        LayoutId(
            id: e,
            child: const ElementWidgetFactory().createElementWidget(flowchart.elements2[e]!, e)!
        )
    ).toList();

    widgets += flowchart.elementInsertList.entries.map<LayoutId>((e) =>
        LayoutId(
          id: e.key,
          child: AddWidgetArrowArea(positionIndex: e.key.substring(0, e.key.length - 1), type: e.value),
        )
    ).toList();

    return CustomMultiChildLayout(
      delegate: _FlowchartLayoutDelegate(columnsHeight: heights, relativeOffsets: relativeOffsets,
        elements: flowchart.elements2, arrowLines: flowchart.elementInsertList, elementHeight: elementHeight, elementWidth: elementWidth
      ),
      children: widgets
    );
  }

  double? _calculateFlowchartColumnHeight(Map<String, BaseElement> elements, List<String> elementIds, Map<String, double> heights) {
    double? h;

    while (elementIds.isNotEmpty) {
      h = (h ?? 0) + arrowHeight;
      double currentHeight = h;

      String currentId = elementIds.first;
      BaseElement element = elements[currentId]!;
      if (element is! BranchingElement) {
        h = currentHeight + elementHeight;
      }
      else {
        leftTest(String id) => id.startsWith("$currentId.0");
        rightTest(String id) => id.startsWith("$currentId.1");

        List<String> branchLeftIds = elementIds.where(leftTest).toList();
        List<String> branchRightIds = elementIds.where(rightTest).toList();

        elementIds.removeWhere((id) => id.startsWith("$currentId."));

        double branchLeft = (_calculateFlowchartColumnHeight(elements, branchLeftIds, heights) ?? arrowHeight * 2) + arrowHeight;
        double branchRight = (_calculateFlowchartColumnHeight(elements, branchRightIds, heights) ?? arrowHeight * 2) + arrowHeight;


        double finalHeight = branchLeft > branchRight ? branchLeft : branchRight;
        heights[currentId] = finalHeight;

        h = currentHeight + finalHeight;
      }

      elementIds.removeAt(0);
    }

    return h;
  }

  void _calculateOffset(Map<String, BaseElement> elements, List<String> elementIds, Map<String, double> offsets) {
    Map<String, double> temporaryOffsets = {};

    while (elementIds.isNotEmpty) {
      List<int> indexes = elementIds.first.split(".").map<int>((index) => int.parse(index)).toList();

      BaseElement element = elements[elementIds.first]!;

      if (element is! BranchingElement) {
        elementIds.removeAt(0);
        continue;
      }

      // Element type is 2
      // Set child offset
      offsets["${indexes.join(".")}.0"] = -elementWidth;
      offsets["${indexes.join(".")}.1"] = elementWidth;

      String currentElementIndex = indexes.join(".");
      indexes.removeLast();


      // Set self offset
      bool? isLastLeft;
      while (indexes.isNotEmpty) {
        bool isLeftChild = indexes.last == 0;
        String currentIndex = indexes.join(".");
        double currentTemporaryOffset = temporaryOffsets[currentElementIndex] ?? 0.0;

        if (isLeftChild != (isLastLeft ?? !isLeftChild)) {
          currentTemporaryOffset = (isLeftChild ? -elementWidth : elementWidth) * 2 + currentTemporaryOffset;
        }

        if (currentTemporaryOffset.abs() > offsets[currentIndex]!.abs()) {
          offsets[currentIndex] = currentTemporaryOffset;
        }


        temporaryOffsets[currentElementIndex] = currentTemporaryOffset;
        isLastLeft = isLeftChild;
        indexes.removeLast();

        currentElementIndex = indexes.join(".");
        indexes.removeLast();
      }

      elementIds.removeAt(0);
    }
  }

  @override
  Widget build(BuildContext context) {
    Flowchart flowchart = context.watch<FlowchartViewModel>().flowchart;
    BaseElement startElement = flowchart.startElement;

    return Container(
      child: _createFlowchartView(flowchart),
    );

  }

}


class AddWidgetArrowArea extends StatelessWidget {
  final Size size;
  final ArrowLineType type;
  final String positionIndex;

  const AddWidgetArrowArea({super.key, required this.type, required this.positionIndex, this.size = Size.zero});

  @override
  Widget build(BuildContext context) {
    BoxConstraints constraints = const BoxConstraints(minHeight: 50, minWidth: 50);
    if (type == ArrowLineType.branchEmptyLeft || type == ArrowLineType.branchEmptyRight) {
      constraints = const BoxConstraints(minHeight: 150, minWidth: 50);
    }


    return Container(
      constraints: constraints,
      child: DragTarget<BaseElement>(
        builder: (context, items, rejectedItems) => CustomPaint(
          painter: ArrowLineCustomPainter(type: type),
        ),
        onAccept: (item) {
          BaseElement newElement = item.copyWith();

          context.read<FlowchartViewModel>().addNewElement(newElement, positionIndex);
        },
      ),
    );

    /*
    return DragTarget<BaseElement>(
      builder: (context, items, rejectedItems) => Container(
        constraints: constraints,
        child: CustomPaint(
          painter: ArrowLineCustomPainter(type: type),
        ),
      ),
      onAccept: (item) {
        BaseElement newElement = item.copyWith();
        context.read<FlowchartViewModel>().addNewElement(newElement, positionIndex);
      },
    );
     */
  }

}

class ArrowLineCustomPainter extends CustomPainter {
  final ArrowLineType type;

  const ArrowLineCustomPainter({required this.type});

  @override
  void paint(Canvas canvas, Size size) {
    Path path = Path();
    List<Offset> points = [];

    switch (type) {
      case ArrowLineType.straight:
        points = [
          Offset(size.width / 2 - 5, 0),
          Offset(size.width / 2 - 5, size.height - 10),
          Offset(10, size.height - 10),
          Offset(size.width / 2, size.height),
          Offset(size.width - 10, size.height - 10),
          Offset(size.width / 2 + 5, size.height - 10),
          Offset(size.width / 2 + 5, 0)
        ];
        break;

      case ArrowLineType.branchEmptyLeft:
        points = [
          Offset(size.width, 0),
          const Offset(0, 0),
          Offset(0, size.height - 20),
          Offset(size.width - 10, size.height - 20),
          Offset(size.width - 10, size.height - 10),
          Offset(size.width, size.height - 25),
          Offset(size.width - 10, size.height - 40),
          Offset(size.width - 10, size.height - 30),
          Offset(10, size.height - 30),
          const Offset(10, 10),
          Offset(size.width, 10),
        ];
        break;

      case ArrowLineType.branchEmptyRight:
        points = [
          const Offset(0, 0),
          Offset(size.width, 0),
          Offset(size.width, size.height - 20),
          Offset(10, size.height - 20),
          Offset(10, size.height - 15),
          Offset(0, size.height - 25),
          Offset(10, size.height - 35),
          Offset(10, size.height - 30),
          Offset(size.width - 10, size.height - 30),
          Offset(size.width - 10, 10),
          const Offset(0, 10),
        ];
        break;

      case ArrowLineType.branchInLeft:
        points = [
          Offset(size.width, 0),
          const Offset(45, 0),
          Offset(45, size.height - 10),
          Offset(40, size.height - 10),
          Offset(50, size.height),
          Offset(60, size.height - 10),
          Offset(55, size.height - 10),
          const Offset(55, 10),
          Offset(size.width, 10),
        ];
        break;
      case ArrowLineType.branchOutLeft:
        points = [
          const Offset(45, 0),
          Offset(45, size.height - 20),
          Offset(size.width - 10, size.height - 20),
          Offset(size.width - 10, size.height - 15),
          Offset(size.width, size.height - 25),
          Offset(size.width - 10, size.height - 35),
          Offset(size.width - 10, size.height - 30),
          Offset(55, size.height - 30),
          const Offset(55, 0)
        ];
        break;
      case ArrowLineType.branchInRight:
        points = [
          const Offset(0, 0),
          Offset(size.width - 45, 0),
          Offset(size.width - 45, size.height - 10),
          Offset(size.width - 40, size.height - 10),
          Offset(size.width - 50, size.height),
          Offset(size.width - 60, size.height - 10),
          Offset(size.width - 55, size.height - 10),
          Offset(size.width - 55, 10),
          const Offset(0, 10),
        ];
        break;
      case ArrowLineType.branchOutRight:
        points = [
          Offset(size.width - 45, 0),
          Offset(size.width - 45, size.height - 20),
          Offset(10, size.height - 20),
          Offset(10, size.height - 15),
          Offset(0, size.height - 25),
          Offset(10, size.height - 35),
          Offset(10, size.height - 30),
          Offset(size.width - 55, size.height - 30),
          Offset(size.width - 55, 0)
        ];
        break;
    }

    path.addPolygon(points, true);
    canvas.drawPath(path, Paint());
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }

}
import 'package:code_chart/commons/routes.dart';
import 'package:code_chart/flowchart_editor/execution_environment/data_types.dart';
import 'package:code_chart/flowchart_editor/execution_environment/execution_environment.dart';
import 'package:code_chart/flowchart_editor/models/assignment_element.dart';
import 'package:code_chart/flowchart_editor/models/branching_element.dart';
import 'package:code_chart/flowchart_editor/models/declaration_element.dart';
import 'package:code_chart/flowchart_editor/models/flowchart.dart';
import 'package:code_chart/flowchart_editor/models/flowchart_program.dart';
import 'package:code_chart/flowchart_editor/models/function_flowchart.dart';
import 'package:flutter/material.dart';
import "package:code_chart/utility/data_classes.dart";
import "package:code_chart/utility/lexer.dart";
import "package:code_chart/utility/parser.dart";

void tokenPrint(List<Token> tokens) {
  for (Token token in tokens) {
    print("(${token.val}, ${token.type.name})");
  }
  print("\n");
}

void recursivePrint(ASTNode node, int level) {
  if (node.children.length <= 2){
    if (node.children.length >= 1) {
      recursivePrint(node.children[0], level + 1);
    }
    print("${node.value}, Level = $level");
    if (node.children.length == 2) {
      recursivePrint(node.children[1], level + 1);
    }
  }
  else {
    print("${node.value}, Level = $level");
    for (ASTNode ch in node.children) {
      recursivePrint(ch, level + 1);
    }
  }
}

void test() {
  var el1 = BranchingElement(null);
  var el2 = BranchingElement(null);
  var el3 = DeclarationElement(null, false, DataType.integer);
  var el4 = DeclarationElement(null, false, DataType.integer);
  var el5 = DeclarationElement(null, false, DataType.integer);

  FlowchartProgram program = FlowchartProgram("Test");
  Flowchart main = program.mainFlowchart;
  main.addElement2(el1, "1");
  main.addElement2(el2, "1.1.1");
  main.addElement2(el3, "1.1.1.0.1");
  main.addElement2(el4, "1");

  for (var entry in main.elements2.entries) {
    print("${entry.key}, ${entry.value.runtimeType}");
  }
}

void main() {
  test();

  /*
  runApp(const MaterialApp(
    initialRoute: "/home",
    onGenerateRoute: pageRouting,
  ));

   */

  /*
  var tokens = Lexer.lex("return+arr2[A - 3 | 4] == ~arr[32] * -+test(5 % 2, test2[4 / +-5], !(+_ro || true))");
  // var tokens = Lexer.lex("test(2, 3, 4)");
  tokenPrint(tokens);

  var ast = Parser.parseRightToLeftS(null, tokens, Parser.opPrecedenceGroup[9]!, List.empty(growable: true), 9);
  print("\n");
  recursivePrint(ast, 1);

  var tokens2 = Lexer.lex("(6 + 3.5) * (5 / 3.5)");
  var ast2 = Parser.parseRightToLeftS(null, tokens2, Parser.opPrecedenceGroup[9]!, [], 9);

   */

  /*
  DeclarationElement el1 = DeclarationElement("testVar", false, DataType.integer);
  AssignmentElement el2 = AssignmentElement("test()", "testVar");
  DeclarationElement el3 = DeclarationElement("var2", false, DataType.integer);
  AssignmentElement el4 = AssignmentElement("12", "var2");
  AssignmentElement el5 = AssignmentElement("test()", "testVar");
  DeclarationElement el6 = DeclarationElement("str", false, DataType.string);
  BranchingElement el7 = BranchingElement("testVar >= 0");
  AssignmentElement el8 = AssignmentElement("\"Positive\"", "str");
  AssignmentElement el9 = AssignmentElement("\"Negative\"", "str");

  Flowchart flow = Flowchart("Main");
  flow.addElement(DeclarationElement("testVar", false, DataType.integer), "1");
  flow.addElement(AssignmentElement("2 * 5 - 15", "testVar"), "2");
  flow.addElement(DeclarationElement("result", false, DataType.string), "3");
  flow.addElement(AssignmentElement("positiveOrNegative(testVar)", "result"), "4");


  FunctionFlowchart func = FunctionFlowchart("positiveOrNegative");
  func.returnType = DataType.string;
  func.argList = [FunctionArg("number", DataType.integer, false)];
  func.addElement(DeclarationElement("result", false, DataType.string), "1");
  func.addElement(BranchingElement("number >= 0"), "2");
  func.addElement(AssignmentElement("\"Positive\"", "result"), "2.0.1");
  func.addElement(AssignmentElement("\"Negative\"", "result"), "2.1.1");

  func.setReturn("result");

  ExecutionEnvironment env = ExecutionEnvironment(flow.startElement, {"positiveOrNegative": func});
  for (int i = 0; i < 11; i += 1) {
    env.stepRunElement();
    print(env.currentElement.expr);
  }

  print("Done");
  print(env.topStack.variables["result"]!.value);

   */
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _counter = 0;

  void _incrementCounter() {
    setState(() {
      // This call to setState tells the Flutter framework that something has
      // changed in this State, which causes it to rerun the build method below
      // so that the display can reflect the updated values. If we changed
      // _counter without calling setState(), then the build method would not be
      // called again, and so nothing would appear to happen.
      _counter++;
    });
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text(
              'You have pushed the button this many times:',
            ),
            Text(
              '$_counter',
              style: Theme.of(context).textTheme.headline4,
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _incrementCounter,
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

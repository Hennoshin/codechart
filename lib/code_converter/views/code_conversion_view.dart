import 'package:code_chart/code_converter/view_models/code_conversion_viewmodel.dart';
import 'package:code_chart/commons/error_dialog.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CodeConversionView extends StatelessWidget {
  const CodeConversionView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text("Code Conversion"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.upload_file),
            onPressed: () async {
              try {
                await context.read<CodeConversionViewModel>().saveCode();
              }
              catch (e) {
                showDialog(context: context, builder: (_) => ErrorDialog(title: "Unable to save file", content: e.toString()));
              }
            },
          )
        ],
      ),
      body: Container(
        margin: const EdgeInsets.only(left: 10, right: 10),
        child: SingleChildScrollView(
          child: Consumer<CodeConversionViewModel>(
            builder: (_, vm, __) => Text(vm.rawCodes),
          ),
        ),
      ),
    );
  }

}
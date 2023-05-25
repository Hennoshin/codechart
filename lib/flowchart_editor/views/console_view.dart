import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../view_models/console_viewmodel.dart';

class ConsoleView extends StatelessWidget {
  const ConsoleView({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1000,
      width: 500,
      child: Consumer<ConsoleViewModel>(
        builder: (_, consoleViewModel, __) =>
            ListView.builder(
                itemCount: consoleViewModel.outputBuffer.length,
                itemBuilder: (context, index) => Container(
                  height: 750,
                  width: 450,
                  child: Text(consoleViewModel.outputBuffer[index]),
                )
            )
      ),
    );
  }

}
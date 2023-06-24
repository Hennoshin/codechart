import 'package:flutter/material.dart';

mixin ErrorReportingViewModel on ChangeNotifier{
  String? lastError;

  void registerError(String error) {
    lastError = error;
  }

  void registerAndNotifyError(String error) {
    lastError = error;

    notifyListeners();
  }

  void clear() {
    lastError = null;
  }

  void clearErrorAndNotify() {
    lastError = null;

    notifyListeners();
  }

  bool get hasError => lastError != null;
}
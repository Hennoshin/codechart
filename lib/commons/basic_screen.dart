import 'package:flutter/material.dart';

abstract class BasicScreen extends StatelessWidget {
  final RouteSettings settings;

  const BasicScreen({super.key, required this.settings});
}
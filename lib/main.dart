import 'package:flutter/material.dart';
import 'bootstrap.dart';
import 'injection.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencies();
  runApp(const QuiGestorApp());
}

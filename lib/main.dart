import 'package:flutter/widgets.dart';
import 'package:soupbag/app/app.dart';
import 'package:soupbag/bootstrap/bootstrap.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await bootstrapApplication();
  runApp(const SoupbagApp());
}

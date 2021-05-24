import 'package:flutter/material.dart';
import 'package:todo/db/todo_provider.dart';
import 'package:todo/screens/home_screen.dart';
import 'package:get/get.dart';
import 'package:flutter/widgets.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  TodoProvider todoProvider = TodoProvider();
  await todoProvider.open();
  Get.put(todoProvider);
  runApp(App());
}

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Simple Todo',
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.teal,
        splashFactory: InkRipple.splashFactory,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.teal,
        splashFactory: InkRipple.splashFactory,
        /* dark theme settings */
      ),
      themeMode: ThemeMode.system,
      home: HomeScreen(title: 'Simple Todo'),
    );
  }
}

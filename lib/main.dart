import 'package:flutter/material.dart';
import 'screens/shopping_list_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Продвинутый список покупок',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: ShoppingListScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
import 'package:flutter/material.dart';
import 'widgets/grocery_list.dart';

void main() {
  runApp(const Shop());
}

class Shop extends StatelessWidget {
  const Shop({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title:'shop',
      theme: ThemeData.dark().copyWith(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark
        ),
        useMaterial3: true
      ),
      
      home: const GroceryList(),
      );
  }
}
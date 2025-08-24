import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shop/data/categories.dart';
import 'package:shop/models/category.dart';
import 'package:shop/models/grocery_item.dart';
import 'package:shop/widgets/new_item.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;

class GroceryList extends StatefulWidget {
  const GroceryList({super.key});

  @override
  State<GroceryList> createState() => _GroceryListState();
}

class _GroceryListState extends State<GroceryList> {
  List<GroceryItem> _groceryItems = [];
  bool _isLoading = true;

  Future<void> _loadData() async {
    final url = Uri.parse(
        'https://shop-deed3-default-rtdb.firebaseio.com/items.json');
    final http.Response res = await http.get(url);

    if (res.body == "null") {
      setState(() {
        _isLoading = false;
      });
      return;
    }

    final Map<String, dynamic> loadedData = json.decode(res.body);
    final List<GroceryItem> temp = [];

    for (var item in loadedData.entries) {
      final Category cat = categories.entries
          .firstWhere(
              (element) => element.value.title == item.value['category'])
          .value;

      temp.add(GroceryItem(
        id: item.key,
        name: item.value['name'],
        quantity: item.value['quantity'],
        category: cat,
      ));
    }

    setState(() {
      _groceryItems = temp;
      _isLoading = false;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _addItem() async {
    final newItem = await Navigator.of(context).push<GroceryItem>(
      MaterialPageRoute(
        builder: (context) => const NewItem(),
      ),
    );

    if (newItem != null) {
      setState(() {
        _groceryItems.add(newItem);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget content;

    if (_isLoading) {
      content = const Center(child: CircularProgressIndicator());
    } 
    else if (_groceryItems.isEmpty) {
      content = const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.shopping_cart_outlined,
              size: 80,
              color: Colors.white24,
            ),
            SizedBox(height: 16),
            Text(
              'No items yet.\nStart adding!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          ],
        ),
      );
    } 
    else {
      content = ListView.builder(
        itemCount: _groceryItems.length,
        itemBuilder: (ctx, index) => Card(
          color: Colors.grey.shade900,
          margin: const EdgeInsets.symmetric(
            vertical: 6,
            horizontal: 12,
          ),
          elevation: 2,
          child: Dismissible(
            key: ValueKey(_groceryItems[index].id),
            direction: DismissDirection.endToStart,
            background: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            onDismissed: (_) {
              final deletedItem = _groceryItems[index];
              setState(() {
                _groceryItems.removeAt(index);
              });

              final url = Uri.parse(
                  'https://shop-deed3-default-rtdb.firebaseio.com/items/${deletedItem.id}.json');
              http.delete(url);

              ScaffoldMessenger.of(context).clearSnackBars();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Item removed Successfully!',
                    style: const TextStyle(color: Colors.black),
                  ),
                  duration: const Duration(seconds: 2),
                  action: SnackBarAction(
                    label: 'Undo',
                    textColor: Colors.black,
                    onPressed: () {
                      setState(() {
                        _groceryItems.insert(index, deletedItem);
                      });
                    },
                  ),
                ),
              );
            },
            child: ListTile(
              title: Text(
                _groceryItems[index].name,
                style: const TextStyle(color: Colors.white),
              ),
              leading: Container(
                width: 24,
                height: 24,
                color: _groceryItems[index].category.color,
              ),
              trailing: Text(
                _groceryItems[index].quantity.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 4,
        title: Text(
          'Grocery List',
          style: GoogleFonts.macondo(
            textStyle: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        backgroundColor: Colors.blueGrey,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(4),
          ),
        ),
        actions: [
          IconButton(
            onPressed: _addItem,
            icon: const Icon(Icons.add, color: Colors.white),
          )
        ],
      ),
      body: content,
    );
  }
}

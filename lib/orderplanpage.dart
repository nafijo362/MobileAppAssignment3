import 'package:flutter/material.dart';
import 'database_helper.dart';

class OrderPlanPage extends StatefulWidget {
  @override
  _OrderPlanPageState createState() => _OrderPlanPageState();
}

class _OrderPlanPageState extends State<OrderPlanPage> {
  List<Map<String, dynamic>> _foodItems = [];
  Set<String> _selectedFoodItems = Set();

  // Fetch food items from the database when the page is loaded
  @override
  void initState() {
    super.initState();
    _fetchFoodItems();
  }

  // Fetch the list of food items from the database
  Future<void> _fetchFoodItems() async {
    var foodItems = await DatabaseHelper.instance.queryAllFood();
    setState(() {
      _foodItems = foodItems;
    });
  }

  // Add food item to the selected list
  void _addFoodItem(String name, double cost) {
    setState(() {
      _selectedFoodItems.add(name);
    });
  }

  // Remove food item from the selected list
  void _removeFoodItem(String name, double cost) {
    setState(() {
      _selectedFoodItems.remove(name);
    });
  }

  // Show the food items in a list of checkboxes
  Widget _buildFoodList() {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: _foodItems.length,
      itemBuilder: (context, index) {
        final food = _foodItems[index];
        return CheckboxListTile(
          title: Text(food['name']),
          subtitle: Text('\$${food['cost']}'),
          value: _selectedFoodItems.contains(food['name']),
          onChanged: (bool? value) {
            if (value == true) {
              _addFoodItem(food['name'], food['cost']);
            } else {
              _removeFoodItem(food['name'], food['cost']);
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Plan'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select food items:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            _foodItems.isEmpty
                ? CircularProgressIndicator()  // Show loading indicator if food items are still being fetched
                : _buildFoodList(),  // Display the food items in a list
            // You can add more widgets or functionality below, like target cost or saving the plan
          ],
        ),
      ),
    );
  }
}

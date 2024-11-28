import 'package:flutter/material.dart';
import 'database_helper.dart'; // Import your DatabaseHelper file

void main() {
  runApp(OrderPlanApp());
}

class OrderPlanApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Order Plan',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: OrderPlanPage(),
    );
  }
}

class OrderPlanPage extends StatefulWidget {
  @override
  _OrderPlanPageState createState() => _OrderPlanPageState();
}

class _OrderPlanPageState extends State<OrderPlanPage> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _targetCostController = TextEditingController();
  TextEditingController _dateController = TextEditingController();
  String _selectedDate = '';
  List<String> _selectedFoodItems = [];
  double _totalCost = 0.0;

  List<Map<String, dynamic>> _foodItems = [];

  @override
  void initState() {
    super.initState();
    _selectedDate = _getFormattedDate(DateTime.now());
    _dateController.text = _selectedDate;
    _loadFoodItems();
  }

  // Convert DateTime to string in yyyy-MM-dd format
  String _getFormattedDate(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  // Load food items from the database
  void _loadFoodItems() async {
    final dbHelper = DatabaseHelper.instance;
    var foods = await dbHelper.queryAllFood();
    setState(() {
      _foodItems = foods;
    });
  }

  // Save the order plan
  void _saveOrderPlan() async {
    if (_formKey.currentState!.validate()) {
      final dbHelper = DatabaseHelper.instance;

      Map<String, dynamic> order = {
        'date': _selectedDate,
        'target_cost': double.parse(_targetCostController.text),
        'food_items': _selectedFoodItems.join(', '),
      };

      await dbHelper.insertOrder(order);

      // Show a confirmation message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Order Plan saved successfully!')),
      );

      // Optionally clear the form
      _targetCostController.clear();
      setState(() {
        _selectedFoodItems.clear();
        _totalCost = 0.0;
      });
    }
  }

  // Add food item to selected list and calculate total cost
  void _addFoodItem(String foodName, double foodCost) {
    setState(() {
      if (!_selectedFoodItems.contains(foodName)) {
        _selectedFoodItems.add(foodName);
        _totalCost += foodCost;
      }
    });
  }

  // Remove food item from selected list and adjust total cost
  void _removeFoodItem(String foodName, double foodCost) {
    setState(() {
      _selectedFoodItems.remove(foodName);
      _totalCost -= foodCost;
    });
  }

  // Show food items as a list of checkboxes
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

  // Show the order plan for a specific date
  void _showOrderPlan() async {
    final dbHelper = DatabaseHelper.instance;
    var orders = await dbHelper.queryOrderByDate(_selectedDate);

    if (orders.isNotEmpty) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Order Plan for $_selectedDate'),
            content: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Target Cost: \$${orders[0]['target_cost']}'),
                SizedBox(height: 10),
                Text('Food Items: ${orders[0]['food_items']}'),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Close'),
              ),
            ],
          );
        },
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No order plan found for this date!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Plan'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: _showOrderPlan,
          ),
        ],
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Select a Date:'),
              SizedBox(height: 8),
              TextField(
                controller: _dateController,
                decoration: InputDecoration(
                  hintText: 'Select a date (yyyy-MM-dd)',
                  border: OutlineInputBorder(),
                ),
                readOnly: true,
                onTap: () async {
                  DateTime? pickedDate = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2101),
                  );

                  if (pickedDate != null) {
                    setState(() {
                      _selectedDate = _getFormattedDate(pickedDate);
                      _dateController.text = _selectedDate;
                    });
                  }
                },
              ),
              SizedBox(height: 16),
              Text('Target Cost per Day:'),
              SizedBox(height: 8),
              TextFormField(
                controller: _targetCostController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: 'Target Cost',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter a target cost';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Please enter a valid number';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              Text('Select Food Items:'),
              SizedBox(height: 8),
              Expanded(child: _buildFoodList()),
              SizedBox(height: 16),
              Text('Total Cost: \$$_totalCost', style: TextStyle(fontSize: 16)),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _saveOrderPlan,
                child: Text('Save Order Plan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:margo/constants/material.dart';
import 'package:http/http.dart' as http;

class StockInPage extends StatefulWidget {
  @override
  State<StockInPage> createState() => _StockInPageState();
}

class _StockInPageState extends State<StockInPage> {
  final _formKey = GlobalKey<FormState>();
  List<Map<String, dynamic>> ingredients = [];
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  List<Map<String, dynamic>> ingredientList = [];
  List<TextEditingController> qtyControllers = [];
  List<TextEditingController> costControllers = [];
  List<TextEditingController> wastageControllers = [];

  double quantity = 0.0;

  var unit = "";

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });
      await fetchIngredientList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchIngredientList() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients/ingredients_list_advanced'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        setState(() {
          ingredientList = fetchedData.map((item) {
            return {
              'id': item['ingredient_id'].toString(),
              'name': item['name'],
              'quantity_unit': item['quantity_unit'] ?? '',
            };
          }).toList();

          ingredientList.sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

  Future<void> _submitStockData() async {
    final payload = _preparePayload();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/inventory/stock_in'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Ingredient added to stock successfully!')),
        );

        Navigator.pop(context, true);
        print('Stock data submitted successfully!');
      } else {
        print('Failed to submit stock data: ${response.body}');
      }
    } catch (e) {
      print('Error submitting stock data: $e');
    }
  }

  void _addIngredient() {
    for (int i = 0; i < ingredients.length; i++) {
      if (!isCurrentIngredientValid(i)) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
                'Please fill all fields in the existing cards before adding a new one.'),
            duration: Duration(seconds: 3),
          ),
        );
        return;
      }
    }
    setState(() {
      ingredients.add({
        "id": "",
        "quantity": quantity,
        "quantity_unit": unit,
      });
      qtyControllers.add(TextEditingController());
    });
  }

  bool isCurrentIngredientValid(int index) {
    return qtyControllers[index].text.isNotEmpty;
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
    });
  }

  Map<String, dynamic> _preparePayload() {
    return {
      "stocks": ingredients.map((ingredient) {
        return {
          "ingredient_id": int.parse(ingredient['id']),
          "quantity": double.parse(
              qtyControllers[ingredients.indexOf(ingredient)].text),
          "quantity_unit": ingredient['quantity_unit'],
        };
      }).toList(),
    };
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: Color.fromRGBO(101, 104, 103, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'Stockin',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Text(
                          'Add Ingredients',
                          style: AppTextStyles.labelBoldFormat,
                        ),
                        const Spacer(),
                        IconButton(
                          icon: const Icon(
                            Icons.add,
                            size: 18,
                            color: AppColors.hintColor,
                          ),
                          onPressed: _addIngredient,
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        List<Map<String, dynamic>> availableIngredients =
                            ingredientList
                                .where((ingredient) => !ingredients.any((e) =>
                                    e['id'] == ingredient['id'] &&
                                    e != ingredients[index]))
                                .toList();

                        return Card(
                          color: Color.fromRGBO(253, 253, 253, 1),
                          elevation: 0,
                          margin: const EdgeInsets.symmetric(vertical: 6.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                            side: BorderSide(
                                color: Color.fromRGBO(231, 231, 231, 1),
                                width: 1),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                buildDropdownIngreField(
                                  'Ingredient Name',
                                  items: availableIngredients,
                                  onChanged: (value) {
                                    setState(() {
                                      final selectedIngredient =
                                          ingredientList.firstWhere(
                                        (ingredient) =>
                                            ingredient['id'] == value,
                                        orElse: () => {},
                                      );
                                      ingredients[index]["id"] = value ?? '';
                                      ingredients[index]["quantity_unit"] =
                                          selectedIngredient['quantity_unit'] ??
                                              '';
                                    });
                                    // widget.onIngredientsChange(ingredients);
                                  },
                                ),
                                const SizedBox(height: 8),
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Quantity',
                                      style: AppTextStyles.labelFormat,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: SizedBox(
                                            // width: 120.0,
                                            height: 40,
                                            child: TextFormField(
                                              controller: qtyControllers[index],
                                              keyboardType: TextInputType
                                                  .numberWithOptions(
                                                      decimal: true),
                                              // onChanged: (_) =>
                                              //     _onQuantityChanged(index),
                                              decoration: InputDecoration(
                                                hintText: 'Enter Quantity',
                                                hintStyle:
                                                    AppTextStyles.hintFormat,
                                                border: OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                ),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 8.0),
                                              ),
                                              textInputAction:
                                                  TextInputAction.done,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 10),
                                        Expanded(
                                          child: SizedBox(
                                            height: 40,
                                            child: TextFormField(
                                              controller: TextEditingController(
                                                text: ingredients[index]
                                                    ["quantity_unit"],
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              decoration: InputDecoration(
                                                hintText: 'Unit',
                                                hintStyle:
                                                    AppTextStyles.hintFormat,
                                                border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8)),
                                                contentPadding:
                                                    const EdgeInsets.symmetric(
                                                        vertical: 4.0,
                                                        horizontal: 8.0),
                                                errorStyle:
                                                    const TextStyle(height: 0),
                                                fillColor: Color.fromRGBO(
                                                    231, 231, 231, 1),
                                                filled: true,
                                              ),
                                              onSaved: (value) {
                                                ingredients[index]
                                                    ["quantity_unit"] = value;
                                              },
                                              onChanged: null,
                                              enabled: false,
                                            ),
                                          ),
                                        )
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const SizedBox(height: 16),
                                TextButton(
                                  onPressed: () => removeIngredient(index),
                                  child: const Text('Delete Ingredient',
                                      style: AppTextStyles.deleteFormat),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                onPressed:
                    //() {
                    // if (_formKey.currentState?.validate() ?? false) {
                    _submitStockData,
                // }
                //},
                style: AppStyles.elevatedButtonStyle,
                child: const Text(
                  'Save',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildDropdownIngreField(String label,
      {required List<Map<String, dynamic>> items,
      required Function(dynamic value) onChanged}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: AppTextStyles.labelFormat,
            children: [
              if (label.contains('*'))
                const TextSpan(
                  text: ' *',
                  style: TextStyle(
                    color: Colors.red,
                    fontSize: 16.0,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 330, // Fixed width of 353px
          height: 40,

          child: DropdownButtonFormField<String>(
            isExpanded: true,
            hint: Text(
              'Select $label',
              style: AppTextStyles.hintFormat,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['id'].toString(),
                child: Text(item['name']),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

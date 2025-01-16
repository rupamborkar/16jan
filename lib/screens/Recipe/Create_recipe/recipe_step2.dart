import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:margo/screens/Recipe/Create_recipe/widgets.dart';

class RecipeStep2 extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final Function(List<dynamic>) onIngredientsChange;
  final VoidCallback nextStep;
  // final Future<void> Function() saveRecipe;

  const RecipeStep2({
    super.key,
    required this.recipeData,
    required this.onIngredientsChange,
    required this.nextStep,
    //required this.saveRecipe,
  });

  @override
  _RecipeStep2State createState() => _RecipeStep2State();
}

class _RecipeStep2State extends State<RecipeStep2> {
  final _formKey = GlobalKey<FormState>();
  final List<String> massUnits = [
    'gm',
    'kg',
    'oz',
    'lbs',
    'tonne',
    'ml',
    'cl',
    'dl',
    'L',
    'Pint',
    'Quart',
    'fl oz',
    'gallon',
    'Each',
    'Serving',
    'Box',
    'Bag',
    'Can',
    'Carton',
    'Jar',
    'Punnet',
    'Container',
    'Packet',
    'Roll',
    'Bunch',
    'Bottle',
    'Tin',
    'Tub',
    'Piece',
    'Block',
    'Portion',
    'Dozen',
    'Bucket',
    'Slice',
    'Pinch',
    'Tray',
    'Teaspoon',
    'Tablespoon',
    'Cup'
  ]..sort();
  final List<String> metricUnits = ['Kg', 'Oz', 'L'];
  List<Map<String, dynamic>> ingredients = [];
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  List<Map<String, dynamic>> ingredientList = [];
  List<TextEditingController> qtyControllers = [];
  List<TextEditingController> costControllers = [];
  List<TextEditingController> wastageControllers = [];
  //List<String>
  List<Map<String, dynamic>> ingredientsList = [];

  double quantity = 0.0;
  double totalCost = 0.0;
  double totalWastage = 0.0;
  double price_per_unit = 0.0;
  var unit = "";
  var type = "";

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
        Uri.parse('$baseUrl/api/ingredients/ingredient_recipe_list'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);

        List<Map<String, dynamic>> ingredients_only = [];
        List<Map<String, dynamic>> recipes_only = [];

        for (var item in fetchedData) {
          if (item['type'] == 'Ingredient') {
            ingredients_only.add({
              'id': item['ingredient_id'],
              'name': item['name'],
              'quantity_unit': item['quantity_unit'],
              // 'price_per_unit': item['price_per_unit'] ?? 0.0,
              'price_per_unit': item['price_per_unit'] ?? 0.0,
              'type': item['type'],
            });
          } else if (item['type'] == 'Recipe') {
            recipes_only.add({
              'id': item['recipe_id'],
              'name': item['name'],
              'quantity_unit': item['quantity_unit'],
              'price_per_unit': item['price_per_unit'] ?? 0.0,
              'type': item['type'],
              //'cost': item['cost'],
            });
          }
        }

        // Create the final list with section headers
        List<Map<String, dynamic>> ingredientsList = [
          {
            'name': 'Ingredients ---',
            'id': null,
            'quantity_unit': '',
          },
          ...ingredients_only,
          {
            'name': 'Recipes ---',
            'id': null,
            'quantity_unit': '',
          },
          ...recipes_only,
        ];

        setState(() {
          this.ingredientsList = ingredientsList;
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
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
        "cost": totalCost,
        "wastage": totalWastage,
        "type": type,
        //"price_per_unit": price_per_unit,
      });
      qtyControllers.add(TextEditingController());
      costControllers.add(TextEditingController());
      wastageControllers.add(TextEditingController());
      widget.onIngredientsChange(ingredients);
    });
  }

  bool isCurrentIngredientValid(int index) {
    return qtyControllers[index].text.isNotEmpty &&
        costControllers[index].text.isNotEmpty &&
        wastageControllers[index].text.isNotEmpty;
  }

  void removeIngredient(int index) {
    setState(() {
      ingredients.removeAt(index);
      widget.onIngredientsChange(ingredients);
    });
  }

  void _onQuantityChanged(int index) {
    final ingredientId = ingredients[index]["id"];
    if (ingredientId == null || ingredientId.isEmpty) return;

    final selectedIngredient = ingredientsList.firstWhere(
        (ingredient) => ingredient['id'] == ingredientId,
        orElse: () => {});
    if (selectedIngredient.isEmpty) return;

    var unit = selectedIngredient['quantity_unit'];
    var type = selectedIngredient["type"];

    var costPerUnit = selectedIngredient['price_per_unit'] ?? 0.0;

    var price_per_unit = selectedIngredient['price_per_unit'] ?? 0.0;

    quantity = double.tryParse(qtyControllers[index].text) ?? 0.0;

    totalCost = quantity * costPerUnit;

    setState(() {
      costControllers[index].text = totalCost.toStringAsFixed(2);

      ingredients[index]["quantity"] = quantity;
      ingredients[index]["cost"] = totalCost;

      ingredients[index]["quantity_unit"] = unit;

      ingredients[index]["wastage"] =
          double.tryParse(wastageControllers[index].text) ?? 0.0;

      ingredients[index]["type"] = type;
      ingredients[index]["price_per_unit"] = price_per_unit;
    });
  }

  double calculateTotalCost() {
    double total = 0.0;

    for (var ingredient in ingredients) {
      total += ingredient['cost'] ?? 0.0;
    }

    setState(() {
      widget.recipeData['total_food_cost'] = total.toStringAsFixed(2);
    });
    return total;
  }

  double calculateTotalWastageCost() {
    double totWastageCost = 0.0;

    for (var ingredient in ingredients) {
      double wastage = ingredient['wastage'] ?? 0.0;
      double pricePerUnit = ingredient['price_per_unit'] ?? 0.0;

      totWastageCost += wastage * pricePerUnit;
    }

    setState(() {
      widget.recipeData['wastage_cost'] = totWastageCost.toStringAsFixed(2);
    });
    return totWastageCost;
  }

  double calculateTotalFoodCost() {
    double totFoodCost = 0.0;

    for (var ingredient in ingredients) {
      double wastage = ingredient['wastage'] ?? 0.0;
      double pricePerUnit = ingredient['price_per_unit'] ?? 0.0;
      double quant = ingredient['quantity'] ?? 0.0;

      totFoodCost += (quant - wastage) * pricePerUnit;
    }

    setState(() {
      widget.recipeData['food_cost'] = totFoodCost.toStringAsFixed(2);
    });
    return totFoodCost;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      buildTextField(
                        'Recipe Name *',
                        'Enter the name of the recipe',
                        onChanged: (value) => widget.recipeData['name'] = value,
                      ),
                      const SizedBox(height: 16),
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
                              size: 20,
                              color: AppColors.hintColor,
                            ),
                            onPressed: () {
                              if (ingredients.isEmpty ||
                                  isCurrentIngredientValid(
                                      ingredients.length - 1)) {
                                _addIngredient();
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                        'Please fill all fields in the existing cards before adding a new one.'),
                                    duration: Duration(seconds: 3),
                                  ),
                                );
                              }
                            },
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
                              ingredientsList
                                  //ingredientsList
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
                                    onChanged: (selectedIngredient) {
                                      setState(() {
                                        ingredients[index]["id"] =
                                            selectedIngredient['id'] ?? '';
                                        ingredients[index]["quantity_unit"] =
                                            selectedIngredient[
                                                    'quantity_unit'] ??
                                                '';
                                        ingredients[index]["cost"] =
                                            selectedIngredient[
                                                    'price_per_unit'] ??
                                                0;
                                      });
                                      widget.onIngredientsChange(ingredients);
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                              height: 40,
                                              child: TextFormField(
                                                controller:
                                                    qtyControllers[index],
                                                keyboardType: TextInputType
                                                    .numberWithOptions(
                                                        decimal: true),
                                                onChanged: (_) =>
                                                    _onQuantityChanged(index),
                                                decoration: InputDecoration(
                                                  hintText: 'Enter Quantity',
                                                  hintStyle:
                                                      AppTextStyles.hintFormat,
                                                  border: OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10),
                                                  ),
                                                  contentPadding:
                                                      const EdgeInsets
                                                          .symmetric(
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
                                                controller:
                                                    TextEditingController(
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
                                                      const EdgeInsets
                                                          .symmetric(
                                                          vertical: 4.0,
                                                          horizontal: 8.0),
                                                  errorStyle: const TextStyle(
                                                      height: 0),
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
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  buildDisabledTextField(
                                    'Cost',
                                    costControllers[index].text,
                                    onChanged: (value) {
                                      costControllers[index].text = value;
                                    },
                                  ),
                                  const SizedBox(height: 8),
                                  buildWastageField(index),
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
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Total Cost:',
                      style: AppTextStyles.labelBoldFormat,
                    ),
                    Text(
                      '\$${calculateTotalCost().toStringAsFixed(2)}',
                      style: AppTextStyles.valueFormat,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Food Cost:',
                      style: AppTextStyles.labelBoldFormat,
                    ),
                    Text(
                      '\$${calculateTotalFoodCost().toStringAsFixed(2)}',
                      style: AppTextStyles.valueFormat,
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Wastage Cost:',
                      style: AppTextStyles.labelBoldFormat,
                    ),
                    Text(
                      '\$${calculateTotalWastageCost().toStringAsFixed(2)}',
                      style: AppTextStyles.valueFormat,
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (_formKey.currentState?.validate() ?? false) {
                        widget.nextStep();
                      }
                    },
                    style: AppStyles.elevatedButtonStyle,
                    child: const Text(
                      'Next',
                      style: AppTextStyles.buttonText,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget buildWastageField(int index) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: 'Wastage (${ingredients[index]["quantity_unit"]})',
              style: AppTextStyles.labelFormat,
            ),
          ),
          const SizedBox(height: 5.0),
          SizedBox(
            width: 330,
            height: 40,
            child: TextFormField(
              controller: wastageControllers[index],
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                hintText: 'Enter Wastage',
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                errorStyle: TextStyle(height: 0),
              ),
              onChanged: (value) {
                setState(() {
                  final quantity =
                      double.tryParse(qtyControllers[index].text) ?? 0.0;
                  final wastage = double.tryParse(value) ?? 0.0;

                  // Validate if quantity is entered before wastage
                  // if (quantity == 0.0) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(
                  //       content: Text('Please enter quantity first.'),
                  //       duration: Duration(seconds: 2),
                  //     ),
                  //   );
                  //   wastageControllers[index]
                  //       .clear(); // Clear wastage if quantity is not entered
                  // } else
                  if (wastage > quantity) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Wastage cannot be greater than the quantity.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                    wastageControllers[index].clear();
                  } else {
                    ingredients[index]["wastage"] = wastage;
                  }
                });
              },
              validator: (value) {
                final quantity =
                    double.tryParse(qtyControllers[index].text) ?? 0.0;
                final wastage = double.tryParse(value ?? '') ?? 0.0;

                if (quantity == 0.0) {
                  return 'Please enter quantity first';
                }
                if (wastage > quantity) {
                  return 'Wastage cannot be greater than the quantity';
                }
                return null;
              },
              enabled: double.tryParse(qtyControllers[index].text) != null &&
                  double.tryParse(qtyControllers[index].text)! > 0,
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
          width: 330,
          height: 40,
          child: DropdownSearch<String>(
            items: items
                .where((ingredient) =>
                    ingredient['name'] != null) // Ensure non-null values
                .map((ingredient) => ingredient['name'] as String)
                .toList(),
            // items
            //     .map((ingredient) => ingredient['name'] as String)
            //     .toList(),
            onChanged: (value) {
              final selectedIngredient = items.firstWhere(
                (ingredient) => ingredient['name'] == value,
                orElse: () => {},
              );
              onChanged(selectedIngredient);
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'Select $label',
                hintStyle: AppTextStyles.hintFormat,
                contentPadding: const EdgeInsets.symmetric(
                  vertical: 4.0,
                  horizontal: 8.0,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            popupProps: PopupPropsMultiSelection.menu(
              showSearchBox: true,
              constraints: BoxConstraints(maxHeight: 300, maxWidth: 500),
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search or select Ingredients/Recipes',
                  hintStyle: AppTextStyles.hintFormat,
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 4.0, horizontal: 8.0),
                ),
              ),
              // itemBuilder: (context, item, isSelected) {
              itemBuilder: (context, item, isSelected) {
                if (item.endsWith('---')) {
                  return DropdownMenuItem<String>(
                    value: null,
                    enabled: false,
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
                      child: Text(
                        item.replaceAll(' ---', ''),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                  );
                }
                return ListTile(
                  title: Text(item),
                  selected: isSelected,
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget buildDisabledTextField(String label, String hint,
      {required Null Function(dynamic value) onChanged}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.labelFormat,
            ),
          ),
          const SizedBox(height: 5.0),
          SizedBox(
            width: 330,
            height: 40,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Color.fromRGBO(231, 231, 231, 1),
                filled: true,
              ),
              enabled: false,
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

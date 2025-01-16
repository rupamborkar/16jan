import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Recipe/Edit_recipe/edit_method.dart';
import 'package:margo/screens/Recipe/Edit_recipe/edit_recipe_details.dart';
import 'package:margo/screens/Recipe/Edit_recipe/edit_tabs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditIngredientDetails extends StatefulWidget {
  final String recipeId;
  const EditIngredientDetails({Key? key, required this.recipeId})
      : super(key: key);

  @override
  _EditIngredientDetailsState createState() => _EditIngredientDetailsState();
}

class _EditIngredientDetailsState extends State<EditIngredientDetails> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  Future<Map<String, dynamic>?>? recipeData;
  List<Map<String, dynamic>> ingredients = [];
  List<Map<String, dynamic>> ingredientDropdownList = [];
  String? selectedUnit;
  String? type;

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
  final TextEditingController quantityController = TextEditingController();
  final TextEditingController costController = TextEditingController();
  final TextEditingController wastageController = TextEditingController();

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
      setState(() async {
        _jwtToken = token;
        recipeData = fetchRecipeDetails();
        await fetchIngredientList();
      });
    } catch (e) {
      print("Error loading token or fetching recipe details: $e");
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    if (_jwtToken == null) throw Exception('JWT token is null');
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ingredients = List<Map<String, dynamic>>.from(data['ingredients']);
        });
        return data;
      } else {
        throw Exception('Failed to load recipe data');
      }
    } catch (e) {
      throw Exception('Error fetching recipe data: $e');
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
        //  List<Map<String, dynamic>> ingredients = [];
        // List<Map<String, dynamic>> recipes = [];

        // Populate the lists based on fetched data (assuming 'type' determines category)
        for (var item in fetchedData) {
          if (item['type'] == 'Ingredient') {
            ingredients_only.add({
              'id': item['ingredient_id'],
              'name': item['name'],
              'quantity_unit': item['quantity_unit'],
              'price_per_unit': item['cost_per_unit'] ?? 0.0,
              'type': item['type'],
              // 'cost': item['cost'],
            });
          } else if (item['type'] == 'Recipe') {
            recipes_only.add({
              'id': item['recipe_id'],
              'name': item['name'],
              'quantity_unit': item['quantity_unit'],
              'price_per_unit': item['cost_per_unit'] ?? 0.0,
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
            //'cost': 0
          },
          ...ingredients_only,
          {
            'name': 'Recipes ---', 'id': null, 'quantity_unit': '',
            //'cost': 0
          },
          ...recipes_only,
        ];

        setState(() {
          this.ingredientDropdownList = ingredientsList;
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

  void _toggleExpand(int index) {
    setState(() {
      ingredients[index]['expanded'] =
          !(ingredients[index]['expanded'] ?? false);
    });
  }

  Future<void> deleteIngredient(String ingredientId, String type) async {
    try {
      final response = await http.delete(
        Uri.parse(
            '$baseUrl/api/recipes/${widget.recipeId}/${type}/${ingredientId}'),
        headers: {
          'Authorization': 'Bearer ${_jwtToken}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient deleted successfully')),
        );

        Navigator.of(context).pop(true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete ingredient.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting ingredient: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the ingredient.')),
      );
    }
  }

  void confirmDelete(String ingredientId, String type) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content:
              const Text('Are you sure you want to delete this ingredient?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                deleteIngredient(ingredientId, type);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  void duplicateIngredient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Ingredient with same name already added'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Ok'),
            ),
          ],
        );
      },
    );
  }

  void _showAddIngredientDialog(String recipeId) {
    String? selectedIngredientName;
    String? selectedIngredientId;
    String? selectedUnit;

    TextEditingController quantityController = TextEditingController();
    TextEditingController costController = TextEditingController();
    TextEditingController wastageController = TextEditingController();
    TextEditingController quantityUnitController = TextEditingController();

    bool isWastageEnabled = false;

    void _updateCostAndWastage() {
      if (selectedIngredientId != null) {
        double quantity = double.tryParse(quantityController.text) ?? 0.0;

        var costPerUnit = ingredientDropdownList.firstWhere(
              (ingredient) => ingredient['id'] == selectedIngredientId,
              orElse: () => {'price_per_unit': 0.0},
            )['price_per_unit'] ??
            0.0;

        double totalCost = quantity * costPerUnit;

        setState(() {
          costController.text = totalCost.toStringAsFixed(2);
          isWastageEnabled = quantity > 0.0;
        });
      }
    }

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Add New Ingredient'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    RichText(
                      text: const TextSpan(
                        text: 'Ingredient Name',
                        style: AppTextStyles.labelFormat,
                      ),
                    ),
                    const SizedBox(height: 8.0),
                    SizedBox(
                      width: 353,
                      height: 40,
                      child: DropdownSearch<String>(
                        selectedItem: selectedIngredientName,
                        items: ingredientDropdownList
                            .map((ingredient) => ingredient['name'] as String)
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedIngredientName = value;
                            final selected = ingredientDropdownList.firstWhere(
                              (element) => element['name'] == value,
                            );
                            selectedIngredientId = selected['id'];
                            selectedUnit = selected['quantity_unit'] ?? '';
                            quantityUnitController.text = selectedUnit ?? '';
                            type = selected['type'] ?? '';
                            _updateCostAndWastage();
                          });
                        },
                        dropdownDecoratorProps: DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            hintText: 'Select Ingredient',
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
                          constraints:
                              BoxConstraints(maxHeight: 300, maxWidth: 500),
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: 'Search or select Ingredients',
                              hintStyle: AppTextStyles.hintFormat,
                              prefixIcon: Icon(Icons.search),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                  vertical: 4.0, horizontal: 8.0),
                            ),
                          ),
                          itemBuilder: (context, item, isSelected) {
                            if (item.endsWith('---')) {
                              return DropdownMenuItem<String>(
                                value: null,
                                enabled: false,
                                child: Padding(
                                  padding:
                                      const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
                ),
                const SizedBox(height: 10.0),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Quantity Required',
                      style: AppTextStyles.labelFormat,
                    ),
                    const SizedBox(height: 8.0),
                    Row(
                      children: [
                        Expanded(
                          child: SizedBox(
                            height: 40,
                            child: TextFormField(
                              controller: quantityController,
                              keyboardType: TextInputType.numberWithOptions(
                                  decimal: true),
                              decoration: InputDecoration(
                                hintText: 'Enter quantity',
                                hintStyle: AppTextStyles.hintFormat,
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                      color: Color.fromRGBO(231, 231, 231, 1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),
                              ),
                              textInputAction: TextInputAction.done,
                              onChanged: (value) {
                                _updateCostAndWastage();
                              },
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            //width: 160,
                            height: 40,
                            child: TextFormField(
                              controller: quantityUnitController,
                              keyboardType: TextInputType.number,
                              decoration: InputDecoration(
                                hintText: 'Unit',
                                hintStyle: const TextStyle(
                                    fontSize: 15,
                                    height: 1.5,
                                    fontWeight: FontWeight.w300,
                                    color: Color.fromRGBO(150, 153, 151, 1)),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: const BorderSide(
                                      width: 1.0,
                                      style: BorderStyle.solid,
                                      color: Color.fromRGBO(231, 231, 231, 1)),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                    vertical: 4.0, horizontal: 8.0),

                                fillColor: Color.fromRGBO(
                                    231, 231, 231, 1), // Grey background color
                                filled: true,
                              ),
                              enabled: false,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 10.0),
                _buildDisabledDialogTextField('Cost', costController),
                const SizedBox(height: 10.0),
                _buildDialogTextField(
                  'Wastage',
                  wastageController,
                  isNumeric: true,
                  enabled: isWastageEnabled,
                  onChanged: (value) {
                    final quantity =
                        double.tryParse(quantityController.text) ?? 0.0;
                    final wastage = double.tryParse(value) ?? 0.0;

                    if (wastage > quantity) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                              'Wastage cannot be greater than the quantity.'),
                          duration: Duration(seconds: 2),
                        ),
                      );
                      wastageController
                          .clear(); // Clear the wastage input if validation fails
                    }
                  },
                ),
                // _buildDialogTextField('Wastage ', wastageController),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child:
                  const Text('Cancel', style: TextStyle(color: Colors.black)),
            ),
            // Add Button
            TextButton(
              onPressed: () async {
                final double quantity =
                    double.tryParse(quantityController.text) ?? 0.0;
                final double wastage =
                    double.tryParse(wastageController.text) ?? 0.0;

                // Check if wastage is greater than quantity
                if (quantity == 0.0) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Please enter quantity first.'),
                      duration: Duration(seconds: 2),
                    ),
                  );
                  // Clear wastage if quantity is not entered
                } else if (wastage > quantity) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Wastage cannot be greater than quantity',
                        //style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                  return; // Exit without proceeding further
                }

                if (selectedIngredientId == null ||
                    selectedIngredientName == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'Please select an ingredient',
                        //style: TextStyle(color: Colors.red),
                      ),
                    ),
                  );
                  return; // Exit if ingredient not selected
                }

                final ingredientData = {
                  'ingredient_id': selectedIngredientId,
                  'quantity': double.tryParse(quantityController.text) ?? 0.0,
                  'quantity_unit': selectedUnit,
                  'cost': double.tryParse(costController.text) ?? 0.0,
                  'wastage': double.tryParse(wastageController.text) ?? 0.0,
                  'type': type,
                };

                try {
                  final response = await http.post(
                    Uri.parse('$baseUrl/api/recipes/$recipeId/add_ingredient'),
                    headers: {
                      'Authorization': 'Bearer $_jwtToken',
                      'Content-Type': 'application/json',
                    },
                    body: json.encode(ingredientData),
                  );

                  if (response.statusCode == 200 ||
                      response.statusCode == 201) {
                    Navigator.of(context).pop();
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Ingredient added successfully')));
                    await _loadTokenAndFetchDetails();
                    setState(() {});
                  } else if (response.statusCode == 403) {
                    duplicateIngredient(context);
                  } else {
                    // Handle error
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Failed to add ingredient')));
                  }
                } catch (e) {
                  print("Error: $e");
                  ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Error occurred')));
                }
              },
              child: const Text(
                'Add',
                style: TextStyle(color: Colors.black),
              ),
            ),
          ],
        );
      },
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
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
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
          width: 353,
          height: 40,
          child: DropdownButtonFormField<String>(
            isExpanded: true,
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item['id'].toString(),
                child: Text(item['name']),
              );
            }).toList(),
            onChanged: onChanged,
            decoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            menuMaxHeight: 400,
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledDialogTextField(
      String label, TextEditingController controller,
      {bool isNumeric = false}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelFormat,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353,
          height: 40,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumeric
                ? TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            decoration: InputDecoration(
              hintText: label,
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
          ),
        ),
      ],
    );
  }

  Widget _buildDialogTextField(
    String label,
    TextEditingController controller, {
    bool isNumeric = false,
    bool enabled = true,
    required Function(String) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelFormat,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353,
          height: 40,
          child: TextFormField(
            controller: controller,
            keyboardType: isNumeric
                ? TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            onChanged: onChanged,
            decoration: InputDecoration(
              //labelText: label,
              hintText: 'Enter $label',
              hintStyle: AppTextStyles.hintFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Colors.grey[300]!, width: 1), // Grey border
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget _buildDialogTextField(
  //   String label,
  //   TextEditingController controller, {
  //   bool isNumeric = false,
  //   bool enabled = true,
  // }) {
  //   return Column(
  //     crossAxisAlignment: CrossAxisAlignment.start,
  //     children: [
  //       RichText(
  //         text: TextSpan(
  //           text: label,
  //           style: AppTextStyles.labelFormat,
  //         ),
  //       ),
  //       const SizedBox(height: 8.0),
  //       SizedBox(
  //         width: 353,
  //         height: 40,
  //         child: TextFormField(
  //           controller: controller,
  //           keyboardType: isNumeric
  //               ? TextInputType.numberWithOptions(decimal: true)
  //               : TextInputType.text,
  //           decoration: InputDecoration(
  //             //labelText: label,
  //             hintText: 'Enter $label',
  //             hintStyle: AppTextStyles.hintFormat,
  //             contentPadding:
  //                 const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
  //             border:
  //                 OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
  //             disabledBorder: OutlineInputBorder(
  //               borderSide: BorderSide(
  //                   color: Colors.grey[300]!, width: 1), // Grey border
  //               borderRadius: BorderRadius.circular(10),
  //             ),
  //           ),
  //         ),
  //       ),
  //     ],
  //   );
  // }

  Widget _buildTextField(String label, String hint,
      {bool isNumber = false, int index = -1, String? field}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelFormat,
          ),
          const SizedBox(height: 8.0),
          TextFormField(
            initialValue: index >= 0 ? ingredients[index][field] ?? '' : '',
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.valueFormat,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            textInputAction: TextInputAction.done,
            keyboardType: isNumber
                ? TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            onChanged: (value) {
              if (index >= 0 && field != null) {
                setState(() {
                  ingredients[index][field] = value;
                });
              }
            },
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: recipeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            return Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Add Ingredient',
                        style: AppTextStyles.labelBoldFormat,
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.hintColor,
                        ),
                        onPressed: () {
                          _showAddIngredientDialog(widget.recipeId);
                        },

                        //_addIngredient,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      return Card(
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(
                            color: Color.fromRGBO(231, 231, 231, 1),
                            width: 1,
                          ),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            ingredient['name'] ?? 'Ingredient',
                            style: AppTextStyles.labelBoldFormat,
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quantity',
                                    style: AppTextStyles.labelFormat,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: TextFormField(
                                          initialValue: ingredients[index]
                                              ["quantity"],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            fillColor: Color.fromRGBO(
                                                231, 231, 231, 1),
                                            filled: true,
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 8.0,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Quantity is required';
                                            }
                                            return null;
                                          },
                                          enabled: false,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 210.0,
                                        height: 40,
                                        child: TextFormField(
                                          initialValue: ingredients[index]
                                              ['quantity_unit'],
                                          //controller: quantityUnitController,
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Unit',
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                height: 1.5,
                                                fontWeight: FontWeight.w300,
                                                color: Color.fromRGBO(
                                                    150, 153, 151, 1)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                  width: 1.0,
                                                  style: BorderStyle.solid,
                                                  color: Color.fromRGBO(
                                                      231, 231, 231, 1)),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0),
                                            fillColor: Color.fromRGBO(
                                                231, 231, 231, 1),
                                            filled: true,
                                          ),
                                          enabled: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 15),
                                  buildDisabledTextField(
                                    'Wastage',
                                    '',
                                    initialValue: ingredients[index]["wastage"]
                                        .toString(),
                                  ),
                                  const SizedBox(height: 10),
                                  buildDisabledTextField(
                                    'Cost',
                                    '',
                                    initialValue:
                                        ingredients[index]["cost"].toString(),
                                  ),
                                  TextButton(
                                    onPressed: () => setState(() {
                                      String deleteIngredientId =
                                          ingredients[index]
                                              ["recipe_ingredient_id"];
                                      confirmDelete(deleteIngredientId,
                                          ingredients[index]["type"]);
                                    }),
                                    child: const Text('Delete Ingredient',
                                        style: AppTextStyles.deleteFormat),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            );
          }
          return const Center(child: Text('No Data Available'));
        },
      ),
    );
  }

  Widget buildDisabledTextField(String label, String hint,
//initialValue,
      {required initialValue}) {
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
          const SizedBox(height: 8),
          SizedBox(
            width: 340,
            height: 40,
            child: TextFormField(
              initialValue: initialValue,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
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
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    quantityController.dispose();
    costController.dispose();
    wastageController.dispose();
    super.dispose();
  }
}

class EditIngredientsTab extends StatelessWidget {
  final String recipeId;

  const EditIngredientsTab({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return RecipeTabs(
      initialIndex: 1,
      tabViews: [
        RecipeEditDetails(
          recipeId: recipeId,
        ),
        EditIngredientDetails(
          recipeId: recipeId,
        ),
        EditMethod(
          recipeId: recipeId,
        ),
      ],
    );
  }
}

// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:margo/constants/material.dart';
// import 'package:margo/screens/Recipe/Edit_recipe/edit_method.dart';
// import 'package:margo/screens/Recipe/Edit_recipe/edit_recipe_details.dart';
// import 'package:margo/screens/Recipe/Edit_recipe/edit_tabs.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class EditIngredientDetails extends StatefulWidget {
//   final String recipeId;
//   const EditIngredientDetails({Key? key, required this.recipeId})
//       : super(key: key);

//   @override
//   _EditIngredientDetailsState createState() => _EditIngredientDetailsState();
// }

// class _EditIngredientDetailsState extends State<EditIngredientDetails> {
//   final FlutterSecureStorage _storage = FlutterSecureStorage();
//   String? _jwtToken;
//   Future<Map<String, dynamic>?>? recipeData;
//   List<Map<String, dynamic>> ingredients = [];
//   List<Map<String, dynamic>> ingredientDropdownList = [];
//   String? selectedUnit;
//   String? type;

//   final List<String> massUnits = [
//     'gm',
//     'kg',
//     'oz',
//     'lbs',
//     'tonne',
//     'ml',
//     'cl',
//     'dl',
//     'L',
//     'Pint',
//     'Quart',
//     'fl oz',
//     'gallon',
//     'Each',
//     'Serving',
//     'Box',
//     'Bag',
//     'Can',
//     'Carton',
//     'Jar',
//     'Punnet',
//     'Container',
//     'Packet',
//     'Roll',
//     'Bunch',
//     'Bottle',
//     'Tin',
//     'Tub',
//     'Piece',
//     'Block',
//     'Portion',
//     'Dozen',
//     'Bucket',
//     'Slice',
//     'Pinch',
//     'Tray',
//     'Teaspoon',
//     'Tablespoon',
//     'Cup'
//   ]..sort();
//   final TextEditingController quantityController = TextEditingController();
//   final TextEditingController costController = TextEditingController();
//   final TextEditingController wastageController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _loadTokenAndFetchDetails();
//   }

//   Future<void> _loadTokenAndFetchDetails() async {
//     try {
//       final token = await _storage.read(key: 'jwt_token');
//       if (token == null) {
//         throw Exception("JWT token not found. Please log in again.");
//       }
//       setState(() async {
//         _jwtToken = token;
//         recipeData = fetchRecipeDetails();
//         await fetchIngredientList();
//       });
//     } catch (e) {
//       print("Error loading token or fetching recipe details: $e");
//     }
//   }

//   Future<Map<String, dynamic>> fetchRecipeDetails() async {
//     if (_jwtToken == null) throw Exception('JWT token is null');
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
//         headers: {'Authorization': 'Bearer $_jwtToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         setState(() {
//           ingredients = List<Map<String, dynamic>>.from(data['ingredients']);
//         });
//         return data;
//       } else {
//         throw Exception('Failed to load recipe data');
//       }
//     } catch (e) {
//       throw Exception('Error fetching recipe data: $e');
//     }
//   }

//   Future<void> fetchIngredientList() async {
//     if (_jwtToken == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/ingredients/ingredient_recipe_list'),
//         headers: {'Authorization': 'Bearer $_jwtToken'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> fetchedData = json.decode(response.body);
//         List<Map<String, dynamic>> ingredients_only = [];
//         List<Map<String, dynamic>> recipes_only = [];
//         //  List<Map<String, dynamic>> ingredients = [];
//         // List<Map<String, dynamic>> recipes = [];

//         // Populate the lists based on fetched data (assuming 'type' determines category)
//         for (var item in fetchedData) {
//           if (item['type'] == 'Ingredient') {
//             ingredients_only.add({
//               'id': item['ingredient_id'],
//               'name': item['name'],
//               'quantity_unit': item['quantity_unit'],
//               'price_per_unit': item['cost_per_unit'] ?? 0.0,
//               'type': item['type'],
//               // 'cost': item['cost'],
//             });
//           } else if (item['type'] == 'Recipe') {
//             recipes_only.add({
//               'id': item['recipe_id'],
//               'name': item['name'],
//               'quantity_unit': item['quantity_unit'],
//               'price_per_unit': item['cost_per_unit'] ?? 0.0,
//               'type': item['type'],
//               //'cost': item['cost'],
//             });
//           }
//         }

//         // Create the final list with section headers
//         List<Map<String, dynamic>> ingredientsList = [
//           {
//             'name': 'Ingredients ---',
//             'id': null,
//             'quantity_unit': '',
//             //'cost': 0
//           },
//           ...ingredients_only,
//           {
//             'name': 'Recipes ---', 'id': null, 'quantity_unit': '',
//             //'cost': 0
//           },
//           ...recipes_only,
//         ];

//         setState(() {
//           this.ingredientDropdownList = ingredientsList;
//         });
//       } else {
//         print(
//             'Failed to load ingredient data. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching ingredient data: $e');
//     }
//   }

//   void _toggleExpand(int index) {
//     setState(() {
//       ingredients[index]['expanded'] =
//           !(ingredients[index]['expanded'] ?? false);
//     });
//   }

//   Future<void> deleteIngredient(String ingredientId, String type) async {
//     try {
//       final response = await http.delete(
//         Uri.parse(
//             '$baseUrl/api/recipes/${widget.recipeId}/${type}/${ingredientId}'),
//         headers: {
//           'Authorization': 'Bearer ${_jwtToken}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Ingredient deleted successfully')),
//         );

//         Navigator.of(context).pop(true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to delete ingredient.',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error deleting ingredient: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('An error occurred while deleting the ingredient.')),
//       );
//     }
//   }

//   void confirmDelete(String ingredientId, String type) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Confirm Delete'),
//           content:
//               const Text('Are you sure you want to delete this ingredient?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Cancel'),
//             ),
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//                 deleteIngredient(ingredientId, type);
//               },
//               child: const Text(
//                 'Delete',
//                 style: TextStyle(color: Colors.red),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void duplicateIngredient(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: const Text('Ingredient with same name already added'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child: const Text('Ok'),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   void _showAddIngredientDialog(String recipeId) {
//     String? selectedIngredientName;
//     String? selectedIngredientId;
//     String? selectedUnit;

//     TextEditingController quantityController = TextEditingController();
//     TextEditingController costController = TextEditingController();
//     TextEditingController wastageController = TextEditingController();
//     TextEditingController quantityUnitController = TextEditingController();

//     void _updateCostAndWastage() {
//       if (selectedIngredientId != null) {
//         double quantity = double.tryParse(quantityController.text) ?? 0.0;

//         var costPerUnit = ingredientDropdownList.firstWhere(
//               (ingredient) => ingredient['id'] == selectedIngredientId,
//               orElse: () => {'price_per_unit': 0.0},
//             )['price_per_unit'] ??
//             0.0;

//         double totalCost = quantity * costPerUnit;

//         setState(() {
//           costController.text = totalCost.toStringAsFixed(2);
//         });
//       }
//     }

//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           title: const Text('Add New Ingredient'),
//           content: SingleChildScrollView(
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     RichText(
//                       text: const TextSpan(
//                         text: 'Ingredient Name',
//                         style: AppTextStyles.labelFormat,
//                       ),
//                     ),
//                     const SizedBox(height: 8.0),
//                     SizedBox(
//                       width: 353,
//                       height: 40,
//                       child: DropdownSearch<String>(
//                         selectedItem: selectedIngredientName,
//                         items: ingredientDropdownList
//                             .map((ingredient) => ingredient['name'] as String)
//                             .toList(),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedIngredientName = value;
//                             final selected = ingredientDropdownList.firstWhere(
//                               (element) => element['name'] == value,
//                             );
//                             selectedIngredientId = selected['id'];
//                             selectedUnit = selected['quantity_unit'] ?? '';
//                             quantityUnitController.text = selectedUnit ?? '';
//                             type = selected['type'] ?? '';
//                             _updateCostAndWastage();
//                           });
//                         },
//                         dropdownDecoratorProps: DropDownDecoratorProps(
//                           dropdownSearchDecoration: InputDecoration(
//                             hintText: 'Select Ingredient',
//                             hintStyle: AppTextStyles.hintFormat,
//                             contentPadding: const EdgeInsets.symmetric(
//                               vertical: 4.0,
//                               horizontal: 8.0,
//                             ),
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(8),
//                             ),
//                           ),
//                         ),
//                         popupProps: PopupPropsMultiSelection.menu(
//                           showSearchBox: true,
//                           constraints:
//                               BoxConstraints(maxHeight: 300, maxWidth: 500),
//                           searchFieldProps: TextFieldProps(
//                             decoration: InputDecoration(
//                               hintText: 'Search or select Ingredients',
//                               hintStyle: AppTextStyles.hintFormat,
//                               prefixIcon: Icon(Icons.search),
//                               border: OutlineInputBorder(
//                                 borderRadius: BorderRadius.circular(10),
//                               ),
//                               contentPadding: const EdgeInsets.symmetric(
//                                   vertical: 4.0, horizontal: 8.0),
//                             ),
//                           ),
//                           itemBuilder: (context, item, isSelected) {
//                             if (item.endsWith('---')) {
//                               return DropdownMenuItem<String>(
//                                 value: null,
//                                 enabled: false,
//                                 child: Padding(
//                                   padding:
//                                       const EdgeInsets.fromLTRB(10, 0, 0, 0),
//                                   child: Text(
//                                     item.replaceAll(' ---', ''),
//                                     style: const TextStyle(
//                                       fontWeight: FontWeight.bold,
//                                       color: Colors.grey,
//                                     ),
//                                   ),
//                                 ),
//                               );
//                             }
//                             return ListTile(
//                               title: Text(item),
//                               selected: isSelected,
//                             );
//                           },
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10.0),
//                 Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     const Text(
//                       'Quantity Required',
//                       style: AppTextStyles.labelFormat,
//                     ),
//                     const SizedBox(height: 8.0),
//                     Row(
//                       children: [
//                         Expanded(
//                           child: SizedBox(
//                             height: 40,
//                             child: TextFormField(
//                               controller: quantityController,
//                               keyboardType: TextInputType.numberWithOptions(
//                                   decimal: true),
//                               decoration: InputDecoration(
//                                 hintText: 'Enter quantity',
//                                 hintStyle: AppTextStyles.hintFormat,
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                   borderSide: const BorderSide(
//                                       width: 1.0,
//                                       style: BorderStyle.solid,
//                                       color: Color.fromRGBO(231, 231, 231, 1)),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 4.0, horizontal: 8.0),
//                               ),
//                               textInputAction: TextInputAction.done,
//                               onChanged: (value) {
//                                 _updateCostAndWastage();
//                               },
//                             ),
//                           ),
//                         ),
//                         const SizedBox(width: 10),
//                         Expanded(
//                           child: SizedBox(
//                             //width: 160,
//                             height: 40,
//                             child: TextFormField(
//                               controller: quantityUnitController,
//                               keyboardType: TextInputType.number,
//                               decoration: InputDecoration(
//                                 hintText: 'Unit',
//                                 hintStyle: const TextStyle(
//                                     fontSize: 15,
//                                     height: 1.5,
//                                     fontWeight: FontWeight.w300,
//                                     color: Color.fromRGBO(150, 153, 151, 1)),
//                                 border: OutlineInputBorder(
//                                   borderRadius: BorderRadius.circular(8.0),
//                                   borderSide: const BorderSide(
//                                       width: 1.0,
//                                       style: BorderStyle.solid,
//                                       color: Color.fromRGBO(231, 231, 231, 1)),
//                                 ),
//                                 contentPadding: const EdgeInsets.symmetric(
//                                     vertical: 4.0, horizontal: 8.0),

//                                 fillColor: Color.fromRGBO(
//                                     231, 231, 231, 1), // Grey background color
//                                 filled: true,
//                               ),
//                               enabled: false,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ],
//                 ),
//                 const SizedBox(height: 10.0),
//                 _buildDisabledDialogTextField('Cost', costController),
//                 const SizedBox(height: 10.0),
//                 _buildDialogTextField('Wastage ', wastageController),
//               ],
//             ),
//           ),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.of(context).pop();
//               },
//               child:
//                   const Text('Cancel', style: TextStyle(color: Colors.black)),
//             ),
//             // Add Button
//             TextButton(
//               onPressed: () async {
//                 final ingredientData = {
//                   'ingredient_id': selectedIngredientId,
//                   'quantity': double.tryParse(quantityController.text) ?? 0.0,
//                   'quantity_unit': selectedUnit,
//                   'cost': double.tryParse(costController.text) ?? 0.0,
//                   'wastage': double.tryParse(wastageController.text) ?? 0.0,
//                   'type': type,
//                 };

//                 try {
//                   final response = await http.post(
//                     Uri.parse('$baseUrl/api/recipes/$recipeId/add_ingredient'),
//                     headers: {
//                       'Authorization': 'Bearer $_jwtToken',
//                       'Content-Type': 'application/json',
//                     },
//                     body: json.encode(ingredientData),
//                   );

//                   if (response.statusCode == 200 ||
//                       response.statusCode == 201) {
//                     Navigator.of(context).pop();
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                         content: Text('Ingredient added successfully')));
//                     await _loadTokenAndFetchDetails();
//                     setState(() {});
//                   } else if (response.statusCode == 403) {
//                     duplicateIngredient(context);
//                   } else {
//                     // Handle error
//                     ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
//                         content: Text('Failed to add ingredient')));
//                   }
//                 } catch (e) {
//                   print("Error: $e");
//                   ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Error occurred')));
//                 }
//               },
//               child: const Text(
//                 'Add',
//                 style: TextStyle(color: Colors.black),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget buildDropdownIngreField(String label,
//       {required List<Map<String, dynamic>> items,
//       required Function(dynamic value) onChanged}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label.replaceAll('*', ''),
//             style: TextStyle(
//               color: Colors.grey[600],
//               fontSize: 16,
//               fontWeight: FontWeight.w500,
//             ),
//             children: [
//               if (label.contains('*'))
//                 const TextSpan(
//                   text: ' *',
//                   style: TextStyle(
//                     color: Colors.red,
//                     fontSize: 16.0,
//                   ),
//                 ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 8.0),
//         SizedBox(
//           width: 353,
//           height: 40,
//           child: DropdownButtonFormField<String>(
//             isExpanded: true,
//             items: items.map((item) {
//               return DropdownMenuItem<String>(
//                 value: item['id'].toString(),
//                 child: Text(item['name']),
//               );
//             }).toList(),
//             onChanged: onChanged,
//             decoration: InputDecoration(
//               hintText: 'Select $label',
//               hintStyle: const TextStyle(color: Colors.grey),
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//             ),
//             menuMaxHeight: 400,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDisabledDialogTextField(
//       String label, TextEditingController controller,
//       {bool isNumeric = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label,
//             style: AppTextStyles.labelFormat,
//           ),
//         ),
//         const SizedBox(height: 8.0),
//         SizedBox(
//           width: 353,
//           height: 40,
//           child: TextFormField(
//             controller: controller,
//             keyboardType: isNumeric
//                 ? TextInputType.numberWithOptions(decimal: true)
//                 : TextInputType.text,
//             decoration: InputDecoration(
//               hintText: label,
//               hintStyle: AppTextStyles.hintFormat,
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               disabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               fillColor: Color.fromRGBO(231, 231, 231, 1),
//               filled: true,
//             ),
//             enabled: false,
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildDialogTextField(String label, TextEditingController controller,
//       {bool isNumeric = false}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label,
//             style: AppTextStyles.labelFormat,
//           ),
//         ),
//         const SizedBox(height: 8.0),
//         SizedBox(
//           width: 353,
//           height: 40,
//           child: TextFormField(
//             controller: controller,
//             keyboardType: isNumeric
//                 ? TextInputType.numberWithOptions(decimal: true)
//                 : TextInputType.text,
//             decoration: InputDecoration(
//               //labelText: label,
//               hintText: 'Enter $label',
//               hintStyle: AppTextStyles.hintFormat,
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//               border:
//                   OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               disabledBorder: OutlineInputBorder(
//                 borderSide: BorderSide(
//                     color: Colors.grey[300]!, width: 1), // Grey border
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildTextField(String label, String hint,
//       {bool isNumber = false, int index = -1, String? field}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Text(
//             label,
//             style: AppTextStyles.labelFormat,
//           ),
//           const SizedBox(height: 8.0),
//           TextFormField(
//             initialValue: index >= 0 ? ingredients[index][field] ?? '' : '',
//             decoration: InputDecoration(
//               hintText: hint,
//               hintStyle: AppTextStyles.valueFormat,
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(10),
//               ),
//             ),
//             textInputAction: TextInputAction.done,
//             keyboardType: isNumber
//                 ? TextInputType.numberWithOptions(decimal: true)
//                 : TextInputType.text,
//             onChanged: (value) {
//               if (index >= 0 && field != null) {
//                 setState(() {
//                   ingredients[index][field] = value;
//                 });
//               }
//             },
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: FutureBuilder<Map<String, dynamic>?>(
//         future: recipeData,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (snapshot.hasData) {
//             return Column(
//               children: [
//                 Padding(
//                   padding:
//                       const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
//                   child: Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       const Text(
//                         'Add Ingredient',
//                         style: AppTextStyles.labelBoldFormat,
//                       ),
//                       IconButton(
//                         icon: const Icon(Icons.add),
//                         onPressed: () {
//                           _showAddIngredientDialog(widget.recipeId);
//                         },

//                         //_addIngredient,
//                       ),
//                     ],
//                   ),
//                 ),
//                 Expanded(
//                   child: ListView.builder(
//                     padding: const EdgeInsets.all(16),
//                     itemCount: ingredients.length,
//                     itemBuilder: (context, index) {
//                       final ingredient = ingredients[index];
//                       return Card(
//                         color: const Color.fromRGBO(253, 253, 253, 1),
//                         elevation: 0,
//                         margin: const EdgeInsets.symmetric(vertical: 6.0),
//                         shape: RoundedRectangleBorder(
//                           borderRadius: BorderRadius.circular(8.0),
//                           side: const BorderSide(
//                             color: Color.fromRGBO(231, 231, 231, 1),
//                             width: 1,
//                           ),
//                         ),
//                         child: ExpansionTile(
//                           title: Text(
//                             ingredient['name'] ?? 'Ingredient',
//                             style: AppTextStyles.labelBoldFormat,
//                           ),
//                           collapsedShape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(8.0),
//                           ),
//                           children: [
//                             Padding(
//                               padding: const EdgeInsets.all(8.0),
//                               child: Column(
//                                 crossAxisAlignment: CrossAxisAlignment.start,
//                                 children: [
//                                   const Text(
//                                     'Quantity',
//                                     style: AppTextStyles.labelFormat,
//                                   ),
//                                   const SizedBox(height: 8.0),
//                                   Row(
//                                     children: [
//                                       SizedBox(
//                                         width: 120,
//                                         height: 40,
//                                         child: TextFormField(
//                                           initialValue: ingredients[index]
//                                               ["quantity"],
//                                           keyboardType:
//                                               TextInputType.numberWithOptions(
//                                                   decimal: true),
//                                           decoration: InputDecoration(
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8),
//                                             ),
//                                             fillColor: Color.fromRGBO(
//                                                 231, 231, 231, 1),
//                                             filled: true,
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                               vertical: 4.0,
//                                               horizontal: 8.0,
//                                             ),
//                                           ),
//                                           validator: (value) {
//                                             if (value == null ||
//                                                 value.isEmpty) {
//                                               return 'Quantity is required';
//                                             }
//                                             return null;
//                                           },
//                                           enabled: false,
//                                         ),
//                                       ),
//                                       const SizedBox(width: 10),
//                                       SizedBox(
//                                         width: 210.0,
//                                         height: 40,
//                                         child: TextFormField(
//                                           initialValue: ingredients[index]
//                                               ['quantity_unit'],
//                                           //controller: quantityUnitController,
//                                           keyboardType: TextInputType.number,
//                                           decoration: InputDecoration(
//                                             hintText: 'Unit',
//                                             hintStyle: const TextStyle(
//                                                 fontSize: 15,
//                                                 height: 1.5,
//                                                 fontWeight: FontWeight.w300,
//                                                 color: Color.fromRGBO(
//                                                     150, 153, 151, 1)),
//                                             border: OutlineInputBorder(
//                                               borderRadius:
//                                                   BorderRadius.circular(8.0),
//                                               borderSide: const BorderSide(
//                                                   width: 1.0,
//                                                   style: BorderStyle.solid,
//                                                   color: Color.fromRGBO(
//                                                       231, 231, 231, 1)),
//                                             ),
//                                             contentPadding:
//                                                 const EdgeInsets.symmetric(
//                                                     vertical: 4.0,
//                                                     horizontal: 8.0),
//                                             fillColor: Color.fromRGBO(
//                                                 231, 231, 231, 1),
//                                             filled: true,
//                                           ),
//                                           enabled: false,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                   const SizedBox(height: 15),
//                                   buildDisabledTextField(
//                                     'Wastage',
//                                     '',
//                                     initialValue: ingredients[index]["wastage"]
//                                         .toString(),
//                                   ),
//                                   const SizedBox(height: 10),
//                                   buildDisabledTextField(
//                                     'Cost',
//                                     '',
//                                     initialValue:
//                                         ingredients[index]["cost"].toString(),
//                                   ),
//                                   TextButton(
//                                     onPressed: () => setState(() {
//                                       String deleteIngredientId =
//                                           ingredients[index]
//                                               ["recipe_ingredient_id"];
//                                       confirmDelete(deleteIngredientId,
//                                           ingredients[index]["type"]);
//                                     }),
//                                     child: const Text('Delete Ingredient',
//                                         style: AppTextStyles.deleteFormat),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             );
//           }
//           return const Center(child: Text('No Data Available'));
//         },
//       ),
//     );
//   }

//   Widget buildDisabledTextField(String label, String hint,
// //initialValue,
//       {required initialValue}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           RichText(
//             text: TextSpan(
//               text: label,
//               style: AppTextStyles.labelFormat,
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             width: 340,
//             height: 40,
//             child: TextFormField(
//               initialValue: initialValue,
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle: AppTextStyles.valueFormat,
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                 disabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 fillColor: Color.fromRGBO(231, 231, 231, 1),
//                 filled: true,
//               ),
//               enabled: false,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     quantityController.dispose();
//     costController.dispose();
//     wastageController.dispose();
//     super.dispose();
//   }
// }

// class EditIngredientsTab extends StatelessWidget {
//   final String recipeId;

//   const EditIngredientsTab({super.key, required this.recipeId});

//   @override
//   Widget build(BuildContext context) {
//     return RecipeTabs(
//       initialIndex: 1,
//       tabViews: [
//         RecipeEditDetails(
//           recipeId: recipeId,
//         ),
//         EditIngredientDetails(
//           recipeId: recipeId,
//         ),
//         EditMethod(
//           recipeId: recipeId,
//         ),
//       ],
//     );
//   }
// }

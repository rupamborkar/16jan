import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Recipe/Edit_recipe/edit_ingredient_recipe.dart';
import 'package:margo/screens/Recipe/Edit_recipe/edit_method.dart';
import 'package:margo/screens/Recipe/Edit_recipe/edit_tabs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeEditDetails extends StatefulWidget {
  final String recipeId;

  const RecipeEditDetails({super.key, required this.recipeId});

  @override
  State<RecipeEditDetails> createState() => _RecipeEditDetailsState();
}

class _RecipeEditDetailsState extends State<RecipeEditDetails> {
  bool _isDataPopulated = false;
  final _formKey = GlobalKey<FormState>();

  String? selectedUnit;
  bool _useAsIngredient = false;
  String? comment;
  String? selectedCategory;
  List<String> selectedTags = [];

  final List<String> recipeCategory = ['Food', 'Beverage', 'Others']..sort();

  final List<String> tagList = [
    'Contains-Nuts',
    'Dairy-free',
    'Gluten-free',
    'Sugar-free',
    'Seafood',
    'Vegan',
    'Vegetarian',
    'Non-Vegetarian'
  ]..sort();

  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<Map<String, dynamic>?>? recipeData;
  String? _jwtToken;
  double totalFoodCost = 0.0;
  double initialFoodCost = 0.0;
  double initialWastageCost = 0.0;

  late TextEditingController recipeNameController;
  late TextEditingController categoryController;
  late TextEditingController tagController;
  late TextEditingController costController;
  late TextEditingController sellingPController;
  late TextEditingController taxController;
  late TextEditingController totfoodCController;
  late TextEditingController foodCostController;
  late TextEditingController wastageController;
  late TextEditingController netEController;
  late TextEditingController commentController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTokenAndFetchDetails();
  }

  void _initializeControllers() {
    recipeNameController = TextEditingController();
    categoryController = TextEditingController();
    tagController = TextEditingController();
    costController = TextEditingController();
    sellingPController = TextEditingController();
    taxController = TextEditingController();
    totfoodCController = TextEditingController();
    foodCostController = TextEditingController();
    wastageController = TextEditingController();
    netEController = TextEditingController();
    commentController = TextEditingController();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }

      setState(() {
        _jwtToken = token;
        recipeData = fetchRecipeDetails();
      });
    } catch (e) {
      print("Error loading token or fetching recipe details: $e");
    }
  }

  Future<Map<String, dynamic>> fetchRecipeDetails() async {
    if (_jwtToken == null) {
      throw Exception('JWT token is null');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
        },
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to load recipe data');
      }
    } catch (e) {
      throw Exception('Error fetching recipe data: $e');
    }
  }

  void _populateControllers(Map<String, dynamic> data) {
    initialFoodCost =
        double.tryParse(data['food_cost']?.toString() ?? '0') ?? 0.0;
    initialWastageCost =
        double.tryParse(data['wastage_cost']?.toString() ?? '0') ?? 0.0;
    totalFoodCost = initialFoodCost + initialWastageCost;

    recipeNameController.text = data['name'] ?? '';
    categoryController.text = data['category'] ?? '';

    tagController.text = (data['tags'] != null && data['tags'] is List)
        ? (data['tags'] as List)
            .map((tag) => tag.toString().replaceAll('"', '').trim())
            .join(', ')
        : '';

    costController.text = data['cost']?.toString() ?? '';
    sellingPController.text = data['selling_price']?.toString() ?? '';
    taxController.text = data['tax']?.toString() ?? '';
    totfoodCController.text = data['food_cost']?.toString() ?? '';
    foodCostController.text = data['food_cost']?.toString() ?? '';
    wastageController.text = data['wastage_cost']?.toString() ?? '';
    netEController.text = data['net_earnings']?.toString() ?? '';
    commentController.text = data['comments'] ?? '';
    _useAsIngredient = data['use_as_ingredient'] ?? false;
  }

  Future<void> updateRecipeDetails() async {
    if (_jwtToken == null) {
      throw Exception('JWT token is null');
    }

    if (_formKey.currentState?.validate() ?? false) {
      // List<String> updatedTags = selectedTags;
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
          headers: {
            'Authorization': 'Bearer $_jwtToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': recipeNameController.text,
            'category':
                (selectedCategory != null && selectedCategory!.isNotEmpty)
                    ? selectedCategory
                    : categoryController.text.isNotEmpty
                        ? categoryController.text
                        : null,
            'tags': selectedTags,
            // 'cost': costController.text,
            'selling_price': sellingPController.text,
            'tax': taxController.text,
            // 'food_cost': foodCController.text,
            'net_earnings': netEController.text,
            'comments': commentController.text,
            'use_as_ingredient': _useAsIngredient,
          }),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe updated successfully!')),
          );
          Navigator.of(context).pop(true);
        } else {
          throw Exception('Failed to update recipe');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating recipe: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: recipeData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Error loading recipe: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (snapshot.hasData) {
            final data = snapshot.data;
            if (data != null && !_isDataPopulated) {
              _populateControllers(data);
              _isDataPopulated = true;
            }

            return Form(
              key: _formKey,
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildTextField(
                              'Recipe Name *', recipeNameController),
                          const SizedBox(height: 15),
                          buildCategoryDropdownField(
                            'Category',
                            recipeCategory,
                            categoryController,
                            initialValue: data?['category'],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              ConstrainedBox(
                                constraints: const BoxConstraints(
                                  maxWidth: 200,
                                ),
                                child: buildDropdownField(
                                  'Tags',
                                  tagList,
                                  // tagController,
                                  initialValues: data?['tags'] is String
                                      ? (data!['tags'] as String).split(',')
                                      : (data?['tags'] as List<dynamic>?)
                                              ?.cast<String>() ??
                                          [],
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Use as Ingredient?',
                                      style: AppTextStyles.labelFormat,
                                    ),
                                    const SizedBox(height: 2),
                                    SizedBox(
                                      height: 40,
                                      child: ToggleButtons(
                                        isSelected: [
                                          _useAsIngredient,
                                          !_useAsIngredient
                                        ],
                                        onPressed: (int index) {
                                          setState(() {
                                            _useAsIngredient = index == 0;
                                            data?['use_as_ingredient'] =
                                                _useAsIngredient;
                                          });
                                        },
                                        color: Colors.black,
                                        selectedColor: const Color.fromRGBO(
                                            0, 128, 128, 1),
                                        fillColor: const Color.fromRGBO(
                                            230, 242, 242, 1),
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                        borderColor: const Color.fromRGBO(
                                            231, 231, 231, 1),
                                        selectedBorderColor:
                                            const Color.fromRGBO(
                                                0, 128, 128, 1),
                                        children: const [
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.0,
                                                vertical: 10.0),
                                            child: Text('Yes'),
                                          ),
                                          Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 18.0,
                                                vertical: 10.0),
                                            child: Text('No'),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildRowDisabledTextField(
                                      'Food Cost', foodCostController)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildRowDisabledTextField(
                                'Wastage Cost',
                                wastageController,
                              )),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildRowDisabledTextField(
                                'Total Food Cost',
                                //totfoodCController
                                //totalFoodCost as TextEditingController
                                TextEditingController(
                                  text: totalFoodCost.toStringAsFixed(2),
                                ),
                              )),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildRowTextField(
                                      'Tax', taxController,
                                      isNumber: true)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                  child: _buildRowTextField(
                                      'Selling Price', sellingPController,
                                      isNumber: true)),
                              const SizedBox(width: 8),
                              Expanded(
                                  child: _buildDisabledTextField(
                                      'Net Earnings', netEController)),
                            ],
                          ),
                          const SizedBox(height: 16),
                          _buildTextField(
                            'Comments',
                            commentController,
                            maxLines: 3,
                            onChanged: (value) {
                              comment = value;
                            },
                          ),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          updateRecipeDetails();
                        },
                        style: AppStyles.elevatedButtonStyle,
                        child: const Text(
                          'Update',
                          style: AppTextStyles.buttonText,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            );
          } else {
            return const Center(child: Text('No data found'));
          }
        },
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    //String hint,
    {
    bool isNumber = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return
        // Padding(
        //   padding: const EdgeInsets.only(bottom: 10.0),
        //   child:
        Column(
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
                    color: Color.fromRGBO(244, 67, 54, 1),
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
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              //hintText: hint,
              hintStyle: AppTextStyles.valueFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 168, style: BorderStyle.solid),
              ),
            ),
            textInputAction: TextInputAction.done,
            keyboardType: isNumber
                ? TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
            maxLines: maxLines,
            validator: (value) {
              if (label.contains('*') &&
                  (value == null || value.trim().isEmpty)) {
                return 'Enter the ${label.replaceAll('*', '').trim()}';
              }
              return null;
            },
          ),
        ),
      ],
    );
    // );
  }

  Widget _buildRowTextField(
    String label,
    TextEditingController controller,
    //String hint,
    {
    bool isNumber = false,
    int maxLines = 1,
    Function(String)? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
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
                      color: Color.fromRGBO(244, 67, 54, 1),
                      fontSize: 16.0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 160,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                //hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide:
                      const BorderSide(width: 168, style: BorderStyle.solid),
                ),
              ),
              textInputAction: TextInputAction.done,
              keyboardType: isNumber
                  ? TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              maxLines: maxLines,
              onChanged: onChanged,
              validator: (value) {
                if (label.contains('*') &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Enter the ${label.replaceAll('*', '').trim()}';
                }
                return null;
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget buildCategoryDropdownField(
      String label, List<String> items, TextEditingController controller,
      {required initialValue}) {
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
          width: 353,
          height: 40,
          child: DropdownSearch<String>(
            items: items,
            selectedItem: controller.text.isNotEmpty ? controller.text : null,
            enabled: true,
            onChanged: (newValue) {
              setState(() {
                selectedCategory = newValue;
                //controller.text = newValue ?? '';
              });
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'Select $label',
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: true, // Enables search box
              constraints: BoxConstraints(maxHeight: 300),
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search or select $label',
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

  Widget buildDropdownField(
    String label,
    List<String> items, {
    List<String>? initialValues,
  }) {
    if (initialValues != null && selectedTags.isEmpty) {
      selectedTags = List<String>.from(initialValues);
    }

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
          width: 353,
          child: DropdownSearch<String>.multiSelection(
            items: items,
            selectedItems: selectedTags,
            onChanged: (List<String> selectedItems) {
              setState(() {
                selectedTags = List<String>.from(selectedItems);
              });
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
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search or select $label',
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

  Widget _buildDisabledTextField(
    String label,
    TextEditingController controller,
  ) {
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
            width: 353,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintStyle: AppTextStyles.valueFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(width: 1.0, style: BorderStyle.solid)),
                fillColor: const Color.fromRGBO(231, 231, 231, 1),
                filled: true,
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRowDisabledTextField(
    String label,
    TextEditingController controller,
    //String hint
  ) {
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
            width: 160,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                //hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide:
                        const BorderSide(width: 1.0, style: BorderStyle.solid)),
                fillColor: const Color.fromRGBO(231, 231, 231, 1),
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
    recipeNameController.dispose();
    //categoryController.dispose();

    foodCostController.dispose();
    wastageController.dispose();
    commentController.dispose();
    super.dispose();
  }
}

// Main widget for EditIngredient with IngredientTabs
class EditDetailsTab extends StatelessWidget {
  final String recipeId;

  const EditDetailsTab({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return PopScope(
      onPopInvokedWithResult: (didPop, result) async {
        Navigator.pop(context);
        return Future.value();
      },
      child: RecipeTabs(
        //return RecipeTabs(
        initialIndex: 0,
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
      ),
    );
  }
}

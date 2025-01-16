import 'dart:convert';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:margo/constants/material.dart';

class EditIngredientsDetail extends StatefulWidget {
  final String ingredientId;
  final String jwtToken;

  const EditIngredientsDetail({
    required this.ingredientId,
    Key? key,
    required this.jwtToken,
  }) : super(key: key);

  @override
  State<EditIngredientsDetail> createState() => _EditIngredientsDetailState();
}

class _EditIngredientsDetailState extends State<EditIngredientsDetail> {
  bool _addToInventory = false;
  Map<String, dynamic>? ingredientData;
  final FlutterSecureStorage _storage = const FlutterSecureStorage();
  String? _jwtToken;
  List<Map<String, dynamic>> supplierList = [];
  String? selectedMetricUnit;
  String? selectedWeightUnit;
  String? selectedPriceUnit;
  String? selectedSupplierId;
  String? selectedCategory;
  String? selectedSubCategory;
  String? selectedUnit;
  double? pricePerSelectedUnit;
  double? pricePerUnit;
  String? selectedPricePerUnit;
  final List<String> categories = ['Food', 'Beverage', 'Others']..sort();
  final Map<String, List<String>> subCategoryOptions = {
    'Food': [
      'Salad',
      'Herb',
      'Vegetable',
      'Mushroom',
      'Fresh Nut',
      'Meat',
      'Fruit',
      'Seafood',
      'Cured Meat',
      'Cheese',
      'Dairy',
      'Dry Good',
      'grain',
      'Flour',
      'Spices',
      'Chocolate',
      'Bakery',
      'Grains/Seeds',
      'Nuts',
      'Sugar',
      'Dryfruits',
      'Dessert',
      'Snack'
    ],
    'Beverage': ['Alcohol', 'Drink', 'Cocktail', 'Mocktail'],
    'Others': ['Oil', 'Vinegar', 'Flower', 'Ice Cream', 'Consumable']
  };

  final List<String> massUnits = [
    'Metric Units ---',
    'Kg',
    'Oz',
    'L',
    'Non-Metric Units ---',
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
    'Cup',
    'Pint'
  ];
  final List<String> metricUnits = ['Kg', 'Oz', 'L'];

  late TextEditingController nameController;
  late TextEditingController categoryController;
  late TextEditingController subCategoryController;
  late TextEditingController supplierController;
  late TextEditingController supplierProductCController;
  late TextEditingController quantityController;
  late TextEditingController quantityUnitController;
  late TextEditingController weightController;
  late TextEditingController weightUnitController;
  late TextEditingController taxController;
  late TextEditingController priceController;
  late TextEditingController priceUnitController;
  late TextEditingController commentsController;

  final _formKey = GlobalKey<FormState>(); // Global key for the form

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadTokenAndFetchDetails();
  }

  void _initializeControllers() {
    nameController = TextEditingController();
    categoryController = TextEditingController();
    subCategoryController = TextEditingController();
    supplierController = TextEditingController();
    supplierProductCController = TextEditingController();
    quantityController = TextEditingController();
    quantityUnitController = TextEditingController();
    weightController = TextEditingController();
    weightUnitController = TextEditingController();
    taxController = TextEditingController();
    priceController = TextEditingController();
    priceUnitController = TextEditingController();
    commentsController = TextEditingController();
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

      await fetchIngredientDetails();
      fetchSupplierList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchIngredientDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/ingredients/${widget.ingredientId}/full'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          ingredientData = data;
          _populateControllers(data);
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

  Future<void> fetchSupplierList() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/supplier/supplier_list'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> suppData = json.decode(response.body);
        setState(() {
          supplierList = [
            {'name': 'None', 'id': null},
            ...suppData.map((supplier) {
              return {
                'name': supplier['name'],
                'id': supplier['supplier_id'],
              };
            }).toList(),
          ];

          supplierList.sort((a, b) => a['name'].compareTo(b['name']));
          print(supplierList);
        });

        if (ingredientData != null) {
          _populateControllers(ingredientData!);
        }
      } else {
        print(
            'Failed to load supplier data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
    }
  }

//   if (weightController.text.isEmpty) {
//   weightController.text.text = '0'; // Default value
// }

  void _populateControllers(Map<String, dynamic> data) {
    nameController.text = data['name'] ?? '';
    categoryController.text = data['category'] ?? '';
    subCategoryController.text = data['sub_category'] ?? '';
    supplierController.text = data['supplier'] ?? '';

    // final matchedSupplier = supplierList.firstWhere(
    //   (supplier) => supplier['name'] == data['supplier'],
    //   orElse: () => <String, dynamic>{},
    // );
    // selectedSupplierId = matchedSupplier != null ? matchedSupplier['id'] : null;

    if (supplierList.isNotEmpty) {
      final matchedSupplier = supplierList.firstWhere(
        (supplier) => supplier['name'] == data['supplier'],
        orElse: () => <String, dynamic>{}, // Return null if no match is found
      );

      // Set the supplier ID only if a matching supplier is found
      if (matchedSupplier != null) {
        selectedSupplierId = matchedSupplier['id'];
      } else {
        selectedSupplierId = null; // No matching supplier, set ID to null
      }
    } else {
      selectedSupplierId = null; // No suppliers available, set ID to null
    }

    supplierProductCController.text = data['product_code'] ?? '';
    quantityController.text = data['quantity_purchased']?.toString() ?? '';
    quantityUnitController.text = data['quantity_unit'] ?? '';

    weightController.text = data['each_selected_quantity']?.toString() ?? '';
    if (weightController.text.isEmpty) {
      weightController.text = '0';
    }
    weightUnitController.text = data['each_selected_unit'] ?? '';
    taxController.text = data['tax']?.toString() ?? '';

    //(data['quantity_unit'] == data['selected_unit_metric'])
    priceController.text =
        (data['quantity_unit'] == data['selected_unit_metric'])
            //(data['selected_unit_metric'] == data['each_selected_unit'])
            ? (data['price_per_unit']?.toString() ?? '')
            : (data['price_per_selected_unit']?.toString() ?? '');

    priceUnitController.text = data['selected_unit_metric'];
    commentsController.text = data['comments'] ?? '';
    _addToInventory = data['add_to_inventory'] ?? false;

    setState(() {
      selectedUnit = data['quantity_unit'];
      selectedWeightUnit = data['each_selected_unit'];
      selectedCategory = data['category'];
      selectedSubCategory = ingredientData?['sub_category'];
      selectedPriceUnit = data['selected_unit_metric'];
      pricePerSelectedUnit = data['price_per_selected_unit'];
      pricePerUnit = data['price_per_unit'];
    });
  }

  Future<void> _updateIngredientDetails() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        final response = await http.put(
          Uri.parse('$baseUrl/api/ingredients/${widget.ingredientId}'),
          headers: {
            'Authorization': 'Bearer $_jwtToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'name': nameController.text,
            'category': selectedCategory,
            // 'category': categoryController.text,
            // "sub_category": subCategoryController.text,
            "sub_category": selectedSubCategory,
            'supplier': selectedSupplierId,
            'product_code': supplierProductCController.text,
            'quantity_purchased': quantityController.text,
            "quantity_unit": quantityUnitController.text,

            "each_selected_quantity": weightController.text,
            // "each_selected_unit": weightUnitController.text,
            "each_selected_unit": selectedWeightUnit,
            'tax': taxController.text,
            'price_per_unit': priceController.text,
            'selected_unit_metric': selectedPriceUnit,
            //priceUnitController.text,
            //selectedPriceUnit,
            // 'selected_unit_metric': priceUnitController.text,
            'comments': commentsController.text,
            'cost': ingredientData?['cost'],
            'add_to_inventory': _addToInventory,
          }),
        );

        print(response.body);

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ingredient updated successfully!')),
          );

          Navigator.pop(context, true);
        } else if (response.statusCode == 403) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Ingredient with same name already exists')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update ingredient: ${response.body}')),
          );
        }
      } catch (error) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating ingredient: $error')),
        );
      }
    }
  }

  double Result = 0;
  void calculate() {
    final double price = double.tryParse(priceController.text) ?? 0;

    final double tax = double.tryParse(taxController.text) ?? 0;

    final double result = price + tax;

    setState(() {
      Result = result;
      ingredientData?['cost'] = Result;
    });

    print('Price: $price, Tax: $tax, Result: $Result');
  }

  @override
  Widget build(BuildContext context) {
    List<String> unitOptions = [];
    if (selectedUnit != null) {
      if (metricUnits.contains(selectedUnit)) {
        unitOptions = [selectedUnit!];
        selectedPriceUnit = selectedUnit;
      } else {
        unitOptions = [
          selectedUnit!,
          selectedWeightUnit ?? '',
        ];
      }
    }

    if (ingredientData == null) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: AppColors.hintColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
      ),

      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField('Ingredient Name *', nameController,
                  onSaved: (value) {}, onChanged: (value) {}),
              const SizedBox(height: 10),
              buildDropdownField(
                'Category *',
                categories,
                controller: TextEditingController(),
                selectedItem: ingredientData?['category'],
                onSaved: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedSubCategory = null;
                  });
                },
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value;
                    selectedSubCategory = null;
                  });
                  ingredientData?['category'] = selectedCategory;
                  ingredientData?['sub_category'] = null;
                  //categoryController = selectedCategory;
                },
              ),
              const SizedBox(height: 16),

              buildDropdownField(
                'Sub-Category',
                selectedCategory != null
                    ? subCategoryOptions[selectedCategory!] ?? []
                    : [],
                isEnabled: selectedCategory != null,
                showSearchBox: true,
                controller: subCategoryController,
                // selectedItem: ingredientData?['sub_category'],
                selectedItem: subCategoryController.text.isNotEmpty
                    ? subCategoryController.text
                    : null,

                onSaved: (value) {
                  setState(() {
                    selectedSubCategory = value;
                  });
                  ingredientData?['sub_category'] =
                      value?.isNotEmpty == true ? value : null;
                },
                onChanged: (value) {
                  setState(() {
                    selectedSubCategory = value;
                  });
                  ingredientData?['sub_category'] = selectedSubCategory;
                },
              ),
              const SizedBox(height: 10),

              buildSuppDropdownField(
                'Supplier',
                supplierList.map((e) => e['name']! as String).toList(),
                initialValue: ingredientData?['supplier'],
                onSaved: (value) {
                  final selectedSupplier = supplierList.firstWhere(
                    (supplier) => supplier['name'] == value,
                  );

                  supplierController =
                      (int.tryParse(selectedSupplier['id'] ?? '0') ?? 0)
                          as TextEditingController;
                  selectedSupplierId = selectedSupplier['id'];
                },
                onChanged: (value) {
                  final selectedSupplier = supplierList.firstWhere(
                    (supplier) => supplier['name'] == value,
                  );
                  setState(() {
                    selectedSupplierId = selectedSupplier['id'];
                    print(selectedSupplierId);
                  });
                },
              ),
              const SizedBox(height: 10),
              // _buildTextField(
              //     'Supplier Product Code', supplierProductCController,
              //     onSaved: (value) {}, onChanged: (value) {}),

              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ConstrainedBox(
                  //   constraints: const BoxConstraints(
                  //     maxWidth: 200,
                  //   ),
                  Expanded(
                    child: _buildTextField(
                        'Supplier Product Code', supplierProductCController,
                        onSaved: (value) {}, onChanged: (value) {}),
                  ),
                  //),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Add to Inventory?',
                          style: AppTextStyles.labelFormat,
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 40,
                          // width: 353,
                          child: ToggleButtons(
                            isSelected: [_addToInventory, !_addToInventory],
                            onPressed: (int index) {
                              setState(() {
                                _addToInventory = index == 0;
                                ingredientData?['add_to_inventory'] =
                                    _addToInventory;
                              });
                            },
                            color: Colors.black,
                            selectedColor: AppColors.buttonColor,
                            fillColor: const Color.fromRGBO(230, 242, 242, 1),
                            borderRadius: BorderRadius.circular(8.0),
                            borderColor: const Color.fromRGBO(231, 231, 231, 1),
                            selectedBorderColor: AppColors.buttonColor,
                            children: const [
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 0.0),
                                child: Text('On'),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: 20.0, vertical: 0.0),
                                child: Text('Off'),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              _buildQuantityAndUnitFields(
                  'Quantity Purchased *', quantityController),
              const SizedBox(height: 10),

              buildTextFieldWithDropdown(
                'Price *',
                priceController,
                isNumber: true,
                dynamicLabel: selectedUnit != null
                    ? (metricUnits.contains(selectedUnit)
                        ? 'Price Per $selectedUnit (\$)'
                        : (selectedWeightUnit != null
                            ? (selectedPriceUnit != null
                                ? 'Price Per $selectedPriceUnit (\$)'
                                : 'Price Per Unit (\$)')
                            : 'Price Per $selectedUnit (\$)'))
                    : 'Price Per Unit (\$)',
                priceFieldKey: 'price_per_unit (\$)',
                onPriceSaved: (value) {
                  ingredientData?['price_per_unit'] =
                      double.tryParse(value ?? '0') ?? 0.0;
                  calculate();
                },
                onPriceChanged: (value) {
                  setState(() {
                    ingredientData?['price_per_unit'] =
                        double.tryParse(value) ?? 0.0;
                  });
                  calculate();
                },
                unitFieldKey: 'unit',
                unitOptions: unitOptions,
                selectedPricePerUnit: metricUnits.contains(selectedUnit)
                    ? selectedUnit
                    : selectedPriceUnit,
                onUnitChanged: (value) {
                  setState(() {
                    selectedPriceUnit = value;
                    ingredientData?['selected_unit_metric'] = selectedPriceUnit;
                    // selectedUnit = value;
                  });
                  ingredientData?['selected_unit_metric'] = value;
                  //widget.data['selected_unit_metric'] = value;
                },
              ),
              const SizedBox(height: 10),
              _buildTextField(
                'Tax (%) *',
                taxController,
                isNumber: true,
                onSaved: (value) {
                  ingredientData?['tax'] = double.tryParse(value ?? '1') ?? 1;
                  calculate();
                },
                onChanged: (value) {
                  setState(() {
                    ingredientData?['tax'] = double.tryParse(value) ?? 1;
                  });
                  calculate();
                },
              ),

              const SizedBox(height: 10),
              _buildTextField('Comments', commentsController,
                  onChanged: (value) {}, onSaved: (value) {}),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
      //),
      //Padding(
      bottomNavigationBar: Padding(
        // padding: const EdgeInsets.all(16.0),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          //width: double.infinity,
          width: 353,
          height: 50,
          child: ElevatedButton(
            onPressed: () {
              _updateIngredientDetails();
              // Handle update logic here
            },
            style: AppStyles.elevatedButtonStyle,
            child: const Text(
              'Update',
              style: AppTextStyles.buttonText,
            ),
          ),
        ),
      ),
    );
  }

  Widget buildTextFieldWithDropdown(
    String labelText,
    // String placeholder,
    TextEditingController controller, {
    required String priceFieldKey,
    required Function(String?) onPriceSaved,
    required Function(String) onPriceChanged,
    required String unitFieldKey,
    required List<String> unitOptions,
    String? selectedPricePerUnit,
    required Function(String?) onUnitChanged,
    String? dynamicLabel,
    bool isNumber = false,
    // required initialValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Padding(
        //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
        //   child:
        RichText(
          text: TextSpan(
            text: dynamicLabel ?? labelText.replaceAll('*', ''),
            style: AppTextStyles.labelFormat,
            children: [
              if (labelText.contains('*'))
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
        //),
        // Padding(
        //   padding: const EdgeInsets.all(4.0),
        //   child:
        Row(
          children: [
            Expanded(
              child: SizedBox(
                height: 40,
                child: TextFormField(
                  //  initialValue: initialValue,
                  // key: Key(priceFieldKey),
                  controller: controller,
                  decoration: InputDecoration(
                    // hintText: placeholder,
                    hintStyle: AppTextStyles.hintFormat,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                  ),
                  keyboardType: isNumber
                      ? const TextInputType.numberWithOptions(decimal: true)
                      : TextInputType.text,
                  onSaved: onPriceSaved,
                  onChanged: onPriceChanged,
                  validator: (value) {
                    if (labelText.contains('*') &&
                        (value == null || value.trim().isEmpty)) {
                      return '${labelText.replaceAll('*', '').trim()} is required';
                    }

                    if (isNumber) {
                      final parsedValue = double.tryParse(value ?? '0');
                      if (parsedValue == null || parsedValue <= 0) {
                        return '${labelText.replaceAll('*', '').trim()} must be greater than 0';
                      }
                    }
                    return null;
                  },
                  textInputAction: TextInputAction.done,
                ),
              ),
            ),
            const SizedBox(width: 3),
            const Text('Per'),
            const SizedBox(width: 3),
            //const SizedBox(width: 8),
            Expanded(
              child: metricUnits.contains(selectedUnit)
                  ? SizedBox(
                      height: 40,
                      child: TextFormField(
                        //initialValue: selectedUnit!,
                        controller: TextEditingController(text: selectedUnit),
                        style: AppTextStyles.labelFormat,
                        decoration: InputDecoration(
                          // hintText: placeholder,
                          hintStyle: AppTextStyles.hintFormat,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                        ),
                        onChanged: (value) {
                          setState(() {
                            selectedUnit = value;
                            selectedPriceUnit = value;
                            //selectedPriceUnit = selectedUnit;
                          });
                          ingredientData?['selected_unit_metric'] =
                              selectedUnit;
                        },
                        onSaved: (value) {
                          ingredientData?['selected_unit_metric'] = value;
                          selectedPriceUnit = value;
                        },
                        enabled: false,
                      ),
                    )
                  : SizedBox(
                      height: 40,
                      child: DropdownButtonFormField<String>(
                        isExpanded: true,
                        hint: const Text(
                          'Unit',
                          style: AppTextStyles.hintFormat,
                        ),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              vertical: 4.0, horizontal: 8.0),
                        ),
                        // value: selectedPricePerUnit,
                        //value: priceUnitController.text,
                        value: selectedPriceUnit,
                        items: unitOptions.map((unit) {
                          return DropdownMenuItem(
                            value: unit,
                            child: Text(unit),
                          );
                        }).toList(),
                        onChanged: (value) {
                          if (value != null) {
                            onUnitChanged(value);
                          }
                          //widget.data['selected_unit'] = value;
                        },
                        onSaved: (value) {
                          onUnitChanged(value);
                          // widget.data['selected_unit'] = value;
                        },
                        validator: (value) {
                          if (labelText.contains('*') &&
                              (value == null || value.trim().isEmpty)) {
                            return '${labelText.replaceAll('*', '').trim()} is required';
                          }
                          return null;
                        },
                      ),
                    ),
            ),
          ],
        ),
        //),
      ],
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {bool isNumber = false,
      required Null Function(dynamic value) onSaved,
      required Null Function(dynamic value) onChanged,
      String? dynamicLabel}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: dynamicLabel ?? label.replaceAll('*', ''),
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
          child: TextFormField(
            controller: controller,
            decoration: InputDecoration(
              hintStyle: AppTextStyles.valueFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide:
                    const BorderSide(width: 1.0, style: BorderStyle.solid),
              ),
            ),
            textInputAction: TextInputAction.done,
            keyboardType: isNumber
                ? const TextInputType.numberWithOptions(decimal: true)
                : TextInputType.text,
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
  }

  Widget buildDropdownField(
    String label,
    List<String> items, {
    required TextEditingController controller,
    required Function(String?) onSaved,
    Function(String?)? onChanged,
    bool isEnabled = true,
    bool showSearchBox = false,
    String? selectedItem,
    // required initialValue
  }) {
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
            // selectedItem: initialValue,
            selectedItem: selectedItem,
            enabled: isEnabled,
            onChanged: isEnabled
                ? (value) {
                    if (onChanged != null) {
                      onChanged(value);
                    }

                    if (value != null &&
                        value.isNotEmpty &&
                        !items.contains(value)) {
                      setState(() {
                        items.add(value);

                        if (selectedCategory != null) {
                          subCategoryOptions[selectedCategory!] = items;
                        }
                      });
                    }
                  }
                : null,
            onSaved: (value) {
              onSaved(value);
            },
            validator: (value) {
              if (label.contains('*') &&
                  isEnabled &&
                  (value == null || value.trim().isEmpty)) {
                return '${label.replaceAll('*', '').trim()} is required';
              }
              return null;
            },
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText:
                    isEnabled ? 'Select $label' : 'Select a Category first',
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
            popupProps: PopupProps.menu(
              showSearchBox: showSearchBox,
              constraints: const BoxConstraints(
                  maxWidth: 300,
                  maxHeight:
                      300 // Set the desired width for the dropdown items box
                  ),
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search or Add Subcategories',
                  hintStyle: AppTextStyles.hintFormat,
                  prefixIcon:
                      const Icon(Icons.search), // Add the search icon here
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
              emptyBuilder: (context, searchEntry) {
                return Center(
                  child: GestureDetector(
                    onTap: () {
                      if (searchEntry != null && searchEntry.isNotEmpty) {
                        setState(() {
                          if (!items.contains(searchEntry)) {
                            items.add(searchEntry);
                          }
                          selectedSubCategory = searchEntry;
                          if (selectedCategory != null) {
                            subCategoryOptions[selectedCategory!] = items;
                          }

                          if (onChanged != null) {
                            onChanged(searchEntry);
                          }
                        });
                      }
                    },
                    child: Text(
                        'No data found for "$searchEntry". Tap to add it.',
                        style: AppTextStyles.labelBoldFormat),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildQuantityAndUnitFields(
      String label, TextEditingController controller) {
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
        //),
        const SizedBox(height: 8.0),

        Row(
          children: [
            Expanded(
              child: SizedBox(
                width: 120,
                height: 40,
                child: TextFormField(
                  controller: controller,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter quantity',
                    hintStyle: AppTextStyles.hintFormat,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                  ),
                  textInputAction: TextInputAction.done,
                  // onChanged: (value) {
                  //   quantityController.text = value;
                  // },
                  validator: (value) {
                    if (label.contains('*') &&
                        (value == null || value.trim().isEmpty)) {
                      return '${label.replaceAll('*', '').trim()} is required';
                    }
                    return null;
                  },
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                width: 180,
                height: 40,
                child: DropdownSearch<String>(
                  items: massUnits,
                  selectedItem: selectedUnit,
                  onChanged: (value) {
                    setState(() {
                      selectedUnit = value;
                      selectedMetricUnit =
                          metricUnits.contains(value) ? value : null;
                      quantityUnitController.text = value ?? '';
                      selectedPriceUnit = null;
                      // selectedPriceUnit =
                      //     metricUnits.contains(value) ? value : null;
                      selectedPricePerUnit = null;
                    });
                  },
                  validator: (value) {
                    if (label.contains('*') &&
                        (value == null || value.trim().isEmpty)) {
                      return '${label.replaceAll('*', '').trim()} is required';
                    }
                    return null;
                  },
                  dropdownDecoratorProps: DropDownDecoratorProps(
                    dropdownSearchDecoration: InputDecoration(
                      hintText: 'Select unit',
                      hintStyle: AppTextStyles.hintFormat,
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  popupProps: PopupProps.menu(
                    showSearchBox: true, // Enables search box
                    constraints: const BoxConstraints(maxHeight: 300),
                    searchFieldProps: TextFieldProps(
                      decoration: InputDecoration(
                        hintText: 'Search or select unit',
                        hintStyle: AppTextStyles.hintFormat,
                        prefixIcon: const Icon(Icons.search),
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
            ),
          ],
        ),

        if (selectedUnit != null && !metricUnits.contains(selectedUnit!)) ...[
          const SizedBox(height: 16.0),
          // _buildNonMetricField(selectedUnit!),
          _buildNonMetricField(selectedUnit!, 'Each $selectedUnit has *'),
        ],
      ],
    );
  }

  Widget _buildNonMetricField(String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Text(
        //   'Each $unit has',
        //   style: AppTextStyles.labelFormat,
        // ),
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
        Row(
          children: [
            Expanded(
              child: SizedBox(
                width: 120,
                height: 40,
                child: TextFormField(
                  controller: weightController,
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    hintText: 'Enter quantity',
                    hintStyle: AppTextStyles.hintFormat,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (label.contains('*') &&
                        (value == null || value.trim().isEmpty)) {
                      return '${label.replaceAll('*', '').trim()} is required';
                    }
                    return null;
                  },
                  onSaved: (value) {},
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: SizedBox(
                width: 180,
                height: 40,
                child: DropdownButtonFormField<String>(
                  value: metricUnits.contains(selectedWeightUnit)
                      ? selectedWeightUnit
                      : null,
                  hint: const Text(
                    'Select unit',
                    style: AppTextStyles.hintFormat,
                  ),
                  items: metricUnits.map((unit) {
                    return DropdownMenuItem<String>(
                      value: unit,
                      child: Text(unit),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      //selectedMetricUnit = value;
                      selectedWeightUnit = value;
                      ingredientData?['each_selected_unit'] = value;
                      // selectedMetricUnit = value;
                      selectedPriceUnit = null;
                      selectedPricePerUnit = null;
                      ingredientData?['selected_unit_metric'] = null;
                    });
                  },
                  validator: (value) {
                    if (label.contains('*') &&
                        (value == null || value.trim().isEmpty)) {
                      return '${label.replaceAll('*', '').trim()} is required';
                    }
                    return null;
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 4.0, horizontal: 8.0),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget buildSuppDropdownField(
    String label,
    List<String> items, {
    required Function(String?) onSaved,
    Function(String?)? onChanged,
    required initialValue,
  }) {
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
            selectedItem: initialValue,
            items: items,
            dropdownDecoratorProps: DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'Select $label',
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            onChanged: onChanged,
            //onSaved: onSaved,
            onSaved: (value) {
              if (value == 'None') {
                onSaved(null); // Save null if "None" is selected
              } else {
                onSaved(value); // Otherwise, save the selected value
              }
            },
            popupProps: PopupProps.menu(
              showSearchBox: true,
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  labelText: 'Search $label',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            // menuMaxHeight: 400,
          ),
        ),
      ],
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    categoryController.dispose();
    supplierController.dispose();
    priceController.dispose();
    super.dispose();
  }
}




// import 'dart:convert';
// import 'package:dropdown_search/dropdown_search.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:margo/constants/material.dart';

// class EditIngredientsDetail extends StatefulWidget {
//   final String ingredientId;
//   final String jwtToken;

//   const EditIngredientsDetail({
//     required this.ingredientId,
//     Key? key,
//     required this.jwtToken,
//   }) : super(key: key);

//   @override
//   State<EditIngredientsDetail> createState() => _EditIngredientsDetailState();
// }

// class _EditIngredientsDetailState extends State<EditIngredientsDetail> {
//   bool _addToInventory = false;
//   Map<String, dynamic>? ingredientData;
//   final FlutterSecureStorage _storage = const FlutterSecureStorage();
//   String? _jwtToken;
//   List<Map<String, dynamic>> supplierList = [];
//   String? selectedMetricUnit;
//   String? selectedWeightUnit;
//   String? selectedPriceUnit;
//   String? selectedSupplierId;
//   String? selectedCategory;
//   String? selectedSubCategory;
//   String? selectedUnit;
//   double? pricePerSelectedUnit;
//   double? pricePerUnit;
//   String? selectedPricePerUnit;
//   final List<String> categories = ['Food', 'Beverage', 'Others']..sort();
//   final Map<String, List<String>> subCategoryOptions = {
//     'Food': [
//       'Salad',
//       'Herb',
//       'Vegetable',
//       'Mushroom',
//       'Fresh Nut',
//       'Meat',
//       'Fruit',
//       'Seafood',
//       'Cured Meat',
//       'Cheese',
//       'Dairy',
//       'Dry Good',
//       'grain',
//       'Flour',
//       'Spices',
//       'Chocolate',
//       'Bakery',
//       'Grains/Seeds',
//       'Nuts',
//       'Sugar',
//       'Dryfruits',
//       'Dessert',
//       'Snack'
//     ],
//     'Beverage': ['Alcohol', 'Drink', 'Cocktail', 'Mocktail'],
//     'Others': ['Oil', 'Vinegar', 'Flower', 'Ice Cream', 'Consumable']
//   };

//   final List<String> massUnits = [
//     'Metric Units ---',
//     'Kg',
//     'Oz',
//     'L',
//     'Non-Metric Units ---',
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
//     'Cup',
//     'Pint'
//   ];
//   final List<String> metricUnits = ['Kg', 'Oz', 'L'];

//   late TextEditingController nameController;
//   late TextEditingController categoryController;
//   late TextEditingController subCategoryController;
//   late TextEditingController supplierController;
//   late TextEditingController supplierProductCController;
//   late TextEditingController quantityController;
//   late TextEditingController quantityUnitController;
//   late TextEditingController weightController;
//   late TextEditingController weightUnitController;
//   late TextEditingController taxController;
//   late TextEditingController priceController;
//   late TextEditingController priceUnitController;
//   late TextEditingController commentsController;

//   final _formKey = GlobalKey<FormState>(); // Global key for the form

//   @override
//   void initState() {
//     super.initState();
//     _initializeControllers();
//     _loadTokenAndFetchDetails();
//   }

//   void _initializeControllers() {
//     nameController = TextEditingController();
//     categoryController = TextEditingController();
//     subCategoryController = TextEditingController();
//     supplierController = TextEditingController();
//     supplierProductCController = TextEditingController();
//     quantityController = TextEditingController();
//     quantityUnitController = TextEditingController();
//     weightController = TextEditingController();
//     weightUnitController = TextEditingController();
//     taxController = TextEditingController();
//     priceController = TextEditingController();
//     priceUnitController = TextEditingController();
//     commentsController = TextEditingController();
//   }

//   Future<void> _loadTokenAndFetchDetails() async {
//     try {
//       final token = await _storage.read(key: 'jwt_token');
//       if (token == null) {
//         throw Exception("JWT token not found. Please log in again.");
//       }
//       setState(() {
//         _jwtToken = token;
//       });

//       await fetchIngredientDetails();
//       fetchSupplierList();
//     } catch (e) {
//       print("Error loading token or fetching ingredient details: $e");
//     }
//   }

//   Future<void> fetchIngredientDetails() async {
//     if (_jwtToken == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/ingredients/${widget.ingredientId}/full'),
//         headers: {'Authorization': 'Bearer $_jwtToken'},
//       );

//       if (response.statusCode == 200) {
//         final data = json.decode(response.body);
//         setState(() {
//           ingredientData = data;
//           _populateControllers(data);
//         });
//       } else {
//         print(
//             'Failed to load ingredient data. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching ingredient data: $e');
//     }
//   }

//   Future<void> fetchSupplierList() async {
//     if (_jwtToken == null) return;

//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/supplier/supplier_list'),
//         headers: {'Authorization': 'Bearer $_jwtToken'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> suppData = json.decode(response.body);
//         setState(() {
//           supplierList = [
//             {'name': 'None', 'id': null},
//             ...suppData.map((supplier) {
//               return {
//                 'name': supplier['name'],
//                 'id': supplier['supplier_id'],
//               };
//             }).toList(),
//           ];

//           supplierList.sort((a, b) => a['name'].compareTo(b['name']));
//           print(supplierList);
//         });

//         if (ingredientData != null) {
//           _populateControllers(ingredientData!);
//         }
//       } else {
//         print(
//             'Failed to load supplier data. Status code: ${response.statusCode}');
//       }
//     } catch (e) {
//       print('Error fetching supplier data: $e');
//     }
//   }

// //   if (weightController.text.isEmpty) {
// //   weightController.text.text = '0'; // Default value
// // }

//   void _populateControllers(Map<String, dynamic> data) {
//     nameController.text = data['name'] ?? '';
//     categoryController.text = data['category'] ?? '';
//     subCategoryController.text = data['sub_category'] ?? '';
//     supplierController.text = data['supplier'] ?? '';

//     // final matchedSupplier = supplierList.firstWhere(
//     //   (supplier) => supplier['name'] == data['supplier'],
//     //   orElse: () => <String, dynamic>{},
//     // );
//     // selectedSupplierId = matchedSupplier != null ? matchedSupplier['id'] : null;

//     if (supplierList.isNotEmpty) {
//       final matchedSupplier = supplierList.firstWhere(
//         (supplier) => supplier['name'] == data['supplier'],
//         orElse: () => <String, dynamic>{}, // Return null if no match is found
//       );

//       // Set the supplier ID only if a matching supplier is found
//       if (matchedSupplier != null) {
//         selectedSupplierId = matchedSupplier['id'];
//       } else {
//         selectedSupplierId = null; // No matching supplier, set ID to null
//       }
//     } else {
//       selectedSupplierId = null; // No suppliers available, set ID to null
//     }

//     supplierProductCController.text = data['product_code'] ?? '';
//     quantityController.text = data['quantity_purchased']?.toString() ?? '';
//     quantityUnitController.text = data['quantity_unit'] ?? '';

//     weightController.text = data['each_selected_quantity']?.toString() ?? '';
//     if (weightController.text.isEmpty) {
//       weightController.text = '0';
//     }
//     weightUnitController.text = data['each_selected_unit'] ?? '';
//     taxController.text = data['tax']?.toString() ?? '';

//     //(data['quantity_unit'] == data['selected_unit_metric'])
//     priceController.text =
//         (data['quantity_unit'] == data['selected_unit_metric'])
//             //(data['selected_unit_metric'] == data['each_selected_unit'])
//             ? (data['price_per_unit']?.toString() ?? '')
//             : (data['price_per_selected_unit']?.toString() ?? '');

//     priceUnitController.text = data['selected_unit_metric'];
//     commentsController.text = data['comments'] ?? '';
//     _addToInventory = data['add_to_inventory'] ?? false;

//     setState(() {
//       selectedUnit = data['quantity_unit'];
//       selectedWeightUnit = data['each_selected_unit'];
//       selectedCategory = data['category'];
//       selectedSubCategory = ingredientData?['sub_category'];
//       selectedPriceUnit = data['selected_unit_metric'];
//       pricePerSelectedUnit = data['price_per_selected_unit'];
//       pricePerUnit = data['price_per_unit'];
//     });
//   }

//   Future<void> _updateIngredientDetails() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       try {
//         final response = await http.put(
//           Uri.parse('$baseUrl/api/ingredients/${widget.ingredientId}'),
//           headers: {
//             'Authorization': 'Bearer $_jwtToken',
//             'Content-Type': 'application/json',
//           },
//           body: jsonEncode({
//             'name': nameController.text,
//             'category': selectedCategory,
//             // 'category': categoryController.text,
//             // "sub_category": subCategoryController.text,
//             "sub_category": selectedSubCategory,
//             'supplier': selectedSupplierId,
//             'product_code': supplierProductCController.text,
//             'quantity_purchased': quantityController.text,
//             "quantity_unit": quantityUnitController.text,

//             "each_selected_quantity": weightController.text,
//             // "each_selected_unit": weightUnitController.text,
//             "each_selected_unit": selectedWeightUnit,
//             'tax': taxController.text,
//             'price_per_unit': priceController.text,
//             'selected_unit_metric': selectedPriceUnit,
//             //priceUnitController.text,
//             //selectedPriceUnit,
//             // 'selected_unit_metric': priceUnitController.text,
//             'comments': commentsController.text,
//             'cost': ingredientData?['cost'],
//             'add_to_inventory': _addToInventory,
//           }),
//         );

//         print(response.body);

//         if (response.statusCode == 200 || response.statusCode == 201) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Ingredient updated successfully!')),
//           );

//           Navigator.pop(context, true);
//         } else if (response.statusCode == 403) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('Ingredient with same name already exists')),
//           );
//         } else {
//           ScaffoldMessenger.of(context).showSnackBar(
//             SnackBar(
//                 content: Text('Failed to update ingredient: ${response.body}')),
//           );
//         }
//       } catch (error) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error updating ingredient: $error')),
//         );
//       }
//     }
//   }

//   double Result = 0;
//   void calculate() {
//     final double price = double.tryParse(priceController.text) ?? 0;

//     final double tax = double.tryParse(taxController.text) ?? 0;

//     final double result = price + tax;

//     setState(() {
//       Result = result;
//       ingredientData?['cost'] = Result;
//     });

//     print('Price: $price, Tax: $tax, Result: $Result');
//   }

//   @override
//   Widget build(BuildContext context) {
//     List<String> unitOptions = [];
//     if (selectedUnit != null) {
//       if (metricUnits.contains(selectedUnit)) {
//         unitOptions = [selectedUnit!];
//         selectedPriceUnit = selectedUnit;
//       } else {
//         unitOptions = [
//           selectedUnit!,
//           selectedWeightUnit ?? '',
//         ];
//       }
//     }

//     if (ingredientData == null) {
//       return const Scaffold(
//         body: Center(
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Edit',
//           style: AppTextStyles.heading,
//         ),
//         centerTitle: true,
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             size: 15,
//             color: AppColors.hintColor,
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//       ),

//       body: SingleChildScrollView(
//         padding: const EdgeInsets.all(20.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField('Ingredient Name *', nameController,
//                   onSaved: (value) {}, onChanged: (value) {}),
//               const SizedBox(height: 10),
//               buildDropdownField(
//                 'Category *',
//                 categories,
//                 controller: TextEditingController(),
//                 selectedItem: ingredientData?['category'],
//                 onSaved: (value) {
//                   setState(() {
//                     selectedCategory = value;
//                     selectedSubCategory = null;
//                   });
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     selectedCategory = value;
//                     selectedSubCategory = null;
//                   });
//                   ingredientData?['category'] = selectedCategory;
//                   ingredientData?['sub_category'] = null;
//                   //categoryController = selectedCategory;
//                 },
//               ),
//               const SizedBox(height: 16),

//               buildDropdownField(
//                 'Sub-Category',
//                 selectedCategory != null
//                     ? subCategoryOptions[selectedCategory!] ?? []
//                     : [],
//                 isEnabled: selectedCategory != null,
//                 showSearchBox: true,
//                 controller: subCategoryController,
//                 // selectedItem: ingredientData?['sub_category'],
//                 selectedItem: subCategoryController.text.isNotEmpty
//                     ? subCategoryController.text
//                     : null,

//                 onSaved: (value) {
//                   setState(() {
//                     selectedSubCategory = value;
//                   });
//                   ingredientData?['sub_category'] =
//                       value?.isNotEmpty == true ? value : null;
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     selectedSubCategory = value;
//                   });
//                   ingredientData?['sub_category'] = selectedSubCategory;
//                 },
//               ),
//               const SizedBox(height: 10),

//               buildSuppDropdownField(
//                 'Supplier',
//                 supplierList.map((e) => e['name']! as String).toList(),
//                 initialValue: ingredientData?['supplier'],
//                 onSaved: (value) {
//                   final selectedSupplier = supplierList.firstWhere(
//                     (supplier) => supplier['name'] == value,
//                   );

//                   supplierController =
//                       (int.tryParse(selectedSupplier['id'] ?? '0') ?? 0)
//                           as TextEditingController;
//                   selectedSupplierId = selectedSupplier['id'];
//                 },
//                 onChanged: (value) {
//                   final selectedSupplier = supplierList.firstWhere(
//                     (supplier) => supplier['name'] == value,
//                   );
//                   setState(() {
//                     selectedSupplierId = selectedSupplier['id'];
//                     print(selectedSupplierId);
//                   });
//                 },
//               ),
//               const SizedBox(height: 10),
//               // _buildTextField(
//               //     'Supplier Product Code', supplierProductCController,
//               //     onSaved: (value) {}, onChanged: (value) {}),

//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // ConstrainedBox(
//                   //   constraints: const BoxConstraints(
//                   //     maxWidth: 200,
//                   //   ),
//                   Expanded(
//                     child: _buildTextField(
//                         'Supplier Product Code', supplierProductCController,
//                         onSaved: (value) {}, onChanged: (value) {}),
//                   ),
//                   //),
//                   const SizedBox(width: 14),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text(
//                           'Add to Inventory?',
//                           style: AppTextStyles.labelFormat,
//                         ),
//                         const SizedBox(height: 8),
//                         SizedBox(
//                           height: 40,
//                           // width: 353,
//                           child: ToggleButtons(
//                             isSelected: [_addToInventory, !_addToInventory],
//                             onPressed: (int index) {
//                               setState(() {
//                                 _addToInventory = index == 0;
//                                 ingredientData?['add_to_inventory'] =
//                                     _addToInventory;
//                               });
//                             },
//                             color: Colors.black,
//                             selectedColor: AppColors.buttonColor,
//                             fillColor: const Color.fromRGBO(230, 242, 242, 1),
//                             borderRadius: BorderRadius.circular(8.0),
//                             borderColor: const Color.fromRGBO(231, 231, 231, 1),
//                             selectedBorderColor: AppColors.buttonColor,
//                             children: const [
//                               Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 20.0, vertical: 0.0),
//                                 child: Text('On'),
//                               ),
//                               Padding(
//                                 padding: EdgeInsets.symmetric(
//                                     horizontal: 20.0, vertical: 0.0),
//                                 child: Text('Off'),
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 10),
//               _buildQuantityAndUnitFields(
//                   'Quantity Purchased *', quantityController),
//               const SizedBox(height: 10),

//               buildTextFieldWithDropdown(
//                 'Price *',
//                 priceController,
//                 isNumber: true,
//                 dynamicLabel: selectedUnit != null
//                     ? (metricUnits.contains(selectedUnit)
//                         ? 'Price Per $selectedUnit (\$)'
//                         : (selectedWeightUnit != null
//                             ? (selectedPriceUnit != null
//                                 ? 'Price Per $selectedPriceUnit (\$)'
//                                 : 'Price Per Unit (\$)')
//                             : 'Price Per $selectedUnit (\$)'))
//                     : 'Price Per Unit (\$)',
//                 priceFieldKey: 'price_per_unit (\$)',
//                 onPriceSaved: (value) {
//                   ingredientData?['price_per_unit'] =
//                       double.tryParse(value ?? '0') ?? 0.0;
//                   calculate();
//                 },
//                 onPriceChanged: (value) {
//                   setState(() {
//                     ingredientData?['price_per_unit'] =
//                         double.tryParse(value) ?? 0.0;
//                   });
//                   calculate();
//                 },
//                 unitFieldKey: 'unit',
//                 unitOptions: unitOptions,
//                 selectedPricePerUnit: metricUnits.contains(selectedUnit)
//                     ? selectedUnit
//                     : selectedPriceUnit,
//                 onUnitChanged: (value) {
//                   setState(() {
//                     selectedPriceUnit = value;
//                     ingredientData?['selected_unit_metric'] = selectedPriceUnit;
//                     // selectedUnit = value;
//                   });
//                   ingredientData?['selected_unit_metric'] = value;
//                   //widget.data['selected_unit_metric'] = value;
//                 },
//               ),
//               const SizedBox(height: 10),
//               _buildTextField(
//                 'Tax (%) *',
//                 taxController,
//                 isNumber: true,
//                 onSaved: (value) {
//                   ingredientData?['tax'] = double.tryParse(value ?? '1') ?? 1;
//                   calculate();
//                 },
//                 onChanged: (value) {
//                   setState(() {
//                     ingredientData?['tax'] = double.tryParse(value) ?? 1;
//                   });
//                   calculate();
//                 },
//               ),

//               const SizedBox(height: 10),
//               _buildTextField('Comments', commentsController,
//                   onChanged: (value) {}, onSaved: (value) {}),
//               const SizedBox(height: 10),
//             ],
//           ),
//         ),
//       ),
//       //),
//       //Padding(
//       bottomNavigationBar: Padding(
//         // padding: const EdgeInsets.all(16.0),
//         padding: EdgeInsets.only(
//           left: 16,
//           right: 16,
//           bottom: MediaQuery.of(context).viewInsets.bottom + 16,
//         ),
//         child: SizedBox(
//           //width: double.infinity,
//           width: 353,
//           height: 50,
//           child: ElevatedButton(
//             onPressed: () {
//               _updateIngredientDetails();
//               // Handle update logic here
//             },
//             style: AppStyles.elevatedButtonStyle,
//             child: const Text(
//               'Update',
//               style: AppTextStyles.buttonText,
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildTextFieldWithDropdown(
//     String labelText,
//     // String placeholder,
//     TextEditingController controller, {
//     required String priceFieldKey,
//     required Function(String?) onPriceSaved,
//     required Function(String) onPriceChanged,
//     required String unitFieldKey,
//     required List<String> unitOptions,
//     String? selectedPricePerUnit,
//     required Function(String?) onUnitChanged,
//     String? dynamicLabel,
//     bool isNumber = false,
//     // required initialValue,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Padding(
//         //   padding: const EdgeInsets.symmetric(horizontal: 4.0),
//         //   child:
//         RichText(
//           text: TextSpan(
//             text: dynamicLabel ?? labelText.replaceAll('*', ''),
//             style: AppTextStyles.labelFormat,
//             children: [
//               if (labelText.contains('*'))
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
//         //),
//         // Padding(
//         //   padding: const EdgeInsets.all(4.0),
//         //   child:
//         Row(
//           children: [
//             Expanded(
//               child: SizedBox(
//                 height: 40,
//                 child: TextFormField(
//                   //  initialValue: initialValue,
//                   // key: Key(priceFieldKey),
//                   controller: controller,
//                   decoration: InputDecoration(
//                     // hintText: placeholder,
//                     hintStyle: AppTextStyles.hintFormat,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 4.0, horizontal: 8.0),
//                   ),
//                   keyboardType: isNumber
//                       ? const TextInputType.numberWithOptions(decimal: true)
//                       : TextInputType.text,
//                   onSaved: onPriceSaved,
//                   onChanged: onPriceChanged,
//                   validator: (value) {
//                     if (labelText.contains('*') &&
//                         (value == null || value.trim().isEmpty)) {
//                       return '${labelText.replaceAll('*', '').trim()} is required';
//                     }

//                     if (isNumber) {
//                       final parsedValue = double.tryParse(value ?? '0');
//                       if (parsedValue == null || parsedValue <= 0) {
//                         return '${labelText.replaceAll('*', '').trim()} must be greater than 0';
//                       }
//                     }
//                     return null;
//                   },
//                   textInputAction: TextInputAction.done,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 3),
//             const Text('Per'),
//             const SizedBox(width: 3),
//             //const SizedBox(width: 8),
//             Expanded(
//               child: metricUnits.contains(selectedUnit)
//                   ? SizedBox(
//                       height: 40,
//                       child: TextFormField(
//                         initialValue: selectedUnit!,
//                         style: AppTextStyles.labelFormat,
//                         decoration: InputDecoration(
//                           // hintText: placeholder,
//                           hintStyle: AppTextStyles.hintFormat,
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 4.0, horizontal: 8.0),
//                         ),
//                         onChanged: (value) {
//                           setState(() {
//                             selectedUnit = value;
//                             selectedPriceUnit = value;
//                             //selectedPriceUnit = selectedUnit;
//                             //Added
//                           });
//                           ingredientData?['selected_unit_metric'] =
//                               selectedUnit;
//                         },
//                         onSaved: (value) {
//                           ingredientData?['selected_unit_metric'] = value;
//                           selectedPriceUnit = value;
//                         },
//                         enabled: false,
//                       ),
//                     )
//                   : SizedBox(
//                       height: 40,
//                       child: DropdownButtonFormField<String>(
//                         isExpanded: true,
//                         hint: const Text(
//                           'Unit',
//                           style: AppTextStyles.hintFormat,
//                         ),
//                         decoration: InputDecoration(
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(8),
//                           ),
//                           contentPadding: const EdgeInsets.symmetric(
//                               vertical: 4.0, horizontal: 8.0),
//                         ),
//                         // value: selectedPricePerUnit,
//                         //value: priceUnitController.text,
//                         value: selectedPriceUnit,
//                         items: unitOptions.map((unit) {
//                           return DropdownMenuItem(
//                             value: unit,
//                             child: Text(unit),
//                           );
//                         }).toList(),
//                         onChanged: (value) {
//                           if (value != null) {
//                             onUnitChanged(value);
//                           }
//                           //widget.data['selected_unit'] = value;
//                         },
//                         onSaved: (value) {
//                           onUnitChanged(value);
//                           // widget.data['selected_unit'] = value;
//                         },
//                         validator: (value) {
//                           if (labelText.contains('*') &&
//                               (value == null || value.trim().isEmpty)) {
//                             return '${labelText.replaceAll('*', '').trim()} is required';
//                           }
//                           return null;
//                         },
//                       ),
//                     ),
//             ),
//           ],
//         ),
//         //),
//       ],
//     );
//   }

//   Widget _buildTextField(String label, TextEditingController controller,
//       {bool isNumber = false,
//       required Null Function(dynamic value) onSaved,
//       required Null Function(dynamic value) onChanged,
//       String? dynamicLabel}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: dynamicLabel ?? label.replaceAll('*', ''),
//             style: AppTextStyles.labelFormat,
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
//           child: TextFormField(
//             controller: controller,
//             decoration: InputDecoration(
//               hintStyle: AppTextStyles.valueFormat,
//               contentPadding:
//                   const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//               border: OutlineInputBorder(
//                 borderRadius: BorderRadius.circular(8.0),
//                 borderSide:
//                     const BorderSide(width: 1.0, style: BorderStyle.solid),
//               ),
//             ),
//             textInputAction: TextInputAction.done,
//             keyboardType: isNumber
//                 ? const TextInputType.numberWithOptions(decimal: true)
//                 : TextInputType.text,
//             validator: (value) {
//               if (label.contains('*') &&
//                   (value == null || value.trim().isEmpty)) {
//                 return 'Enter the ${label.replaceAll('*', '').trim()}';
//               }
//               return null;
//             },
//           ),
//         ),
//       ],
//     );
//   }

//   Widget buildDropdownField(
//     String label,
//     List<String> items, {
//     required TextEditingController controller,
//     required Function(String?) onSaved,
//     Function(String?)? onChanged,
//     bool isEnabled = true,
//     bool showSearchBox = false,
//     String? selectedItem,
//     // required initialValue
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label.replaceAll('*', ''),
//             style: AppTextStyles.labelFormat,
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
//           child: DropdownSearch<String>(
//             items: items,
//             // selectedItem: initialValue,
//             selectedItem: selectedItem,
//             enabled: isEnabled,
//             onChanged: isEnabled
//                 ? (value) {
//                     if (onChanged != null) {
//                       onChanged(value);
//                     }

//                     if (value != null &&
//                         value.isNotEmpty &&
//                         !items.contains(value)) {
//                       setState(() {
//                         items.add(value);

//                         if (selectedCategory != null) {
//                           subCategoryOptions[selectedCategory!] = items;
//                         }
//                       });
//                     }
//                   }
//                 : null,
//             onSaved: (value) {
//               onSaved(value);
//             },
//             validator: (value) {
//               if (label.contains('*') &&
//                   isEnabled &&
//                   (value == null || value.trim().isEmpty)) {
//                 return '${label.replaceAll('*', '').trim()} is required';
//               }
//               return null;
//             },
//             dropdownDecoratorProps: DropDownDecoratorProps(
//               dropdownSearchDecoration: InputDecoration(
//                 hintText:
//                     isEnabled ? 'Select $label' : 'Select a Category first',
//                 hintStyle: AppTextStyles.hintFormat,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                 border: OutlineInputBorder(
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//               ),
//             ),
//             popupProps: PopupProps.menu(
//               showSearchBox: showSearchBox,
//               constraints: const BoxConstraints(
//                   maxWidth: 300,
//                   maxHeight:
//                       300 // Set the desired width for the dropdown items box
//                   ),
//               searchFieldProps: TextFieldProps(
//                 decoration: InputDecoration(
//                   hintText: 'Search or Add Subcategories',
//                   hintStyle: AppTextStyles.hintFormat,
//                   prefixIcon:
//                       const Icon(Icons.search), // Add the search icon here
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(10),
//                   ),
//                   contentPadding: const EdgeInsets.symmetric(
//                       vertical: 4.0, horizontal: 8.0),
//                 ),
//               ),
//               itemBuilder: (context, item, isSelected) {
//                 return ListTile(
//                   title: Text(item),
//                   selected: isSelected,
//                 );
//               },
//               emptyBuilder: (context, searchEntry) {
//                 return Center(
//                   child: GestureDetector(
//                     onTap: () {
//                       if (searchEntry != null && searchEntry.isNotEmpty) {
//                         setState(() {
//                           if (!items.contains(searchEntry)) {
//                             items.add(searchEntry);
//                           }
//                           selectedSubCategory = searchEntry;
//                           if (selectedCategory != null) {
//                             subCategoryOptions[selectedCategory!] = items;
//                           }

//                           if (onChanged != null) {
//                             onChanged(searchEntry);
//                           }
//                         });
//                       }
//                     },
//                     child: Text(
//                         'No data found for "$searchEntry". Tap to add it.',
//                         style: AppTextStyles.labelBoldFormat),
//                   ),
//                 );
//               },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildQuantityAndUnitFields(
//       String label, TextEditingController controller) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label.replaceAll('*', ''),
//             style: AppTextStyles.labelFormat,
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
//         //),
//         const SizedBox(height: 8.0),

//         Row(
//           children: [
//             Expanded(
//               child: SizedBox(
//                 width: 120,
//                 height: 40,
//                 child: TextFormField(
//                   controller: controller,
//                   keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                   decoration: InputDecoration(
//                     hintText: 'Enter quantity',
//                     hintStyle: AppTextStyles.hintFormat,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 4.0, horizontal: 8.0),
//                   ),
//                   textInputAction: TextInputAction.done,
//                   // onChanged: (value) {
//                   //   quantityController.text = value;
//                   // },
//                   validator: (value) {
//                     if (label.contains('*') &&
//                         (value == null || value.trim().isEmpty)) {
//                       return '${label.replaceAll('*', '').trim()} is required';
//                     }
//                     return null;
//                   },
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: SizedBox(
//                 width: 180,
//                 height: 40,
//                 child: DropdownSearch<String>(
//                   items: massUnits,
//                   selectedItem: selectedUnit,
//                   onChanged: (value) {
//                     setState(() {
//                       selectedUnit = value;
//                       selectedMetricUnit =
//                           metricUnits.contains(value) ? value : null;
//                       quantityUnitController.text = value ?? '';
//                       selectedPriceUnit = null;
//                       // selectedPriceUnit =
//                       //     metricUnits.contains(value) ? value : null;
//                       selectedPricePerUnit = null;
//                     });
//                   },
//                   validator: (value) {
//                     if (label.contains('*') &&
//                         (value == null || value.trim().isEmpty)) {
//                       return '${label.replaceAll('*', '').trim()} is required';
//                     }
//                     return null;
//                   },
//                   dropdownDecoratorProps: DropDownDecoratorProps(
//                     dropdownSearchDecoration: InputDecoration(
//                       hintText: 'Select unit',
//                       hintStyle: AppTextStyles.hintFormat,
//                       contentPadding: const EdgeInsets.symmetric(
//                           vertical: 4.0, horizontal: 8.0),
//                       border: OutlineInputBorder(
//                         borderRadius: BorderRadius.circular(8),
//                       ),
//                     ),
//                   ),
//                   popupProps: PopupProps.menu(
//                     showSearchBox: true, // Enables search box
//                     constraints: const BoxConstraints(maxHeight: 300),
//                     searchFieldProps: TextFieldProps(
//                       decoration: InputDecoration(
//                         hintText: 'Search or select unit',
//                         hintStyle: AppTextStyles.hintFormat,
//                         prefixIcon: const Icon(Icons.search),
//                         border: OutlineInputBorder(
//                           borderRadius: BorderRadius.circular(10),
//                         ),
//                         contentPadding: const EdgeInsets.symmetric(
//                             vertical: 4.0, horizontal: 8.0),
//                       ),
//                     ),

//                     itemBuilder: (context, item, isSelected) {
//                       if (item.endsWith('---')) {
//                         return DropdownMenuItem<String>(
//                           value: null,
//                           enabled: false,
//                           child: Padding(
//                             padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
//                             child: Text(
//                               item.replaceAll(' ---', ''),
//                               style: const TextStyle(
//                                 fontWeight: FontWeight.bold,
//                                 color: Colors.grey,
//                               ),
//                             ),
//                           ),
//                         );
//                       }
//                       return ListTile(
//                         title: Text(item),
//                         selected: isSelected,
//                       );
//                     },
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),

//         if (selectedUnit != null && !metricUnits.contains(selectedUnit!)) ...[
//           const SizedBox(height: 16.0),
//           // _buildNonMetricField(selectedUnit!),
//           _buildNonMetricField(selectedUnit!, 'Each $selectedUnit has *'),
//         ],
//       ],
//     );
//   }

//   Widget _buildNonMetricField(String unit, String label) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // Text(
//         //   'Each $unit has',
//         //   style: AppTextStyles.labelFormat,
//         // ),
//         RichText(
//           text: TextSpan(
//             text: label.replaceAll('*', ''),
//             style: AppTextStyles.labelFormat,
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
//         Row(
//           children: [
//             Expanded(
//               child: SizedBox(
//                 width: 120,
//                 height: 40,
//                 child: TextFormField(
//                   controller: weightController,
//                   keyboardType:
//                       const TextInputType.numberWithOptions(decimal: true),
//                   decoration: InputDecoration(
//                     hintText: 'Enter quantity',
//                     hintStyle: AppTextStyles.hintFormat,
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 4.0, horizontal: 8.0),
//                   ),
//                   textInputAction: TextInputAction.done,
//                   validator: (value) {
//                     if (label.contains('*') &&
//                         (value == null || value.trim().isEmpty)) {
//                       return '${label.replaceAll('*', '').trim()} is required';
//                     }
//                     return null;
//                   },
//                   onSaved: (value) {},
//                 ),
//               ),
//             ),
//             const SizedBox(width: 10),
//             Expanded(
//               child: SizedBox(
//                 width: 180,
//                 height: 40,
//                 child: DropdownButtonFormField<String>(
//                   value: metricUnits.contains(selectedWeightUnit)
//                       ? selectedWeightUnit
//                       : null,
//                   hint: const Text(
//                     'Select unit',
//                     style: AppTextStyles.hintFormat,
//                   ),
//                   items: metricUnits.map((unit) {
//                     return DropdownMenuItem<String>(
//                       value: unit,
//                       child: Text(unit),
//                     );
//                   }).toList(),
//                   onChanged: (value) {
//                     setState(() {
//                       //selectedMetricUnit = value;
//                       selectedWeightUnit = value;
//                       ingredientData?['each_selected_unit'] = value;
//                       // selectedMetricUnit = value;
//                       selectedPriceUnit = null;
//                       selectedPricePerUnit = null;
//                       ingredientData?['selected_unit_metric'] = null;
//                     });
//                   },
//                   validator: (value) {
//                     if (label.contains('*') &&
//                         (value == null || value.trim().isEmpty)) {
//                       return '${label.replaceAll('*', '').trim()} is required';
//                     }
//                     return null;
//                   },
//                   decoration: InputDecoration(
//                     border: OutlineInputBorder(
//                       borderRadius: BorderRadius.circular(8),
//                     ),
//                     contentPadding: const EdgeInsets.symmetric(
//                         vertical: 4.0, horizontal: 8.0),
//                   ),
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget buildSuppDropdownField(
//     String label,
//     List<String> items, {
//     required Function(String?) onSaved,
//     Function(String?)? onChanged,
//     required initialValue,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         RichText(
//           text: TextSpan(
//             text: label.replaceAll('*', ''),
//             style: AppTextStyles.labelFormat,
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
//           child: DropdownSearch<String>(
//             selectedItem: initialValue,
//             items: items,
//             dropdownDecoratorProps: DropDownDecoratorProps(
//               dropdownSearchDecoration: InputDecoration(
//                 hintText: 'Select $label',
//                 hintStyle: AppTextStyles.hintFormat,
//                 contentPadding:
//                     const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//               ),
//             ),
//             onChanged: onChanged,
//             //onSaved: onSaved,
//             onSaved: (value) {
//               if (value == 'None') {
//                 onSaved(null); // Save null if "None" is selected
//               } else {
//                 onSaved(value); // Otherwise, save the selected value
//               }
//             },
//             popupProps: PopupProps.menu(
//               showSearchBox: true,
//               searchFieldProps: TextFieldProps(
//                 decoration: InputDecoration(
//                   labelText: 'Search $label',
//                   prefixIcon: const Icon(Icons.search),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(8),
//                   ),
//                 ),
//               ),
//             ),
//             // menuMaxHeight: 400,
//           ),
//         ),
//       ],
//     );
//   }

//   @override
//   void dispose() {
//     nameController.dispose();
//     categoryController.dispose();
//     supplierController.dispose();
//     priceController.dispose();
//     super.dispose();
//   }
// }

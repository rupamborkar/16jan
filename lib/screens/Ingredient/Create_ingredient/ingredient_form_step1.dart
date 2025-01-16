import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Ingredient/Create_ingredient/form_fields.dart';
import 'package:dropdown_search/dropdown_search.dart';

class IngredientFormStep1 extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final Map<String, dynamic> data;

  const IngredientFormStep1({
    required this.formKey,
    required this.data,
    super.key,
  });

  @override
  State<IngredientFormStep1> createState() => _IngredientFormStep1State();
}

class _IngredientFormStep1State extends State<IngredientFormStep1> {
  bool _addToInventory = false;
  String? selectedMetricUnit;
  String? selectedWeightUnit;
  String? selectedPriceUnit;
  String? selectedUnit;
  String? selectedSupplierId;
  String? selectedCategory;
  String? selectedSubCategory;
  bool isSubcategoryEnabled = false;
  String? _jwtToken;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<Map<String, dynamic>> supplierList = [];
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
  ];
  final List<String> metricUnits = ['Kg', 'Oz', 'L'];

  double Result = 0.0;
  void calculate() {
    final double price = widget.data['price'] is double
        ? widget.data['price'] as double
        : double.tryParse(widget.data['price'].toString()) ?? 0.0;

    final double tax = widget.data['tax'] is double
        ? widget.data['tax'] as double
        : double.tryParse(widget.data['tax'].toString()) ?? 0.0;

    final double result = price + ((price * tax) / 100);

    setState(() {
      Result = result;
      widget.data['cost'] = Result;
    });

    print('Price: $price, Quantity: $tax, Result: $Result');
  }

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

      await fetchSupplierList();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
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
            {'name': 'None', 'id': null}, // Add 'None' option
            ...suppData.map((supplier) {
              return {
                'name': supplier['name'],
                'id': supplier['supplier_id'],
              };
            }).toList(),
          ];
          // supplierList = suppData.map((supplier) {
          //   return {
          //     'name': supplier['name'],
          //     'id': supplier['supplier_id'],
          //   };
          // }).toList();

          supplierList.sort((a, b) => a['name'].compareTo(b['name']));
        });
      } else {
        print(
            'Failed to load supplier data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    List<String> unitOptions = [];
    if (selectedUnit != null) {
      if (metricUnits.contains(selectedUnit)) {
        unitOptions = [selectedUnit!];
      } else {
        unitOptions = [
          selectedUnit!,
          selectedWeightUnit ?? '',
        ];
      }
    }
    return Scaffold(
        body: Form(
            key: widget.formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Text(
                    'Basic Details',
                    style: AppTextStyles.labelBoldFormat,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Column(
                      children: [
                        buildTextField(
                          'Ingredient Name *',
                          'e.g. Carrot, Almond',
                          onSaved: (value) {
                            widget.data['name'] = value;
                          },
                          onChanged: (value) {
                            widget.data['name'] = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        buildDropdownField(
                          'Category *',
                          categories,
                          showSearchBox: false,
                          selectedItem: selectedCategory,
                          onSaved: (value) {
                            widget.data['category'] = value!;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedCategory = value;
                              selectedSubCategory = null;
                            });
                            widget.data['category'] = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        // buildDropdownField(
                        //   'SubCategory',
                        //   selectedCategory != null
                        //       ? subCategoryOptions[selectedCategory!] ?? []
                        //       : [],
                        //   isEnabled: selectedCategory != null,
                        //   showSearchBox: true,
                        //   selectedItem: selectedSubCategory,
                        //   onSaved: (value) {
                        //     setState(() {
                        //       selectedSubCategory = value;
                        //     });
                        //     widget.data['sub_category'] = value!;
                        //   },
                        //   onChanged: (value) {
                        //     setState(() {
                        //       selectedSubCategory = value;
                        //     });
                        //     widget.data['sub_category'] = value;
                        //   },
                        // ),

                        buildDropdownField(
                          'SubCategory',
                          selectedCategory != null
                              ? subCategoryOptions[selectedCategory!] ?? []
                              : [],
                          isEnabled: selectedCategory != null,
                          showSearchBox: true,
                          selectedItem: selectedSubCategory,
                          onSaved: (value) {
                            setState(() {
                              selectedSubCategory = value;
                            });
                            widget.data['sub_category'] =
                                value?.isNotEmpty == true ? value : null;
                            // widget.data['sub_category'] = value!;
                          },
                          onChanged: (value) {
                            setState(() {
                              selectedSubCategory = value;
                            });
                            widget.data['sub_category'] =
                                value?.isNotEmpty == true ? value : null;
                            // widget.data['sub_category'] = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        // buildSuppDropdownField(
                        //   'Supplier',
                        //   supplierList
                        //       .map((e) => e['name']! as String)
                        //       .toList(),
                        //   onSaved: (value) {

                        //     final selectedSupplier = supplierList.firstWhere(
                        //       (supplier) => supplier['name'] == value,
                        //     );
                        //     widget.data['supplier_id'] =
                        //         int.tryParse(selectedSupplier['id'] ?? '0') ??
                        //             0;
                        //   },
                        //   onChanged: (value) {
                        //     final selectedSupplier = supplierList.firstWhere(
                        //       (supplier) => supplier['name'] == value,
                        //     );
                        //     setState(() {
                        //       selectedSupplierId = selectedSupplier['id'];
                        //     });
                        //     widget.data['supplier_id'] =
                        //         int.tryParse(selectedSupplier['id'] ?? '0') ??
                        //             0;
                        //   },
                        // ),

                        buildSuppDropdownField(
                          'Supplier',
                          supplierList
                              .map((e) => e['name']! as String)
                              .toList(),
                          onSaved: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value == 'None') {
                              //if (value == null || value.trim().isEmpty) {
                              widget.data['supplier_id'] = null;
                            } else {
                              final selectedSupplier = supplierList.firstWhere(
                                (supplier) => supplier['name'] == value,
                                orElse: () => <String, dynamic>{},
                              );
                              widget.data['supplier_id'] =
                                  selectedSupplier != null
                                      ? int.tryParse(
                                              selectedSupplier['id'] ?? '0') ??
                                          0
                                      : null;
                            }
                          },
                          onChanged: (value) {
                            if (value == null ||
                                value.trim().isEmpty ||
                                value == 'None') {
                              // if (value == null || value.trim().isEmpty) {
                              setState(() {
                                selectedSupplierId = null;
                              });
                              widget.data['supplier_id'] = null;
                            } else {
                              final selectedSupplier = supplierList.firstWhere(
                                (supplier) => supplier['name'] == value,
                                orElse: () => <String, dynamic>{},
                              );
                              setState(() {
                                selectedSupplierId = selectedSupplier?['id'];
                              });
                              widget.data['supplier_id'] =
                                  selectedSupplier != null
                                      ? int.tryParse(
                                              selectedSupplier['id'] ?? '0') ??
                                          0
                                      : null;
                            }
                          },
                        ),
                        const SizedBox(height: 16),

                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // ConstrainedBox(
                            //   constraints: const BoxConstraints(
                            //     maxWidth: 200,
                            //   ),
                            Expanded(
                              child: buildTextField(
                                'Supplier Product Code',
                                'e.g. CB12234',
                                onSaved: (value) {
                                  widget.data['product_code'] = value;
                                },
                                onChanged: (value) {
                                  widget.data['product_code'] = value;
                                },
                              ),
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
                                      isSelected: [
                                        _addToInventory,
                                        !_addToInventory
                                      ],
                                      onPressed: (int index) {
                                        setState(() {
                                          _addToInventory = index == 0;
                                          widget.data['add_to_inventory'] =
                                              _addToInventory;
                                        });
                                      },
                                      color: Colors.black,
                                      selectedColor: AppColors.buttonColor,
                                      fillColor: const Color.fromRGBO(
                                          230, 242, 242, 1),
                                      borderRadius: BorderRadius.circular(8.0),
                                      borderColor: const Color.fromRGBO(
                                          231, 231, 231, 1),
                                      selectedBorderColor:
                                          AppColors.buttonColor,
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
                        // buildTextField(
                        //   'Supplier Product Code',
                        //   'e.g. CB12234',
                        //   onSaved: (value) {
                        //     widget.data['product_code'] = value;
                        //   },
                        //   onChanged: (value) {
                        //     widget.data['product_code'] = value;
                        //   },
                        // ),
                        const SizedBox(height: 16),
                        _buildQuantityAndUnitFields('Quantity Purchased *'),
                        const SizedBox(height: 16),
                        buildTextFieldWithDropdown(
                          'Price *',
                          'Enter price',
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
                            widget.data['price_per_unit'] =
                                double.tryParse(value ?? '0') ?? 0.0;
                            calculate();
                          },
                          onPriceChanged: (value) {
                            setState(() {
                              widget.data['price_per_unit'] =
                                  double.tryParse(value) ?? 0.0;
                            });
                            calculate();
                          },
                          unitFieldKey: 'unit',
                          unitOptions: unitOptions,
                          selectedPricePerUnit:
                              metricUnits.contains(selectedUnit)
                                  ? selectedUnit
                                  : selectedPriceUnit,
                          onUnitChanged: (value) {
                            setState(() {
                              selectedPriceUnit = value;
                            });
                            widget.data['selected_unit_metric'] = value;
                          },
                        ),
                        const SizedBox(height: 16),
                        buildTextField(
                          'Tax (%) *',
                          'Enter a tax %',
                          isNumber: true,
                          onSaved: (value) {
                            widget.data['tax'] =
                                double.tryParse(value ?? '1') ?? 0.0;
                            calculate();
                          },
                          onChanged: (value) {
                            setState(() {
                              widget.data['tax'] =
                                  double.tryParse(value) ?? 0.0;
                            });
                            calculate();
                          },
                        ),
                        const SizedBox(height: 16),
                        buildTextField(
                          'Comments',
                          'Enter the comments',
                          onSaved: (value) {
                            widget.data['comments'] = value;
                          },
                          onChanged: (value) {
                            widget.data['comments'] = value;
                          },
                        ),
                        const SizedBox(height: 16),
                      ],
                    ),
                  ),
                ),
              ],
            )));
  }

  Widget buildTextFieldWithDropdown(
    String labelText,
    String placeholder, {
    required String priceFieldKey,
    required Function(String?) onPriceSaved,
    required Function(String) onPriceChanged,
    required String unitFieldKey,
    required List<String> unitOptions,
    String? selectedPricePerUnit,
    required Function(String?) onUnitChanged,
    String? dynamicLabel,
    bool isNumber = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: RichText(
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
        ),
        Padding(
          padding: const EdgeInsets.all(6.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    decoration: InputDecoration(
                      hintText: placeholder,
                      hintStyle: AppTextStyles.hintFormat,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 4.0, horizontal: 8.0),
                    ),
                    keyboardType: isNumber
                        ? TextInputType.numberWithOptions(decimal: true)
                        : TextInputType.text,
                    onSaved: onPriceSaved,
                    onChanged: onPriceChanged,
                    validator: (value) {
                      if (labelText.contains('*') &&
                          (value == null || value.trim().isEmpty)) {
                        return '${labelText.replaceAll('*', '').trim()} is required';
                      }
                      return null;
                    },
                    textInputAction: TextInputAction.done,
                  ),
                ),
              ),
              SizedBox(width: 3),
              const Text('Per'),
              SizedBox(width: 3),
              //SizedBox(width: 8),
              Expanded(
                child: metricUnits.contains(selectedUnit)
                    ? SizedBox(
                        height: 40,
                        child: TextFormField(
                          //initialValue: selectedUnit!,
                          controller: TextEditingController(text: selectedUnit),
                          style: AppTextStyles.labelFormat,
                          decoration: InputDecoration(
                            hintText: placeholder,
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
                            });
                            widget.data['selected_unit_metric'] = value;
                          },
                          onSaved: (value) {
                            widget.data['selected_unit_metric'] = value;
                          },
                          enabled: false,
                        ),
                      )
                    // Text(
                    //     selectedUnit!,
                    //     style: AppTextStyles.labelFormat,
                    //   )
                    : SizedBox(
                        height: 40,
                        child: DropdownButtonFormField<String>(
                          isExpanded: true,
                          hint: Text(
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
                          value: selectedPricePerUnit,
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
                            widget.data['selected_unit_metric'] = value;
                          },
                          onSaved: (value) {
                            onUnitChanged(value);
                            widget.data['selected_unit_metric'] = value;
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
        ),
      ],
    );
  }

  Widget buildDropdownField(
    String label,
    List<String> items, {
    required Function(String?) onSaved,
    Function(String?)? onChanged,
    bool isEnabled = true,
    bool showSearchBox = false,
    String? selectedItem,
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
              showSearchBox: showSearchBox, // Enables search box
              constraints: BoxConstraints(
                  maxWidth: 300,
                  maxHeight:
                      300 // Set the desired width for the dropdown items box
                  ),
              searchFieldProps: TextFieldProps(
                decoration: InputDecoration(
                  hintText: 'Search or Add Subcategories',
                  hintStyle: AppTextStyles.hintFormat,
                  prefixIcon: Icon(Icons.search), // Add the search icon here
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

  Widget _buildQuantityAndUnitFields(String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: RichText(
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
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
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
                    onSaved: (value) {
                      widget.data['quantity'] =
                          double.tryParse(value ?? '1') ?? 1.0;
                    },
                    onChanged: (value) {
                      widget.data['quantity'] =
                          double.tryParse(value ?? '1') ?? 1.0;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: DropdownSearch<String>(
                    items: massUnits,
                    selectedItem: selectedUnit,
                    enabled: true,
                    onChanged: (value) {
                      setState(() {
                        selectedUnit = value;
                        selectedMetricUnit =
                            metricUnits.contains(value) ? value : null;
                        selectedPriceUnit = null;
                      });
                      widget.data['quantity_unit'] = value;
                    },
                    onSaved: (value) {
                      widget.data['quantity_unit'] = value;
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
                      constraints: BoxConstraints(maxHeight: 300),
                      searchFieldProps: TextFieldProps(
                        decoration: InputDecoration(
                          hintText: 'Search or select unit',
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
        ),
        if (selectedUnit != null && !metricUnits.contains(selectedUnit!)) ...[
          const SizedBox(height: 16.0),
          _buildNonMetricField(selectedUnit!, 'Each $selectedUnit has *'),
        ],
      ],
    );
  }

  Widget _buildNonMetricField(String unit, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: RichText(
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
        ),
        const SizedBox(height: 8.0),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 6.0),
          child: Row(
            children: [
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: TextFormField(
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
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
                    onSaved: (value) {
                      widget.data['each_selected_quantity'] =
                          double.tryParse(value ?? '1') ?? 1.0;
                    },
                    onChanged: (value) {
                      widget.data['each_selected_quantity'] =
                          double.tryParse(value ?? '1') ?? 1.0;
                    },
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: SizedBox(
                  height: 40,
                  child: DropdownButtonFormField<String>(
                    isExpanded: true,
                    value: selectedWeightUnit,
                    //selectedMetricUnit,
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
                        selectedWeightUnit = value;
                        widget.data['each_selected_unit'] = value;
                        // selectedMetricUnit = value;
                        selectedPriceUnit = null;
                        widget.data['selected_unit_metric'] = null;
                      });
                      widget.data['each_selected_unit'] = value;
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
        ),
      ],
    );
  }
}

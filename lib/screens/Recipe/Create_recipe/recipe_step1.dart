import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Recipe/Create_recipe/widgets.dart';

class RecipeStep1 extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  //final VoidCallback nextStep;
  final Future<void> Function() saveRecipe;

  const RecipeStep1({
    super.key,
    required this.recipeData,
    //required this.nextStep,
    required this.saveRecipe,
  });

  @override
  State<RecipeStep1> createState() => _RecipeStep1State();
}

class _RecipeStep1State extends State<RecipeStep1> {
  final _formKey = GlobalKey<FormState>();
  bool _useAsIngredient = false;
  String? selectedUnit;
  final List<String> massUnits = [
    'Metric Units ---',
    'kg',
    'oz',
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
  final List<String> RecipeCategory = ['Food', 'Beverage', 'Others']..sort();
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Form(
      key: _formKey,
      child: Scaffold(
        body: Column(
          children: [
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
              alignment: Alignment.centerLeft,
              child: const Text(
                'Basic Details',
                style: AppTextStyles.labelBoldFormat,
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.04),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    buildDisabledTextField(
                      'Recipe Name *',
                      widget.recipeData['name'] ?? 'N/A',
                      onChanged: (value) => widget.recipeData['name'] = value,
                    ),
                    // buildTextField(
                    //   'Recipe Name *',
                    //   'Enter the name of the recipe',
                    //   onChanged: (value) => widget.recipeData['name'] = value,
                    // ),
                    const SizedBox(height: 16),
                    buildCategoryDropdownField(
                      'Category',
                      RecipeCategory,
                      onChanged: (value) =>
                          widget.recipeData['category'] = value,
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
                          child: buildDropdownField(
                            'Tags',
                            tagList,
                            onChanged: (selectedTags) {
                              widget.recipeData['tags'] =
                                  selectedTags; // Save selected tags
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
                                'Use as Ingredient?',
                                style: AppTextStyles.labelFormat,
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 40,
                                // width: 353,
                                child: ToggleButtons(
                                  isSelected: [
                                    _useAsIngredient,
                                    !_useAsIngredient
                                  ],
                                  onPressed: (int index) {
                                    setState(() {
                                      _useAsIngredient = index == 0;
                                      widget.recipeData['use_as_ingredient'] =
                                          _useAsIngredient;
                                    });
                                  },
                                  color: Colors.black,
                                  selectedColor: AppColors.buttonColor,
                                  fillColor:
                                      const Color.fromRGBO(230, 242, 242, 1),
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderColor:
                                      const Color.fromRGBO(231, 231, 231, 1),
                                  selectedBorderColor: AppColors.buttonColor,
                                  children: const [
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 0.0),
                                      child: Text('Yes'),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 20.0, vertical: 0.0),
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
                    //]),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: buildRowDisabledTextField(
                          'Food Cost',
                          widget.recipeData['food_cost'] ?? 'N/A',
                          onChanged: (value) =>
                              widget.recipeData['food_cost'] = value,
                        )),
                        const SizedBox(width: 14),
                        Expanded(
                            child: buildRowDisabledTextField(
                          'Wastage Cost',
                          widget.recipeData['wastage_cost'] ?? 'N/A',
                          onChanged: (value) =>
                              widget.recipeData['wastage_cost'] = value,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Expanded(
                            child: buildRowDisabledTextField(
                          'Total Food Cost',
                          widget.recipeData['total_food_cost'] ?? 'N/A',
                          onChanged: (value) =>
                              widget.recipeData['total_food_cost'] = value,
                        )),
                        const SizedBox(width: 14),
                        Expanded(
                            child: buildRowTextField(
                          'Tax',
                          'Enter tax%',
                          isNumber: true,
                          onChanged: (value) =>
                              widget.recipeData['tax'] = value,
                        )),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                            child: buildRowTextField(
                          'Selling Price *',
                          'e.g. 12.00',
                          isNumber: true,
                          onChanged: (value) =>
                              widget.recipeData['selling_price'] = value,
                        )),
                        const SizedBox(width: 14),
                        Expanded(
                          child: buildDisabledTextField(
                            'Net Earnings',
                            'N/A',
                            onChanged: (value) =>
                                widget.recipeData['net_earnings'] = value,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    const SizedBox(height: 16),
                    buildTextField(
                      'Comments',
                      'Add comments',
                      maxLines: 3,
                      onChanged: (value) =>
                          widget.recipeData['comments'] = value,
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState?.validate() ?? false) {
                    widget.saveRecipe();
                    //widget.nextStep();
                  }
                },
                style: AppStyles.elevatedButtonStyle,
                child: const Text(
                  'Save',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

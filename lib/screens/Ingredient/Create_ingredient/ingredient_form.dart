import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'ingredient_form_step1.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientForm extends StatefulWidget {
  final String token;
  final VoidCallback onEntityCreated;

  const IngredientForm({
    super.key,
    required this.token,
    required this.onEntityCreated,
  });

  @override
  _IngredientFormState createState() => _IngredientFormState();
}

class _IngredientFormState extends State<IngredientForm> {
  final Map<String, dynamic> _ingredientData = {
    "name": null,
    "category": null,
    "sub_category": null,
    "supplier_id": null,
    "product_code": null,
    'add_to_inventory': false,
    "quantity": null,
    "quantity_unit": null,
    "each_selected_quantity": null,
    "each_selected_unit": null,
    // "selected_unit": null,
    "selected_unit_metric": null,
    "tax": null,
    "cost": null,
    "price_per_unit": null,
    "comments": null,
  };

  final List<GlobalKey<FormState>> _stepKeys = [
    GlobalKey<FormState>(),
  ];

  void _saveIngredient() async {
    final isValid = _stepKeys.first.currentState?.validate() ?? false;
    if (!isValid) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill * fields before saving.')),
      );
      return;
    }

    // Save form data to _ingredientData
    _stepKeys.first.currentState?.save();

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/ingredients/'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: jsonEncode(_ingredientData),
      );
      //print(_ingredientData);

      if (response.statusCode == 200 || response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ingredient saved successfully!')),
        );

        widget.onEntityCreated();
        Navigator.pop(context, true);

        if (_ingredientData['add_to_inventory'] == true) {
          addToInventoryPopup(context);
        }
      } else if (response.statusCode == 403) {
        duplicateIngredient(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to save ingredient: ${response.body}')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $error')),
      );
    }
  }

  void duplicateIngredient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Ingredient with same name already exists'),
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

  void addToInventoryPopup(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Ingredient added to inventory'),
          content: const Text(
              'If you want to delete the ingredient, you can delete it within 24 hours'),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Ingredient',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 18,
              color: AppColors.hintColor,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          children: [
            const SizedBox(height: 15),
            Expanded(
              child: IndexedStack(
                children: [
                  IngredientFormStep1(
                    formKey: _stepKeys[0],
                    data: _ingredientData,
                  ),
                ],
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveIngredient,
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






// import 'package:flutter/material.dart';
// import 'package:margo/constants/material.dart';
// import 'ingredient_form_step1.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class IngredientForm extends StatefulWidget {
//   final String token;
//   final VoidCallback onEntityCreated;

//   const IngredientForm({
//     super.key,
//     required this.token,
//     required this.onEntityCreated,
//   });

//   @override
//   _IngredientFormState createState() => _IngredientFormState();
// }

// class _IngredientFormState extends State<IngredientForm> {
//   final Map<String, dynamic> _ingredientData = {
//     "name": null,
//     "category": null,
//     "sub_category": null,
//     "supplier_id": null,
//     "product_code": null,
//     'add_to_inventory': false,
//     "quantity": null,
//     "quantity_unit": null,
//     "each_selected_quantity": null,
//     "each_selected_unit": null,
//     // "selected_unit": null,
//     "selected_unit_metric": null,
//     "tax": null,
//     "cost": null,
//     "price_per_unit": null,
//     "comments": null,
//   };

//   final List<GlobalKey<FormState>> _stepKeys = [
//     GlobalKey<FormState>(),
//   ];

//   void _saveIngredient() async {
//     final isValid = _stepKeys.first.currentState?.validate() ?? false;
//     if (!isValid) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Please fill * fields before saving.')),
//       );
//       return;
//     }

//     // Save form data to _ingredientData
//     _stepKeys.first.currentState?.save();

//     try {
//       final response = await http.post(
//         Uri.parse('$baseUrl/api/ingredients/'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//         body: jsonEncode(_ingredientData),
//       );
//       print(_ingredientData);

//       if (response.statusCode == 200 || response.statusCode == 201) {
//         if (_ingredientData['add_to_inventory'] == true) {
//           addToInventoryPopup(context);
//         }
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Ingredient saved successfully!')),
//         );

//         widget.onEntityCreated();
//         Navigator.pop(context, true);
//       } else if (response.statusCode == 403) {
//         duplicateIngredient(context);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//               content: Text('Failed to save ingredient: ${response.body}')),
//         );
//       }
//     } catch (error) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: $error')),
//       );
//     }
//   }

//   void duplicateIngredient(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: const Text('Ingredient with same name already exists'),
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

//   void addToInventoryPopup(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: const Text(
//               'Ingredient added to inventory. If you want to delete the ingredient, you can delete it within 24 hours'),
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

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text(
//           'Create Ingredient',
//           style: AppTextStyles.heading,
//         ),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         actions: [
//           IconButton(
//             icon: const Icon(
//               Icons.close,
//               size: 18,
//               color: AppColors.hintColor,
//             ),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(8.0),
//         child: Column(
//           children: [
//             const SizedBox(height: 15),
//             Expanded(
//               child: IndexedStack(
//                 children: [
//                   IngredientFormStep1(
//                     formKey: _stepKeys[0],
//                     data: _ingredientData,
//                   ),
//                 ],
//               ),
//             ),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: _saveIngredient,
//                 style: AppStyles.elevatedButtonStyle,
//                 child: Text(
//                   'Save',
//                   style: AppTextStyles.buttonText,
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Recipe/Create_recipe/recipe_step2.dart';
import 'package:margo/screens/Recipe/Create_recipe/step_indicator.dart';
import 'recipe_step1.dart';
import 'recipe_step3.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeCreateForm extends StatefulWidget {
  final String token;
  final VoidCallback onEntityCreated;
  //final String recipeName;

  const RecipeCreateForm({
    super.key,
    required this.token,
    required this.onEntityCreated,
    // required this.recipeName,
  });

  @override
  _RecipeCreateFormState createState() => _RecipeCreateFormState();
}

class _RecipeCreateFormState extends State<RecipeCreateForm> {
  final Map<String, dynamic> recipeData = {
    "name": "",
    "category": "",
    "use_as_ingredient": false,
    "tags": '',
    // "cost": 0.0,
    "tax": 0.0,
    "selling_price": 0.0,
    "food_cost": 0.0,
    "net_earnings": 0.0,
    "comments": "",
    "method": "",
    "ingredient": [],
  };

  int _currentStep = 0;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  void _nextStep() {
    if (_currentStep < 2) {
      if (_formKey.currentState?.validate() ?? false) {
        _formKey.currentState?.save();
        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _previousStep() {
    if (_currentStep > 0) {
      setState(() {
        _currentStep--;
      });
    }
  }

  Future<void> saveRecipe() async {
    if (_formKey.currentState?.validate() ?? false) {
      _formKey.currentState?.save();

      final url = Uri.parse('$baseUrl/api/recipes/add_recipe');
      try {
        final response = await http.post(
          url,
          headers: {
            'Authorization': 'Bearer ${widget.token}',
            "Content-Type": "application/json",
          },
          body: jsonEncode(recipeData),
        );
        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Recipe saved successfully!')),
          );
          widget.onEntityCreated();
          Navigator.pop(context, true);
        } else if (response.statusCode == 403) {
          duplicateRecipe(context);
        } else {
          throw Exception('Failed to save recipe');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: ${e.toString()}')),
        );
      }
    }
  }

  void updateIngredients(List<dynamic> ingredients) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          recipeData["ingredient"] = ingredients;
        });
      }
    });
  }

  void duplicateRecipe(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Recipe with the same name already exists'),
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

  // List<Widget> steps() {
  //   return [
  //     RecipeStep1(
  //       recipeData: recipeData,
  //       nextStep: _nextStep,
  //     ),
  //     RecipeStep2(
  //       recipeData: recipeData,
  //       onIngredientsChange: updateIngredients,
  //       nextStep: _nextStep,
  //     ),
  //     RecipeStep3(
  //       recipeData: recipeData,
  //       saveRecipe: saveRecipe,
  //     ),
  //   ];
  // }

  List<Widget> steps() {
    return [
      RecipeStep2(
        recipeData: recipeData,
        onIngredientsChange: updateIngredients,
        nextStep: _nextStep,
      ),
      RecipeStep3(
        recipeData: recipeData,
        nextStep: _nextStep,
        //saveRecipe: saveRecipe,
      ),
      RecipeStep1(
        recipeData: recipeData,
        // nextStep: _nextStep,
        saveRecipe: saveRecipe,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Recipe',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        leading: _currentStep > 0
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 15),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              StepIndicator(currentStep: _currentStep),
              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: steps(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}






// class RecipeCreateForm extends StatefulWidget {
//   final String token;
//   final VoidCallback onEntityCreated;
//   const RecipeCreateForm({
//     super.key,
//     required this.token,
//     required this.onEntityCreated,
//   });

//   @override
//   _RecipeCreateFormState createState() => _RecipeCreateFormState();
// }

// class _RecipeCreateFormState extends State<RecipeCreateForm> {
//   final Map<String, dynamic> recipeData = {
//     "name": "",
//     "category": "",
//     "use_as_ingredeint": '',
//     "tags": '',
//     "cost": 0.0,
//     "tax": 0.0,
//     "selling_price": 0.0,
//     "food_cost": 0.0,
//     "net_earnings": 0.0,
//     "comments": "",
//     "method": "",
//     "ingredient": [],
//   };

//   int _currentStep = 0;
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

//   void _nextStep() {
//     if (_currentStep < 2) {
//       if (_formKey.currentState?.validate() ?? false) {
//         _formKey.currentState?.save();
//         setState(() {
//           _currentStep++;
//         });
//       }
//     }
//   }

//   void _previousStep() {
//     if (_currentStep > 0) {
//       setState(() {
//         _currentStep--;
//       });
//     }
//   }

//   Future<void> saveRecipe() async {
//     if (_formKey.currentState?.validate() ?? false) {
//       _formKey.currentState?.save();

//       final url = Uri.parse('$baseUrl/api/recipes/add_recipe');
//       try {
//         final response = await http.post(
//           url,
//           headers: {
//             'Authorization': 'Bearer ${widget.token}',
//             "Content-Type": "application/json",
//           },
//           body: jsonEncode(recipeData),
//         );
//         print(recipeData);
//         if (response.statusCode == 200 || response.statusCode == 201) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Recipe saved successfully!')),
//           );

//           widget.onEntityCreated();

//           Navigator.pop(context, true);
//         } else if (response.statusCode == 403) {
//           duplicateRecipe(context);
//         } else {
//           throw Exception('Failed to save recipe');
//         }
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text('Error: ${e.toString()}')),
//         );
//       }
//     }
//   }

//   void updateIngredients(List<dynamic> ingredients) {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (mounted) {
//         setState(() {
//           recipeData["ingredient"] = ingredients;
//         });
//       }
//     });
//   }

//   List<Widget> steps() {
//     return [
//       RecipeStep1(
//         recipeData: recipeData,
//         nextStep: _nextStep,
//         // saveRecipe: saveRecipe,
//       ),
//       RecipeStep2(
//         recipeData: recipeData,
//         onIngredientsChange: updateIngredients,
//         nextStep: _nextStep,
//         //saveRecipe: saveRecipe,
//       ),
//       RecipeStep3(
//         recipeData: recipeData,
//         //nextStep: _nextStep,
//         saveRecipe: saveRecipe,
//       ),
//     ];
//   }

//   void duplicateRecipe(BuildContext context) {
//     showDialog(
//       context: context,
//       builder: (BuildContext context) {
//         return AlertDialog(
//           content: const Text('Recipe with same name already exists'),
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
//           'Create Recipe',
//           style: AppTextStyles.heading,
//         ),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//         leading: _currentStep > 0
//             ? IconButton(
//                 icon: const Icon(Icons.arrow_back_ios, size: 15),
//                 onPressed: _previousStep,
//               )
//             : null,
//         actions: [
//           IconButton(
//             icon: const Icon(Icons.close, size: 20),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ],
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Form(
//           key: _formKey,
//           child: Column(
//             children: [
//               StepIndicator(currentStep: _currentStep),
//               Expanded(
//                 child: steps()[_currentStep],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

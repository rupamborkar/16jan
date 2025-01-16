import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Recipe/Edit_recipe/edit_ingredient_recipe.dart';
import 'package:margo/screens/Recipe/Edit_recipe/edit_recipe_details.dart';
import 'package:margo/screens/Recipe/Edit_recipe/edit_tabs.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditMethod extends StatefulWidget {
  final String recipeId;
  const EditMethod({super.key, required this.recipeId});

  @override
  _EditMethodState createState() => _EditMethodState();
}

class _EditMethodState extends State<EditMethod> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Future<Map<String, dynamic>?>? recipeData;
  String? _jwtToken;

  final TextEditingController _preparationMethodController =
      TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      // Retrieve JWT token from secure storage
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

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _preparationMethodController.text = data['method'] ?? '';
        return data;
      } else {
        throw Exception('Failed to load recipe data');
      }
    } catch (e) {
      throw Exception('Error fetching recipe data: $e');
    }
  }

  Future<void> _updateRecipe() async {
    if (_jwtToken == null) {
      throw Exception('JWT token is null');
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/recipes/${widget.recipeId}'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'method': _preparationMethodController.text,
        }),
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Recipe updated successfully!')),
        );
        Navigator.of(context).pop(true);
        //Navigator.pop(context);
      } else {
        throw Exception('Failed to update recipe');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating recipe: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'How to Prepare',
              style: AppTextStyles.labelBoldFormat,
            ),
            const SizedBox(height: 16),
            _buildTextField(
              ' ',
              _preparationMethodController,
              maxLines: 8,
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _updateRecipe,
                style: AppStyles.elevatedButtonStyle,
                child: const Text(
                  'Update',
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      //String hint,
      {int maxLines = 4}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: AppTextStyles.labelFormat,
          ),
          const SizedBox(height: 2),
          TextFormField(
            controller: controller,
            maxLines: maxLines,
            decoration: InputDecoration(
              hintStyle: AppTextStyles.valueFormat,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            // onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

class EditMethodTab extends StatelessWidget {
  final String recipeId;

  const EditMethodTab({super.key, required this.recipeId});

  @override
  Widget build(BuildContext context) {
    return RecipeTabs(
      initialIndex: 2,
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

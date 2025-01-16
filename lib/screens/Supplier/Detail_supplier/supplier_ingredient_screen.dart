import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupplierIngredientScreen extends StatefulWidget {
  final String supplierId;

  const SupplierIngredientScreen({super.key, required this.supplierId});

  @override
  _SupplierIngredientScreenState createState() =>
      _SupplierIngredientScreenState();
}

class _SupplierIngredientScreenState extends State<SupplierIngredientScreen> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  String? _jwtToken;
  List<dynamic> ingredients = [];
  bool isLoading = true;

  Set<int> expandedIngredients = {};

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchIngredients();
  }

  Future<void> _loadTokenAndFetchIngredients() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });

      await fetchIngredients();
    } catch (e) {
      print("Error loading token or fetching ingredients: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchIngredients() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/supplier/${widget.supplierId}/supplier_ingredients'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          ingredients = data;
          isLoading = false;
        });
      } else {
        print(
            'Failed to load ingredients. Status code: ${response.statusCode}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching ingredients: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : ingredients.isEmpty
                ? const Center(child: Text("No ingredients found."))
                : ListView.builder(
                    itemCount: ingredients.length,
                    itemBuilder: (context, index) {
                      final ingredient = ingredients[index];
                      // final ingredientId = ingredient['id'];
                      final ingredientName = ingredient['name'] ?? 'Unknown';

                      return Container(
                        margin: const EdgeInsets.symmetric(vertical: 8),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.grey,
                            width: 1.0,
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ingredientName,
                                  style: AppTextStyles.labelBoldFormat,
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Recipe/Detail_recipe/recipe_details_screen.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RecipeHomePage extends StatefulWidget {
  final String jwtToken;

  const RecipeHomePage({Key? key, required this.jwtToken}) : super(key: key);

  @override
  _RecipeHomePageState createState() => _RecipeHomePageState();
}

class _RecipeHomePageState extends State<RecipeHomePage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> recipes = [];
  List<Map<String, dynamic>> filteredRecipes = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchRecipes();
    _searchController.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    setState(() {
      filteredRecipes = recipes.where((recipe) {
        return recipe['name']!
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  Future<void> _fetchRecipes() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/recipes/'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          recipes = data
              .map((recipe) => {
                    'id': recipe['id'].toString(),
                    'name': recipe['name'] ?? 'Unknown',
                    'category': recipe['category'] ?? 'Unknown',
                    'food_cost': recipe['food_cost'].toString(),
                    'selling_price': recipe['selling_price'].toString(),
                    'net_earnings': recipe['net_earnings'].toString(),
                    'date': recipe['last_update'] ?? '',
                  })
              .toList();
          filteredRecipes = recipes;
        });
      } else {
        throw Exception('Failed to load recipes');
      }
    } catch (error) {
      print('Error fetching recipes: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                // Search bar
                Expanded(
                  child: Container(
                    height: 40,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(231, 231, 231, 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Opacity(
                            opacity: 0.8,
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search for Recipe',
                                hintStyle: AppTextStyles.hintFormat,
                                prefixIcon: Icon(
                                  EneftyIcons.search_normal_2_outline,
                                  size: 20,
                                  color: AppColors.hintColor,
                                ),
                                border: InputBorder.none,
                                isDense: true,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8.0),

                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(231, 231, 231, 1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.filter_list, size: 18),
                    onPressed: () {},
                  ),
                )
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      children: filteredRecipes.map((recipe) {
                        return RecipeCard(
                          id: recipe['id'],
                          name: recipe['name'] ?? 'Unknown',
                          category: recipe['category'] ?? 'Unknown',
                          cost: recipe['food_cost'] ?? 'N/A',
                          sellingPrice: recipe['selling_price'].toString(),
                          netEarning: recipe['net_earnings'] ?? 'N/A',
                          date: recipe['date'] ?? '',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => RecipeDetail(
                                  name: recipe['name'] ?? 'Unknown',
                                  recipeId: recipe['id'],
                                ),
                              ),
                            );
                            if (result == true) {
                              setState(() {
                                _fetchRecipes();
                              });
                            }
                          },
                        );
                      }).toList(),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}

class RecipeCard extends StatelessWidget {
  final String id;
  final String name;
  final String category;
  final String cost;
  final String sellingPrice;
  final String netEarning;
  final String date;

  final VoidCallback onTap;

  const RecipeCard({
    Key? key,
    required this.id,
    required this.name,
    required this.category,
    required this.cost,
    required this.sellingPrice,
    required this.netEarning,
    required this.date,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: Colors.white,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: const BorderSide(
              color: Color.fromRGBO(231, 231, 231, 1), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                      child: Text(
                        name,
                        style: AppTextStyles.nameFormat,
                      ),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(230, 242, 242, 1),
                      borderRadius: BorderRadius.circular(15.0),
                    ),
                    child: Text(
                      category,
                      style: AppTextStyles.categoryFormat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (date.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.fromLTRB(6, 0, 0, 0),
                  child: Text(
                    date,
                    style: AppTextStyles.dateFormat,
                  ),
                ),
              const SizedBox(height: 8),
              const Divider(
                  thickness: 1, color: Color.fromRGBO(230, 242, 242, 1)),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 0, 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildInfoColumn('\$${cost}', 'Food Cost'),
                    _buildInfoColumn('\$${sellingPrice}', 'Selling Price'),
                    _buildNetEarnInfoColumn(
                        earnings: netEarning, 'Net Earnings'),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: AppTextStyles.valueFormat,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: AppTextStyles.labelFormat,
        ),
      ],
    );
  }

  Widget _buildNetEarnInfoColumn(String label, {String? earnings}) {
    Color earningsColor = earnings != null
        ? double.tryParse(earnings) != null && double.tryParse(earnings)! > 0
            ? Color.fromRGBO(76, 175, 80, 1)
            : Color.fromRGBO(222, 61, 49, 1)
        : Colors.black;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (earnings != null)
            Text(
              '\$${earnings}',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 13,
                height: 1.5,
                fontWeight: FontWeight.w400,
                color: earningsColor,
              ),
            ),
          SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.labelFormat,
          ),
        ],
      ),
    );
  }
}

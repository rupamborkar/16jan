import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Ingredient/Edit_ingredient/edit_ingredient.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class IngredientDetail extends StatefulWidget {
  final String ingredientId;
  final String name;

  IngredientDetail({required this.ingredientId, required this.name});

  @override
  _IngredientDetailState createState() => _IngredientDetailState();
}

class _IngredientDetailState extends State<IngredientDetail> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Map<String, dynamic>? ingredientData;
  String? _jwtToken;
  final int _currentTabIndex = 0;

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
      });

      await fetchIngredientDetails();
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
        setState(() {
          ingredientData = json.decode(response.body);
        });
      } else {
        print(
            'Failed to load ingredient data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching ingredient data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 1,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              size: 15,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: Text(
            widget.name,
            style: AppTextStyles.heading,
          ),
          centerTitle: true,
          actions: [
            IconButton(
              icon: const Icon(Icons.edit_outlined,
                  color: Color.fromRGBO(101, 104, 103, 1)),
              onPressed: () async {
                if (_currentTabIndex == 0) {
                  final result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => EditIngredientsDetail(
                        ingredientId: widget.ingredientId,
                        jwtToken: _jwtToken!,
                      ),
                    ),
                  );
                  if (result == true) {
                    setState(() {
                      fetchIngredientDetails();
                    });
                  }
                }
              },
            ),
          ],
          bottom: TabBar(
            labelColor: Color.fromRGBO(0, 128, 128, 1),
            unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
            indicatorColor: Color.fromRGBO(0, 128, 128, 1),
            labelStyle: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            tabs: const [
              Tab(text: 'Details'),
            ],
          ),
        ),
        body: ingredientData == null
            ? const Center(child: CircularProgressIndicator())
            : TabBarView(
                children: [
                  DetailsTab(
                      ingredientData: ingredientData!,
                      jwtToken: _jwtToken!,
                      ingredientId: widget.ingredientId),
                ],
              ),
      ),
    );
  }
}

class DetailsTab extends StatefulWidget {
  final Map<String, dynamic> ingredientData;
  final String jwtToken;
  final String ingredientId;

  DetailsTab(
      {required this.ingredientData,
      required this.jwtToken,
      required this.ingredientId});

  @override
  _DetailsTabState createState() => _DetailsTabState();
}

class _DetailsTabState extends State<DetailsTab> {
  late BuildContext scaffoldContext;

  bool isNonMetricUnit(String? unit) {
    const nonMetricUnits = [
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
    return unit != null && nonMetricUnits.contains(unit);
  }

  void duplicateIngredient(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: const Text('Ingredient is already present in recipe '),
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

  Future<void> deleteIngredient(String ingredientId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/ingredients/$ingredientId'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}', // Use the token here
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          const SnackBar(content: Text('Ingredient deleted successfully')),
        );
        Navigator.of(scaffoldContext).pop(true);
      } else if (response.statusCode == 403) {
        final responseBody = jsonDecode(response.body);
        final message =
            responseBody['message'] ?? 'Failed to delete ingredient.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
        // duplicateIngredient(context);
      } else {
        ScaffoldMessenger.of(scaffoldContext).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete ingredient.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting ingredient: $e');
      ScaffoldMessenger.of(scaffoldContext).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the ingredient.')),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: scaffoldContext,
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
                deleteIngredient(widget.ingredientId);
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

  @override
  Widget build(BuildContext context) {
    return Builder(
      builder: (BuildContext newContext) {
        scaffoldContext = newContext;

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: const Color.fromRGBO(253, 253, 253, 1),
                elevation: 0,
                margin: const EdgeInsets.symmetric(vertical: 6.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  side: BorderSide(
                      color: const Color.fromRGBO(231, 231, 231, 1), width: 1),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildRow('Ingredient Name:',
                          widget.ingredientData['name'] ?? 'N/A'),
                      _buildRow('Category:',
                          widget.ingredientData['category'] ?? 'N/A'),
                      _buildRow('Sub-Category:',
                          widget.ingredientData['sub_category'] ?? 'N/A'),
                      _buildRow('Supplier:',
                          widget.ingredientData['supplier'] ?? 'N/A'),
                      _buildRow('Product Code:',
                          widget.ingredientData['product_code'] ?? 'N/A'),
                      _buildRow('Quantity Purchased:',
                          '${widget.ingredientData['quantity_purchased'] ?? '0.00'} ${widget.ingredientData['quantity_unit'] ?? ''}'),
                      // if (isNonMetricUnit(
                      //     widget.ingredientData['quantity_unit']))
                      //   _buildRow(
                      //     'Each ${widget.ingredientData['quantity_unit']} has:',
                      //     '${widget.ingredientData['each_selected_quantity'] ?? 'N/A'} ${widget.ingredientData['each_selected_unit'] ?? ''}',
                      //   ),
                      if (isNonMetricUnit(
                          widget.ingredientData['quantity_unit'])) ...[
                        _buildRow(
                          'Price per ${widget.ingredientData['quantity_unit'] ?? ''}:',
                          '\$${widget.ingredientData['price_per_unit'] ?? '0.00'}',
                        ),
                        _buildRow(
                          'Each ${widget.ingredientData['quantity_unit']} has:',
                          '${widget.ingredientData['each_selected_quantity'] ?? 'N/A'} ${widget.ingredientData['each_selected_unit'] ?? ''}',
                        ),
                        _buildRow(
                          'Price per ${widget.ingredientData['each_selected_unit'] ?? ''}:',
                          '\$${widget.ingredientData['price_per_selected_unit'] ?? '0.00'}',
                        ),
                      ] else ...[
                        _buildRow(
                          'Price per ${widget.ingredientData['quantity_unit'] ?? ''}:',
                          '\$${widget.ingredientData['price_per_unit'] ?? '0.00'}',
                        ),
                      ],
                      // _buildRow(
                      //   isNonMetricUnit(widget.ingredientData['quantity_unit'])
                      //       ? 'Price per ${widget.ingredientData['each_selected_unit'] ?? ''}:'
                      //       : 'Price per ${widget.ingredientData['quantity_unit'] ?? ''}:',
                      //   '\$${widget.ingredientData['price_per_unit'] ?? '0.00'}',
                      // ),
                      _buildRow('Total Price:',
                          '\$${widget.ingredientData['total_price'] ?? '0.00'}'),
                      _buildRow(
                          'Tax:', '${widget.ingredientData['tax'] ?? '0'}%'),
                      _buildRow('Tax Amount:',
                          '\$${widget.ingredientData['tax_amount'] ?? '0.00'}'),
                      _buildRow('Total Price with Tax:',
                          '\$${widget.ingredientData['cost'] ?? '0.00'}'),
                      _buildRow('Last Update',
                          widget.ingredientData['last_update'] ?? 'N/A'),
                      _buildRow('Comments: ',
                          widget.ingredientData['comments'] ?? 'N/A'),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton(
                  onPressed: () {
                    confirmDelete();
                  },
                  child: const Text('Delete ingredients',
                      style: AppTextStyles.deleteFormat),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

Widget _buildRow(String label, String value) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 4.0),
    child: Row(
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: AppTextStyles.labelFormat,
          ),
        ),
        Expanded(
          flex: 4,
          child: Text(
            value.toString(),
            style: AppTextStyles.valueFormat,
            textAlign: TextAlign.left,
          ),
        ),
      ],
    ),
  );
}

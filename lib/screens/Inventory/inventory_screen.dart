import 'package:margo/constants/material.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:margo/screens/Inventory/current_inventoryPage.dart';
import 'package:margo/screens/Inventory/inventory_history.dart';
import 'package:margo/screens/Inventory/stockin.dart';
import 'package:margo/screens/Inventory/stocktake.dart';
import 'dart:convert';

class StocktakeScreen extends StatefulWidget {
  final String token;

  const StocktakeScreen({super.key, required this.token});

  @override
  State<StocktakeScreen> createState() => _StocktakeScreenState();
}

class _StocktakeScreenState extends State<StocktakeScreen> {
  final TextEditingController _searchController = TextEditingController();
  //List<Map<String, dynamic>> stocktakeData = [];
  //Future<Map<String, dynamic>?>?
  Map<String, dynamic>? stocktakeData;
  List<Map<String, dynamic>> stockInData = [];
  List<Map<String, dynamic>> inventoryData = [];
  bool isLoadingStocktake = false;
  bool isLoadingStockIn = false;
  List<TextEditingController> priceControllers = [];
  List<TextEditingController> quantityControllers = [];

  @override
  void initState() {
    super.initState();
    _fetchStocktakeData();
    // _fetchStockInData();
    fetchStocktakeDetails();
  }

  Future<void> fetchStocktakeDetails() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/inventory/'),
        //api/inventory/stock_quantity_wise
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        setState(() {
          inventoryData = fetchedData.map((item) {
            return {
              'id': item['id'],
              'ingredient_id': item['ingredient_id'],
              'name': item['name'],
              'price': item['price'].toString(),
              'price_with_tax': item['cost'].toString(),
              'quantity': item['quantity'].toString(),
              'quantity_unit': item['quantity_unit'],
            };
          }).toList();

          priceControllers = inventoryData
              .map((item) => TextEditingController(text: item['price']))
              .toList();
          quantityControllers = inventoryData
              .map((item) => TextEditingController(text: item['quantity']))
              .toList();
        });
      } else {
        print('Failed to fetch stocktake data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching stocktake details: $e');
    }
  }

  Future<void> _fetchStocktakeData() async {
    setState(() {
      isLoadingStocktake = true;
    });

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/inventory/monthly_stock'),
        headers: {'Authorization': 'Bearer ${widget.token}'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        setState(() {
          stocktakeData = data;
        });
      } else {
        throw Exception('Failed to load stocktake data');
      }
    } catch (error) {
      print('Error fetching stocktake data: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoadingStocktake = false;
        });
      }
    }
  }

  // Future<void> _fetchStockInData() async {
  //   setState(() {
  //     isLoadingStockIn = true;
  //   });

  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/api/stockin/'),
  //       headers: {'Authorization': 'Bearer ${widget.token}'},
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       setState(() {
  //         stockInData =
  //             data.map((item) => item as Map<String, dynamic>).toList();
  //       });
  //     } else {
  //       throw Exception('Failed to load stockin data');
  //     }
  //   } catch (error) {
  //     print('Error fetching stockin data: $error');
  //   } finally {
  //     if (mounted) {
  //       setState(() {
  //         isLoadingStockIn = false;
  //       });
  //     }
  //   }
  // }

  Widget _buildStockOutCard(
    String title,
    Map<String, dynamic>? data, // Updated type to match stocktakeData
    bool isLoading,
  ) {
    return Card(
      color: Color.fromRGBO(253, 253, 253, 1),
      elevation: 0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 8),
            if (isLoading)
              const Center(child: CircularProgressIndicator())
            else if (data == null || data.isEmpty)
              const Text('No data available')
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Date: ${data['date'] ?? 'N/A'}',
                    style: AppTextStyles.nameFormat,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Initial Warehouse Value: ${data['initial_value'] ?? 'N/A'}',
                    style: AppTextStyles.valueFormat,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Final Warehouse Value: ${data['final_value'] ?? 'N/A'}',
                    style: AppTextStyles.valueFormat,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Total Utilized Value: ${data['total_utilised_value'] ?? 'N/A'}',
                    style: AppTextStyles.valueFormat,
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStockInCard(
      String title, List<Map<String, dynamic>> data, bool isLoading) {
    double totalPrice = 0;
    for (var item in data) {
      totalPrice += double.tryParse(item['price']?.toString() ?? '0') ?? 0;
    }
    return Card(
      color: Color.fromRGBO(253, 253, 253, 1),
      elevation: 0,
      margin: const EdgeInsets.all(16.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
        side: BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title
            Text(
              title,
              style: AppTextStyles.heading,
            ),
            const SizedBox(height: 8),
            if (!isLoading
                // && data.isNotEmpty
                )
              Padding(
                padding: const EdgeInsets.only(
                    bottom:
                        16.0), // Adjusted padding to separate from next section
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Current Warehouse Worth:',
                      style: AppTextStyles.labelFormat,
                    ),
                    Text(
                      data.isNotEmpty
                          ? '\$${totalPrice.toStringAsFixed(2)}'
                          : '\$0', // Show 0 if data is empty
                      style: AppTextStyles.valueFormat,
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          'Inventory',
          style: AppTextStyles.heading,
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_none),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                _buildStockOutCard(
                    'Last Month', stocktakeData, isLoadingStocktake),
                _buildStockInCard(
                    'Current Month',
                    inventoryData,
                    //stockInData,
                    isLoadingStockIn),
                _buildListTile(
                  title: 'Current Inventory',
                  icon: Icons.chevron_right,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => CurrentInventory(),
                    ),
                  ),
                ),
                _buildListTile(
                  title: 'Inventory History',
                  icon: Icons.chevron_right,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => InventoryHistory(
                        jwtToken: widget.token,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => StockInPage()),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 32),
                  ),
                  child: const Text(
                    "Stockin",
                    style: AppTextStyles.buttonText,
                  ),
                ),
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              StockTakePage(token: widget.token)),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.buttonColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 32),
                  ),
                  child: const Text(
                    "Stocktake",
                    style: AppTextStyles.buttonText,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildListTile({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return Container(
      height: 40,

      padding: EdgeInsets.fromLTRB(18, 0, 16, 0),
      //const EdgeInsets.all(16.0),
      // const EdgeInsets.symmetric(vertical: 4.0),
      child: InkWell(
        onTap: onTap,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: AppTextStyles.valueFormat,
            ),
            Icon(icon, color: AppColors.hintColor),
          ],
        ),
      ),
    );
  }
}

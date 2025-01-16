// import 'package:flutter/material.dart';
// import 'package:margo/constants/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:margo/screens/Inventory/stockin_history.dart';
// import 'package:margo/screens/Inventory/stocktake_history.dart';

// class InventoryHistory extends StatefulWidget {
//   final String jwtToken;
//   const InventoryHistory({
//     Key? key,
//     required this.jwtToken,
//   }) : super(key: key);

//   @override
//   _InventoryHistoryState createState() => _InventoryHistoryState();
// }

// class _InventoryHistoryState extends State<InventoryHistory> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> inventoryHistory = [];
//   List<Map<String, dynamic>> filteredIngredients = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchInventoryHistory();
//     // _searchController.addListener(_onSearchChanged);
//   }

//   Future<void> _fetchInventoryHistory() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       // print("Token: ${widget.jwtToken}");

//       final response = await http.get(
//         Uri.parse(
//             '$baseUrl/api/inventory/inventory_history'), // Ensure correct API endpoint
//         headers: {
//           'Authorization': 'Bearer ${widget.jwtToken}',
//         },
//       );
//       // print('Requesting stoc from: $baseUrl/api/ingredients');
//       // print('Headers: ${{
//       //   'Authorization': 'Bearer ${widget.jwtToken}',
//       // }}');
//       // print('Response body: ${response.body}'); // Debugging print statement
//       // print('Response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           inventoryHistory = data
//               .map((inventory) => inventory as Map<String, dynamic>)
//               .toList();
//           //filteredIngredients = inventory_history;
//         });
//       } else {
//         throw Exception('Failed to load inventory history');
//       }
//     } catch (error) {
//       print('Error fetching inventory history: $error');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             size: 15,
//             color: Color.fromRGBO(101, 104, 103, 1),
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Inventory History',
//           style: AppTextStyles.heading,
//         ),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: isLoading
//                   ? const Center(
//                       child: CircularProgressIndicator(),
//                     )
//                   : ListView(
//                       children: inventoryHistory.map((inventory) {
//                         //filteredIngredients.map((ingredient) {
//                         return IngredientCard(
//                           token: widget.jwtToken,
//                           id: inventory['id'].toString(),
//                           operationName: inventory['operation'] ?? 'Unknown',
//                           date: inventory['date'] ?? '',
//                           delete: inventory['recent'] ?? false,
//                           //current_worth: inventory['current_worth'].toString(),
//                           onTap: () async {
//                             if (inventory['operation'] == 'stock_in') {
//                               final result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => StockInHistoryDetail(
//                                     // name: ingredient['name'] ?? 'Unknown',
//                                     inventoryId: inventory['id'],
//                                     inventoryData: inventoryHistory,
//                                   ),
//                                 ),
//                               );

//                               if (result == true) {
//                                 setState(() {
//                                   _fetchInventoryHistory(); // Example: Fetch updated ingredients
//                                 });
//                               }
//                             } else {
//                               final result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => StocktakeHistoryDetail(
//                                     inventoryId: inventory['id'],
//                                     inventoryData: inventoryHistory,
//                                   ),
//                                 ),
//                               );

//                               if (result == true) {
//                                 setState(() {
//                                   _fetchInventoryHistory(); // Example: Fetch updated ingredients
//                                 });
//                               }
//                             }
//                           },
//                         );
//                       }).toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// class IngredientCard extends StatefulWidget {
//   final String token;
//   final String id;
//   final String operationName;
//   final String date;
//   final bool delete;
//   final VoidCallback onTap;

//   const IngredientCard({
//     required this.id,
//     required this.operationName,
//     required this.date,
//     required this.delete,
//     required this.onTap,
//     required this.token,
//   });

//   @override
//   State<IngredientCard> createState() => _IngredientCardState();
// }

// class _IngredientCardState extends State<IngredientCard> {
//   void onDelete(
//     String id,
//   ) {
//     // Show a confirmation dialog before deleting
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Card'),
//         content: const Text('Are you sure you want to delete this card?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(), // Cancel deletion
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               deleteStock(id);
//               Navigator.of(context).pop();
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> deleteStock(String id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/api/inventory/recent/$id'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Stock deleted successfully')),
//         );
//         Navigator.of(context).pop(true);
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to delete stocktake.',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error deleting stock: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('An error occurred while deleting the stock.')),
//       );
//     }
//   }

//   // String toCamelCase(String text) {
//   //   return text
//   //       .split('_')
//   //       .map((word) => word.isNotEmpty
//   //           ? word[0].toUpperCase() + word.substring(1).toLowerCase()
//   //           : '')
//   //       .join('');
//   // }

//   String toCamelCase(String text) {
//     List<String> parts = text.split('_');
//     if (parts.isEmpty) return '';

//     String firstPart = parts.first.isNotEmpty
//         ? parts.first[0].toUpperCase() + parts.first.substring(1).toLowerCase()
//         : '';

//     String remainingParts =
//         parts.skip(1).map((word) => word.toLowerCase()).join('');

//     return firstPart + remainingParts;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Card(
//         color: AppColors.cardColor,
//         elevation: 0,
//         margin: const EdgeInsets.symmetric(vertical: 6.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8.0),
//           side: BorderSide(color: AppColors.borderColor, width: 1),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       //widget.operation_name,
//                       toCamelCase(widget.operationName),
//                       style: AppTextStyles.nameFormat,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 4),
//               if (widget.date.isNotEmpty)
//                 Text(
//                   widget.date,
//                   style: AppTextStyles.dateFormat,
//                 ),
//               const SizedBox(height: 8),
//               const Divider(
//                   thickness: 1, color: Color.fromRGBO(230, 242, 242, 1)),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(),
//                   if (widget.delete)
//                     TextButton(
//                       onPressed: () {
//                         onDelete(widget.id);
//                       },
//                       child: const Text('Delete',
//                           style: AppTextStyles.deleteFormat),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:margo/screens/Inventory/stockin_history.dart';
import 'package:margo/screens/Inventory/stocktake_history.dart';

class InventoryHistory extends StatefulWidget {
  final String jwtToken;
  const InventoryHistory({
    Key? key,
    required this.jwtToken,
  }) : super(key: key);

  @override
  _InventoryHistoryState createState() => _InventoryHistoryState();
}

class _InventoryHistoryState extends State<InventoryHistory> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> inventoryHistory = [];
  List<Map<String, dynamic>> filteredIngredients = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchInventoryHistory();
    // _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchInventoryHistory() async {
    setState(() {
      isLoading = true;
    });
    try {
      // print("Token: ${widget.jwtToken}");

      final response = await http.get(
        Uri.parse(
            '$baseUrl/api/inventory/inventory_history'), // Ensure correct API endpoint
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          inventoryHistory = data
              .map((inventory) => inventory as Map<String, dynamic>)
              .toList();
        });
      } else {
        throw Exception('Failed to load inventory history');
      }
    } catch (error) {
      print('Error fetching inventory history: $error');
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
        title: const Text(
          'Inventory History',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: isLoading
                  ? const Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      children: inventoryHistory.map((inventory) {
                        return IngredientCard(
                          token: widget.jwtToken,
                          // id: inventory['id'].toString(),
                          id: inventory['id'],
                          operationName: inventory['operation'] ?? 'Unknown',
                          date: inventory['date'] ?? '',
                          delete: inventory['recent'] ?? false,

                          onTap: () async {
                            if (inventory['operation'] == 'stock_in') {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StockInHistoryDetail(
                                    inventoryId: inventory['id'],
                                    inventoryData: inventoryHistory,
                                  ),
                                ),
                              );

                              if (result == true) {
                                setState(() {
                                  _fetchInventoryHistory();
                                });
                              }
                            } else {
                              final result = await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StocktakeHistoryDetail(
                                    inventoryId: inventory['id'],
                                    inventoryData: inventoryHistory,
                                  ),
                                ),
                              );

                              if (result == true) {
                                setState(() {
                                  _fetchInventoryHistory(); // Example: Fetch updated ingredients
                                });
                              }
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

class IngredientCard extends StatefulWidget {
  final String token;
  final int id;
  final String operationName;
  final String date;
  final bool delete;
  final VoidCallback onTap;

  const IngredientCard({
    required this.id,
    required this.operationName,
    required this.date,
    required this.delete,
    required this.onTap,
    required this.token,
  });

  @override
  State<IngredientCard> createState() => _IngredientCardState();
}

class _IngredientCardState extends State<IngredientCard> {
  void onDelete(
    int id,
  ) {
    // Show a confirmation dialog before deleting
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Card'),
        content: const Text('Are you sure you want to delete this card?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(), // Cancel deletion
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              deleteStock(id);
              Navigator.of(context).pop();
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> deleteStock(int id) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/inventory/recent/$id'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Stock deleted successfully')),
        );
        Navigator.of(context).pop(true);
      } else if (response.statusCode == 404) {
        final responseBody = jsonDecode(response.body);
        final message = responseBody['message'] ?? 'Failed to delete stock.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete stocktake.',
            ),
          ),
        );
      }
    } catch (e) {
      print('Error deleting stock: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the stock.')),
      );
    }
  }

  // String toCamelCase(String text) {
  //   return text
  //       .split('_')
  //       .map((word) => word.isNotEmpty
  //           ? word[0].toUpperCase() + word.substring(1).toLowerCase()
  //           : '')
  //       .join('');
  // }

  String toCamelCase(String text) {
    List<String> parts = text.split('_');
    if (parts.isEmpty) return '';

    String firstPart = parts.first.isNotEmpty
        ? parts.first[0].toUpperCase() + parts.first.substring(1).toLowerCase()
        : '';

    String remainingParts =
        parts.skip(1).map((word) => word.toLowerCase()).join('');

    return firstPart + remainingParts;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Card(
        color: AppColors.cardColor,
        elevation: 0,
        margin: const EdgeInsets.symmetric(vertical: 6.0),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8.0),
          side: BorderSide(color: AppColors.borderColor, width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      //widget.operation_name,
                      'Operation : ',
                      style: AppTextStyles.nameFormat,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      //widget.operation_name,
                      toCamelCase(widget.operationName),
                      style: AppTextStyles.nameFormat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      //widget.operation_name,
                      'Date : ',
                      style: AppTextStyles.nameFormat,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      widget.date,
                      style: AppTextStyles.dateFormat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(),
                  if (widget.delete)
                    TextButton(
                      onPressed: () {
                        onDelete(widget.id);
                      },
                      child: const Text('Delete',
                          style: AppTextStyles.deleteFormat),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}




// import 'package:flutter/material.dart';
// import 'package:margo/constants/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:margo/screens/Inventory/stockin_history.dart';
// import 'package:margo/screens/Inventory/stocktake_history.dart';

// class InventoryHistory extends StatefulWidget {
//   final String jwtToken;
//   const InventoryHistory({
//     Key? key,
//     required this.jwtToken,
//   }) : super(key: key);

//   @override
//   _InventoryHistoryState createState() => _InventoryHistoryState();
// }

// class _InventoryHistoryState extends State<InventoryHistory> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> inventoryHistory = [];
//   List<Map<String, dynamic>> filteredIngredients = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchInventoryHistory();
//     // _searchController.addListener(_onSearchChanged);
//   }

//   Future<void> _fetchInventoryHistory() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       // print("Token: ${widget.jwtToken}");

//       final response = await http.get(
//         Uri.parse(
//             '$baseUrl/api/inventory/inventory_history'), // Ensure correct API endpoint
//         headers: {
//           'Authorization': 'Bearer ${widget.jwtToken}',
//         },
//       );
//       // print('Requesting stoc from: $baseUrl/api/ingredients');
//       // print('Headers: ${{
//       //   'Authorization': 'Bearer ${widget.jwtToken}',
//       // }}');
//       // print('Response body: ${response.body}'); // Debugging print statement
//       // print('Response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           inventoryHistory = data
//               .map((inventory) => inventory as Map<String, dynamic>)
//               .toList();
//           //filteredIngredients = inventory_history;
//         });
//       } else {
//         throw Exception('Failed to load inventory history');
//       }
//     } catch (error) {
//       print('Error fetching inventory history: $error');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             size: 15,
//             color: Color.fromRGBO(101, 104, 103, 1),
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Inventory History',
//           style: AppTextStyles.heading,
//         ),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: isLoading
//                   ? const Center(
//                       child: CircularProgressIndicator(),
//                     )
//                   : ListView(
//                       children: inventoryHistory.map((inventory) {
//                         //filteredIngredients.map((ingredient) {
//                         return IngredientCard(
//                           token: widget.jwtToken,
//                           id: inventory['id'].toString(),
//                           operationName: inventory['operation'] ?? 'Unknown',
//                           date: inventory['date'] ?? '',
//                           delete: inventory['recent'] ?? false,
//                           //current_worth: inventory['current_worth'].toString(),
//                           onTap: () async {
//                             if (inventory['operation'] == 'stock_in') {
//                               final result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => StockInHistoryDetail(
//                                     // name: ingredient['name'] ?? 'Unknown',
//                                     inventoryId: inventory['id'],
//                                     inventoryData: inventoryHistory,
//                                   ),
//                                 ),
//                               );

//                               if (result == true) {
//                                 setState(() {
//                                   _fetchInventoryHistory(); // Example: Fetch updated ingredients
//                                 });
//                               }
//                             } else {
//                               final result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => StocktakeHistoryDetail(
//                                     inventoryId: inventory['id'],
//                                     inventoryData: inventoryHistory,
//                                   ),
//                                 ),
//                               );

//                               if (result == true) {
//                                 setState(() {
//                                   _fetchInventoryHistory(); // Example: Fetch updated ingredients
//                                 });
//                               }
//                             }
//                           },
//                         );
//                       }).toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// class IngredientCard extends StatefulWidget {
//   final String token;
//   final String id;
//   final String operationName;
//   final String date;
//   final bool delete;
//   final VoidCallback onTap;

//   const IngredientCard({
//     required this.id,
//     required this.operationName,
//     required this.date,
//     required this.delete,
//     required this.onTap,
//     required this.token,
//   });

//   @override
//   State<IngredientCard> createState() => _IngredientCardState();
// }

// class _IngredientCardState extends State<IngredientCard> {
//   void onDelete(
//    String id,
//   ) {
//     // Show a confirmation dialog before deleting
//     showDialog(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Delete Card'),
//         content: const Text('Are you sure you want to delete this card?'),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(), // Cancel deletion
//             child: const Text('Cancel'),
//           ),
//           TextButton(
//             onPressed: () {
//               deleteStock(id);
//               Navigator.of(context).pop();
//             },
//             child: const Text('Delete', style: TextStyle(color: Colors.red)),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> deleteStock(String id) async {
//     try {
//       final response = await http.delete(
//         Uri.parse('$baseUrl/api/inventory/recent/$id'),
//         headers: {
//           'Authorization': 'Bearer ${widget.token}',
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode == 200) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Stock deleted successfully')),
//         );
//         Navigator.of(context).pop(true);
//       } else if (response.statusCode == 404) {
//         final responseBody = jsonDecode(response.body);
//         final message =
//             responseBody['message'] ?? 'Failed to delete stocktake.';
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(content: Text(message)),
//         );
//       } else {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text(
//               'Failed to delete stocktake.',
//             ),
//           ),
//         );
//       }
//     } catch (e) {
//       print('Error deleting stock: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//             content: Text('An error occurred while deleting the stock.')),
//       );
//     }
//   }

//   // String toCamelCase(String text) {
//   //   return text
//   //       .split('_')
//   //       .map((word) => word.isNotEmpty
//   //           ? word[0].toUpperCase() + word.substring(1).toLowerCase()
//   //           : '')
//   //       .join('');
//   // }

//   String toCamelCase(String text) {
//     List<String> parts = text.split('_');
//     if (parts.isEmpty) return '';

//     String firstPart = parts.first.isNotEmpty
//         ? parts.first[0].toUpperCase() + parts.first.substring(1).toLowerCase()
//         : '';

//     String remainingParts =
//         parts.skip(1).map((word) => word.toLowerCase()).join('');

//     return firstPart + remainingParts;
//   }

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: widget.onTap,
//       child: Card(
//         color: AppColors.cardColor,
//         elevation: 0,
//         margin: const EdgeInsets.symmetric(vertical: 6.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8.0),
//           side: BorderSide(color: AppColors.borderColor, width: 1),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       //widget.operation_name,
//                       'Operation : ',
//                       style: AppTextStyles.nameFormat,
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       //widget.operation_name,
//                       toCamelCase(widget.operationName),
//                       style: AppTextStyles.nameFormat,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       //widget.operation_name,
//                       'Date : ',
//                       style: AppTextStyles.nameFormat,
//                     ),
//                   ),
//                   Expanded(
//                     child: Text(
//                       widget.date,
//                       style: AppTextStyles.dateFormat,
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(),
//                   if (widget.delete)
//                     TextButton(
//                       onPressed: () {
//                         onDelete(widget.id);
//                       },
//                       child: const Text('Delete',
//                           style: AppTextStyles.deleteFormat),
//                     ),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }




// import 'package:flutter/material.dart';
// import 'package:margo/constants/material.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';
// import 'package:margo/screens/Inventory/stockin_history.dart';
// import 'package:margo/screens/Inventory/stocktake_history.dart';

// class InventoryHistory extends StatefulWidget {
//   final String jwtToken;
//   const InventoryHistory({
//     Key? key,
//     required this.jwtToken,
//   }) : super(key: key);

//   @override
//   _InventoryHistoryState createState() => _InventoryHistoryState();
// }

// class _InventoryHistoryState extends State<InventoryHistory> {
//   final TextEditingController _searchController = TextEditingController();
//   List<Map<String, dynamic>> inventory_history = [];
//   List<Map<String, dynamic>> filteredIngredients = [];
//   bool isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     _fetchInventoryHistory();
//     // _searchController.addListener(_onSearchChanged);
//   }

//   Future<void> _fetchInventoryHistory() async {
//     setState(() {
//       isLoading = true;
//     });
//     try {
//       print("Token: ${widget.jwtToken}");

//       final response = await http.get(
//         Uri.parse(
//             '$baseUrl/api/inventory/inventory_history'), // Ensure correct API endpoint
//         headers: {
//           'Authorization': 'Bearer ${widget.jwtToken}',
//         },
//       );
//       print('Requesting ingredients from: $baseUrl/api/ingredients');
//       print('Headers: ${{
//         'Authorization': 'Bearer ${widget.jwtToken}',
//       }}');
//       print('Response body: ${response.body}'); // Debugging print statement
//       print('Response status: ${response.statusCode}');

//       if (response.statusCode == 200) {
//         final List<dynamic> data = json.decode(response.body);
//         setState(() {
//           inventory_history = data
//               .map((inventory) => inventory as Map<String, dynamic>)
//               .toList();
//           //filteredIngredients = inventory_history;
//         });
//       } else {
//         throw Exception('Failed to load ingredients');
//       }
//     } catch (error) {
//       print('Error fetching ingredients: $error');
//     } finally {
//       if (mounted) {
//         setState(() {
//           isLoading = false; // Set loading to false
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         leading: IconButton(
//           icon: const Icon(
//             Icons.arrow_back_ios,
//             size: 15,
//             color: Color.fromRGBO(101, 104, 103, 1),
//           ),
//           onPressed: () {
//             Navigator.pop(context);
//           },
//         ),
//         title: const Text(
//           'Inventory History',
//           style: AppTextStyles.heading,
//         ),
//         centerTitle: true,
//         automaticallyImplyLeading: false,
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           children: [
//             Expanded(
//               child: isLoading
//                   ? Center(
//                       child: CircularProgressIndicator(),
//                     )
//                   : ListView(
//                       children: inventory_history.map((inventory) {
//                         //filteredIngredients.map((ingredient) {
//                         return IngredientCard(
//                           id: inventory['id'].toString(),
//                           operation_name: inventory['operation'] ?? 'Unknown',
//                           date: inventory['date'] ?? '',
//                           delete: inventory['date'] ?? false,
//                           //current_worth: inventory['current_worth'].toString(),
//                           onTap: () async {
//                             if (inventory['operation'] == 'stock_in') {
//                               final result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => StockInHistoryDetail(
//                                     // name: ingredient['name'] ?? 'Unknown',
//                                     inventoryId: inventory['id'],
//                                     inventoryData: inventory_history,
//                                   ),
//                                 ),
//                               );

//                               if (result == true) {
//                                 setState(() {
//                                   _fetchInventoryHistory(); // Example: Fetch updated ingredients
//                                 });
//                               }
//                             } else {
//                               final result = await Navigator.push(
//                                 context,
//                                 MaterialPageRoute(
//                                   builder: (context) => StocktakeHistoryDetail(
//                                     inventoryId: inventory['id'],
//                                     inventoryData: inventory_history,
//                                   ),
//                                 ),
//                               );

//                               if (result == true) {
//                                 setState(() {
//                                   _fetchInventoryHistory(); // Example: Fetch updated ingredients
//                                 });
//                               }
//                             }
//                           },
//                         );
//                       }).toList(),
//                     ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   @override
//   void dispose() {
//     _searchController.dispose();
//     super.dispose();
//   }
// }

// class IngredientCard extends StatelessWidget {
//   final String id;
//   final String operation_name;
//   final String date;
//   final bool delete;
//   final VoidCallback onTap;

//   const IngredientCard({
//     required this.id,
//     required this.operation_name,
//     required this.date,
//     required this.delete,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return GestureDetector(
//       onTap: onTap,
//       child: Card(
//         color: Color.fromRGBO(253, 253, 253, 1),
//         elevation: 0,
//         margin: const EdgeInsets.symmetric(vertical: 6.0),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(8.0),
//           side: BorderSide(color: Color.fromRGBO(231, 231, 231, 1), width: 1),
//         ),
//         child: Padding(
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Row(
//                 children: [
//                   Expanded(
//                     child: Text(
//                       operation_name,
//                       style: AppTextStyles.nameFormat,
//                     ),
//                   ),
//                 ],
//               ),
//               SizedBox(height: 4),
//               if (date.isNotEmpty)
//                 Text(
//                   date,
//                   style: AppTextStyles.dateFormat,
//                 ),
//               SizedBox(height: 8),
//               Divider(thickness: 1, color: Color.fromRGBO(230, 242, 242, 1)),
//               SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Container(),
//                   if (delete)
//                     IconButton(
//                       icon: const Icon(Icons.delete, color: Colors.red),
//                       onPressed: onDelete,
//                       tooltip: 'Delete',
//                     ),
//                   // _buildInfoColumn('\$${current_worth}', 'Current Worth'),
//                 ],
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildInfoColumn(String value, String label) {
//     return Padding(
//       padding: const EdgeInsets.all(4.0),
//       child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//         Text(
//           value,
//           style: AppTextStyles.valueFormat,
//         ),
//         SizedBox(height: 4),
//         Text(
//           label,
//           style: AppTextStyles.labelFormat,
//         ),
//       ]),
//     );
//   }
// }

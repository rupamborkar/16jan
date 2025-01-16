import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:margo/constants/material.dart';

class CurrentInventory extends StatefulWidget {
  const CurrentInventory({super.key});

  @override
  State<CurrentInventory> createState() => _CurrentInventoryState();
}

class _CurrentInventoryState extends State<CurrentInventory> {
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<Map<String, dynamic>> stocktakeData = [];
  bool isLoading = false;
  String? _jwtToken;

  @override
  void initState() {
    super.initState();
    _loadTokenAndFetchDetails();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    final token = await _storage.read(key: 'jwt_token');
    if (token == null) {
      print('JWT token not found. Please log in again.');
      return;
    }
    setState(() {
      _jwtToken = token;
    });
    await fetchStocktakeDetails();
  }

  Future<void> fetchStocktakeDetails() async {
    setState(() {
      isLoading = true;
    });
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/inventory/'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> fetchedData = json.decode(response.body);
        setState(() {
          stocktakeData = fetchedData.map((item) {
            return {
              'id': item['id'],
              'ingredient_id': item['ingredient_id'],
              'name': item['name'],
              'price': double.parse(item['price'].toString()),
              'quantity': double.parse(item['quantity'].toString()),
              'quantity_unit': item['quantity_unit'],
            };
          }).toList();
        });
      } else {
        print('Failed to fetch stocktake data: ${response.body}');
      }
    } catch (e) {
      print('Error fetching stocktake details: $e');
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
              color: AppColors.hintColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Current Inventory',
            style: AppTextStyles.heading,
          ),
          centerTitle: true,
        ),
        body: Padding(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: AppColors.borderColor,
                width: 1.0,
              ),
              borderRadius: BorderRadius.circular(8.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          'Ingredient',
                          style: AppTextStyles.nameFormat,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Quantity',
                          style: AppTextStyles.nameFormat,
                          textAlign: TextAlign.center,
                        ),
                      ),
                      Expanded(
                        child: Text(
                          'Price',
                          style: AppTextStyles.nameFormat,
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                  const Divider(),
                  //stocktakeData.isEmpty
                  isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : SingleChildScrollView(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight:
                                  100, // Set a minimum height for the box
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              physics:
                                  NeverScrollableScrollPhysics(), // Disable internal scrolling
                              itemCount: stocktakeData.length,
                              itemBuilder: (context, index) {
                                final item = stocktakeData[index];
                                return Padding(
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 8.0),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      // Ingredient Name
                                      Expanded(
                                        child: Text(
                                          item['name'] ?? 'N/A',
                                          style: AppTextStyles.valueFormat,
                                        ),
                                      ),
                                      // Quantity
                                      Expanded(
                                        child: Text(
                                          '${item['quantity'].toString() ?? 'N/A'} ${item['quantity_unit'].toString() ?? 'N/A'}',
                                          // item['quantity'].toString() ?? 'N/A',
                                          style: AppTextStyles.valueFormat,
                                          textAlign: TextAlign.center,
                                        ),
                                      ),
                                      // Price
                                      Expanded(
                                        child: Text(
                                          item['price'].toString() ?? 'N/A',
                                          style: AppTextStyles.valueFormat,
                                          textAlign: TextAlign.right,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                ],
              ),
            ),
          ),
        )

        // body: Padding(
        //   padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
        //   // padding: const EdgeInsets.all(16.0),
        //   child: Container(
        //     decoration: BoxDecoration(
        //       border: Border.all(
        //         color: AppColors.borderColor,
        //         width: 1.0,
        //       ),
        //       borderRadius: BorderRadius.circular(8.0),
        //     ),
        //     child: Padding(
        //       padding: const EdgeInsets.all(8.0), // Padding inside the border
        //       child: Column(
        //         children: [
        //           Row(
        //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
        //             children: [
        //               Expanded(
        //                 child: Text(
        //                   'Ingredient',
        //                   style: AppTextStyles.nameFormat,
        //                 ),
        //               ),
        //               Expanded(
        //                 child: Text(
        //                   'Quantity',
        //                   style: AppTextStyles.nameFormat,
        //                   textAlign: TextAlign.center,
        //                 ),
        //               ),
        //               Expanded(
        //                 child: Text(
        //                   'Price',
        //                   style: AppTextStyles.nameFormat,
        //                   textAlign: TextAlign.right,
        //                 ),
        //               ),
        //             ],
        //           ),
        //           const Divider(),
        //           stocktakeData.isEmpty
        //               ? const Center(child: CircularProgressIndicator())
        //               : Expanded(
        //                   child: SizedBox(
        //                     height: double.infinity, // Based on your need
        //                     width: double.infinity,
        //                     child: ListView.builder(
        //                       itemCount: stocktakeData.length,
        //                       itemBuilder: (context, index) {
        //                         final item = stocktakeData[index];
        //                         return Padding(
        //                           padding:
        //                               const EdgeInsets.symmetric(vertical: 8.0),
        //                           child: Row(
        //                             mainAxisAlignment:
        //                                 MainAxisAlignment.spaceBetween,
        //                             children: [
        //                               // Ingredient Name
        //                               Expanded(
        //                                 child: Text(
        //                                   item['name'] ?? 'N/A',
        //                                   style: AppTextStyles.valueFormat,
        //                                 ),
        //                               ),
        //                               // Quantity
        //                               Expanded(
        //                                 child: Text(
        //                                   item['quantity'].toString() ?? 'N/A',
        //                                   style: AppTextStyles.valueFormat,
        //                                   textAlign: TextAlign.center,
        //                                 ),
        //                               ),
        //                               // Price
        //                               Expanded(
        //                                 child: Text(
        //                                   item['price'].toString() ?? 'N/A',
        //                                   style: AppTextStyles.valueFormat,
        //                                   textAlign: TextAlign.right,
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                         );
        //                       },
        //                     ),
        //                   ),
        //                 ),
        //         ],
        //       ),
        //     ),
        //   ),
        // ),
        );
  }
}







// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:http/http.dart' as http;
// import 'package:margo/constants/material.dart';

// class CurrentInventory extends StatefulWidget {
//   const CurrentInventory({super.key});

//   @override
//   State<CurrentInventory> createState() => _CurrentInventoryState();
// }

// class _CurrentInventoryState extends State<CurrentInventory> {
//   final FlutterSecureStorage _storage = FlutterSecureStorage();
//   List<Map<String, dynamic>> stocktakeData = [];
//   bool isLoading = false;
//   String? _jwtToken;

//   @override
//   void initState() {
//     super.initState();
//     _loadTokenAndFetchDetails();
//   }

//   Future<void> _loadTokenAndFetchDetails() async {
//     final token = await _storage.read(key: 'jwt_token');
//     if (token == null) {
//       print('JWT token not found. Please log in again.');
//       return;
//     }
//     setState(() {
//       _jwtToken = token;
//     });
//     await fetchStocktakeDetails();
//   }

//   Future<void> fetchStocktakeDetails() async {
//     try {
//       final response = await http.get(
//         Uri.parse('$baseUrl/api/inventory/'),
//         headers: {'Authorization': 'Bearer $_jwtToken'},
//       );

//       if (response.statusCode == 200) {
//         final List<dynamic> fetchedData = json.decode(response.body);
//         setState(() {
//           stocktakeData = fetchedData.map((item) {
//             return {
//               'id': item['id'],
//               'ingredient_id': item['ingredient_id'],
//               'name': item['name'],
//               'price': double.parse(item['price'].toString()),
//               'quantity': double.parse(item['quantity'].toString()),
//               'quantity_unit': item['quantity_unit'],
//             };
//           }).toList();
//         });
//       } else {
//         print('Failed to fetch stocktake data: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching stocktake details: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//         appBar: AppBar(
//           leading: IconButton(
//             icon: const Icon(
//               Icons.arrow_back_ios,
//               size: 15,
//               color: AppColors.hintColor,
//             ),
//             onPressed: () {
//               Navigator.pop(context);
//             },
//           ),
//           title: const Text(
//             'Current Inventory',
//             style: AppTextStyles.heading,
//           ),
//           centerTitle: true,
//         ),
//         body: Padding(
//           padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
//           child: Container(
//             decoration: BoxDecoration(
//               border: Border.all(
//                 color: AppColors.borderColor,
//                 width: 1.0,
//               ),
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Column(
//                 children: [
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                     children: [
//                       Expanded(
//                         child: Text(
//                           'Ingredient',
//                           style: AppTextStyles.nameFormat,
//                         ),
//                       ),
//                       Expanded(
//                         child: Text(
//                           'Quantity',
//                           style: AppTextStyles.nameFormat,
//                           textAlign: TextAlign.center,
//                         ),
//                       ),
//                       Expanded(
//                         child: Text(
//                           'Price',
//                           style: AppTextStyles.nameFormat,
//                           textAlign: TextAlign.right,
//                         ),
//                       ),
//                     ],
//                   ),
//                   const Divider(),
//                   stocktakeData.isEmpty
//                       ? const Center(child: CircularProgressIndicator())
//                       : SingleChildScrollView(
//                           child: ConstrainedBox(
//                             constraints: BoxConstraints(
//                               minHeight:
//                                   100, // Set a minimum height for the box
//                             ),
//                             child: ListView.builder(
//                               shrinkWrap: true,
//                               physics:
//                                   NeverScrollableScrollPhysics(), // Disable internal scrolling
//                               itemCount: stocktakeData.length,
//                               itemBuilder: (context, index) {
//                                 final item = stocktakeData[index];
//                                 return Padding(
//                                   padding:
//                                       const EdgeInsets.symmetric(vertical: 8.0),
//                                   child: Row(
//                                     mainAxisAlignment:
//                                         MainAxisAlignment.spaceBetween,
//                                     children: [
//                                       // Ingredient Name
//                                       Expanded(
//                                         child: Text(
//                                           item['name'] ?? 'N/A',
//                                           style: AppTextStyles.valueFormat,
//                                         ),
//                                       ),
//                                       // Quantity
//                                       Expanded(
//                                         child: Text(
//                                           item['quantity'].toString() ?? 'N/A',
//                                           style: AppTextStyles.valueFormat,
//                                           textAlign: TextAlign.center,
//                                         ),
//                                       ),
//                                       // Price
//                                       Expanded(
//                                         child: Text(
//                                           item['price'].toString() ?? 'N/A',
//                                           style: AppTextStyles.valueFormat,
//                                           textAlign: TextAlign.right,
//                                         ),
//                                       ),
//                                     ],
//                                   ),
//                                 );
//                               },
//                             ),
//                           ),
//                         ),
//                 ],
//               ),
//             ),
//           ),
//         )

//         // body: Padding(
//         //   padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
//         //   // padding: const EdgeInsets.all(16.0),
//         //   child: Container(
//         //     decoration: BoxDecoration(
//         //       border: Border.all(
//         //         color: AppColors.borderColor,
//         //         width: 1.0,
//         //       ),
//         //       borderRadius: BorderRadius.circular(8.0),
//         //     ),
//         //     child: Padding(
//         //       padding: const EdgeInsets.all(8.0), // Padding inside the border
//         //       child: Column(
//         //         children: [
//         //           Row(
//         //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         //             children: [
//         //               Expanded(
//         //                 child: Text(
//         //                   'Ingredient',
//         //                   style: AppTextStyles.nameFormat,
//         //                 ),
//         //               ),
//         //               Expanded(
//         //                 child: Text(
//         //                   'Quantity',
//         //                   style: AppTextStyles.nameFormat,
//         //                   textAlign: TextAlign.center,
//         //                 ),
//         //               ),
//         //               Expanded(
//         //                 child: Text(
//         //                   'Price',
//         //                   style: AppTextStyles.nameFormat,
//         //                   textAlign: TextAlign.right,
//         //                 ),
//         //               ),
//         //             ],
//         //           ),
//         //           const Divider(),
//         //           stocktakeData.isEmpty
//         //               ? const Center(child: CircularProgressIndicator())
//         //               : Expanded(
//         //                   child: SizedBox(
//         //                     height: double.infinity, // Based on your need
//         //                     width: double.infinity,
//         //                     child: ListView.builder(
//         //                       itemCount: stocktakeData.length,
//         //                       itemBuilder: (context, index) {
//         //                         final item = stocktakeData[index];
//         //                         return Padding(
//         //                           padding:
//         //                               const EdgeInsets.symmetric(vertical: 8.0),
//         //                           child: Row(
//         //                             mainAxisAlignment:
//         //                                 MainAxisAlignment.spaceBetween,
//         //                             children: [
//         //                               // Ingredient Name
//         //                               Expanded(
//         //                                 child: Text(
//         //                                   item['name'] ?? 'N/A',
//         //                                   style: AppTextStyles.valueFormat,
//         //                                 ),
//         //                               ),
//         //                               // Quantity
//         //                               Expanded(
//         //                                 child: Text(
//         //                                   item['quantity'].toString() ?? 'N/A',
//         //                                   style: AppTextStyles.valueFormat,
//         //                                   textAlign: TextAlign.center,
//         //                                 ),
//         //                               ),
//         //                               // Price
//         //                               Expanded(
//         //                                 child: Text(
//         //                                   item['price'].toString() ?? 'N/A',
//         //                                   style: AppTextStyles.valueFormat,
//         //                                   textAlign: TextAlign.right,
//         //                                 ),
//         //                               ),
//         //                             ],
//         //                           ),
//         //                         );
//         //                       },
//         //                     ),
//         //                   ),
//         //                 ),
//         //         ],
//         //       ),
//         //     ),
//         //   ),
//         // ),
//         );
//   }
// }

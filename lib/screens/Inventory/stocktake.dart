import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:margo/constants/material.dart';

class StockTakePage extends StatefulWidget {
  final String token;

  const StockTakePage({super.key, required this.token});

  @override
  State<StockTakePage> createState() => _StockTakePageState();
}

class _StockTakePageState extends State<StockTakePage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  List<Map<String, dynamic>> stocktakeData = [];
  List<TextEditingController> priceControllers = [];
  List<TextEditingController> quantityControllers = [];
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
              'price': item['price'].toString(),
              'quantity': item['quantity'].toString(),
              'quantity_unit': item['quantity_unit'],
            };
          }).toList();

          priceControllers = stocktakeData
              .map((item) => TextEditingController(text: item['price']))
              .toList();
          quantityControllers = stocktakeData
              .map((item) => TextEditingController(text: item['quantity']))
              .toList();
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

  Future<void> submitUpdatedStocktake() async {
    if (_formKey.currentState!.validate()) {
      final updatedStock = stocktakeData.map((item) {
        final index = stocktakeData.indexOf(item);
        return {
          'id': item['id'],
          'ingredient_id': item['ingredient_id'],
          'quantity': double.tryParse(quantityControllers[index].text) ?? 0,
          'quantity_unit': item['quantity_unit'],
        };
      }).toList();

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/inventory/stock_take'),
          headers: {
            'Authorization': 'Bearer $_jwtToken',
            'Content-Type': 'application/json',
          },
          body: json.encode({'stocks': updatedStock}),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Stocktake updated successfully!')),
          );

          Navigator.pop(context, true);
        } else {
          print('Failed to update stocktake: ${response.body}');
        }
      } catch (e) {
        print('Error submitting stocktake updates: $e');
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
          'Stocktake',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : stocktakeData.isEmpty
              ? const Center(
                  child: Text(
                    'Empty Stocktake. Please add something in the inventory first',
                    textAlign: TextAlign.center,
                  ),
                )
              : Form(
                  key: _formKey,
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: stocktakeData.length,
                    itemBuilder: (context, index) {
                      final item = stocktakeData[index];
                      return Card(
                        color: const Color.fromRGBO(253, 253, 253, 1),
                        elevation: 0,
                        margin: const EdgeInsets.symmetric(vertical: 6.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                          side: const BorderSide(
                            color: Color.fromRGBO(231, 231, 231, 1),
                            width: 1,
                          ),
                        ),
                        child: ExpansionTile(
                          title: Text(
                            item['name'] ?? 'Ingredient',
                            style: AppTextStyles.labelBoldFormat,
                          ),
                          collapsedShape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          ),
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Quantity',
                                    style: AppTextStyles.labelFormat,
                                  ),
                                  const SizedBox(height: 8.0),
                                  Row(
                                    children: [
                                      SizedBox(
                                        width: 120,
                                        height: 40,
                                        child: TextFormField(
                                          controller:
                                              quantityControllers[index],
                                          // initialValue: item['quantity'],
                                          keyboardType:
                                              TextInputType.numberWithOptions(
                                                  decimal: true),
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                              vertical: 4.0,
                                              horizontal: 8.0,
                                            ),
                                          ),
                                          validator: (value) {
                                            if (value == null ||
                                                value.isEmpty) {
                                              return 'Quantity is required';
                                            }
                                            final enteredQuantity =
                                                double.tryParse(value);
                                            final fetchedQuantity =
                                                double.tryParse(item['quantity']
                                                    .toString());
                                            if (enteredQuantity != null &&
                                                fetchedQuantity != null &&
                                                enteredQuantity >
                                                    fetchedQuantity) {
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                    'Quantity cannot exceed the stocktake quantity (${fetchedQuantity.toString()})',
                                                  ),
                                                  // backgroundColor: Colors.red,
                                                  duration: const Duration(
                                                      seconds: 3),
                                                ),
                                              );
                                              return '';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      SizedBox(
                                        width: 180.0,
                                        height: 40,
                                        child: TextFormField(
                                          initialValue: item['quantity_unit'],
                                          keyboardType: TextInputType.number,
                                          decoration: InputDecoration(
                                            hintText: 'Unit',
                                            hintStyle: const TextStyle(
                                                fontSize: 15,
                                                height: 1.5,
                                                fontWeight: FontWeight.w300,
                                                color: Color.fromRGBO(
                                                    150, 153, 151, 1)),
                                            border: OutlineInputBorder(
                                              borderRadius:
                                                  BorderRadius.circular(8.0),
                                              borderSide: const BorderSide(
                                                  width: 1.0,
                                                  style: BorderStyle.solid,
                                                  color: Color.fromRGBO(
                                                      231, 231, 231, 1)),
                                            ),
                                            contentPadding:
                                                const EdgeInsets.symmetric(
                                                    vertical: 4.0,
                                                    horizontal: 8.0),
                                            fillColor: Color.fromRGBO(
                                                231, 231, 231, 1),
                                            filled: true,
                                          ),
                                          enabled: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                      // return Card(
                      //   margin: const EdgeInsets.symmetric(vertical: 8.0),
                      //   child: Padding(
                      //     padding: const EdgeInsets.all(16.0),
                      //     child: Column(
                      //       crossAxisAlignment: CrossAxisAlignment.start,
                      //       children: [
                      //         Text(
                      //           item['name'],
                      //           style: const TextStyle(
                      //             fontSize: 18,
                      //             fontWeight: FontWeight.bold,
                      //           ),
                      //         ),
                      //         const SizedBox(height: 8),
                      //         Row(
                      //           children: [
                      //             Flexible(
                      //               child: TextFormField(
                      //                 controller: priceControllers[index],
                      //                 decoration: const InputDecoration(
                      //                   labelText: 'Price',
                      //                   border: OutlineInputBorder(),
                      //                 ),
                      //                 keyboardType: TextInputType.number,
                      //               ),
                      //             ),
                      //             const SizedBox(width: 16),
                      //             Flexible(
                      //               child: TextFormField(
                      //                 controller: quantityControllers[index],
                      //                 decoration: const InputDecoration(
                      //                   labelText: 'Quantity',
                      //                   border: OutlineInputBorder(),
                      //                 ),
                      //                 keyboardType: TextInputType.number,
                      //               ),
                      //             ),
                      //           ],
                      //         ),
                      //         const SizedBox(height: 8),
                      //         Text(
                      //           'Unit: ${item['quantity_unit']}',
                      //           style: const TextStyle(fontSize: 16),
                      //         ),
                      //       ],
                      //     ),
                      //   ),
                      // );
                    },
                  ),
                ),
      bottomNavigationBar: Padding(
        // padding: const EdgeInsets.all(16.0),
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: SizedBox(
          //width: double.infinity,
          width: 353,
          height: 50,
          child: ElevatedButton(
            onPressed: submitUpdatedStocktake,
            style: AppStyles.elevatedButtonStyle,
            child: const Text(
              'Update',
              style: AppTextStyles.buttonText,
            ),
          ),
        ),
      ),
      // bottomNavigationBar: Padding(
      //   padding: const EdgeInsets.all(16.0),
      //   child: ElevatedButton(
      //     onPressed: submitUpdatedStocktake,
      //     style: AppStyles.elevatedButtonStyle,
      //     child: const Text(
      //       'Update',
      //       style: AppTextStyles.buttonText,
      //     ),
      //   ),
      // ),
    );
  }

  Widget buildDisabledTextField(String label, String hint,
//initialValue,
      {required initialValue}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.labelFormat,
            ),
          ),
          const SizedBox(height: 8),
          SizedBox(
            width: 340,
            height: 40,
            child: TextFormField(
              initialValue: initialValue,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.valueFormat,
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                disabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                  borderRadius: BorderRadius.circular(10),
                ),
                fillColor: Color.fromRGBO(231, 231, 231, 1),
                filled: true,
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}





// import 'package:flutter/material.dart';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:flutter_secure_storage/flutter_secure_storage.dart';
// import 'package:margo/constants/material.dart';

// class StockTakePage extends StatefulWidget {
//   final String token;

//   const StockTakePage({super.key, required this.token});

//   @override
//   State<StockTakePage> createState() => _StockTakePageState();
// }

// class _StockTakePageState extends State<StockTakePage> {
//   final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
//   final FlutterSecureStorage _storage = FlutterSecureStorage();
//   List<Map<String, dynamic>> stocktakeData = [];
//   List<TextEditingController> priceControllers = [];
//   List<TextEditingController> quantityControllers = [];
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
//               'price': item['price'].toString(),
//               'quantity': item['quantity'].toString(),
//               'quantity_unit': item['quantity_unit'],
//             };
//           }).toList();

//           priceControllers = stocktakeData
//               .map((item) => TextEditingController(text: item['price']))
//               .toList();
//           quantityControllers = stocktakeData
//               .map((item) => TextEditingController(text: item['quantity']))
//               .toList();
//         });
//       } else {
//         print('Failed to fetch stocktake data: ${response.body}');
//       }
//     } catch (e) {
//       print('Error fetching stocktake details: $e');
//     }
//   }

//   Future<void> submitUpdatedStocktake() async {
//     if (_formKey.currentState!.validate()) {
//       final updatedStock = stocktakeData.map((item) {
//         final index = stocktakeData.indexOf(item);
//         return {
//           'id': item['id'],
//           'ingredient_id': item['ingredient_id'],
//           'quantity': double.tryParse(quantityControllers[index].text) ?? 0,
//           'quantity_unit': item['quantity_unit'],
//         };
//       }).toList();

//       try {
//         final response = await http.post(
//           Uri.parse('$baseUrl/api/inventory/stock_take'),
//           headers: {
//             'Authorization': 'Bearer $_jwtToken',
//             'Content-Type': 'application/json',
//           },
//           body: json.encode({'stocks': updatedStock}),
//         );

//         if (response.statusCode == 200 || response.statusCode == 201) {
//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(content: Text('Stocktake updated successfully!')),
//           );

//           Navigator.pop(context, true);
//         } else {
//           print('Failed to update stocktake: ${response.body}');
//         }
//       } catch (e) {
//         print('Error submitting stocktake updates: $e');
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
//           'Stocktake',
//           style: AppTextStyles.heading,
//         ),
//         centerTitle: true,
//       ),
//       body: stocktakeData.isEmpty
//           ? const Center(child: CircularProgressIndicator())
//           : Form(
//               key: _formKey, // Wrap content with Form widget
//               child: ListView.builder(
//                 padding: const EdgeInsets.all(16),
//                 itemCount: stocktakeData.length,
//                 itemBuilder: (context, index) {
//                   final item = stocktakeData[index];
//                   return Card(
//                     color: const Color.fromRGBO(253, 253, 253, 1),
//                     elevation: 0,
//                     margin: const EdgeInsets.symmetric(vertical: 6.0),
//                     shape: RoundedRectangleBorder(
//                       borderRadius: BorderRadius.circular(8.0),
//                       side: const BorderSide(
//                         color: Color.fromRGBO(231, 231, 231, 1),
//                         width: 1,
//                       ),
//                     ),
//                     child: ExpansionTile(
//                       title: Text(
//                         item['name'] ?? 'Ingredient',
//                         style: AppTextStyles.labelBoldFormat,
//                       ),
//                       collapsedShape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       shape: RoundedRectangleBorder(
//                         borderRadius: BorderRadius.circular(8.0),
//                       ),
//                       children: [
//                         Padding(
//                           padding: const EdgeInsets.all(8.0),
//                           child: Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               const Text(
//                                 'Quantity',
//                                 style: AppTextStyles.labelFormat,
//                               ),
//                               const SizedBox(height: 8.0),
//                               Row(
//                                 children: [
//                                   SizedBox(
//                                     width: 120,
//                                     height: 40,
//                                     child: TextFormField(
//                                       controller: quantityControllers[index],
//                                       // initialValue: item['quantity'],
//                                       keyboardType:
//                                           TextInputType.numberWithOptions(
//                                               decimal: true),
//                                       decoration: InputDecoration(
//                                         border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(8),
//                                         ),
//                                         contentPadding:
//                                             const EdgeInsets.symmetric(
//                                           vertical: 4.0,
//                                           horizontal: 8.0,
//                                         ),
//                                       ),
//                                       validator: (value) {
//                                         if (value == null || value.isEmpty) {
//                                           return 'Quantity is required';
//                                         }
//                                         final enteredQuantity =
//                                             double.tryParse(value);
//                                         final fetchedQuantity = double.tryParse(
//                                             item['quantity'].toString());
//                                         if (enteredQuantity != null &&
//                                             fetchedQuantity != null &&
//                                             enteredQuantity > fetchedQuantity) {
//                                           ScaffoldMessenger.of(context)
//                                               .showSnackBar(
//                                             SnackBar(
//                                               content: Text(
//                                                 'Quantity cannot exceed the stocktake quantity (${fetchedQuantity.toString()})',
//                                               ),
//                                               // backgroundColor: Colors.red,
//                                               duration:
//                                                   const Duration(seconds: 3),
//                                             ),
//                                           );
//                                           return '';
//                                         }
//                                         return null;
//                                       },
//                                     ),
//                                   ),
//                                   const SizedBox(width: 10),
//                                   SizedBox(
//                                     width: 180.0,
//                                     height: 40,
//                                     child: TextFormField(
//                                       initialValue: item['quantity_unit'],
//                                       keyboardType: TextInputType.number,
//                                       decoration: InputDecoration(
//                                         hintText: 'Unit',
//                                         hintStyle: const TextStyle(
//                                             fontSize: 15,
//                                             height: 1.5,
//                                             fontWeight: FontWeight.w300,
//                                             color: Color.fromRGBO(
//                                                 150, 153, 151, 1)),
//                                         border: OutlineInputBorder(
//                                           borderRadius:
//                                               BorderRadius.circular(8.0),
//                                           borderSide: const BorderSide(
//                                               width: 1.0,
//                                               style: BorderStyle.solid,
//                                               color: Color.fromRGBO(
//                                                   231, 231, 231, 1)),
//                                         ),
//                                         contentPadding:
//                                             const EdgeInsets.symmetric(
//                                                 vertical: 4.0, horizontal: 8.0),
//                                         fillColor:
//                                             Color.fromRGBO(231, 231, 231, 1),
//                                         filled: true,
//                                       ),
//                                       enabled: false,
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                             ],
//                           ),
//                         ),
//                       ],
//                     ),
//                   );
//                   // return Card(
//                   //   margin: const EdgeInsets.symmetric(vertical: 8.0),
//                   //   child: Padding(
//                   //     padding: const EdgeInsets.all(16.0),
//                   //     child: Column(
//                   //       crossAxisAlignment: CrossAxisAlignment.start,
//                   //       children: [
//                   //         Text(
//                   //           item['name'],
//                   //           style: const TextStyle(
//                   //             fontSize: 18,
//                   //             fontWeight: FontWeight.bold,
//                   //           ),
//                   //         ),
//                   //         const SizedBox(height: 8),
//                   //         Row(
//                   //           children: [
//                   //             Flexible(
//                   //               child: TextFormField(
//                   //                 controller: priceControllers[index],
//                   //                 decoration: const InputDecoration(
//                   //                   labelText: 'Price',
//                   //                   border: OutlineInputBorder(),
//                   //                 ),
//                   //                 keyboardType: TextInputType.number,
//                   //               ),
//                   //             ),
//                   //             const SizedBox(width: 16),
//                   //             Flexible(
//                   //               child: TextFormField(
//                   //                 controller: quantityControllers[index],
//                   //                 decoration: const InputDecoration(
//                   //                   labelText: 'Quantity',
//                   //                   border: OutlineInputBorder(),
//                   //                 ),
//                   //                 keyboardType: TextInputType.number,
//                   //               ),
//                   //             ),
//                   //           ],
//                   //         ),
//                   //         const SizedBox(height: 8),
//                   //         Text(
//                   //           'Unit: ${item['quantity_unit']}',
//                   //           style: const TextStyle(fontSize: 16),
//                   //         ),
//                   //       ],
//                   //     ),
//                   //   ),
//                   // );
//                 },
//               ),
//             ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: ElevatedButton(
//           onPressed: submitUpdatedStocktake,
//           style: AppStyles.elevatedButtonStyle,
//           child: const Text(
//             'Update',
//             style: AppTextStyles.buttonText,
//           ),
//         ),
//       ),
//     );
//   }

//   Widget buildDisabledTextField(String label, String hint,
// //initialValue,
//       {required initialValue}) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 10.0),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           RichText(
//             text: TextSpan(
//               text: label,
//               style: AppTextStyles.labelFormat,
//             ),
//           ),
//           const SizedBox(height: 8),
//           SizedBox(
//             width: 340,
//             height: 40,
//             child: TextFormField(
//               initialValue: initialValue,
//               decoration: InputDecoration(
//                 hintText: hint,
//                 hintStyle: AppTextStyles.valueFormat,
//                 border:
//                     OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                 disabledBorder: OutlineInputBorder(
//                   borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
//                   borderRadius: BorderRadius.circular(10),
//                 ),
//                 fillColor: Color.fromRGBO(231, 231, 231, 1),
//                 filled: true,
//               ),
//               enabled: false,
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }

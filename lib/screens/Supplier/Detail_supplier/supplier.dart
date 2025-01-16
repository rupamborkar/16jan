import 'package:enefty_icons/enefty_icons.dart';
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:margo/screens/Supplier/Detail_supplier/supplier_detail.dart';

class SupplierPage extends StatefulWidget {
  final String jwtToken;

  const SupplierPage({Key? key, required this.jwtToken}) : super(key: key);

  @override
  _SupplierPageState createState() => _SupplierPageState();
}

class _SupplierPageState extends State<SupplierPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> suppliers = [];
  List<Map<String, dynamic>> filteredSuppliers = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
    _searchController.addListener(_onSearchChanged);
  }

  Future<void> _fetchSuppliers() async {
    setState(() {
      isLoading = true; // Set loading to true
    });
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/supplier/'),
        headers: {
          'Authorization': 'Bearer ${widget.jwtToken}',
        },
      );

      print('Response body: ${response.body}'); // Debugging print statement
      print('Response status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          suppliers = data.map((item) => item as Map<String, dynamic>).toList();
          filteredSuppliers = suppliers;
        });
      } else {
        throw Exception('Failed to load suppliers');
      }
    } catch (error) {
      print('Error fetching suppliers: $error');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false; // Set loading to false
        });
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      filteredSuppliers = suppliers.where((supplier) {
        return supplier['name']!
            .toLowerCase()
            .contains(_searchController.text.toLowerCase());
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Suppliers',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Container(
                    width: 353,
                    height: 40,
                    padding:
                        const EdgeInsets.symmetric(vertical: 4, horizontal: 8),
                    decoration: BoxDecoration(
                      color: const Color.fromRGBO(231, 231, 231, 1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: const InputDecoration(
                        hintText: 'Search',
                        hintStyle: AppTextStyles.hintFormat,
                        prefixIcon: Icon(
                          EneftyIcons.search_normal_2_outline,
                          // Icons.search,
                          size: 20,
                          color: Color.fromRGBO(101, 104, 103, 1),
                        ),
                        border: InputBorder.none,
                        isDense: true,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
              ],
            ),
            const SizedBox(height: 10),
            Expanded(
              child: isLoading
                  ? Center(
                      child: CircularProgressIndicator(),
                    )
                  : ListView(
                      children: filteredSuppliers.map((supplier) {
                        return SupplierCard(
                          id: supplier['supplier_id'],
                          name: supplier['name'] ?? 'Unknown',
                          email: supplier['email'] ?? 'Unknown',
                          phone: supplier['phone'] ?? 'N/A',
                          date: supplier['last_update'] ?? '',
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => SupplierDetail(
                                  supplierId: supplier['supplier_id'],
                                  onTabChanged: (int) {},
                                ),
                              ),
                            );
                            if (result == true) {
                              setState(() {
                                _fetchSuppliers();
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

class SupplierCard extends StatelessWidget {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String date;
  final VoidCallback onTap;

  const SupplierCard({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.date,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: const Color.fromRGBO(253, 253, 253, 1),
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
                    child: Text(
                      name,
                      style: AppTextStyles.nameFormat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                date,
                style: AppTextStyles.dateFormat,
              ),
              const SizedBox(height: 8),
              const Divider(
                thickness: 1,
                color: Color.fromRGBO(230, 242, 242, 1),
              ),
              const SizedBox(height: 8),
              // Row(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [
              _buildInfoColumn('Phone', phone),
              _buildInfoColumn('Email  ', email),
              // ],
              // ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.labelFormat,
            ),
            const SizedBox(width: 10),
            Spacer(
              flex: 1,
            ),
            Text(
              value,
              style: AppTextStyles.valueFormat,
            ),
            Spacer(
              flex: 40,
            )
          ],
        )
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Supplier/Detail_supplier/supplier_ingredient_screen.dart';
import 'package:margo/screens/Supplier/Edit_supplier/supplier_edit_screen.dart';

class SupplierDetail extends StatefulWidget {
  final String supplierId;
  final Function(int) onTabChanged;

  const SupplierDetail(
      {required this.onTabChanged, super.key, required this.supplierId});

  @override
  _SupplierDetailState createState() => _SupplierDetailState();
}

class _SupplierDetailState extends State<SupplierDetail>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FlutterSecureStorage _storage = FlutterSecureStorage();
  Map<String, dynamic>? supplierData;
  String? _jwtToken;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() {
      widget.onTabChanged(_tabController.index);
    });
    _loadTokenAndFetchDetails();
  }

  Future<void> _loadTokenAndFetchDetails() async {
    try {
      final token = await _storage.read(key: 'jwt_token');
      if (token == null) {
        throw Exception("JWT token not found. Please log in again.");
      }
      setState(() {
        _jwtToken = token;
      });

      await fetchSupplierDetails();
    } catch (e) {
      print("Error loading token or fetching ingredient details: $e");
    }
  }

  Future<void> fetchSupplierDetails() async {
    if (_jwtToken == null) return;

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/supplier/${widget.supplierId}/full'),
        headers: {'Authorization': 'Bearer $_jwtToken'},
      );

      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        setState(() {
          supplierData = json.decode(response.body);
        });
      } else {
        print(
            'Failed to load supplier data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
    }
  }

  Future<void> _navigateToSupplierDetail() async {
    final shouldRefresh = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SupplierDetail(
          supplierId: 'your_supplier_id',
          onTabChanged: (index) {
            print('Tab changed to: $index');
          },
        ),
      ),
    );

    if (shouldRefresh == true) {
      print("Refreshing supplier details...");
      fetchSupplierDetails();
    }
  }

  void duplicateSupplier(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content:
              const Text('Supplier is related to alredy present ingredient '),
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

  Future<void> deleteSupplier(String supplierId) async {
    try {
      final response = await http.delete(
        Uri.parse('$baseUrl/api/supplier/$supplierId'),
        headers: {
          'Authorization': 'Bearer $_jwtToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Supplier deleted successfully')),
        );
        Navigator.of(context).pop(true);
      } else if (response.statusCode == 403) {
        duplicateSupplier(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to delete supplier.')),
        );
      }
    } catch (e) {
      print('Error deleting supplier: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('An error occurred while deleting the supplier.')),
      );
    }
  }

  void confirmDelete() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this supplier?'),
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
                deleteSupplier(widget.supplierId);
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
    return Scaffold(
      backgroundColor: Colors.white,
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
        title: Text(
          supplierData?['name'] ?? ' ',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.edit_outlined,
              color: AppColors.hintColor,
            ),
            onPressed: () async {
              if (_tabController.index == 0) {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) =>
                          SupplierEditScreen(supplierId: widget.supplierId)),
                );

                if (result == true) {
                  setState(() {
                    fetchSupplierDetails();
                  });
                }
              } else if (_tabController.index == 1) {}
            },
          )
        ],
        bottom: TabBar(
          labelColor: AppColors.buttonColor,
          unselectedLabelColor: AppColors.labelColor,
          indicatorColor: AppColors.buttonColor,
          controller: _tabController,
          tabs: const [
            Tab(text: 'Details'),
            Tab(text: 'Ingredients'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildDetailsTab(),
          SupplierIngredientScreen(supplierId: widget.supplierId),
        ],
      ),
    );
  }

  Widget _buildDetailsTab() {
    if (supplierData == null) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Card(
            color: Color.fromRGBO(253, 253, 253, 1),
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
                  _buildDetailRow(
                      'Supplier Name', supplierData?['name'] ?? 'N/A'),
                  _buildDetailRow(
                      'Agent Name', supplierData?['agent_name'] ?? 'N/A'),
                  _buildDetailRow(
                      'Location', supplierData?['location'] ?? 'N/A'),
                  _buildDetailRow('VAT No', supplierData?['vat_no'] ?? 'N/A'),
                  _buildDetailRow('Address', supplierData?['address'] ?? 'N/A'),
                  _buildDetailRow('Phone', supplierData?['phone'] ?? 'N/A'),
                  _buildDetailRow('Email', supplierData?['email'] ?? 'N/A'),
                  _buildDetailRow(
                      'Last Update', supplierData?['last_update'] ?? 'N/A'),
                  _buildDetailRow(
                      'Comments', supplierData?['comments'] ?? 'N/A'),
                ],
              ),
            ),
          ),
          const SizedBox(height: 2),
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton(
              onPressed: () {
                confirmDelete();
              },
              child: const Text('Delete Supplier',
                  style: AppTextStyles.deleteFormat),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$title:',
              style: AppTextStyles.labelFormat,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: AppTextStyles.valueFormat,
              textAlign: TextAlign.left,
            ),
          ),
        ],
      ),
    );
  }
}

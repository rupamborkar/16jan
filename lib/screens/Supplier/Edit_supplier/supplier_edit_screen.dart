import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class SupplierEditScreen extends StatefulWidget {
  final String supplierId;

  const SupplierEditScreen({super.key, required this.supplierId});

  @override
  _SupplierEditScreenState createState() => _SupplierEditScreenState();
}

class _SupplierEditScreenState extends State<SupplierEditScreen> {
  final double fieldHeight = 50.0;
  final double fieldWidth = double.infinity;

  final FlutterSecureStorage _storage =
      FlutterSecureStorage(); // Secure storage
  Map<String, dynamic>? supplierData;
  String? _jwtToken;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController agentController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController vatController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController commentsController = TextEditingController();

  final _formKey = GlobalKey<FormState>(); // Global key for the form

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

      if (response.statusCode == 200) {
        supplierData = json.decode(response.body);
        setState(() {
          nameController.text = supplierData?['name'] ?? '';
          agentController.text = supplierData?['agent_name'] ?? '';
          locationController.text = supplierData?['location'] ?? '';
          emailController.text = supplierData?['email'] ?? '';
          phoneController.text = supplierData?['phone'] ?? '';
          vatController.text = supplierData?['vat_no'] ?? '';
          addressController.text = supplierData?['address'] ?? '';
          commentsController.text = supplierData?['comments'] ?? '';
        });
      } else {
        print(
            'Failed to load supplier data. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching supplier data: $e');
    }
  }

  Future<void> updateSupplierDetails() async {
    if (_jwtToken == null) return;

    if (_formKey.currentState?.validate() ?? false) {
      try {
        final Map<String, dynamic> payload = {
          "name": nameController.text,
          "agent_name": agentController.text,
          "location": locationController.text,
          "email": emailController.text,
          "phone": phoneController.text,
          "vat_no": vatController.text,
          "address": addressController.text,
          "comments": commentsController.text,
        };

        final response = await http.put(
          Uri.parse('$baseUrl/api/supplier/${widget.supplierId}'),
          headers: {
            'Authorization': 'Bearer $_jwtToken',
            'Content-Type': 'application/json',
          },
          body: json.encode(payload),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
                content: Text('Supplier details updated successfully!')),
          );
          Navigator.pop(context, true);
        } else if (response.statusCode == 403) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Supplier with same name already exists')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to update Supplier: ${response.body}')),
          );
        }
      } catch (e) {
        print('Error updating supplier details: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Edit',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
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
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey, // Form widget with global key
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildTextField('Supplier Name *', nameController),
              _buildTextField('Agent Name *', agentController),
              _buildTextField('Location', locationController),
              _buildTextField('Email', emailController),
              _buildTextField('Phone', phoneController, isNumber: true),
              _buildTextField('VAT No', vatController),
              _buildTextField('Address', addressController),
              _buildTextField('Comments', commentsController, maxLines: 1),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              updateSupplierDetails();
            },
            style: AppStyles.elevatedButtonStyle,
            child: const Text(
              'Update',
              style: AppTextStyles.buttonText,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label.replaceAll('*', ''),
              style: AppTextStyles.labelFormat,
              children: [
                if (label.contains('*'))
                  const TextSpan(
                    text: ' *',
                    style: TextStyle(
                      color: Colors.red,
                      fontSize: 16.0,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: 353,
            height: 40,
            child: TextFormField(
              controller: controller,
              keyboardType: isNumber
                  ? TextInputType.numberWithOptions(decimal: true)
                  : TextInputType.text,
              maxLines: maxLines,
              decoration: InputDecoration(
                hintStyle: AppTextStyles.valueFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              validator: (value) {
                if (label.toLowerCase().contains('email')) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your email';
                  }
                  if (!RegExp(
                          r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                      .hasMatch(value)) {
                    return 'Please enter a valid email';
                  }
                } else {
                  if (label.contains('*') &&
                      (value == null || value.trim().isEmpty)) {
                    return '${label.replaceAll('*', '').trim()} is required';
                  }
                }
                return null;
              },
              textInputAction: TextInputAction.done,
            ),
          ),
        ],
      ),
    );
  }
}

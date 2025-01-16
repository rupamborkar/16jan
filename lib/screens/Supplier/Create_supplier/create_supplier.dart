import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:http/http.dart' as http;

class CreateSupplierPage extends StatelessWidget {
  final String token;
  final VoidCallback onEntityCreated;
  const CreateSupplierPage({
    super.key,
    required this.token,
    required this.onEntityCreated,
  });

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();
    final TextEditingController nameController = TextEditingController();
    final TextEditingController agentController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController emailController = TextEditingController();
    final TextEditingController phoneController = TextEditingController();
    final TextEditingController vatController = TextEditingController();
    final TextEditingController addressController = TextEditingController();
    final TextEditingController commentsController = TextEditingController();

    void duplicateSupplier(BuildContext context) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            content: const Text('Supplier with same name already exists'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog
                },
                child: const Text('Ok'),
              ),
            ],
          );
        },
      );
    }

    Future<void> saveSupplier() async {
      final Map<String, dynamic> supplierData = {
        "name": nameController.text.trim(),
        "agent_name": agentController.text.trim(),
        "location": locationController.text.trim(),
        "email": emailController.text.trim(),
        "phone": phoneController.text.trim(),
        "vat_no": vatController.text.trim(),
        "address": addressController.text.trim(),
        "comments": commentsController.text.trim(),
      };

      try {
        final response = await http.post(
          Uri.parse('$baseUrl/api/supplier/'),
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'application/json'
          },
          body: jsonEncode(supplierData),
        );

        if (response.statusCode == 200 || response.statusCode == 201) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Supplier saved successfully!')),
          );

          onEntityCreated();
          Navigator.pop(context, true);
        } else if (response.statusCode == 403) {
          duplicateSupplier(context);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
                content: Text('Failed to save Supplier: ${response.body}')),
          );
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Center(
          child: Text(
            'Create Supplier',
            style: AppTextStyles.heading,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              color: AppColors.hintColor,
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: formKey,
          child: Column(
            children: [
              Expanded(
                child: ListView(
                  children: [
                    const Text(
                      'Basic Details',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                        color: Color.fromRGBO(10, 15, 13, 1),
                      ),
                    ),
                    const SizedBox(height: 20),
                    _buildTextField(
                      controller: nameController,
                      label: 'Supplier Name *',
                      hintText: 'Enter the name of the supplier',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: agentController,
                      label: 'Agent Name *',
                      hintText: 'Enter the name of the supplier',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: locationController,
                      label: 'Location',
                      hintText: 'Enter location',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: emailController,
                      label: 'Email',
                      hintText: 'Enter email id',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: phoneController,
                      label: 'Phone',
                      hintText: 'Enter phone number',
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: vatController,
                      label: 'VAT No',
                      hintText: 'Enter VAT number',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: addressController,
                      label: 'Address',
                      hintText: 'Enter address',
                      keyboardType: TextInputType.text,
                    ),
                    const SizedBox(height: 12),
                    _buildTextField(
                      controller: commentsController,
                      label: 'Comments',
                      hintText: 'Add comments',
                      keyboardType: TextInputType.text,
                    ),
                  ],
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        if (formKey.currentState!.validate()) {
                          saveSupplier();
                        }
                      },
                      style: AppStyles.elevatedButtonStyle,
                      child: const Text(
                        'Save',
                        style: AppTextStyles.buttonText,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hintText,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4.0),
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
          const SizedBox(height: 8.0),
          SizedBox(
            width: 353,
            height: 40,
            child: TextFormField(
              controller: controller,
              decoration: InputDecoration(
                hintText: hintText,
                hintStyle: AppTextStyles.hintFormat,
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                  borderSide: const BorderSide(
                      width: 1.0,
                      style: BorderStyle.solid,
                      color: Color.fromRGBO(231, 231, 231, 1)),
                ),
              ),
              keyboardType: keyboardType ?? TextInputType.text,
              maxLines: maxLines,
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

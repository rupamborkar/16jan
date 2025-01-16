import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PersonalInfoScreen extends StatefulWidget {
  final String token;

  const PersonalInfoScreen({super.key, required this.token});

  @override
  State<PersonalInfoScreen> createState() => _PersonalInfoScreenState();
}

class _PersonalInfoScreenState extends State<PersonalInfoScreen> {
  Map<String, dynamic>? userData;

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController roleController;
  late TextEditingController assignedByController;

  @override
  void initState() {
    super.initState();
    nameController = TextEditingController();
    emailController = TextEditingController();
    roleController = TextEditingController();
    assignedByController = TextEditingController();
    _fetchUsersInfo();
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    roleController.dispose();
    assignedByController.dispose();
    super.dispose();
  }

  Future<void> _fetchUsersInfo() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/api/user/complete_info'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
        },
      );

      if (response.statusCode == 200) {
        setState(() {
          userData = json.decode(response.body);
          nameController.text = userData?['user_name'] ?? '';
          emailController.text = userData?['email'] ?? '';
          roleController.text = userData?['role'] ?? '';
          assignedByController.text = userData?['assigned_by'] ?? '';
        });
      } else {
        throw Exception('Failed to load user data');
      }
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon:
              Icon(Icons.arrow_back_ios, size: 15, color: AppColors.hintColor),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text('Personal Info', style: AppTextStyles.heading
            // TextStyle(
            //     fontSize: 20,
            //     height: 24,
            //     fontWeight: FontWeight.w600,
            //     color: Color.fromRGBO(10, 15, 13, 1))
            ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTextField('Name', nameController),
            SizedBox(height: 16),

            _buildTextField('Email ID', emailController),
            SizedBox(height: 16),

            _buildDisabledTextField('Role Assigned', roleController),
            SizedBox(height: 16),

            _buildDisabledTextField('Assigned By', assignedByController),
            SizedBox(height: 35),
            //SizedBox(height: 16),
            // ElevatedButton(
            //   onPressed: () {},
            //   child: Text(
            //     'Save',
            //     style: TextStyle(
            //       color: Colors.white,
            //       fontSize: 16,
            //     ),
            //   ),
            //   style: ElevatedButton.styleFrom(
            //     padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            //     backgroundColor: Color.fromRGBO(101, 104, 103, 1),
            //     shape: RoundedRectangleBorder(
            //       borderRadius: BorderRadius.circular(30),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelFormat
            //TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 40,
          // padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: Colors.grey),
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(8, 4, 4, 8)

                //isDense: true,
                ),
          ),
        ),
      ],
    );
  }

  Widget _buildDisabledTextField(
      String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelFormat
            //TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
        SizedBox(height: 6),
        Container(
          width: double.infinity,
          height: 40,
          //padding: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(8),
            border: Border.all(width: 1, color: Colors.grey),
            color: Colors.grey[200], // Grey background color
            //filled: true, // To make the fi
          ),
          child: TextField(
            controller: controller,
            decoration: InputDecoration(
                border: InputBorder.none,
                contentPadding: const EdgeInsets.fromLTRB(8, 4, 4, 8),
                // isDense: true,
                enabled: false),
          ),
        ),
      ],
    );
  }
}

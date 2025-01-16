import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditUserScreen extends StatefulWidget {
  final String email;
  final String role;
  final String token;

  const EditUserScreen(
      {super.key,
      required this.email,
      required this.role,
      required this.token});
  @override
  State<EditUserScreen> createState() => _EditUserScreenState();
}

class _EditUserScreenState extends State<EditUserScreen> {
  late TextEditingController roleController;
  // final FlutterSecureStorage _storage = FlutterSecureStorage();
  // String? _jwtToken;
  final List<String> roleList = ['Chef', 'Manager', 'User'];
  late String selectedRole;

  @override
  void initState() {
    super.initState();
    if (roleList.contains(widget.role)) {
      selectedRole = widget.role;
    } else {
      selectedRole = roleList.first; // Default to the first item
    }
  }

  @override
  void dispose() {
    roleController.dispose();
    super.dispose();
  }

  Future<void> saveUserDetails() async {
    final response = await http.put(
      Uri.parse('$baseUrl/api/user/change_role'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'email': widget.email, 'role': selectedRole}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User details saved successfully!')),
      );

      Navigator.pop(context);
    }
  }

  Future<void> deleteUser(String email) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/api/user/delete_user'),
      headers: {
        'Authorization': 'Bearer ${widget.token}',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'email': email,

        //roleController.text,
      }),
    );
    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('User deleted successfully!')),
      );

      Navigator.pop(context);
      // setState(() {
      //   // _usersFuture = fetchUsers();
      // });
    } else {
      throw Exception('Failed to delete user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: AppColors.hintColor,
            //fromRGBO(101, 104, 103, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Edit User',
          style: AppTextStyles.heading,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            buildTextField('Email Id', widget.email, enabled: false),
            SizedBox(height: 12),
            buildDropdownField(
              'Role Assigned',
              roleList,
            ),
            Container(
                child: roleList == "admin"
                    ? TextButton(
                        onPressed: () {
                          deleteUser(widget.email);
                        },
                        child: const Text(
                          'Delete User',
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                            color: AppColors.buttonColor,
                            //fromRGBO(0, 128, 128, 1)
                          ),
                        ),
                      )
                    : SizedBox(
                        height: 29,
                      )),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                saveUserDetails();
              },
              child: Text(
                'Save',
                style: AppTextStyles.buttonText,
              ),

              // style: AppStyles.elevatedButtonStyle,
              style: ElevatedButton.styleFrom(
                minimumSize: Size(double.infinity, 50),
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                backgroundColor: AppColors.hintColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDropdownField(
    String label,
    List<String> items,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label.replaceAll('*', ''),
            style: AppTextStyles.labelFormat,
            // TextStyle(
            //   color: Colors.grey[600],
            //   fontSize: 16,
            //   fontWeight: FontWeight.w500,
            // ),
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
          width: 353, // Fixed width of 353px
          height: 40,

          child: DropdownButtonFormField<String>(
            value: widget.role.toLowerCase() == 'admin'
                ? 'Admin'
                : selectedRole, // Fixed to 'Admin' if role is Admin
            items: widget.role.toLowerCase() == 'admin'
                ? [
                    DropdownMenuItem<String>(
                      value: 'Admin',
                      child: Text('Admin'),
                    )
                  ] // Fixed Admin item
                : items.map((item) {
                    return DropdownMenuItem<String>(
                      value: item,
                      child: Text(item),
                    );
                  }).toList(),
            onChanged: widget.role.toLowerCase() == 'admin'
                ? null // Disable changes for Admin role
                : (value) {
                    setState(() {
                      selectedRole = value!;
                    });
                  },
            decoration: InputDecoration(
              hintText: widget.role.toLowerCase() == 'admin'
                  ? 'Admin role is fixed'
                  : 'Select $label',
              hintStyle: AppTextStyles.hintFormat,
              // TextStyle(
              //   color: Colors.grey[600],
              // ),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
            style: TextStyle(
              color: widget.role.toLowerCase() == 'admin'
                  ? Colors.grey[600]
                  : Colors.black,
            ),
          ),
        ),
      ],
    );
  }

  Widget buildTextField(String label, String hint, {required bool enabled}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          RichText(
            text: TextSpan(
              text: label,
              style: AppTextStyles.labelFormat,
              // TextStyle(
              //   color: Colors.grey[600],
              //   fontSize: 16,
              //   fontWeight: FontWeight.w500,
              // ),
            ),
          ),
          const SizedBox(height: 8.0),
          SizedBox(
            width: 353,
            height: 40,
            child: TextFormField(
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: AppTextStyles.hintFormat,
                // const TextStyle(color: Colors.grey),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              enabled: false,
            ),
          ),
        ],
      ),
    );
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:http/http.dart' as http;

class ChangePasswordScreen extends StatefulWidget {
  final String token;

  const ChangePasswordScreen({super.key, required this.token});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _currentPasswordController =
      TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _retypeNewPasswordController =
      TextEditingController();

  Future<void> _changePassword() async {
    final oldPassword = _currentPasswordController.text;
    final newPassword = _newPasswordController.text;
    final retypeNewPassword = _retypeNewPasswordController.text;

    if (newPassword != retypeNewPassword) {
      _showErrorDialog('New passwords does not match.');
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/api/user/update_password'),
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode({
          "current_password": oldPassword,
          "new_password": newPassword,
        }),
      );

      if (response.statusCode == 200) {
        _showSuccessDialog('Password changed successfully.');
      } else {
        final responseBody = json.decode(response.body);
        _showErrorDialog(responseBody['error'] ?? 'Failed to change password.');
      }
    } catch (error) {
      _showErrorDialog('An error occurred. Please try again.');
    }
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context); // Go back to the previous screen
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
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
            //Color.fromRGBO(101, 104, 103, 1),
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Change Password',
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CustomTextField(
              label: 'Current Password',
              controller: _currentPasswordController,
              obscureText: true,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'New Password',
              controller: _newPasswordController,
              obscureText: true,
            ),
            SizedBox(height: 16),
            CustomTextField(
              label: 'Retype New Password',
              controller: _retypeNewPasswordController,
              obscureText: true,
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                // Handle forgot password action
              },
              child: Align(
                alignment: Alignment(-1.1, 0.0),
                child: Text(
                  'Forgot Password?',
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.buttonColor,
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _changePassword,
              child: Text(
                'Save',
                style: AppTextStyles.buttonText,
              ),
              // style: AppStyles.elevatedButtonStyle,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 10, vertical: 16),
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
}

class CustomTextField extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool obscureText;

  const CustomTextField({
    super.key,
    required this.label,
    required this.controller,
    this.obscureText = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: AppTextStyles.labelFormat,
          // TextStyle(
          //   fontSize: 13,
          //   fontWeight: FontWeight.w300,
          // ),
        ),
        SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: 40,
          child: TextField(
            controller: controller,
            obscureText: obscureText,
            decoration: InputDecoration(
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              contentPadding:
                  EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            ),
          ),
        ),
      ],
    );
  }
}

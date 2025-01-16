import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AssignRolesScreen extends StatefulWidget {
  final String token;

  const AssignRolesScreen({super.key, required this.token});
  @override
  _AssignRolesScreenState createState() => _AssignRolesScreenState();
}

class _AssignRolesScreenState extends State<AssignRolesScreen> {
  final TextEditingController managerController = TextEditingController();
  final TextEditingController chefController = TextEditingController();
  final TextEditingController userController = TextEditingController();

  String myManager = 'Manager';
  String myChef = 'Chef';
  String myUser = 'User';

  // Variable to store the last updated field
  String? lastUpdatedField;

  Future<void> sendRolesRequest() async {
    final url = Uri.parse('$baseUrl/api/invite_user'); // Backend endpoint

    // Create the list of roles with non-empty emails
    final List<Map<String, String>> roles = [];

    if (managerController.text.isNotEmpty) {
      roles.add({"role": "Manager", "email": managerController.text});
    }
    if (chefController.text.isNotEmpty) {
      roles.add({"role": "Chef", "email": chefController.text});
    }
    if (userController.text.isNotEmpty) {
      roles.add({"role": "User", "email": userController.text});
    }

    // If no roles are filled, stop the function
    if (roles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter at least one email.")),
      );
      return;
    }

    // Construct the body
    final body = {"roles": roles};

    try {
      // Send POST request
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer ${widget.token}',
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      // Handle the response
      if (response.statusCode == 207) {
        final responseData = json.decode(response.body);
        List failedList = responseData["failed"] ?? [];
        List successList = responseData["success"] ?? [];
        String message =
            responseData["message"] ?? "Invitation process completed.";

        _showResultDialog(failedList, successList, message);
      } else {
        final responseData = json.decode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(responseData["error"] ?? "Failed to assign roles.")),
        );
      }
    } catch (e) {
      // Handle network errors
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Failed to send request: $e")),
      );
    }
  }

  void _showResultDialog(List failed, List success, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Result Summary"),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 8),
                if (success.isNotEmpty) ...[
                  Text("Success (${success.length}):"),
                  for (var email in success) Text(" - ${email["email"]}"),
                  SizedBox(height: 8),
                ],
                if (failed.isNotEmpty) ...[
                  Text("Failed (${failed.length}):"),
                  for (var failure in failed)
                    Text(" - ${failure["email"]}: ${failure["error"]}"),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Close"),
            ),
          ],
        );
      },
    );
  }

  late String updatedValue = '';
  void _onTextFieldChange(String label) {
    setState(() {
      lastUpdatedField = label;
    });
    updatedValue;
    if (label == myManager) {
      updatedValue = managerController.text;
    } else if (label == myChef) {
      updatedValue = chefController.text;
    } else if (label == myUser) {
      updatedValue = userController.text;
    } else {
      updatedValue = '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(
          "Assign Roles",
          style: AppTextStyles.heading,
        ),
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              "Skip",
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: AppColors.headingColor),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Select roles for team members to give them access and permission in the app.",
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w400,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 24),
            _buildRoleField(
              controller: managerController,
              role: "Manager",
              description:
                  "Can view, edit, and manage all data, including users, recipes, ingredients, and menus.",
              onChanged: (value) => _onTextFieldChange(myManager),
            ),
            SizedBox(height: 16),
            _buildRoleField(
              controller: chefController,
              role: "Chef",
              description:
                  "Can view, edit, and manage all data, recipes, ingredients, and menus.",
              onChanged: (value) => _onTextFieldChange(myChef),
            ),
            SizedBox(height: 16),
            _buildRoleField(
              controller: userController,
              role: "User",
              description:
                  "Can view, edit, and manage all data, recipes, ingredients, and menus.",
              onChanged: (value) => _onTextFieldChange(myUser),
            ),
            Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  await sendRolesRequest();
                },
                style: AppStyles.elevatedButtonStyle,
                child: Text(
                  "Send Request",
                  style: AppTextStyles.buttonText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleField({
    required TextEditingController controller,
    required String role,
    required String description,
    required void Function(dynamic value) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(role, style: AppTextStyles.labelBoldFormat),
        SizedBox(height: 8),
        Text(description, style: AppTextStyles.valueFormat),
        SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: "Enter user's email id",
            hintStyle: AppTextStyles.hintFormat,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey),
            ),
            contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
        ),
      ],
    );
  }
}

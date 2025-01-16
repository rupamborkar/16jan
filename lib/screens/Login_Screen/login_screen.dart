import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Bottom_Navbar/home_screen.dart';

class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  final _storage = FlutterSecureStorage();
  bool _obscureText = true;

  Future<void> _login() async {
    if (_formKey.currentState?.validate() ?? false) {
      setState(() {
        _isLoading = true;
      });

      final url = '$baseUrl/api/login';
      final headers = {'Content-Type': 'application/json'};
      final body = json.encode({
        'email': _emailController.text,
        'password': _passwordController.text,
      });

      try {
        final response = await http.post(
          Uri.parse(url),
          headers: headers,
          body: body,
        );

        setState(() {
          _isLoading = false;
        });

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          print('Response data: $data');

          final token = data['access_token'] ?? '';

          if (token.isEmpty) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Token not received!')),
            );
            return;
          }

          // Store token securely
          await _storage.write(key: 'jwt_token', value: token);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Login Successful! Welcome'),
            ),
          );

          // Navigate to Home Screen with token
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => HomeScreen(token: token),
            ),
          );
        } else {
          final errorMessage =
              json.decode(response.body)['message']?.toString() ??
                  'Login failed';
          print('Error response body: ${response.body}');
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Login failed: $errorMessage')),
          );
        }
      } catch (error) {
        setState(() {
          _isLoading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $error')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Login to your account",
                  style: AppTextStyles.heading,
                ),
                SizedBox(height: 20),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    hintText: 'Enter your email',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  textInputAction: TextInputAction.done,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your email';
                    }
                    if (!RegExp(
                            r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$")
                        .hasMatch(value)) {
                      return 'Please enter a valid email';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15),
                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    hintText: 'Enter your password',
                    border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10)),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscureText ? Icons.visibility : Icons.visibility_off,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscureText = !_obscureText;
                        });
                      },
                    ),
                  ),
                  textInputAction: TextInputAction.done,
                  obscureText: _obscureText,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter your password';
                    }
                    if (value.length < 6) {
                      return 'Password must be at least 6 characters';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton(
                    onPressed: () {},
                    child: Text(
                      'Forgot Password?',
                      textAlign: TextAlign.left,
                      style: const TextStyle(
                          fontSize: 15, color: AppColors.buttonColor),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                      style: AppStyles.elevatedButtonStyle,
                      onPressed: _isLoading ? null : _login,
                      child: Text(
                        'Login',
                        style: AppTextStyles.buttonText,
                      )),
                ),
                if (_isLoading)
                  Padding(
                    padding: const EdgeInsets.only(top: 20.0),
                    child: CircularProgressIndicator(),
                  ),
                SizedBox(height: 10),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

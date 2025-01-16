import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:developer';
import 'dart:convert';

import 'package:margo/constants/material.dart';

class CreateStocktakePage extends StatefulWidget {
  final String token;
  final VoidCallback onEntityCreated;
  const CreateStocktakePage({
    super.key,
    required this.token,
    required this.onEntityCreated,
  });

  @override
  _CreateStocktakePageState createState() => _CreateStocktakePageState();
}

class _CreateStocktakePageState extends State<CreateStocktakePage> {
  int currentStep = 1;
  bool showIngredientForm = false;
  String? selectedUnit;

  List<Map<String, dynamic>> ingredients = [];

  void nextStep() {
    setState(() {
      currentStep = 2;
    });
  }

  void _previousStep() {
    if (currentStep > 0) {
      setState(() {
        currentStep--;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Center(
          child: Text(
            'Create Stocktake',
            style: AppTextStyles.heading,
          ),
        ),
        leading: currentStep == 2
            ? IconButton(
                icon: const Icon(Icons.arrow_back_ios, size: 15),
                onPressed: _previousStep,
              )
            : null,
        actions: [
          IconButton(
            icon: const Icon(Icons.close, color: Color.fromRGBO(10, 15, 13, 8)),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Create Stocktake Page",
            style: AppTextStyles.heading,
          ),
        ),
      ),
    );
  }
}

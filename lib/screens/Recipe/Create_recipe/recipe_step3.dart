import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';

class RecipeStep3 extends StatefulWidget {
  final Map<String, dynamic> recipeData;
  final VoidCallback nextStep;
  //final Future<void> Function() saveRecipe;

  const RecipeStep3({
    super.key,
    required this.recipeData,
    required this.nextStep,
    //required this.saveRecipe,
  });

  @override
  State<RecipeStep3> createState() => _RecipeStep3State();
}

class _RecipeStep3State extends State<RecipeStep3> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'How to Prepare',
                        style: AppTextStyles.labelBoldFormat,
                      ),
                      const SizedBox(height: 8),
                      buildTextField(
                        '',
                        'Enter the method or preparation',
                        maxLines: 8,
                        onChanged: (value) =>
                            widget.recipeData['method'] = value,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  widget.nextStep();
                  // widget.saveRecipe();
                }
              },
              style: AppStyles.elevatedButtonStyle,
              child: const Text(
                'Next',
                style: AppTextStyles.buttonText,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildTextField(String label, String hint,
      {int maxLines = 1, Function(String)? onChanged}) {
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
          const SizedBox(height: 8.0),
          TextFormField(
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: AppTextStyles.hintFormat,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            textInputAction: TextInputAction.done,
            maxLines: maxLines,
            validator: (value) {
              if (label.contains('*') &&
                  (value == null || value.trim().isEmpty)) {
                return '${label.replaceAll('*', '').trim()} is required';
              }
              return null;
            },
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}

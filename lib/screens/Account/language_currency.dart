import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';

class LanguageCurrencyScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: AppColors.hintColor,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          'Language & Currency',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildDropdownField('Language', ['English', 'Spanish']),
            SizedBox(height: 16),
            _buildDropdownField('Currency', ['USD', 'EUR']),
            SizedBox(height: 25),
            ElevatedButton(
              onPressed: () {},
              child: Text(
                'Save',
                style: AppTextStyles.buttonText,
              ),
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

  Widget _buildDropdownField(String label, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelFormat,
          ),
        ),
        const SizedBox(height: 8.0),
        SizedBox(
          width: 353,
          height: 40,
          child: DropdownButtonFormField<String>(
            hint: Text(
              'Select $label',
              style: AppTextStyles.hintFormat,
            ),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(item),
              );
            }).toList(),
            onChanged: (value) {},
            decoration: InputDecoration(
              // hintText: 'Select $label',
              // hintStyle: const TextStyle(color: Colors.grey),
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
        ),
      ],
    );
  }
}

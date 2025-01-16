import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';

Widget buildTextField(
  String label,
  String hint, {
  int maxLines = 1,
  bool isNumber = false,
  String? dynamicLabel,
  required void Function(dynamic value) onSaved,
  required void Function(dynamic value) onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      RichText(
        text: TextSpan(
          text: dynamicLabel ?? label.replaceAll('*', ''),
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
          keyboardType: isNumber
              ? TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.hintFormat,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
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
          onSaved: onSaved,
          onChanged: onChanged,
        ),
      ),
    ],
  );
}

Widget buildDisabledTextField(String label,
    {required Null Function(dynamic value) onSaved}) {
  return Padding(
    padding: const EdgeInsets.only(bottom: 10.0),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            text: label,
            style: AppTextStyles.labelFormat,
          ),
        ),
        const SizedBox(height: 5.0),
        SizedBox(
          width: 353,
          height: 40,
          child: TextFormField(
            decoration: InputDecoration(
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
                borderRadius: BorderRadius.circular(10),
              ),
              fillColor: Colors.grey[200],
              filled: true,
            ),
            textInputAction: TextInputAction.done,
            enabled: false,
          ),
        ),
      ],
    ),
  );
}

Widget buildSuppDropdownField(
  String label,
  List<String> items, {
  required Function(String?) onSaved,
  Function(String?)? onChanged,
}) {
  return Column(
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
        child: DropdownSearch<String>(
          items: items,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: AppTextStyles.hintFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            ),
          ),
          onChanged: onChanged,
          onSaved: onSaved,
          validator: (value) {
            if (label.contains('*') &&
                (value == null || value.trim().isEmpty)) {
              return '${label.replaceAll('*', '').trim()} is required';
            }
            return null;
          },
          popupProps: PopupProps.menu(
            showSearchBox: true,
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                labelText: 'Search $label',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ),
      ),
    ],
  );
}

import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:dropdown_search/dropdown_search.dart';

Widget buildTextField(
  String label,
  String hint, {
  bool isNumber = false,
  int maxLines = 1,
  Function(String)? onChanged,
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
        child: TextFormField(
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
          onChanged: onChanged,
          keyboardType: isNumber
              ? TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
        ),
      ),
    ],
  );
  // );
}

Widget buildDisabledTextField(String label, String hint,
    {required Null Function(dynamic value) onChanged}) {
  return Column(
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
            hintText: hint,
            hintStyle: AppTextStyles.hintFormat,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            fillColor: Color.fromRGBO(231, 231, 231, 1),
            filled: true,
          ),
          enabled: false,
          onChanged: onChanged,
        ),
      ),
    ],
  );
  //);
}

Widget buildCategoryDropdownField(
  String label,
  List<String> items, {
  required Function(dynamic value) onChanged,
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
          onChanged: onChanged,
          enabled: true,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: AppTextStyles.hintFormat,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          popupProps: PopupProps.menu(
            showSearchBox: true,
            constraints: BoxConstraints(maxHeight: 300),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search or select $label',
                hintStyle: AppTextStyles.hintFormat,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              ),
            ),
            itemBuilder: (context, item, isSelected) {
              return ListTile(
                title: Text(item),
                selected: isSelected,
              );
            },
          ),
        ),
      ),
    ],
  );
}

Widget buildDropdownField(
  String label,
  List<String> items, {
  required Function(List<String> values) onChanged,
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
        //height: 40,
        child: DropdownSearch<String>.multiSelection(
          items: items,
          onChanged: onChanged,
          dropdownDecoratorProps: DropDownDecoratorProps(
            dropdownSearchDecoration: InputDecoration(
              hintText: 'Select $label',
              hintStyle: AppTextStyles.hintFormat,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 4.0,
                horizontal: 8.0,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          popupProps: PopupPropsMultiSelection.menu(
            showSearchBox: true,
            constraints: BoxConstraints(maxHeight: 300, maxWidth: 500),
            searchFieldProps: TextFieldProps(
              decoration: InputDecoration(
                hintText: 'Search or select $label',
                hintStyle: AppTextStyles.hintFormat,
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
              ),
            ),
            itemBuilder: (context, item, isSelected) {
              return ListTile(
                title: Text(item),
                selected: isSelected,
              );
            },
          ),
          selectedItems: [],
        ),
      ),
    ],
  );
}

Widget buildRowDisabledTextField(String label, String hint,
    {required Null Function(dynamic value) onChanged}) {
  return Column(
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
        width: 165,
        height: 40,
        child: TextFormField(
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: AppTextStyles.hintFormat,
            contentPadding:
                const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[300]!, width: 1),
              borderRadius: BorderRadius.circular(10),
            ),
            fillColor: Color.fromRGBO(231, 231, 231, 1),
            filled: true,
          ),
          enabled: false,
          onChanged: onChanged,
        ),
      ),
    ],
  );
  //);
}

Widget buildRowTextField(
  String label,
  String hint, {
  bool isNumber = false,
  int maxLines = 1,
  Function(String)? onChanged,
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
        width: 165,
        height: 40,
        child: TextFormField(
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
          onChanged: onChanged,
          keyboardType: isNumber
              ? TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
        ),
      ),
    ],
  );
  //);
}

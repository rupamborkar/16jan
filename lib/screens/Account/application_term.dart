import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';

class AppTerms extends StatelessWidget {
  const AppTerms({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Application Terms',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
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
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                'There are no application terms define yet',
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}

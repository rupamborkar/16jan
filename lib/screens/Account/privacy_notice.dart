import 'package:flutter/material.dart';

class PrivacyNotice extends StatelessWidget {
  const PrivacyNotice({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Privacy Notice'),
        centerTitle: true,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: Color.fromRGBO(101, 104, 103, 1),
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
                'There are no privacy and policies yet',
                textAlign: TextAlign.center,
              ),
            )
          ],
        ),
      ),
    );
  }
}

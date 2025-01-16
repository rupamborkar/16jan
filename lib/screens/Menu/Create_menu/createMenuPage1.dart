import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';

class CreateMenuPage1 extends StatefulWidget {
  final String token;
  final VoidCallback onEntityCreated;
  const CreateMenuPage1({
    super.key,
    required this.token,
    required this.onEntityCreated,
  });

  @override
  _CreateMenuPage1State createState() => _CreateMenuPage1State();
}

class _CreateMenuPage1State extends State<CreateMenuPage1> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Create Menu',
          style: AppTextStyles.heading,
        ),
        centerTitle: true,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.close,
              size: 18,
              color: Color.fromRGBO(101, 104, 103, 1),
            ),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            "Create Menu Page",
            style: AppTextStyles.heading,
          ),
        ),
      ),
    );
  }
}

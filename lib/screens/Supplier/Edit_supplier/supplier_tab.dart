import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';

class SupplierTabs extends StatefulWidget {
  final int initialIndex;
  final List<Widget> tabViews;

  const SupplierTabs(
      {super.key, required this.initialIndex, required this.tabViews});

  @override
  _SupplierTabsState createState() => _SupplierTabsState();
}

class _SupplierTabsState extends State<SupplierTabs> {
  late int _currentTabIndex;

  @override
  void initState() {
    super.initState();
    _currentTabIndex = widget.initialIndex;
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: _currentTabIndex,
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            icon: const Icon(Icons.close, size: 20),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
          title: const Text(
            'Edit',
            style: AppTextStyles.heading,
          ),
          centerTitle: true,
          bottom: TabBar(
            labelColor: Colors.teal,
            unselectedLabelColor: Colors.black,
            indicatorColor: Colors.teal,
            onTap: (index) {
              setState(() {
                _currentTabIndex = index;
              });
            },
            tabs: const [
              Tab(text: 'Details'),
              Tab(text: 'Ingredient'),
            ],
          ),
        ),
        body: TabBarView(
          children: widget.tabViews,
        ),
      ),
    );
  }
}

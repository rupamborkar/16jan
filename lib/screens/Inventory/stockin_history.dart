import 'package:flutter/material.dart';

class StockInHistoryDetail extends StatefulWidget {
  final int inventoryId;
  final List<Map<String, dynamic>> inventoryData;

  const StockInHistoryDetail({
    super.key,
    required this.inventoryId,
    required this.inventoryData,
  });

  @override
  State<StockInHistoryDetail> createState() => _StockInHistoryDetailState();
}

class _StockInHistoryDetailState extends State<StockInHistoryDetail> {
  List<Map<String, dynamic>> inventories = [];

  @override
  void initState() {
    super.initState();
    fetchStocktakeDetails();
  }

  Future<void> fetchStocktakeDetails() async {
    final selectedInventory = widget.inventoryData.firstWhere(
      (inventory) => inventory['id'] == widget.inventoryId,
      orElse: () => <String, dynamic>{},
    );

    if (selectedInventory != null) {
      // Extract and map operations for the selected inventory
      final List<Map<String, dynamic>> extractedInventories =
          (selectedInventory['operations'] as List<dynamic>)
              .map((operation) => {
                    'id': operation['ingredient_id'],
                    'name': operation['ingredient_name'],
                    'price': operation['price'],
                    'quantity': operation['quantity'],
                    'quantity_unit': operation['quantity_unit'],
                  })
              .toList();

      setState(() {
        inventories = extractedInventories;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios,
            size: 15,
            color: Colors.grey,
          ),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: const Text(
          'StockIn',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.grey,
              width: 1.0,
            ),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: const [
                    Expanded(
                      child: Text(
                        'Ingredient',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Quantity',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        'Price',
                        style: TextStyle(fontWeight: FontWeight.bold),
                        textAlign: TextAlign.right,
                      ),
                    ),
                  ],
                ),
                const Divider(),
                inventories.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : Expanded(
                        child: ListView.builder(
                          itemCount: inventories.length,
                          itemBuilder: (context, index) {
                            final item = inventories[index];
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8.0),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      item['name'] ?? 'N/A',
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${item['quantity']} ${item['quantity_unit']}',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                  Expanded(
                                    child: Text(
                                      '${item['price']}',
                                      textAlign: TextAlign.right,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

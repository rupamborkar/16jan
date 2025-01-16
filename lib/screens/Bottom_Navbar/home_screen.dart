import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Account/user_profile.dart';
import 'package:margo/screens/Bottom_Navbar/home_tab_screen.dart';
import 'package:margo/screens/Ingredient/Create_ingredient/ingredient_form.dart';
import 'package:margo/screens/Inventory/inventory_screen.dart';
import 'package:margo/screens/Menu/Create_menu/createMenuPage1.dart';
import 'package:margo/screens/Recipe/Create_recipe/recipe_create_form.dart';
import 'package:margo/screens/Supplier/Create_supplier/create_supplier.dart';
import 'package:margo/screens/Supplier/Detail_supplier/supplier.dart';

class HomeScreen extends StatefulWidget {
  final String token;

  const HomeScreen({super.key, required this.token});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final GlobalKey<HomeTabScreenState> _homeTabKey =
      GlobalKey<HomeTabScreenState>();

  late List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      HomeTabScreen(key: _homeTabKey, token: widget.token),
      SupplierPage(jwtToken: widget.token),
      const Center(child: Text("Create Page")),
      StocktakeScreen(token: widget.token),
      UserProfileScreen(token: widget.token),
    ];
  }

  void _onItemTapped(int index) {
    if (index == 2) {
      _showCreateBottomSheet();
    } else {
      setState(() {
        _selectedIndex = index;
      });
    }
  }

  void _showCreateBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildBottomSheetItem(
              'Create Ingredient',
              (onEntityCreated) => IngredientForm(
                token: widget.token,
                onEntityCreated: onEntityCreated,
              ),
            ),
            Divider(
                color: Colors.grey,
                thickness: 1,
                height: 0,
                indent: 10,
                endIndent: 10),
            _buildBottomSheetItem(
              'Create Recipe',
              (onEntityCreated) => RecipeCreateForm(
                token: widget.token,
                onEntityCreated: onEntityCreated,
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 0,
              indent: 10,
              endIndent: 10,
            ),
            _buildBottomSheetItem(
              'Create Supplier',
              (onEntityCreated) => CreateSupplierPage(
                token: widget.token,
                onEntityCreated: onEntityCreated,
              ),
            ),
            Divider(
              color: Colors.grey,
              thickness: 1,
              height: 0,
              indent: 10,
              endIndent: 10,
            ),
            _buildBottomSheetItem(
              'Create Menu',
              (onEntityCreated) => CreateMenuPage1(
                token: widget.token,
                onEntityCreated: onEntityCreated,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildBottomSheetItem(
      String text, Widget Function(VoidCallback onEntityCreated) destination) {
    return ListTile(
      title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
      onTap: () async {
        Navigator.pop(context);
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => destination(() {
              _homeTabKey.currentState?.refresh();
            }),
          ),
        );

        if (result == true) {
          setState(() {
            _selectedIndex = 0;
          });
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        items: const [
          BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined), label: 'Home'),
          BottomNavigationBarItem(
              icon: Icon(Icons.local_shipping_outlined), label: 'Supplier'),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle_outline), label: 'Create'),
          BottomNavigationBarItem(
              icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
          BottomNavigationBarItem(
              icon: Icon(Icons.person_2_outlined), label: 'Account'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: const Color.fromRGBO(0, 128, 128, 1),
        unselectedItemColor: AppColors.hintColor,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}


//class _HomeScreenState extends State<HomeScreen> {



//   int _selectedIndex = 0;

//   late List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _initializePages();
//   }

//   void _initializePages() {
//     _pages = [
//       HomeTabScreen(
//         token: widget.token,
//         onRefresh: _refreshHomePage,
//       ),
//       SupplierPage(
//         jwtToken: widget.token,
//       ),
//       const Center(child: Text("Create Page")),
//       StocktakeScreen(
//         token: widget.token,
//       ),
//       UserProfileScreen(
//         token: widget.token,
//       ),
//     ];
//   }

//   void _refreshHomePage() {
//     setState(() {
//       _pages[0] = HomeTabScreen(
//         token: widget.token,
//         onRefresh: _refreshHomePage,
//       );
//     });
//   }

//   void _onItemTapped(int index) {
//     if (index == 2) {
//       _showCreateBottomSheet();
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   void _showCreateBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildBottomSheetItem(
//               'Create Ingredient',
//               (onEntityCreated) => IngredientForm(
//                 token: widget.token,
//                 onEntityCreated: () {
//                   onEntityCreated();
//                   _refreshHomePage();
//                 },
//               ),
//             ),
//             Divider(
//               color: Colors.grey,
//               thickness: 1,
//               height: 0,
//               indent: 10,
//               endIndent: 10,
//             ),
//             _buildBottomSheetItem(
//               'Create Recipe',
//               (onEntityCreated) => RecipeCreateForm(
//                 token: widget.token,
//                 onEntityCreated: () {
//                   onEntityCreated();
//                   _refreshHomePage();
//                 },
//               ),
//             ),
//             Divider(
//               color: Colors.grey,
//               thickness: 1,
//               height: 0,
//               indent: 10,
//               endIndent: 10,
//             ),
//             _buildBottomSheetItem(
//               'Create Supplier',
//               (onEntityCreated) => CreateSupplierPage(
//                 token: widget.token,
//                 onEntityCreated: onEntityCreated,
//               ),
//               // CreateSupplierPage(
//               //   token: widget.token,
//               // )
//             ),
//             Divider(
//               color: Colors.grey,
//               thickness: 1,
//               height: 0,
//               indent: 10,
//               endIndent: 10,
//             ),
//             _buildBottomSheetItem(
//               'Create Menu',

//               (onEntityCreated) => CreateMenuPage1(
//                 token: widget.token,
//                 onEntityCreated: onEntityCreated,
//               ),
//               // CreateMenuPage1(
//               //   token: widget.token,
//               // )
//             ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildBottomSheetItem(
//       String text, Widget Function(VoidCallback onEntityCreated) destination) {
//     return ListTile(
//       title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
//       onTap: () async {
//         Navigator.pop(context);
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => destination(() {
//               _refreshHomePage(); // Trigger a refresh when an entity is created
//             }),
//           ),
//         );

//         if (result == true) {
//           setState(() {
//             _selectedIndex = 0; // Switch to HomeTabScreen
//           });
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined), label: 'Home'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.local_shipping_outlined), label: 'Supplier'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.add_circle_outline), label: 'Create'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.person_2_outlined), label: 'Account'),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: const Color.fromRGBO(0, 128, 128, 1),
//         unselectedItemColor: AppColors.hintColor,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }
// }





//Working code by 13-1-25
// import 'package:flutter/material.dart';
// import 'package:margo/constants/material.dart';
// import 'package:margo/screens/Account/user_profile.dart';
// import 'package:margo/screens/Bottom_Navbar/home_tab_screen.dart';
// import 'package:margo/screens/Ingredient/Create_ingredient/ingredient_form.dart';
// import 'package:margo/screens/Inventory/inventory_screen.dart';
// import 'package:margo/screens/Menu/Create_menu/createMenuPage1.dart';
// import 'package:margo/screens/Recipe/Create_recipe/recipe_create_form.dart';
// import 'package:margo/screens/Supplier/Create_supplier/create_supplier.dart';
// import 'package:margo/screens/Supplier/Detail_supplier/supplier.dart';

// class HomeScreen extends StatefulWidget {
//   final String token;

//   const HomeScreen({super.key, required this.token});

//   @override
//   _HomeScreenState createState() => _HomeScreenState();
// }

// class _HomeScreenState extends State<HomeScreen> {
//   int _selectedIndex = 0;

//   late List<Widget> _pages;

//   @override
//   void initState() {
//     super.initState();
//     _pages = [
//       HomeTabScreen(
//         token: widget.token,
//       ),
//       SupplierPage(
//         jwtToken: widget.token,
//       ),
//       const Center(child: Text("Create Page")),
//       StocktakeScreen(
//         token: widget.token,
//       ),
//       UserProfileScreen(
//         token: widget.token,
//       ),
//     ];
//   }

//   void _onItemTapped(int index) {
//     if (index == 2) {
//       _showCreateBottomSheet();
//     } else {
//       setState(() {
//         _selectedIndex = index;
//       });
//     }
//   }

//   void _showCreateBottomSheet() {
//     showModalBottomSheet(
//       context: context,
//       shape: const RoundedRectangleBorder(
//         borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
//       ),
//       builder: (BuildContext context) {
//         return Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             _buildBottomSheetItem(
//               'Create Ingredient',
//               // IngredientForm(
//               //   token: widget.token,
//               // )

//               (onEntityCreated) => IngredientForm(
//                 token: widget.token,
//                 onEntityCreated: onEntityCreated,
//               ),
//             ),
//             Divider(
//               color: Colors.grey,
//               thickness: 1,
//               height: 0,
//               indent: 10,
//               endIndent: 10,
//             ),
//             _buildBottomSheetItem(
//               'Create Recipe',
//               // RecipeCreateForm(
//               //   token: widget.token,
//               // )
//               (onEntityCreated) => RecipeCreateForm(
//                 token: widget.token,
//                 onEntityCreated: onEntityCreated,
//               ),
//             ),

//             Divider(
//               color: Colors.grey,
//               thickness: 1,
//               height: 0,
//               indent: 10,
//               endIndent: 10,
//             ),
//             _buildBottomSheetItem(
//               'Create Supplier',
//               (onEntityCreated) => CreateSupplierPage(
//                 token: widget.token,
//                 onEntityCreated: onEntityCreated,
//               ),
//               // CreateSupplierPage(
//               //   token: widget.token,
//               // )
//             ),

//             Divider(
//               color: Colors.grey,
//               thickness: 1,
//               height: 0,
//               indent: 10,
//               endIndent: 10,
//             ),
//             _buildBottomSheetItem(
//               'Create Menu',

//               (onEntityCreated) => CreateMenuPage1(
//                 token: widget.token,
//                 onEntityCreated: onEntityCreated,
//               ),
//               // CreateMenuPage1(
//               //   token: widget.token,
//               // )
//             ),
//             Divider(
//               color: Colors.grey,
//               thickness: 1,
//               height: 0,
//               indent: 10,
//               endIndent: 10,
//             ),
//             // _buildBottomSheetItem(
//             //   'Create Stocktake',
//             //   (onEntityCreated) => CreateStocktakePage(
//             //     token: widget.token,
//             //     onEntityCreated: onEntityCreated,
//             //   ),
//             //   // CreateStocktakePage(
//             //   //   token: widget.token,
//             //   // )
//             // ),
//           ],
//         );
//       },
//     );
//   }

//   Widget _buildBottomSheetItem(
//       String text, Widget Function(VoidCallback onEntityCreated) destination) {
//     return ListTile(
//       title: Text(text, style: const TextStyle(fontWeight: FontWeight.bold)),
//       onTap: () async {
//         Navigator.pop(context);
//         final result = await Navigator.push(
//           context,
//           MaterialPageRoute(
//             builder: (context) => destination(() {
//               setState(() {
//                 _pages[0] = HomeTabScreen(token: widget.token);
//                 _pages[1] = SupplierPage(jwtToken: widget.token);
//               });
//             }),
//           ),
//         );

//         if (result == true) {
//           setState(() {
//             _selectedIndex = 0;
//           });
//         }
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: _pages[_selectedIndex],
//       bottomNavigationBar: BottomNavigationBar(
//         backgroundColor: Colors.white,
//         items: const [
//           BottomNavigationBarItem(
//               icon: Icon(Icons.home_outlined), label: 'Home'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.local_shipping_outlined), label: 'Supplier'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.add_circle_outline), label: 'Create'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.inventory_2_outlined), label: 'Inventory'),
//           BottomNavigationBarItem(
//               icon: Icon(Icons.person_2_outlined), label: 'Account'),
//         ],
//         currentIndex: _selectedIndex,
//         selectedItemColor: const Color.fromRGBO(0, 128, 128, 1),
//         unselectedItemColor: AppColors.hintColor,
//         onTap: _onItemTapped,
//         type: BottomNavigationBarType.fixed,
//       ),
//     );
//   }
// }

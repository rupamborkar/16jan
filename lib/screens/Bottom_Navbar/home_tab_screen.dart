import 'package:flutter/material.dart';
import 'package:margo/constants/material.dart';
import 'package:margo/screens/Bottom_Navbar/qr_code.dart';
import 'package:margo/screens/Ingredient/Detail_ingredient/home_ingredient.dart';
import 'package:margo/screens/Recipe/Detail_recipe/home_recipe.dart';

class HomeTabScreen extends StatefulWidget {
  final String token;

  const HomeTabScreen({super.key, required this.token});

  @override
  HomeTabScreenState createState() => HomeTabScreenState();
}

class HomeTabScreenState extends State<HomeTabScreen> {
  late Future<void> _fetchDataFuture;

  @override
  void initState() {
    super.initState();
    _fetchDataFuture = _fetchData();
  }

  Future<void> _fetchData() async {
    // Fetch your data for ingredients, recipes, and menus here
  }

  void refresh() {
    setState(() {
      _fetchDataFuture = _fetchData();
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Home', style: AppTextStyles.heading),
              IconButton(
                onPressed: () async {},
                icon: const Icon(Icons.qr_code_scanner,
                    color: Color.fromRGBO(101, 104, 103, 1)),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_none,
                  color: Color.fromRGBO(101, 104, 103, 1)),
              onPressed: () {
                print("Notifications clicked");
              },
            ),
          ],
          bottom: const TabBar(
            labelColor: Color.fromRGBO(0, 128, 128, 1),
            unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
            indicatorColor: Color.fromRGBO(0, 128, 128, 1),
            labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            tabs: [
              Tab(text: 'Ingredients'),
              Tab(text: 'Recipes'),
              Tab(text: 'Menus'),
            ],
          ),
        ),
        body: FutureBuilder(
          future: _fetchDataFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text("Error loading data"));
            }
            return TabBarView(
              children: [
                HomePage(jwtToken: widget.token),
                RecipeHomePage(jwtToken: widget.token),
                const Center(child: Text("Menu details")),
              ],
            );
          },
        ),
      ),
    );
  }
}


// class HomeTabScreen extends StatelessWidget {
//   final String token;
//   final VoidCallback onRefresh;

//   const HomeTabScreen(
//       {super.key, required this.token, required this.onRefresh});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Home',
//                 style: AppTextStyles.heading,
//               ),
//               IconButton(
//                 onPressed: () async {},
//                 icon: const Icon(Icons.qr_code_scanner,
//                     color: Color.fromRGBO(101, 104, 103, 1)),
//               ),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(
//                 Icons.notifications_none,
//                 color: Color.fromRGBO(101, 104, 103, 1),
//               ),
//               onPressed: () {
//                 print("Notifications clicked");
//               },
//             ),
//           ],
//           bottom: const TabBar(
//             labelColor: Color.fromRGBO(0, 128, 128, 1),
//             unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
//             indicatorColor: Color.fromRGBO(0, 128, 128, 1),
//             labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//             tabs: [
//               Tab(text: 'Ingredients'),
//               Tab(text: 'Recipes'),
//               Tab(text: 'Menus'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             // Ingredients tab
//             HomePage(jwtToken: token),
//             // Recipes tab
//             RecipeHomePage(jwtToken: token),
//             // Menus tab
//             const Center(child: Text("Menu details")),
//           ],
//         ),
//         floatingActionButton: FloatingActionButton(
//           onPressed: onRefresh,
//           child: const Icon(Icons.refresh),
//         ),
//       ),
//     );
//   }
// }






//Working code by 13-1-25
// import 'package:flutter/material.dart';
// import 'package:margo/constants/material.dart';
// import 'package:margo/screens/Bottom_Navbar/qr_code.dart';
// import 'package:margo/screens/Ingredient/Detail_ingredient/home_ingredient.dart';
// import 'package:margo/screens/Recipe/Detail_recipe/home_recipe.dart';

// class HomeTabScreen extends StatelessWidget {
//   final String token;

//   const HomeTabScreen({super.key, required this.token});

//   @override
//   Widget build(BuildContext context) {
//     return DefaultTabController(
//       length: 3,
//       child: Scaffold(
//         appBar: AppBar(
//           automaticallyImplyLeading: false,
//           backgroundColor: Colors.white,
//           elevation: 0,
//           title: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text(
//                 'Home',
//                 style: AppTextStyles.heading,
//               ),
//               IconButton(
//                 onPressed: () async {},
//                 icon: const Icon(Icons.qr_code_scanner,
//                     color: Color.fromRGBO(101, 104, 103, 1)),
//               ),
//             ],
//           ),
//           actions: [
//             IconButton(
//               icon: const Icon(
//                 Icons.notifications_none,
//                 color: Color.fromRGBO(101, 104, 103, 1),
//               ),
//               onPressed: () {
//                 print("Notifications clicked");
//               },
//             ),
//           ],
//           bottom: const TabBar(
//             labelColor: Color.fromRGBO(0, 128, 128, 1),
//             unselectedLabelColor: Color.fromRGBO(150, 152, 151, 1),
//             indicatorColor: Color.fromRGBO(0, 128, 128, 1),
//             labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
//             tabs: [
//               Tab(text: 'Ingredients'),
//               Tab(text: 'Recipes'),
//               Tab(text: 'Menus'),
//             ],
//           ),
//         ),
//         body: TabBarView(
//           children: [
//             // Ingredients tab
//             HomePage(jwtToken: token),
//             // Recipes tab
//             RecipeHomePage(jwtToken: token),
//             // Menus tab
//             const Center(child: Text("Menu details")),
//           ],
//         ),
//       ),
//     );
//   }
// }

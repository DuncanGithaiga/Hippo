import 'dart:convert';
import 'package:hippo/constants/customBottomBar.dart';
import 'package:hippo/constants/customdrawer.dart';
import 'package:hippo/models/user.dart';
import 'package:http/http.dart' as http;
import 'package:hippo/models/post.dart';
import 'package:hippo/models/product.dart';
import 'package:hippo/services/authapi.dart';
import 'package:hippo/services/dbapi.dart';
import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  // FirebaseAuth auth = FirebaseAuth.instance;
  String? token;
  String? email;
  String? name;
  String? imageUrl;
  int? userId;

  final TextEditingController _searchQueryController = TextEditingController();
  bool _isSearching = false;
  String searchQuery = "Search query";
  UserDetail? user;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserDetails();
    // getUserData();
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   checkToken();
    // });
  }

  // void checkToken() async {
  //   bool isValid = await AuthApi().isTokenValid();

  //   debugPrint('Is token valid: $isValid');

  //   if (!mounted) return; // Ensure widget is still mounted before navigation

  //   if (isValid) {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => Home()),
  //     );
  //   } else {
  //     Navigator.of(context).pushReplacement(
  //       MaterialPageRoute(builder: (context) => Authenticate()),
  //     );
  //   }
  // }

  void fetchUserDetails() async {
    try {
      UserDetail? fetchedUser = await AuthApi().getUserProfile();
      setState(() {
        debugPrint('User: $fetchedUser');
        user = fetchedUser;
        isLoading = false;
      });
    } catch (e) {
      print("Error fetching user: $e");
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchImageUrl() async {
    final response = await http.get(
      Uri.parse("http://10.0.2.2:8000/api/get-image"),
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        imageUrl =
            data["url"]; // Laravel API should return {"url": "http://your-api.com/storage/images/example.jpg"}
      });
    } else {
      throw Exception("Failed to load image");
    }
  }

  // void getUserData() async {
  //   final storage = FlutterSecureStorage();
  //   final token = await storage.read(key: 'token');
  //   final email = await storage.read(key: 'email');
  //   final name = await storage.read(key: 'name');
  //   final userIdString = await storage.read(key: 'user_id');
  //   final userId = userIdString != null ? int.tryParse(userIdString) : null;
  //   print(storage);

  //   if (!mounted) return; // Check if the widget is still mounted
  //   setState(() {
  //     this.token = token;
  //     this.email = email;
  //     this.name = name;
  //     this.userId = userId;
  //   });
  // }

  List<Widget> _buildActions() {
    if (_isSearching) {
      return <Widget>[
        IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            if (_searchQueryController == null ||
                _searchQueryController.text.isEmpty) {
              Navigator.pop(context);
              return;
            }
            _clearSearchQuery();
          },
        ),
      ];
    }

    return <Widget>[
      IconButton(icon: const Icon(Icons.search), onPressed: _startSearch),
    ];
  }

  void _startSearch() {
    ModalRoute.of(
      context,
    )?.addLocalHistoryEntry(LocalHistoryEntry(onRemove: _stopSearching));

    setState(() {
      _isSearching = true;
    });
  }

  void updateSearchQuery(String newQuery) {
    setState(() {
      searchQuery = newQuery;
    });
  }

  void _stopSearching() {
    _clearSearchQuery();

    setState(() {
      _isSearching = false;
    });
  }

  void _clearSearchQuery() {
    setState(() {
      _searchQueryController.clear();
      updateSearchQuery("");
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(100.0), // here the desired height
        child: AppBar(
          title: Padding(
            padding: const EdgeInsets.only(left: 200.0),
            child: Text(
              'Home',
              style: TextStyle(color: Colors.white, fontSize: 20),
            ),
          ), // You can add title here
          toolbarHeight: 60.2,
          toolbarOpacity: 0.8,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(25),
              bottomLeft: Radius.circular(25),
            ),
          ),
          flexibleSpace: Image(
            image: AssetImage('assets/images/1.png'),
            fit: BoxFit.cover,
          ),
          elevation: 0.00,
          actions: [],
          iconTheme: IconThemeData(color: Colors.white),
        ),
      ),
      drawer: customDrawer(),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Row(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0)),
                Text(
                  AuthApi().greeting(),
                  style: TextStyle(
                    fontSize: 20,
                    fontFamily: 'RubikDoodleShadow',
                  ),
                ),
                Divider(color: Colors.grey, thickness: 2),
                SizedBox(height: 60.0),
              ],
            ),
            Column(
              children: [
                // SizedBox(
                //   width: 350.0,
                //   child: TextField(
                //     controller: _searchQueryController,
                //     style: TextStyle(color: Color.fromARGB(255, 99, 13, 114)),
                //     cursorColor: Colors.white,
                //     decoration: InputDecoration(
                //       hintText: 'Search Product...',
                //       hintStyle: TextStyle(
                //         color: Color.fromARGB(255, 99, 13, 114),
                //       ),
                //       border: OutlineInputBorder(
                //         borderRadius: BorderRadius.circular(10.0),
                //         borderSide: BorderSide.none,
                //       ),
                //       fillColor: Colors.purple.withOpacity(0.1),
                //       filled: true,
                //       prefixIcon: Icon(Icons.search),
                //     ),
                //     onChanged: (value) {
                //       // Perform search functionality here
                //       (query) => updateSearchQuery(query);
                //     },
                //   ),
                // ),

                // Search results will be displayed here
                //        Expanded(
                //         child:filterediTtems,
                //          ListView.builder(
                //           itemCount: 0,
                //           itemBuilder: (context, index) {
                //             return ListTile(
                //               title: Text('Search Result $index'),
                //             );
                //           },
                //         ),
                //     )
                // ])
              ],
            ),
            SizedBox(height: 20.0),
            SizedBox(
              height: 180.0, // Set a fixed height for the CarouselSlider
              child: CarouselSlider(
                items: [
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/images/camera.jpg'),
                        fit: BoxFit.cover, // Optional: to cover the container
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/images/headphone.jpg'),
                        fit: BoxFit.cover, // Optional: to cover the container
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/images/ipad.jpg'),
                        fit: BoxFit.cover, // Optional: to cover the container
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/images/laptop.jpg'),
                        fit: BoxFit.cover, // Optional: to cover the container
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/images/lens.jpg'),
                        fit: BoxFit.cover, // Optional: to cover the container
                      ),
                    ),
                  ),
                  Container(
                    margin: EdgeInsets.all(6.0),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8.0),
                      image: DecorationImage(
                        image: AssetImage('assets/images/pad.jpg'),
                        fit: BoxFit.cover, // Optional: to cover the container
                      ),
                    ),
                  ),
                ],

                //Slider Container properties
                //carousel Slider flutter
                options: CarouselOptions(
                  height: 180.0,
                  enlargeCenterPage: true,
                  autoPlay: true,
                  aspectRatio: 16 / 9,
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enableInfiniteScroll: true,
                  autoPlayAnimationDuration: Duration(milliseconds: 800),
                  viewportFraction: 0.8,
                ),
              ),
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0)),
                Text(
                  'Products',
                  style: TextStyle(fontSize: 20, fontFamily: 'poppins'),
                ),
                Divider(color: Colors.grey, thickness: 2),
              ],
            ),
            SizedBox(height: 10.0),
            FutureBuilder<List<Product>>(
              future: DbApi().getProducts(),
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  return Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 10.0,
                    ), // Padding for the container
                    child: Row(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceEvenly, // Even spacing between items
                      children:
                          snapshot.data!.take(4).map((product) {
                            return Expanded(
                              child: Card(
                                elevation: 4, // Shadow effect
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12.0),
                                ),
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    8.0,
                                  ), // Padding inside the card
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      // Product Name
                                      Text(
                                        product.name ?? "No Product Name",
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ), // Space between name and price
                                      // Product Price
                                      Text(
                                        product.price != null
                                            ? '\$${product.price!.toStringAsFixed(2)}'
                                            : 'No Price Available',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                      SizedBox(
                                        height: 8.0,
                                      ), // Space between price and description
                                      // Product Description (optional, truncate if needed)
                                      Text(
                                        product.description != null
                                            ? (product.description!.length > 20
                                                ? product.description!
                                                        .substring(0, 20) +
                                                    '...'
                                                : product.description!)
                                            : 'No Description Available',
                                        style: TextStyle(
                                          fontSize: 10,
                                          color: Colors.grey[700],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }).toList(), // Convert the products to widgets in the Row
                    ),
                  );
                } else if (snapshot.hasError) {
                  return Text("Error: ${snapshot.error}");
                }

                return Center(
                  child: CircularProgressIndicator(), // Loading spinner
                );
              },
            ),
            SizedBox(height: 10.0),
            Row(
              children: [
                Padding(padding: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 20.0)),
                Text(
                  'Posts',
                  style: TextStyle(fontSize: 20, fontFamily: 'Poppins'),
                ),
                Divider(color: Colors.grey, thickness: 2),
              ],
            ),
            SizedBox(height: 10.0),
            Container(
              child: Center(
                child: FutureBuilder<List<Post>>(
                  future: DbApi().userPosts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount:
                            snapshot.data!.length >= 2
                                ? 2
                                : snapshot.data!.length, // Show only 2 posts
                        itemBuilder: (context, index) {
                          return Card(
                            child: ListTile(
                              title: Text(
                                snapshot.data![index].title ?? "No Title",
                              ),
                              subtitle: Text(
                                snapshot.data![index].body ?? "No Body",
                              ),
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text("Error: ${snapshot.error}");
                    } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return Text("Post Your First Post");
                    }

                    // By default, show a loading spinner.
                    return CircularProgressIndicator(); // Display a spinner while waiting for data
                  },
                ),
              ),
            ),
          ],
        ),
      ),
      extendBody: true,
      bottomNavigationBar: BottomNavBarCurvedFb1(),
    );
  }
}

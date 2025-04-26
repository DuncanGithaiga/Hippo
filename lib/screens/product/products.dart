import 'package:hippo/constants/customAppBar.dart';
import 'package:hippo/models/product.dart';
import 'package:hippo/models/product_list_item.dart';
import 'package:hippo/screens/product/product_list_item_view.dart';
import 'package:hippo/services/dbapi.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:intl/intl.dart';

class Products extends StatefulWidget {
  const Products({super.key});

  @override
  State<Products> createState() => _ProductsState();
}

class _ProductsState extends State<Products> {
  String? token;
  final priceFormat = NumberFormat.currency(symbol: "\$", decimalDigits: 2);

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  // In the _UserProfileState class

  void initializePreferences() async {}

  void getUserData() async {
    final storage = FlutterSecureStorage();
    final token = await storage.read(key: 'token');
    print(storage);

    setState(() {
      this.token = token;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: 'Products',
        backgroundColor: Color.fromARGB(255, 99, 13, 114),
      ),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            SizedBox(height: 10),
            SingleChildScrollView(
              child: Center(
                child: (FutureBuilder<List<Product>>(
                  future: DbApi().getProducts(),
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      return ListView.builder(
                        shrinkWrap: true,
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          return ProductListItemView(
                            item: ProductListItem(
                              // id: snapshot.data![index].id,
                              imageUrl:
                                  snapshot.data![index].imageUrl ??
                                  'assets/default_image.png',
                              name: snapshot.data![index].name ?? 'No Name',
                              description:
                                  snapshot.data![index].description ??
                                  'No Description',
                              price:
                                  snapshot.data![index].price?.toString() ??
                                  'No Price',
                              id: '',
                            ),
                          );
                        },
                      );
                    } else if (snapshot.hasError) {
                      return Text("${snapshot.error}");
                    }

                    // By default, show a loading spinner.
                    return Text('No Posts');
                  },
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

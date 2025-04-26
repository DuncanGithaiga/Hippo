import 'dart:ffi';

class Product {
  String? name;
  String? slug;
  String? description;
  double? price;
  String? imageUrl;

  Product({this.name, this.slug, this.description, this.price, this.imageUrl});

  //convert JSON to dart object for dart to understand and view
  //map (Key Value) map each json keys to corresponding model fields
  Product.fromJson(Map<String, dynamic> json) {
    name = json['name'];
    slug = json['slug'];
    description = json['description'];
    imageUrl = json['imageUrl'];
    // Handle the case where the price is a String or double
    if (json['price'] is String) {
      price = double.tryParse(json['price']); // Convert String to double
    } else if (json['price'] is double) {
      price = json['price']; // It's already a double
    }
  }
}

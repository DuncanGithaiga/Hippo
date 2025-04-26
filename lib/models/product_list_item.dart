class ProductListItem {
  final String id;
  final String name;
  final String description;
  final String price;
  final String? imageUrl;
  ProductListItem({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    this.imageUrl,
  });
}

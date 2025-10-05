class Product {
  final int id;
  final String name;
  final String description;
  final double price;
  final String imgUrl;

  Product({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.imgUrl,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'],
      name: json['title'],
      description: json['description'],
      price: (json['price'] as num).toDouble(),
      imgUrl: json['thumbnail'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'description': description,
      'price': price,
      'thumbnail': imgUrl,
    };
  }
}

class Product {
  final String id;
  final String name;
  double price;
  String description;
  int stockQuantity;
  String? imageUrl;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.stockQuantity = 0,
    this.imageUrl,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    int? stockQuantity,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'stock_quantity': stockQuantity,
      'image_url': imageUrl,
      'created_at': DateTime.now().toIso8601String(),
      'updated_at': DateTime.now().toIso8601String(),
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      description: json['description'] as String? ?? '',
      stockQuantity: json['stock_quantity'] as int? ?? 0,
      imageUrl: json['image_url'] as String?,
    );
  }
}


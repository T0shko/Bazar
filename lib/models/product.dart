class Product {
  final String id;
  final String name;
  double price;
  String description;
  int stockQuantity;

  Product({
    required this.id,
    required this.name,
    required this.price,
    this.description = '',
    this.stockQuantity = 0,
  });

  Product copyWith({
    String? id,
    String? name,
    double? price,
    String? description,
    int? stockQuantity,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      stockQuantity: stockQuantity ?? this.stockQuantity,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'description': description,
      'stock_quantity': stockQuantity,
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
    );
  }
}


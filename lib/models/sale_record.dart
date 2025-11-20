import 'product.dart';

class SaleRecord {
  final String id;
  final Product? product;
  final String? coffeeAmount;
  final String? donationAmount;
  final int quantity;
  final double total;
  final DateTime date;

  SaleRecord({
    required this.id,
    this.product,
    this.coffeeAmount,
    this.donationAmount,
    required this.quantity,
    required this.total,
    required this.date,
  });

  String get type {
    if (coffeeAmount != null) return 'Coffee';
    if (donationAmount != null) return 'Donation';
    return 'Product Sale';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'product_id': product?.id,
      'coffee_amount': coffeeAmount,
      'donation_amount': donationAmount,
      'quantity': quantity,
      'total': total,
      'date': date.toIso8601String(),
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  factory SaleRecord.fromJson(Map<String, dynamic> json, {Product? product}) {
    return SaleRecord(
      id: json['id'] as String,
      product: product,
      coffeeAmount: json['coffee_amount'] as String?,
      donationAmount: json['donation_amount'] as String?,
      quantity: json['quantity'] as int,
      total: (json['total'] as num).toDouble(),
      date: DateTime.parse(json['date'] as String),
    );
  }
}


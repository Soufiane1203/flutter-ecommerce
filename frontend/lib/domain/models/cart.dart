import 'package:equatable/equatable.dart';

/// Article du panier
class CartItem extends Equatable {
  final int id;
  final int quantity;
  final int productId;
  final String name;
  final double price;
  final String? imageUrl;
  final double subtotal;
  final DateTime? addedAt;

  const CartItem({
    required this.id,
    required this.quantity,
    required this.productId,
    required this.name,
    required this.price,
    this.imageUrl,
    required this.subtotal,
    this.addedAt,
  });

  factory CartItem.fromJson(Map<String, dynamic> json) {
    return CartItem(
      id: _parseInt(json['id']),
      quantity: _parseInt(json['quantity']),
      productId: _parseInt(json['product_id']),
      name: json['name'] as String,
      price: _parseDouble(json['price']),
      imageUrl: json['image_url'] as String?,
      subtotal: _parseDouble(json['subtotal']),
      addedAt: json['added_at'] != null
          ? DateTime.parse(json['added_at'] as String)
          : null,
    );
  }

  /// Parse double depuis String ou num
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }

  /// Parse int depuis String ou int
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.parse(value);
    return 0;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'quantity': quantity,
      'product_id': productId,
      'name': name,
      'price': price,
      'image_url': imageUrl,
      'subtotal': subtotal,
      'added_at': addedAt?.toIso8601String(),
    };
  }

  @override
  List<Object?> get props => [
        id,
        quantity,
        productId,
        name,
        price,
        imageUrl,
        subtotal,
        addedAt,
      ];
}

/// Panier complet
class Cart extends Equatable {
  final List<CartItem> items;
  final double total;
  final int itemCount;

  const Cart({
    required this.items,
    required this.total,
    required this.itemCount,
  });

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      items: (json['items'] as List<dynamic>)
          .map((item) => CartItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      total: _parseDouble(json['total']),
      itemCount: CartItem._parseInt(json['itemCount']),
    );
  }

  /// Parse double depuis String ou num
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }

  /// Panier vide
  const Cart.empty()
      : items = const [],
        total = 0.0,
        itemCount = 0;

  /// Vérifier si le panier est vide
  bool get isEmpty => items.isEmpty;

  @override
  List<Object?> get props => [items, total, itemCount];
}

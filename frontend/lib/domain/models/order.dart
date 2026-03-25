import 'package:equatable/equatable.dart';

/// Statut de commande
enum OrderStatus {
  pending,
  confirmed,
  shipped,
  delivered,
  cancelled;

  String get displayName {
    switch (this) {
      case OrderStatus.pending:
        return 'En attente';
      case OrderStatus.confirmed:
        return 'Confirmée';
      case OrderStatus.shipped:
        return 'Expédiée';
      case OrderStatus.delivered:
        return 'Livrée';
      case OrderStatus.cancelled:
        return 'Annulée';
    }
  }

  static OrderStatus fromString(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'shipped':
        return OrderStatus.shipped;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

/// Article de commande
class OrderItem extends Equatable {
  final int id;
  final int quantity;
  final double unitPrice;
  final double subtotal;
  final int productId;
  final String name;
  final String? imageUrl;
  final String? brand;

  const OrderItem({
    required this.id,
    required this.quantity,
    required this.unitPrice,
    required this.subtotal,
    required this.productId,
    required this.name,
    this.imageUrl,
    this.brand,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: _parseInt(json['id']),
      quantity: _parseInt(json['quantity']),
      unitPrice: _parseDouble(json['unit_price']),
      subtotal: _parseDouble(json['subtotal']),
      productId: _parseInt(json['product_id']),
      name: json['name'] as String,
      imageUrl: json['image_url'] as String?,
      brand: json['brand'] as String?,
    );
  }

  /// Parse int depuis String ou num
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    return 0;
  }

  /// Parse double depuis String ou num
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }

  @override
  List<Object?> get props => [
        id,
        quantity,
        unitPrice,
        subtotal,
        productId,
        name,
        imageUrl,
        brand,
      ];
}

/// Commande
class Order extends Equatable {
  final int id;
  final int userId;
  final double totalAmount;
  final OrderStatus status;
  final String shippingAddress;
  final String phone;
  final String? notes;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? fullName;
  final String? email;
  final List<OrderItem>? items;
  final int? itemCount;

  const Order({
    required this.id,
    required this.userId,
    required this.totalAmount,
    required this.status,
    required this.shippingAddress,
    required this.phone,
    this.notes,
    required this.createdAt,
    this.updatedAt,
    this.fullName,
    this.email,
    this.items,
    this.itemCount,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: _parseInt(json['id']),
      userId: _parseInt(json['user_id']),
      totalAmount: _parseDouble(json['total_amount']),
      status: OrderStatus.fromString(json['status'] as String),
      shippingAddress: json['shipping_address'] as String,
      phone: json['phone'] as String,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      fullName: json['full_name'] as String?,
      email: json['email'] as String?,
      items: json['items'] != null
          ? (json['items'] as List<dynamic>)
              .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
              .toList()
          : null,
      itemCount: json['item_count'] != null ? _parseInt(json['item_count']) : null,
    );
  }

  /// Parse int depuis String ou num
  static int _parseInt(dynamic value) {
    if (value is int) return value;
    if (value is num) return value.toInt();
    if (value is String) return int.parse(value);
    return 0;
  }

  /// Parse double depuis String ou num
  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.parse(value);
    return 0.0;
  }

  /// Vérifier si la commande peut être annulée
  bool get canBeCancelled {
    return status != OrderStatus.delivered && status != OrderStatus.cancelled;
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        totalAmount,
        status,
        shippingAddress,
        phone,
        notes,
        createdAt,
        updatedAt,
        fullName,
        email,
        items,
        itemCount,
      ];
}

/// Pagination des commandes
class PaginatedOrders extends Equatable {
  final List<Order> orders;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedOrders({
    required this.orders,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedOrders.fromJson(
    List<dynamic> ordersJson,
    Map<String, dynamic> pagination,
  ) {
    return PaginatedOrders(
      orders: ordersJson.map((json) => Order.fromJson(json)).toList(),
      currentPage: Order._parseInt(pagination['currentPage']),
      itemsPerPage: Order._parseInt(pagination['itemsPerPage']),
      totalItems: Order._parseInt(pagination['totalItems']),
      totalPages: Order._parseInt(pagination['totalPages']),
      hasNextPage: pagination['hasNextPage'] as bool,
      hasPreviousPage: pagination['hasPreviousPage'] as bool,
    );
  }

  @override
  List<Object?> get props => [
        orders,
        currentPage,
        itemsPerPage,
        totalItems,
        totalPages,
        hasNextPage,
        hasPreviousPage,
      ];
}

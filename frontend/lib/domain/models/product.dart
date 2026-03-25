import 'package:equatable/equatable.dart';

/// Modèle Catégorie
class Category extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int? productCount;

  const Category({
    required this.id,
    required this.name,
    this.description,
    this.productCount,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: _parseInt(json['id']),
      name: json['name'] as String,
      description: json['description'] as String?,
      productCount: json['product_count'] != null ? _parseInt(json['product_count']) : null,
    );
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
      'name': name,
      'description': description,
      'product_count': productCount,
    };
  }

  @override
  List<Object?> get props => [id, name, description, productCount];
}

/// Modèle Produit
class Product extends Equatable {
  final int id;
  final String name;
  final String? description;
  final double price;
  final int stockQuantity;
  final int? categoryId;
  final String? categoryName;
  final String? imageUrl;
  final String? brand;
  final Map<String, dynamic>? specifications;
  final bool isActive;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  const Product({
    required this.id,
    required this.name,
    this.description,
    required this.price,
    required this.stockQuantity,
    this.categoryId,
    this.categoryName,
    this.imageUrl,
    this.brand,
    this.specifications,
    this.isActive = true,
    this.createdAt,
    this.updatedAt,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _parseInt(json['id']),
      name: json['name'] as String,
      description: json['description'] as String?,
      price: _parsePrice(json['price']),
      stockQuantity: _parseInt(json['stock_quantity']),
      categoryId: json['category_id'] != null ? _parseInt(json['category_id']) : null,
      categoryName: json['category_name'] as String?,
      imageUrl: json['image_url'] as String?,
      brand: json['brand'] as String?,
      specifications: json['specifications'] as Map<String, dynamic>?,
      isActive: json['is_active'] as bool? ?? true,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Parse le prix depuis String ou num
  static double _parsePrice(dynamic price) {
    if (price is num) {
      return price.toDouble();
    } else if (price is String) {
      return double.parse(price);
    }
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
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stockQuantity,
      'category_id': categoryId,
      'category_name': categoryName,
      'image_url': imageUrl,
      'brand': brand,
      'specifications': specifications,
      'is_active': isActive,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  /// Vérifier si le produit est en stock
  bool get inStock => stockQuantity > 0;

  /// Copier avec modifications
  Product copyWith({
    int? id,
    String? name,
    String? description,
    double? price,
    int? stockQuantity,
    int? categoryId,
    String? categoryName,
    String? imageUrl,
    String? brand,
    Map<String, dynamic>? specifications,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      price: price ?? this.price,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      imageUrl: imageUrl ?? this.imageUrl,
      brand: brand ?? this.brand,
      specifications: specifications ?? this.specifications,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        price,
        stockQuantity,
        categoryId,
        categoryName,
        imageUrl,
        brand,
        specifications,
        isActive,
        createdAt,
        updatedAt,
      ];
}

/// Pagination des produits
class PaginatedProducts extends Equatable {
  final List<Product> products;
  final int currentPage;
  final int itemsPerPage;
  final int totalItems;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  const PaginatedProducts({
    required this.products,
    required this.currentPage,
    required this.itemsPerPage,
    required this.totalItems,
    required this.totalPages,
    required this.hasNextPage,
    required this.hasPreviousPage,
  });

  factory PaginatedProducts.fromJson(
    List<dynamic> productsJson,
    Map<String, dynamic> pagination,
  ) {
    return PaginatedProducts(
      products: productsJson.map((json) => Product.fromJson(json)).toList(),
      currentPage: pagination['currentPage'] as int,
      itemsPerPage: pagination['itemsPerPage'] as int,
      totalItems: pagination['totalItems'] as int,
      totalPages: pagination['totalPages'] as int,
      hasNextPage: pagination['hasNextPage'] as bool,
      hasPreviousPage: pagination['hasPreviousPage'] as bool,
    );
  }

  @override
  List<Object?> get props => [
        products,
        currentPage,
        itemsPerPage,
        totalItems,
        totalPages,
        hasNextPage,
        hasPreviousPage,
      ];
}

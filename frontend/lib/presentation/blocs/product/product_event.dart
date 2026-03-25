import 'package:equatable/equatable.dart';
import '../../../domain/models/product.dart';

/// === PRODUCT EVENTS ===

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

/// Charger tous les produits
class ProductsLoadRequested extends ProductEvent {
  final int page;
  final int limit;
  final String? search;
  final int? categoryId;
  final double? minPrice;
  final double? maxPrice;

  const ProductsLoadRequested({
    this.page = 1,
    this.limit = 20,
    this.search,
    this.categoryId,
    this.minPrice,
    this.maxPrice,
  });

  @override
  List<Object?> get props => [page, limit, search, categoryId, minPrice, maxPrice];
}

/// Charger un produit par ID
class ProductByIdLoadRequested extends ProductEvent {
  final int id;

  const ProductByIdLoadRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Créer un produit (Admin)
class ProductCreateRequested extends ProductEvent {
  final String name;
  final String description;
  final double price;
  final int stock;
  final int categoryId;
  final String? imageUrl;
  final Map<String, dynamic>? specifications;

  const ProductCreateRequested({
    required this.name,
    required this.description,
    required this.price,
    required this.stock,
    required this.categoryId,
    this.imageUrl,
    this.specifications,
  });

  @override
  List<Object?> get props => [name, description, price, stock, categoryId, imageUrl, specifications];
}

/// Mettre à jour un produit (Admin)
class ProductUpdateRequested extends ProductEvent {
  final int id;
  final String? name;
  final String? description;
  final double? price;
  final int? stock;
  final int? categoryId;
  final String? imageUrl;
  final Map<String, dynamic>? specifications;

  const ProductUpdateRequested({
    required this.id,
    this.name,
    this.description,
    this.price,
    this.stock,
    this.categoryId,
    this.imageUrl,
    this.specifications,
  });

  @override
  List<Object?> get props => [id, name, description, price, stock, categoryId, imageUrl, specifications];
}

/// Supprimer un produit (Admin)
class ProductDeleteRequested extends ProductEvent {
  final int id;

  const ProductDeleteRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Upload image produit (Admin)
class ProductImageUploadRequested extends ProductEvent {
  final String filePath;

  const ProductImageUploadRequested(this.filePath);

  @override
  List<Object?> get props => [filePath];
}

/// Charger les catégories
class CategoriesLoadRequested extends ProductEvent {}

/// === PRODUCT STATES ===

abstract class ProductState extends Equatable {
  const ProductState();

  @override
  List<Object?> get props => [];
}

/// État initial
class ProductInitial extends ProductState {}

/// Chargement en cours
class ProductLoading extends ProductState {}

/// Liste des produits chargée
class ProductsLoaded extends ProductState {
  final PaginatedProducts paginatedProducts;

  const ProductsLoaded(this.paginatedProducts);

  @override
  List<Object?> get props => [paginatedProducts];
}

/// Détails d'un produit chargés
class ProductDetailLoaded extends ProductState {
  final Product product;

  const ProductDetailLoaded(this.product);

  @override
  List<Object?> get props => [product];
}

/// Produit créé avec succès
class ProductCreated extends ProductState {
  final Product product;

  const ProductCreated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Produit mis à jour avec succès
class ProductUpdated extends ProductState {
  final Product product;

  const ProductUpdated(this.product);

  @override
  List<Object?> get props => [product];
}

/// Produit supprimé avec succès
class ProductDeleted extends ProductState {}

/// Image uploadée avec succès
class ProductImageUploaded extends ProductState {
  final String imageUrl;

  const ProductImageUploaded(this.imageUrl);

  @override
  List<Object?> get props => [imageUrl];
}

/// Catégories chargées
class CategoriesLoaded extends ProductState {
  final List<Category> categories;

  const CategoriesLoaded(this.categories);

  @override
  List<Object?> get props => [categories];
}

/// Erreur produit
class ProductError extends ProductState {
  final String message;

  const ProductError(this.message);

  @override
  List<Object?> get props => [message];
}

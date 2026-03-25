import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/product_service.dart';
import 'product_event.dart';
import 'product_event.dart' as product_event;

export 'product_event.dart';

/// BLoC de gestion des produits
/// Gère le catalogue, filtres, CRUD admin
class ProductBloc extends Bloc<ProductEvent, product_event.ProductState> {
  final ProductService _productService;

  ProductBloc(this._productService) : super(product_event.ProductInitial()) {
    on<ProductsLoadRequested>(_onProductsLoadRequested);
    on<ProductByIdLoadRequested>(_onProductByIdLoadRequested);
    on<ProductCreateRequested>(_onProductCreateRequested);
    on<ProductUpdateRequested>(_onProductUpdateRequested);
    on<ProductDeleteRequested>(_onProductDeleteRequested);
    on<ProductImageUploadRequested>(_onProductImageUploadRequested);
    on<CategoriesLoadRequested>(_onCategoriesLoadRequested);
  }

  /// Charger tous les produits avec pagination et filtres
  Future<void> _onProductsLoadRequested(
    ProductsLoadRequested event,
    Emitter<product_event.ProductState> emit,
  ) async {
    emit(product_event.ProductLoading());

    try {
      final paginatedProducts = await _productService.getProducts(
        page: event.page,
        limit: event.limit,
        search: event.search,
        categoryId: event.categoryId,
        minPrice: event.minPrice,
        maxPrice: event.maxPrice,
      );
      emit(product_event.ProductsLoaded(paginatedProducts));
    } catch (e) {
      emit(product_event.ProductError(e.toString()));
    }
  }

  /// Charger un produit par ID
  Future<void> _onProductByIdLoadRequested(
    ProductByIdLoadRequested event,
    Emitter<product_event.ProductState> emit,
  ) async {
    emit(product_event.ProductLoading());

    try {
      final product = await _productService.getProductById(event.id);
      emit(product_event.ProductDetailLoaded(product));
    } catch (e) {
      emit(product_event.ProductError(e.toString()));
    }
  }

  /// Créer un produit
  Future<void> _onProductCreateRequested(
    ProductCreateRequested event,
    Emitter<product_event.ProductState> emit,
  ) async {
    emit(product_event.ProductLoading());

    try {
      final product = await _productService.createProduct(
        name: event.name,
        description: event.description,
        price: event.price,
        stock: event.stock,
        categoryId: event.categoryId,
        imageUrl: event.imageUrl,
        specifications: event.specifications,
      );
      emit(product_event.ProductCreated(product));
    } catch (e) {
      // Extraire le message d'erreur détaillé
      String errorMessage = 'Erreur lors de la création du produit';
      final errorString = e.toString();
      if (errorString.contains('Erreurs de validation')) {
        errorMessage = 'Validation échouée: Vérifiez tous les champs requis (nom, prix, stock, catégorie)';
      } else if (errorString.contains(':')) {
        errorMessage = errorString.split(':').last.trim();
      } else {
        errorMessage = errorString;
      }
      emit(product_event.ProductError(errorMessage));
    }
  }

  /// Mettre à jour un produit
  Future<void> _onProductUpdateRequested(
    ProductUpdateRequested event,
    Emitter<product_event.ProductState> emit,
  ) async {
    emit(product_event.ProductLoading());

    try {
      final product = await _productService.updateProduct(
        id: event.id,
        name: event.name,
        description: event.description,
        price: event.price,
        stock: event.stock,
        categoryId: event.categoryId,
        imageUrl: event.imageUrl,
        specifications: event.specifications,
      );
      emit(product_event.ProductUpdated(product));
    } catch (e) {
      emit(product_event.ProductError(e.toString()));
    }
  }

  /// Supprimer un produit
  Future<void> _onProductDeleteRequested(
    ProductDeleteRequested event,
    Emitter<product_event.ProductState> emit,
  ) async {
    emit(product_event.ProductLoading());

    try {
      await _productService.deleteProduct(event.id);
      emit(product_event.ProductDeleted());
    } catch (e) {
      emit(product_event.ProductError(e.toString()));
    }
  }

  /// Upload image produit
  Future<void> _onProductImageUploadRequested(
    ProductImageUploadRequested event,
    Emitter<product_event.ProductState> emit,
  ) async {
    emit(product_event.ProductLoading());

    try {
      final imageUrl = await _productService.uploadProductImage(event.filePath);
      emit(product_event.ProductImageUploaded(imageUrl));
    } catch (e) {
      emit(product_event.ProductError(e.toString()));
    }
  }

  /// Charger les catégories
  Future<void> _onCategoriesLoadRequested(
    CategoriesLoadRequested event,
    Emitter<product_event.ProductState> emit,
  ) async {
    emit(product_event.ProductLoading());

    try {
      final categories = await _productService.getCategories();
      emit(product_event.CategoriesLoaded(categories));
    } catch (e) {
      emit(product_event.ProductError(e.toString()));
    }
  }
}

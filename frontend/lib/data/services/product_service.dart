import '../../core/constants/api_constants.dart';
import '../../domain/models/product.dart';
import 'api_service.dart';

/// Service de gestion des produits
/// Gère le catalogue, filtres, recherche, CRUD admin
class ProductService {
  final ApiService _apiService;

  ProductService(this._apiService);

  /// Récupérer tous les produits avec pagination et filtres
  Future<PaginatedProducts> getProducts({
    int page = 1,
    int limit = 20,
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (search != null && search.isNotEmpty) {
      queryParams['search'] = search;
    }
    if (categoryId != null) {
      queryParams['category_id'] = categoryId;
    }
    if (minPrice != null) {
      queryParams['min_price'] = minPrice;
    }
    if (maxPrice != null) {
      queryParams['max_price'] = maxPrice;
    }

    final response = await _apiService.get(
      ApiConstants.getAllProducts,
      queryParameters: queryParams,
    );

    // L'API retourne { data: [...products], pagination: {...} }
    return PaginatedProducts.fromJson(
      response.data['data'], // Liste de produits directement dans 'data'
      response.data['pagination'],
    );
  }

  /// Récupérer un produit par son ID
  Future<Product> getProductById(int id) async {
    final response = await _apiService.get(
      ApiConstants.getProductById(id),
    );
    // L'API retourne { data: {produit complet}, message, success }
    return Product.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Créer un nouveau produit (Admin)
  Future<Product> createProduct({
    required String name,
    required String description,
    required double price,
    required int stock,
    required int categoryId,
    String? imageUrl,
    Map<String, dynamic>? specifications,
  }) async {
    final data = {
      'name': name,
      'description': description,
      'price': price,
      'stock_quantity': stock,
      'category_id': categoryId,
    };

    if (imageUrl != null) data['image_url'] = imageUrl;
    if (specifications != null) data['specifications'] = specifications;

    final response = await _apiService.post(
      ApiConstants.createProduct,
      data: data,
    );

    // L'API retourne { data: {nouveau produit}, message, success }
    return Product.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Mettre à jour un produit (Admin)
  Future<Product> updateProduct({
    required int id,
    String? name,
    String? description,
    double? price,
    int? stock,
    int? categoryId,
    String? imageUrl,
    Map<String, dynamic>? specifications,
  }) async {
    final data = <String, dynamic>{};

    if (name != null) data['name'] = name;
    if (description != null) data['description'] = description;
    if (price != null) data['price'] = price;
    if (stock != null) data['stock_quantity'] = stock;
    if (categoryId != null) data['category_id'] = categoryId;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (specifications != null) data['specifications'] = specifications;

    final response = await _apiService.put(
      ApiConstants.updateProduct(id),
      data: data,
    );

    // L'API retourne { data: {produit mis à jour}, message, success }
    return Product.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Supprimer un produit (Admin)
  Future<void> deleteProduct(int id) async {
    await _apiService.delete(ApiConstants.deleteProduct(id));
  }

  /// Upload image produit (Admin)
  Future<String> uploadProductImage(String filePath) async {
    final response = await _apiService.uploadFile(
      ApiConstants.uploadProductImage,
      'image',
      filePath,
    );
    return response.data['image_url'];
  }

  /// Récupérer toutes les catégories
  Future<List<Category>> getCategories() async {
    final response = await _apiService.get(ApiConstants.getCategories);
    final List categoriesJson = response.data['categories'];
    return categoriesJson.map((json) => Category.fromJson(json)).toList();
  }
}

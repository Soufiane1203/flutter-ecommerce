/// Constantes pour l'API Backend
class ApiConstants {
  // Base URL du backend Node.js
  static const String baseUrl = 'http://localhost:3000/api';

  // Endpoints Authentification
  static const String register = '/auth/register';
  static const String login = '/auth/login';
  static const String profile = '/auth/profile';
  static const String updateProfile = '/auth/profile';
  static const String changePassword = '/auth/change-password';

  // Endpoints Produits
  static const String getAllProducts = '/products';
  static String getProductById(int id) => '/products/$id';
  static const String createProduct = '/products';
  static String updateProduct(int id) => '/products/$id';
  static String deleteProduct(int id) => '/products/$id';
  static const String uploadProductImage = '/products/upload';
  static const String getCategories = '/products/categories/all';
  static const String brands = '/products/brands/all';

  // Endpoints Panier
  static const String getCart = '/cart';
  static const String addToCart = '/cart';
  static String updateCartItem(int itemId) => '/cart/$itemId';
  static String removeFromCart(int itemId) => '/cart/$itemId';
  static const String clearCart = '/cart';

  // Endpoints Commandes
  static const String createOrder = '/orders';
  static const String getMyOrders = '/orders';
  static String getOrderById(int id) => '/orders/$id';
  static String cancelOrder(int id) => '/orders/$id/cancel';
  static const String getAllOrders = '/orders/admin/all';
  static String updateOrderStatus(int id) => '/orders/$id/status';

  // Headers
  static const String contentType = 'application/json';
  static const String authorization = 'Authorization';
  static String bearer(String token) => 'Bearer $token';

  // Timeout
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

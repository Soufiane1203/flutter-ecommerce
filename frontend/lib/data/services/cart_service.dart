import '../../core/constants/api_constants.dart';
import '../../domain/models/cart.dart';
import 'api_service.dart';

/// Service de gestion du panier
/// Gère l'ajout, modification, suppression d'articles
class CartService {
  final ApiService _apiService;

  CartService(this._apiService);

  /// Récupérer le panier de l'utilisateur connecté
  Future<Cart> getCart() async {
    final response = await _apiService.get(ApiConstants.getCart);
    // L'API retourne { data: { items, total, itemCount } }
    return Cart.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Ajouter un produit au panier
  Future<CartItem> addToCart({
    required int productId,
    required int quantity,
  }) async {
    final response = await _apiService.post(
      ApiConstants.addToCart,
      data: {
        'product_id': productId,
        'quantity': quantity,
      },
    );
    // L'API retourne { data: {cart_item complet}, message, success }
    return CartItem.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Mettre à jour la quantité d'un produit dans le panier
  Future<CartItem> updateCartItem({
    required int itemId,
    required int quantity,
  }) async {
    final response = await _apiService.put(
      ApiConstants.updateCartItem(itemId),
      data: {
        'quantity': quantity,
      },
    );
    // L'API retourne { data: {cart_item mis à jour}, message, success }
    return CartItem.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Supprimer un produit du panier
  Future<void> removeFromCart(int itemId) async {
    await _apiService.delete(ApiConstants.removeFromCart(itemId));
  }

  /// Vider le panier
  Future<void> clearCart() async {
    await _apiService.delete(ApiConstants.clearCart);
  }
}

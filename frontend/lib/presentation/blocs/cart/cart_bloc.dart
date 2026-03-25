import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/cart_service.dart';
import 'cart_event.dart';
import 'cart_event.dart' as cart_event;

export 'cart_event.dart';

/// BLoC de gestion du panier
/// Gère l'ajout, modification, suppression d'articles
class CartBloc extends Bloc<CartEvent, cart_event.CartState> {
  final CartService _cartService;

  CartBloc(this._cartService) : super(cart_event.CartInitial()) {
    on<CartLoadRequested>(_onCartLoadRequested);
    on<CartItemAddRequested>(_onCartItemAddRequested);
    on<CartItemUpdateRequested>(_onCartItemUpdateRequested);
    on<CartItemRemoveRequested>(_onCartItemRemoveRequested);
    on<CartClearRequested>(_onCartClearRequested);
  }

  /// Charger le panier
  Future<void> _onCartLoadRequested(
    CartLoadRequested event,
    Emitter<cart_event.CartState> emit,
  ) async {
    emit(cart_event.CartLoading());

    try {
      final cart = await _cartService.getCart();
      emit(cart_event.CartLoaded(cart));
    } catch (e) {
      emit(cart_event.CartError(e.toString()));
    }
  }

  /// Ajouter au panier
  Future<void> _onCartItemAddRequested(
    CartItemAddRequested event,
    Emitter<cart_event.CartState> emit,
  ) async {
    emit(cart_event.CartLoading());

    try {
      final item = await _cartService.addToCart(
        productId: event.productId,
        quantity: event.quantity,
      );
      emit(cart_event.CartItemAdded(item));
      // Recharger le panier complet
      final cart = await _cartService.getCart();
      emit(cart_event.CartLoaded(cart));
    } catch (e) {
      emit(cart_event.CartError(e.toString()));
    }
  }

  /// Mettre à jour un article
  Future<void> _onCartItemUpdateRequested(
    CartItemUpdateRequested event,
    Emitter<cart_event.CartState> emit,
  ) async {
    emit(cart_event.CartLoading());

    try {
      final item = await _cartService.updateCartItem(
        itemId: event.itemId,
        quantity: event.quantity,
      );
      emit(cart_event.CartItemUpdated(item));
      // Recharger le panier complet
      final cart = await _cartService.getCart();
      emit(cart_event.CartLoaded(cart));
    } catch (e) {
      emit(cart_event.CartError(e.toString()));
    }
  }

  /// Supprimer un article
  Future<void> _onCartItemRemoveRequested(
    CartItemRemoveRequested event,
    Emitter<cart_event.CartState> emit,
  ) async {
    emit(cart_event.CartLoading());

    try {
      await _cartService.removeFromCart(event.itemId);
      emit(cart_event.CartItemRemoved());
      // Recharger le panier complet
      final cart = await _cartService.getCart();
      emit(cart_event.CartLoaded(cart));
    } catch (e) {
      emit(cart_event.CartError(e.toString()));
    }
  }

  /// Vider le panier
  Future<void> _onCartClearRequested(
    CartClearRequested event,
    Emitter<cart_event.CartState> emit,
  ) async {
    emit(cart_event.CartLoading());

    try {
      await _cartService.clearCart();
      emit(cart_event.CartCleared());
      // Recharger le panier complet
      final cart = await _cartService.getCart();
      emit(cart_event.CartLoaded(cart));
    } catch (e) {
      emit(cart_event.CartError(e.toString()));
    }
  }
}

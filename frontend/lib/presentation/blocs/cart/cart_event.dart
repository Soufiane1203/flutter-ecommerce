import 'package:equatable/equatable.dart';
import '../../../domain/models/cart.dart';

/// === CART EVENTS ===

abstract class CartEvent extends Equatable {
  const CartEvent();

  @override
  List<Object?> get props => [];
}

/// Charger le panier
class CartLoadRequested extends CartEvent {}

/// Ajouter au panier
class CartItemAddRequested extends CartEvent {
  final int productId;
  final int quantity;

  const CartItemAddRequested({
    required this.productId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [productId, quantity];
}

/// Mettre à jour la quantité
class CartItemUpdateRequested extends CartEvent {
  final int itemId;
  final int quantity;

  const CartItemUpdateRequested({
    required this.itemId,
    required this.quantity,
  });

  @override
  List<Object?> get props => [itemId, quantity];
}

/// Supprimer du panier
class CartItemRemoveRequested extends CartEvent {
  final int itemId;

  const CartItemRemoveRequested(this.itemId);

  @override
  List<Object?> get props => [itemId];
}

/// Vider le panier
class CartClearRequested extends CartEvent {}

/// === CART STATES ===

abstract class CartState extends Equatable {
  const CartState();

  @override
  List<Object?> get props => [];
}

/// État initial
class CartInitial extends CartState {}

/// Chargement en cours
class CartLoading extends CartState {}

/// Panier chargé
class CartLoaded extends CartState {
  final Cart cart;

  const CartLoaded(this.cart);

  @override
  List<Object?> get props => [cart];
}

/// Article ajouté
class CartItemAdded extends CartState {
  final CartItem item;

  const CartItemAdded(this.item);

  @override
  List<Object?> get props => [item];
}

/// Article mis à jour
class CartItemUpdated extends CartState {
  final CartItem item;

  const CartItemUpdated(this.item);

  @override
  List<Object?> get props => [item];
}

/// Article supprimé
class CartItemRemoved extends CartState {}

/// Panier vidé
class CartCleared extends CartState {}

/// Erreur panier
class CartError extends CartState {
  final String message;

  const CartError(this.message);

  @override
  List<Object?> get props => [message];
}

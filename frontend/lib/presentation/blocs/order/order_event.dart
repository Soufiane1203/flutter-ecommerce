import 'package:equatable/equatable.dart';
import '../../../domain/models/order.dart';

/// === ORDER EVENTS ===

abstract class OrderEvent extends Equatable {
  const OrderEvent();

  @override
  List<Object?> get props => [];
}

/// Créer une commande
class OrderCreateRequested extends OrderEvent {
  final String shippingAddress;
  final String phone;
  final String? notes;

  const OrderCreateRequested({
    required this.shippingAddress,
    required this.phone,
    this.notes,
  });

  @override
  List<Object?> get props => [shippingAddress, phone, notes];
}

/// Charger mes commandes
class MyOrdersLoadRequested extends OrderEvent {
  final int page;
  final int limit;

  const MyOrdersLoadRequested({
    this.page = 1,
    this.limit = 20,
  });

  @override
  List<Object?> get props => [page, limit];
}

/// Charger une commande par ID
class OrderByIdLoadRequested extends OrderEvent {
  final int id;

  const OrderByIdLoadRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Annuler une commande
class OrderCancelRequested extends OrderEvent {
  final int id;

  const OrderCancelRequested(this.id);

  @override
  List<Object?> get props => [id];
}

/// Charger toutes les commandes (Admin)
class AllOrdersLoadRequested extends OrderEvent {
  final int page;
  final int limit;
  final String? status;

  const AllOrdersLoadRequested({
    this.page = 1,
    this.limit = 20,
    this.status,
  });

  @override
  List<Object?> get props => [page, limit, status];
}

/// Mettre à jour le statut (Admin)
class OrderStatusUpdateRequested extends OrderEvent {
  final int id;
  final String status;

  const OrderStatusUpdateRequested({
    required this.id,
    required this.status,
  });

  @override
  List<Object?> get props => [id, status];
}

/// === ORDER STATES ===

abstract class OrderState extends Equatable {
  const OrderState();

  @override
  List<Object?> get props => [];
}

/// État initial
class OrderInitial extends OrderState {}

/// Chargement en cours
class OrderLoading extends OrderState {}

/// Commande créée
class OrderCreated extends OrderState {
  final Order order;

  const OrderCreated(this.order);

  @override
  List<Object?> get props => [order];
}

/// Liste de commandes chargée
class OrdersLoaded extends OrderState {
  final PaginatedOrders paginatedOrders;

  const OrdersLoaded(this.paginatedOrders);

  @override
  List<Object?> get props => [paginatedOrders];
}

/// Détails d'une commande
class OrderDetailLoaded extends OrderState {
  final Order order;

  const OrderDetailLoaded(this.order);

  @override
  List<Object?> get props => [order];
}

/// Commande annulée
class OrderCancelled extends OrderState {
  final Order order;

  const OrderCancelled(this.order);

  @override
  List<Object?> get props => [order];
}

/// Statut mis à jour
class OrderStatusUpdated extends OrderState {
  final Order order;

  const OrderStatusUpdated(this.order);

  @override
  List<Object?> get props => [order];
}

/// Erreur commande
class OrderError extends OrderState {
  final String message;

  const OrderError(this.message);

  @override
  List<Object?> get props => [message];
}

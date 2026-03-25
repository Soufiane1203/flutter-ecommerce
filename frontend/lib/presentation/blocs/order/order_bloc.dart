import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/order_service.dart';
import 'order_event.dart';
import 'order_event.dart' as order_event;

export 'order_event.dart';

/// BLoC de gestion des commandes
/// Gère la création, historique, gestion admin
class OrderBloc extends Bloc<OrderEvent, order_event.OrderState> {
  final OrderService _orderService;

  OrderBloc(this._orderService) : super(order_event.OrderInitial()) {
    on<OrderCreateRequested>(_onOrderCreateRequested);
    on<MyOrdersLoadRequested>(_onMyOrdersLoadRequested);
    on<OrderByIdLoadRequested>(_onOrderByIdLoadRequested);
    on<OrderCancelRequested>(_onOrderCancelRequested);
    on<AllOrdersLoadRequested>(_onAllOrdersLoadRequested);
    on<OrderStatusUpdateRequested>(_onOrderStatusUpdateRequested);
  }

  /// Créer une commande
  Future<void> _onOrderCreateRequested(
    OrderCreateRequested event,
    Emitter<order_event.OrderState> emit,
  ) async {
    debugPrint('🛒 ORDER BLOC: Starting order creation');
    debugPrint('🛒 ORDER BLOC: Address: ${event.shippingAddress}');
    debugPrint('🛒 ORDER BLOC: Phone: ${event.phone}');
    debugPrint('🛒 ORDER BLOC: Notes: ${event.notes}');
    
    emit(order_event.OrderLoading());

    try {
      debugPrint('🛒 ORDER BLOC: Calling order service...');
      final order = await _orderService.createOrder(
        shippingAddress: event.shippingAddress,
        phone: event.phone,
        notes: event.notes,
      );
      debugPrint('🛒 ORDER BLOC: Order created successfully! ID: ${order.id}');
      emit(order_event.OrderCreated(order));
    } catch (e, stackTrace) {
      debugPrint('🛒 ORDER BLOC ERROR: $e');
      debugPrint('🛒 ORDER BLOC STACK: $stackTrace');
      
      // Extraire un message d'erreur plus clair
      String errorMessage = 'Erreur lors de la création de la commande';
      final errorString = e.toString();
      
      if (errorString.contains('Format de réponse invalide')) {
        errorMessage = 'Erreur de communication avec le serveur';
      } else if (errorString.contains('Exception:')) {
        errorMessage = errorString.split('Exception:').last.trim();
      }
      
      emit(order_event.OrderError(errorMessage));
    }
  }

  /// Charger mes commandes
  Future<void> _onMyOrdersLoadRequested(
    MyOrdersLoadRequested event,
    Emitter<order_event.OrderState> emit,
  ) async {
    emit(order_event.OrderLoading());

    try {
      final paginatedOrders = await _orderService.getMyOrders(
        page: event.page,
        limit: event.limit,
      );
      emit(order_event.OrdersLoaded(paginatedOrders));
    } catch (e) {
      emit(order_event.OrderError(e.toString()));
    }
  }

  /// Charger une commande par ID
  Future<void> _onOrderByIdLoadRequested(
    OrderByIdLoadRequested event,
    Emitter<order_event.OrderState> emit,
  ) async {
    emit(order_event.OrderLoading());

    try {
      final order = await _orderService.getOrderById(event.id);
      emit(order_event.OrderDetailLoaded(order));
    } catch (e) {
      emit(order_event.OrderError(e.toString()));
    }
  }

  /// Annuler une commande
  Future<void> _onOrderCancelRequested(
    OrderCancelRequested event,
    Emitter<order_event.OrderState> emit,
  ) async {
    emit(order_event.OrderLoading());

    try {
      final order = await _orderService.cancelOrder(event.id);
      emit(order_event.OrderCancelled(order));
    } catch (e) {
      emit(order_event.OrderError(e.toString()));
    }
  }

  /// Charger toutes les commandes (Admin)
  Future<void> _onAllOrdersLoadRequested(
    AllOrdersLoadRequested event,
    Emitter<order_event.OrderState> emit,
  ) async {
    emit(order_event.OrderLoading());

    try {
      final paginatedOrders = await _orderService.getAllOrders(
        page: event.page,
        limit: event.limit,
        status: event.status,
      );
      emit(order_event.OrdersLoaded(paginatedOrders));
    } catch (e) {
      emit(order_event.OrderError(e.toString()));
    }
  }

  /// Mettre à jour le statut (Admin)
  Future<void> _onOrderStatusUpdateRequested(
    OrderStatusUpdateRequested event,
    Emitter<order_event.OrderState> emit,
  ) async {
    emit(order_event.OrderLoading());

    try {
      final order = await _orderService.updateOrderStatus(
        id: event.id,
        status: event.status,
      );
      emit(order_event.OrderStatusUpdated(order));
    } catch (e) {
      emit(order_event.OrderError(e.toString()));
    }
  }
}

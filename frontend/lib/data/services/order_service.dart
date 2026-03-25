import 'package:flutter/foundation.dart';
import '../../core/constants/api_constants.dart';
import '../../domain/models/order.dart';
import 'api_service.dart';

/// Service de gestion des commandes
/// Gère la création, historique, gestion admin des commandes
class OrderService {
  final ApiService _apiService;

  OrderService(this._apiService);

  /// Créer une commande depuis le panier actuel
  Future<Order> createOrder({
    required String shippingAddress,
    required String phone,
    String? notes,
  }) async {
    debugPrint('📦 ORDER SERVICE: Creating order...');
    debugPrint('📦 ORDER SERVICE: Address: $shippingAddress');
    debugPrint('📦 ORDER SERVICE: Phone: $phone');
    debugPrint('📦 ORDER SERVICE: Notes: $notes');
    
    final response = await _apiService.post(
      ApiConstants.createOrder,
      data: {
        'shipping_address': shippingAddress,
        'phone': phone,
        if (notes != null) 'notes': notes,
      },
    );
    
    debugPrint('📦 ORDER SERVICE: Response status: ${response.statusCode}');
    debugPrint('📦 ORDER SERVICE: Response data type: ${response.data.runtimeType}');
    debugPrint('📦 ORDER SERVICE: Response data: ${response.data}');
    
    // L'API retourne { success: true, message: '...', data: {ordre complet} }
    if (response.data is Map && response.data['data'] != null) {
      return Order.fromJson(response.data['data'] as Map<String, dynamic>);
    } else {
      throw Exception('Format de réponse invalide: ${response.data}');
    }
  }

  /// Récupérer l'historique des commandes de l'utilisateur
  Future<PaginatedOrders> getMyOrders({
    int page = 1,
    int limit = 20,
  }) async {
    final response = await _apiService.get(
      ApiConstants.getMyOrders,
      queryParameters: {
        'page': page,
        'limit': limit,
      },
    );
    // L'API retourne { data: [...orders], pagination, message, success }
    return PaginatedOrders.fromJson(
      response.data['data'],
      response.data['pagination'],
    );
  }

  /// Récupérer les détails d'une commande
  Future<Order> getOrderById(int id) async {
    final response = await _apiService.get(ApiConstants.getOrderById(id));
    // L'API retourne { data: {ordre complet avec items}, message, success }
    return Order.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Annuler une commande (User)
  Future<Order> cancelOrder(int id) async {
    final response = await _apiService.put(ApiConstants.cancelOrder(id));
    // L'API retourne { data: {ordre mis à jour}, message, success }
    return Order.fromJson(response.data['data'] as Map<String, dynamic>);
  }

  /// Récupérer toutes les commandes (Admin)
  Future<PaginatedOrders> getAllOrders({
    int page = 1,
    int limit = 20,
    String? status,
  }) async {
    final queryParams = <String, dynamic>{
      'page': page,
      'limit': limit,
    };

    if (status != null && status.isNotEmpty) {
      queryParams['status'] = status;
    }

    final response = await _apiService.get(
      ApiConstants.getAllOrders,
      queryParameters: queryParams,
    );
    // L'API retourne { data: [...orders], pagination, message, success }
    return PaginatedOrders.fromJson(
      response.data['data'],
      response.data['pagination'],
    );
  }

  /// Mettre à jour le statut d'une commande (Admin)
  Future<Order> updateOrderStatus({
    required int id,
    required String status,
  }) async {
    final response = await _apiService.put(
      ApiConstants.updateOrderStatus(id),
      data: {
        'status': status,
      },
    );
    // L'API retourne { data: {ordre mis à jour}, message, success }
    return Order.fromJson(response.data['data'] as Map<String, dynamic>);
  }
}

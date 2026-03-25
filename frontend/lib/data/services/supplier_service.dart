import 'package:dio/dio.dart';
import '../models/supplier.dart';
import 'api_service.dart';

/// Service pour gérer les fournisseurs
class SupplierService {
  final ApiService _apiService;

  SupplierService(this._apiService);

  /// Récupérer tous les fournisseurs
  Future<List<Supplier>> getAllSuppliers({String? status, String? search}) async {
    try {
      final queryParams = <String, dynamic>{};
      if (status != null) queryParams['status'] = status;
      if (search != null) queryParams['search'] = search;

      final response = await _apiService.dio.get(
        '/suppliers',
        queryParameters: queryParams,
      );

      if (response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((json) => Supplier.fromJson(json)).toList();
      }

      throw Exception('Erreur lors de la récupération des fournisseurs');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur réseau');
    }
  }

  /// Récupérer un fournisseur par ID
  Future<Supplier> getSupplierById(int id) async {
    try {
      final response = await _apiService.dio.get('/suppliers/$id');

      if (response.data['success'] == true) {
        return Supplier.fromJson(response.data['data']);
      }

      throw Exception('Fournisseur introuvable');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur réseau');
    }
  }

  /// Créer un nouveau fournisseur (Admin)
  Future<Supplier> createSupplier({
    required String name,
    String? email,
    String? phone,
    String? address,
    String status = 'active',
  }) async {
    try {
      final response = await _apiService.dio.post(
        '/suppliers',
        data: {
          'name': name,
          'email': email,
          'phone': phone,
          'address': address,
          'status': status,
        },
      );

      if (response.data['success'] == true) {
        return Supplier.fromJson(response.data['data']);
      }

      throw Exception('Erreur lors de la création du fournisseur');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur réseau');
    }
  }

  /// Mettre à jour un fournisseur (Admin)
  Future<Supplier> updateSupplier({
    required int id,
    String? name,
    String? email,
    String? phone,
    String? address,
    String? status,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (name != null) data['name'] = name;
      if (email != null) data['email'] = email;
      if (phone != null) data['phone'] = phone;
      if (address != null) data['address'] = address;
      if (status != null) data['status'] = status;

      final response = await _apiService.dio.put(
        '/suppliers/$id',
        data: data,
      );

      if (response.data['success'] == true) {
        return Supplier.fromJson(response.data['data']);
      }

      throw Exception('Erreur lors de la mise à jour du fournisseur');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur réseau');
    }
  }

  /// Supprimer un fournisseur (Admin)
  Future<void> deleteSupplier(int id) async {
    try {
      final response = await _apiService.dio.delete('/suppliers/$id');

      if (response.data['success'] != true) {
        throw Exception('Erreur lors de la suppression du fournisseur');
      }
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur réseau');
    }
  }

  /// Changer le statut d'un fournisseur (Admin)
  Future<Supplier> changeStatus(int id, String status) async {
    try {
      final response = await _apiService.dio.patch(
        '/suppliers/$id/status',
        data: {'status': status},
      );

      if (response.data['success'] == true) {
        return Supplier.fromJson(response.data['data']);
      }

      throw Exception('Erreur lors du changement de statut');
    } on DioException catch (e) {
      throw Exception(e.response?.data['message'] ?? 'Erreur réseau');
    }
  }
}

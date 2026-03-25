import 'package:equatable/equatable.dart';

/// Événements pour le SupplierBloc
abstract class SupplierEvent extends Equatable {
  const SupplierEvent();

  @override
  List<Object?> get props => [];
}

/// Charger tous les fournisseurs
class FetchSuppliers extends SupplierEvent {
  final String? status;
  final String? search;

  const FetchSuppliers({this.status, this.search});

  @override
  List<Object?> get props => [status, search];
}

/// Charger un fournisseur par ID
class FetchSupplierById extends SupplierEvent {
  final int id;

  const FetchSupplierById(this.id);

  @override
  List<Object> get props => [id];
}

/// Créer un nouveau fournisseur
class CreateSupplier extends SupplierEvent {
  final String name;
  final String? email;
  final String? phone;
  final String? address;
  final String status;

  const CreateSupplier({
    required this.name,
    this.email,
    this.phone,
    this.address,
    this.status = 'active',
  });

  @override
  List<Object?> get props => [name, email, phone, address, status];
}

/// Mettre à jour un fournisseur
class UpdateSupplier extends SupplierEvent {
  final int id;
  final String? name;
  final String? email;
  final String? phone;
  final String? address;
  final String? status;

  const UpdateSupplier({
    required this.id,
    this.name,
    this.email,
    this.phone,
    this.address,
    this.status,
  });

  @override
  List<Object?> get props => [id, name, email, phone, address, status];
}

/// Supprimer un fournisseur
class DeleteSupplier extends SupplierEvent {
  final int id;

  const DeleteSupplier(this.id);

  @override
  List<Object> get props => [id];
}

/// Changer le statut d'un fournisseur
class ChangeSupplierStatus extends SupplierEvent {
  final int id;
  final String status;

  const ChangeSupplierStatus(this.id, this.status);

  @override
  List<Object> get props => [id, status];
}

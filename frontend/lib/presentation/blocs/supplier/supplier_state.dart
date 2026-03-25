import 'package:equatable/equatable.dart';
import '../../../data/models/supplier.dart';

/// États pour le SupplierBloc
abstract class SupplierState extends Equatable {
  const SupplierState();

  @override
  List<Object?> get props => [];
}

/// État initial
class SupplierInitial extends SupplierState {}

/// État de chargement
class SupplierLoading extends SupplierState {}

/// État: Liste des fournisseurs chargée
class SuppliersLoaded extends SupplierState {
  final List<Supplier> suppliers;

  const SuppliersLoaded(this.suppliers);

  @override
  List<Object> get props => [suppliers];
}

/// État: Un fournisseur chargé
class SupplierLoaded extends SupplierState {
  final Supplier supplier;

  const SupplierLoaded(this.supplier);

  @override
  List<Object> get props => [supplier];
}

/// État: Fournisseur créé avec succès
class SupplierCreated extends SupplierState {
  final Supplier supplier;

  const SupplierCreated(this.supplier);

  @override
  List<Object> get props => [supplier];
}

/// État: Fournisseur mis à jour avec succès
class SupplierUpdated extends SupplierState {
  final Supplier supplier;

  const SupplierUpdated(this.supplier);

  @override
  List<Object> get props => [supplier];
}

/// État: Fournisseur supprimé avec succès
class SupplierDeleted extends SupplierState {}

/// État d'erreur
class SupplierError extends SupplierState {
  final String message;

  const SupplierError(this.message);

  @override
  List<Object> get props => [message];
}

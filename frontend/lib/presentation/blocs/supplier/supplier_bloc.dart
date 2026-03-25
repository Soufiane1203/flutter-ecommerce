import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../data/services/supplier_service.dart';
import 'supplier_event.dart';
import 'supplier_state.dart';

/// BLoC pour gérer l'état des fournisseurs
class SupplierBloc extends Bloc<SupplierEvent, SupplierState> {
  final SupplierService _supplierService;

  SupplierBloc(this._supplierService) : super(SupplierInitial()) {
    on<FetchSuppliers>(_onFetchSuppliers);
    on<FetchSupplierById>(_onFetchSupplierById);
    on<CreateSupplier>(_onCreateSupplier);
    on<UpdateSupplier>(_onUpdateSupplier);
    on<DeleteSupplier>(_onDeleteSupplier);
    on<ChangeSupplierStatus>(_onChangeSupplierStatus);
  }

  Future<void> _onFetchSuppliers(
    FetchSuppliers event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    try {
      final suppliers = await _supplierService.getAllSuppliers(
        status: event.status,
        search: event.search,
      );
      emit(SuppliersLoaded(suppliers));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onFetchSupplierById(
    FetchSupplierById event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    try {
      final supplier = await _supplierService.getSupplierById(event.id);
      emit(SupplierLoaded(supplier));
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onCreateSupplier(
    CreateSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    try {
      final supplier = await _supplierService.createSupplier(
        name: event.name,
        email: event.email,
        phone: event.phone,
        address: event.address,
        status: event.status,
      );
      emit(SupplierCreated(supplier));
      // Recharger la liste
      add(const FetchSuppliers());
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onUpdateSupplier(
    UpdateSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    try {
      final supplier = await _supplierService.updateSupplier(
        id: event.id,
        name: event.name,
        email: event.email,
        phone: event.phone,
        address: event.address,
        status: event.status,
      );
      emit(SupplierUpdated(supplier));
      // Recharger la liste
      add(const FetchSuppliers());
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onDeleteSupplier(
    DeleteSupplier event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    try {
      await _supplierService.deleteSupplier(event.id);
      emit(SupplierDeleted());
      // Recharger la liste
      add(const FetchSuppliers());
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }

  Future<void> _onChangeSupplierStatus(
    ChangeSupplierStatus event,
    Emitter<SupplierState> emit,
  ) async {
    emit(SupplierLoading());
    try {
      final supplier = await _supplierService.changeStatus(event.id, event.status);
      emit(SupplierUpdated(supplier));
      // Recharger la liste
      add(const FetchSuppliers());
    } catch (e) {
      emit(SupplierError(e.toString()));
    }
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/supplier/supplier_bloc.dart';
import '../../blocs/supplier/supplier_event.dart';
import '../../blocs/supplier/supplier_state.dart';
import '../../../data/models/supplier.dart';
import 'package:intl/intl.dart';

/// Écran de gestion des fournisseurs
class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  String _selectedFilter = 'all';
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<SupplierBloc>().add(const FetchSuppliers());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Fournisseurs'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _refreshSuppliers(),
          ),
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showSupplierDialog(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildFilterChips(),
          Expanded(
            child: BlocConsumer<SupplierBloc, SupplierState>(
              listener: (context, state) {
                if (state is SupplierCreated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fournisseur créé avec succès'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } else if (state is SupplierUpdated) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fournisseur mis à jour'),
                      backgroundColor: Colors.blue,
                    ),
                  );
                } else if (state is SupplierDeleted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Fournisseur supprimé'),
                      backgroundColor: Colors.orange,
                    ),
                  );
                } else if (state is SupplierError) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(state.message),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
              builder: (context, state) {
                if (state is SupplierLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is SuppliersLoaded) {
                  final suppliers = _filterSuppliers(state.suppliers);

                  if (suppliers.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.business, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            _selectedFilter == 'all'
                                ? 'Aucun fournisseur'
                                : 'Aucun fournisseur ${_getFilterLabel(_selectedFilter)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            icon: const Icon(Icons.add),
                            label: const Text('Ajouter un fournisseur'),
                            onPressed: () => _showSupplierDialog(context),
                          ),
                        ],
                      ),
                    );
                  }

                  return RefreshIndicator(
                    onRefresh: () async => _refreshSuppliers(),
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16),
                      itemCount: suppliers.length,
                      itemBuilder: (context, index) => _buildSupplierCard(context, suppliers[index]),
                    ),
                  );
                }

                return const SizedBox();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Rechercher un fournisseur...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _refreshSuppliers();
                  },
                )
              : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        ),
        onChanged: (value) {
          // Recherche en temps réel
          if (value.length > 2 || value.isEmpty) {
            context.read<SupplierBloc>().add(FetchSuppliers(
                  status: _selectedFilter == 'all' ? null : _selectedFilter,
                  search: value.isEmpty ? null : value,
                ));
          }
        },
      ),
    );
  }

  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('all', 'Tous'),
            const SizedBox(width: 8),
            _buildFilterChip('active', 'Actifs'),
            const SizedBox(width: 8),
            _buildFilterChip('inactive', 'Inactifs'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
        _refreshSuppliers();
      },
    );
  }

  List<Supplier> _filterSuppliers(List<Supplier> suppliers) {
    if (_selectedFilter == 'all') return suppliers;
    return suppliers.where((s) => s.status == _selectedFilter).toList();
  }

  String _getFilterLabel(String filter) {
    return filter == 'active' ? 'actifs' : 'inactifs';
  }

  void _refreshSuppliers() {
    context.read<SupplierBloc>().add(FetchSuppliers(
          status: _selectedFilter == 'all' ? null : _selectedFilter,
          search: _searchController.text.isEmpty ? null : _searchController.text,
        ));
  }

  Widget _buildSupplierCard(BuildContext context, Supplier supplier) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: supplier.isActive ? Colors.green : Colors.grey,
          child: const Icon(
            Icons.business,
            color: Colors.white,
          ),
        ),
        title: Text(
          supplier.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (supplier.email != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.email, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(child: Text(supplier.email!, style: const TextStyle(fontSize: 12))),
                ],
              ),
            ],
            if (supplier.phone != null) ...[
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.phone, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Text(supplier.phone!, style: const TextStyle(fontSize: 12)),
                ],
              ),
            ],
            const SizedBox(height: 8),
            Chip(
              label: Text(
                supplier.isActive ? 'Actif' : 'Inactif',
                style: const TextStyle(color: Colors.white, fontSize: 11),
              ),
              backgroundColor: supplier.isActive ? Colors.green : Colors.grey,
              padding: EdgeInsets.zero,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'view',
              child: Row(
                children: [
                  Icon(Icons.visibility, size: 20),
                  SizedBox(width: 8),
                  Text('Voir détails'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'edit',
              child: Row(
                children: [
                  Icon(Icons.edit, size: 20),
                  SizedBox(width: 8),
                  Text('Modifier'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'status',
              child: Row(
                children: [
                  Icon(supplier.isActive ? Icons.block : Icons.check_circle, size: 20),
                  const SizedBox(width: 8),
                  Text(supplier.isActive ? 'Désactiver' : 'Activer'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'delete',
              child: Row(
                children: [
                  Icon(Icons.delete, size: 20, color: Colors.red),
                  SizedBox(width: 8),
                  Text('Supprimer', style: TextStyle(color: Colors.red)),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'view') {
              _showSupplierDetails(context, supplier);
            } else if (value == 'edit') {
              _showSupplierDialog(context, supplier: supplier);
            } else if (value == 'status') {
              _toggleSupplierStatus(supplier);
            } else if (value == 'delete') {
              _confirmDeleteSupplier(context, supplier);
            }
          },
        ),
      ),
    );
  }

  void _showSupplierDetails(BuildContext context, Supplier supplier) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        builder: (context, scrollController) => Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: ListView(
            controller: scrollController,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    supplier.name,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  Chip(
                    label: Text(
                      supplier.isActive ? 'Actif' : 'Inactif',
                      style: const TextStyle(color: Colors.white),
                    ),
                    backgroundColor: supplier.isActive ? Colors.green : Colors.grey,
                  ),
                ],
              ),
              const Divider(height: 32),
              if (supplier.email != null) _buildDetailRow(Icons.email, 'Email', supplier.email!),
              if (supplier.phone != null) _buildDetailRow(Icons.phone, 'Téléphone', supplier.phone!),
              if (supplier.address != null)
                _buildDetailRow(Icons.location_on, 'Adresse', supplier.address!),
              _buildDetailRow(
                Icons.calendar_today,
                'Créé le',
                DateFormat('dd/MM/yyyy à HH:mm').format(supplier.createdAt),
              ),
              _buildDetailRow(
                Icons.update,
                'Mis à jour',
                DateFormat('dd/MM/yyyy à HH:mm').format(supplier.updatedAt),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey[600]),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(value, style: const TextStyle(fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSupplierDialog(BuildContext context, {Supplier? supplier}) {
    final nameController = TextEditingController(text: supplier?.name);
    final emailController = TextEditingController(text: supplier?.email);
    final phoneController = TextEditingController(text: supplier?.phone);
    final addressController = TextEditingController(text: supplier?.address);
    String selectedStatus = supplier?.status ?? 'active';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(supplier == null ? 'Nouveau Fournisseur' : 'Modifier Fournisseur'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom *',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: phoneController,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.phone,
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: addressController,
                  decoration: const InputDecoration(
                    labelText: 'Adresse',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: selectedStatus,
                  decoration: const InputDecoration(
                    labelText: 'Statut',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'active', child: Text('Actif')),
                    DropdownMenuItem(value: 'inactive', child: Text('Inactif')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedStatus = value!;
                    });
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = nameController.text.trim();
                if (name.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Le nom est requis')),
                  );
                  return;
                }

                if (supplier == null) {
                  context.read<SupplierBloc>().add(CreateSupplier(
                        name: name,
                        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                        address:
                            addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                        status: selectedStatus,
                      ));
                } else {
                  context.read<SupplierBloc>().add(UpdateSupplier(
                        id: supplier.id,
                        name: name,
                        email: emailController.text.trim().isEmpty ? null : emailController.text.trim(),
                        phone: phoneController.text.trim().isEmpty ? null : phoneController.text.trim(),
                        address:
                            addressController.text.trim().isEmpty ? null : addressController.text.trim(),
                        status: selectedStatus,
                      ));
                }

                Navigator.pop(dialogContext);
              },
              child: Text(supplier == null ? 'Créer' : 'Modifier'),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSupplierStatus(Supplier supplier) {
    final newStatus = supplier.isActive ? 'inactive' : 'active';
    context.read<SupplierBloc>().add(ChangeSupplierStatus(supplier.id, newStatus));
  }

  void _confirmDeleteSupplier(BuildContext context, Supplier supplier) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le fournisseur'),
        content: Text('Voulez-vous vraiment supprimer "${supplier.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<SupplierBloc>().add(DeleteSupplier(supplier.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }
}

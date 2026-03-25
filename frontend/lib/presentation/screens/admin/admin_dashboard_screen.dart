import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:file_picker/file_picker.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/order/order_bloc.dart';
import '../../../domain/models/product.dart';
import '../../../domain/models/order.dart';
import '../../../core/constants/storage_constants.dart';
import 'package:intl/intl.dart';

/// Dashboard admin avec CRUD produits et gestion commandes
class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    context.read<ProductBloc>().add(const ProductsLoadRequested());
    context.read<OrderBloc>().add(const AllOrdersLoadRequested());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Administration'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(icon: Icon(Icons.dashboard), text: 'Stats'),
            Tab(icon: Icon(Icons.inventory), text: 'Produits'),
            Tab(icon: Icon(Icons.shopping_bag), text: 'Commandes'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildStatsTab(),
          _buildProductsTab(),
          _buildOrdersTab(),
        ],
      ),
    );
  }

  // ============== STATS TAB ==============
  Widget _buildStatsTab() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, orderState) {
        return BlocBuilder<ProductBloc, ProductState>(
          builder: (context, productState) {
            // Gestion du chargement
            if (orderState is OrderLoading || productState is ProductLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Gestion des erreurs
            if (orderState is OrderError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erreur commandes: ${orderState.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<OrderBloc>().add(const AllOrdersLoadRequested());
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (productState is ProductError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.error, size: 64, color: Colors.red),
                    const SizedBox(height: 16),
                    Text('Erreur produits: ${productState.message}'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        context.read<ProductBloc>().add(const ProductsLoadRequested());
                      },
                      child: const Text('Réessayer'),
                    ),
                  ],
                ),
              );
            }

            if (orderState is OrdersLoaded && productState is ProductsLoaded) {
              final orders = orderState.paginatedOrders.orders;
              final products = productState.paginatedProducts.products;

              final totalRevenue = orders.fold<double>(
                0,
                (sum, order) => sum + (order.status.name != 'cancelled' ? order.totalAmount : 0),
              );
              final pendingOrders = orders.where((o) => o.status.name == 'pending').length;
              final lowStockProducts = products.where((p) => p.stockQuantity < 10).length;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '📊 Vue d\'ensemble',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Revenu Total',
                            '${totalRevenue.toStringAsFixed(2)} €',
                            Icons.euro,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Commandes',
                            '${orders.length}',
                            Icons.shopping_cart,
                            Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'En attente',
                            '$pendingOrders',
                            Icons.schedule,
                            Colors.orange,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            context,
                            'Stock bas',
                            '$lowStockProducts',
                            Icons.warning,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    Text(
                      '📉 Produits - Stock faible',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    const SizedBox(height: 12),
                    if (lowStockProducts > 0)
                      ...products.where((p) => p.stockQuantity < 10).map((product) {
                        return Card(
                          margin: const EdgeInsets.only(bottom: 8),
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: product.stockQuantity < 5 ? Colors.red : Colors.orange,
                              child: Text('${product.stockQuantity}'),
                            ),
                            title: Text(product.name),
                            subtitle: Text('Stock: ${product.stockQuantity} unités'),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () => _tabController.animateTo(1),
                          ),
                        );
                      })
                    else
                      const Card(
                        child: Padding(
                          padding: EdgeInsets.all(16),
                          child: Text('✅ Tous les produits ont un stock suffisant'),
                        ),
                      ),
                  ],
                ),
              );
            }

            // État par défaut
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Chargement des données...'),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon, Color color) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icon, size: 32, color: color),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============== PRODUCTS TAB ==============
  Widget _buildProductsTab() {
    return BlocBuilder<ProductBloc, ProductState>(
      builder: (context, state) {
        if (state is ProductLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is ProductError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<ProductBloc>().add(const ProductsLoadRequested());
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (state is ProductsLoaded) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${state.paginatedProducts.products.length} produits',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    ElevatedButton.icon(
                      icon: const Icon(Icons.add),
                      label: const Text('Nouveau'),
                      onPressed: () => _showProductDialog(context),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: state.paginatedProducts.products.length,
                  itemBuilder: (context, index) {
                    final product = state.paginatedProducts.products[index];
                    return _buildProductCard(context, product);
                  },
                ),
              ),
            ],
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement des produits...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductCard(BuildContext context, Product product) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        contentPadding: const EdgeInsets.all(12),
        leading: Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: product.imageUrl != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    product.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                  ),
                )
              : const Icon(Icons.image),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 4),
            Text('${product.price.toStringAsFixed(2)} €'),
            Text(
              'Stock: ${product.stockQuantity}',
              style: TextStyle(
                color: product.stockQuantity < 10 ? Colors.red : Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        trailing: PopupMenuButton(
          itemBuilder: (context) => [
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
            if (value == 'edit') {
              _showProductDialog(context, product: product);
            } else if (value == 'delete') {
              _confirmDeleteProduct(context, product);
            }
          },
        ),
      ),
    );
  }

  void _showProductDialog(BuildContext context, {Product? product}) {
    final nameController = TextEditingController(text: product?.name);
    final priceController = TextEditingController(text: product?.price.toString());
    final stockController = TextEditingController(text: product?.stockQuantity.toString());
    final descriptionController = TextEditingController(text: product?.description);
    final imageController = TextEditingController(text: product?.imageUrl);

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(product == null ? 'Nouveau Produit' : 'Modifier Produit'),
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
                controller: priceController,
                decoration: const InputDecoration(
                  labelText: 'Prix (€) *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: stockController,
                decoration: const InputDecoration(
                  labelText: 'Stock *',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descriptionController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: imageController,
                      decoration: const InputDecoration(
                        labelText: 'URL Image',
                        border: OutlineInputBorder(),
                        helperText: 'Cliquez sur "Uploader" ou collez une URL',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    onPressed: () async {
                      try {
                        // Sélectionner une image depuis le PC
                        final result = await FilePicker.platform.pickFiles(
                          type: FileType.image,
                          allowMultiple: false,
                        );

                        if (result != null && result.files.isNotEmpty) {
                          final file = result.files.first;
                          
                          // Afficher un indicateur de chargement
                          if (dialogContext.mounted) {
                            showDialog(
                              context: dialogContext,
                              barrierDismissible: false,
                              builder: (_) => const Center(
                                child: CircularProgressIndicator(),
                              ),
                            );
                          }

                          // Upload vers le backend
                          final dio = Dio();
                          final prefs = await SharedPreferences.getInstance();
                          final token = prefs.getString(StorageConstants.authToken);
                          
                          if (token == null) {
                            throw Exception('Token non disponible');
                          }
                          
                          final formData = FormData.fromMap({
                            'image': MultipartFile.fromBytes(
                              file.bytes!,
                              filename: file.name,
                            ),
                          });

                          final response = await dio.post(
                            'http://localhost:3000/api/products/upload-image',
                            data: formData,
                            options: Options(
                              headers: {
                                'Authorization': 'Bearer $token',
                              },
                            ),
                          );

                          // Fermer l'indicateur de chargement
                          if (dialogContext.mounted) {
                            Navigator.pop(dialogContext);
                          }

                          // Extraire l'URL de l'image uploadée
                          if (response.statusCode == 200) {
                            final uploadedImageUrl = response.data['data']['imageUrl'] as String?;
                            if (uploadedImageUrl != null) {
                              imageController.text = 'http://localhost:3000$uploadedImageUrl';
                            }
                            
                            if (dialogContext.mounted) {
                              ScaffoldMessenger.of(dialogContext).showSnackBar(
                                const SnackBar(content: Text('✅ Image uploadée avec succès')),
                              );
                            }
                          }
                        }
                      } catch (e) {
                        // Fermer l'indicateur si erreur
                        if (dialogContext.mounted && Navigator.canPop(dialogContext)) {
                          Navigator.pop(dialogContext);
                        }
                        if (dialogContext.mounted) {
                          ScaffoldMessenger.of(dialogContext).showSnackBar(
                            SnackBar(content: Text('❌ Erreur upload: $e')),
                          );
                        }
                      }
                    },
                    icon: const Icon(Icons.upload_file, size: 20),
                    label: const Text('Uploader'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
                    ),
                  ),
                ],
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
              final name = nameController.text;
              final price = double.tryParse(priceController.text) ?? 0;
              final stock = int.tryParse(stockController.text) ?? 0;
              final description = descriptionController.text;
              final imageUrl = imageController.text;

              if (name.isNotEmpty && price > 0) {
                if (product == null) {
                  context.read<ProductBloc>().add(ProductCreateRequested(
                        name: name,
                        price: price,
                        categoryId: 1,
                        stock: stock,
                        description: description.isEmpty ? 'Aucune description' : description,
                        imageUrl: imageUrl.isEmpty ? null : imageUrl,
                      ));
                } else {
                  context.read<ProductBloc>().add(ProductUpdateRequested(
                        id: product.id,
                        name: name,
                        price: price,
                        stock: stock,
                        description: description.isEmpty ? 'Aucune description' : description,
                        imageUrl: imageUrl.isEmpty ? null : imageUrl,
                      ));
                }
                Navigator.pop(dialogContext);
              }
            },
            child: Text(product == null ? 'Créer' : 'Modifier'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteProduct(BuildContext context, Product product) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Supprimer le produit'),
        content: Text('Voulez-vous vraiment supprimer "${product.name}" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              context.read<ProductBloc>().add(ProductDeleteRequested(product.id));
              Navigator.pop(dialogContext);
            },
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );
  }

  // ============== ORDERS TAB ==============
  Widget _buildOrdersTab() {
    return BlocBuilder<OrderBloc, OrderState>(
      builder: (context, state) {
        if (state is OrderLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (state is OrderError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text('Erreur: ${state.message}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    context.read<OrderBloc>().add(const AllOrdersLoadRequested());
                  },
                  child: const Text('Réessayer'),
                ),
              ],
            ),
          );
        }

        if (state is OrdersLoaded) {
          final orders = state.paginatedOrders.orders;

          if (orders.isEmpty) {
            return const Center(child: Text('Aucune commande'));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              return _buildOrderCard(context, order);
            },
          );
        }

        return const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Chargement des commandes...'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: _getStatusColor(order.status.name),
          child: Text('#${order.id}', style: const TextStyle(fontSize: 12)),
        ),
        title: Text('Commande #${order.id} - ${order.totalAmount.toStringAsFixed(2)} €'),
        subtitle: Text(
          '${DateFormat('dd/MM/yyyy HH:mm').format(order.createdAt)} - ${_getStatusLabel(order.status.name)}',
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Articles (${order.items?.length ?? 0}):',
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                ...(order.items ?? []).map((item) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(child: Text('${item.name} x${item.quantity}')),
                        Text('${(item.unitPrice * item.quantity).toStringAsFixed(2)} €'),
                      ],
                    ),
                  );
                }),
                const Divider(height: 24),
                Text('Changer le statut:', style: Theme.of(context).textTheme.titleSmall),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  children: [
                    _buildStatusChip(context, order, 'pending', 'En attente'),
                    _buildStatusChip(context, order, 'processing', 'En cours'),
                    _buildStatusChip(context, order, 'shipped', 'Expédiée'),
                    _buildStatusChip(context, order, 'delivered', 'Livrée'),
                    _buildStatusChip(context, order, 'cancelled', 'Annulée'),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip(BuildContext context, Order order, String status, String label) {
    final isSelected = order.status.name == status;
    return FilterChip(
      selected: isSelected,
      label: Text(label),
      backgroundColor: _getStatusColor(status).withValues(alpha: 0.1),
      selectedColor: _getStatusColor(status),
      labelStyle: TextStyle(
        color: isSelected ? Colors.white : Colors.black87,
        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
      ),
      onSelected: (selected) {
        if (selected && !isSelected) {
          context.read<OrderBloc>().add(OrderStatusUpdateRequested(
            id: order.id,
            status: status,
          ));
        }
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      case 'shipped':
        return Colors.purple;
      case 'delivered':
        return Colors.green;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'pending':
        return 'En attente';
      case 'processing':
        return 'En cours';
      case 'shipped':
        return 'Expédiée';
      case 'delivered':
        return 'Livrée';
      case 'cancelled':
        return 'Annulée';
      default:
        return status;
    }
  }
}

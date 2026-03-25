import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../../core/utils/format_utils.dart';
import '../../../domain/models/product.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import 'product_detail_screen.dart';
import 'product_search_delegate.dart';

/// Écran d'affichage de tous les produits
class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  final ScrollController _scrollController = ScrollController();
  int _currentPage = 1;
  List<Product> _allProducts = [];
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadProducts({
    String? search,
    int? categoryId,
    double? minPrice,
    double? maxPrice,
  }) {
    context.read<ProductBloc>().add(
          ProductsLoadRequested(
            page: _currentPage,
            search: search,
            categoryId: categoryId,
            minPrice: minPrice,
            maxPrice: maxPrice,
          ),
        );
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      if (_hasMore) {
        setState(() {
          _currentPage++;
        });
        _loadProducts();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Catalogue'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: ProductSearchDelegate(),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () => _showFilterDialog(context),
          ),
        ],
      ),
      body: BlocConsumer<ProductBloc, ProductState>(
        listener: (context, state) {
          if (state is ProductsLoaded) {
            setState(() {
              if (_currentPage == 1) {
                _allProducts = state.paginatedProducts.products;
              } else {
                _allProducts.addAll(state.paginatedProducts.products);
              }
              _hasMore = state.paginatedProducts.currentPage <
                  state.paginatedProducts.totalPages;
            });
          }
        },
        builder: (context, state) {
          if (state is ProductLoading && _currentPage == 1) {
            return const LoadingWidget();
          }

          if (state is ProductError && _allProducts.isEmpty) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () => _loadProducts(),
            );
          }

          if (_allProducts.isEmpty) {
            return const Center(
              child: Text('Aucun produit disponible'),
            );
          }

          return GridView.builder(
            controller: _scrollController,
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: _allProducts.length + (_hasMore ? 1 : 0),
            itemBuilder: (context, index) {
              if (index == _allProducts.length) {
                return const Center(child: CircularProgressIndicator());
              }

              final product = _allProducts[index];
              return ProductCard(product: product);
            },
          );
        },
      ),
    );
  }

  void _showFilterDialog(BuildContext context) {
    final minPriceController = TextEditingController();
    final maxPriceController = TextEditingController();

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Filtrer les produits'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: minPriceController,
              decoration: const InputDecoration(
                labelText: 'Prix minimum (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: maxPriceController,
              decoration: const InputDecoration(
                labelText: 'Prix maximum (€)',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              final minPrice = double.tryParse(minPriceController.text);
              final maxPrice = double.tryParse(maxPriceController.text);
              
              setState(() {
                _currentPage = 1;
                _allProducts = [];
              });
              
              _loadProducts(
                minPrice: minPrice,
                maxPrice: maxPrice,
              );
              
              Navigator.pop(dialogContext);
            },
            child: const Text('Appliquer'),
          ),
        ],
      ),
    );
  }
}

/// Widget carte produit
class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(productId: product.id),
            ),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: product.imageUrl != null
                        ? CachedNetworkImage(
                            imageUrl: product.imageUrl!,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => const Center(
                              child: CircularProgressIndicator(),
                            ),
                            errorWidget: (context, url, error) => const Icon(
                              Icons.image_not_supported,
                              size: 50,
                            ),
                          )
                        : const Icon(Icons.image, size: 50),
                  ),
                  // Badge stock faible
                  if (product.stockQuantity < 5)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'Stock bas',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
            
            // Informations
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      FormatUtils.formatPrice(product.price),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 4),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.read<CartBloc>().add(
                                CartItemAddRequested(
                                  productId: product.id,
                                  quantity: 1,
                                ),
                              );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Ajouté au panier'),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        icon: const Icon(Icons.add_shopping_cart, size: 16),
                        label: const Text('Ajouter', style: TextStyle(fontSize: 12)),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

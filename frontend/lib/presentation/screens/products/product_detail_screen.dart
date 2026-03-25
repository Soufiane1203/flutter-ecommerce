import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/product/product_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../widgets/loading_widget.dart';
import '../../widgets/error_widget.dart';
import '../../../core/utils/format_utils.dart';

/// Écran de détails d'un produit
class ProductDetailScreen extends StatefulWidget {
  final int productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int _quantity = 1;

  @override
  void initState() {
    super.initState();
    context.read<ProductBloc>().add(ProductByIdLoadRequested(widget.productId));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails du produit'),
      ),
      body: BlocBuilder<ProductBloc, ProductState>(
        builder: (context, state) {
          if (state is ProductLoading) {
            return const LoadingWidget();
          }

          if (state is ProductError) {
            return ErrorDisplayWidget(
              message: state.message,
              onRetry: () {
                context.read<ProductBloc>().add(
                      ProductByIdLoadRequested(widget.productId),
                    );
              },
            );
          }

          if (state is ProductDetailLoaded) {
            final product = state.product;

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Image
                  Container(
                    height: 300,
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: product.imageUrl != null
                        ? Image.network(
                            product.imageUrl!,
                            fit: BoxFit.cover,
                          )
                        : const Icon(Icons.image, size: 100),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Nom
                        Text(
                          product.name,
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                        const SizedBox(height: 8),

                        // Prix
                        Text(
                          FormatUtils.formatPrice(product.price),
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).primaryColor,
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Stock
                        Row(
                          children: [
                            Icon(
                              product.stockQuantity > 0
                                  ? Icons.check_circle
                                  : Icons.cancel,
                              color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              product.stockQuantity > 0
                                  ? '${product.stockQuantity} en stock'
                                  : 'Rupture de stock',
                              style: TextStyle(
                                color: product.stockQuantity > 0 ? Colors.green : Colors.red,
                              ),
                            ),
                          ],
                        ),
                        const Divider(height: 32),

                        // Description
                        Text(
                          'Description',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 8),
                        Text(product.description ?? 'Aucune description disponible'),
                        const SizedBox(height: 24),

                        // Sélecteur de quantité
                        Row(
                          children: [
                            const Text('Quantité: '),
                            IconButton(
                              onPressed: _quantity > 1
                                  ? () {
                                      setState(() {
                                        _quantity--;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.remove_circle_outline),
                            ),
                            Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            IconButton(
                              onPressed: _quantity < product.stockQuantity
                                  ? () {
                                      setState(() {
                                        _quantity++;
                                      });
                                    }
                                  : null,
                              icon: const Icon(Icons.add_circle_outline),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),

                        // Bouton ajouter au panier
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: product.stockQuantity > 0
                                ? () {
                                    context.read<CartBloc>().add(
                                          CartItemAddRequested(
                                            productId: product.id,
                                            quantity: _quantity,
                                          ),
                                        );
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                        content: Text('Ajouté au panier'),
                                      ),
                                    );
                                  }
                                : null,
                            icon: const Icon(Icons.add_shopping_cart),
                            label: const Text('Ajouter au panier'),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          }

          return const Center(child: Text('Produit non trouvé'));
        },
      ),
    );
  }
}

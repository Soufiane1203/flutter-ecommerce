import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/product.dart';
import '../../blocs/product/product_bloc.dart';

/// Délégué de recherche de produits
class ProductSearchDelegate extends SearchDelegate<Product?> {
  @override
  String get searchFieldLabel => 'Rechercher un produit...';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _searchProducts(context, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        if (snapshot.hasError) {
          return Center(child: Text('Erreur: ${snapshot.error}'));
        }
        
        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return const Center(child: Text('Aucun produit trouvé'));
        }
        
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              leading: const Icon(Icons.shopping_bag),
              title: Text(product.name),
              subtitle: Text('${product.price.toStringAsFixed(2)} €'),
              onTap: () => close(context, product),
            );
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Entrez un nom de produit'),
      );
    }

    return FutureBuilder<List<Product>>(
      future: _searchProducts(context, query),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final products = snapshot.data ?? [];
        
        if (products.isEmpty) {
          return const Center(child: Text('Aucune suggestion'));
        }
        
        return ListView.builder(
          itemCount: products.length,
          itemBuilder: (context, index) {
            final product = products[index];
            return ListTile(
              leading: const Icon(Icons.search),
              title: Text(product.name),
              subtitle: Text('${product.price.toStringAsFixed(2)} €'),
              onTap: () {
                query = product.name;
                showResults(context);
              },
            );
          },
        );
      },
    );
  }

  Future<List<Product>> _searchProducts(BuildContext context, String searchQuery) async {
    if (searchQuery.trim().isEmpty) {
      return [];
    }

    try {
      // Utiliser ProductBloc pour rechercher les produits
      final productBloc = context.read<ProductBloc>();
      
      // Charger les produits avec le filtre de recherche
      productBloc.add(ProductsLoadRequested(search: searchQuery.trim()));
      
      // Attendre que les produits soient chargés
      await Future.delayed(const Duration(milliseconds: 300));
      
      // Récupérer l'état actuel du bloc
      final state = productBloc.state;
      
      if (state is ProductsLoaded) {
        // Filtrer localement aussi pour une recherche plus précise
        final query = searchQuery.toLowerCase().trim();
        return state.paginatedProducts.products.where((product) {
          final name = product.name.toLowerCase();
          final brand = (product.brand ?? '').toLowerCase();
          return name.contains(query) || brand.contains(query);
        }).toList();
      }
      
      return [];
    } catch (e) {
      debugPrint('Error searching products: $e');
      return [];
    }
  }
}

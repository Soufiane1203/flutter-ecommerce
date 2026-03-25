import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../blocs/auth/auth_bloc.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/product/product_bloc.dart';
import '../products/products_screen.dart';
import '../cart/cart_screen.dart';
import '../orders/orders_screen.dart';
import '../profile/profile_screen.dart';
import '../admin/admin_dashboard_screen.dart';

/// Écran d'accueil principal avec navigation par onglets
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    // Charger les produits au démarrage
    context.read<ProductBloc>().add(const ProductsLoadRequested());
    // Charger le panier
    context.read<CartBloc>().add(CartLoadRequested());
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, authState) {
        final isAdmin = authState is Authenticated && authState.user.isAdmin;

        // Liste des écrans (User)
        final List<Widget> userScreens = [
          const ProductsScreen(),
          const CartScreen(),
          const OrdersScreen(),
          const ProfileScreen(),
        ];

        // Liste des écrans (Admin)
        final List<Widget> adminScreens = [
          const ProductsScreen(),
          const AdminDashboardScreen(),
          const ProfileScreen(),
        ];

        final screens = isAdmin ? adminScreens : userScreens;

        return Scaffold(
          body: IndexedStack(
            index: _currentIndex,
            children: screens,
          ),
          bottomNavigationBar: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) {
              setState(() {
                _currentIndex = index;
              });
            },
            type: BottomNavigationBarType.fixed,
            selectedItemColor: Theme.of(context).primaryColor,
            unselectedItemColor: Colors.grey,
            items: isAdmin
                ? const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.store),
                      label: 'Produits',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.admin_panel_settings),
                      label: 'Admin',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profil',
                    ),
                  ]
                : const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.store),
                      label: 'Catalogue',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.shopping_cart),
                      label: 'Panier',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.receipt_long),
                      label: 'Commandes',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Profil',
                    ),
                  ],
          ),
        );
      },
    );
  }
}

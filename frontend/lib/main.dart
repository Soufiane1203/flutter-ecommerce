import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Import des constantes et thème
import 'core/theme/app_theme.dart';
import 'core/constants/storage_constants.dart';

// Import des services
import 'data/services/api_service.dart';
import 'data/services/auth_service.dart';
import 'data/services/product_service.dart';
import 'data/services/cart_service.dart';
import 'data/services/order_service.dart';

// Import des BLoCs
import 'presentation/blocs/auth/auth_bloc.dart';
import 'presentation/blocs/product/product_bloc.dart';
import 'presentation/blocs/cart/cart_bloc.dart';
import 'presentation/blocs/order/order_bloc.dart';

// Import des écrans
import 'presentation/screens/splash/splash_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialisation asynchrone de SharedPreferences
  SharedPreferences.getInstance().then((prefs) {
    runApp(MyApp(prefs: prefs));
  }).catchError((error) {
    debugPrint('❌ SharedPreferences error: $error');
    // En cas d'erreur, lancer l'app avec un délai
    Future.delayed(const Duration(milliseconds: 100), () async {
      final prefs = await SharedPreferences.getInstance();
      runApp(MyApp(prefs: prefs));
    });
  });
}

class MyApp extends StatelessWidget {
  final SharedPreferences prefs;

  const MyApp({super.key, required this.prefs});

  @override
  Widget build(BuildContext context) {
    // Initialiser les services
    final apiService = ApiService(prefs);
    final authService = AuthService(apiService, prefs);
    final productService = ProductService(apiService);
    final cartService = CartService(apiService);
    final orderService = OrderService(apiService);
    
    // Récupérer le thème sauvegardé
    final isDarkMode = prefs.getBool(StorageConstants.isDarkMode) ?? false;

    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authService),
        RepositoryProvider.value(value: productService),
        RepositoryProvider.value(value: cartService),
        RepositoryProvider.value(value: orderService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(create: (context) => AuthBloc(authService)..add(AuthCheckRequested())),
          BlocProvider(create: (context) => ProductBloc(productService)),
          BlocProvider(create: (context) => CartBloc(cartService)),
          BlocProvider(create: (context) => OrderBloc(orderService)),
        ],
        child: MaterialApp(
          title: 'E-commerce App',
          debugShowCheckedModeBanner: false,
          
          // Thème
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: isDarkMode ? ThemeMode.dark : ThemeMode.light,
          
          // Page d'accueil avec le vrai SplashScreen qui gère la navigation
          home: const SplashScreen(),
        ),
      ),
    );
  }
}

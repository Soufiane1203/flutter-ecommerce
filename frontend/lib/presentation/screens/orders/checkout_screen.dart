import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import '../../../domain/models/cart.dart';
import '../../blocs/order/order_bloc.dart';
import '../orders/orders_screen.dart';

/// Écran de checkout (création commande)
class CheckoutScreen extends StatefulWidget {
  final Cart cart;
  
  const CheckoutScreen({super.key, required this.cart});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void dispose() {
    _addressController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _handleCheckout() {
    if (_formKey.currentState!.validate()) {
      context.read<OrderBloc>().add(
            OrderCreateRequested(
              shippingAddress: _addressController.text.trim(),
              phone: _phoneController.text.trim(),
              notes: _notesController.text.trim().isEmpty 
                  ? null 
                  : _notesController.text.trim(),
            ),
          );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finaliser la commande'),
      ),
      body: BlocConsumer<OrderBloc, OrderState>(
        listener: (context, state) {
          if (state is OrderCreated) {
            Fluttertoast.showToast(
              msg: 'Commande créée avec succès!',
              backgroundColor: Colors.green,
            );
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const OrdersScreen()),
            );
          } else if (state is OrderError) {
            Fluttertoast.showToast(
              msg: state.message,
              backgroundColor: Colors.red,
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is OrderLoading;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Résumé panier
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Résumé de votre commande',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 12),
                          Text('${widget.cart.itemCount} article(s)'),
                          const SizedBox(height: 8),
                          Text(
                            'Total: ${widget.cart.total.toStringAsFixed(2)} €',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Formulaire d'adresse
                  Text(
                    'Informations de livraison',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _addressController,
                    enabled: !isLoading,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Adresse de livraison *',
                      hintText: 'Numéro, rue, ville, code postal...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.location_on),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Adresse requise';
                      }
                      if (value.trim().length < 10) {
                        return 'Adresse trop courte';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _phoneController,
                    enabled: !isLoading,
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      labelText: 'Téléphone *',
                      hintText: '+33 6 12 34 56 78',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.phone),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Téléphone requis';
                      }
                      if (value.trim().length < 10) {
                        return 'Numéro invalide';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _notesController,
                    enabled: !isLoading,
                    maxLines: 2,
                    decoration: const InputDecoration(
                      labelText: 'Instructions spéciales (optionnel)',
                      hintText: 'Code porte, étage, commentaires...',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.note),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Bouton valider
                  ElevatedButton(
                    onPressed: isLoading ? null : _handleCheckout,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Confirmer la commande (${widget.cart.total.toStringAsFixed(2)} €)',
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                          ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

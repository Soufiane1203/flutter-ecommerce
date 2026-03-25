import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/models/cart.dart';
import '../../blocs/cart/cart_bloc.dart';
import '../../blocs/order/order_bloc.dart';

/// Écran de paiement et confirmation de commande
class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _phoneController = TextEditingController();
  final _notesController = TextEditingController();

  String _paymentMethod = 'cash'; // Seul mode disponible pour l'instant
  bool _saveAddress = true;

  @override
  void dispose() {
    _addressController.dispose();
    _cityController.dispose();
    _postalCodeController.dispose();
    _phoneController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Finaliser la commande'),
      ),
      body: BlocListener<OrderBloc, OrderState>(
        listener: (context, state) {
          debugPrint('🎯 CHECKOUT LISTENER: State changed to ${state.runtimeType}');
          
          if (state is OrderCreated) {
            debugPrint('✅ CHECKOUT: Order created successfully, ID: ${state.order.id}');
            
            // Recharger le panier (déjà vidé par le backend)
            context.read<CartBloc>().add(CartLoadRequested());
            
            // Succès - Afficher message et rediriger
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Commande créée avec succès ! Visible dans "Mes commandes"'),
                backgroundColor: Colors.green,
                duration: Duration(seconds: 3),
              ),
            );
            
            // Retour à l'écran principal
            Navigator.of(context).popUntil((route) => route.isFirst);
          } else if (state is OrderError) {
            debugPrint('❌ CHECKOUT: Order error: ${state.message}');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('❌ Erreur: ${state.message}'),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
              ),
            );
          } else if (state is OrderLoading) {
            debugPrint('⏳ CHECKOUT: Order loading...');
          }
        },
        child: BlocBuilder<CartBloc, CartState>(
          builder: (context, cartState) {
            if (cartState is! CartLoaded || cartState.cart.items.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.shopping_cart_outlined, size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    const Text('Votre panier est vide'),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Retour aux produits'),
                    ),
                  ],
                ),
              );
            }

            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionTitle(context, '📍 Adresse de livraison'),
                    const SizedBox(height: 16),
                    _buildAddressForm(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, '💳 Mode de paiement'),
                    const SizedBox(height: 16),
                    _buildPaymentMethods(),
                    const SizedBox(height: 24),
                    _buildSectionTitle(context, '📦 Résumé de la commande'),
                    const SizedBox(height: 16),
                    _buildOrderSummary(cartState.cart),
                    const SizedBox(height: 24),
                    _buildTotalSection(cartState.cart),
                    const SizedBox(height: 24),
                    BlocBuilder<OrderBloc, OrderState>(
                      builder: (context, orderState) {
                        final isLoading = orderState is OrderLoading;
                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : _confirmOrder,
                            child: isLoading
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                : const Text(
                                    'Confirmer la commande',
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
    );
  }

  Widget _buildAddressForm() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Adresse *',
                hintText: '123 Rue de la République',
                prefixIcon: Icon(Icons.home),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Veuillez entrer votre adresse';
                }
                if (value.length < 5) {
                  return 'Adresse trop courte';
                }
                return null;
              },
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    controller: _cityController,
                    decoration: const InputDecoration(
                      labelText: 'Ville *',
                      hintText: 'Paris',
                      prefixIcon: Icon(Icons.location_city),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _postalCodeController,
                    decoration: const InputDecoration(
                      labelText: 'Code postal *',
                      hintText: '75001',
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Requis';
                      }
                      if (value.length != 5) {
                        return 'Code postal invalide';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: const InputDecoration(
                labelText: 'Téléphone *',
                hintText: '06 12 34 56 78',
                prefixIcon: Icon(Icons.phone),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Téléphone requis';
                }
                // Validation flexible : au moins 8 chiffres
                final digitsOnly = value.replaceAll(RegExp(r'\D'), '');
                if (digitsOnly.length < 8) {
                  return 'Numéro trop court (min 8 chiffres)';
                }
                return null;
              },
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (optionnel)',
                hintText: 'Instructions de livraison...',
                prefixIcon: Icon(Icons.note),
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            CheckboxListTile(
              value: _saveAddress,
              onChanged: (value) => setState(() => _saveAddress = value ?? true),
              title: const Text('Enregistrer cette adresse pour mes prochaines commandes'),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPaymentMethods() {
    return Card(
      child: Column(
        children: [
          ListTile(
            leading: Icon(
              _paymentMethod == 'card' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: Colors.grey,
            ),
            title: const Text('Carte bancaire'),
            subtitle: const Text('🕒 Bientôt disponible'),
            trailing: const Icon(Icons.credit_card, color: Colors.grey),
            enabled: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🕒 Carte bancaire sera disponible prochainement'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              _paymentMethod == 'paypal' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: Colors.grey,
            ),
            title: const Text('PayPal'),
            subtitle: const Text('🕒 Bientôt disponible'),
            trailing: const Icon(Icons.paypal, color: Colors.grey),
            enabled: false,
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('🕒 PayPal sera disponible prochainement'),
                  duration: Duration(seconds: 2),
                ),
              );
            },
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(
              _paymentMethod == 'cash' ? Icons.radio_button_checked : Icons.radio_button_unchecked,
              color: _paymentMethod == 'cash' ? Theme.of(context).primaryColor : null,
            ),
            title: const Text('Paiement à la livraison'),
            subtitle: const Text('✅ Espèces ou carte à la réception'),
            trailing: const Icon(Icons.local_shipping),
            onTap: () => setState(() => _paymentMethod = 'cash'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderSummary(Cart cart) {
    return Card(
      child: ListView.separated(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        itemCount: cart.items.length,
        separatorBuilder: (context, index) => const Divider(height: 24),
        itemBuilder: (context, index) {
          final item = cart.items[index];
          return Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                ),
                child: item.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          item.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.image),
                        ),
                      )
                    : const Icon(Icons.image),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      item.name,
                      style: Theme.of(context).textTheme.titleSmall,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Quantité: ${item.quantity}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ],
                ),
              ),
              Text(
                '${(item.price * item.quantity).toStringAsFixed(2)} €',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildTotalSection(Cart cart) {
    final subtotal = cart.items.fold<double>(
      0,
      (sum, item) => sum + (item.price * item.quantity),
    );
    final shipping = subtotal > 50 ? 0.0 : 5.99;
    final total = subtotal + shipping;

    return Card(
      color: Theme.of(context).colorScheme.primaryContainer,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildTotalRow('Sous-total', '${subtotal.toStringAsFixed(2)} €'),
            const SizedBox(height: 8),
            _buildTotalRow('Frais de livraison', shipping == 0 ? 'GRATUIT' : '${shipping.toStringAsFixed(2)} €'),
            if (subtotal < 50) ...[
              const SizedBox(height: 4),
              Text(
                'Livraison gratuite dès 50€ d\'achat',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.orange[700],
                      fontStyle: FontStyle.italic,
                    ),
              ),
            ],
            const Divider(height: 24),
            _buildTotalRow(
              'Total',
              '${total.toStringAsFixed(2)} €',
              isTotal: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, {bool isTotal = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)
              : Theme.of(context).textTheme.titleMedium,
        ),
        Text(
          value,
          style: isTotal
              ? Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.primary,
                  )
              : Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  void _confirmOrder() {
    if (_formKey.currentState!.validate()) {
      // Vérifier que seul 'cash' est autorisé
      if (_paymentMethod != 'cash') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('⚠️ Seul le paiement à la livraison est disponible actuellement'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }

      final shippingAddress = '${_addressController.text}, '
          '${_postalCodeController.text} ${_cityController.text}';

      final notes = _notesController.text.isNotEmpty
          ? '${_notesController.text}\nPaiement: Paiement à la livraison'
          : 'Paiement: Paiement à la livraison';

      context.read<OrderBloc>().add(OrderCreateRequested(
            shippingAddress: shippingAddress,
            phone: _phoneController.text.trim(),
            notes: notes,
          ));
    }
  }
}

import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/api/address_api.dart';
import 'package:shop/services/api/cart_api.dart';
import 'package:shop/services/api/card_api.dart';
import 'package:shop/services/api/order_api.dart';
import 'package:shop/services/api/payment_api.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/screens/order/views/components/address_section.dart';
import 'package:shop/screens/order/views/components/products_section.dart';
import 'package:shop/screens/order/views/components/payment_section.dart';
import 'package:shop/screens/order/views/components/total_section.dart';
import 'package:shop/screens/order/views/components/premium_badge.dart';
import 'package:shop/screens/order/views/components/error_section.dart';
import 'package:shop/services/api/send_mail_api.dart';

class OrderDetailsScreen extends StatefulWidget {
  const OrderDetailsScreen({super.key});

  @override
  State<OrderDetailsScreen> createState() => _OrderDetailsScreenState();
}

class _OrderDetailsScreenState extends State<OrderDetailsScreen> {
  List<Map<String, dynamic>> _addresses = [];
  List<Map<String, dynamic>> _cartProducts = [];
  List<Map<String, dynamic>> _cards = [];
  int? _selectedAddressIndex;
  int? _selectedCardIndex;
  String? _selectedProductId;
  double _subTotal = 0;
  double _tva = 0;
  double _livraison = 0;
  double _remise = 0;
  double _total = 0;
  bool _isLoadingPayment = false;
  bool _showSuccess = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCheckoutData();
  }

  Future<void> _loadCheckoutData() async {
    try {
      // Chargement des adresses
      final addresses = await fetchUserAddresses();
      // Chargement des produits du panier
      final cartProducts = await fetchCartItems();
      // Chargement des cartes bancaires
      final cards = await fetchUserCards();

      // Sélection par défaut
      int? selectedAddressIndex;
      if (addresses.isNotEmpty) {
        selectedAddressIndex = addresses.indexWhere((a) => a['par_defaut'] == 1);
        if (selectedAddressIndex == -1) selectedAddressIndex = 0;
      }
      int? selectedCardIndex;
      if (cards.isNotEmpty) {
        selectedCardIndex = cards.indexWhere((c) => c['par_defaut'] == 1);
        if (selectedCardIndex == -1) selectedCardIndex = 0;
      }

      // Calcul des totaux
      double subTotal = cartProducts.fold<double>(0, (sum, p) {
        double prix = 0;
        if (p['prix_promo'] != null && p['prix_promo'] > 0 && p['prix'] != null && p['prix_promo'] < p['prix']) {
          prix = (p['prix_promo'] as num).toDouble();
        } else if (p['prix'] != null) {
          prix = (p['prix'] as num).toDouble();
        }
        final qte = p['quantity'] ?? p['quantite'] ?? 1;
        return sum + (prix * (qte is num ? qte.toDouble() : double.tryParse(qte.toString()) ?? 1));
      });
      double tva = subTotal * 0.2;
      double livraison = 4.99;
      double remise = 0;
      double total = subTotal + tva + livraison - remise;

      setState(() {
        _addresses = addresses;
        _cartProducts = cartProducts;
        _cards = cards;
        _selectedAddressIndex = selectedAddressIndex;
        _selectedCardIndex = selectedCardIndex;
        _subTotal = subTotal;
        _tva = tva;
        _livraison = livraison;
        _remise = remise;
        _total = total;
      });
    } catch (e) {
      setState(() => _error = e.toString());
    }
  }

  Future<void> _payWithSelectedCard() async {
    setState(() => _isLoadingPayment = true);
    try {
      // 1. Créer la commande (order_api)
      if (_selectedAddressIndex == null || _selectedCardIndex == null || _cartProducts.isEmpty) {
        setState(() {
          _error = "Veuillez sélectionner une adresse, une carte et avoir des produits dans le panier.";
        });
        return;
      }
      final addressId = _addresses[_selectedAddressIndex!]['id'];
      final card = _cards[_selectedCardIndex!];
      final cardId = card['id'];
      final paymentMethodId = card['stripe_payment_method_id'];
      final products = _cartProducts;
      final orderError = await placeOrder(addressId: addressId, cardId: cardId, products: products);
      if (orderError != null) {
        setState(() {
          _error = orderError;
        });
        return;
      }

      // 2. Récupérer l'id et le montant de la commande (payment_api)
      final orderResult = await placeOrderAndGetTotal();
      if (orderResult == null || orderResult['id'] == null || orderResult['montant_total'] == null) {
        setState(() {
          _error = 'Erreur lors de la récupération du montant de la commande.';
        });
        return;
      }
      final commandeId = orderResult['id'].toString();
      final montant = orderResult['montant_total'];

      // 3. Créer le PaymentIntent Stripe (payment_api)
      final paymentIntentResult = await createPaymentIntent(
        montant,
        commandeId,
        paymentMethodId: paymentMethodId, // Named parameter with curly braces
      );
      if (paymentIntentResult == null || paymentIntentResult['clientSecret'] == null || paymentIntentResult['paymentIntentId'] == null) {
        setState(() {
          _error = 'Erreur lors de la création du paiement Stripe.';
        });
        return;
      }
      final clientSecret = paymentIntentResult['clientSecret'];
      final paymentIntentId = paymentIntentResult['paymentIntentId'];

      // 4. Confirmer le paiement Stripe
      String paymentStatus = 'failed';
      try {
        if (paymentMethodId != null && paymentMethodId.toString().isNotEmpty) {
          // Use existing payment method
          final paymentResult = await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: clientSecret,
            data: PaymentMethodParams.cardFromMethodId(
              paymentMethodData: PaymentMethodDataCardFromMethod(
                paymentMethodId: paymentMethodId,
              ),
            ),
          );
          print('Stripe paymentResult: \n${paymentResult.toJson()}');
          paymentStatus = paymentResult.status?.toString() ?? 'failed';
        } else {
          // Collect new card details
          final paymentResult = await Stripe.instance.confirmPayment(
            paymentIntentClientSecret: clientSecret,
            data: const PaymentMethodParams.card(
              paymentMethodData: PaymentMethodData(),
            ),
          );
          paymentStatus = paymentResult.status?.toString() ?? 'failed';
        }
      } catch (e) {
        paymentStatus = 'failed';
        setState(() => _error = 'Erreur de paiement: ${e.toString()}');
      }

      // 5. Mettre à jour le statut du paiement (payment_api)
      final updateResponse = await updatePaymentStatus(paymentIntentId, paymentStatus, commandeId);

      // 6. Vérifier le statut du paiement retourné par le backend
      if (updateResponse != null && updateResponse['statut'] == 'succeeded') {
        setState(() {
          _showSuccess = true;
          _error = null;
        });
        await emptyCart();
        Future.delayed(const Duration(milliseconds: 1500), () {
          if (mounted) {
            setState(() => _showSuccess = false);
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (_) => const SuccessOrderScreen()),
            );
          } else {
            _showSuccess = false;
          }
        });
      } else {
        setState(() {
          _error = 'Paiement refusé.';
          _showSuccess = false;
        });
      }
    } catch (e) {
      setState(() => _error = e.toString());
    } finally {
      setState(() => _isLoadingPayment = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Détails de la commande'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AddressSection(
                  addresses: _addresses,
                  selectedAddressIndex: _selectedAddressIndex,
                  onSelectAddress: (i) => setState(() => _selectedAddressIndex = i),
                  onManageAddresses: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: const DeliveryAddressScreen(),
                      ),
                    );
                    _loadCheckoutData();
                  },
                ),
                ProductsSection(
                  cartProducts: _cartProducts,
                  onSelectProduct: (id) => setState(() => _selectedProductId = id),
                  onRemoveFromCart: (id) async {
                    await removeFromCart(id);
                    _loadCheckoutData();
                  },
                ),
                PaymentSection(
                  cards: _cards,
                  selectedCardIndex: _selectedCardIndex,
                  onSelectCard: (i) => setState(() => _selectedCardIndex = i),
                  onAddCard: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: const PaymentDetailsScreen(),
                      ),
                    );
                    _loadCheckoutData();
                  },
                  onManageCards: () async {
                    await showModalBottomSheet(
                      context: context,
                      isScrollControlled: true,
                      shape: const RoundedRectangleBorder(
                        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
                      ),
                      builder: (context) => SizedBox(
                        height: MediaQuery.of(context).size.height * 0.85,
                        child: const PaymentDetailsScreen(),
                      ),
                    );
                    _loadCheckoutData();
                  },
                ),
                TotalSection(
                  subTotal: _subTotal,
                  tva: _tva,
                  livraison: _livraison,
                  remise: _remise,
                  total: _total,
                  isLoadingPayment: _isLoadingPayment,
                  onCommander: _payWithSelectedCard,
                  isCommanderEnabled: _cartProducts.isNotEmpty &&
                      _selectedAddressIndex != null &&
                      _selectedCardIndex != null,
                ),
                const PremiumBadge(),
                if (_error != null) ErrorSection(error: _error!),
              ],
            ),
          ),
          if (_showSuccess)
            Container(
              color: Colors.white.withOpacity(0.85),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: const [
                    Icon(Icons.check_circle, color: Colors.green, size: 80),
                    SizedBox(height: 18),
                    Text(
                      'Paiement validé !',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
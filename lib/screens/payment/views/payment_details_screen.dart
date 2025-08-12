import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/api/card_api.dart';
import 'package:flutter_stripe/flutter_stripe.dart' as stripe;

/// Permet d'enregistrer une carte bancaire pour paiement rapide (utilisée dans PaymentScreen)
class PaymentDetailsScreen extends StatefulWidget {
  const PaymentDetailsScreen({super.key});

  @override
  State<PaymentDetailsScreen> createState() => _PaymentDetailsScreenState();
}

class _PaymentDetailsScreenState extends State<PaymentDetailsScreen> {
  // Ajout d'un bouton flottant pour ajouter une carte à tout moment
  Widget _buildFloatingActionButton() {
    return FloatingActionButton(
      onPressed: () => _showAddCardForm(),
      child: const Icon(Icons.add),
      tooltip: 'Ajouter une carte',
    );
  }
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  stripe.CardFieldInputDetails? _cardFieldInput;
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _showForm = false;
  String? _error;
  List<Map<String, dynamic>> cards = [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() => _isLoadingData = true);
    final fetched = await fetchUserCards();
    setState(() {
      cards = fetched;
      _showForm = fetched.isEmpty;
      _isLoadingData = false;
    });
  }

  void _showAddCardForm({bool forceDefault = false}) {
    setState(() {
      _showForm = true;
      _error = null;
    });
    nomController.clear();
    _cardFieldInput = null;
    _addAsDefault = forceDefault;
  }
  bool _addAsDefault = false;

  void _hideForm() {
    setState(() {
      _showForm = false;
      _error = null;
    });
    nomController.clear();
    _cardFieldInput = null;
  }

  Future<void> _saveCard() async {
    if (!_formKey.currentState!.validate() || _cardFieldInput == null || !_cardFieldInput!.complete) {
      setState(() => _error = 'Veuillez remplir tous les champs de la carte');
      return;
    }

    setState(() => _isLoading = true);
    try {
      final paymentMethod = await stripe.Stripe.instance.createPaymentMethod(
        params: stripe.PaymentMethodParams.card(
          paymentMethodData: stripe.PaymentMethodData(
            billingDetails: stripe.BillingDetails(name: nomController.text),
          ),
        ),
      );

      final card = paymentMethod.card;
      final cardData = {
        'stripe_payment_method_id': paymentMethod.id,
        'last4': card?.last4,
        'exp_month': card?.expMonth,
        'exp_year': card?.expYear,
        'par_defaut': _addAsDefault ? 1 : 0,
        'nom': nomController.text,
      };

      final err = await addUserCard(cardData);
      if (err == null) {
        await _loadCards();
        _hideForm();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carte enregistrée !'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $err'), backgroundColor: Colors.red),
        );
      }
    } catch (e) {
      setState(() => _error = e.toString());
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e'), backgroundColor: Colors.red),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _deleteCard(int index) async {
    final cardId = cards[index]['id'];
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Supprimer la carte', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette carte ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Supprimer', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      final err = await deleteUserCard(cardId);
      if (err == null) {
        await _loadCards();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Carte supprimée'), backgroundColor: Colors.green),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $err'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _setDefaultCard(int index) async {
    final cardId = cards[index]['id'];
    final err = await setDefaultCard(cardId);
    if (err == null) {
      await _loadCards();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $err'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text('Mes cartes'),
        titleTextStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22, color: Colors.black),
        iconTheme: const IconThemeData(color: Colors.black),
        leading: _showForm
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: _hideForm,
              )
            : null,
        actions: [
          if (cards.isNotEmpty && !_showForm)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showAddCardForm,
              tooltip: 'Nouvelle carte',
            ),
        ],
      ),
      body: _isLoadingData
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!_showForm && cards.isNotEmpty) ...[
              Text(
                'Mes cartes (${cards.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: defaultPadding),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(begin: const Offset(0.1, 0), end: Offset.zero).animate(animation),
                    child: FadeTransition(opacity: animation, child: child),
                  );
                },
                child: Column(
                  key: ValueKey(cards.map((c) => c['id']).join(',')),
                  children: [
                    ...cards.asMap().entries.map((entry) {
                      final i = entry.key;
                      final card = entry.value;
                      final isDefault = card['par_defaut'] == 1;
                      return Card(
                        elevation: 5,
                        margin: const EdgeInsets.only(bottom: defaultPadding),
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: isDefault ? BorderSide(color: primaryColor, width: 2) : BorderSide.none,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24),
                          child: Row(
                            children: [
                              Icon(Icons.credit_card, color: isDefault ? primaryColor : Colors.grey, size: 32),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('**** ${card['last4']}', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 18)),
                                    const SizedBox(height: 4),
                                    Text('Exp: ${card['exp_month']}/${card['exp_year']}', style: TextStyle(color: Colors.grey[700], fontSize: 15)),
                                    if (card['nom'] != null && card['nom'].toString().isNotEmpty)
                                      Text(card['nom'], style: const TextStyle(color: Colors.black87, fontSize: 14)),
                                  ],
                                ),
                              ),
                              if (isDefault)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                                  decoration: BoxDecoration(
                                    color: primaryColor,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: const Text('PAR DÉFAUT', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              if (!isDefault)
                                TextButton(
                                  onPressed: () => _setDefaultCard(i),
                                  child: const Text('Par défaut'),
                                ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteCard(i),
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ],
            if (_showForm) ...[
              Card(
                elevation: 8,
                margin: const EdgeInsets.only(bottom: defaultPadding),
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Ajouter une carte', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 18),
                        TextFormField(
                          controller: nomController,
                          decoration: const InputDecoration(
                            labelText: 'Nom sur la carte',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.person),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          validator: (value) => value == null || value.isEmpty ? 'Champ requis' : null,
                        ),
                        const SizedBox(height: 16),
                        stripe.CardField(
                          onCardChanged: (card) => setState(() => _cardFieldInput = card),
                          decoration: const InputDecoration(
                            border: OutlineInputBorder(),
                            labelText: 'Détails de la carte',
                            prefixIcon: Icon(Icons.credit_card),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                          style: const TextStyle(fontSize: 18),
                        ),
                        Row(
                          children: [
                            Checkbox(
                              value: _addAsDefault,
                              onChanged: (v) => setState(() => _addAsDefault = v ?? false),
                            ),
                            const Text('Définir comme carte par défaut'),
                          ],
                        ),
                        if (_error != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: Text(_error!, style: const TextStyle(color: Colors.red)),
                          ),
                        const SizedBox(height: 18),
                        _isLoading
                            ? const Center(child: CircularProgressIndicator())
                            : Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                icon: const Icon(Icons.save),
                                onPressed: _saveCard,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: primaryColor,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                label: const Text('Enregistrer'),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: OutlinedButton.icon(
                                icon: const Icon(Icons.close),
                                onPressed: _hideForm,
                                style: OutlinedButton.styleFrom(
                                  padding: const EdgeInsets.symmetric(vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                label: const Text('Annuler'),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
            if (!_showForm) ...[
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Column(
                  children: [
                    if (cards.isEmpty) ...[
                      const Icon(Icons.credit_card_off, size: 48, color: Colors.grey),
                      const SizedBox(height: 12),
                      const Text('Aucune carte enregistrée', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      const Text('Ajoutez une carte pour faciliter vos paiements.', style: TextStyle(fontSize: 14, color: Colors.grey)),
                    ],
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _showAddCardForm(),
                      icon: const Icon(Icons.add),
                      label: const Text('Ajouter une carte'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: primaryColor,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 32),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

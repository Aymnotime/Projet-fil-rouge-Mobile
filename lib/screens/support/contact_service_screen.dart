import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class ContactServiceScreen extends StatefulWidget {
  const ContactServiceScreen({super.key});

  @override
  State<ContactServiceScreen> createState() => _ContactServiceScreenState();
}

class _ContactServiceScreenState extends State<ContactServiceScreen> {
  final _formKey = GlobalKey<FormState>();
  String? _name, _email, _message, _requestType;
  bool _sending = false;

  void _sendContact() async {
    if (!_formKey.currentState!.validate()) return;
    _formKey.currentState!.save();
    setState(() => _sending = true);
    await Future.delayed(const Duration(seconds: 2)); // Simule l'envoi
    setState(() => _sending = false);
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.blueAccent.withOpacity(0.12),
                  shape: BoxShape.circle,
                ),
                padding: const EdgeInsets.all(16),
                child: const Icon(Icons.check_circle_outline, color: Colors.blueAccent, size: 48),
              ),
              const SizedBox(height: 18),
              Text(
                'Message envoyé !',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 22,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Votre demande a bien été transmise à notre équipe support. Nous vous répondrons sous 24h à l'adresse indiquée.",
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, color: Colors.black87, height: 1.4),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    minimumSize: const Size.fromHeight(44),
                  ),
                  child: const Text('Fermer', style: TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
    _formKey.currentState!.reset();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: Row(
          children: [
            Container(
              decoration: BoxDecoration(
                color: Colors.blueAccent.withOpacity(0.12),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.all(6),
              child: const Icon(Icons.support_agent, color: Colors.blueAccent, size: 28),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'Support Technoshop',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 20,
                  letterSpacing: 0.2,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 8),
                child: Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
                  color: Colors.white,
                  margin: const EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.email_rounded, color: Colors.blueAccent, size: 26),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Formulaire de contact',
                              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).primaryColor,
                                fontSize: 22,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          width: double.infinity,
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blueAccent.withOpacity(0.06),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.info_outline, color: Colors.blueAccent, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Notre équipe support est disponible 7j/7 pour répondre à vos questions et résoudre vos problèmes. Remplissez le formulaire ci-dessous, nous vous répondrons sous 24h.",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                width: double.infinity,
                                child: Container(
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: Colors.grey.shade300, width: 1.2),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                  child: DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: 'Type de demande',
                                      prefixIcon: const Icon(Icons.category_outlined),
                                      border: InputBorder.none,
                                      contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 0),
                                      labelStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    dropdownColor: Colors.white,
                                    value: _requestType,
                                    isExpanded: true,
                                    items: const [
                                      DropdownMenuItem(value: 'Commande', child: Text('Commande')),
                                      DropdownMenuItem(value: 'Paiement', child: Text('Paiement')),
                                      DropdownMenuItem(value: 'Livraison', child: Text('Livraison')),
                                      DropdownMenuItem(value: 'Retour/SAV', child: Text('Retour / SAV')),
                                      DropdownMenuItem(value: 'Compte', child: Text('Compte')),
                                      DropdownMenuItem(value: 'Technique', child: Text('Problème technique')),
                                      DropdownMenuItem(value: 'Autre', child: Text('Autre')),
                                    ],
                                    onChanged: (v) => setState(() => _requestType = v),
                                    validator: (v) => v == null || v.isEmpty ? 'Sélectionnez un type de demande' : null,
                                    onSaved: (v) => _requestType = v,
                                    icon: const Icon(Icons.arrow_drop_down_rounded, color: Colors.blueAccent),
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Nom',
                                  prefixIcon: const Icon(Icons.person_outline),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                validator: (v) => v == null || v.isEmpty ? 'Champ obligatoire' : null,
                                onSaved: (v) => _name = v,
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Email',
                                  prefixIcon: const Icon(Icons.email_outlined),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                validator: (v) => v == null || !v.contains('@') ? 'Email invalide' : null,
                                onSaved: (v) => _email = v,
                              ),
                              const SizedBox(height: 18),
                              TextFormField(
                                decoration: InputDecoration(
                                  labelText: 'Message',
                                  prefixIcon: const Icon(Icons.message_outlined),
                                  filled: true,
                                  fillColor: Colors.grey[50],
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
                                ),
                                maxLines: 5,
                                validator: (v) => v == null || v.isEmpty ? 'Champ obligatoire' : null,
                                onSaved: (v) => _message = v,
                              ),
                              const SizedBox(height: 28),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  onPressed: _sending ? null : _sendContact,
                                  style: ElevatedButton.styleFrom(
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                    backgroundColor: Theme.of(context).primaryColor,
                                    elevation: 2,
                                  ),
                                  child: _sending
                                      ? Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      ),
                                      const SizedBox(width: 12),
                                      const Text('Envoi...', style: TextStyle(fontSize: 16)),
                                    ],
                                  )
                                      : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.send, size: 20),
                                      const SizedBox(width: 10),
                                      const Text('Envoyer', style: TextStyle(fontSize: 16)),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

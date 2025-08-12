import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  final List<Map<String, String>> faqs = const [
    {
      'question': 'Comment passer une commande ?',
      'answer': 'Sélectionnez vos produits, ajoutez-les au panier puis validez votre commande depuis la page Panier.'
    },
    {
      'question': 'Quels sont les moyens de paiement acceptés ?',
      'answer': 'Carte bancaire, Stripe, et autres moyens affichés lors du paiement.'
    },
    {
      'question': 'Comment suivre ma commande ?',
      'answer': 'Rendez-vous dans la rubrique "Commandes" de votre profil pour voir le statut et le suivi.'
    },
    {
      'question': 'Comment modifier mon adresse de livraison ?',
      'answer': 'Allez dans "Adresse de livraison" dans votre profil et modifiez ou ajoutez une adresse.'
    },
    {
      'question': 'Comment contacter le support ?',
      'answer': 'Utilisez la rubrique "Obtenir de l’aide" pour envoyer un message au support.'
    },
    {
      'question': 'Comment réinitialiser mon mot de passe ?',
      'answer': 'Depuis la page de connexion, cliquez sur "Mot de passe oublié" et suivez les instructions.'
    },
    {
      'question': 'Comment activer les notifications ?',
      'answer': 'Rendez-vous dans "Notifications" dans la personnalisation du profil.'
    },
    {
      'question': 'Comment supprimer mon compte ?',
      'answer': 'Contactez le support via le formulaire de contact pour demander la suppression.'
    },
  ];

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
              child: const Icon(Icons.help_outline, color: Colors.blueAccent, size: 28),
            ),
            const SizedBox(width: 12),
            Flexible(
              child: Text(
                'FAQ',
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
                              child: const Icon(Icons.question_answer_rounded, color: Colors.blueAccent, size: 26),
                            ),
                            const SizedBox(width: 10),
                            Text(
                              'Questions fréquentes',
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
                                  "Retrouvez ici les réponses aux questions les plus courantes sur l’utilisation de Technoshop.",
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.black87, fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: faqs.length,
                          separatorBuilder: (_, __) => const Divider(height: 24, color: Colors.transparent),
                          itemBuilder: (context, index) {
                            final faq = faqs[index];
                            return Theme(
                              data: Theme.of(context).copyWith(
                                dividerColor: Colors.transparent,
                                splashColor: Colors.transparent,
                              ),
                              child: Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                                color: Colors.grey[50],
                                margin: const EdgeInsets.symmetric(vertical: 2, horizontal: 0),
                                child: ExpansionTile(
                                  tilePadding: const EdgeInsets.symmetric(horizontal: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  collapsedShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                  backgroundColor: Colors.white,
                                  collapsedBackgroundColor: Colors.grey.shade50,
                                  title: Row(
                                    children: [
                                      const Icon(Icons.help_outline, color: Colors.blueAccent, size: 20),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          faq['question']!,
                                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ],
                                  ),
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(left: 8, right: 8, bottom: 12),
                                      child: Text(
                                        faq['answer']!,
                                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
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

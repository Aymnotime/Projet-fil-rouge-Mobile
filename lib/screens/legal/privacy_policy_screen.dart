import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Politique de confidentialité',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontSize: 20,
            letterSpacing: 0.2,
          ),
          overflow: TextOverflow.ellipsis,
        ),
        centerTitle: true,
        elevation: 0,
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            child: Center(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
                child: Card(
                  elevation: 5,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  color: Colors.white,
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.blueAccent.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              padding: const EdgeInsets.all(6),
                              child: const Icon(Icons.verified_user, color: Colors.blueAccent, size: 22),
                            ),
                            const SizedBox(width: 10),
                            Flexible(
                              child: Text(
                                'Politique de confidentialité',
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                  fontSize: 20,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        Text(
                          "Chez Technoshop, la protection de vos données personnelles est une priorité. Cette politique de confidentialité explique comment nous collectons, utilisons et protégeons vos informations.",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5, color: Colors.black87),
                        ),
                        const SizedBox(height: 18),
                        ..._buildPrivacySections(context),
                        const SizedBox(height: 18),
                        Divider(height: 32, thickness: 1.2, color: Colors.grey[300]),
                        Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Text(
                            "Dernière mise à jour : 26 juillet 2025",
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[700]),
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

  List<Widget> _buildPrivacySections(BuildContext context) {
    final sections = [
      {
        'title': '1. Collecte des données',
        'content': 'Nous collectons les informations que vous fournissez lors de la création de votre compte, de la passation de commande ou lors de l’utilisation de nos services.'
      },
      {
        'title': '2. Utilisation des données',
        'content': 'Vos données sont utilisées pour traiter vos commandes, améliorer nos services, personnaliser votre expérience et vous informer des nouveautés.'
      },
      {
        'title': '3. Partage des données',
        'content': 'Technoshop ne partage vos données personnelles qu’avec des partenaires de confiance et uniquement dans le cadre de la gestion de votre commande ou de l’amélioration du service.'
      },
      {
        'title': '4. Sécurité',
        'content': 'Nous mettons en œuvre des mesures de sécurité pour protéger vos données contre tout accès non autorisé, altération ou destruction.'
      },
      {
        'title': '5. Droits des utilisateurs',
        'content': 'Vous pouvez accéder, rectifier ou supprimer vos données à tout moment via votre compte ou en contactant notre service client.'
      },
      {
        'title': '6. Cookies',
        'content': 'L’application peut utiliser des cookies pour améliorer votre expérience utilisateur. Vous pouvez gérer vos préférences dans les paramètres de votre appareil.'
      },
      {
        'title': '7. Modifications',
        'content': 'Technoshop se réserve le droit de modifier cette politique de confidentialité. Les utilisateurs seront informés des changements via l’application.'
      },
      {
        'title': '8. Contact',
        'content': 'Pour toute question relative à la protection des données, contactez-nous via la rubrique "Obtenir de l’aide".'
      },
    ];
    return sections.map((s) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          s['title']!,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
            fontSize: 17,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          s['content']!,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontSize: 15, height: 1.4),
        ),
        const SizedBox(height: 14),
      ],
    )).toList();
  }
}

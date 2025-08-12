import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class CguScreen extends StatelessWidget {
  const CguScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Conditions Générales d’Utilisation',
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
                                'Conditions Générales d’Utilisation (CGU)',
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
                          "Bienvenue sur Technoshop !\n\nEn utilisant notre application, vous acceptez les présentes Conditions Générales d’Utilisation. Veuillez les lire attentivement.",
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(fontSize: 16, height: 1.5, color: Colors.black87),
                        ),
                        const SizedBox(height: 18),
                        ..._buildCguSections(context),
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

  List<Widget> _buildCguSections(BuildContext context) {
    final sections = [
      {
        'title': '1. Objet',
        'content': 'Technoshop est une plateforme de vente de produits électroniques et accessoires. Les présentes CGU définissent les conditions d’utilisation de l’application.'
      },
      {
        'title': '2. Accès au service',
        'content': 'L’accès à l’application nécessite la création d’un compte utilisateur. Vous êtes responsable de la confidentialité de vos identifiants et de toute activité réalisée sous votre compte.'
      },
      {
        'title': '3. Commandes et Paiement',
        'content': 'Toute commande passée sur Technoshop implique une obligation de paiement. Les moyens de paiement acceptés sont affichés lors de la validation du panier.'
      },
      {
        'title': '4. Livraison',
        'content': 'Les délais de livraison sont indiqués lors de la commande. Technoshop s’engage à respecter ces délais dans la mesure du possible, mais ne pourra être tenu responsable en cas de force majeure ou d’événements indépendants de sa volonté.'
      },
      {
        'title': '5. Droit de rétractation',
        'content': 'Conformément à la loi, vous disposez d’un délai de 14 jours pour exercer votre droit de rétractation. Les modalités de retour sont précisées dans la rubrique "Obtenir de l’aide".'
      },
      {
        'title': '6. Garanties et retours',
        'content': 'Les produits bénéficient de la garantie légale de conformité. Pour tout retour ou réclamation, contactez le service client via la rubrique "Obtenir de l’aide".'
      },
      {
        'title': '7. Protection des données',
        'content': 'Vos données personnelles sont traitées conformément à notre politique de confidentialité et aux réglementations en vigueur. Vous disposez d’un droit d’accès, de rectification et de suppression de vos données.'
      },
      {
        'title': '8. Responsabilité',
        'content': 'Technoshop met tout en œuvre pour assurer la sécurité et la fiabilité de l’application. Toutefois, l’utilisateur reconnaît utiliser l’application à ses risques et périls. Technoshop, ses dirigeants, employés et partenaires ne sauraient être tenus responsables des dommages directs ou indirects, matériels ou immatériels, résultant de l’utilisation ou de l’impossibilité d’utiliser l’application, y compris en cas de perte de données, d’interruption de service, de bug, ou de tout autre préjudice. En aucun cas Technoshop ne pourra être poursuivi pour un dommage quelconque, sauf disposition légale impérative contraire.'
      },
      {
        'title': '9. Propriété intellectuelle',
        'content': 'Tous les contenus présents sur Technoshop (textes, images, logos, marques, etc.) sont protégés par le droit d’auteur et la propriété intellectuelle. Toute reproduction, représentation ou utilisation sans autorisation préalable est strictement interdite.'
      },
      {
        'title': '10. Modification des CGU',
        'content': 'Technoshop se réserve le droit de modifier les présentes CGU à tout moment. Les utilisateurs seront informés des changements via l’application. L’utilisation continue de l’application vaut acceptation des nouvelles CGU.'
      },
      {
        'title': '11. Contact',
        'content': 'Pour toute question ou réclamation, contactez-nous via la rubrique "Obtenir de l’aide".'
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

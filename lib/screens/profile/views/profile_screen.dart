import 'package:shop/screens/payment/views/payment_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/list_tile/divider_list_tile.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/api/auth_api.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<Map<String, dynamic>?> _userFuture;

  @override
  void initState() {
    super.initState();
    _userFuture = fetchCurrentUser();
  }

  void _refreshUserData() {
    setState(() {
      _userFuture = fetchCurrentUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _userFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text("Non connecté"));
          }
          final user = snapshot.data!;
          return ListView(
            children: [
              ProfileCard(
                name: "${user['prenom']} ${user['nom']}",
                email: user['email'],
                imageSrc: "",
                press: () async {
                  final result = await Navigator.pushNamed(context, userInfoScreenRoute);
                  if (result == true) {
                    _refreshUserData();
                  }
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Compte",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              // ...sections existantes...
              // ...section Paramètres déjà présente plus haut, on retire la duplication...
              // Section Légal harmonisée placée juste après Paramètres
              // ...section Légal déplacée après Aide & Support...
              ProfileMenuListTile(
                text: "Commandes",
                svgSrc: "assets/icons/Order.svg",
                press: () {
                  Navigator.pushNamed(context, ordersScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Retours",
                svgSrc: "assets/icons/Return.svg",
                press: () {},
              ),
              ProfileMenuListTile(
                text: "Liste de souhaits",
                svgSrc: "assets/icons/Wishlist.svg",
                press: () {},
              ),
              ProfileMenuListTile(
                text: "Adresse de livraison",
                svgSrc: "assets/icons/Address.svg",
                press: () async {
                  final result = await Navigator.pushNamed(context, deliveryAddressScreenRoute);
                  if (result == true) {
                    _refreshUserData();
                  }
                },
              ),
              ProfileMenuListTile(
                text: "Paiement",
                svgSrc: "assets/icons/card.svg",
                press: () {
                  Navigator.pushNamed(context, paymentDetailsScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Portefeuille",
                svgSrc: "assets/icons/Wallet.svg",
                press: () {
                  //Navigator.pushNamed(context, walletScreenRoute);
                },
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  "Sécurité",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              ProfileMenuListTile(
                text: "Mot de passe",
                svgSrc: "assets/icons/Lock.svg",
                press: () {
                  Navigator.pushNamed(context, securityScreenRoute);
                },
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Personnalisation",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              DividerListTileWithTrilingText(
                svgSrc: "assets/icons/Notification.svg",
                title: "Notifications",
                trilingText: "",
                press: () {
                  //Navigator.pushNamed(context, enableNotificationScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Préférences",
                svgSrc: "assets/icons/Preferences.svg",
                press: () {
                  Navigator.pushNamed(context, preferencesScreenRoute);
                },
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Paramètres",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ProfileMenuListTile(
                text: "Langue",
                svgSrc: "assets/icons/Language.svg",
                press: () {
                  Navigator.pushNamed(context, selectLanguageScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Localisation",
                svgSrc: "assets/icons/Location.svg",
                press: () {},
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(
                    horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Aide & Support",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ProfileMenuListTile(
                text: "Obtenir de l'aide",
                svgSrc: "assets/icons/Help.svg",
                press: () {
                  Navigator.pushNamed(context, contactServiceScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "FAQ",
                svgSrc: "assets/icons/FAQ.svg",
                press: () {
                  Navigator.pushNamed(context, faqScreenRoute);
                },
                isShowDivider: false,
              ),
              const SizedBox(height: defaultPadding),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
                child: Text(
                  "Légal",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              ProfileMenuListTile(
                text: "CGU",
                svgSrc: "assets/icons/Policy.svg",
                press: () {
                  Navigator.pushNamed(context, cguScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Politique de confidentialité",
                svgSrc: "assets/icons/Privacy.svg",
                press: () {
                  Navigator.pushNamed(context, privacyPolicyScreenRoute);
                },
                isShowDivider: false,
              ),
              const SizedBox(height: defaultPadding / 2),
              // Déconnexion avec boîte de dialogue stylisée
              ListTile(
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      contentPadding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                      title: Row(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: errorColor.withOpacity(0.10),
                              shape: BoxShape.circle,
                            ),
                            padding: const EdgeInsets.all(10),
                            child: const Icon(Icons.logout, color: errorColor, size: 28),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            'Déconnexion',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: errorColor,
                              fontSize: 18,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        'Voulez-vous vraiment vous déconnecter ?',
                        style: TextStyle(fontSize: 15, color: Colors.black87),
                        textAlign: TextAlign.center,
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.grey.shade200,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Annuler', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: errorColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Se déconnecter', style: TextStyle(fontSize: 15)),
                        ),
                      ],
                    ),
                  );

                  if (shouldLogout != true) return;

                  // Afficher loader modal
                  showDialog(
                    context: context,
                    barrierDismissible: false,
                    builder: (_) => const Center(child: CircularProgressIndicator()),
                  );

                  final errorMessage = await logoutUser();

                  Navigator.of(context).pop(); // Fermer loader

                  if (errorMessage == null) {
                    if (!context.mounted) return;
                    Navigator.of(context).pushNamedAndRemoveUntil(logInScreenRoute, (route) => false);
                  } else {
                    if (!context.mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(errorMessage)),
                    );
                  }
                },
                minLeadingWidth: 24,
                leading: SvgPicture.asset(
                  "assets/icons/Logout.svg",
                  height: 24,
                  width: 24,
                  colorFilter: const ColorFilter.mode(
                    errorColor,
                    BlendMode.srcIn,
                  ),
                ),
                title: const Text(
                  "Se déconnecter",
                  style: TextStyle(color: errorColor, fontSize: 14, height: 1),
                ),
              )
            ],
          );
        },
      ),
    );
  }
}
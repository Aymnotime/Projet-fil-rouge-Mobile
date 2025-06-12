import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:shop/components/list_tile/divider_list_tile.dart';
import 'package:shop/components/network_image_with_loader.dart';
import 'package:shop/constants.dart';
import 'package:shop/route/screen_export.dart';
import 'package:shop/services/auth_service.dart';

import 'components/profile_card.dart';
import 'components/profile_menu_item_list_tile.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: fetchCurrentUser(),
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
                press: () {
                  Navigator.pushNamed(context, userInfoScreenRoute);
                },
              ),

              Padding(
                padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
                child: Text(
                  "Compte",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
              const SizedBox(height: defaultPadding / 2),
              ProfileMenuListTile(
                text: "Commandes",
                svgSrc: "assets/icons/Order.svg",
                press: () {
                  //Navigator.pushNamed(context, ordersScreenRoute);
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
                text: "Adresses",
                svgSrc: "assets/icons/Address.svg",
                press: () {
                  //Navigator.pushNamed(context, addressesScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "Paiement",
                svgSrc: "assets/icons/card.svg",
                press: () {
                  //Navigator.pushNamed(context, emptyPaymentScreenRoute);
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
                  Navigator.pushNamed(context, getHelpScreenRoute);
                },
              ),
              ProfileMenuListTile(
                text: "FAQ",
                svgSrc: "assets/icons/FAQ.svg",
                press: () {},
                isShowDivider: false,
              ),
              const SizedBox(height: defaultPadding),
              // Déconnexion avec boîte de dialogue stylisée
              ListTile(
                onTap: () async {
                  final shouldLogout = await showDialog<bool>(
                    context: context,
                    builder: (context) => AlertDialog(
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      titlePadding: const EdgeInsets.only(top: 24, left: 24, right: 24),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      actionsPadding: const EdgeInsets.only(bottom: 12, right: 12, left: 12),
                      title: Row(
                        children: [
                          const Icon(Icons.logout, color: errorColor, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            'Déconnexion',
                            style: TextStyle(
                              color: errorColor,
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                      content: const Text(
                        'Voulez-vous vraiment vous déconnecter ?',
                        style: TextStyle(fontSize: 16),
                      ),
                      actionsAlignment: MainAxisAlignment.end,
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(false),
                          child: const Text('Annuler'),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: errorColor,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          onPressed: () => Navigator.of(context).pop(true),
                          child: const Text('Se déconnecter'),
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
                    Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
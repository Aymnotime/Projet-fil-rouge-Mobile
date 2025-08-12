import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/theme/theme_service.dart';
import 'package:provider/provider.dart';

import 'components/preference_list_tile.dart';

class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen> {
  bool _analyticsEnabled = true;
  bool _personalizationEnabled = false;
  bool _marketingEnabled = false;
  bool _socialMediaEnabled = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Préférences"),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _analyticsEnabled = true;
                _personalizationEnabled = false;
                _marketingEnabled = false;
                _socialMediaEnabled = false;
              });
            },
            child: const Text("Reset"),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: defaultPadding),
        child: Column(
          children: [
            // Section Mode sombre
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Apparence",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            Consumer<ThemeService>(
              builder: (context, themeService, child) {
                return PreferencesListTile(
                  titleText: "Mode sombre",
                  subtitleTxt:
                  "Activez le mode sombre pour une meilleure expérience visuelle dans des environnements peu éclairés et pour économiser la batterie.",
                  isActive: themeService.isDarkMode,
                  press: () {
                    themeService.toggleTheme();
                  },
                );
              },
            ),
            const Divider(height: defaultPadding * 2),

            // Section Cookies
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: defaultPadding),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Cookies",
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            const SizedBox(height: defaultPadding / 2),
            PreferencesListTile(
              titleText: "Analytics",
              subtitleTxt:
              "Les cookies d'analyse nous aident à améliorer notre application en collectant et en rapportant des informations sur la façon dont vous l'utilisez. Ils collectent des informations de manière à ne pas vous identifier directement.",
              isActive: _analyticsEnabled,
              press: () {
                setState(() {
                  _analyticsEnabled = !_analyticsEnabled;
                });
              },
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "Personnalisation",
              subtitleTxt:
              "Les cookies de personnalisation collectent des informations sur votre utilisation de cette application afin d'afficher du contenu et des expériences qui vous sont pertinents.",
              isActive: _personalizationEnabled,
              press: () {
                setState(() {
                  _personalizationEnabled = !_personalizationEnabled;
                });
              },
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "Marketing",
              subtitleTxt:
              "Les cookies marketing collectent des informations sur votre utilisation de cette application et d'autres pour permettre l'affichage de publicités et d'autres contenus marketing qui vous sont plus pertinents.",
              isActive: _marketingEnabled,
              press: () {
                setState(() {
                  _marketingEnabled = !_marketingEnabled;
                });
              },
            ),
            const Divider(height: defaultPadding * 2),
            PreferencesListTile(
              titleText: "Cookies des réseaux sociaux",
              subtitleTxt:
              "Ces cookies sont définis par une gamme de services de réseaux sociaux que nous avons ajoutés au site pour vous permettre de partager notre contenu avec vos amis et réseaux.",
              isActive: _socialMediaEnabled,
              press: () {
                setState(() {
                  _socialMediaEnabled = !_socialMediaEnabled;
                });
              },
            ),
          ],
        ),
      ),
    );
  }
}

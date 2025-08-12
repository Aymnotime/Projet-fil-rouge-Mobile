import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/api/auth_api.dart';

import '../../../route/route_constants.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String token;
  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Image.asset(
              "assets/images/imagepc.jpg",
              fit: BoxFit.cover,
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Réinitialiser le mot de passe",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  const Text(
                    "Entrez votre nouveau mot de passe.",
                  ),
                  const SizedBox(height: defaultPadding),
                  Form(
                    key: _formKey,
                    child: TextFormField(
                      controller: _passwordController,
                      obscureText: true,
                      decoration: const InputDecoration(
                        labelText: "Nouveau mot de passe",
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return "Veuillez entrer un mot de passe";
                        }
                        if (value.length < 12) {
                          return "Le mot de passe doit contenir au moins 12 caractères";
                        }
                        if (!RegExp(r'(?=.*?[#?!@$%^&*-])').hasMatch(value)) {
                          return "Le mot de passe doit contenir au moins un caractère spécial";
                        }
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  ElevatedButton(
                    onPressed: _isLoading
                        ? null
                        : () async {
                      if (_formKey.currentState!.validate()) {
                        setState(() => _isLoading = true);
                        showDialog(
                          context: context,
                          barrierDismissible: false,
                          builder: (context) => const Center(child: CircularProgressIndicator()),
                        );
                        final result = await resetPasswordWithToken(
                          widget.token,
                          _passwordController.text.trim(),
                        );
                        Navigator.of(context).pop(); // Ferme le loader
                        setState(() => _isLoading = false);
                        if (result == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Mot de passe réinitialisé avec succès !"),
                              backgroundColor: Colors.green,
                            ),
                          );
                          Navigator.pop(context);
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(result),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text("Réinitialiser"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Retour à la"),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context, logInScreenRoute);
                        },
                        child: const Text("Connexion"),
                      )
                    ],
                  ),
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}

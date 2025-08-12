import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/api/auth_api.dart';
import 'package:shop/screens/auth/views/components/validators.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingData = true;
  Map<String, dynamic>? userInfo;

  @override
  void initState() {
    super.initState();
    _loadUserInfo();
  }

  Future<void> _loadUserInfo() async {
    try {
      final info = await getUserInfo();
      if (mounted) {
        setState(() {
          userInfo = info;
          nomController.text = info?['nom'] ?? '';
          prenomController.text = info?['prenom'] ?? '';
          emailController.text = info?['email'] ?? '';
          phoneController.text = info?['telephone'] ?? '';
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingData = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement: $e')),
        );
      }
    }
  }

  Future<void> _updateUserInfo() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifie s'il y a eu une modification
    final hasChanged =
        nomController.text != (userInfo?['nom'] ?? '') ||
            prenomController.text != (userInfo?['prenom'] ?? '') ||
            emailController.text != (userInfo?['email'] ?? '') ||
            phoneController.text != (userInfo?['telephone'] ?? '');

    if (!hasChanged) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune modification détectée.')),
      );
      return;
    }

    // Demande le mot de passe avant de continuer
    final password = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final TextEditingController pwdController = TextEditingController();
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: Row(
            children: const [
              Icon(Icons.lock_outline, color: Colors.blue),
              SizedBox(width: 8),
              Text('Confirmation requise'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Pour valider la modification de vos informations, veuillez entrer votre mot de passe.',
                style: TextStyle(fontSize: 15),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: pwdController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.lock),
                ),
                autofocus: true,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Annuler'),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Valider'),
              style: ElevatedButton.styleFrom(minimumSize: const Size(120, 40)),
              onPressed: () => Navigator.of(context).pop(pwdController.text),
            ),
          ],
        );
      },
    );
    if (password == null || password.isEmpty) return;

    setState(() => _isLoading = true);

    // Vérification du mot de passe via l'API auth
    final authError = await loginUser(emailController.text, password);
    if (authError != null) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Mot de passe incorrect.')),
      );
      return;
    }

    try {
      // Mise à jour des informations personnelles
      final updateData = {
        'nom': nomController.text,
        'prenom': prenomController.text,
        'email': emailController.text,
        'telephone': phoneController.text,
      };

      final error = await updateUserInfo(updateData);

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Informations mises à jour avec succès !'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else {
        throw Exception(error);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes informations'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image d'en-tête similaire au login
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, Color(0xFF1976D2)],
                ),
              ),
              child: const Icon(
                Icons.person,
                size: 80,
                color: Colors.white,
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Modifier mes informations",
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: defaultPadding / 2),
                    const Text("Mettez à jour vos informations personnelles."),
                    const SizedBox(height: defaultPadding),

                    // Champs d'informations personnelles
                    TextFormField(
                      controller: nomController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: "Nom",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre nom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: defaultPadding),

                    TextFormField(
                      controller: prenomController,
                      textInputAction: TextInputAction.next,
                      decoration: const InputDecoration(
                        hintText: "Prénom",
                        prefixIcon: Icon(Icons.person_outline),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez entrer votre prénom';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: defaultPadding),

                    TextFormField(
                      controller: emailController,
                      validator: emailValidator.call,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        hintText: "Email",
                        prefixIcon: Icon(Icons.email_outlined),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),

                    TextFormField(
                      controller: phoneController,
                      textInputAction: TextInputAction.next,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        hintText: "Téléphone",
                        prefixIcon: Icon(Icons.phone_outlined),
                      ),
                    ),
                    const SizedBox(height: defaultPadding),

                    const SizedBox(height: defaultPadding * 2),

                    // Bouton de mise à jour
                    SizedBox(
                      width: double.infinity,
                      child: _isLoading
                          ? const Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                        onPressed: _updateUserInfo,
                        child: const Text("Mettre à jour"),
                      ),
                    ),

                    const SizedBox(height: defaultPadding),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    emailController.dispose();
    phoneController.dispose();
    super.dispose();
  }
}

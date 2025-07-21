import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/auth_service.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_picker/country_picker.dart';

class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  // Utilitaire : code pays à partir du nom
  String? _countryCodeFromName(String? name) {
    if (name == null) return null;
    final lower = name.toLowerCase();
    if (lower.contains('france')) return 'FR';
    if (lower.contains('belgique')) return 'BE';
    if (lower.contains('maroc')) return 'MA';
    if (lower.contains('algérie')) return 'DZ';
    if (lower.contains('suisse')) return 'CH';
    if (lower.contains('italie')) return 'IT';
    if (lower.contains('allemagne')) return 'DE';
    if (lower.contains('canada')) return 'CA';
    if (lower.contains('états-unis') || lower.contains('usa') || lower.contains('united states')) return 'US';
    return null;
  }

  // Utilitaire : longueur max téléphone selon le pays
  int _getPhoneMaxLength(String? code) {
    switch (code) {
      case 'FR':
      case 'BE':
      case 'MA':
      case 'DZ':
      case 'CH':
        return 9;
      case 'US':
      case 'CA':
      case 'IT':
        return 10;
      case 'DE':
        return 11;
      default:
        return 12;
    }
  }
  Country? _selectedCountry = Country(
    phoneCode: '33',
    countryCode: 'FR',
    e164Sc: 0,
    geographic: true,
    level: 1,
    name: 'France',
    example: '612345678',
    displayName: 'France',
    displayNameNoCountryCode: 'France',
    e164Key: '',
  );
  String? _selectedCountryCode = 'FR';
  int? _phoneMaxLength = 9;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController nomController = TextEditingController();
  final TextEditingController prenomController = TextEditingController();
  final TextEditingController adresseController = TextEditingController();
  final TextEditingController complementController = TextEditingController();
  final TextEditingController codePostalController = TextEditingController();
  final TextEditingController villeController = TextEditingController();
  final TextEditingController paysController = TextEditingController();
  final TextEditingController telephoneController = TextEditingController();

  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isDefaultAddress = false;
  bool _showForm = false; // Contrôle l'affichage du formulaire
  List<Map<String, dynamic>> addresses = [];
  Map<String, dynamic>? currentUserInfo;
  String? editingAddressId;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUserInfo(),
      _loadAddresses(),
    ]);

    // Logique d'affichage : formulaire si aucune adresse, sinon cartes
    setState(() {
      _showForm = addresses.isEmpty;
      _isLoadingData = false;
    });
  }

  Future<void> _loadUserInfo() async {
    try {
      final info = await getUserInfo();
      if (info != null && mounted) {
        setState(() {
          currentUserInfo = info;
          // Pré-remplir les champs nom/prénom depuis les infos utilisateur
          nomController.text = info['nom'] ?? '';
          prenomController.text = info['prenom'] ?? '';
          paysController.text = 'France';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des infos utilisateur: $e')),
        );
      }
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final addressList = await fetchUserAddresses();
      if (mounted) {
        setState(() {
          addresses = addressList;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors du chargement des adresses: $e')),
        );
      }
    }
  }

  void _fillFormWithAddress(Map<String, dynamic> address) {
    adresseController.text = address['adresse'] ?? '';
    complementController.text = address['complement_adresse'] ?? '';
    codePostalController.text = address['code_postal'] ?? '';
    villeController.text = address['ville'] ?? '';
    paysController.text = address['pays'] ?? 'France';
    telephoneController.text = address['telephone'] ?? '';
    _isDefaultAddress = (address['par_defaut'] ?? 0) == 1;
    // Sélectionne le pays dans le picker si possible
    if (address['pays'] != null && address['pays'].toString().isNotEmpty) {
      final code = _countryCodeFromName(address['pays']);
      if (code != null) {
        _selectedCountryCode = code;
      }
    }
  }

  void _clearForm() {
    adresseController.clear();
    complementController.clear();
    codePostalController.clear();
    villeController.clear();
    telephoneController.clear();
    paysController.text = 'France';
    _selectedCountryCode = 'FR';
    _selectedCountry = Country(
      phoneCode: '33',
      countryCode: 'FR',
      e164Sc: 0,
      geographic: true,
      level: 1,
      name: 'France',
      example: '612345678',
      displayName: 'France',
      displayNameNoCountryCode: 'France',
      e164Key: '',
    );
    _isDefaultAddress = false;
    editingAddressId = null;
  }

  void _showFormForEdit(Map<String, dynamic> address) {
    _fillFormWithAddress(address);
    setState(() {
      editingAddressId = address['id']?.toString();
      _showForm = true;
    });
  }

  void _showFormForAdd() {
    _clearForm();
    setState(() {
      editingAddressId = null;
      _showForm = true;
    });
  }

  void _hideForm() {
    setState(() {
      _showForm = false;
      editingAddressId = null;
    });
    _clearForm();
  }

  Future<void> _saveAddress() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Concatène l'indicatif pays et le numéro pour le champ téléphone
      final fullPhone = '+${_selectedCountry?.phoneCode ?? '33'}${telephoneController.text}';
      final addressData = {
        'telephone': fullPhone,
        'adresse': adresseController.text,
        'complement_adresse': complementController.text,
        'code_postal': codePostalController.text,
        'ville': villeController.text,
        'pays': paysController.text,
        'par_defaut': _isDefaultAddress,
      };

      String? error;
      if (editingAddressId != null) {
        // Modifier une adresse existante
        error = await updateUserAddress(editingAddressId!, addressData);
      } else {
        // Ajouter une nouvelle adresse
        error = await addUserAddress(addressData);
      }

      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(editingAddressId != null
                ? 'Adresse modifiée avec succès !'
                : 'Nouvelle adresse ajoutée avec succès !'),
            backgroundColor: Colors.green,
          ),
        );

        // Recharger les adresses
        await _loadAddresses();

        // Masquer le formulaire et revenir aux cartes
        setState(() {
          _showForm = false;
          editingAddressId = null;
        });
        _clearForm();

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

  Future<void> _deleteAddress(String addressId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer l\'adresse'),
        content: const Text('Êtes-vous sûr de vouloir supprimer cette adresse ?'),
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
      try {
        final error = await deleteUserAddress(addressId);
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Adresse supprimée avec succès'),
              backgroundColor: Colors.green,
            ),
          );
          await _loadAddresses();

          // Si plus d'adresses, afficher le formulaire
          if (addresses.isEmpty) {
            setState(() {
              _showForm = true;
            });
          }
        } else {
          throw Exception(error);
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la suppression: $e')),
        );
      }
    }
  }

  Future<void> _setAsDefault(String addressId) async {
    try {
      final error = await setDefaultAddress(addressId);
      if (error == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Adresse définie par défaut'),
            backgroundColor: Colors.green,
          ),
        );
        await _loadAddresses();
      } else {
        throw Exception(error);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoadingData) {
      return const Scaffold(
        backgroundColor: Colors.white,
        body: Center(child: CircularProgressIndicator(color: Colors.grey)),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Adresses de livraison'),
        centerTitle: true,
        actions: [
          if (addresses.isNotEmpty && !_showForm)
            IconButton(
              icon: const Icon(Icons.add),
              onPressed: _showFormForAdd,
              tooltip: 'Nouvelle adresse',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Affichage conditionnel : cartes OU formulaire
            if (!_showForm && addresses.isNotEmpty) ...[
              // Liste des adresses sous forme de cartes
              Text(
                'Mes adresses (${addresses.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: defaultPadding),
              ...addresses.map((address) => _buildAddressCard(address)),
            ],

            // Formulaire (affiché si aucune adresse OU en mode édition)
            if (_showForm) ...[
              _buildAddressForm(),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAddressForm() {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white, // Fond blanc pour le formulaire
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // En-tête du formulaire
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    editingAddressId != null ? Icons.edit : Icons.add_location,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        editingAddressId != null
                            ? 'Modifier l\'adresse'
                            : 'Nouvelle adresse',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Renseignez votre adresse de livraison complète',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                if (editingAddressId != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: _hideForm,
                    tooltip: 'Fermer',
                  ),
              ],
            ),
            const SizedBox(height: defaultPadding * 1.5),

            Form(
              key: _formKey,
              child: Column(
                children: [
                  // Nom et Prénom (lecture seule)
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: prenomController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "Prénom",
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Expanded(
                        child: TextFormField(
                          controller: nomController,
                          enabled: false,
                          decoration: InputDecoration(
                            labelText: "Nom",
                            prefixIcon: const Icon(Icons.person_outline),
                            filled: true,
                            fillColor: Colors.grey[50],
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),

                  // Téléphone : indicatif et numéro séparés sur la même ligne
                  Row(
                    children: [
                      // Sélecteur d'indicatif sur fond gris clair, popup blanc, largeur augmentée et gestion du débordement
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[50],
                          border: Border.all(color: Colors.grey.shade300),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Theme(
                          data: ThemeData(
                            colorScheme: ColorScheme.light(
                              primary: Colors.grey,
                              secondary: Colors.grey,
                              surface: Colors.white,
                              background: Colors.white,
                              onPrimary: Colors.black,
                            ),
                            highlightColor: Colors.transparent,
                            splashColor: Colors.transparent,
                            dialogBackgroundColor: Colors.white,
                            popupMenuTheme: const PopupMenuThemeData(color: Colors.white),
                            canvasColor: Colors.white,
                            scaffoldBackgroundColor: Colors.white,
                          ),
                          child: Builder(
                            builder: (context) => SizedBox(
                              width: 120,
                              child: IntlPhoneField(
                                controller: telephoneController,
                                initialCountryCode: _selectedCountryCode ?? 'FR',
                                decoration: InputDecoration(
                                  labelText: '',
                                  border: InputBorder.none,
                                  counterText: '',
                                  fillColor: Colors.grey[50],
                                  filled: true,
                                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 0),
                                ),
                                dropdownIconPosition: IconPosition.trailing,
                                flagsButtonMargin: const EdgeInsets.only(left: 4, right: 2),
                                onCountryChanged: (country) {
                                  setState(() {
                                    _selectedCountryCode = country.code;
                                    paysController.text = country.name;
                                    _selectedCountry = Country(
                                      phoneCode: country.dialCode,
                                      countryCode: country.code,
                                      e164Sc: 0,
                                      geographic: true,
                                      level: 1,
                                      name: country.name,
                                      example: '',
                                      displayName: country.name,
                                      displayNameNoCountryCode: country.name,
                                      e164Key: '',
                                    );
                                    _phoneMaxLength = _getPhoneMaxLength(country.code);
                                  });
                                },
                                disableLengthCheck: true,
                                validator: (value) {
                                  if (value == null || value.number.isEmpty) {
                                    return 'Numéro requis';
                                  }
                                  if (_phoneMaxLength != null && value.number.length != _phoneMaxLength) {
                                    return 'Le numéro doit contenir $_phoneMaxLength chiffres';
                                  }
                                  if (!RegExp(r'^[0-9]+$').hasMatch(value.number)) {
                                    return 'Chiffres uniquement';
                                  }
                                  return null;
                                },
                                onChanged: (phone) {
                                  telephoneController.text = phone.number;
                                },
                                showCountryFlag: true,
                                textAlign: TextAlign.left,
                                style: const TextStyle(fontSize: 16),
                                dropdownTextStyle: const TextStyle(
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                        ),
                        width: 120,
                        height: 56,
                        alignment: Alignment.center,
                      ),
                      const SizedBox(width: 8),
                      // Champ numéro de téléphone sur fond blanc
                      Expanded(
                        child: TextFormField(
                          controller: telephoneController,
                          keyboardType: TextInputType.number,
                          maxLength: _phoneMaxLength,
                          decoration: InputDecoration(
                            labelText: "Numéro de téléphone *",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterText: '',
                            fillColor: Colors.white,
                            filled: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Numéro requis';
                            }
                            if (_phoneMaxLength != null && value.length != _phoneMaxLength) {
                              return 'Le numéro doit contenir $_phoneMaxLength chiffres';
                            }
                            if (!RegExp(r'^[0-9]+$').hasMatch(value)) {
                              return 'Chiffres uniquement';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),

                  // Adresse principale
                  TextFormField(
                    controller: adresseController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Adresse *",
                      hintText: "Numéro et nom de rue",
                      prefixIcon: const Icon(Icons.home_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Adresse requise';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: defaultPadding),

                  // Complément d'adresse
                  TextFormField(
                    controller: complementController,
                    textInputAction: TextInputAction.next,
                    decoration: InputDecoration(
                      labelText: "Complément d'adresse",
                      hintText: "Bâtiment, étage, appartement...",
                      prefixIcon: const Icon(Icons.add_home_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),

                  // Code postal et Ville
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: TextFormField(
                          controller: codePostalController,
                          textInputAction: TextInputAction.next,
                          keyboardType: TextInputType.number,
                          maxLength: 5,
                          decoration: InputDecoration(
                            labelText: "Code postal *",
                            prefixIcon: const Icon(Icons.local_post_office_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Code postal requis';
                            }
                            if (value.length != 5) {
                              return 'Code postal invalide';
                            }
                            return null;
                          },
                        ),
                      ),
                      const SizedBox(width: defaultPadding),
                      Expanded(
                        flex: 3,
                        child: TextFormField(
                          controller: villeController,
                          textInputAction: TextInputAction.next,
                          decoration: InputDecoration(
                            labelText: "Ville *",
                            prefixIcon: const Icon(Icons.location_city_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ville requise';
                            }
                            return null;
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: defaultPadding),

                  // Pays avec sélection via country_picker et drapeau
                  GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: false,
                        countryListTheme: CountryListThemeData(
                          backgroundColor: Colors.white,
                          borderRadius: BorderRadius.circular(8),
                          inputDecoration: InputDecoration(
                            labelText: 'Rechercher un pays',
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            filled: true,
                            fillColor: Colors.white,
                          ),
                        ),
                        onSelect: (Country country) {
                          setState(() {
                            paysController.text = country.name;
                            _selectedCountry = country;
                            _selectedCountryCode = country.countryCode;
                            _phoneMaxLength = _getPhoneMaxLength(country.countryCode);
                          });
                        },
                      );
                    },
                    child: AbsorbPointer(
                      child: TextFormField(
                        controller: paysController,
                        readOnly: true,
                        decoration: InputDecoration(
                          labelText: "Pays *",
                          prefixIcon: _selectedCountry != null
                              ? Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(_selectedCountry!.flagEmoji ?? ''),
                          )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Pays requis';
                          }
                          return null;
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 1.5),

                  // Adresse par défaut
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Adresse de livraison par défaut',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: const Text('Utiliser cette adresse pour mes commandes'),
                      value: _isDefaultAddress,
                      onChanged: (value) {
                        setState(() {
                          _isDefaultAddress = value;
                        });
                      },
                      activeColor: primaryColor,
                    ),
                  ),

                  const SizedBox(height: defaultPadding * 2),

                  // Boutons d'action
                  Row(
                    children: [
                      if (editingAddressId != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: _hideForm,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text("Annuler"),
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                      ],
                      Expanded(
                        child: _isLoading
                            ? const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16),
                            child: CircularProgressIndicator(color: Colors.grey),
                          ),
                        )
                            : ElevatedButton(
                          onPressed: _saveAddress,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(editingAddressId != null
                              ? "Modifier l'adresse"
                              : "Ajouter l'adresse"),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address) {
    final isDefault = (address['par_defaut'] ?? 0) == 1;
    final countryName = address['pays'] ?? 'France';
    final countryCode = _countryCodeFromName(countryName) ?? 'FR';
    // Affichage du téléphone au format international (si pas déjà au bon format)
    String phoneDisplay = '';
    if (address['telephone'] != null && address['telephone'].isNotEmpty) {
      final tel = address['telephone'].toString();
      if (tel.startsWith('+')) {
        phoneDisplay = tel;
      } else {
        // Essaie de retrouver l'indicatif à partir du pays
        String indicatif = '';
        switch (countryCode) {
          case 'FR': indicatif = '+33'; break;
          case 'BE': indicatif = '+32'; break;
          case 'MA': indicatif = '+212'; break;
          case 'DZ': indicatif = '+213'; break;
          case 'CH': indicatif = '+41'; break;
          case 'IT': indicatif = '+39'; break;
          case 'DE': indicatif = '+49'; break;
          case 'CA': indicatif = '+1'; break;
          case 'US': indicatif = '+1'; break;
          default: indicatif = ''; break;
        }
        phoneDisplay = indicatif + tel;
      }
    }

    return Card(
      elevation: 3,
      margin: const EdgeInsets.only(bottom: defaultPadding),
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDefault
            ? BorderSide(color: primaryColor, width: 2)
            : BorderSide.none,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(defaultPadding * 1.5),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // En-tête avec icône, badge et code pays
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDefault
                          ? primaryColor.withOpacity(0.1)
                          : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      isDefault ? Icons.home : Icons.location_on_outlined,
                      color: isDefault ? primaryColor : Colors.grey[600],
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              address['adresse'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                countryCode,
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (address['complement_adresse'] != null &&
                            address['complement_adresse'].isNotEmpty)
                          Text(
                            address['complement_adresse'],
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (isDefault)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [primaryColor, primaryColor.withOpacity(0.8)],
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: primaryColor.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Text(
                        'PAR DÉFAUT',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: defaultPadding),

              // Informations de l'adresse
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.location_city, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(
                          '${address['code_postal']} ${address['ville']}',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Icon(Icons.public, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 8),
                        Text(address['pays'] ?? 'France'),
                      ],
                    ),
                    if (phoneDisplay.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                          const SizedBox(width: 8),
                          Text(
                            phoneDisplay,
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              const SizedBox(height: defaultPadding),

              // Actions
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _showFormForEdit(address),
                      icon: const Icon(Icons.edit, size: 18),
                      label: const Text('Modifier'),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),

                  if (!isDefault) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _setAsDefault(address['id'].toString()),
                        icon: const Icon(Icons.star_outline, size: 18),
                        label: const Text('Par défaut'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          foregroundColor: Colors.orange,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: () => _deleteAddress(address['id'].toString()),
                      icon: const Icon(Icons.delete_outline, color: Colors.red),
                      tooltip: 'Supprimer',
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.red.shade50,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAddressForm() {
    // Cette méthode peut être étendue pour une meilleure UX
    // par exemple, scroll automatique ou animation
  }

  @override
  void dispose() {
    nomController.dispose();
    prenomController.dispose();
    adresseController.dispose();
    complementController.dispose();
    codePostalController.dispose();
    villeController.dispose();
    paysController.dispose();
    telephoneController.dispose();
    super.dispose();
  }
}

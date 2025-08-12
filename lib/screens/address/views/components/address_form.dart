import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:country_picker/country_picker.dart';

class AddressForm extends StatefulWidget {
  final Map<String, dynamic>? initialData;
  final Map<String, dynamic>? userInfo;
  final String? editingAddressId;
  final bool isLoading;
  final Function(Map<String, dynamic>) onSave;
  final VoidCallback? onCancel;

  const AddressForm({
    super.key,
    this.initialData,
    this.userInfo,
    this.editingAddressId,
    required this.isLoading,
    required this.onSave,
    this.onCancel,
  });

  @override
  State<AddressForm> createState() => _AddressFormState();
}

class _AddressFormState extends State<AddressForm> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Controllers
  late final TextEditingController nomController;
  late final TextEditingController prenomController;
  late final TextEditingController adresseController;
  late final TextEditingController complementController;
  late final TextEditingController codePostalController;
  late final TextEditingController villeController;
  late final TextEditingController paysController;
  late final TextEditingController telephoneController;

  // State
  bool _isDefaultAddress = false;
  Country? _selectedCountry;
  String? _selectedCountryCode = 'FR';
  int? _phoneMaxLength = 9;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeData();
  }

  void _initializeControllers() {
    nomController = TextEditingController();
    prenomController = TextEditingController();
    adresseController = TextEditingController();
    complementController = TextEditingController();
    codePostalController = TextEditingController();
    villeController = TextEditingController();
    paysController = TextEditingController();
    telephoneController = TextEditingController();
  }

  void _initializeData() {
    // Données utilisateur
    if (widget.userInfo != null) {
      nomController.text = widget.userInfo!['nom'] ?? '';
      prenomController.text = widget.userInfo!['prenom'] ?? '';
    }

    // Données d'adresse initiales
    if (widget.initialData != null) {
      adresseController.text = widget.initialData!['adresse'] ?? '';
      complementController.text = widget.initialData!['complement_adresse'] ?? '';
      codePostalController.text = widget.initialData!['code_postal'] ?? '';
      villeController.text = widget.initialData!['ville'] ?? '';
      paysController.text = widget.initialData!['pays'] ?? 'France';
      telephoneController.text = widget.initialData!['telephone'] ?? '';
      _isDefaultAddress = (widget.initialData!['par_defaut'] ?? 0) == 1;

      if (widget.initialData!['pays'] != null) {
        final code = _countryCodeFromName(widget.initialData!['pays']);
        if (code != null) {
          _selectedCountryCode = code;
        }
      }
    } else {
      paysController.text = 'France';
    }

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
  }

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

  void _handleSave() {
    if (!_formKey.currentState!.validate()) return;

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

    widget.onSave(addressData);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
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
                    widget.editingAddressId != null ? Icons.edit : Icons.add_location,
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
                        widget.editingAddressId != null
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
                if (widget.editingAddressId != null && widget.onCancel != null)
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: widget.onCancel,
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

                  // Téléphone premium deux colonnes
                  Row(
                    children: [
                      SizedBox(
                        width: 120,
                        child: Theme(
                          data: Theme.of(context).copyWith(
                            canvasColor: Colors.white,
                            dialogBackgroundColor: Colors.white,
                            cardColor: Colors.white,
                            colorScheme: Theme.of(context).colorScheme.copyWith(
                              surface: Colors.white,
                              background: Colors.white,
                            ),
                          ),
                          child: IntlPhoneField(
                            initialCountryCode: _selectedCountryCode ?? 'FR',
                            decoration: InputDecoration(
                              filled: true,
                              fillColor: Colors.white,
                              labelText: '',
                              prefixIcon: Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                child: Center(
                                  child: Text(
                                    '+${_selectedCountry?.phoneCode ?? '33'}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.black),
                                  ),
                                ),
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(8),
                                borderSide: BorderSide(color: Colors.grey.shade300),
                              ),
                              contentPadding: const EdgeInsets.symmetric(vertical: 16),
                            ),
                            dropdownDecoration: const BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.all(Radius.circular(8)),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black12,
                                  blurRadius: 4,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                            dropdownTextStyle: TextStyle(color: Colors.black, fontSize: 16),
                            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black),
                            disableLengthCheck: true,
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
                            onChanged: (phone) {
                              // Ne rien faire ici, le champ numéro est à droite
                            },
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: telephoneController,
                          keyboardType: TextInputType.number,
                          maxLength: _phoneMaxLength,
                          decoration: InputDecoration(
                            labelText: "Numéro de téléphone *",
                            hintText: "612345678",
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterText: '',
                            fillColor: Colors.white,
                            filled: true,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
                          ),
                          style: const TextStyle(fontSize: 16),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Numéro requis';
                            }
                            if (_phoneMaxLength != null && value.length != _phoneMaxLength) {
                              return 'Le numéro doit contenir $_phoneMaxLength chiffres';
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
                            prefixIcon: const Icon(Icons.location_on_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            counterText: '',
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Code requis';
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

                  // Pays
                  GestureDetector(
                    onTap: () {
                      showCountryPicker(
                        context: context,
                        showPhoneCode: false,
                        onSelect: (Country country) {
                          setState(() {
                            _selectedCountryCode = country.countryCode;
                            paysController.text = country.name;
                            _selectedCountry = country;
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
                          prefixIcon: const Icon(Icons.public),
                          suffixIcon: const Icon(Icons.arrow_drop_down),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding * 1.5),

                  // Switch adresse par défaut
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
                      if (widget.editingAddressId != null && widget.onCancel != null) ...[
                        Expanded(
                          child: OutlinedButton(
                            onPressed: widget.onCancel,
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                            child: const Text('Annuler'),
                          ),
                        ),
                        const SizedBox(width: defaultPadding),
                      ],
                      Expanded(
                        child: widget.isLoading
                            ? const Center(
                          child: CircularProgressIndicator(),
                        )
                            : ElevatedButton(
                          onPressed: _handleSave,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: Text(
                            widget.editingAddressId != null ? 'Modifier' : 'Ajouter',
                          ),
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

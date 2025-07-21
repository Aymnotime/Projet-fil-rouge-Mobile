import 'package:flutter/material.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Map<String, dynamic>> addresses = [
    {
      'name': 'Domicile',
      'address': '12 rue de la Paix, 75002 Paris',
      'phone': '+33 6 12 34 56 78',
      'isDefault': true,
    },
    {
      'name': 'Travail',
      'address': '100 avenue de France, 75013 Paris',
      'phone': '+33 1 23 45 67 89',
      'isDefault': false,
    },
  ];

  void _addAddress() async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => const AddOrEditAddressDialog(),
    );
    if (result != null) {
      setState(() {
        bool isFirst = addresses.isEmpty;
        addresses.add({
          ...result,
          'isDefault': isFirst,
        });
        if (isFirst) {
          for (int i = 1; i < addresses.length; i++) {
            addresses[i]['isDefault'] = false;
          }
        }
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adresse ajoutée avec succès !')),
      );
    }
  }

  void _editAddress(int index) async {
    final result = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => AddOrEditAddressDialog(address: addresses[index]),
    );
    if (result != null) {
      setState(() {
        addresses[index] = {
          ...addresses[index],
          'name': result['name'],
          'address': result['address'],
          'phone': result['phone'],
        };
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Adresse modifiée avec succès !')),
      );
    }
  }

  void _deleteAddress(int index) {
    setState(() {
      final wasDefault = addresses[index]['isDefault'];
      addresses.removeAt(index);
      if (wasDefault && addresses.isNotEmpty) {
        addresses[0]['isDefault'] = true;
      }
    });
  }

  void _setDefault(int index) {
    setState(() {
      for (int i = 0; i < addresses.length; i++) {
        addresses[i]['isDefault'] = i == index;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes adresses'),
      ),
      body: SafeArea(
        child: addresses.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.location_off, size: 64, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Aucune adresse enregistrée',
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                icon: const Icon(Icons.add, size: 20),
                label: const Text('Ajouter une adresse'),
                onPressed: _addAddress,
              ),
            ],
          ),
        )
            : ListView.separated(
          padding: const EdgeInsets.all(16),
          itemCount: addresses.length,
          separatorBuilder: (context, index) => const SizedBox(height: 16),
          itemBuilder: (context, index) {
            final address = addresses[index];
            return _buildAddressCard(address, index);
          },
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.add_location_alt),
        label: const Text('Ajouter'),
        onPressed: _addAddress,
      ),
    );
  }

  Widget _buildAddressCard(Map<String, dynamic> address, int index) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: Theme.of(context).primaryColor),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    address['name'] ?? '',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (address['isDefault'] == true)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star, color: Colors.orange, size: 16),
                        SizedBox(width: 4),
                        Text(
                          'Par défaut',
                          style: TextStyle(
                            color: Colors.orange.shade800,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address['address'] ?? '',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 8),
            Text(
              address['phone'] ?? '',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.grey.shade700,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                _buildActionButton(
                  icon: Icons.edit,
                  label: 'Modifier',
                  color: Colors.blue,
                  onPressed: () => _editAddress(index),
                ),
                SizedBox(width: 8),
                _buildActionButton(
                  icon: Icons.delete,
                  label: 'Supprimer',
                  color: Colors.red,
                  onPressed: () => _deleteAddress(index),
                ),
                SizedBox(width: 8),
                _buildDefaultButton(
                  isDefault: address['isDefault'] == true,
                  onPressed: () => _setDefault(index),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return OutlinedButton.icon(
      icon: Icon(icon, size: 18),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(color: color),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
    );
  }

  Widget _buildDefaultButton({
    required bool isDefault,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton.icon(
      icon: Icon(
        isDefault ? Icons.check_circle : Icons.radio_button_unchecked,
        size: 18,
      ),
      label: Text(isDefault ? 'Défaut' : 'Définir'),
      style: ElevatedButton.styleFrom(
        foregroundColor: isDefault ? Colors.orange : Colors.grey,
        backgroundColor: isDefault
            ? Colors.orange.withOpacity(0.1)
            : Colors.grey.withOpacity(0.1),
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      ),
      onPressed: onPressed,
    );
  }
}

class AddOrEditAddressDialog extends StatefulWidget {
  final Map<String, dynamic>? address;
  const AddOrEditAddressDialog({super.key, this.address});

  @override
  State<AddOrEditAddressDialog> createState() => _AddOrEditAddressDialogState();
}

class _AddOrEditAddressDialogState extends State<AddOrEditAddressDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.address?['name'] ?? '');
    _addressController = TextEditingController(text: widget.address?['address'] ?? '');
    _phoneController = TextEditingController(text: widget.address?['phone'] ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      return 'Champ requis';
    }
    final phoneRegExp = RegExp(r'^(\+33|0)[1-9](\d{8})$');
    if (!phoneRegExp.hasMatch(value)) {
      return 'Numéro de téléphone invalide';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.address == null ? 'Nouvelle adresse' : 'Modifier l\'adresse',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Nom',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person_outline),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Champ requis' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: 'Adresse',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.home_outlined),
                ),
                validator: (value) =>
                value == null || value.trim().isEmpty ? 'Champ requis' : null,
                maxLines: 2,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: 'Téléphone',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone_outlined),
                ),
                keyboardType: TextInputType.phone,
                validator: _validatePhone,
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  SizedBox(width: 16),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        if (_formKey.currentState!.validate()) {
                          Navigator.pop(context, {
                            'name': _nameController.text.trim(),
                            'address': _addressController.text.trim(),
                            'phone': _phoneController.text.trim(),
                          });
                        }
                      },
                      child: Text(widget.address == null ? 'Ajouter' : 'Enregistrer'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
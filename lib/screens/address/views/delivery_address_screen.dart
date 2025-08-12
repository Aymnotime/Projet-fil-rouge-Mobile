import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/screens/address/views/components/address_form.dart';
import 'package:shop/screens/address/views/components/address_card.dart';
import 'package:shop/services/api/address_api.dart';





class DeliveryAddressScreen extends StatefulWidget {
  const DeliveryAddressScreen({super.key});

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _showForm = false;
  List<Map<String, dynamic>> addresses = [];
  Map<String, dynamic>? currentUserInfo;
  String? editingAddressId;
  Map<String, dynamic>? editingAddressData;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoadingData = true);

    try {
      final results = await Future.wait([
        fetchUserInfo(),
        fetchUserAddresses(),
      ]);

      if (mounted) {
        setState(() {
          currentUserInfo = results[0] as Map<String, dynamic>?;
          addresses = results[1] as List<Map<String, dynamic>>;
          _showForm = addresses.isEmpty;
          _isLoadingData = false;
        });
      }
    } catch (e) {
      if (mounted) {
        _showError('Erreur lors du chargement: $e');
        setState(() => _isLoadingData = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  void _showFormForAdd() {
    setState(() {
      editingAddressId = null;
      editingAddressData = null;
      _showForm = true;
    });
  }

  void _showFormForEdit(Map<String, dynamic> address) {
    setState(() {
      editingAddressId = address['id']?.toString();
      editingAddressData = address;
      _showForm = true;
    });
  }

  void _hideForm() {
    setState(() {
      _showForm = false;
      editingAddressId = null;
      editingAddressData = null;
    });
  }

  Future<void> _saveAddress(Map<String, dynamic> addressData) async {
    setState(() => _isLoading = true);

    try {
      String? error;
      if (editingAddressId != null) {
        error = await updateUserAddress(editingAddressId!, addressData);
      } else {
        error = await addUserAddress(addressData);
      }

      if (error != null) {
        throw Exception(error);
      }

      _showSuccess(editingAddressId != null
          ? 'Adresse modifiée avec succès !'
          : 'Nouvelle adresse ajoutée avec succès !');

      await _loadData();
      _hideForm();
    } catch (e) {
      _showError('Erreur: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
        if (error != null) {
          throw Exception(error);
        }
        _showSuccess('Adresse supprimée avec succès');
        await _loadData();
      } catch (e) {
        _showError('Erreur lors de la suppression: $e');
      }
    }
  }

  Future<void> _setAsDefault(String addressId) async {
    try {
      final error = await setDefaultAddress(addressId);
      if (error != null) {
        throw Exception(error);
      }
      _showSuccess('Adresse définie par défaut');
      if (mounted) {
        setState(() {
          _defaultAddressAnimationKey = UniqueKey();
        });
        await Future.delayed(const Duration(milliseconds: 400));
      }
      await _loadData();
    } catch (e) {
      _showError('Erreur: $e');
    }
  }

  Key _defaultAddressAnimationKey = UniqueKey();

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
            if (!_showForm && addresses.isNotEmpty) ...[
              Text(
                'Mes adresses (${addresses.length})',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: defaultPadding),
              AnimatedSwitcher(
                key: _defaultAddressAnimationKey,
                duration: const Duration(milliseconds: 400),
                transitionBuilder: (Widget child, Animation<double> animation) {
                  return SlideTransition(
                    position: Tween<Offset>(
                      begin: const Offset(0.1, 0),
                      end: Offset.zero,
                    ).animate(animation),
                    child: FadeTransition(
                      opacity: animation,
                      child: child,
                    ),
                  );
                },
                child: Column(
                  key: ValueKey(addresses.map((a) => a['id']).join(',')),
                  children: [
                    ...addresses.map((address) => AddressCard(
                      key: ValueKey(address['id']),
                      address: address,
                      onEdit: () => _showFormForEdit(address),
                      onSetDefault: (address['par_defaut'] ?? 0) != 1
                          ? () => _setAsDefault(address['id'].toString())
                          : null,
                      onDelete: (address['par_defaut'] ?? 0) != 1
                          ? () => _deleteAddress(address['id'].toString())
                          : null,
                    )),
                  ],
                ),
              ),
            ],

            if (_showForm) ...[
              AddressForm(
                initialData: editingAddressData,
                userInfo: currentUserInfo,
                editingAddressId: editingAddressId,
                isLoading: _isLoading,
                onSave: _saveAddress,
                onCancel: editingAddressId != null ? _hideForm : null,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

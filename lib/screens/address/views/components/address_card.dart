import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class AddressCard extends StatelessWidget {
  final Map<String, dynamic> address;
  final VoidCallback onEdit;
  final VoidCallback? onSetDefault;
  final VoidCallback? onDelete;

  const AddressCard({
    super.key,
    required this.address,
    required this.onEdit,
    this.onSetDefault,
    this.onDelete,
  });

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

  String _getPhoneDisplay() {
    if (address['telephone'] == null || address['telephone'].isEmpty) return '';

    final tel = address['telephone'].toString();
    if (tel.startsWith('+')) return tel;

    final countryName = address['pays'] ?? 'France';
    final countryCode = _countryCodeFromName(countryName) ?? 'FR';

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
    return indicatif + tel;
  }

  @override
  Widget build(BuildContext context) {
    final isDefault = (address['par_defaut'] ?? 0) == 1;
    final phoneDisplay = _getPhoneDisplay();

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
              // En-tête avec icône et badge
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
                        Text(
                          address['adresse'] ?? '',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        if (address['complement_adresse'] != null &&
                            address['complement_adresse'].toString().isNotEmpty)
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
                          '${address['code_postal'] ?? ''} ${address['ville'] ?? ''}',
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
                          Text(phoneDisplay),
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
                      onPressed: onEdit,
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

                  if (!isDefault && onSetDefault != null) ...[
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: onSetDefault,
                        icon: const Icon(Icons.star_outline, size: 18),
                        label: const Text('Par défaut'),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    IconButton(
                      onPressed: onDelete,
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
}

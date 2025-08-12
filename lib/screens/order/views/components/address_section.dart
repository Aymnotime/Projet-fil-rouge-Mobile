import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/services/api/address_api.dart';
import 'package:shop/route/screen_export.dart';

class AddressSection extends StatelessWidget {
  final List<Map<String, dynamic>> addresses;
  final int? selectedAddressIndex;
  final Function(int) onSelectAddress;
  final VoidCallback onManageAddresses;

  const AddressSection({
    super.key,
    required this.addresses,
    required this.selectedAddressIndex,
    required this.onSelectAddress,
    required this.onManageAddresses,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 6,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      margin: const EdgeInsets.only(bottom: defaultPadding),
      color: Colors.white,
      shadowColor: Colors.black12,
      child: Padding(
        padding: const EdgeInsets.all(22),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: primaryColor, size: 30),
                const SizedBox(width: 14),
                const Text('Adresse de livraison', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 14),
            if (addresses.isEmpty)
              const Text('Aucune adresse enregistrée.', style: TextStyle(color: Colors.grey)),
            ...addresses.asMap().entries.map((entry) {
              final i = entry.key;
              final address = entry.value;
              final isSelected = i == selectedAddressIndex;
              final isDefault = (address['par_defaut'] ?? 0) == 1;
              return Card(
                elevation: isSelected ? 8 : 4,
                margin: const EdgeInsets.only(bottom: 12),
                color: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: isSelected ? BorderSide(color: primaryColor, width: 2) : BorderSide.none,
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => onSelectAddress(i),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: isDefault ? primaryColor.withOpacity(0.10) : Colors.grey.withOpacity(0.10),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isDefault ? Icons.home : Icons.location_on_outlined,
                                color: isDefault ? primaryColor : Colors.grey[600],
                                size: 22,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    address['adresse'] ?? '',
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                  ),
                                  if (isDefault)
                                    Container(
                                      margin: const EdgeInsets.only(top: 4),
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: primaryColor.withOpacity(0.08),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        'Par défaut',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: primaryColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            if (isSelected)
                              Icon(Icons.check_circle, color: primaryColor),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(14),
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
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(Icons.public, size: 16, color: Colors.grey[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    address['pays'] ?? 'France',
                                    style: Theme.of(context).textTheme.bodyMedium,
                                  ),
                                ],
                              ),
                              if (address['telephone'] != null && address['telephone'].toString().isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                                    const SizedBox(width: 8),
                                    Text(
                                      address['telephone'].toString().startsWith('+')
                                          ? address['telephone'].toString()
                                          : '+33${address['telephone']}',
                                      style: Theme.of(context).textTheme.bodyMedium,
                                    ),
                                  ],
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: onManageAddresses,
                icon: const Icon(Icons.settings),
                label: const Text('Gérer mes adresses'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

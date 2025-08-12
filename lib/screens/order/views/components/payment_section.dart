import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class PaymentSection extends StatelessWidget {
  final List<Map<String, dynamic>> cards;
  final int? selectedCardIndex;
  final Function(int) onSelectCard;
  final VoidCallback onAddCard;
  final VoidCallback onManageCards;

  const PaymentSection({
    super.key,
    required this.cards,
    required this.selectedCardIndex,
    required this.onSelectCard,
    required this.onAddCard,
    required this.onManageCards,
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
                Icon(Icons.credit_card, color: primaryColor, size: 30),
                const SizedBox(width: 14),
                const Text('Moyen de paiement', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              ],
            ),
            const SizedBox(height: 14),
            if (cards.isEmpty)
              TextButton.icon(
                onPressed: onAddCard,
                icon: const Icon(Icons.add),
                label: const Text('Ajouter une carte'),
                style: TextButton.styleFrom(
                  foregroundColor: primaryColor,
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              )
            else ...[
              ...cards.asMap().entries.map((entry) {
                final i = entry.key;
                final card = entry.value;
                final isSelected = i == selectedCardIndex;
                final isDefault = (card['par_defaut'] ?? 0) == 1;
                return Card(
                  elevation: isSelected ? 8 : 4,
                  margin: const EdgeInsets.only(bottom: 10),
                  color: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: isSelected ? BorderSide(color: primaryColor, width: 2) : BorderSide.none,
                  ),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(16),
                    onTap: () => onSelectCard(i),
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
                                  Icons.credit_card,
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
                                      '**** ${card['last4']}',
                                      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600),
                                    ),
                                    Text(
                                      'Exp: ${card['exp_month']}/${card['exp_year']}',
                                      style: TextStyle(color: Colors.grey[700], fontSize: 14),
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
                        ],
                      ),
                    ),
                  ),
                );
              }),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: onManageCards,
                  icon: const Icon(Icons.settings),
                  label: const Text('Gérer mes cartes'),
                  style: TextButton.styleFrom(
                    foregroundColor: primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

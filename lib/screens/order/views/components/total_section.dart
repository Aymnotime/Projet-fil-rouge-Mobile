import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class TotalSection extends StatelessWidget {
  final num subTotal;
  final num tva;
  final num livraison;
  final num remise;
  final num total;
  final bool isLoadingPayment;
  final VoidCallback? onCommander;
  final bool isCommanderEnabled;

  const TotalSection({
    super.key,
    required this.subTotal,
    required this.tva,
    required this.livraison,
    required this.remise,
    required this.total,
    required this.isLoadingPayment,
    required this.onCommander,
    required this.isCommanderEnabled,
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
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Sous-total', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('${subTotal.toStringAsFixed(2)} €'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('TVA (20%)', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('${tva.toStringAsFixed(2)} €'),
              ],
            ),
            const SizedBox(height: 6),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Livraison', style: TextStyle(fontWeight: FontWeight.w500)),
                Text('${livraison.toStringAsFixed(2)} €'),
              ],
            ),
            const SizedBox(height: 6),
            if (remise > 0)
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Remise', style: TextStyle(fontWeight: FontWeight.w500, color: Colors.green)),
                  Text('-${remise.toStringAsFixed(2)} €', style: const TextStyle(color: Colors.green)),
                ],
              ),
            const Divider(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total à payer', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text('${total.toStringAsFixed(2)} €', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: primaryColor)),
              ],
            ),
            const SizedBox(height: 22),
            isLoadingPayment
                ? const Center(child: CircularProgressIndicator())
                : ElevatedButton.icon(
              onPressed: isCommanderEnabled ? onCommander : null,
              icon: const Icon(Icons.check_circle),
              label: const Text('Commander'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 18),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

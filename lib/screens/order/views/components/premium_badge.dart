import 'package:flutter/material.dart';

class PremiumBadge extends StatelessWidget {
  const PremiumBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.12),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
              border: Border.all(color: Colors.green, width: 1.2),
            ),
            child: Row(
              children: [
                Icon(Icons.verified, color: Colors.green, size: 22),
                const SizedBox(width: 8),
                Text('Paiement sécurisé', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../../../../constants.dart';

class UnitPrice extends StatelessWidget {
  const UnitPrice({
    super.key,
    required this.price,
    this.prixPromo,
  });

  final double price;
  final double? prixPromo;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Prix unitaire",
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: defaultPadding / 1),
        Text.rich(
          TextSpan(
            text: prixPromo == null
                ? "${price.toStringAsFixed(2)} €  "
                : "${prixPromo!.toStringAsFixed(2)} €  ",
            style: Theme.of(context).textTheme.titleLarge,
            children: [
              if (prixPromo != null)
                TextSpan(
                  text: "${price.toStringAsFixed(2)} €",
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: Theme.of(context).textTheme.bodyMedium!.color,
                      decoration: TextDecoration.lineThrough),
                ),
            ],
          ),
        )
      ],
    );
  }
}

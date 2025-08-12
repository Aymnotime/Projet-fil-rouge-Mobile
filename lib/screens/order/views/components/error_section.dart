import 'package:flutter/material.dart';

class ErrorSection extends StatelessWidget {
  final String? error;
  const ErrorSection({super.key, required this.error});

  @override
  Widget build(BuildContext context) {
    if (error == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(top: 8),
      child: Text(error!, style: const TextStyle(color: Colors.red)),
    );
  }
}

import 'package:flutter/material.dart';

import '../../network_image_with_loader.dart';

class BannerM extends StatelessWidget {
  const BannerM({
    super.key,
    required this.image,
    required this.press,
    required this.children,
  });

  final String image;
  final VoidCallback press;
  final List<Widget> children;

  bool get isNetworkImage =>
      image.startsWith('http://') || image.startsWith('https://');

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.87,
      child: GestureDetector(
        onTap: press,
        child: Stack(
          fit: StackFit.expand,
          children: [
            isNetworkImage
                ? NetworkImageWithLoader(image, radius: 0)
                : Image.asset(
              image,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Erreur de chargement d\'image: $error');
                return Container(
                  color: Colors.grey.shade300,
                  child: const Center(
                    child: Icon(Icons.error, color: Colors.red),
                  ),
                );
              },
            ),
            Container(color: Colors.black45),
            ...children,
          ],
        ),
      ),
    );
  }
}

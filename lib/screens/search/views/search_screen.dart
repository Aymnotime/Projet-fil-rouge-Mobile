import 'package:flutter/material.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  List<ProductModel> allProducts = [];
  List<ProductModel> suggestions = [];
  bool isLoading = true;
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final items = await fetchStockItems();
      final products = items.map((item) => ProductModel.fromJson(item)).toList();
      setState(() {
        allProducts = products;
        isLoading = false;
      });
    } catch (e, stack) {
      debugPrint('Erreur dans fetchProducts: $e');
      debugPrint(stack.toString());
      setState(() {
        isLoading = false;
      });
    }
  }

  void _onSearchChanged(String? query) {
    setState(() {
      searchQuery = query?.trim() ?? '';
      if (searchQuery.isEmpty) {
        suggestions = [];
      } else {
        suggestions = allProducts.where((p) =>
        p.title.toLowerCase().contains(searchQuery.toLowerCase()) ||
            (p.brandName.toLowerCase().contains(searchQuery.toLowerCase()) ?? false)
        ).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Recherche de produits'),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 0.5,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: SizedBox(
                width: 480,
                child: TextField(
                  autofocus: true,
                  onChanged: _onSearchChanged,
                  decoration: InputDecoration(
                    hintText: 'Rechercher un produit, une marque...',
                    prefixIcon: const Icon(Icons.search, color: Colors.black54),
                    filled: true,
                    fillColor: Colors.grey[100],
                    contentPadding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(16),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(fontSize: 16),
                  textInputAction: TextInputAction.search,
                  onSubmitted: (val) {
                    if (suggestions.isNotEmpty) {
                      Navigator.pushNamed(
                        context,
                        productDetailsScreenRoute,
                        arguments: suggestions.first,
                      );
                    }
                  },
                ),
              ),
            ),
            const SizedBox(height: 24),
            if (searchQuery.isNotEmpty)
              Expanded(
                child: suggestions.isEmpty
                    ? const Center(
                  child: Text(
                    'Aucun produit trouvé',
                    style: TextStyle(fontSize: 18, color: Colors.black54, fontWeight: FontWeight.w500),
                  ),
                )
                    : ListView.separated(
                  itemCount: suggestions.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final p = suggestions[index];
                    return ListTile(
                      leading: p.image != null && p.image.isNotEmpty
                          ? ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(p.image, width: 48, height: 48, fit: BoxFit.cover),
                      )
                          : const Icon(Icons.image_not_supported, size: 40, color: Colors.grey),
                      title: Text(p.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(p.brandName ?? '', maxLines: 1, overflow: TextOverflow.ellipsis),
                      trailing: Text('${p.priceAfterDiscount?.toStringAsFixed(2) ?? p.price.toStringAsFixed(2)} €', style: const TextStyle(fontWeight: FontWeight.bold)),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          productDetailsScreenRoute,
                          arguments: p,
                        );
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
    );
  }
}

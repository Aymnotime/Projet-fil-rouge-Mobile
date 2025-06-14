import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/auth_service.dart';
import '../../search/views/components/search_form.dart';

import '../../../constants.dart';

class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  List<ProductModel> allProducts = [];
  List<ProductModel> filteredProducts = [];
  bool isLoading = true;

  // Filtres
  List<String> selectedCategories = [];
  String? selectedBrand;
  double minPrice = 0;
  double maxPrice = 1000;
  double currentMinPrice = 0;
  double currentMaxPrice = 1000;
  bool onlyPromo = false;
  bool showFilters = false; // Ajouté pour afficher/masquer le panneau de filtres

  List<String> categories = [];
  List<String> brands = [];

  @override
  void initState() {
    super.initState();
    fetchProducts();
  }

  Future<void> fetchProducts() async {
    try {
      final items = await fetchStockItems();
      final products = items.map((item) => ProductModel.fromJson(item)).toList();
      // Récupère toutes les catégories uniques (même multiples par produit)
      final Set<String> cats = {};
      for (final p in products) {
        if (p.categorie != null && p.categorie!.isNotEmpty) {
          // Si plusieurs catégories séparées par virgule ou point-virgule
          final splitCats = p.categorie!.split(RegExp(r'[;,]')).map((e) => e.trim()).where((e) => e.isNotEmpty);
          cats.addAll(splitCats);
        }
      }
      final brs = products.map((p) => p.brandName ?? '').toSet().toList()..removeWhere((e) => e.isEmpty);
      // Récupère min/max prix
      final prices = products.map((p) => p.price).toList();
      final minP = prices.isNotEmpty ? prices.reduce((a, b) => a < b ? a : b).toDouble() : 0.0;
      final maxP = prices.isNotEmpty ? prices.reduce((a, b) => a > b ? a : b).toDouble() : 1000.0;
      setState(() {
        allProducts = products;
        filteredProducts = products;
        categories = cats.toList();
        brands = brs;
        minPrice = minP;
        maxPrice = maxP;
        currentMinPrice = minP;
        currentMaxPrice = maxP;
        selectedCategories = [];
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

  void _filterProducts({String? search}) {
    setState(() {
      filteredProducts = allProducts.where((p) {
        final matchSearch = search == null || search.isEmpty || p.title.toLowerCase().contains(search.toLowerCase());
        // Gestion multi-catégories par produit
        final prodCats = (p.categorie ?? '').split(RegExp(r'[;,]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        final matchCategory = selectedCategories.isEmpty || prodCats.any((cat) => selectedCategories.contains(cat));
        final matchBrand = selectedBrand == null || selectedBrand == '' || p.brandName == selectedBrand;
        final matchPrice = p.price >= currentMinPrice && p.price <= currentMaxPrice;
        final matchPromo = !onlyPromo || (p.discountPercent != null && p.discountPercent! > 0);
        return matchSearch && matchCategory && matchBrand && matchPrice && matchPromo;
      }).toList();
    });
  }

  void _searchProducts(String? query) {
    _filterProducts(search: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Nos produits',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: MediaQuery.of(context).size.width * 0.4, // 40% de la largeur
                      height: 2.2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Theme.of(context).primaryColor.withOpacity(0.7),
                            Colors.black.withOpacity(0.18),
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: [
                          BoxShadow(
                            color: Theme.of(context).primaryColor.withOpacity(0.10),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  SearchForm(
                    onChanged: _searchProducts,
                    onTabFilter: () {
                      setState(() {
                        showFilters = !showFilters;
                      });
                    },
                  ),
                  if (showFilters) ...[
                    const SizedBox(height: 12),
                    Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).inputDecorationTheme.fillColor ?? Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.08),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ],
                        border: Border.all(
                          color: Theme.of(context).dividerColor.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      margin: EdgeInsets.zero,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Filtres', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.black)),
                            const SizedBox(height: 14),
                            const Text('Catégories', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            ...categories.map((cat) => Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: CheckboxListTile(
                                value: selectedCategories.contains(cat),
                                title: Text(cat, style: const TextStyle(fontWeight: FontWeight.w500)),
                                contentPadding: EdgeInsets.zero,
                                controlAffinity: ListTileControlAffinity.leading,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                activeColor: Theme.of(context).primaryColor,
                                onChanged: (checked) {
                                  setState(() {
                                    if (checked == true) {
                                      selectedCategories.add(cat);
                                    } else {
                                      selectedCategories.remove(cat);
                                    }
                                  });
                                  _filterProducts();
                                },
                              ),
                            )),
                            const SizedBox(height: 12),
                            const Text('Marque', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.white, // fond blanc pour le dropdown
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.black12),
                              ),
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: selectedBrand,
                                  hint: const Text('Toutes', style: TextStyle(fontWeight: FontWeight.w500)),
                                  isExpanded: true,
                                  borderRadius: BorderRadius.circular(8),
                                  style: const TextStyle(fontWeight: FontWeight.w500, color: Colors.black),
                                  dropdownColor: Colors.white, // fond blanc pour la liste déroulante
                                  items: [const DropdownMenuItem(value: '', child: Text('Toutes')),
                                    ...brands.map((b) => DropdownMenuItem(value: b, child: Text(b)))
                                  ],
                                  onChanged: (val) {
                                    setState(() => selectedBrand = val == '' ? null : val);
                                    _filterProducts();
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 12),
                            const Text('Prix', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                            RangeSlider(
                              min: minPrice,
                              max: maxPrice,
                              divisions: (maxPrice - minPrice).toInt() > 0 ? (maxPrice - minPrice).toInt() : null,
                              values: RangeValues(currentMinPrice, currentMaxPrice),
                              labels: RangeLabels(
                                currentMinPrice.toStringAsFixed(0),
                                currentMaxPrice.toStringAsFixed(0),
                              ),
                              activeColor: Theme.of(context).primaryColor,
                              onChanged: (values) {
                                setState(() {
                                  currentMinPrice = values.start;
                                  currentMaxPrice = values.end;
                                });
                                _filterProducts();
                              },
                            ),
                            Row(
                              children: [
                                Checkbox(
                                  value: onlyPromo,
                                  activeColor: Theme.of(context).primaryColor,
                                  onChanged: (val) {
                                    setState(() => onlyPromo = val ?? false);
                                    _filterProducts();
                                  },
                                ),
                                const Text('En promotion', style: TextStyle(fontWeight: FontWeight.w500)),
                              ],
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    setState(() {
                                      showFilters = false;
                                    });
                                  },
                                  style: TextButton.styleFrom(
                                    foregroundColor: Colors.black,
                                    textStyle: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  child: const Text('Fermer'),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  // ... le reste (plus de Wrap de filtres ici)
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: defaultPadding,
              vertical: defaultPadding,
            ),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 200.0,
                mainAxisSpacing: defaultPadding,
                crossAxisSpacing: defaultPadding,
                childAspectRatio: 0.66,
              ),
              delegate: SliverChildBuilderDelegate(
                    (BuildContext context, int index) {
                  final product = filteredProducts[index];
                  return ProductCard(
                    image: product.image,
                    title: product.title,
                    brandName: product.brandName,
                    price: product.price,
                    priceAfterDiscount: product.priceAfterDiscount,
                    discountPercent: product.discountPercent,
                    categorie: product.categorie,
                    press: () {
                      Navigator.pushNamed(
                        context,
                        productDetailsScreenRoute,
                        arguments: product,
                      );
                    },
                  );
                },
                childCount: filteredProducts.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shop/components/product/product_card.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/route/route_constants.dart';
import 'package:shop/services/api/product_api.dart';
import '../components/filters_screen.dart';
import '../../search/views/components/search_form.dart';
import 'package:shop/constants.dart';


class ProductsScreen extends StatefulWidget {
  const ProductsScreen({super.key});

  @override
  State<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends State<ProductsScreen> {
  // Carrousel supprimé : ProductsScreen ne gère que la liste filtrable
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
  bool showFilters = false; // Pour afficher/masquer le panneau de filtres

  List<String> categories = [];
  List<String> brands = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;
      String? initialCategory;
      if (args is Map && args['category'] is String) {
        initialCategory = args['category'] as String;
      }
      fetchProducts(initialCategory: initialCategory);
    });
  }

  Future<void> fetchProducts({String? initialCategory}) async {
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
        categories = cats.toList();
        brands = brs;
        minPrice = minP;
        maxPrice = maxP;
        currentMinPrice = minP;
        currentMaxPrice = maxP;
        selectedCategories = initialCategory != null ? [initialCategory] : [];
        isLoading = false;
      });
      _filterProducts();
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
        // Un produit est en promo si prix_promo existe, > 0 et < prix
        final isPromo = p.prix_promo != null && p.prix_promo! > 0 && p.prix_promo! < p.price;
        final matchPromo = !onlyPromo || isPromo;
        return matchSearch && matchCategory && matchBrand && matchPrice && matchPromo;
      }).toList();
    });
  }

  void _openFiltersScreen() async {
    setState(() {
      showFilters = true;
    });
  }

  void _closeFilters() {
    setState(() {
      showFilters = false;
    });
  }

  void _applyFilters(Map<String, dynamic> filters) {
    setState(() {
      selectedCategories = List<String>.from(filters['selectedCategories']);
      selectedBrand = filters['selectedBrand'];
      currentMinPrice = filters['currentMinPrice'];
      currentMaxPrice = filters['currentMaxPrice'];
      onlyPromo = filters['onlyPromo'];
      showFilters = false;
    });
    _filterProducts();
  }

  void _searchProducts(String? query) {
    _filterProducts(search: query);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: showFilters
          ? FiltersPanel(
        selectedCategories: selectedCategories,
        selectedBrand: selectedBrand,
        minPrice: minPrice,
        maxPrice: maxPrice,
        currentMinPrice: currentMinPrice,
        currentMaxPrice: currentMaxPrice,
        onlyPromo: onlyPromo,
        categories: categories,
        brands: brands,
        onClose: _closeFilters,
        onApplyFilters: _applyFilters,
      )
          : isLoading
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
                    onTabFilter: _openFiltersScreen,
                  ),
                  const SizedBox(height: 16),
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
                    prixPromo: product.prix_promo,
                    price: product.price,
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

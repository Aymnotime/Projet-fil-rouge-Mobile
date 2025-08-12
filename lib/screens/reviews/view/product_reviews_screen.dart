import 'package:flutter/material.dart';
import 'package:shop/constants.dart';
import 'package:shop/models/product_model.dart';
import 'package:shop/services/api/review_api.dart';


class ProductReviewsScreen extends StatefulWidget {
  const ProductReviewsScreen({super.key});

  @override
  State<ProductReviewsScreen> createState() => _ProductReviewsScreenState();
}

class _ProductReviewsScreenState extends State<ProductReviewsScreen> {
  List<Map<String, dynamic>> reviews = [];
  bool isLoading = true;
  bool isLoadingAdd = false;
  ProductModel? product;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments;
    print('Arguments reçus: $args'); // Debug
    if (args is ProductModel) {
      product = args;
      print('Produit ID: ${product!.id}'); // Debug
      _loadReviews();
    } else {
      print('Erreur: arguments ne sont pas un ProductModel, type: ${args.runtimeType}'); // Debug
    }
  }

  Future<void> _loadReviews() async {
    if (product == null) return;

    setState(() => isLoading = true);
    try {
      final reviewsData = await fetchProductReviews(product!.id);
      setState(() {
        reviews = reviewsData;
        isLoading = false;
      });
    } catch (e) {
      setState(() => isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: $e')),
        );
      }
    }
  }

  Future<void> _showAddReviewDialog() async {
    if (product == null) return;

    int selectedRating = 5;
    final titreController = TextEditingController();
    final commentaireController = TextEditingController();
    final GlobalKey<FormState> formKey = GlobalKey<FormState>();

    await showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Ajouter un avis', style: TextStyle(fontWeight: FontWeight.bold)),
          content: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Note:', style: TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () {
                          setDialogState(() {
                            selectedRating = index + 1;
                          });
                        },
                        icon: Icon(
                          index < selectedRating ? Icons.star : Icons.star_border,
                          color: Colors.amber,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: titreController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      hintText: 'Titre (optionnel)',
                      prefixIcon: Icon(Icons.title_outlined),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),
                  TextFormField(
                    controller: commentaireController,
                    maxLines: 4,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      hintText: 'Commentaire (optionnel)',
                      prefixIcon: Icon(Icons.comment_outlined),
                    ),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: isLoadingAdd ? null : () async {
                setState(() => isLoadingAdd = true);

                final error = await addProductReview(
                  product!.id,
                  selectedRating,
                  titreController.text.isEmpty ? null : titreController.text,
                  commentaireController.text.isEmpty ? null : commentaireController.text,
                );

                setState(() => isLoadingAdd = false);

                if (error == null) {
                  Navigator.pop(context);
                  _loadReviews(); // Recharger les avis
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Avis ajouté avec succès !'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } else {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(error)),
                    );
                  }
                }
              },
              child: isLoadingAdd
                  ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                  : const Text('Ajouter'),
            ),
          ],
        ),
      ),
    );
  }

  double _calculateAverageRating() {
    if (reviews.isEmpty) return 0.0;
    final total = reviews.fold<int>(0, (sum, review) => sum + (review['note'] as int));
    return total / reviews.length;
  }

  Widget _buildStarRating(double rating, {double size = 16}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < rating.floor()
              ? Icons.star
              : index < rating
              ? Icons.star_half
              : Icons.star_border,
          color: Colors.amber,
          size: size,
        );
      }),
    );
  }

  Widget _buildReviewCard(Map<String, dynamic> review) {
    final DateTime date = DateTime.parse(review['date_creation']);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: defaultPadding, vertical: defaultPadding / 2),
      padding: const EdgeInsets.all(defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: primaryColor,
                child: Text(
                  '${review['prenom'][0]}${review['nom'][0]}',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${review['prenom']} ${review['nom']}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Row(
                      children: [
                        _buildStarRating(review['note'].toDouble()),
                        const SizedBox(width: 8),
                        Text(
                          '${date.day}/${date.month}/${date.year}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (review['titre'] != null && review['titre'].isNotEmpty) ...[
            const SizedBox(height: 12),
            Text(
              review['titre'],
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
          ],
          if (review['commentaire'] != null && review['commentaire'].isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              review['commentaire'],
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (product == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Avis')),
        body: const Center(child: Text('Produit non trouvé')),
      );
    }

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final averageRating = _calculateAverageRating();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Avis clients'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // En-tête avec gradient similaire à user_info_screen
            Container(
              height: 200,
              width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [primaryColor, Color(0xFF1976D2)],
                ),
              ),
              child: const Icon(
                Icons.rate_review,
                size: 80,
                color: Colors.white,
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Avis clients",
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: defaultPadding / 2),
                  Text("Découvrez les avis sur ${product!.title}"),
                  const SizedBox(height: defaultPadding),

                  // Statistiques des avis
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(defaultPadding),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Column(
                      children: [
                        if (reviews.isNotEmpty) ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              _buildStarRating(averageRating, size: 24),
                              const SizedBox(width: 8),
                              Text(
                                '${averageRating.toStringAsFixed(1)} (${reviews.length} avis)',
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ] else ...[
                          const Text(
                            'Aucun avis pour le moment',
                            style: TextStyle(fontSize: 16, color: Colors.grey),
                          ),
                        ],
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _showAddReviewDialog,
                          icon: const Icon(Icons.add),
                          label: const Text('Ajouter un avis'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: defaultPadding * 2),

                  // Liste des avis
                  if (reviews.isEmpty) ...[
                    Center(
                      child: Column(
                        children: [
                          Icon(Icons.rate_review_outlined, size: 64, color: Colors.grey.shade400),
                          const SizedBox(height: 16),
                          Text(
                            'Aucun avis pour ce produit',
                            style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Soyez le premier à laisser un avis !',
                            style: TextStyle(color: Colors.grey.shade500),
                          ),
                        ],
                      ),
                    ),
                  ] else ...[
                    Text(
                      "Tous les avis (${reviews.length})",
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: defaultPadding),
                    ...reviews.map((review) => _buildReviewCard(review)),
                  ],

                  const SizedBox(height: defaultPadding),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:shop/constants.dart';

class FiltersPanel extends StatefulWidget {
  final List<String> selectedCategories;
  final String? selectedBrand;
  final double minPrice;
  final double maxPrice;
  final double currentMinPrice;
  final double currentMaxPrice;
  final bool onlyPromo;
  final List<String> categories;
  final List<String> brands;
  final VoidCallback onClose;
  final Function(Map<String, dynamic>) onApplyFilters;

  const FiltersPanel({
    super.key,
    required this.selectedCategories,
    required this.selectedBrand,
    required this.minPrice,
    required this.maxPrice,
    required this.currentMinPrice,
    required this.currentMaxPrice,
    required this.onlyPromo,
    required this.categories,
    required this.brands,
    required this.onClose,
    required this.onApplyFilters,
  });

  @override
  State<FiltersPanel> createState() => _FiltersPanelState();
}

class _FiltersPanelState extends State<FiltersPanel> {
  late List<String> _selectedCategories;
  late String? _selectedBrand;
  late double _currentMinPrice;
  late double _currentMaxPrice;
  late bool _onlyPromo;

  @override
  void initState() {
    super.initState();
    _selectedCategories = List.from(widget.selectedCategories);
    _selectedBrand = widget.selectedBrand;
    _currentMinPrice = widget.currentMinPrice;
    _currentMaxPrice = widget.currentMaxPrice;
    _onlyPromo = widget.onlyPromo;
  }

  void _resetFilters() {
    setState(() {
      _selectedCategories.clear();
      _selectedBrand = null;
      _currentMinPrice = widget.minPrice;
      _currentMaxPrice = widget.maxPrice;
      _onlyPromo = false;
    });
  }

  void _applyFilters() {
    widget.onApplyFilters({
      'selectedCategories': _selectedCategories,
      'selectedBrand': _selectedBrand,
      'currentMinPrice': _currentMinPrice,
      'currentMaxPrice': _currentMaxPrice,
      'onlyPromo': _onlyPromo,
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Column(
        children: [
          // En-tête avec design similaire à delivery_address_screen
          Container(
            padding: const EdgeInsets.all(defaultPadding * 1.5),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.tune,
                    color: primaryColor,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Filtres de recherche',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Affinez votre recherche de produits',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                TextButton(
                  onPressed: _resetFilters,
                  child: Text(
                    'Réinitialiser',
                    style: TextStyle(color: primaryColor),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  tooltip: 'Fermer',
                ),
              ],
            ),
          ),

          // Contenu des filtres
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Section Catégories
                  _buildFilterCard(
                    title: 'Catégories',
                    icon: Icons.category_outlined,
                    child: Column(
                      children: widget.categories.map((cat) =>
                          _buildCheckboxTile(
                            title: cat,
                            value: _selectedCategories.contains(cat),
                            onChanged: (checked) {
                              setState(() {
                                if (checked == true) {
                                  _selectedCategories.add(cat);
                                } else {
                                  _selectedCategories.remove(cat);
                                }
                              });
                            },
                          ),
                      ).toList(),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),

                  // Section Marques
                  _buildFilterCard(
                    title: 'Marque',
                    icon: Icons.branding_watermark_outlined,
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[50],
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _selectedBrand,
                          hint: Text(
                            'Toutes les marques',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          isExpanded: true,
                          dropdownColor: Colors.white,
                          items: [
                            const DropdownMenuItem(
                              value: null,
                              child: Text('Toutes les marques'),
                            ),
                            ...widget.brands.map((brand) => DropdownMenuItem(
                              value: brand,
                              child: Text(brand),
                            )),
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedBrand = value;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: defaultPadding),

                  // Section Prix
                  _buildFilterCard(
                    title: 'Gamme de prix',
                    icon: Icons.euro_outlined,
                    child: Column(
                      children: [
                        RangeSlider(
                          min: widget.minPrice,
                          max: widget.maxPrice,
                          divisions: (widget.maxPrice - widget.minPrice).toInt() > 0
                              ? (widget.maxPrice - widget.minPrice).toInt()
                              : null,
                          values: RangeValues(_currentMinPrice, _currentMaxPrice),
                          labels: RangeLabels(
                            '${_currentMinPrice.toStringAsFixed(0)}€',
                            '${_currentMaxPrice.toStringAsFixed(0)}€',
                          ),
                          activeColor: primaryColor,
                          onChanged: (values) {
                            setState(() {
                              _currentMinPrice = values.start;
                              _currentMaxPrice = values.end;
                            });
                          },
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_currentMinPrice.toStringAsFixed(0)}€',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: Colors.grey[100],
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${_currentMaxPrice.toStringAsFixed(0)}€',
                                style: const TextStyle(fontWeight: FontWeight.w500),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: defaultPadding),

                  // Section Promotions
                  _buildFilterCard(
                    title: 'Promotions',
                    icon: Icons.local_offer_outlined,
                    child: _buildSwitchTile(
                      title: 'Produits en promotion uniquement',
                      subtitle: 'Afficher seulement les articles en promotion',
                      value: _onlyPromo,
                      onChanged: (value) {
                        setState(() {
                          _onlyPromo = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Boutons d'action (similaire à delivery_address_screen)
          Container(
            padding: const EdgeInsets.all(defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: widget.onClose,
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Annuler'),
                  ),
                ),
                const SizedBox(width: defaultPadding),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _applyFilters,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Appliquer'),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterCard({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      margin: EdgeInsets.zero,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(defaultPadding * 1.5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(
                    icon,
                    color: primaryColor,
                    size: 16,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: defaultPadding),
            child,
          ],
        ),
      ),
    );
  }

  Widget _buildCheckboxTile({
    required String title,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 4),
      child: CheckboxListTile(
        value: value,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        contentPadding: EdgeInsets.zero,
        controlAffinity: ListTileControlAffinity.leading,
        activeColor: primaryColor,
        onChanged: onChanged,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: SwitchListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(color: Colors.grey[600]),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: primaryColor,
      ),
    );
  }
}

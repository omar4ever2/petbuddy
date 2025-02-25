import 'package:flutter/material.dart';
import '../widgets/product_card.dart';
import '../services/supabase_service.dart';
import 'package:provider/provider.dart';

class CategoriesPage extends StatefulWidget {
  final String? categoryId;
  final String? categoryName;

  const CategoriesPage({
    Key? key,
    this.categoryId,
    this.categoryName,
  }) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _categories = [];
  List<Map<String, dynamic>> _products = [];
  String? _selectedCategoryId;
  String? _selectedCategoryName;

  @override
  void initState() {
    super.initState();
    _selectedCategoryId = widget.categoryId;
    _selectedCategoryName = widget.categoryName;
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      
      // Load categories
      final categories = await supabaseService.getCategories();
      setState(() {
        _categories = categories;
      });

      // If a category is selected, load its products
      if (_selectedCategoryId != null) {
        _loadProductsByCategory(_selectedCategoryId!);
      } else if (_categories.isNotEmpty) {
        // Otherwise, select the first category
        _selectedCategoryId = _categories[0]['id'];
        _selectedCategoryName = _categories[0]['name'];
        _loadProductsByCategory(_selectedCategoryId!);
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading categories: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadProductsByCategory(String categoryId) async {
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      final products = await supabaseService.getProductsByCategory(categoryId);
      
      setState(() {
        _products = products;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading products: $e');
      setState(() {
        _products = [];
        _isLoading = false;
      });
    }
  }

  void _selectCategory(String categoryId, String categoryName) {
    setState(() {
      _selectedCategoryId = categoryId;
      _selectedCategoryName = categoryName;
      _isLoading = true;
    });
    _loadProductsByCategory(categoryId);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_selectedCategoryName ?? 'Categories'),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : Column(
              children: [
                // Category tabs
                SizedBox(
                  height: 50,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: _categories.length,
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    itemBuilder: (context, index) {
                      final category = _categories[index];
                      final isSelected = category['id'] == _selectedCategoryId;
                      
                      return GestureDetector(
                        onTap: () => _selectCategory(
                          category['id'],
                          category['name'],
                        ),
                        child: Container(
                          margin: const EdgeInsets.only(right: 12),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          decoration: BoxDecoration(
                            color: isSelected
                                ? const Color(0xFF5C6BC0)
                                : Colors.grey[200],
                            borderRadius: BorderRadius.circular(25),
                          ),
                          child: Center(
                            child: Text(
                              category['name'],
                              style: TextStyle(
                                color: isSelected ? Colors.white : Colors.black,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
                
                // Products grid
                Expanded(
                  child: _products.isEmpty
                      ? const Center(
                          child: Text('No products found in this category'),
                        )
                      : GridView.builder(
                          padding: const EdgeInsets.all(16),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 2,
                            childAspectRatio: 0.7,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                          ),
                          itemCount: _products.length,
                          itemBuilder: (context, index) {
                            final product = _products[index];
                            return ProductCard(
                              id: product['id'],
                              name: product['name'],
                              price: (product['price'] as num).toDouble(),
                              imageUrl: product['image'] ?? '',
                              discountPrice: product['discount_price'] != null
                                  ? (product['discount_price'] as num).toDouble()
                                  : null,
                              rating: product['average_rating'] != null
                                  ? (product['average_rating'] as num).toDouble()
                                  : 0.0,
                            );
                          },
                        ),
                ),
              ],
            ),
    );
  }
} 
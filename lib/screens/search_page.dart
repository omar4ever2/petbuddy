import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _searchHistory = [];
  final List<String> _suggestions = [
    'Dog food',
    'Cat toys',
    'Fish tank',
    'Bird cage',
    'Pet carrier',
  ];

  // All products from all categories
  final List<Map<String, dynamic>> _allProducts = [
    // Dogs
    {
      'id': 'dog-food-premium',
      'name': 'Premium Dog Food',
      'price': 29.99,
      'image': 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Dogs',
    },
    {
      'id': 'dog-toy-ball',
      'name': 'Interactive Dog Ball',
      'price': 15.99,
      'image': 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Dogs',
    },
    {
      'id': 'dog-collar-leather',
      'name': 'Leather Dog Collar',
      'price': 24.99,
      'image': 'https://images.unsplash.com/photo-1599839575945-a9e5af0c3fa5?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Dogs',
    },
    // Cats
    {
      'id': 'cat-post',
      'name': 'Cat Scratching Post',
      'price': 49.99,
      'image': 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Cats',
    },
    {
      'id': 'cat-toy-mouse',
      'name': 'Catnip Mouse Toy',
      'price': 7.99,
      'image': 'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Cats',
    },
    // Birds
    {
      'id': 'bird-cage',
      'name': 'Bird Cage Deluxe',
      'price': 89.99,
      'image': 'https://images.unsplash.com/photo-1520808663317-647b476a81b9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Birds',
    },
    // Fish
    {
      'id': 'fish-tank',
      'name': 'Fish Tank Kit',
      'price': 119.99,
      'image': 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Fish',
    },
    // Food & Treats
    {
      'id': 'dog-food-premium-large',
      'name': 'Premium Dog Food (Large Breed)',
      'price': 39.99,
      'image': 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Food & Treats',
    },
    {
      'id': 'cat-treats-salmon',
      'name': 'Salmon Cat Treats',
      'price': 7.99,
      'image': 'https://images.unsplash.com/photo-1583511655826-05700442976d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Food & Treats',
    },
    // Accessories
    {
      'id': 'pet-carrier-deluxe',
      'name': 'Deluxe Pet Carrier',
      'price': 59.99,
      'image': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Accessories',
    },
    {
      'id': 'pet-grooming-kit',
      'name': 'Professional Grooming Kit',
      'price': 49.99,
      'image': 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      'category': 'Accessories',
    },
  ];

  List<Map<String, dynamic>> get _filteredProducts {
    if (_searchQuery.isEmpty) return [];
    
    return _allProducts.where((product) {
      final name = product['name'].toString().toLowerCase();
      final category = product['category'].toString().toLowerCase();
      final query = _searchQuery.toLowerCase();
      
      return name.contains(query) || category.contains(query);
    }).toList();
  }

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
    });
  }

  void _loadSearchHistory() {
    // In a real app, you'd load this from SharedPreferences or a database
    setState(() {
      _searchHistory = ['Dog food', 'Cat toys', 'Fish tank'];
    });
  }

  void _saveSearchQuery(String query) {
    if (query.isEmpty) return;
    
    // Don't add duplicates
    if (_searchHistory.contains(query)) {
      // Move to top if it exists
      _searchHistory.remove(query);
    }
    
    setState(() {
      _searchHistory.insert(0, query);
      // Limit history to 5 items
      if (_searchHistory.length > 5) {
        _searchHistory = _searchHistory.sublist(0, 5);
      }
    });
    
    // In a real app, you'd save this to SharedPreferences or a database
  }

  void _clearSearchHistory() {
    setState(() {
      _searchHistory = [];
    });
    // In a real app, you'd clear this from SharedPreferences or a database
  }

  void _performSearch(String query) {
    _saveSearchQuery(query);
    setState(() {
      _searchQuery = query;
      _searchController.text = query;
    });
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Search for products...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            border: InputBorder.none,
            suffixIcon: _searchController.text.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                    },
                  )
                : null,
          ),
          style: const TextStyle(fontSize: 16),
          textInputAction: TextInputAction.search,
          onSubmitted: _performSearch,
        ),
      ),
      body: _searchQuery.isEmpty
          ? _buildSearchSuggestions()
          : _buildSearchResults(),
    );
  }

  Widget _buildSearchSuggestions() {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_searchHistory.isNotEmpty) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Recent Searches',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: _clearSearchHistory,
                    child: const Text('Clear'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: _searchHistory.map((query) {
                  return GestureDetector(
                    onTap: () => _performSearch(query),
                    child: Chip(
                      label: Text(query),
                      backgroundColor: Colors.grey[200],
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () {
                        setState(() {
                          _searchHistory.remove(query);
                        });
                      },
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
            ],
            const Text(
              'Popular Searches',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _suggestions.map((suggestion) {
                return GestureDetector(
                  onTap: () => _performSearch(suggestion),
                  child: Chip(
                    label: Text(suggestion),
                    backgroundColor: Colors.grey[200],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            const Text(
              'Browse Categories',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              childAspectRatio: 2.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children: [
                _buildCategoryCard('Dogs', Icons.pets),
                _buildCategoryCard('Cats', Icons.content_cut),
                _buildCategoryCard('Birds', Icons.front_hand),
                _buildCategoryCard('Fish', Icons.water),
                _buildCategoryCard('Food & Treats', Icons.fastfood),
                _buildCategoryCard('Accessories', Icons.shopping_bag),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryCard(String title, IconData icon) {
    return GestureDetector(
      onTap: () => _performSearch(title),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 1,
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Row(
            children: [
              Icon(icon, color: const Color(0xFF5C6BC0)),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchResults() {
    final results = _filteredProducts;
    
    if (results.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            const Text(
              'No results found',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Try a different search term',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            '${results.length} results for "${_searchQuery}"',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: GridView.builder(
            padding: const EdgeInsets.all(16),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 0.7,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
            ),
            itemCount: results.length,
            itemBuilder: (context, index) {
              final product = results[index];
              return ProductCard(
                id: product['id'] as String,
                name: product['name'] as String,
                price: product['price'] as double,
                imageUrl: product['image'] as String,
              );
            },
          ),
        ),
      ],
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/product_card.dart';
import '../services/supabase_service.dart';
import 'dart:async';

class SearchPage extends StatefulWidget {
  const SearchPage({Key? key}) : super(key: key);

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  List<String> _searchHistory = [];
  List<Map<String, dynamic>> _searchResults = [];
  bool _isLoading = false;
  Timer? _debounce;
  late AnimationController _animationController;
  late Animation<double> _animation;

  final List<String> _suggestions = [
    'Dog food',
    'Cat toys',
    'Fish tank',
    'Bird cage',
    'Pet carrier',
    'Grooming',
  ];

  final List<Map<String, dynamic>> _categories = [
    {'title': 'Dogs', 'icon': Icons.pets},
    {'title': 'Cats', 'icon': Icons.content_cut},
    {'title': 'Birds', 'icon': Icons.flutter_dash},
    {'title': 'Fish', 'icon': Icons.water},
    {'title': 'Food & Treats', 'icon': Icons.fastfood},
    {'title': 'Accessories', 'icon': Icons.shopping_bag},
  ];

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
    _searchController.addListener(_onSearchChanged);
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    _animation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (_searchController.text.length >= 2) {
        _performSearch(_searchController.text);
      } else {
        setState(() {
          _searchQuery = _searchController.text;
          _searchResults = [];
        });
      }
    });
  }

  void _loadSearchHistory() {
    // In a real app, you'd load this from SharedPreferences or a database
    setState(() {
      _searchHistory = ['Dog food', 'Cat toys', 'Fish tank'];
    });
  }

  void _saveSearchQuery(String query) {
    if (query.isEmpty || query.length < 2) return;
    
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

  Future<void> _performSearch(String query) async {
    if (query.length < 2) return;
    
    setState(() {
      _isLoading = true;
      _searchQuery = query;
    });
    
    try {
      final supabaseService = Provider.of<SupabaseService>(context, listen: false);
      final results = await supabaseService.searchProducts(query);
      
      setState(() {
        _searchResults = results;
        _isLoading = false;
      });
      
      _saveSearchQuery(query);
    } catch (e) {
      print('Error searching products: $e');
      setState(() {
        _isLoading = false;
        _searchResults = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        titleSpacing: 0,
        title: Container(
          height: 48,
          margin: const EdgeInsets.only(right: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search for products...',
              hintStyle: TextStyle(color: Colors.grey[400]),
              prefixIcon: const Icon(Icons.search, color: Color(0xFF5C6BC0)),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                          _searchResults = [];
                        });
                      },
                    )
                  : null,
            ),
            style: const TextStyle(fontSize: 16),
            textInputAction: TextInputAction.search,
            onSubmitted: _performSearch,
          ),
        ),
      ),
      body: _searchQuery.isEmpty
          ? FadeTransition(
              opacity: _animation,
              child: _buildSearchSuggestions(),
            )
          : _isLoading
              ? const Center(child: CircularProgressIndicator())
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
                    child: const Text(
                      'Clear',
                      style: TextStyle(color: Color(0xFF5C6BC0)),
                    ),
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
                      backgroundColor: const Color(0xFF5C6BC0).withOpacity(0.1),
                      labelStyle: const TextStyle(color: Color(0xFF5C6BC0)),
                      deleteIcon: const Icon(Icons.close, size: 16, color: Color(0xFF5C6BC0)),
                      onDeleted: () {
                        setState(() {
                          _searchHistory.remove(query);
                        });
                      },
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
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
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
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
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 2.5,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                return _buildCategoryCard(
                  category['title'] as String,
                  category['icon'] as IconData,
                );
              },
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
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF5C6BC0).withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: const Color(0xFF5C6BC0), size: 20),
              ),
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
    if (_searchResults.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF5C6BC0).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.search_off,
                size: 64,
                color: Color(0xFF5C6BC0),
              ),
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
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () {
                _searchController.clear();
                setState(() {
                  _searchQuery = '';
                  _searchResults = [];
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF5C6BC0),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Clear Search'),
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
            '${_searchResults.length} results for "${_searchQuery}"',
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
            itemCount: _searchResults.length,
            itemBuilder: (context, index) {
              final product = _searchResults[index];
              return ProductCard(
                id: product['id'] as String,
                name: product['name'] as String,
                price: (product['price'] as num).toDouble(),
                imageUrl: product['image_url'] as String? ?? '',
                discountPrice: product['discount_price'] != null 
                    ? (product['discount_price'] as num).toDouble() 
                    : null,
                rating: product['rating'] != null 
                    ? (product['rating'] as num).toDouble() 
                    : 0.0,
              );
            },
          ),
        ),
      ],
    );
  }
} 
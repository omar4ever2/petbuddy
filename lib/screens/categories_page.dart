import 'package:flutter/material.dart';
import '../widgets/category_card.dart';

class CategoriesPage extends StatelessWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample category data
    final categories = [
      {
        'name': 'Dogs',
        'icon': Icons.pets,
        'items': 42,
        'color': const Color(0xFF5C6BC0),
        'image': 'https://images.unsplash.com/photo-1587300003388-59208cc962cb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
      {
        'name': 'Cats',
        'icon': Icons.content_cut,
        'items': 38,
        'color': const Color(0xFFEC407A),
        'image': 'https://images.unsplash.com/photo-1514888286974-6c03e2ca1dba?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
      {
        'name': 'Birds',
        'icon': Icons.front_hand,
        'items': 24,
        'color': const Color(0xFF26A69A),
        'image': 'https://images.unsplash.com/photo-1522926193341-e9ffd686c60f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
      {
        'name': 'Fish',
        'icon': Icons.water,
        'items': 16,
        'color': const Color(0xFF7E57C2),
        'image': 'https://images.unsplash.com/photo-1524704654690-b56c05c78a00?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
      {
        'name': 'Small Pets',
        'icon': Icons.home,
        'items': 19,
        'color': const Color(0xFFEF5350),
        'image': 'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
      {
        'name': 'Reptiles',
        'icon': Icons.pest_control,
        'items': 12,
        'color': const Color(0xFF66BB6A),
        'image': 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
      {
        'name': 'Food & Treats',
        'icon': Icons.fastfood,
        'items': 53,
        'color': const Color(0xFFFFB74D),
        'image': 'https://images.unsplash.com/photo-1568640347023-a616a30bc3bd?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
      {
        'name': 'Accessories',
        'icon': Icons.shopping_bag,
        'items': 67,
        'color': const Color(0xFF42A5F5),
        'image': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'All Categories',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              // Implement search functionality
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.85,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return CategoryCard(
              name: category['name'] as String,
              icon: category['icon'] as IconData,
              items: category['items'] as int,
              color: category['color'] as Color,
              imageUrl: category['image'] as String,
              onTap: () {
                // Navigate to category detail page
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => CategoryDetailPage(
                      categoryName: category['name'] as String,
                      categoryColor: category['color'] as Color,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class CategoryDetailPage extends StatelessWidget {
  final String categoryName;
  final Color categoryColor;

  const CategoryDetailPage({
    Key? key,
    required this.categoryName,
    required this.categoryColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Sample products for this category
    final products = List.generate(
      10,
      (index) => {
        'name': '$categoryName Product ${index + 1}',
        'price': (19.99 + index * 5.0),
        'image': 'https://source.unsplash.com/random/300x200?${categoryName.toLowerCase()}',
      },
    );

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: categoryColor.withOpacity(0.1),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: categoryColor.withOpacity(0.1),
            child: Row(
              children: [
                Text(
                  'Showing ${products.length} products',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: const [
                      Text('Sort by'),
                      SizedBox(width: 4),
                      Icon(Icons.arrow_drop_down, size: 20),
                    ],
                  ),
                ),
              ],
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
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.1),
                        spreadRadius: 1,
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                            child: Image.network(
                              product['image'] as String,
                              height: 150,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  height: 150,
                                  color: Colors.grey[200],
                                  child: const Center(
                                    child: Icon(Icons.error_outline, color: Colors.grey),
                                  ),
                                );
                              },
                            ),
                          ),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.favorite_border,
                                size: 18,
                                color: Colors.red,
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              product['name'] as String,
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '\$${(product['price'] as double).toStringAsFixed(2)}',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: categoryColor,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    color: categoryColor,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                    size: 20,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
} 
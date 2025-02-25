import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/category_card.dart';
import '../widgets/product_card.dart';
import '../providers/cart_provider.dart';
import '../providers/favorites_provider.dart';

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
    // Category-specific products
    final Map<String, List<Map<String, dynamic>>> categoryProducts = {
      'Dogs': [
        {
          'id': 'dog-food-premium',
          'name': 'Premium Dog Food',
          'price': 29.99,
          'image': 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'dog-toy-ball',
          'name': 'Interactive Dog Ball',
          'price': 15.99,
          'image': 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'dog-collar-leather',
          'name': 'Leather Dog Collar',
          'price': 24.99,
          'image': 'https://images.unsplash.com/photo-1599839575945-a9e5af0c3fa5?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'dog-bed-plush',
          'name': 'Plush Dog Bed',
          'price': 49.99,
          'image': 'https://images.unsplash.com/photo-1541599468348-e96984315921?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'dog-leash-retractable',
          'name': 'Retractable Dog Leash',
          'price': 19.99,
          'image': 'https://images.unsplash.com/photo-1567752881298-894bb81f9379?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'dog-treats-organic',
          'name': 'Organic Dog Treats',
          'price': 12.99,
          'image': 'https://images.unsplash.com/photo-1582798358481-d199fb7347bb?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
      ],
      'Cats': [
        {
          'id': 'cat-post-deluxe',
          'name': 'Deluxe Cat Scratching Post',
          'price': 49.99,
          'image': 'https://images.unsplash.com/photo-1545249390-6bdfa286032f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'cat-food-organic',
          'name': 'Organic Cat Food',
          'price': 24.99,
          'image': 'https://images.unsplash.com/photo-1583511655857-d19b40a7a54e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'cat-toy-mouse',
          'name': 'Interactive Mouse Toy',
          'price': 9.99,
          'image': 'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'cat-litter-box',
          'name': 'Self-Cleaning Litter Box',
          'price': 89.99,
          'image': 'https://images.unsplash.com/photo-1555685812-4b8f286e7f30?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'cat-bed-plush',
          'name': 'Plush Cat Bed',
          'price': 34.99,
          'image': 'https://images.unsplash.com/photo-1570018144715-43110363d70a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
      ],
      'Birds': [
        {
          'id': 'bird-cage-deluxe',
          'name': 'Deluxe Bird Cage',
          'price': 89.99,
          'image': 'https://images.unsplash.com/photo-1520808663317-647b476a81b9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'bird-food-premium',
          'name': 'Premium Bird Seed Mix',
          'price': 14.99,
          'image': 'https://images.unsplash.com/photo-1603316468506-b4e34edc2c1e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'bird-toy-swing',
          'name': 'Bird Swing Toy',
          'price': 12.99,
          'image': 'https://images.unsplash.com/photo-1559715541-5daf8a0296d0?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'bird-perch-natural',
          'name': 'Natural Wood Perch',
          'price': 9.99,
          'image': 'https://images.unsplash.com/photo-1556435847-2d48e5a9381d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
      ],
      'Fish': [
        {
          'id': 'fish-tank-kit',
          'name': 'Complete Aquarium Kit',
          'price': 119.99,
          'image': 'https://images.unsplash.com/photo-1522069169874-c58ec4b76be5?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'fish-food-flakes',
          'name': 'Premium Fish Flakes',
          'price': 8.99,
          'image': 'https://images.unsplash.com/photo-1584473457493-17c4c24290c5?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'fish-filter-advanced',
          'name': 'Advanced Aquarium Filter',
          'price': 34.99,
          'image': 'https://images.unsplash.com/photo-1584473457583-88f2315b8b9c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'fish-decor-plants',
          'name': 'Artificial Aquarium Plants',
          'price': 19.99,
          'image': 'https://images.unsplash.com/photo-1584473457568-2af00654cbe9?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
      ],
      'Small Pets': [
        {
          'id': 'hamster-cage-deluxe',
          'name': 'Deluxe Hamster Habitat',
          'price': 49.99,
          'image': 'https://images.unsplash.com/photo-1425082661705-1834bfd09dca?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'rabbit-food-premium',
          'name': 'Premium Rabbit Food',
          'price': 15.99,
          'image': 'https://images.unsplash.com/photo-1585110396000-c9ffd4e4b308?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'guinea-pig-bedding',
          'name': 'Natural Guinea Pig Bedding',
          'price': 12.99,
          'image': 'https://images.unsplash.com/photo-1591871937573-74dbba515c4c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
      ],
      'Reptiles': [
        {
          'id': 'terrarium-kit',
          'name': 'Complete Terrarium Kit',
          'price': 99.99,
          'image': 'https://images.unsplash.com/photo-1504450874802-0ba2bcd9b5ae?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'reptile-heat-lamp',
          'name': 'Reptile Heat Lamp',
          'price': 29.99,
          'image': 'https://images.unsplash.com/photo-1548550023-2bdb3c5beed7?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'reptile-food-crickets',
          'name': 'Live Crickets (50 Pack)',
          'price': 14.99,
          'image': 'https://images.unsplash.com/photo-1567381141228-63e141f38f7a?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
      ],
      'Food & Treats': [
        {
          'id': 'dog-food-premium-large',
          'name': 'Premium Dog Food (Large Breed)',
          'price': 39.99,
          'image': 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'cat-treats-salmon',
          'name': 'Salmon Cat Treats',
          'price': 7.99,
          'image': 'https://images.unsplash.com/photo-1583511655826-05700442976d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'bird-seed-premium',
          'name': 'Premium Bird Seed Mix',
          'price': 12.99,
          'image': 'https://images.unsplash.com/photo-1603316468506-b4e34edc2c1e?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'fish-food-tropical',
          'name': 'Tropical Fish Food',
          'price': 8.99,
          'image': 'https://images.unsplash.com/photo-1584473457493-17c4c24290c5?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
      ],
      'Accessories': [
        {
          'id': 'pet-carrier-deluxe',
          'name': 'Deluxe Pet Carrier',
          'price': 59.99,
          'image': 'https://images.unsplash.com/photo-1583337130417-3346a1be7dee?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'pet-grooming-kit',
          'name': 'Professional Grooming Kit',
          'price': 49.99,
          'image': 'https://images.unsplash.com/photo-1516734212186-a967f81ad0d7?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'pet-water-fountain',
          'name': 'Automatic Water Fountain',
          'price': 39.99,
          'image': 'https://images.unsplash.com/photo-1585499583264-6edc590c5149?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
        {
          'id': 'pet-id-tag',
          'name': 'Personalized Pet ID Tag',
          'price': 9.99,
          'image': 'https://images.unsplash.com/photo-1518155317743-a8ff43ea6a5f?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
        },
      ],
    };

    // Get products for this category
    final products = categoryProducts[categoryName] ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.white,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '${products.length} Products',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
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
            child: products.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.inventory_2_outlined,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No products available',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Check back soon for new items',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
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
      ),
    );
  }
} 
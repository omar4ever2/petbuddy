import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' as io;

class SupabaseService with ChangeNotifier {
  final SupabaseClient _client;
  User? _user;
  Map<String, dynamic> _userData = {};

  SupabaseService(this._client) {
    _init();
  }

  // Initialize and set up auth state listener
  Future<void> _init() async {
    // Set up auth state change listener
    _client.auth.onAuthStateChange.listen((data) {
      final AuthChangeEvent event = data.event;
      final Session? session = data.session;

      if (event == AuthChangeEvent.signedIn) {
        _user = session?.user;
        notifyListeners();
      } else if (event == AuthChangeEvent.signedOut) {
        _user = null;
        notifyListeners();
      }
    });

    // Get initial auth state
    final session = _client.auth.currentSession;
    _user = session?.user;
  }

  // Get current user
  User? get currentUser => _user;

  // Check if user is authenticated
  bool get isAuthenticated => _user != null;

  // Sign up with email and password
  Future<void> signUp({
    required String email,
    required String password,
    String? username,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: username != null ? {'username': username} : null,
      );
      
      _user = response.user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Sign in with email and password
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      _user = response.user;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(email);
    } catch (e) {
      rethrow;
    }
  }

  // Fetch products from database
  Future<List<Map<String, dynamic>>> getProducts() async {
    try {
      final response = await _client
          .from('products')
          .select("*")
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Fetch categories from database
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      
      // Use a simpler query first to debug
      final response = await _client
          .from('categories')
          .select('*');
      
      
      if (response == null) {
        return [];
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Fetch featured products from database
  Future<List<Map<String, dynamic>>> getFeaturedProducts() async {
    try {
      print('Fetching featured products from Supabase...');
      
      // Use a simpler query first to debug
      final response = await _client
          .from('products')
          .select('*')
          .eq('is_featured', true);
      
      print('Featured products response raw: $response');
      
      if (response == null) {
        print('Featured products response is null');
        return [];
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching featured products: $e');
      return [];
    }
  }

  // Fetch products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(String categoryId) async {
    try {
      final response = await _client
          .from('products')
          .select('*, categories(name)')
          .eq('category_id', categoryId)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      return [];
    }
  }

  // Add product to favorites
  Future<void> addToFavorites(String productId) async {
    if (_user == null) return;
    
    try {
      await _client.from('favorites').insert({
        'user_id': _user!.id,
        'product_id': productId,
      });
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Remove product from favorites
  Future<void> removeFromFavorites(String productId) async {
    if (_user == null) return;
    
    try {
      await _client
          .from('favorites')
          .delete()
          .eq('user_id', _user!.id)
          .eq('product_id', productId);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }

  // Get user favorites
  Future<List<String>> getFavoriteIds() async {
    if (_user == null) return [];
    
    try {
      final response = await _client
          .from('favorites')
          .select('product_id')
          .eq('user_id', _user!.id);
      
      return List<String>.from(
        response.map((item) => item['product_id'] as String),
      );
    } catch (e) {
      return [];
    }
  }

  // Get favorite products with details
  Future<List<Map<String, dynamic>>> getFavoriteProducts() async {
    if (_user == null) return [];
    
    try {
      final response = await _client
          .from('favorites')
          .select('product_id, products(*)')
          .eq('user_id', _user!.id);
      
      return List<Map<String, dynamic>>.from(
        response.map((item) => item['products'] as Map<String, dynamic>),
      );
    } catch (e) {
      return [];
    }
  }

  // Search products
  Future<List<Map<String, dynamic>>> searchProducts(String query) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .ilike('name', '%$query%')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Upload product image
  Future<String> uploadImage(String filePath, String fileName) async {
    try {
      final file = io.File(filePath);
      final bytes = await file.readAsBytes();
      
      final response = await _client.storage
          .from('product_images')
          .uploadBinary(fileName, bytes);
      
      return _client.storage.from('product_images').getPublicUrl(fileName);
    } catch (e) {
      rethrow;
    }
  }

  // Debug function to insert test data
  Future<void> insertTestData() async {
    try {
      // Insert test category
      final categoryResponse = await _client.from('categories').insert([
        {
          'name': 'Test Category',
          'description': 'Test description',
          'icon_name': 'pets',
        }
      ]).select();
      
      print('Inserted test category: $categoryResponse');
      
      if (categoryResponse != null && categoryResponse.isNotEmpty) {
        // Insert test product
        final productResponse = await _client.from('products').insert([
          {
            'name': 'Test Product',
            'description': 'Test product description',
            'price': 19.99,
            'stock_quantity': 10,
            'category_id': categoryResponse[0]['id'],
            'is_featured': true,
          }
        ]).select();
        
        print('Inserted test product: $productResponse');
      }
    } catch (e) {
      print('Error inserting test data: $e');
    }
  }

  // Fetch featured adoptable pets
  Future<List<Map<String, dynamic>>> getFeaturedAdoptablePets() async {
    try {
      print('Fetching featured adoptable pets from Supabase...');
      
      final response = await _client
          .from('adoptable_pets')
          .select('*')
          .eq('is_featured', true)
          .order('created_at', ascending: false);
      
      print('Featured adoptable pets response: $response');
      
      if (response == null) {
        print('Featured adoptable pets response is null');
        return [];
      }
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching featured adoptable pets: $e');
      return [];
    }
  }

  // Fetch all adoptable pets
  Future<List<Map<String, dynamic>>> getAllAdoptablePets() async {
    try {
      final response = await _client
          .from('adoptable_pets')
          .select('*')
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching all adoptable pets: $e');
      return [];
    }
  }

  // Fetch adoptable pets by species
  Future<List<Map<String, dynamic>>> getAdoptablePetsBySpecies(String species) async {
    try {
      final response = await _client
          .from('adoptable_pets')
          .select('*')
          .eq('species', species)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('Error fetching adoptable pets by species: $e');
      return [];
    }
  }

  // Fetch user orders
  Future<List<Map<String, dynamic>>> getUserOrders() async {
    try {
      if (!isAuthenticated) {
        return [];
      }
      
      // For demo purposes, we'll return mock data
      // In a real app, you would fetch from Supabase
      return [
        {
          'id': '12345678-abcd-1234-efgh-123456789012',
          'created_at': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
          'status': 'Processing',
          'total_amount': 129.97,
          'shipping_address': '123 Main St, Apt 4B, New York, NY 10001',
          'payment_method': 'Credit Card (**** 1234)',
          'items': [
            {
              'name': 'Premium Dog Food',
              'quantity': 2,
              'price': 29.99,
              'image_url': 'https://images.unsplash.com/photo-1589924691995-400dc9ecc119?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
            },
            {
              'name': 'Dog Collar - Large',
              'quantity': 1,
              'price': 19.99,
              'image_url': 'https://images.unsplash.com/photo-1567612529009-afe25eb3d0bc?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
            },
            {
              'name': 'Interactive Dog Toy',
              'quantity': 1,
              'price': 49.99,
              'image_url': 'https://images.unsplash.com/photo-1576201836106-db1758fd1c97?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
            },
          ],
        },
        {
          'id': '87654321-dcba-4321-hgfe-210987654321',
          'created_at': DateTime.now().subtract(const Duration(days: 15)).toIso8601String(),
          'status': 'Delivered',
          'total_amount': 89.98,
          'shipping_address': '123 Main St, Apt 4B, New York, NY 10001',
          'payment_method': 'PayPal',
          'items': [
            {
              'name': 'Cat Tree Condo',
              'quantity': 1,
              'price': 79.99,
              'image_url': 'https://images.unsplash.com/photo-1592194996308-7b43878e84a6?ixlib=rb-4.0.3&auto=format&fit=crop&w=1974&q=80',
            },
            {
              'name': 'Cat Treats',
              'quantity': 2,
              'price': 4.99,
              'image_url': 'https://images.unsplash.com/photo-1583511655826-05700442982d?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
            },
          ],
        },
        {
          'id': '13579246-abcd-2468-efgh-135792468013',
          'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
          'status': 'Shipped',
          'total_amount': 45.98,
          'shipping_address': '123 Main St, Apt 4B, New York, NY 10001',
          'payment_method': 'Credit Card (**** 5678)',
          'items': [
            {
              'name': 'Bird Cage - Medium',
              'quantity': 1,
              'price': 39.99,
              'image_url': 'https://images.unsplash.com/photo-1552728089-57bdde30beb3?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
            },
            {
              'name': 'Bird Food Mix',
              'quantity': 1,
              'price': 5.99,
              'image_url': 'https://images.unsplash.com/photo-1600880292089-90a7e086ee0c?ixlib=rb-1.2.1&auto=format&fit=crop&w=500&q=60',
            },
          ],
        },
      ];
      
      // In a real app, you would fetch from Supabase like this:
      /*
      final response = await _client
          .from('orders')
          .select('*, order_items(*)')
          .eq('user_id', _user!.id)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
      */
    } catch (e) {
      print('Error fetching user orders: $e');
      return [];
    }
  }

  // Get user profile data
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      if (!isAuthenticated) {
        return {};
      }
      
      // For demo purposes, we'll return mock data
      // In a real app, you would fetch from Supabase
      // return {
      //   'username': _user?.userMetadata?['username'] ?? 'Pet Lover',
      //   'full_name': _user?.userMetadata?['full_name'] ?? 'Pet Lover',
      //   'email': _user?.email ?? 'petlover@example.com',
      //   'phone': _user?.phone ?? '+1 (555) 123-4567',
      //   'bio': _user?.userMetadata?['bio'] ?? 'Animal lover and pet enthusiast. I have two dogs and a cat.',
      //   'avatar_url': _user?.userMetadata?['avatar_url'] ?? 'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=M3wxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8fA%3D%3D&auto=format&fit=crop&w=1760&q=80',
      //   'notification_preferences': {
      //     'order_updates': true,
      //     'promotions': true,
      //     'app_updates': false,
      //   },
      //   'address': '123 Main St, Apt 4B, New York, NY 10001',
      //   'created_at': DateTime.now().subtract(const Duration(days: 120)).toIso8601String(),
      // };
      
      // In a real app, you would fetch from Supabase like this:
      final response = await _client
          .from('user_profiles')
          .select('*')
          .eq('id', _user!.id)
          .single();
      
      return response ?? {};
    } catch (e) {
      print('Error fetching user profile: $e');
      return {};
    }
  }

  // Update user profile
  Future<void> updateUserProfile(Map<String, dynamic> data) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }
      
      // In a real app, you would update in Supabase like this:
      await _client
          .from('user_profiles')
          .update(data)
          .eq('id', _user!.id);
      
      // For demo purposes, we'll just print the data
      print('Updating user profile with data: $data');
      
      // Notify listeners that profile data has changed
      notifyListeners();
    } catch (e) {
      print('Error updating user profile: $e');
      rethrow;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(io.File imageFile) async {
    try {
      final fileName = '${_client.auth.currentUser!.id}_${DateTime.now().millisecondsSinceEpoch}.jpg';
      
      // Get public URL for the uploaded image
      final imageUrl = _client
          .storage
          .from('avatars')
          .getPublicUrl(fileName);
      
      return imageUrl;
    } catch (e) {
      print('Error uploading profile image: $e');
      throw Exception('Failed to upload profile image: $e');
    }
  }

  /// Refreshes the user data from Supabase
  Future<void> refreshUserData() async {
    if (!isAuthenticated) return;
    
    try {
      final userId = _client.auth.currentUser!.id;
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .single();
      
      // Update any cached user data you might have in the service
      _userData = response;
      notifyListeners();
    } catch (e) {
      print('Error refreshing user data: $e');
      rethrow;
    }
  }

  Future<void> createUserProfile(Map<String, dynamic> profileData) async {
    try {
      final userId = _client.auth.currentUser!.id;
      
      // Check if profile already exists
      final existingProfile = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      if (existingProfile != null) {
        // Update existing profile
        await _client
            .from('user_profiles')
            .update(profileData)
            .eq('id', userId);
      } else {
        // Create new profile
        await _client
            .from('user_profiles')
            .insert({
              'id': userId,
              ...profileData,
            });
      }
    } catch (e) {
      print('Error creating user profile: $e');
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<bool> checkUserHasProfile() async {
    try {
      final userId = _client.auth.currentUser!.id;
      
      final profile = await _client
          .from('user_profiles')
          .select()
          .eq('id', userId)
          .maybeSingle();
      
      return profile != null;
    } catch (e) {
      print('Error checking user profile: $e');
      return false;
    }
  }
} 
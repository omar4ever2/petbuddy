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
        throw Exception('User not authenticated');
      }
      
      // Instead of fetching from Supabase, return mock data
      print('Returning mock user profile data');
      
      // Simulate a delay to make it feel like a real API call
      await Future.delayed(const Duration(milliseconds: 500));
      
      return {
        'id': _client.auth.currentUser?.id ?? 'user123',
        'full_name': 'John Doe',
        'email': 'john.doe@example.com',
        'phone': '(555) 123-4567',
        'address': '123 Main Street',
        'city': 'New York',
        'state': 'NY',
        'zip': '10001',
        'created_at': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      };
      
      // Original Supabase code (commented out)
      /*
      final userId = _client.auth.currentUser!.id;
      
      final response = await _client
          .from('profiles')
          .select()
          .eq('id', userId)
          .single();
      
      return response;
      */
    } catch (e) {
      print('Error getting user profile: $e');
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
  
  // Get upcoming vaccine appointments for the current user
  Future<List<Map<String, dynamic>>> getUpcomingVaccineAppointments() async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }
      
      // Instead of fetching from Supabase, return mock data
      print('Returning mock vaccine appointments data');
      
      // Get current date for relative dates
      final now = DateTime.now();
      
      return [
        {
          'id': '1',
          'user_id': _client.auth.currentUser?.id ?? 'user123',
          'pet_name': 'Max',
          'pet_type': 'Dog',
          'appointment_date': now.add(const Duration(days: 3)).toIso8601String(),
          'vaccine_type': 'Rabies',
          'status': 'confirmed',
          'notes': 'Annual vaccination',
          'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
        },
        {
          'id': '2',
          'user_id': _client.auth.currentUser?.id ?? 'user123',
          'pet_name': 'Bella',
          'pet_type': 'Cat',
          'appointment_date': now.add(const Duration(days: 7)).toIso8601String(),
          'vaccine_type': 'Distemper',
          'status': 'pending',
          'notes': 'First time vaccination',
          'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
        },
        {
          'id': '3',
          'user_id': _client.auth.currentUser?.id ?? 'user123',
          'pet_name': 'Charlie',
          'pet_type': 'Dog',
          'appointment_date': now.add(const Duration(days: 14)).toIso8601String(),
          'vaccine_type': 'Bordetella',
          'status': 'pending',
          'notes': 'Required for doggy daycare',
          'created_at': now.subtract(const Duration(hours: 12)).toIso8601String(),
        },
        {
          'id': '4',
          'user_id': _client.auth.currentUser?.id ?? 'user123',
          'pet_name': 'Luna',
          'pet_type': 'Cat',
          'appointment_date': now.add(const Duration(days: 21)).toIso8601String(),
          'vaccine_type': 'Feline Leukemia',
          'status': 'pending',
          'notes': null,
          'created_at': now.subtract(const Duration(hours: 6)).toIso8601String(),
        },
        {
          'id': '5',
          'user_id': _client.auth.currentUser?.id ?? 'user123',
          'pet_name': 'Rocky',
          'pet_type': 'Dog',
          'appointment_date': now.subtract(const Duration(days: 5)).toIso8601String(),
          'vaccine_type': 'Parvovirus',
          'status': 'completed',
          'notes': 'Booster shot',
          'created_at': now.subtract(const Duration(days: 15)).toIso8601String(),
        },
        {
          'id': '6',
          'user_id': _client.auth.currentUser?.id ?? 'user123',
          'pet_name': 'Daisy',
          'pet_type': 'Rabbit',
          'appointment_date': now.subtract(const Duration(days: 2)).toIso8601String(),
          'vaccine_type': 'Myxomatosis',
          'status': 'cancelled',
          'notes': 'Rescheduling needed',
          'created_at': now.subtract(const Duration(days: 10)).toIso8601String(),
        },
      ];
      
      // Original Supabase code (commented out)
      /*
      final userId = _client.auth.currentUser!.id;
      final now = DateTime.now().toIso8601String();
      
      final response = await _client
          .from('vaccine_appointments')
          .select()
          .eq('user_id', userId)
          .gte('appointment_date', now)
          .order('appointment_date', ascending: true)
          .limit(5);
      
      return response;
      */
    } catch (e) {
      print('Error getting upcoming vaccine appointments: $e');
      return [];
    }
  }
  
  // Create a new vaccine appointment
  Future<Map<String, dynamic>> createVaccineAppointment(Map<String, dynamic> appointmentData) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }
      
      // Instead of creating in Supabase, just return mock data
      print('Creating mock vaccine appointment with data: $appointmentData');
      
      final userId = _client.auth.currentUser?.id ?? 'user123';
      final now = DateTime.now();
      
      // Generate a random ID
      final id = 'appointment_${now.millisecondsSinceEpoch}';
      
      // Create a mock response
      final response = {
        'id': id,
        'user_id': userId,
        'pet_name': appointmentData['pet_name'],
        'pet_type': appointmentData['pet_type'],
        'vaccine_type': appointmentData['vaccine_type'],
        'appointment_date': appointmentData['appointment_date'],
        'notes': appointmentData['notes'],
        'status': 'pending',
        'created_at': now.toIso8601String(),
      };
      
      // Simulate a delay to make it feel like a real API call
      await Future.delayed(const Duration(milliseconds: 800));
      
      return response;
      
      // Original Supabase code (commented out)
      /*
      final userId = _client.auth.currentUser!.id;
      
      final data = {
        'user_id': userId,
        'created_at': DateTime.now().toIso8601String(),
        'status': 'pending',
        ...appointmentData,
      };
      
      final response = await _client
          .from('vaccine_appointments')
          .insert(data)
          .select()
          .single();
      
      return response;
      */
    } catch (e) {
      print('Error creating vaccine appointment: $e');
      throw Exception('Failed to create vaccine appointment: $e');
    }
  }
  
  // Cancel a vaccine appointment
  Future<void> cancelVaccineAppointment(String appointmentId) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }
      
      // Instead of updating in Supabase, just log the cancellation
      print('Cancelling mock vaccine appointment with ID: $appointmentId');
      
      // Simulate a delay to make it feel like a real API call
      await Future.delayed(const Duration(milliseconds: 600));
      
      // Original Supabase code (commented out)
      /*
      final userId = _client.auth.currentUser!.id;
      
      await _client
          .from('vaccine_appointments')
          .update({'status': 'cancelled'})
          .eq('id', appointmentId)
          .eq('user_id', userId);
      */
    } catch (e) {
      print('Error cancelling vaccine appointment: $e');
      throw Exception('Failed to cancel vaccine appointment: $e');
    }
  }
  
  // Get available vaccine types
  Future<List<Map<String, dynamic>>> getVaccineTypes() async {
    try {
      // Return predefined vaccine types instead of fetching from Supabase
      print('Returning predefined vaccine types');
      
      // Simulate a delay to make it feel like a real API call
      await Future.delayed(const Duration(milliseconds: 300));
      
      return [
        {'id': '1', 'name': 'Rabies', 'description': 'Protection against rabies virus'},
        {'id': '2', 'name': 'Distemper', 'description': 'Protection against canine distemper'},
        {'id': '3', 'name': 'Parvovirus', 'description': 'Protection against parvovirus'},
        {'id': '4', 'name': 'Bordetella', 'description': 'Protection against kennel cough'},
        {'id': '5', 'name': 'Leptospirosis', 'description': 'Protection against leptospirosis'},
        {'id': '6', 'name': 'Feline Leukemia', 'description': 'Protection for cats against feline leukemia virus'},
        {'id': '7', 'name': 'Feline Calicivirus', 'description': 'Protection for cats against calicivirus'},
        {'id': '8', 'name': 'Avian Influenza', 'description': 'Protection for birds against avian flu'},
      ];
      
      // Original Supabase code (commented out)
      /*
      final response = await _client
          .from('vaccine_types')
          .select()
          .order('name', ascending: true);
      
      return response;
      */
    } catch (e) {
      print('Error getting vaccine types: $e');
      // Return some default vaccine types if there's an error
      return [
        {'id': '1', 'name': 'Rabies', 'description': 'Protection against rabies virus'},
        {'id': '2', 'name': 'Distemper', 'description': 'Protection against canine distemper'},
        {'id': '3', 'name': 'Parvovirus', 'description': 'Protection against parvovirus'},
        {'id': '4', 'name': 'Bordetella', 'description': 'Protection against kennel cough'},
        {'id': '5', 'name': 'Leptospirosis', 'description': 'Protection against leptospirosis'},
      ];
    }
  }

  // Create a new order
  Future<Map<String, dynamic>> createOrder(Map<String, dynamic> orderData) async {
    try {
      if (!isAuthenticated) {
        throw Exception('User not authenticated');
      }
      
      // Instead of creating in Supabase, just return the data with an ID
      print('Creating mock order with data: $orderData');
      
      // Simulate a delay to make it feel like a real API call
      await Future.delayed(const Duration(seconds: 1));
      
      // Add user ID if not present
      if (!orderData.containsKey('user_id')) {
        orderData['user_id'] = _client.auth.currentUser?.id ?? 'user123';
      }
      
      // Add created_at if not present
      if (!orderData.containsKey('created_at')) {
        orderData['created_at'] = DateTime.now().toIso8601String();
      }
      
      // Add order ID if not present
      if (!orderData.containsKey('id')) {
        orderData['id'] = 'order_${DateTime.now().millisecondsSinceEpoch}';
      }
      
      return orderData;
      
      // Original Supabase code (commented out)
      /*
      final userId = _client.auth.currentUser!.id;
      
      // Add user ID to order data
      orderData['user_id'] = userId;
      
      // Add created_at timestamp
      orderData['created_at'] = DateTime.now().toIso8601String();
      
      // Insert order into orders table
      final orderResponse = await _client
          .from('orders')
          .insert(orderData)
          .select()
          .single();
      
      // Get order ID
      final orderId = orderResponse['id'];
      
      // Insert order items
      final items = orderData['items'] as List;
      for (var item in items) {
        item['order_id'] = orderId;
        await _client.from('order_items').insert(item);
      }
      
      return orderResponse;
      */
    } catch (e) {
      print('Error creating order: $e');
      throw Exception('Failed to create order: $e');
    }
  }
} 
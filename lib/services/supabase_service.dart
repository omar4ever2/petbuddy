import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'dart:io' as io;

class SupabaseService with ChangeNotifier {
  final SupabaseClient _client;
  User? _user;

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
          .select()
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Fetch products by category
  Future<List<Map<String, dynamic>>> getProductsByCategory(String category) async {
    try {
      final response = await _client
          .from('products')
          .select()
          .eq('category', category)
          .order('created_at', ascending: false);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
    }
  }

  // Fetch categories
  Future<List<Map<String, dynamic>>> getCategories() async {
    try {
      final response = await _client
          .from('categories')
          .select()
          .order('name', ascending: true);
      
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      rethrow;
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
} 
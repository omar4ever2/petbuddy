import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../services/supabase_service.dart';

class FavoritesProvider with ChangeNotifier {
  final List<String> _favoriteIds = [];
  bool _isInitialized = false;
  SupabaseService? _supabaseService;
  
  List<String> get favoriteIds => [..._favoriteIds];
  
  int get favoriteCount => _favoriteIds.length;
  
  // Initialize with Supabase service
  Future<void> initialize(SupabaseService supabaseService) async {
    if (_isInitialized) return;
    
    _supabaseService = supabaseService;
    
    // Only fetch favorites if user is authenticated
    if (supabaseService.isAuthenticated) {
      try {
        final favIds = await supabaseService.getFavoriteIds();
        _favoriteIds.clear();
        _favoriteIds.addAll(favIds);
        _isInitialized = true;
        notifyListeners();
      } catch (e) {
        debugPrint('Error initializing favorites: $e');
      }
    }
  }
  
  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }
  
  Future<void> addFavorite(String id) async {
    if (!_favoriteIds.contains(id)) {
      _favoriteIds.add(id);
      notifyListeners();
      
      // Sync with Supabase if authenticated
      if (_supabaseService != null && _supabaseService!.isAuthenticated) {
        try {
          await _supabaseService!.addToFavorites(id);
        } catch (e) {
          // Revert on error
          _favoriteIds.remove(id);
          notifyListeners();
          debugPrint('Error adding favorite: $e');
        }
      }
    }
  }
  
  Future<void> removeFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      notifyListeners();
      
      // Sync with Supabase if authenticated
      if (_supabaseService != null && _supabaseService!.isAuthenticated) {
        try {
          await _supabaseService!.removeFromFavorites(id);
        } catch (e) {
          // Revert on error
          _favoriteIds.add(id);
          notifyListeners();
          debugPrint('Error removing favorite: $e');
        }
      }
    }
  }
  
  Future<void> toggleFavorite(String id) async {
    if (_favoriteIds.contains(id)) {
      await removeFavorite(id);
    } else {
      await addFavorite(id);
    }
  }
  
  Future<void> clearFavorites() async {
    final oldFavorites = [..._favoriteIds];
    _favoriteIds.clear();
    notifyListeners();
    
    // Sync with Supabase if authenticated
    if (_supabaseService != null && _supabaseService!.isAuthenticated) {
      try {
        for (final id in oldFavorites) {
          await _supabaseService!.removeFromFavorites(id);
        }
      } catch (e) {
        // Revert on error
        _favoriteIds.addAll(oldFavorites);
        notifyListeners();
        debugPrint('Error clearing favorites: $e');
      }
    }
  }
  
  // Refresh favorites from Supabase
  Future<void> refreshFavorites() async {
    if (_supabaseService != null && _supabaseService!.isAuthenticated) {
      try {
        final favIds = await _supabaseService!.getFavoriteIds();
        _favoriteIds.clear();
        _favoriteIds.addAll(favIds);
        notifyListeners();
      } catch (e) {
        debugPrint('Error refreshing favorites: $e');
      }
    }
  }
} 
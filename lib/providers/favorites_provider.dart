import 'package:flutter/foundation.dart';

class FavoritesProvider with ChangeNotifier {
  final List<String> _favoriteIds = [];
  
  List<String> get favoriteIds => [..._favoriteIds];
  
  int get favoriteCount => _favoriteIds.length;
  
  bool isFavorite(String id) {
    return _favoriteIds.contains(id);
  }
  
  void addFavorite(String id) {
    if (!_favoriteIds.contains(id)) {
      _favoriteIds.add(id);
      notifyListeners();
    }
  }
  
  void removeFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
      notifyListeners();
    }
  }
  
  void toggleFavorite(String id) {
    if (_favoriteIds.contains(id)) {
      _favoriteIds.remove(id);
    } else {
      _favoriteIds.add(id);
    }
    notifyListeners();
  }
  
  void clearFavorites() {
    _favoriteIds.clear();
    notifyListeners();
  }
} 
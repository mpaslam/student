import 'package:flutter/material.dart';

class SearchProvider with ChangeNotifier {
  String _searchQuery = '';
  bool _isSearchVisible = false;

  String get searchQuery => _searchQuery;
  bool get isSearchVisible => _isSearchVisible;

  set searchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  set isSearchVisible(bool isVisible) {
    _isSearchVisible = isVisible;
    notifyListeners();
  }
}

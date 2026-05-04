import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SearchHistoryViewModel extends ChangeNotifier {
  static const String _storageKey = 'search_history';
  static const int _maxHistoryItems = 10;

  List<String> _searchHistory = [];
  bool _isLoading = false;

  List<String> get searchHistory => _searchHistory;
  bool get isLoading => _isLoading;
  bool get hasHistory => _searchHistory.isNotEmpty;

  SearchHistoryViewModel() {
    loadSearchHistory();
  }

  Future<void> loadSearchHistory() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _searchHistory = prefs.getStringList(_storageKey) ?? [];
    } catch (e) {
      _searchHistory = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addSearch(String query) async {
    if (query.trim().isEmpty) return;

    final trimmedQuery = query.trim();
    
    _searchHistory.remove(trimmedQuery);
    _searchHistory.insert(0, trimmedQuery);
    
    if (_searchHistory.length > _maxHistoryItems) {
      _searchHistory = _searchHistory.sublist(0, _maxHistoryItems);
    }

    notifyListeners();
    await _saveToStorage();
  }

  Future<void> removeSearch(String query) async {
    _searchHistory.remove(query);
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> clearHistory() async {
    _searchHistory.clear();
    notifyListeners();
    await _saveToStorage();
  }

  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setStringList(_storageKey, _searchHistory);
    } catch (e) {
      debugPrint('Error saving search history: $e');
    }
  }

  List<String> getSuggestions(String query) {
    if (query.isEmpty) return _searchHistory;
    
    return _searchHistory
        .where((item) => item.toLowerCase().contains(query.toLowerCase()))
        .toList();
  }
}

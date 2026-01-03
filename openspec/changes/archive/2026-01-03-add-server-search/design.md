# Design: Server-side Product Search

## Architecture Decision

### Option 1: Separate SearchViewModel (Recommended)
```
SearchViewModel (new)
├── searchQuery: String
├── searchResults: List<ProductModel>
├── isSearching: bool
├── errorMessage: String?
├── debounceTimer: Timer?
└── search(query) → calls ProductRepository.searchProducts()
```

**Pros**:
- Single Responsibility: tách search logic ra riêng
- Dễ test và maintain
- Không làm phức tạp ProductListScreen

**Cons**:
- Thêm 1 ViewModel mới
- Cần coordinate với category filter

### Option 2: Extend ProductListScreen state
Giữ nguyên logic trong StatefulWidget, chỉ thay đổi `_handleSearch()`.

**Pros**: Ít thay đổi code

**Cons**: ProductListScreen đã khá phức tạp, thêm logic sẽ khó maintain

### Decision: Option 1

## Data Flow

```
User types → debounce(300ms) → SearchViewModel.search()
                                    ↓
                            ProductRepository.searchProducts(query)
                                    ↓
                            ApiService.searchProducts(query)
                                    ↓
                            Update searchResults → notifyListeners()
                                    ↓
                            ProductListScreen rebuilds with results
```

## Debounce Implementation

Sử dụng `Timer` từ `dart:async` thay vì rxdart để không thêm dependency:

```dart
class SearchViewModel extends ChangeNotifier {
  Timer? _debounceTimer;

  void search(String query) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      _performSearch(query);
    });
  }
}
```

## State Management

ProductListScreen sẽ combine 2 nguồn data:
1. `SearchViewModel.searchResults` khi có search query
2. `_allProducts` (load từ getAllProducts) khi không search

```dart
List<ProductViewModel> get displayedProducts {
  if (_searchQuery.isEmpty) {
    return _filteredProducts; // from getAllProducts + category filter
  }
  return searchViewModel.searchResults;
}
```

## Error Handling

- Network timeout: Hiển thị retry button
- Empty results: Hiển thị "Không tìm thấy sản phẩm" với suggestion
- API error: Fallback về local filter (graceful degradation)

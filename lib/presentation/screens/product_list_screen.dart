import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/repositories/product_repository.dart';
import '../view_models/product_view_model.dart';
import '../view_models/cart_view_model.dart';
import '../view_models/search_history_view_model.dart';
import '../view_models/search_view_model.dart';
import '../widgets/product_card.dart';
import '../widgets/skeleton_loading.dart';
import '../widgets/search_history_overlay.dart';
import 'cart_screen.dart';
import 'product_detail_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';

/// Wrapper cho SettingsScreen với AppBar
class SettingsPageWrapper extends StatelessWidget {
  const SettingsPageWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cài đặt'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: const SettingsScreen(),
    );
  }
}

/// Màn hình danh sách sản phẩm - Shopping Hub
class ProductListScreen extends StatefulWidget {
  /// Nếu true, không hiển thị Scaffold (dùng để embed trong HomeScreen)
  final bool embedded;

  const ProductListScreen({super.key, this.embedded = false});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  final LayerLink _layerLink = LayerLink();
  final ProductRepository _productRepository = ProductRepository();
  OverlayEntry? _overlayEntry;
  
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  String _sortBy = 'Mới nhất';
  bool _isGridView = true;
  bool _isLoading = true;

  List<ProductViewModel> _allProducts = [];
  List<ProductViewModel> _filteredProducts = [];

  @override
  void initState() {
    super.initState();
    _loadProducts();
    _searchFocusNode.addListener(_onSearchFocusChange);
  }

  Future<void> _loadProducts() async {
    setState(() => _isLoading = true);
    try {
      final result = await _productRepository.getAllProducts();
      if (mounted) {
        setState(() {
          _allProducts = result.products.map((p) => ProductViewModel(product: p)).toList();
          _filteredProducts = _allProducts;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.removeListener(_onSearchFocusChange);
    _searchFocusNode.dispose();
    _removeOverlay();
    super.dispose();
  }

  void _onSearchFocusChange() {
    if (_searchFocusNode.hasFocus) {
      _showOverlay();
    } else {
      Future.delayed(const Duration(milliseconds: 200), _removeOverlay);
    }
  }

  void _showOverlay() {
    _removeOverlay();
    _overlayEntry = _createOverlayEntry();
    Overlay.of(context).insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  OverlayEntry _createOverlayEntry() {
    final renderBox = context.findRenderObject() as RenderBox;
    final size = renderBox.size;

    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Tap outside to close
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                _searchFocusNode.unfocus();
                _removeOverlay();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(color: Colors.transparent),
            ),
          ),
          // Search overlay
          Positioned(
            width: size.width - 32,
            left: 16,
            child: CompositedTransformFollower(
              link: _layerLink,
              showWhenUnlinked: false,
              offset: const Offset(0, 56),
              child: Material(
                color: Colors.transparent,
                child: Consumer<SearchHistoryViewModel>(
                  builder: (context, searchHistoryVM, _) {
                    return SearchHistoryOverlay(
                      searchHistory: searchHistoryVM.searchHistory,
                      suggestions: searchHistoryVM.getSuggestions(_searchQuery),
                      currentQuery: _searchQuery,
                      onItemTap: (query) {
                        _searchController.text = query;
                        _handleSearchSubmit(query);
                        _searchFocusNode.unfocus();
                        _removeOverlay();
                      },
                      onRemove: (query) {
                        searchHistoryVM.removeSearch(query);
                        _overlayEntry?.markNeedsBuild();
                      },
                      onClearAll: () {
                        searchHistoryVM.clearHistory();
                        _overlayEntry?.markNeedsBuild();
                      },
                      onClose: _removeOverlay,
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> get _categories {
    // Use brand as category for phone products
    final categories = _allProducts.map((p) => p.product.brand).toSet().toList();
    categories.insert(0, 'Tất cả');
    return categories;
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        bool matchCategory = _selectedCategory == 'Tất cả' ||
            product.product.brand == _selectedCategory;
        bool matchSearch = _searchQuery.isEmpty ||
            product.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            product.description
                .toLowerCase()
                .contains(_searchQuery.toLowerCase());
        return matchCategory && matchSearch;
      }).toList();

      switch (_sortBy) {
        case 'Giá: Thấp - Cao':
          _filteredProducts.sort((a, b) => a.price.compareTo(b.price));
          break;
        case 'Giá: Cao - Thấp':
          _filteredProducts.sort((a, b) => b.price.compareTo(a.price));
          break;
        case 'Đánh giá cao':
          _filteredProducts.sort((a, b) => b.rating.compareTo(a.rating));
          break;
        case 'Tên A-Z':
          _filteredProducts.sort((a, b) => a.name.compareTo(b.name));
          break;
        case 'Mới nhất':
        default:
          _filteredProducts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
    });
  }

  void _handleSearch(String query) {
    setState(() => _searchQuery = query);
    _overlayEntry?.markNeedsBuild();

    // Sử dụng server-side search qua SearchViewModel
    final searchVM = context.read<SearchViewModel>();
    searchVM.search(query);

    // Nếu query rỗng, quay về local filter
    if (query.isEmpty) {
      _applyFilters();
    }
  }

  /// Xử lý khi user submit search (Enter hoặc tap suggestion)
  void _handleSearchSubmit(String query) {
    setState(() => _searchQuery = query);
    _overlayEntry?.markNeedsBuild();

    if (query.trim().isNotEmpty) {
      // Lưu vào history chỉ khi submit
      context.read<SearchHistoryViewModel>().addSearch(query.trim());
      // Search ngay lập tức
      context.read<SearchViewModel>().searchImmediate(query);
    } else {
      _applyFilters();
    }
  }

  void _selectCategory(String category) {
    setState(() => _selectedCategory = category);
    _applyFilters();
  }

  void _handleSort(String? sortOption) {
    if (sortOption == null) return;
    setState(() => _sortBy = sortOption);
    _applyFilters();
  }

  Future<void> _addToCart(ProductViewModel product) async {
    try {
      final cartViewModel = context.read<CartViewModel>();
      final defaultColor = product.colors.isNotEmpty 
          ? product.colors.first.toMap() 
          : {'name': 'Mặc định', 'hex': '#000000'};
      final success = await cartViewModel.addToCart(
        productId: product.id,
        quantity: 1,
        color: defaultColor,
      );
      
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã thêm "${product.name}" vào giỏ hàng'),
            backgroundColor: kGreenColor,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 2),
            action: SnackBarAction(
              label: 'Xem giỏ hàng',
              textColor: Colors.white,
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const CartScreen(),
                  ),
                );
              },
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Không thể thêm sản phẩm vào giỏ hàng'),
            backgroundColor: kRedColor,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Lỗi: ${e.toString()}'),
          backgroundColor: kRedColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  void _showProductDetail(ProductViewModel product) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ProductDetailScreen(product: product),
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await _loadProducts();
    _applyFilters();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    final body = Consumer<SearchViewModel>(
      builder: (context, searchVM, _) {
        // Quyết định hiển thị kết quả search hay danh sách filter
        final bool isSearchMode = _searchQuery.isNotEmpty && _searchQuery.length >= 2;
        final bool showSearchLoading = isSearchMode && searchVM.isSearching;
        final bool showSearchResults = isSearchMode && !searchVM.isSearching;

        // Products để hiển thị
        List<ProductViewModel> displayProducts;
        if (showSearchResults && searchVM.hasResults) {
          // Hiển thị kết quả từ server
          displayProducts = searchVM.searchResults
              .map((p) => ProductViewModel(product: p))
              .toList();
        } else if (!isSearchMode) {
          // Hiển thị danh sách filter local
          displayProducts = _filteredProducts;
        } else {
          displayProducts = [];
        }

        return Column(
          children: [
            _buildSearchBar(isSearching: searchVM.isSearching),
            _buildCategoryChips(),
            _buildFilterBar(
              productCount: isSearchMode ? searchVM.totalResults : _filteredProducts.length,
            ),
            Expanded(
              child: RefreshIndicator(
                onRefresh: _handleRefresh,
                color: kAccentColor,
                child: _isLoading || showSearchLoading
                    ? ProductListSkeleton(isGrid: _isGridView)
                    : displayProducts.isEmpty
                        ? _buildEmptyState(
                            isSearchMode: isSearchMode,
                            searchQuery: _searchQuery,
                            errorMessage: searchVM.errorMessage,
                          )
                        : _isGridView
                            ? _buildProductGrid(displayProducts)
                            : _buildProductList(displayProducts),
              ),
            ),
          ],
        );
      },
    );

    // Nếu embedded, chỉ trả về body (không có Scaffold)
    if (widget.embedded) {
      return body;
    }

    // Nếu không embedded, trả về Scaffold đầy đủ
    return Scaffold(
      backgroundColor: colors.background,
      appBar: _buildAppBar(),
      body: body,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final colors = AppColors.of(context);
    return AppBar(
      backgroundColor: colors.background,
      elevation: 0,
      automaticallyImplyLeading: false,
      toolbarHeight: 64,
      titleSpacing: 16,
      title: const Text(
        'Sản phẩm',
        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
      actions: [
        // Cart Button with Badge
        Consumer<CartViewModel>(
          builder: (context, cartVM, _) {
            return Stack(
              children: [
                IconButton(
                  icon: const Icon(Icons.shopping_cart_outlined, size: 26),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const CartScreen(),
                      ),
                    );
                  },
                  tooltip: 'Giỏ hàng',
                  color: colors.primaryText,
                ),
                if (cartVM.itemCount > 0)
                  Positioned(
                    right: 8,
                    top: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: kRedColor,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                      child: Text(
                        cartVM.itemCount > 99 ? '99+' : '${cartVM.itemCount}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
        // Profile Button
        IconButton(
          icon: const Icon(Icons.person_outline, size: 26),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const ProfileScreen()),
            );
          },
          tooltip: 'Hồ sơ',
          color: colors.primaryText,
        ),
        // Settings Button
        IconButton(
          icon: const Icon(Icons.settings_outlined, size: 26),
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const SettingsPageWrapper()),
            );
          },
          tooltip: 'Cài đặt',
          color: colors.primaryText,
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar({bool isSearching = false}) {
    final colors = AppColors.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: CompositedTransformTarget(
        link: _layerLink,
        child: Container(
          height: 44,
          decoration: BoxDecoration(
            color: colors.card,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: colors.border),
          ),
          child: TextField(
            controller: _searchController,
            focusNode: _searchFocusNode,
            onChanged: _handleSearch,
            onSubmitted: (value) {
              _handleSearchSubmit(value);
              _searchFocusNode.unfocus();
            },
            style: TextStyle(color: colors.primaryText, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Tìm kiếm sản phẩm...',
              hintStyle: TextStyle(color: colors.secondaryText, fontSize: 14),
              prefixIcon: Icon(Icons.search_rounded, color: colors.secondaryText, size: 20),
              suffixIcon: _searchQuery.isNotEmpty
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isSearching)
                          const Padding(
                            padding: EdgeInsets.only(right: 8),
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                color: kAccentColor,
                              ),
                            ),
                          ),
                        IconButton(
                          icon: Icon(Icons.close_rounded, color: colors.secondaryText, size: 18),
                          onPressed: () {
                            _searchController.clear();
                            _handleSearch('');
                            context.read<SearchViewModel>().clearSearch();
                          },
                        ),
                      ],
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final colors = AppColors.of(context);
    return SizedBox(
      height: 40,
      child: Row(
        children: [
          // Grid/List Toggle Button
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 8),
            child: GestureDetector(
              onTap: () => setState(() => _isGridView = !_isGridView),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: colors.border),
                ),
                child: Icon(
                  _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
                  size: 20,
                  color: colors.primaryText,
                ),
              ),
            ),
          ),
          // Category Chips
          Expanded(
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: GestureDetector(
                    onTap: () => _selectCategory(category),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: isSelected ? kAccentColor : colors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isSelected ? kAccentColor : colors.border,
                        ),
                      ),
                      child: Text(
                        category,
                        style: TextStyle(
                          color: isSelected ? Colors.white : colors.primaryText,
                          fontSize: 13,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar({int? productCount}) {
    final colors = AppColors.of(context);
    final count = productCount ?? _filteredProducts.length;
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      child: Row(
        children: [
          Text(
            '$count sản phẩm',
            style: TextStyle(
              color: colors.secondaryText,
              fontSize: 13,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () => _showSortOptions(),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: colors.card,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: colors.border),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.sort_rounded, size: 16, color: colors.secondaryText),
                  const SizedBox(width: 6),
                  Text(
                    _sortBy,
                    style: TextStyle(fontSize: 13, color: colors.primaryText),
                  ),
                  const SizedBox(width: 4),
                  Icon(Icons.keyboard_arrow_down_rounded, size: 16, color: colors.secondaryText),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSortOptions() {
    final colors = AppColors.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: colors.card,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(top: 12, bottom: 16),
                decoration: BoxDecoration(
                  color: colors.border,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text(
                'Sắp xếp theo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: colors.primaryText,
                ),
              ),
              const SizedBox(height: 8),
              ...['Mới nhất', 'Giá: Thấp - Cao', 'Giá: Cao - Thấp', 'Đánh giá cao', 'Tên A-Z'].map((option) {
                final isSelected = _sortBy == option;
                return ListTile(
                  title: Text(
                    option,
                    style: TextStyle(
                      color: isSelected ? kAccentColor : colors.primaryText,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_rounded, color: kAccentColor, size: 20)
                      : null,
                  onTap: () {
                    _handleSort(option);
                    Navigator.pop(context);
                  },
                );
              }),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Widget _buildProductGrid(List<ProductViewModel> products) {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return ProductCard(
          product: product,
          onTap: () => _showProductDetail(product),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  Widget _buildProductList(List<ProductViewModel> products) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: ProductCard(
            product: product,
            onTap: () => _showProductDetail(product),
            onAddToCart: () => _addToCart(product),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState({
    bool isSearchMode = false,
    String searchQuery = '',
    String? errorMessage,
  }) {
    final colors = AppColors.of(context);

    // Nếu có lỗi, hiển thị error message
    if (errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.wifi_off_rounded,
                size: 64,
                color: colors.secondaryText.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                errorMessage,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: colors.secondaryText),
              ),
              const SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: () {
                  if (isSearchMode) {
                    context.read<SearchViewModel>().searchImmediate(searchQuery);
                  } else {
                    _handleRefresh();
                  }
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Thử lại'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: kAccentColor,
                  foregroundColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state cho search
    if (isSearchMode) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.search_off_rounded,
                size: 64,
                color: colors.secondaryText.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy sản phẩm cho "$searchQuery"',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: colors.secondaryText),
              ),
              const SizedBox(height: 8),
              Text(
                'Thử tìm với từ khóa khác',
                style: TextStyle(
                  fontSize: 14,
                  color: colors.secondaryText.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Empty state mặc định
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: colors.secondaryText.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy sản phẩm',
            style: TextStyle(fontSize: 18, color: colors.secondaryText),
          ),
        ],
      ),
    );
  }
}

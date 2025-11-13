import 'package:flutter/material.dart';
import 'package:veritashop/view_models/color_view_model.dart';
import 'package:veritashop/view_models/product_view_model.dart';
import 'package:veritashop/widgets/product_card.dart';
import 'package:veritashop/screens/home_screen.dart';

/// Màn hình danh sách sản phẩm - Shopping Hub
class ProductListScreen extends StatefulWidget {
  const ProductListScreen({super.key});

  @override
  State<ProductListScreen> createState() => _ProductListScreenState();
}

class _ProductListScreenState extends State<ProductListScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String _selectedCategory = 'Tất cả';
  String _sortBy = 'Mới nhất';
  bool _isGridView = true;

  late List<ProductViewModel> _allProducts;
  late List<ProductViewModel> _filteredProducts;

  @override
  void initState() {
    super.initState();
    _initializeProducts();
    _filteredProducts = _allProducts;
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _initializeProducts() {
    _allProducts = [
      ProductViewModel(
        id: '1',
        name: 'iPhone 15 Pro Max',
        description: 'Điện thoại cao cấp với chip A17 Pro và camera 48MP',
        price: 29990000,
        imageUrl:
            'https://images.unsplash.com/photo-1592286927505-c58ba6c3c10b?w=400',
        category: 'Điện thoại',
        rating: 4.8,
        reviewCount: 234,
        stock: 45,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        tags: ['Apple', 'Premium', 'Hot'],
      ),
      ProductViewModel(
        id: '2',
        name: 'Samsung Galaxy S24 Ultra',
        description: 'Flagship Android với S Pen và màn hình Dynamic AMOLED',
        price: 26990000,
        imageUrl:
            'https://images.unsplash.com/photo-1610945415295-d9bbf067e59c?w=400',
        category: 'Điện thoại',
        rating: 4.7,
        reviewCount: 189,
        stock: 32,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        tags: ['Samsung', 'Android'],
      ),
      ProductViewModel(
        id: '3',
        name: 'MacBook Pro 14" M3',
        description: 'Laptop chuyên nghiệp với chip M3 mạnh mẽ',
        price: 49990000,
        imageUrl:
            'https://images.unsplash.com/photo-1517336714731-489689fd1ca8?w=400',
        category: 'Laptop',
        rating: 4.9,
        reviewCount: 156,
        stock: 18,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 3)),
        tags: ['Apple', 'Premium', 'Laptop'],
      ),
      ProductViewModel(
        id: '4',
        name: 'Sony WH-1000XM5',
        description: 'Tai nghe chống ồn hàng đầu thế giới',
        price: 8990000,
        imageUrl:
            'https://images.unsplash.com/photo-1545127398-14699f92334b?w=400',
        category: 'Phụ kiện',
        rating: 4.6,
        reviewCount: 421,
        stock: 67,
        createdAt: DateTime.now().subtract(const Duration(days: 5)),
        tags: ['Sony', 'Audio', 'Premium'],
      ),
      ProductViewModel(
        id: '5',
        name: 'iPad Pro 12.9" M2',
        description: 'Máy tính bảng cao cấp với chip M2',
        price: 29990000,
        imageUrl:
            'https://images.unsplash.com/photo-1544244015-0df4b3ffc6b0?w=400',
        category: 'Tablet',
        rating: 4.7,
        reviewCount: 98,
        stock: 8,
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        tags: ['Apple', 'Tablet'],
      ),
      ProductViewModel(
        id: '6',
        name: 'Apple Watch Series 9',
        description: 'Đồng hồ thông minh với chip S9 và Always-On display',
        price: 10990000,
        imageUrl:
            'https://images.unsplash.com/photo-1579586337278-3befd40fd17a?w=400',
        category: 'Phụ kiện',
        rating: 4.5,
        reviewCount: 267,
        stock: 42,
        createdAt: DateTime.now().subtract(const Duration(days: 10)),
        tags: ['Apple', 'Smartwatch'],
      ),
      ProductViewModel(
        id: '7',
        name: 'Dell XPS 15',
        description: 'Laptop Windows cao cấp với màn hình OLED',
        price: 45990000,
        imageUrl:
            'https://images.unsplash.com/photo-1593642632823-8f785ba67e45?w=400',
        category: 'Laptop',
        rating: 4.6,
        reviewCount: 134,
        stock: 0,
        createdAt: DateTime.now().subtract(const Duration(days: 12)),
        tags: ['Dell', 'Windows', 'OLED'],
      ),
      ProductViewModel(
        id: '8',
        name: 'AirPods Pro 2',
        description: 'Tai nghe True Wireless với chống ồn chủ động',
        price: 6490000,
        imageUrl:
            'https://images.unsplash.com/photo-1606841837239-c5a1a4a07af7?w=400',
        category: 'Phụ kiện',
        rating: 4.8,
        reviewCount: 512,
        stock: 95,
        isFeatured: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        tags: ['Apple', 'Audio', 'Hot'],
      ),
    ];
  }

  List<String> get _categories {
    final categories = _allProducts.map((p) => p.category).toSet().toList();
    categories.insert(0, 'Tất cả');
    return categories;
  }

  void _applyFilters() {
    setState(() {
      _filteredProducts = _allProducts.where((product) {
        bool matchCategory = _selectedCategory == 'Tất cả' ||
            product.category == _selectedCategory;
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
    _applyFilters();
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

  void _addToCart(ProductViewModel product) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã thêm "${product.name}" vào giỏ hàng'),
        backgroundColor: kGreenColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showProductDetail(ProductViewModel product) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: kCardColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: kBorderColor,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    product.imageUrl,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  product.category,
                  style: const TextStyle(
                    color: kSecondaryTextColor,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  product.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: kYellowColor, size: 20),
                    const SizedBox(width: 4),
                    Text(
                      '${product.rating}',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      ' (${product.reviewCount} đánh giá)',
                      style: const TextStyle(color: kSecondaryTextColor),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  product.formattedPrice,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: kAccentColor,
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: product.stockStatusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: product.stockStatusColor),
                  ),
                  child: Text(
                    product.stockStatusText,
                    style: TextStyle(
                      color: product.stockStatusColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Mô tả sản phẩm',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Text(
                  product.description,
                  style: const TextStyle(
                    color: kSecondaryTextColor,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 24),
                if (product.isInStock)
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        _addToCart(product);
                      },
                      icon: const Icon(Icons.shopping_cart),
                      label: const Text('Thêm vào giỏ hàng'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: kAccentColor,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  )
                else
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: null,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text('Hết hàng'),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _handleRefresh() async {
    await Future.delayed(const Duration(seconds: 1));
    setState(() {
      _initializeProducts();
      _applyFilters();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBackgroundColor,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildCategoryChips(),
          _buildFilterBar(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: _handleRefresh,
              color: kAccentColor,
              child: _filteredProducts.isEmpty
                  ? _buildEmptyState()
                  : _isGridView
                      ? _buildProductGrid()
                      : _buildProductList(),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomNav(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: kBackgroundColor,
      elevation: 0,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.all(8),
        child: CircleAvatar(
          backgroundColor: kCardColor,
          child: const Icon(Icons.person, color: kAccentColor, size: 20),
        ),
      ),
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Sản phẩm',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          Text(
            '${_filteredProducts.length} items',
            style: const TextStyle(fontSize: 12, color: kSecondaryTextColor),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(_isGridView ? Icons.list : Icons.grid_view),
          onPressed: () => setState(() => _isGridView = !_isGridView),
        ),
        IconButton(
          icon: const Icon(Icons.shopping_cart_outlined),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Giỏ hàng trống')),
            );
          },
        ),
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert),
          onSelected: (value) {
            if (value == 'logout') {
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            }
          },
          itemBuilder: (context) => [
            const PopupMenuItem(value: 'settings', child: Text('Cài đặt')),
            const PopupMenuItem(value: 'logout', child: Text('Đăng xuất')),
          ],
        ),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: kBackgroundColor,
        border: Border(bottom: BorderSide(color: kBorderColor)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: kCardColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: kBorderColor),
        ),
        child: TextField(
          controller: _searchController,
          onChanged: _handleSearch,
          style: const TextStyle(color: kPrimaryTextColor),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm sản phẩm...',
            hintStyle: const TextStyle(color: kSecondaryTextColor),
            prefixIcon:
                const Icon(Icons.search, color: kSecondaryTextColor, size: 20),
            suffixIcon: _searchQuery.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.clear,
                        color: kSecondaryTextColor, size: 20),
                    onPressed: () {
                      _searchController.clear();
                      _handleSearch('');
                    },
                  )
                : null,
            border: InputBorder.none,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    return Container(
      height: 48,
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: const BoxDecoration(
        color: kBackgroundColor,
        border: Border(bottom: BorderSide(color: kBorderColor)),
      ),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _categories.length,
        itemBuilder: (context, index) {
          final category = _categories[index];
          final isSelected = category == _selectedCategory;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (_) => _selectCategory(category),
              backgroundColor: kCardColor,
              selectedColor: kAccentColor,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : kPrimaryTextColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 13,
              ),
              side: BorderSide(
                color: isSelected ? kAccentColor : kBorderColor,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
          );
        },
      ),
    );
  }

  Widget _buildFilterBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        color: kCardColor,
        border: Border(bottom: BorderSide(color: kBorderColor)),
      ),
      child: Row(
        children: [
          const Icon(Icons.tune, color: kSecondaryTextColor, size: 18),
          const SizedBox(width: 8),
          Text(
            '${_filteredProducts.length} kết quả',
            style: const TextStyle(color: kSecondaryTextColor, fontSize: 13),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: kBackgroundColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: kBorderColor),
            ),
            child: DropdownButton<String>(
              value: _sortBy,
              onChanged: _handleSort,
              underline: const SizedBox.shrink(),
              isDense: true,
              icon: const Icon(Icons.arrow_drop_down,
                  size: 18, color: kSecondaryTextColor),
              style: const TextStyle(fontSize: 13, color: kPrimaryTextColor),
              dropdownColor: kCardColor,
              items: [
                'Mới nhất',
                'Giá: Thấp - Cao',
                'Giá: Cao - Thấp',
                'Đánh giá cao',
                'Tên A-Z',
              ]
                  .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                  .toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.68,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
        return ProductCard(
          product: product,
          onTap: () => _showProductDetail(product),
          onAddToCart: () => _addToCart(product),
        );
      },
    );
  }

  Widget _buildProductList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredProducts.length,
      itemBuilder: (context, index) {
        final product = _filteredProducts[index];
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

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.search_off,
            size: 80,
            color: kSecondaryTextColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy sản phẩm',
            style: TextStyle(fontSize: 18, color: kSecondaryTextColor),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNav() {
    return Container(
      decoration: const BoxDecoration(
        color: kCardColor,
        border: Border(top: BorderSide(color: kBorderColor)),
      ),
      child: BottomNavigationBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 1) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        },
        backgroundColor: kCardColor,
        selectedItemColor: kAccentColor,
        unselectedItemColor: kSecondaryTextColor,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag_outlined),
            activeIcon: Icon(Icons.shopping_bag),
            label: 'Sản phẩm',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard_outlined),
            activeIcon: Icon(Icons.dashboard),
            label: 'AI Dashboard',
          ),
        ],
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:diacritic/diacritic.dart';
import '../models/product_model.dart';
import '../services/product_service.dart';

class ProductProvider with ChangeNotifier {
  final ProductService _productService = ProductService();

  final List<Product> _allProducts = [];
  List<Product> _filteredProducts = [];
  Product? _selectedProduct;

  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String? _selectedCategory;

  Timer? _debounce;

  // Getters
  List<Product> get filteredProducts => _filteredProducts;
  Product? get selectedProduct => _selectedProduct;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get selectedCategory => _selectedCategory;

  /// Load dữ liệu sản phẩm
  Future<void> fetchProducts() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final products = await _productService.fetchProducts();
      _allProducts.clear();
      _allProducts.addAll(products.isNotEmpty ? products : _mockProducts);
    } catch (e) {
      _error = e.toString();
      _allProducts.clear();
      _allProducts.addAll(_mockProducts);
    }

    _filterProducts(); // Lọc luôn sau khi fetch
    _isLoading = false;
    notifyListeners();
  }

  /// Cập nhật từ khóa tìm kiếm
  void updateSearchQuery(String query) {
    _searchQuery = query;
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), _filterProducts);
  }

  /// Cập nhật danh mục
  void updateCategory(String? category) {
    _selectedCategory = category;
    _filterProducts();
  }

  /// Lọc sản phẩm dựa trên query và danh mục
  void _filterProducts() {
    final normQuery = removeDiacritics(_searchQuery.toLowerCase());

    _filteredProducts = _allProducts.where((product) {
      final normTitle = removeDiacritics(product.title.toLowerCase());
      final normDesc = removeDiacritics(product.description?.toLowerCase() ?? '');
      final matchQuery = normTitle.contains(normQuery) || normDesc.contains(normQuery);

      final matchCategory =
          _selectedCategory == null || product.category == _selectedCategory;

      return matchQuery && matchCategory;
    }).toList();

    notifyListeners();
  }

  /// Lấy chi tiết sản phẩm
  Future<void> fetchProductDetail(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProduct = await _productService.fetchProductDetail(id);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  /// Dọn dẹp timer nếu có
  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  /// Dữ liệu mẫu dùng khi có lỗi
  List<Product> get _mockProducts => [
        Product(
          id: '1',
          image: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
          title: 'Cà phê sữa đá',
          description: 'Cà phê truyền thống Việt Nam',
          category: 'Cà phê',
          size: 'M',
          price: 29000,
          salePrice: 25000,
          totalStock: 100,
          averageReview: 4.5,
          stockStatus: 'Còn hàng',
        ),
        Product(
          id: '2',
          image: 'https://images.unsplash.com/photo-1511920170033-f8396924c348?auto=format&fit=crop&w=400&q=80',
          title: 'Latte đá',
          description: 'Latte thơm ngon',
          category: 'Cà phê',
          size: 'L',
          price: 35000,
          salePrice: 32000,
          totalStock: 80,
          averageReview: 4.7,
          stockStatus: 'Còn hàng',
        ),
        Product(
          id: '3',
          image: 'https://images.unsplash.com/photo-1464983953574-0892a716854b?auto=format&fit=crop&w=400&q=80',
          title: 'Trà sữa matcha',
          description: 'Trà sữa vị matcha',
          category: 'Trà sữa',
          size: 'M',
          price: 32000,
          salePrice: 29000,
          totalStock: 60,
          averageReview: 4.3,
          stockStatus: 'Còn hàng',
        ),
        Product(
          id: '4',
          image: 'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=80',
          title: 'Cappuccino',
          description: 'Cappuccino Ý',
          category: 'Cà phê',
          size: 'M',
          price: 39000,
          salePrice: 35000,
          totalStock: 50,
          averageReview: 4.8,
          stockStatus: 'Còn hàng',
        ),
      ];
}

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart' as cs;
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:do_an_mobile_nc/Layout/masterlayout.dart';
import 'package:do_an_mobile_nc/models/product_model.dart';
import 'package:do_an_mobile_nc/screens/product/product_detail_screen.dart';
import 'package:do_an_mobile_nc/config/app_config.dart'; // Import config.dart
import 'package:provider/provider.dart';
import 'package:do_an_mobile_nc/providers/cart_provider.dart';
import '../voucher/voucher_screen.dart';
import 'package:do_an_mobile_nc/providers/auth_provider.dart';
import 'package:do_an_mobile_nc/providers/feature_provider.dart';
import 'package:do_an_mobile_nc/providers/favorites_provider.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> hotDealProducts = [];
  List<Product> allProducts = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchProducts();
    // Lấy banner từ provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<FeatureProvider>(context, listen: false).fetchBanners();
    });
  }

  Future<void> fetchProducts() async {
    setState(() {
      isLoading = true;
    });
    try {
      // Gọi song song 2 API: 1 cho tất cả sản phẩm, 1 cho ưu đãi hot (discount=true)
      final allResFuture = http.get(Uri.parse('${AppConfig.products}/get'));
      final hotDealResFuture = http.get(Uri.parse('${AppConfig.products}/get?discount=true'));
      final allRes = await allResFuture;
      final hotDealRes = await hotDealResFuture;

      if (allRes.statusCode == 200) {
        final data = json.decode(allRes.body);
        allProducts = (data['data'] as List).map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load all products, status: ${allRes.statusCode}');
      }

      if (hotDealRes.statusCode == 200) {
        final data = json.decode(hotDealRes.body);
        hotDealProducts = (data['data'] as List).map((json) => Product.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load hot deal products, status: ${hotDealRes.statusCode}');
      }

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }

  Widget _buildBanner() {
    final featureProvider = Provider.of<FeatureProvider>(context);
    
    if (featureProvider.isLoading) {
      return const SizedBox(
        height: 180,
        child: Center(child: CircularProgressIndicator()),
      );
    }
    
    if (featureProvider.error != null) {
      print('DEBUG: Banner error: ${featureProvider.error}');
      return SizedBox(
        height: 180,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, color: Colors.grey, size: 48),
              SizedBox(height: 8),
              Text(
                'Không thể tải banner',
                style: TextStyle(color: Colors.grey),
              ),
              TextButton(
                onPressed: () {
                  Provider.of<FeatureProvider>(context, listen: false).fetchBanners();
                },
                child: Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }
    
    final banners = featureProvider.banners;
    print('DEBUG: Number of banners: ${banners.length}');
    
    if (banners.isEmpty) {
      return const SizedBox(
        height: 180,
        child: Center(child: Text('Không có banner nào')),
      );
    }
    
    return cs.CarouselSlider(
      options: cs.CarouselOptions(height: 180.0, autoPlay: true),
      items: banners.map((banner) {
        print('DEBUG: Banner image URL: ${banner.image}');
        return Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const VoucherScreen(),
                  ),
                );
              },
              child: Container(
                width: MediaQuery.of(context).size.width,
                margin: const EdgeInsets.symmetric(horizontal: 5.0),
                decoration: BoxDecoration(
                  color: Colors.amber,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    banner.image,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                    print('DEBUG: Error loading banner image: $error');
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
            );
          },
        );
      }).toList(),
    );
  }

  Widget _buildSectionWithFilter(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.brown[800],
            ),
          ),
          GestureDetector(
            onTap: () {
              Navigator.pushReplacementNamed(
                context,
                '/products',
                arguments: null, // Không truyền filter không hợp lý
              );
            },
            child: Text(
              'Tất cả',
              style: TextStyle(
                fontSize: 14,
                color: Colors.orange,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductSlider(BuildContext context, List<Product> products, bool useSalePrice) {
    return Column(
      children: [
        cs.CarouselSlider(
          options: cs.CarouselOptions(
            height: 307.0,
            enlargeCenterPage: false,
            enableInfiniteScroll: false,
            viewportFraction: 0.5,
            padEnds: false, // Sát lề trái/phải
          ),
          items: products.map((product) {
            return Builder(
              builder: (BuildContext context) {
                return _buildProductCard(product, useSalePrice);
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildProductCard(Product product, bool useSalePrice) {
    final price = useSalePrice && product.salePrice != null ? product.salePrice! : product.price;
    String variant = product.description?.split(' ').firstWhere((word) => ['iced', 'frozen', 'chilled'].contains(word.toLowerCase()), orElse: () => '') ?? '';
    String displayTitle = variant.isNotEmpty ? '$variant ${product.title}' : product.title;
    final isOutOfStock = product.stockStatus == 'outOfStock';
    final favoritesProvider = Provider.of<FavoritesProvider>(context, listen: false);
    final isFavorite = favoritesProvider.favoriteProductIds.contains(product.id);

    return Card(
      elevation: 4,
      margin: EdgeInsets.symmetric(horizontal: 2.0, vertical: 4.0),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ProductDetailScreen(productId: product.id)),
          );
        },
        child: Container(
          width: MediaQuery.of(context).size.width * 0.6,
          padding: EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8.0),
                    child: Image.network(
                      product.image,
                      height: 120,
                      width: double.infinity,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(Icons.error, size: 50),
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    displayTitle,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  if (variant.isNotEmpty) SizedBox(height: 4),
                  if (variant.isNotEmpty)
                    Text(
                      variant,
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  SizedBox(height: 4),
                  if (useSalePrice && product.salePrice != null && product.salePrice! > 0)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          formatCurrency(product.salePrice!),
                          style: TextStyle(color: Colors.green, fontSize: 14),
                        ),
                        SizedBox(height: 4),
                        Text(
                          formatCurrency(product.price),
                          style: TextStyle(
                            color: Colors.grey,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    )
                  else
                    Text(
                      formatCurrency(price),
                      style: TextStyle(color: Colors.green, fontSize: 14),
                    ),
                ],
              ),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Icon(Icons.star, color: Colors.yellow, size: 20),
                  SizedBox(width: 4),
                  Text(
                    product.averageReview.toStringAsFixed(1),
                    style: TextStyle(fontSize: 16),
                  ),
                  Spacer(),
                  IconButton(
                    icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : Colors.grey),
                    onPressed: isOutOfStock
                        ? null
                        : () async {
                            await favoritesProvider.addFavorite(product.id);
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text('Đã thêm ${product.title} vào yêu thích!')),
                              );
                            }
                          },
                    iconSize: 24,
                  ),
                  Consumer<CartProvider>(
                    builder: (context, cartProvider, _) => IconButton(
                      icon: Icon(Icons.add_shopping_cart, color: isOutOfStock ? Colors.grey : Colors.brown),
                      onPressed: isOutOfStock
                          ? null
                          : () async {
                              final user = Provider.of<AuthProvider>(context, listen: false).user;
                              if (user == null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Vui lòng đăng nhập để thêm vào giỏ hàng!')),
                                );
                                return;
                              }
                              await cartProvider.addToCart(user.id, product.id, 1);
                              if (context.mounted) {
                                if (cartProvider.error != null) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Thêm vào giỏ hàng thất bại: ${cartProvider.error}'), backgroundColor: Colors.red),
                                  );
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Đã thêm ${product.title} vào giỏ hàng!')),
                                  );
                                }
                              }
                            },
                      iconSize: 24,
                    ),
                  ),
                ],
              ),
              if (isOutOfStock)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Hết hàng',
                    style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String formatCurrency(int value) {
    return value.toString().replaceAllMapped(
      RegExp(r'(\\d{1,3})(?=(\\d{3})+(?!\\d))'),
      (Match m) => '${m[1]}.',
    ) + ' đ';
  }

  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      currentIndex: 0,
      child: RefreshIndicator(
        onRefresh: () async {
          await fetchProducts();
          await Provider.of<FeatureProvider>(context, listen: false).fetchBanners();
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildBanner(),
              if (isLoading)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(50),
                    child: CircularProgressIndicator(),
                  ),
                ),
              if (!isLoading) _buildSectionWithFilter(context, 'Ưu đãi hot'),
              if (!isLoading) _buildProductSlider(context, hotDealProducts, true),
              if (!isLoading) _buildSectionWithFilter(context, 'Tất cả sản phẩm'),
              if (!isLoading) _buildProductSlider(context, allProducts, false),
            ],
          ),
        ),
      ),
    );
  }
}
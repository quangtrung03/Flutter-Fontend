import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/product_provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/favorites_provider.dart';
import '../../models/review_model.dart';
import '../../theme/colors.dart';
import '../../widgets/gradient_button.dart';
import 'add_review_screen.dart';
import 'product_reviews_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final String productId;

  const ProductDetailScreen({Key? key, required this.productId}) : super(key: key);

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}


class _ProductDetailScreenState extends State<ProductDetailScreen> {
  int quantity = 1;

  @override
void initState() {
  super.initState();
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final productId = widget.productId; // ← Lấy từ constructor
    context.read<ProductProvider>().fetchProductDetail(productId);
    context.read<ReviewProvider>().fetchReviews(productId);
  });
}

  @override
  Widget build(BuildContext context) {
    final productProvider = Provider.of<ProductProvider>(context);
    final reviewProvider = Provider.of<ReviewProvider>(context);
    final cartProvider = Provider.of<CartProvider>(context);
    final authProvider = Provider.of<AuthProvider>(context);
    final product = productProvider.selectedProduct;

    if (productProvider.isLoading) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Chi tiết sản phẩm', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
              const SizedBox(height: 16),
              Text(
                'Đang tải thông tin sản phẩm...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (productProvider.error != null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Chi tiết sản phẩm', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 64, color: AppColors.error),
              const SizedBox(height: 16),
              Text(
                'Lỗi: ${productProvider.error}',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Thử lại',
                icon: Icons.refresh,
                onPressed: () {
                  context.read<ProductProvider>().fetchProductDetail(widget.productId);
                },
              ),
            ],
          ),
        ),
      );
    }

    if (product == null) {
      return Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text('Chi tiết sản phẩm', style: TextStyle(color: AppColors.textPrimary)),
          backgroundColor: AppColors.white,
          elevation: 0,
          iconTheme: IconThemeData(color: AppColors.textPrimary),
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.local_bar_outlined, size: 64, color: AppColors.textLight),
              const SizedBox(height: 16),
              Text(
                'Không tìm thấy sản phẩm',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 24),
              GradientButton(
                text: 'Thử lại',
                icon: Icons.refresh,
                onPressed: () {
                  context.read<ProductProvider>().fetchProductDetail(widget.productId);
                },
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          product.title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        actions: [
          Consumer<FavoritesProvider>(
            builder: (context, favoritesProvider, _) {
              final isFavorite = favoritesProvider.favoriteProductIds.contains(product.id);
              return IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : AppColors.accent),
                onPressed: () async {
                  await favoritesProvider.addFavorite(product.id);
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Đã thêm ${product.title} vào yêu thích!'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product Image with gradient overlay
            Container(
              height: 300,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: NetworkImage(product.image),
                  fit: BoxFit.cover,
                ),
              ),
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withOpacity(0.4),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Sale badge
                    if (product.salePrice != null && product.salePrice! > 0)
                      Positioned(
                        top: 20,
                        left: 20,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.shadowMedium,
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Text(
                            'GIẢM GIÁ',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            // Product details
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product Title and Price
                  Text(
                    product.title,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      if (product.salePrice != null && product.salePrice! > 0) ...[
                        Text(
                          '${product.salePrice!.toStringAsFixed(0)} VNĐ',
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${product.price.toStringAsFixed(0)} VNĐ',
                          style: TextStyle(
                            fontSize: 18,
                            color: AppColors.textHint,
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                      ] else
                  Text(
                    '${product.price.toStringAsFixed(0)} VNĐ',
                          style: TextStyle(
                            fontSize: 24,
                            color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Rating and stock
                  Row(
                    children: [
                      Icon(Icons.star, color: AppColors.accent, size: 20),
                      const SizedBox(width: 4),
                      Text(
                        '${product.averageReview}',
                        style: TextStyle(
                          fontSize: 16,
                          color: AppColors.textSecondary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 20),
                      Icon(
                        product.totalStock > 0 ? Icons.check_circle : Icons.cancel,
                        color: product.totalStock > 0 ? AppColors.success : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        product.totalStock > 0 ? 'Còn hàng' : 'Hết hàng',
                        style: TextStyle(
                          fontSize: 16,
                          color: product.totalStock > 0 ? AppColors.success : AppColors.error,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  // Product Description
                  if (product.description != null) ...[
                    Text(
                      'Mô tả:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      product.description!,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  // Quantity Selector
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.background,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Text(
                          'Số lượng: ',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.primary.withOpacity(0.3)),
                          ),
                          child: Row(
                    children: [
                      IconButton(
                        onPressed: () {
                          if (quantity > 1) {
                            setState(() => quantity--);
                          }
                        },
                                icon: Icon(Icons.remove, color: AppColors.primary),
                      ),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16),
                                child: Text(
                                  '$quantity',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ),
                      IconButton(
                        onPressed: () {
                          setState(() => quantity++);
                        },
                                icon: Icon(Icons.add, color: AppColors.primary),
                              ),
                            ],
                          ),
                      ),
                    ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Add to Cart Button
                  GradientButton(
                    text: authProvider.user == null ? 'Đăng nhập để mua' : 'Thêm vào giỏ hàng',
                    icon: authProvider.user == null ? Icons.login : Icons.add_shopping_cart,
                    width: double.infinity,
                    onPressed: authProvider.user == null
                        ? () => Navigator.pushNamed(context, '/login')
                        : () async {
                            await cartProvider.addToCart(
                              authProvider.user!.id,
                              product.id,
                              quantity,
                            );
                            if (mounted) {
                              if (cartProvider.error != null) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(content: Text('Thêm vào giỏ hàng thất bại: ${cartProvider.error}'), backgroundColor: Colors.red),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('Đã thêm vào giỏ hàng'),
                                    backgroundColor: AppColors.success,
                                  ),
                                );
                              }
                            }
                          },
                  ),
                  const SizedBox(height: 16),
                  GradientButton(
                    text: 'Mua ngay',
                    icon: Icons.shopping_bag,
                    width: double.infinity,
                    onPressed: authProvider.user == null
                        ? () => Navigator.pushNamed(context, '/login')
                        : () async {
                            await cartProvider.addToCart(
                              authProvider.user!.id,
                              product.id,
                              quantity,
                            );
                            if (mounted) {
                              Navigator.pushNamed(context, '/checkout');
                            }
                          },
                  ),
                ],
              ),
            ),
            // Reviews Section
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.shadow,
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                    ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.rate_review, color: AppColors.primary, size: 24),
                      const SizedBox(width: 8),
                      Text(
                        'Đánh giá',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const Spacer(),
                      if (reviewProvider.reviews.isNotEmpty) ...[
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ProductReviewsScreen(
                                  productId: widget.productId,
                                  productName: product.title,
                                ),
                              ),
                            );
                          },
                          child: Text(
                            'Xem tất cả (${reviewProvider.reviews.length})',
                            style: TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                      IconButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => AddReviewScreen(
                                productId: widget.productId,
                                productName: product.title,
                              ),
                            ),
                          ).then((result) {
                            if (result == true) {
                              context.read<ReviewProvider>().fetchReviews(widget.productId);
                            }
                          });
                        },
                        icon: Icon(
                          Icons.edit,
                          color: AppColors.primary,
                          size: 20,
                        ),
                        tooltip: 'Viết đánh giá',
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (reviewProvider.isLoading)
                    Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
                      ),
                    )
                  else if (reviewProvider.reviews.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.rate_review_outlined,
                            size: 48,
                            color: AppColors.textLight,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Chưa có đánh giá nào',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    )
                  else
                    ...reviewProvider.reviews.map((review) => _buildReviewCard(review)),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewCard(Review review) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.primary.withOpacity(0.1)),
      ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (review.userAvatar != null)
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16),
                    image: DecorationImage(
                      image: NetworkImage(review.userAvatar!),
                      fit: BoxFit.cover,
                    ),
                  ),
                )
              else
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.person,
                    color: AppColors.primary,
                    size: 20,
                  ),
                  ),
              const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    review.userName,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                  ),
                ),
                Row(
                  children: List.generate(5, (index) {
                    return Icon(
                      index < review.rating ? Icons.star : Icons.star_border,
                    color: AppColors.accent,
                      size: 16,
                    );
                  }),
                ),
              ],
            ),
            const SizedBox(height: 8),
          Text(
            review.comment,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          ],
      ),
    );
  }
}

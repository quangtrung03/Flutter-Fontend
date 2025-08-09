import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/cart_model.dart';
import '../../theme/colors.dart';
import '../../utils/currency_helper.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key);

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<CartProvider>().fetchCart(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final user = Provider.of<AuthProvider>(context).user;
    final cart = cartProvider.cart;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Giỏ hàng', style: TextStyle(color: AppColors.textPrimary)),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppColors.primary),
      ),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary)))
          : (user == null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person_outline, color: AppColors.textLight, size: 48),
                      const SizedBox(height: 16),
                      const Text('Bạn chưa đăng nhập', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                    ],
                  ),
                )
              : (cartProvider.error != null
                  ? (() {
                      // Log lỗi ra console, không hiện lỗi đỏ cho user
                      // ignore: avoid_print
                      print('Cart error: \\${cartProvider.error}');
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.remove_shopping_cart, color: AppColors.textLight, size: 48),
                            const SizedBox(height: 16),
                            const Text('Giỏ hàng trống', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                            const SizedBox(height: 16),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: AppColors.white,
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                              ),
                              onPressed: () {
                                context.read<CartProvider>().fetchCart(user.id);
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tải lại giỏ hàng'),
                            ),
                          ],
                        ),
                      );
                    })()
                  : (cart == null || cart.items.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.remove_shopping_cart, color: AppColors.textLight, size: 48),
                              const SizedBox(height: 16),
                              const Text('Giỏ hàng trống', style: TextStyle(fontSize: 16, color: AppColors.textSecondary)),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primary,
                                  foregroundColor: AppColors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                onPressed: () {
                                  context.read<CartProvider>().fetchCart(user.id);
                                },
                                icon: const Icon(Icons.refresh),
                                label: const Text('Tải lại giỏ hàng'),
                              ),
                            ],
                          ),
                        )
                      : Column(
                          children: [
                            Expanded(
                              child: ListView.builder(
                                padding: const EdgeInsets.all(16),
                                itemCount: cart.items.length,
                                itemBuilder: (context, index) {
                                  final item = cart.items[index];
                                  return _buildCartItem(item, user.id);
                                },
                              ),
                            ),
                            _buildTotalSection(cart),
                          ],
                        ))))
    );
  }

  Widget _buildCartItem(CartItem item, String userId) {
    return Card(
      color: AppColors.white,
      margin: const EdgeInsets.only(bottom: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Product Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                image: DecorationImage(
                  image: NetworkImage(item.image),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Product Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.title,
                    style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Display price with sale price if available
                  if (item.salePrice != null && item.salePrice! < item.price) ...[
                    Row(
                      children: [
                        Text(
                          CurrencyHelper.formatVND(item.price),
                          style: const TextStyle(
                            color: AppColors.textLight,
                            decoration: TextDecoration.lineThrough,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          CurrencyHelper.formatVND(item.salePrice!),
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ] else
                    Text(
                      CurrencyHelper.formatVND(item.price),
                      style: const TextStyle(color: AppColors.primary),
                    ),
                ],
              ),
            ),
            // Quantity Controls
            Column(
              children: [
                Row(
                  children: [
                    IconButton(
                      onPressed: () async {
                        if (item.quantity > 1) {
                          await context.read<CartProvider>().updateCart(
                                userId,
                                item.productId,
                                item.quantity - 1,
                              );
                          if (context.mounted && context.read<CartProvider>().error == null) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Cập nhật số lượng thành công'), backgroundColor: AppColors.success),
                            );
                          }
                        }
                      },
                      icon: Icon(Icons.remove, color: AppColors.primary),
                    ),
                    Text('${item.quantity}', style: TextStyle(color: AppColors.textPrimary)),
                    IconButton(
                      onPressed: () async {
                        await context.read<CartProvider>().updateCart(
                              userId,
                              item.productId,
                              item.quantity + 1,
                            );
                        if (context.mounted && context.read<CartProvider>().error == null) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Cập nhật số lượng thành công'), backgroundColor: AppColors.success),
                          );
                        }
                      },
                      icon: Icon(Icons.add, color: AppColors.primary),
                    ),
                  ],
                ),
                IconButton(
                  onPressed: () async {
                    await context.read<CartProvider>().removeFromCart(
                          userId,
                          item.productId,
                        );
                    if (context.mounted && context.read<CartProvider>().error == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Đã xóa sản phẩm khỏi giỏ hàng'), backgroundColor: AppColors.success),
                      );
                    }
                  },
                  icon: Icon(Icons.delete, color: AppColors.error),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotalSection(Cart cart) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: AppColors.shadow,
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tổng cộng:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
              ),
              Text(
                CurrencyHelper.formatVND(cart.totalPrice),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.accent,
                foregroundColor: AppColors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: cart.items.isEmpty
                  ? null
                  : () {
                Navigator.pushNamed(context, '/checkout');
              },
              child: const Text('Thanh toán', style: TextStyle(fontSize: 16)),
            ),
          ),
        ],
      ),
    );
  }
} 
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/cart_provider.dart';
import '../../models/voucher_model.dart';
import '../../theme/colors.dart';
import '../../utils/currency_helper.dart';

class VoucherScreen extends StatefulWidget {
  const VoucherScreen({Key? key}) : super(key: key);

  @override
  State<VoucherScreen> createState() => _VoucherScreenState();
}

class _VoucherScreenState extends State<VoucherScreen> {
  final _voucherCodeController = TextEditingController();
  
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<VoucherProvider>().fetchVouchers();
    });
  }

  @override
  void dispose() {
    _voucherCodeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Mã giảm giá',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: AppColors.textPrimary),
        centerTitle: true,
      ),
      body: Consumer2<VoucherProvider, CartProvider>(
        builder: (context, voucherProvider, cartProvider, child) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Manual voucher input section
                _buildManualVoucherInput(voucherProvider, cartProvider),
                
                const SizedBox(height: 24),
                
                // Available vouchers section
                Text(
                  'Voucher có sẵn',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                
                if (voucherProvider.isLoading)
                  _buildLoadingState()
                else if (voucherProvider.error != null)
                  _buildErrorState(voucherProvider)
                else if (voucherProvider.vouchers.isEmpty)
                  _buildEmptyState()
                else
                  _buildVoucherList(voucherProvider, cartProvider),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildManualVoucherInput(VoucherProvider voucherProvider, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.confirmation_number,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Nhập mã voucher',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _voucherCodeController,
                  decoration: InputDecoration(
                    hintText: 'Nhập mã voucher',
                    hintStyle: TextStyle(color: AppColors.textLight),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary.withOpacity(0.3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppColors.primary, width: 2),
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  ),
                  textCapitalization: TextCapitalization.characters,
                ),
              ),
              const SizedBox(width: 12),
              ElevatedButton(
                onPressed: voucherProvider.isLoading ? null : () async {
                  if (_voucherCodeController.text.isNotEmpty) {
                        final success = await voucherProvider.applyVoucher(
                          _voucherCodeController.text.toUpperCase(),
                          cartProvider.cart?.totalPrice.toDouble() ?? 0.0,
                        );                    if (success) {
                      _showSnackBar(
                        voucherProvider.successMessage ?? 'Áp dụng voucher thành công!',
                        isSuccess: true,
                      );
                      Navigator.pop(context, true);
                    } else {
                      _showSnackBar(
                        voucherProvider.error ?? 'Không thể áp dụng voucher',
                        isSuccess: false,
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: voucherProvider.isLoading
                    ? SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
                        ),
                      )
                    : const Text('Áp dụng'),
              ),
            ],
          ),
          
          // Show applied voucher
          if (voucherProvider.appliedVoucher != null) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.success.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.success.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppColors.success, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đã áp dụng: ${voucherProvider.appliedVoucher!.code}',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      voucherProvider.clearAppliedVoucher();
                      _voucherCodeController.clear();
                    },
                    child: Text(
                      'Bỏ',
                      style: TextStyle(color: AppColors.error, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
            const SizedBox(height: 16),
            Text(
              'Đang tải voucher...',
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

  Widget _buildErrorState(VoucherProvider voucherProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              voucherProvider.error ?? 'Có lỗi xảy ra',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => voucherProvider.fetchVouchers(),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          children: [
            Icon(
              Icons.local_offer_outlined,
              color: AppColors.textLight,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Không có voucher nào khả dụng',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Hãy quay lại sau để xem voucher mới!',
              style: TextStyle(
                color: AppColors.textLight,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVoucherList(VoucherProvider voucherProvider, CartProvider cartProvider) {
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: voucherProvider.vouchers.length,
      itemBuilder: (context, index) {
        final voucher = voucherProvider.vouchers[index];
        final isValid = voucher.isValidForOrder(cartProvider.cart?.totalPrice.toDouble() ?? 0.0);
        final isApplied = voucherProvider.appliedVoucher?.id == voucher.id;
        
        return _buildVoucherCard(voucher, isValid, isApplied, voucherProvider, cartProvider);
      },
    );
  }

  Widget _buildVoucherCard(
    Voucher voucher, 
    bool isValid, 
    bool isApplied, 
    VoucherProvider voucherProvider, 
    CartProvider cartProvider
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isApplied 
              ? AppColors.success 
              : (isValid ? AppColors.primary.withOpacity(0.3) : AppColors.textLight.withOpacity(0.3)),
          width: isApplied ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textLight.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Voucher header with discount info
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  isValid ? AppColors.primary.withOpacity(0.1) : AppColors.textLight.withOpacity(0.05),
                  isValid ? AppColors.accent.withOpacity(0.1) : AppColors.textLight.withOpacity(0.05),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isValid ? AppColors.primary : AppColors.textLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.local_offer,
                    color: AppColors.white,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        voucher.code,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isValid ? AppColors.primary : AppColors.textLight,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        voucher.displayValue,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isValid ? AppColors.accent : AppColors.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isApplied)
                  Icon(
                    Icons.check_circle,
                    color: AppColors.success,
                    size: 24,
                  ),
              ],
            ),
          ),
          
          // Voucher details
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Conditions
                if (voucher.minOrderAmount != null && voucher.minOrderAmount! > 0) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Đơn hàng tối thiểu: ${CurrencyHelper.formatVND(voucher.minOrderAmount!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                ],
                
                // Expiry date
                if (voucher.expiredAt != null) ...[
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Hết hạn: ${_formatDate(voucher.expiredAt!)}',
                        style: TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Action button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: isApplied 
                        ? () {
                            voucherProvider.clearAppliedVoucher();
                            _showSnackBar('Đã bỏ áp dụng voucher', isSuccess: true);
                          }
                        : isValid 
                            ? () async {
                                final success = await voucherProvider.applyVoucher(
                                  voucher.code,
                                  cartProvider.cart?.totalPrice.toDouble() ?? 0.0,
                                );
                                
                                if (success) {
                                  _showSnackBar(
                                    'Áp dụng voucher thành công!',
                                    isSuccess: true,
                                  );
                                  Navigator.pop(context, true);
                                } else {
                                  _showSnackBar(
                                    voucherProvider.error ?? 'Không thể áp dụng voucher',
                                    isSuccess: false,
                                  );
                                }
                              }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isApplied 
                          ? AppColors.error 
                          : (isValid ? AppColors.primary : AppColors.textLight),
                      foregroundColor: AppColors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      isApplied 
                          ? 'Bỏ áp dụng' 
                          : isValid 
                              ? 'Sử dụng' 
                              : voucher.getErrorMessage(cartProvider.cart?.totalPrice.toDouble() ?? 0.0) ?? 'Không khả dụng',
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  void _showSnackBar(String message, {required bool isSuccess}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isSuccess ? AppColors.success : AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}

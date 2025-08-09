import 'package:intl/intl.dart';

class CurrencyHelper {
  static final NumberFormat _vndFormatter = NumberFormat('#,###', 'vi_VN');
  static final NumberFormat _usdFormatter = NumberFormat('#,##0.00', 'en_US');

  /// Format VND currency (Vietnamese Dong)
  /// Input: 25000 -> Output: "25,000 VNĐ"
  static String formatVND(dynamic amount) {
    if (amount == null) return '0 VNĐ';
    
    int value;
    if (amount is double) {
      value = amount.round();
    } else if (amount is int) {
      value = amount;
    } else {
      value = int.tryParse(amount.toString()) ?? 0;
    }
    
    return '${_vndFormatter.format(value)} VNĐ';
  }

  /// Format USD currency  
  /// Input: 1.50 -> Output: "$1.50"
  static String formatUSD(dynamic amount) {
    if (amount == null) return '\$0.00';
    
    double value;
    if (amount is int) {
      value = amount.toDouble();
    } else if (amount is double) {
      value = amount;
    } else {
      value = double.tryParse(amount.toString()) ?? 0.0;
    }
    
    return '\$${_usdFormatter.format(value)}';
  }

  /// Convert VND to USD (approximate rate: 1 USD = 24,000 VND)
  /// Input: 25000 VND -> Output: 1.04 USD
  static double vndToUsd(dynamic vndAmount) {
    if (vndAmount == null) return 0.0;
    
    double value;
    if (vndAmount is int) {
      value = vndAmount.toDouble();
    } else if (vndAmount is double) {
      value = vndAmount;
    } else {
      value = double.tryParse(vndAmount.toString()) ?? 0.0;
    }
    
    return double.parse((value / 24000).toStringAsFixed(2));
  }

  /// Convert USD to VND (approximate rate: 1 USD = 24,000 VND)
  /// Input: 1.50 USD -> Output: 36000 VND
  static int usdToVnd(dynamic usdAmount) {
    if (usdAmount == null) return 0;
    
    double value;
    if (usdAmount is int) {
      value = usdAmount.toDouble();
    } else if (usdAmount is double) {
      value = usdAmount;
    } else {
      value = double.tryParse(usdAmount.toString()) ?? 0.0;
    }
    
    return (value * 24000).round();
  }

  /// Format price with sale price display
  /// Input: price=30000, salePrice=25000 -> Output: "30,000 VNĐ  25,000 VNĐ"
  /// Input: price=30000, salePrice=null -> Output: "30,000 VNĐ"
  static String formatPriceWithSale(int price, int? salePrice) {
    if (salePrice != null && salePrice < price) {
      return '${formatVND(price)}  ${formatVND(salePrice)}';
    }
    return formatVND(price);
  }

  /// Get effective price (sale price if available, otherwise regular price)
  static int getEffectivePrice(int price, int? salePrice) {
    return salePrice ?? price;
  }

  /// Calculate discount percentage
  /// Input: price=30000, salePrice=25000 -> Output: 17 (%)
  static int getDiscountPercentage(int price, int? salePrice) {
    if (salePrice == null || salePrice >= price) return 0;
    return ((price - salePrice) / price * 100).round();
  }

  /// Format discount badge text
  /// Input: price=30000, salePrice=25000 -> Output: "-17%"
  static String formatDiscountBadge(int price, int? salePrice) {
    final discount = getDiscountPercentage(price, salePrice);
    return discount > 0 ? '-$discount%' : '';
  }

  /// Validate price input (must be positive integer)
  static bool isValidPrice(String input) {
    final value = int.tryParse(input);
    return value != null && value > 0;
  }

  /// Parse price from string input
  static int parsePrice(String input) {
    return int.tryParse(input) ?? 0;
  }

  /// Calculate voucher discount amount
  static double calculateVoucherDiscount(
    double orderTotal, 
    String voucherType, 
    int voucherValue, 
    int? maxDiscount
  ) {
    double discount = 0;
    
    if (voucherType == 'percent') {
      // Percentage discount
      discount = (orderTotal * voucherValue) / 100;
      
      // Apply max discount limit if exists
      if (maxDiscount != null && discount > maxDiscount) {
        discount = maxDiscount.toDouble();
      }
    } else if (voucherType == 'fixed') {
      // Fixed amount discount
      discount = voucherValue.toDouble();
      
      // Discount cannot exceed order total
      if (discount > orderTotal) {
        discount = orderTotal;
      }
    }
    
    return discount;
  }

  /// Check if voucher is valid for order
  static bool isVoucherValidForOrder(
    double orderTotal,
    int? minOrderAmount,
    DateTime? expiredAt,
    bool isActive
  ) {
    // Check if voucher is active
    if (!isActive) return false;
    
    // Check expiration
    if (expiredAt != null && DateTime.now().isAfter(expiredAt)) {
      return false;
    }
    
    // Check minimum order amount
    if (minOrderAmount != null && orderTotal < minOrderAmount) {
      return false;
    }
    
    return true;
  }

  /// Format voucher discount display
  static String formatVoucherDiscount(String type, int value, int? maxDiscount) {
    if (type == 'percent') {
      String display = 'Giảm $value%';
      if (maxDiscount != null && maxDiscount > 0) {
        display += ' (tối đa ${formatVND(maxDiscount)})';
      }
      return display;
    } else {
      return 'Giảm ${formatVND(value)}';
    }
  }

  /// Get voucher error message
  static String? getVoucherErrorMessage(
    double orderTotal,
    int? minOrderAmount,
    DateTime? expiredAt,
    bool isActive
  ) {
    if (!isActive) {
      return 'Mã giảm giá đã bị vô hiệu hóa';
    }
    
    if (expiredAt != null && DateTime.now().isAfter(expiredAt)) {
      return 'Mã giảm giá đã hết hạn';
    }
    
    if (minOrderAmount != null && orderTotal < minOrderAmount) {
      return 'Đơn hàng tối thiểu ${formatVND(minOrderAmount)} để sử dụng mã này';
    }
    
    return null;
  }
}

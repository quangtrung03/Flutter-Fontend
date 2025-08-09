import 'package:flutter/material.dart';
import '../theme/colors.dart';

class AppErrorHandler {
  static void handleError(BuildContext context, dynamic error, {String? customMessage}) {
    String message = customMessage ?? _parseError(error);
    
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    if (!context.mounted) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.primary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static String _parseError(dynamic error) {
    if (error == null) return 'Đã xảy ra lỗi không xác định';
    
    String errorStr = error.toString();
    
    // Parse common error patterns
    if (errorStr.contains('SocketException')) return 'Lỗi kết nối mạng. Vui lòng kiểm tra internet.';
    if (errorStr.contains('TimeoutException')) return 'Kết nối timeout. Vui lòng thử lại.';
    if (errorStr.contains('FormatException')) return 'Lỗi định dạng dữ liệu từ server.';
    if (errorStr.contains('TypeError')) return 'Lỗi kiểu dữ liệu.';
    if (errorStr.contains('Failed to load')) return 'Không thể tải dữ liệu. Vui lòng thử lại.';
    if (errorStr.contains('HttpException')) return 'Lỗi server. Vui lòng thử lại sau.';
    if (errorStr.contains('HandshakeException')) return 'Lỗi bảo mật kết nối.';
    if (errorStr.contains('Instance of \'_JsonMap\'')) return 'Lỗi xử lý dữ liệu từ server.';
    
    // Clean up common error prefixes
    errorStr = errorStr.replaceAll('Exception: ', '');
    errorStr = errorStr.replaceAll('Failed to load orders: ', '');
    errorStr = errorStr.replaceAll('TypeError: ', '');
    
    return errorStr.length > 100 ? 'Đã xảy ra lỗi trong ứng dụng' : errorStr;
  }
}

// Extension for easier usage
extension ErrorHandlerExtension on BuildContext {
  void showError(dynamic error, {String? customMessage}) {
    AppErrorHandler.handleError(this, error, customMessage: customMessage);
  }
  
  void showSuccess(String message) {
    AppErrorHandler.showSuccess(this, message);
  }
  
  void showInfo(String message) {
    AppErrorHandler.showInfo(this, message);
  }
}

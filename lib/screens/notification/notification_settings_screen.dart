import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/colors.dart';
import '../../services/notification_service.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  State<NotificationSettingsScreen> createState() => _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState extends State<NotificationSettingsScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  // Notification settings
  Map<String, bool> _notificationSettings = {
    'newOrder': true,
    'orderStatusUpdate': true,
    'orderDelivered': true,
    'orderCancelled': true,
    'promotions': false,
    'newProduct': false,
  };

  @override
  void initState() {
    super.initState();
    _loadNotificationSettings();
  }

  Future<void> _loadNotificationSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Load user's notification preferences from backend
      final settings = await _notificationService.getNotificationSettings();
      if (settings != null) {
        setState(() {
          _notificationSettings = settings;
        });
      }
    } catch (e) {
      _showSnackBar('Không thể tải cài đặt thông báo: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _updateNotificationSetting(String key, bool value) async {
    setState(() {
      _notificationSettings[key] = value;
    });

    try {
      await _notificationService.updateNotificationSetting(key, value);
      _showSnackBar('Đã cập nhật cài đặt thông báo', isSuccess: true);
    } catch (e) {
      // Revert on error
      setState(() {
        _notificationSettings[key] = !value;
      });
      _showSnackBar('Không thể cập nhật cài đặt: $e', isSuccess: false);
    }
  }

  Future<void> _sendTestNotification(String type) async {
    setState(() {
      _isLoading = true;
    });

    try {
      final user = context.read<AuthProvider>().user;
      if (user == null) {
        _showSnackBar('Bạn cần đăng nhập để gửi thông báo', isSuccess: false);
        return;
      }

      await _notificationService.sendTestNotification(user.email, type);
      _showSnackBar('Đã gửi email thông báo thử nghiệm!', isSuccess: true);
    } catch (e) {
      _showSnackBar('Không thể gửi thông báo: $e', isSuccess: false);
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = context.read<AuthProvider>().user;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Cài đặt thông báo',
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
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
              ),
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // User email info
                  _buildEmailInfoCard(user),
                  
                  const SizedBox(height: 24),
                  
                  // Notification Settings
                  _buildNotificationSettings(),
                  
                  const SizedBox(height: 24),
                  
                  // Test Notifications
                  _buildTestNotifications(),
                ],
              ),
            ),
    );
  }

  Widget _buildEmailInfoCard(user) {
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
                Icons.email,
                color: AppColors.primary,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Thông tin email',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Thông báo sẽ được gửi đến email:',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? 'Chưa có email',
            style: TextStyle(
              color: AppColors.primary,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationSettings() {
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
          Text(
            'Cài đặt thông báo',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildNotificationOption(
            'newOrder',
            'Đơn hàng mới',
            'Nhận thông báo khi có đơn hàng mới',
            Icons.shopping_cart,
          ),
          
          _buildNotificationOption(
            'orderStatusUpdate',
            'Cập nhật trạng thái',
            'Nhận thông báo khi đơn hàng thay đổi trạng thái',
            Icons.update,
          ),
          
          _buildNotificationOption(
            'orderDelivered',
            'Giao hàng thành công',
            'Nhận thông báo khi đơn hàng được giao thành công',
            Icons.check_circle,
          ),
          
          _buildNotificationOption(
            'orderCancelled',
            'Đơn hàng bị hủy',
            'Nhận thông báo khi đơn hàng bị hủy',
            Icons.cancel,
          ),
          
          _buildNotificationOption(
            'promotions',
            'Khuyến mãi',
            'Nhận thông báo về các chương trình khuyến mãi',
            Icons.local_offer,
          ),
          
          _buildNotificationOption(
            'newProduct',
            'Sản phẩm mới',
            'Nhận thông báo về sản phẩm mới',
            Icons.new_releases,
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationOption(String key, String title, String subtitle, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: AppColors.primary,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _notificationSettings[key] ?? false,
            onChanged: (value) => _updateNotificationSetting(key, value),
            activeColor: AppColors.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildTestNotifications() {
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
          Text(
            'Gửi thông báo thử nghiệm',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Bấm vào các nút bên dưới để gửi email thông báo thử nghiệm',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 16),
          
          _buildTestButton(
            'Đơn hàng mới',
            'Gửi email thông báo đơn hàng mới',
            Icons.shopping_cart,
            () => _sendTestNotification('newOrder'),
          ),
          
          _buildTestButton(
            'Cập nhật đơn hàng',
            'Gửi email thông báo cập nhật trạng thái',
            Icons.update,
            () => _sendTestNotification('orderUpdate'),
          ),
          
          _buildTestButton(
            'Giao hàng thành công',
            'Gửi email thông báo giao hàng thành công',
            Icons.check_circle,
            () => _sendTestNotification('orderDelivered'),
          ),
          
          _buildTestButton(
            'Khuyến mãi mới',
            'Gửi email thông báo khuyến mãi',
            Icons.local_offer,
            () => _sendTestNotification('promotion'),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String title, String subtitle, IconData icon, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: SizedBox(
        width: double.infinity,
        child: ElevatedButton(
          onPressed: _isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.white,
            foregroundColor: AppColors.textPrimary,
            padding: const EdgeInsets.all(16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: BorderSide(color: AppColors.primary.withOpacity(0.3)),
            ),
            elevation: 0,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primary, size: 20),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.send,
                color: AppColors.primary,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
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

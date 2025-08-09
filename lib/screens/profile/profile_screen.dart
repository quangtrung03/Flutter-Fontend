import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../Layout/masterlayout.dart';
import '../../theme/colors.dart';
import '../voucher/voucher_screen.dart';
import '../notification/notification_settings_screen.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<AuthProvider>(context).user;

    if (user == null) {
      return MasterLayout(
        currentIndex: 4, // Profile tab
        child: const Center(child: Text('Bạn chưa đăng nhập')),
      );
    }

    return MasterLayout(
      currentIndex: 4, // Profile tab
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // User Avatar and Info
            CircleAvatar(
              radius: 50,
              backgroundImage: user.avatar != null
                  ? NetworkImage(user.avatar!)
                  : null,
              child: user.avatar == null
                  ? Icon(Icons.person, size: 50, color: AppColors.primary)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              user.userName,
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              user.email,
              style: TextStyle(color: AppColors.textSecondary),
            ),
            const SizedBox(height: 24),
            // Profile Options
            _buildProfileOption(
              icon: Icons.shopping_bag,
              title: 'Lịch sử đơn hàng',
              onTap: () => Navigator.pushNamed(context, '/order-history'),
            ),
            _buildProfileOption(
              icon: Icons.favorite,
              title: 'Sản phẩm yêu thích',
              onTap: () => Navigator.pushNamed(context, '/favorites'),
            ),
            _buildProfileOption(
              icon: Icons.local_offer,
              title: 'Mã giảm giá của tôi',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const VoucherScreen(),
                ),
              ),
            ),
            _buildProfileOption(
              icon: Icons.location_on,
              title: 'Địa chỉ giao hàng',
              onTap: () => Navigator.pushNamed(context, '/address'),
            ),
            _buildProfileOption(
              icon: Icons.notifications,
              title: 'Cài đặt thông báo',
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              ),
            ),
            _buildProfileOption(
              icon: Icons.settings,
              title: 'Cài đặt',
              onTap: () => Navigator.pushNamed(context, '/settings'),
            ),
            _buildProfileOption(
              icon: Icons.help,
              title: 'Trợ giúp',
              onTap: () => Navigator.pushNamed(context, '/contact'),
            ),
            _buildProfileOption(
              icon: Icons.chat,
              title: 'Chat với admin',
              onTap: () => Navigator.pushNamed(context, '/contact'),
            ),
            const SizedBox(height: 24),
            // Logout Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await Provider.of<AuthProvider>(context, listen: false).logout();
                  if (context.mounted) {
                    Navigator.pushReplacementNamed(context, '/login');
                  }
                },
                icon: const Icon(Icons.logout),
                label: const Text('Đăng xuất'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            // Nếu là admin, thêm nút chuyển sang trang quản lý
            if (user.role == 'admin') ...[
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.pushNamed(context, '/admin');
                  },
                  icon: const Icon(Icons.admin_panel_settings),
                  label: const Text('Quản lý hệ thống'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 24),
            // User Details
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Thông tin chi tiết',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 16),
                    _buildDetailRow('Tên', user.userName),
                    _buildDetailRow('Vai trò', user.role ?? 'Khách hàng'),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileOption({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios),
      onTap: onTap,
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(value)),
        ],
      ),
    );
  }
} 
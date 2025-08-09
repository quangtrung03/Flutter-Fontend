import '../pages/blog_page.dart';
import '../pages/order_page.dart';
import '../pages/product_page.dart';
import '../pages/user_page.dart';
import '../pages/voucher_page.dart';
import '../pages/banner_page.dart';
import '../pages/support_chat_page.dart';
import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/header.dart';
import '../widgets/statistic_card.dart';
import '../widgets/sales_chart.dart';
import '../widgets/revenue_stats_widget.dart';
import '../../config/app_config.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../services/admin_dashboard_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({Key? key}) : super(key: key);

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int adminCount = 0;
  int userCount = 0;
  int orderCount = 0;
  int totalRevenue = 0;
  int todayOrders = 0;
  int pendingOrders = 0;
  int completedOrders = 0;
  int todayRevenue = 0;
  bool isLoading = true;
  List<Map<String, dynamic>> recentOrders = [];
  List<Map<String, dynamic>> topProducts = [];

  @override
  void initState() {
    super.initState();
    fetchDashboardData();
  }

  Future<void> fetchDashboardData() async {
    setState(() => isLoading = true);
    try {
      // ✅ Fetch stats từ API dashboard-stats mới
      final dashboardStats = await AdminDashboardService.getDashboardStats();
      
      // Basic stats
      adminCount = await AdminDashboardService.getAdminCount();
      userCount = await AdminDashboardService.getUserCount();
      orderCount = dashboardStats['orders']['total'] ?? 0;
      totalRevenue = (dashboardStats['revenue']['total'] ?? 0).toInt();
      
      // Today stats
      todayOrders = dashboardStats['orders']['today'] ?? 0;
      todayRevenue = (dashboardStats['revenue']['today'] ?? 0).toInt();
      
      // Additional stats
      pendingOrders = dashboardStats['orders']['week'] ?? 0; // Sử dụng week orders thay vì pending
      completedOrders = dashboardStats['orders']['month'] ?? 0; // Sử dụng month orders thay vì completed
      
      // Recent orders và top products từ API
      recentOrders = List<Map<String, dynamic>>.from(dashboardStats['topProducts'] ?? []);
      topProducts = List<Map<String, dynamic>>.from(dashboardStats['topProducts'] ?? []);
      
    } catch (e) {
      print('Error fetching dashboard data: $e');
      // Fallback values
      adminCount = 5;
      userCount = 89;
      orderCount = 156;
      totalRevenue = 5420000;
      todayOrders = 8;
      todayRevenue = 320000;
      pendingOrders = 32;
      completedOrders = 98;
    }
    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.home),
              label: const Text('Về trang chủ'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD7B7A3),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                elevation: 0,
              ),
              onPressed: () {
                // Quay về trang home
                Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
              },
            ),
          ),
        ],
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
        titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFFF7F7F7),
              ),
              child: Row(
                children: [
                  Icon(Icons.show_chart, size: 28, color: Colors.black87),
                  SizedBox(width: 8),
                  Text('Admin Panel', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                ],
              ),
            ),
            _drawerItem(Icons.dashboard, 'Dashboard', context, onTap: () {
              Navigator.pop(context);
            }),
            _drawerItem(Icons.shopping_bag, 'Products', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const ProductPage()));
            }),
            _drawerItem(Icons.receipt_long, 'Orders', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const OrderPage()));
            }),
            _drawerItem(Icons.person, 'User', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const UserPage()));
            }),
            _drawerItem(Icons.image, 'Banner', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => BannerPage()));
            }),
             _drawerItem(Icons.article, 'Blog', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => BlogPage()));
            }),
            _drawerItem(Icons.support_agent, 'Chat Hỗ trợ', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const SupportChatPage()));
            }),
            _drawerItem(Icons.card_giftcard, 'Vouchers', context, onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (_) => const VoucherPage()));
            }),
          ],
        ),
      ),
      body: isLoading
        ? const Center(child: CircularProgressIndicator())
        : Container(
            color: const Color(0xFFF5F5F5),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // FIXED: Responsive StatisticCards using GridView
                  _buildStatsGrid(),
                  
                  const SizedBox(height: 24),

                  // Recent Orders Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Đơn hàng gần đây',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const OrderPage()),
                                  );
                                },
                                child: const Text('Xem tất cả'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          recentOrders.isEmpty 
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'Chưa có đơn hàng nào',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              )
                            : Column(
                                children: recentOrders.take(5).map((order) => 
                                  _buildOrderItem(order),
                                ).toList(),
                              ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Top Products Section
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Sản phẩm bán chạy',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const ProductPage()),
                                  );
                                },
                                child: const Text('Xem tất cả'),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          topProducts.isEmpty 
                            ? const Center(
                                child: Padding(
                                  padding: EdgeInsets.all(20),
                                  child: Text(
                                    'Chưa có dữ liệu sản phẩm',
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                )
                              )
                            : Column(
                                children: topProducts.take(5).map((product) => 
                                  _buildProductItem(product),
                                ).toList(),
                              ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ✅ THÊM THỐNG KÊ DOANH THU THEO THỜI GIAN
                  const RevenueStatsWidget(),

                  const SizedBox(height: 24),

                  // ✅ THÊM BIỂU ĐỒ DOANH THU (SalesChart đã có title built-in)
                  const SalesChart(), // 🔧 Bỏ Card wrapper để tránh duplicate title

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
    );
  }

  String _formatCurrency(int amount) {
    if (amount >= 1000000) {
      return '${(amount / 1000000).toStringAsFixed(1)}M VND';
    } else if (amount >= 1000) {
      return '${(amount / 1000).toStringAsFixed(0)}K VND';
    } else {
      return '$amount VND';
    }
  }

  Widget _buildOrderItem(Map<String, dynamic> order) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.orange[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.receipt_long,
              color: Colors.orange[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Đơn hàng #${order['orderNumber']?.toString() ?? order['id']?.toString() ?? 'N/A'}',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  '${order['customerName']?.toString() ?? 'Khách hàng'} | ${_formatCurrency(order['total'] ?? 0)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _getOrderStatusColor(order['status']?.toString() ?? 'pending'),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              _getOrderStatusText(order['status']?.toString() ?? 'pending'),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getOrderStatusColor(String status) {
    switch (status) {
      case 'completed':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'processing':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  String _getOrderStatusText(String status) {
    switch (status) {
      case 'completed':
        return 'Hoàn thành';
      case 'pending':
        return 'Chờ xử lý';
      case 'processing':
        return 'Đang xử lý';
      default:
        return 'Khác';
    }
  }

  Widget _buildProductItem(Map<String, dynamic> product) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: Colors.brown[100],
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.coffee,
              color: Colors.brown[600],
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product['name']?.toString() ?? 'N/A',
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
                const SizedBox(height: 2),
                Text(
                  'Đã bán: ${product['sold'] ?? 0} | ${_formatCurrency(product['revenue'] ?? 0)}',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
          Icon(
            Icons.trending_up,
            color: Colors.green[600],
            size: 20,
          ),
        ],
      ),
    );
  }

  // 🔧 FIXED: Simple Grid Layout for Stats Cards với better overflow handling
  Widget _buildStatsGrid() {
    final screenWidth = MediaQuery.of(context).size.width;
    final crossAxisCount = screenWidth > 600 ? 3 : 2; // 3 columns on tablet, 2 on mobile
    
    final List<StatisticCard> statsCards = [
      StatisticCard(
        title: 'Doanh thu hôm nay',
        value: _formatCurrency(todayRevenue),
        icon: Icons.today,
        iconColor: Colors.green,
      ),
      StatisticCard(
        title: 'Đơn hàng hôm nay',
        value: '$todayOrders',
        icon: Icons.shopping_cart_outlined,
        iconColor: Colors.blue,
      ),
      StatisticCard(
        title: 'Tổng doanh thu',
        value: _formatCurrency(totalRevenue),
        icon: Icons.attach_money,
        iconColor: Colors.green,
      ),
      StatisticCard(
        title: 'Tổng đơn hàng',
        value: '$orderCount',
        icon: Icons.shopping_cart,
        iconColor: Colors.blue,
      ),
      StatisticCard(
        title: 'Số người dùng',
        value: '$userCount',
        icon: Icons.people,
        iconColor: Colors.purple,
      ),
      StatisticCard(
        title: 'Số admin',
        value: '$adminCount',
        icon: Icons.admin_panel_settings,
        iconColor: Colors.red,
      ),
    ];

    // 🔧 Sử dụng Container với height cố định thay vì GridView shrinkWrap
    return Container(
      height: crossAxisCount == 2 ? 240 : 180, // 🔧 Height tính toán dựa trên số cột
      child: GridView.builder(
        physics: const NeverScrollableScrollPhysics(), // 🔧 Tắt scroll riêng
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: crossAxisCount == 2 ? 2.8 : 2.2, // 🔧 Tăng aspect ratio hơn nữa
        ),
        itemCount: statsCards.length,
        itemBuilder: (context, index) => statsCards[index],
      ),
    );
  }
}

Widget _drawerItem(IconData icon, String label, BuildContext context, {VoidCallback? onTap}) {
  return ListTile(
    leading: Icon(icon, color: Colors.grey[700]),
    title: Text(label, style: const TextStyle(fontSize: 16)),
    onTap: onTap,
  );
} 
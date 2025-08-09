import 'package:flutter/material.dart';
import 'order_detail_page.dart';
import 'user_page.dart';
import 'package:do_an_mobile_nc/admin/models/admin_order_model.dart';
import 'package:do_an_mobile_nc/admin/services/admin_order_service.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';
import '../../models/user_model.dart';

class OrderPage extends StatefulWidget {
  const OrderPage({Key? key}) : super(key: key);

  @override
  State<OrderPage> createState() => _OrderPageState();
}

class _OrderPageState extends State<OrderPage> with TickerProviderStateMixin {
  List<Order> orders = [];
  List<Order> filteredOrders = [];
  Map<String, User> users = {}; // Cache users by ID
  bool isLoading = true;
  String selectedStatus = 'all';
  String selectedUserId = 'all';
  String searchQuery = '';
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // 🔧 NEW: Advanced filtering options
  String sortBy = 'date_desc'; // date_desc, date_asc, amount_desc, amount_asc
  DateTimeRange? dateRange;
  String selectedPaymentMethod = 'all';
  double? minAmount;
  double? maxAmount;

  final List<Map<String, String>> statusList = [
    {'key': 'all', 'label': 'Tất cả'},
    {'key': 'pending', 'label': 'Chờ xác nhận'},
    {'key': 'confirmed', 'label': 'Đã xác nhận'},
    {'key': 'inShipping', 'label': 'Đang giao'},
    {'key': 'delivered', 'label': 'Hoàn thành'},
    {'key': 'rejected', 'label': 'Đã hủy'},
  ];

  final List<Map<String, String>> sortOptions = [
    {'key': 'date_desc', 'label': 'Ngày mới nhất'},
    {'key': 'date_asc', 'label': 'Ngày cũ nhất'},
    {'key': 'amount_desc', 'label': 'Giá trị cao nhất'},
    {'key': 'amount_asc', 'label': 'Giá trị thấp nhất'},
    {'key': 'user_name', 'label': 'Tên khách hàng A-Z'},
  ];

  final List<Map<String, String>> paymentMethods = [
    {'key': 'all', 'label': 'Tất cả phương thức'},
    {'key': 'cash', 'label': 'Thanh toán khi nhận'},
    {'key': 'momo', 'label': 'MoMo'},
    {'key': 'paypal', 'label': 'PayPal'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: statusList.length, vsync: this);
    fetchOrders();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> fetchOrders() async {
    setState(() => isLoading = true);
    try {
      // 🚀 Use new optimized endpoint with filtering and pagination
      final result = await AdminOrderService.getFilteredOrders(
        page: 1,
        limit: 50, // Load more at once for better UX
        status: selectedStatus,
        userId: selectedUserId,
        paymentMethod: selectedPaymentMethod,
        sortBy: sortBy,
        search: searchQuery,
        startDate: dateRange?.start.toIso8601String(),
        endDate: dateRange?.end.toIso8601String(),
        minAmount: minAmount,
        maxAmount: maxAmount,
      );
      
      if (result['success'] == true) {
        orders = result['orders'] as List<Order>;
        
        // 🚀 Load users with stats in parallel for better performance
        final usersData = await AdminOrderService.getUsersWithStats();
        users.clear();
        for (var userData in usersData) {
          users[userData['_id']] = User(
            id: userData['_id'],
            userName: userData['userName'],
            email: userData['email'],
          );
        }
        
        // Since filtering is done server-side, just update the UI
        if (mounted) {
          setState(() {
            filteredOrders = orders;
            isLoading = false;
          });
        }
      } else {
        throw Exception(result['error'] ?? 'Failed to load orders');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi tải đơn hàng: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        setState(() => isLoading = false);
      }
    }
  }

  // 🚀 OPTIMIZED: Apply filters with server-side filtering
  Future<void> _applyFilters() async {
    setState(() => isLoading = true);
    
    try {
      final result = await AdminOrderService.getFilteredOrders(
        page: 1,
        limit: 50,
        status: selectedStatus,
        userId: selectedUserId,
        paymentMethod: selectedPaymentMethod,
        sortBy: sortBy,
        search: searchQuery,
        startDate: dateRange?.start.toIso8601String(),
        endDate: dateRange?.end.toIso8601String(),
        minAmount: minAmount,
        maxAmount: maxAmount,
      );
      
      if (result['success'] == true && mounted) {
        setState(() {
          orders = result['orders'] as List<Order>;
          filteredOrders = orders; // No need for client-side filtering
          isLoading = false;
        });
      } else {
        throw Exception(result['error'] ?? 'Failed to apply filters');
      }
    } catch (e) {
      if (mounted) {
        setState(() => isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi khi lọc đơn hàng: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onStatusChanged(String status) {
    setState(() {
      selectedStatus = status;
    });
    _applyFilters();
  }

  void _onSearchChanged(String query) {
    setState(() {
      searchQuery = query;
    });
    _applyFilters();
  }

  void _onUserChanged(String userId) {
    setState(() {
      selectedUserId = userId;
    });
    _applyFilters();
  }

  // 🔧 NEW: Quick date filter methods
  Widget _buildQuickDateFilter(String label, String type, {bool isActive = false}) {
    return InkWell(
      onTap: () => _applyQuickDateFilter(type),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive || _isDateFilterActive(type) ? Colors.brown : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isActive || _isDateFilterActive(type) ? Colors.brown : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w500,
            color: isActive || _isDateFilterActive(type) ? Colors.white : Colors.black87,
          ),
        ),
      ),
    );
  }

  bool _isDateFilterActive(String type) {
    if (dateRange == null) return false;
    final now = DateTime.now();
    switch (type) {
      case 'today':
        return dateRange!.start.day == now.day && 
               dateRange!.start.month == now.month && 
               dateRange!.start.year == now.year;
      case 'week':
        final weekStart = now.subtract(Duration(days: now.weekday - 1));
        return dateRange!.start.day == weekStart.day && 
               dateRange!.start.month == weekStart.month;
      case 'month':
        return dateRange!.start.month == now.month && 
               dateRange!.start.year == now.year;
      default:
        return false;
    }
  }

  void _applyQuickDateFilter(String type) {
    final now = DateTime.now();
    setState(() {
      switch (type) {
        case 'today':
          dateRange = DateTimeRange(
            start: DateTime(now.year, now.month, now.day),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          );
          break;
        case 'week':
          final weekStart = now.subtract(Duration(days: now.weekday - 1));
          dateRange = DateTimeRange(
            start: DateTime(weekStart.year, weekStart.month, weekStart.day),
            end: DateTime(now.year, now.month, now.day, 23, 59, 59),
          );
          break;
        case 'month':
          dateRange = DateTimeRange(
            start: DateTime(now.year, now.month, 1),
            end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
          );
          break;
        case 'clear':
          dateRange = null;
          break;
      }
    });
    _applyFilters();
  }

  int _getActiveFilterCount() {
    int count = 0;
    if (selectedPaymentMethod != 'all') count++;
    if (dateRange != null) count++;
    if (minAmount != null || maxAmount != null) count++;
    if (selectedStatus != 'all') count++;
    if (selectedUserId != 'all') count++;
    if (searchQuery.isNotEmpty) count++;
    return count;
  }

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildAdvancedFiltersSheet(),
    );
  }

  void _showFilterSummary() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Bộ lọc đang áp dụng'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (selectedStatus != 'all') ...[
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.brown),
                  const SizedBox(width: 8),
                  Text('Trạng thái: ${statusList.firstWhere((s) => s['key'] == selectedStatus)['label']}'),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (selectedUserId != 'all') ...[
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Khách hàng: ${users[selectedUserId]?.userName ?? "N/A"}'),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
            if (searchQuery.isNotEmpty) ...[
              Row(
                children: [
                  const Icon(Icons.circle, size: 8, color: Colors.brown),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text('Tìm kiếm: "$searchQuery"'),
                  ),
                ],
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _resetFilters();
            },
            child: const Text('Xóa tất cả'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Đóng'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdvancedFiltersSheet() {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Bộ lọc nâng cao',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Payment Method Filter
                  const Text('Phương thức thanh toán:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: paymentMethods.map((method) => FilterChip(
                      selected: selectedPaymentMethod == method['key'],
                      label: Text(method['label']!),
                      onSelected: (selected) {
                        setState(() {
                          selectedPaymentMethod = selected ? method['key']! : 'all';
                        });
                        _applyFilters();
                      },
                    )).toList(),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Amount Range Filter
                  const Text('Khoảng giá trị đơn hàng:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Từ (₫)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              minAmount = double.tryParse(value);
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: TextField(
                          decoration: const InputDecoration(
                            labelText: 'Đến (₫)',
                            border: OutlineInputBorder(),
                          ),
                          keyboardType: TextInputType.number,
                          onChanged: (value) {
                            setState(() {
                              maxAmount = double.tryParse(value);
                            });
                            _applyFilters();
                          },
                        ),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Custom Date Range
                  const Text('Khoảng thời gian tùy chỉnh:', style: TextStyle(fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  InkWell(
                    onTap: () async {
                      final picked = await showDateRangePicker(
                        context: context,
                        firstDate: DateTime(2020),
                        lastDate: DateTime.now(),
                        initialDateRange: dateRange,
                      );
                      if (picked != null) {
                        setState(() {
                          dateRange = picked;
                        });
                        _applyFilters();
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            dateRange != null
                                ? '${dateRange!.start.day}/${dateRange!.start.month} - ${dateRange!.end.day}/${dateRange!.end.month}'
                                : 'Chọn khoảng thời gian',
                          ),
                          const Icon(Icons.date_range),
                        ],
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 32),
                  
                  // Reset Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        _resetFilters();
                        Navigator.pop(context);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[300],
                        foregroundColor: Colors.black87,
                      ),
                      child: const Text('Xóa tất cả bộ lọc'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetFilters() {
    setState(() {
      selectedStatus = 'all';
      selectedUserId = 'all';
      selectedPaymentMethod = 'all';
      dateRange = null;
      minAmount = null;
      maxAmount = null;
      searchQuery = '';
      sortBy = 'date_desc';
      _searchController.clear();
    });
    _applyFilters();
  }

  int _getStatusCount(String status) {
    if (status == 'all') return orders.length;
    return orders.where((order) => order.orderStatus == status).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Quản lý đơn hàng',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        actions: [
          // Filter indicator
          if (_getActiveFilterCount() > 0)
            Container(
              margin: const EdgeInsets.only(right: 8),
              child: Stack(
                children: [
                  IconButton(
                    icon: const Icon(Icons.filter_list),
                    tooltip: 'Đang lọc dữ liệu',
                    onPressed: _showFilterSummary,
                  ),
                  Positioned(
                    right: 6,
                    top: 6,
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      constraints: const BoxConstraints(
                        minWidth: 16,
                        minHeight: 16,
                      ),
                      child: Text(
                        _getActiveFilterCount().toString(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchOrders,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search Bar
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Tìm kiếm theo tên người dùng hoặc mã đơn hàng...',
                prefixIcon: const Icon(Icons.search, color: Colors.brown),
                suffixIcon: searchQuery.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _onSearchChanged('');
                        },
                      )
                    : null,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.brown.withValues(alpha: 0.3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Colors.brown),
                ),
                filled: true,
                fillColor: Colors.grey[50],
              ),
            ),
          ),
          
          // 🔧 NEW: Smart Filters Row với Time Filter ở góc
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                // Top Row: Sort & Advanced Filters
                Row(
                  children: [
                    // Sort Dropdown
                    Expanded(
                      flex: 2,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.brown.withValues(alpha: 0.3)),
                          borderRadius: BorderRadius.circular(8),
                          color: Colors.grey[50],
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: sortBy,
                            isExpanded: true,
                            icon: const Icon(Icons.sort, color: Colors.brown, size: 18),
                            style: const TextStyle(color: Colors.black87, fontSize: 13),
                            onChanged: (String? newValue) {
                              if (newValue != null) {
                                setState(() {
                                  sortBy = newValue;
                                });
                                _applyFilters();
                              }
                            },
                            items: sortOptions.map<DropdownMenuItem<String>>((option) {
                              return DropdownMenuItem<String>(
                                value: option['key'],
                                child: Text(option['label']!, style: const TextStyle(fontSize: 13)),
                              );
                            }).toList(),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Quick Date Filters (Time Filter ở góc)
                    Expanded(
                      flex: 3,
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _buildQuickDateFilter('Hôm nay', 'today'),
                            const SizedBox(width: 4),
                            _buildQuickDateFilter('Tuần', 'week'),
                            const SizedBox(width: 4),
                            _buildQuickDateFilter('Tháng', 'month'),
                            const SizedBox(width: 4),
                            if (dateRange != null)
                              _buildQuickDateFilter('Xóa', 'clear', isActive: true),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    
                    // Advanced Filter Button
                    Container(
                      decoration: BoxDecoration(
                        color: _getActiveFilterCount() > 0 ? Colors.brown : Colors.grey[100],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: IconButton(
                        icon: Icon(
                          Icons.tune,
                          color: _getActiveFilterCount() > 0 ? Colors.white : Colors.brown,
                          size: 20,
                        ),
                        onPressed: _showAdvancedFilters,
                        tooltip: 'Bộ lọc nâng cao',
                        padding: const EdgeInsets.all(8),
                        constraints: const BoxConstraints(minWidth: 36, minHeight: 36),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 12),
                
                // 🔧 NEW: Horizontal User List
                if (users.isNotEmpty)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.people_outline, size: 16, color: Colors.brown),
                              const SizedBox(width: 6),
                              const Text(
                                'Lọc theo khách hàng:',
                                style: TextStyle(fontWeight: FontWeight.w500, fontSize: 13),
                              ),
                            ],
                          ),
                          if (selectedUserId != 'all')
                            TextButton(
                              onPressed: () => _onUserChanged('all'),
                              child: const Text('Xóa bộ lọc', style: TextStyle(fontSize: 12)),
                              style: TextButton.styleFrom(
                                foregroundColor: Colors.red,
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                minimumSize: Size.zero,
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      
                      // Horizontal User Chips
                      SizedBox(
                        height: 40,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: users.length,
                          itemBuilder: (context, index) {
                            final user = users.values.elementAt(index);
                            final isSelected = selectedUserId == user.id;
                            final userOrderCount = orders.where((o) => o.userId == user.id).length;
                            
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: FilterChip(
                                selected: isSelected,
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    CircleAvatar(
                                      radius: 12,
                                      backgroundColor: isSelected ? Colors.white : Colors.brown.withValues(alpha: 0.1),
                                      backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                                          ? NetworkImage(user.avatar!)
                                          : null,
                                      child: user.avatar == null || user.avatar!.isEmpty
                                          ? Text(
                                              user.userName.isNotEmpty ? user.userName[0].toUpperCase() : '?',
                                              style: TextStyle(
                                                fontSize: 10,
                                                fontWeight: FontWeight.bold,
                                                color: isSelected ? Colors.brown : Colors.brown.withValues(alpha: 0.7),
                                              ),
                                            )
                                          : null,
                                    ),
                                    const SizedBox(width: 6),
                                    Column(
                                      mainAxisSize: MainAxisSize.min,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          user.userName.length > 8 
                                              ? '${user.userName.substring(0, 8)}...' 
                                              : user.userName,
                                          style: TextStyle(
                                            fontSize: 11,
                                            fontWeight: FontWeight.w500,
                                            color: isSelected ? Colors.white : Colors.black87,
                                          ),
                                        ),
                                        Text(
                                          '$userOrderCount đơn',
                                          style: TextStyle(
                                            fontSize: 9,
                                            color: isSelected ? Colors.white70 : Colors.grey[600],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                onSelected: (selected) {
                                  _onUserChanged(selected ? user.id : 'all');
                                },
                                backgroundColor: Colors.grey[50],
                                selectedColor: Colors.brown,
                                checkmarkColor: Colors.white,
                                side: BorderSide(
                                  color: isSelected ? Colors.brown : Colors.grey.withValues(alpha: 0.3),
                                  width: 1,
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          
          // Status Tabs
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              isScrollable: true,
              labelColor: Colors.brown,
              unselectedLabelColor: Colors.grey,
              indicatorColor: Colors.brown,
              indicatorWeight: 3,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold),
              onTap: (index) {
                final statusKey = statusList[index]['key']!;
                _onStatusChanged(statusKey);
              },
              tabs: statusList.map((status) {
                final count = _getStatusCount(status['key']!);
                return Tab(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(status['label']!),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: selectedStatus == status['key']
                              ? Colors.brown
                              : Colors.grey[300],
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          count.toString(),
                          style: TextStyle(
                            color: selectedStatus == status['key']
                                ? Colors.white
                                : Colors.grey[600],
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
          
          // Results Info
          if (searchQuery.isNotEmpty || selectedStatus != 'all' || selectedUserId != 'all')
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      children: [
                        Text(
                          'Tìm thấy ${filteredOrders.length} đơn hàng',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        if (selectedUserId != 'all') ...[
                          const SizedBox(width: 4),
                          Text(
                            'của ${users[selectedUserId]?.userName ?? "khách hàng"}',
                            style: TextStyle(
                              color: Colors.brown,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (searchQuery.isNotEmpty) ...[
                          const SizedBox(width: 4),
                          Text(
                            'cho "$searchQuery"',
                            style: TextStyle(
                              color: Colors.grey[800],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          
          const Divider(height: 1),
          
          // Orders List
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredOrders.isEmpty
                    ? _buildEmptyState()
                    : ListView.builder(
                        itemCount: filteredOrders.length,
                        itemBuilder: (context, index) {
                          final order = filteredOrders[index];
                          final user = users[order.userId];
                          return _buildOrderCard(order, user);
                        },
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    String message;
    IconData icon;
    
    if (searchQuery.isNotEmpty) {
      message = 'Không tìm thấy đơn hàng nào với từ khóa "$searchQuery"';
      icon = Icons.search_off;
    } else if (selectedUserId != 'all') {
      final userName = users[selectedUserId]?.userName ?? 'khách hàng này';
      message = 'Không có đơn hàng nào của $userName';
      icon = Icons.person_off;
    } else if (selectedStatus != 'all') {
      final statusLabel = statusList.firstWhere((s) => s['key'] == selectedStatus)['label'];
      message = 'Không có đơn hàng nào với trạng thái "$statusLabel"';
      icon = Icons.receipt_long_outlined;
    } else {
      message = 'Chưa có đơn hàng nào';
      icon = Icons.shopping_cart_outlined;
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử tìm kiếm với từ khóa khác hoặc xóa bộ lọc',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _resetFilters();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.brown,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Xóa tất cả bộ lọc'),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderCard(Order order, User? user) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => OrderDetailPage(orderId: order.id),
            ),
          );
        },
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Đơn hàng #${order.id.substring(0, 8)}...',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${order.orderDate.day}/${order.orderDate.month}/${order.orderDate.year} ${order.orderDate.hour}:${order.orderDate.minute.toString().padLeft(2, '0')}',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  _buildStatusChip(order.orderStatus),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Customer Info
              if (user != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 20,
                        backgroundColor: Colors.brown.withValues(alpha: 0.1),
                        child: Text(
                          user.userName.isNotEmpty 
                              ? user.userName[0].toUpperCase() 
                              : 'U',
                          style: const TextStyle(
                            color: Colors.brown,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              user.userName,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              user.email,
                              style: TextStyle(
                                color: Colors.grey[600],
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.person, color: Colors.brown),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const UserPage(),
                            ),
                          );
                        },
                        tooltip: 'Xem thông tin khách hàng',
                      ),
                    ],
                  ),
                ),
              
              const SizedBox(height: 12),
              
              // Order Details
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tổng tiền:',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        '${order.totalAmount.toStringAsFixed(0).replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}₫',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.brown,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        'Thanh toán:',
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        _getPaymentMethodText(order.paymentMethod),
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusChip(String status) {
    Color color;
    String label;

    switch (status) {
      case 'pending':
        color = Colors.orange;
        label = 'Chờ xác nhận';
        break;
      case 'confirmed':
        color = Colors.blue;
        label = 'Đã xác nhận';
        break;
      case 'inShipping':
        color = Colors.purple;
        label = 'Đang giao';
        break;
      case 'delivered':
        color = Colors.green;
        label = 'Hoàn thành';
        break;
      case 'rejected':
        color = Colors.red;
        label = 'Đã hủy';
        break;
      default:
        color = Colors.grey;
        label = 'Không xác định';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        border: Border.all(color: color.withValues(alpha: 0.3)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
    );
  }

  String _getPaymentMethodText(String method) {
    switch (method) {
      case 'cash':
        return 'Thanh toán khi nhận';
      case 'momo':
        return 'MoMo';
      case 'paypal':
        return 'PayPal';
      default:
        return method;
    }
  }
}

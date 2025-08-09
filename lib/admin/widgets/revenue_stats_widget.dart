import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/admin_dashboard_service.dart';
import '../../utils/currency_helper.dart';

class RevenueStatsWidget extends StatefulWidget {
  const RevenueStatsWidget({Key? key}) : super(key: key);

  @override
  State<RevenueStatsWidget> createState() => _RevenueStatsWidgetState();
}

class _RevenueStatsWidgetState extends State<RevenueStatsWidget> {
  Map<String, dynamic> dashboardStats = {};
  bool isLoading = true;
  String selectedTimeframe = 'Hôm nay';

  @override
  void initState() {
    super.initState();
    _loadDashboardStats();
  }

  Future<void> _loadDashboardStats() async {
    setState(() => isLoading = true);
    try {
      final stats = await AdminDashboardService.getDashboardStats();
      setState(() {
        dashboardStats = stats;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading dashboard stats: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Thống kê Doanh thu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                DropdownButton<String>(
                  value: selectedTimeframe,
                  items: const [
                    DropdownMenuItem(value: 'Hôm nay', child: Text('Hôm nay')),
                    DropdownMenuItem(value: 'Tuần này', child: Text('Tuần này')),
                    DropdownMenuItem(value: 'Tháng này', child: Text('Tháng này')),
                    DropdownMenuItem(value: 'Tổng cộng', child: Text('Tổng cộng')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedTimeframe = value!;
                    });
                  },
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (isLoading)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: CircularProgressIndicator(),
                ),
              )
            else
              Column(
                children: [
                  // Stats Cards
                  Row(
                    children: [
                      Expanded(
                        child: _buildStatCard(
                          'Doanh thu ${selectedTimeframe.toLowerCase()}',
                          _getRevenueByTimeframe(),
                          Icons.monetization_on,
                          Colors.green,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: _buildStatCard(
                          'Đơn hàng ${selectedTimeframe.toLowerCase()}',
                          '${_getOrdersByTimeframe()}',
                          Icons.shopping_cart,
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  // 7-Day Revenue Chart
                  if (dashboardStats['last7Days'] != null && dashboardStats['last7Days'].isNotEmpty)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Doanh thu 7 ngày gần đây',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          height: 200,
                          child: LineChart(
                            LineChartData(
                              gridData: const FlGridData(show: true),
                              titlesData: FlTitlesData(
                                leftTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    reservedSize: 50,
                                    getTitlesWidget: (value, meta) {
                                      return Text(
                                        '${(value / 1000).toStringAsFixed(0)}K',
                                        style: const TextStyle(fontSize: 10),
                                      );
                                    },
                                  ),
                                ),
                                bottomTitles: AxisTitles(
                                  sideTitles: SideTitles(
                                    showTitles: true,
                                    getTitlesWidget: (value, meta) {
                                      int index = value.toInt();
                                      if (index >= 0 && index < dashboardStats['last7Days'].length) {
                                        return Text(
                                          'Day ${dashboardStats['last7Days'][index]['_id']['day']}',
                                          style: const TextStyle(fontSize: 10),
                                        );
                                      }
                                      return const Text('');
                                    },
                                  ),
                                ),
                                rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                              ),
                              borderData: FlBorderData(show: true),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _generateSpots(),
                                  isCurved: true,
                                  color: Colors.blue,
                                  barWidth: 2,
                                  dotData: const FlDotData(show: true),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Colors.blue.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: color, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: color.withOpacity(0.8),
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  String _getRevenueByTimeframe() {
    if (dashboardStats['revenue'] == null) return '0 VND';
    
    switch (selectedTimeframe) {
      case 'Hôm nay':
        return CurrencyHelper.formatVND(dashboardStats['revenue']['today'] ?? 0);
      case 'Tuần này':
        return CurrencyHelper.formatVND(dashboardStats['revenue']['week'] ?? 0);
      case 'Tháng này':
        return CurrencyHelper.formatVND(dashboardStats['revenue']['month'] ?? 0);
      case 'Tổng cộng':
        return CurrencyHelper.formatVND(dashboardStats['revenue']['total'] ?? 0);
      default:
        return '0 VND';
    }
  }

  int _getOrdersByTimeframe() {
    if (dashboardStats['orders'] == null) return 0;
    
    switch (selectedTimeframe) {
      case 'Hôm nay':
        return dashboardStats['orders']['today'] ?? 0;
      case 'Tuần này':
        return dashboardStats['orders']['week'] ?? 0;
      case 'Tháng này':
        return dashboardStats['orders']['month'] ?? 0;
      case 'Tổng cộng':
        return dashboardStats['orders']['total'] ?? 0;
      default:
        return 0;
    }
  }

  List<FlSpot> _generateSpots() {
    if (dashboardStats['last7Days'] == null) return [];
    
    return dashboardStats['last7Days']
        .asMap()
        .entries
        .map<FlSpot>((entry) => FlSpot(
              entry.key.toDouble(),
              (entry.value['revenue'] ?? 0).toDouble(),
            ))
        .toList();
  }
}

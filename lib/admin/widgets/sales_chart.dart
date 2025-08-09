import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/admin_dashboard_service.dart';
import '../../utils/currency_helper.dart';

class SalesChart extends StatefulWidget {
  final String chartType; // 'monthly', 'weekly', 'daily', 'yearly'
  final int? selectedYear;

  const SalesChart({
    Key? key, 
    this.chartType = 'monthly',
    this.selectedYear,
  }) : super(key: key);

  @override
  State<SalesChart> createState() => _SalesChartState();
}

class _SalesChartState extends State<SalesChart> {
  List<Map<String, dynamic>> salesData = [];
  bool isLoading = true;
  String selectedPeriod = 'Tháng';

  @override
  void initState() {
    super.initState();
    _loadSalesData();
  }

  Future<void> _loadSalesData() async {
    setState(() => isLoading = true);
    try {
      final data = await AdminDashboardService.getSalesPerMonth(widget.selectedYear);
      setState(() {
        salesData = data;
        isLoading = false;
      });
    } catch (e) {
      print('Error loading sales data: $e');
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
                Expanded( // 🔧 Wrap với Expanded
                  child: Text(
                    'Biểu đồ Doanh thu theo $selectedPeriod',
                    style: const TextStyle(
                      fontSize: 16, // 🔧 Giảm font size
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 2, // 🔧 Cho phép xuống dòng
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8), // 🔧 Thêm spacing
                DropdownButton<String>(
                  value: selectedPeriod,
                  items: const [
                    DropdownMenuItem(value: 'Tháng', child: Text('Theo tháng')),
                    DropdownMenuItem(value: 'Tuần', child: Text('Theo tuần')),
                    DropdownMenuItem(value: 'Ngày', child: Text('Theo ngày')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      selectedPeriod = value!;
                    });
                    _loadSalesData();
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
            else if (salesData.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(50),
                  child: Text('Không có dữ liệu'),
                ),
              )
            else
              Container(
                height: 280, // 🔧 Giảm height
                width: double.infinity,
                padding: const EdgeInsets.only(right: 8), // 🔧 Thêm padding
                child: BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: _getMaxY(),
                    barTouchData: BarTouchData(
                      touchTooltipData: BarTouchTooltipData(
                        tooltipBgColor: Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          final data = salesData[group.x.toInt()];
                          return BarTooltipItem(
                            '${data['name']}\n'
                            'Doanh thu: ${CurrencyHelper.formatVND(data['sales'])}\n'
                            'Đơn hàng: ${data['orders']}',
                            const TextStyle(color: Colors.white),
                          );
                        },
                      ),
                    ),
                    titlesData: FlTitlesData(
                      leftTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 45, // 🔧 Giảm reserved size
                          interval: _getMaxY() / 4, // 🔧 Thêm interval để giảm số labels
                          getTitlesWidget: (value, meta) {
                            if (value == 0) return const Text('');
                            return Text(
                              '${(value / 1000000).toStringAsFixed(0)}M',
                              style: const TextStyle(
                                fontSize: 8, // 🔧 Giảm font size
                                color: Colors.grey,
                              ),
                            );
                          },
                        ),
                      ),
                      bottomTitles: AxisTitles(
                        sideTitles: SideTitles(
                          showTitles: true,
                          reservedSize: 35, // 🔧 Tăng reserved size cho bottom
                          getTitlesWidget: (value, meta) {
                            int index = value.toInt();
                            if (index >= 0 && index < salesData.length) {
                              String name = salesData[index]['name'];
                              // 🔧 Rút gọn tên tháng
                              if (name.startsWith('Tháng ')) {
                                name = 'T${name.substring(6)}';
                              }
                              return Padding(
                                padding: const EdgeInsets.only(top: 4),
                                child: Transform.rotate(
                                  angle: -0.5, // 🔧 Xoay text 30 độ
                                  child: Text(
                                    name,
                                    style: const TextStyle(
                                      fontSize: 8, // 🔧 Giảm font size
                                      color: Colors.grey,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              );
                            }
                            return const Text('');
                          },
                        ),
                      ),
                      rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                      topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false),
                      ),
                    ),
                    borderData: FlBorderData(show: false),
                    barGroups: _generateBarGroups(),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  double _getMaxY() {
    if (salesData.isEmpty) return 100;
    double maxValue = salesData
        .map<double>((data) => (data['sales'] ?? 0).toDouble())
        .reduce((a, b) => a > b ? a : b);
    return maxValue * 1.2; // Thêm 20% để chart không chạm đỉnh
  }

  List<BarChartGroupData> _generateBarGroups() {
    return salesData.asMap().entries.map((entry) {
      int index = entry.key;
      Map<String, dynamic> data = entry.value;
      
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: (data['sales'] ?? 0).toDouble(),
            color: _getBarColor(index),
            width: 16,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(4),
              topRight: Radius.circular(4),
            ),
          ),
        ],
      );
    }).toList();
  }

  Color _getBarColor(int index) {
    List<Color> colors = [
      Colors.blue,
      Colors.green,
      Colors.orange,
      Colors.purple,
      Colors.red,
      Colors.teal,
      Colors.pink,
      Colors.indigo,
      Colors.amber,
      Colors.cyan,
      Colors.lime,
      Colors.deepOrange,
    ];
    return colors[index % colors.length];
  }
} 
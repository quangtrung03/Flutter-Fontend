import 'package:flutter/material.dart';
import '../models/admin_voucher_model.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';
import '../../utils/currency_helper.dart';

class VoucherPage extends StatefulWidget {
  const VoucherPage({Key? key}) : super(key: key);

  @override
  State<VoucherPage> createState() => _VoucherPageState();
}

class _VoucherPageState extends State<VoucherPage> {
  
  List<Voucher> vouchers = [];
  bool isLoading = true;
  
  String statusFilter = 'Tất cả';
  String typeFilter = 'Tất cả';
  final List<String> statusOptions = ['Tất cả', 'Hoạt động', 'Hết hạn', 'Tạm dừng'];
  final List<String> typeOptions = ['Tất cả', 'Giảm %', 'Giảm cố định'];

  @override
  void initState() {
    super.initState();
    fetchVouchers();
  }

  Future<void> fetchVouchers() async {
    setState(() { isLoading = true; });
    try {
      final response = await http.get(Uri.parse('${AppConfig.adminVoucher}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> voucherList;
        if (data is List) {
          voucherList = data;
        } else if (data['data'] is List) {
          voucherList = data['data'];
        } else if (data['vouchers'] is List) {
          voucherList = data['vouchers'];
        } else {
          voucherList = [];
        }
        setState(() {
          vouchers = voucherList.map((e) => Voucher.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Failed to load vouchers, status: ${response.statusCode}');
      }
    } catch (e) {
      setState(() { isLoading = false; });
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  Future<void> deleteVoucher(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc chắn muốn xóa voucher này?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa', style: TextStyle(color: Colors.red))),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      final response = await http.delete(Uri.parse('${AppConfig.adminVoucher}/$id'));
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Đã xóa voucher thành công!')));
        fetchVouchers();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Xóa thất bại: ${response.body}')));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi: $e')));
    }
  }

  void _showVoucherForm([Voucher? voucher]) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => VoucherForm(voucher: voucher),
    );
    if (result == true) fetchVouchers();
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final filteredVouchers = vouchers.where((v) {
      // Lọc theo trạng thái
      bool matchStatus = true;
      if (statusFilter == 'Hoạt động') {
        matchStatus = v.isActive && (v.expiredAt == null || v.expiredAt!.isAfter(now));
      } else if (statusFilter == 'Hết hạn') {
        matchStatus = v.expiredAt != null && v.expiredAt!.isBefore(now);
      } else if (statusFilter == 'Tạm dừng') {
        matchStatus = !v.isActive;
      }
      // Lọc theo loại
      bool matchType = true;
      if (typeFilter == 'Giảm %') {
        matchType = v.type == 'percent';
      } else if (typeFilter == 'Giảm cố định') {
        matchType = v.type == 'fixed';
      }
      return matchStatus && matchType;
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Quản lý Voucher'),
      ),
      body: SafeArea(
        
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Card(
                      color: Colors.brown[50],
                      margin: const EdgeInsets.only(bottom: 16),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: const [
                            Icon(Icons.info, color: Colors.brown),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Nhập mã voucher, loại giảm giá, giá trị, điều kiện tối thiểu, hạn sử dụng và trạng thái hoạt động.',
                                style: TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    // Bộ lọc
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: statusFilter,
                            items: statusOptions.map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (v) => setState(() => statusFilter = v!),
                            decoration: const InputDecoration(labelText: 'Trạng thái'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: typeFilter,
                            items: typeOptions.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                            onChanged: (v) => setState(() => typeFilter = v!),
                            decoration: const InputDecoration(labelText: 'Loại giảm'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Text('Danh sách Voucher', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    const SizedBox(height: 8),
                    Expanded(
                      child: ListView(
                        children: [
                          ...filteredVouchers.map((voucher) => ModernVoucherCard(
                                voucher: voucher,
                                onEdit: () => _showVoucherForm(voucher),
                                onDelete: () => deleteVoucher(voucher.id),
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showVoucherForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}

class ModernVoucherCard extends StatelessWidget {
  final Voucher voucher;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const ModernVoucherCard({
    Key? key,
    required this.voucher,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isActive = voucher.isActive && (voucher.expiredAt == null || voucher.expiredAt!.isAfter(DateTime.now()));
    final gradient = isActive
        ? [Colors.green[200]!, Colors.green[50]!]
        : [Colors.grey[300]!, Colors.grey[100]!];

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: gradient,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    voucher.code,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: voucher.statusColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      voucher.statusText,
                      style: TextStyle(
                        color: voucher.statusColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  _infoChip(
                    voucher.displayValue,
                    color: Colors.orange[100],
                    textColor: Colors.orange[900],
                  ),
                  _infoChip('Min Order: ${CurrencyHelper.formatVND(voucher.minOrderAmount)}'),
                  _infoChip('Hạn: ${voucher.expiredAt != null ? _formatDate(voucher.expiredAt!) : ''}'),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    onPressed: onEdit,
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    onPressed: onDelete,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _infoChip(String text, {Color? color, Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color ?? Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        text,
        style: TextStyle(fontSize: 12, color: textColor ?? Colors.black87),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}

class VoucherForm extends StatefulWidget {
  final Voucher? voucher;
  const VoucherForm({Key? key, this.voucher}) : super(key: key);

  @override
  State<VoucherForm> createState() => _VoucherFormState();
}

class _VoucherFormState extends State<VoucherForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController codeController;
  late TextEditingController valueController;
  late TextEditingController maxDiscountController;
  late TextEditingController minOrderAmountController;
  late TextEditingController expiredAtController;
  String type = 'percent';
  bool isActive = true;

  @override
  void initState() {
    super.initState();
    codeController = TextEditingController(text: widget.voucher?.code ?? '');
    valueController = TextEditingController(text: widget.voucher?.value.toString() ?? '');
    maxDiscountController = TextEditingController(text: widget.voucher?.maxDiscount.toString() ?? '');
    minOrderAmountController = TextEditingController(text: widget.voucher?.minOrderAmount.toString() ?? '');
    expiredAtController = TextEditingController(text: widget.voucher?.expiredAt != null ? _formatDate(widget.voucher!.expiredAt!) : '');
    type = widget.voucher?.type ?? 'percent';
    isActive = widget.voucher?.isActive ?? true;
  }

  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  DateTime? _parseDate(String input) {
    try {
      final parts = input.split('/');
      if (parts.length == 3) {
        return DateTime(int.parse(parts[2]), int.parse(parts[1]), int.parse(parts[0]));
      }
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    DateTime? expiredAt;
    if (expiredAtController.text.isNotEmpty) {
      expiredAt = _parseDate(expiredAtController.text);
      if (expiredAt == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Ngày hết hạn không hợp lệ. Định dạng: dd/mm/yyyy')));
        return;
      }
    }
    final voucher = Voucher(
      id: widget.voucher?.id ?? '',
      code: codeController.text.trim(),
      type: type,
      value: int.tryParse(valueController.text) ?? 0,
      minOrderAmount: int.tryParse(minOrderAmountController.text) ?? 0,
      maxDiscount: int.tryParse(maxDiscountController.text) ?? 100000,
      expiredAt: expiredAt,
      isActive: isActive,
    );
    try {
      bool ok = false;
      if (widget.voucher == null) {
        // Thêm mới
        final res = await http.post(
          Uri.parse('${AppConfig.adminVoucher}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(voucher.toJson()),
        );
        ok = res.statusCode == 200 || res.statusCode == 201;
      } else {
        // Sửa
        final res = await http.put(
          Uri.parse('${AppConfig.adminVoucher}/${widget.voucher!.id}'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode(voucher.toJson()),
        );
        ok = res.statusCode == 200;
      }
      if (ok) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(widget.voucher == null ? 'Đã tạo voucher!' : 'Đã cập nhật voucher!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Thao tác thất bại!')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.voucher != null;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 24,
        bottom: MediaQuery.of(context).viewInsets.bottom + 16,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Column(
                  children: [
                    Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Text(
                      isEdit ? 'Cập nhật voucher' : 'Tạo mới voucher',
                      style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      isEdit
                          ? 'Chỉnh sửa thông tin voucher bên dưới.'
                          : 'Điền đầy đủ thông tin để tạo voucher mới.',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: codeController,
                decoration: const InputDecoration(
                  labelText: 'Mã voucher',
                  prefixIcon: Icon(Icons.card_giftcard),
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: type,
                items: const [
                  DropdownMenuItem(value: 'percent', child: Text('Giảm %')),
                  DropdownMenuItem(value: 'fixed', child: Text('Giảm cố định')),
                ],
                onChanged: (v) => setState(() => type = v ?? 'percent'),
                decoration: const InputDecoration(
                  labelText: 'Loại giảm',
                  prefixIcon: Icon(Icons.percent),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: valueController,
                      decoration: InputDecoration(
                        labelText: type == 'percent' ? 'Giá trị (%)' : 'Giá trị (VNĐ)',
                        prefixIcon: const Icon(Icons.percent),
                        border: const OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                      validator: (v) => v == null || v.trim().isEmpty ? 'Không được để trống' : null,
                    ),
                  ),
                  if (type == 'percent') ...[
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: maxDiscountController,
                        decoration: const InputDecoration(
                          labelText: 'Giảm tối đa (VNĐ)',
                          prefixIcon: Icon(Icons.money),
                          border: OutlineInputBorder(),
                        ),
                        keyboardType: TextInputType.number,
                      ),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: minOrderAmountController,
                      decoration: const InputDecoration(
                        labelText: 'Tối thiểu đơn hàng (VNĐ)',
                        prefixIcon: Icon(Icons.shopping_cart),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: expiredAtController,
                      decoration: const InputDecoration(
                        labelText: 'Hạn sử dụng (dd/mm/yyyy)',
                        prefixIcon: Icon(Icons.calendar_today),
                        border: OutlineInputBorder(),
                      ),
                      keyboardType: TextInputType.datetime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Checkbox(
                    value: isActive,
                    onChanged: (v) => setState(() => isActive = v ?? true),
                  ),
                  const Text('Đang hoạt động'),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    backgroundColor: Colors.brown,
                  ),
                  onPressed: _submit,
                  label: Text(isEdit ? 'Cập nhật' : 'Tạo mới',
                      style: const TextStyle(fontSize: 16, color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
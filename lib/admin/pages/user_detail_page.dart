import 'package:flutter/material.dart';
import '../models/admin_user_model.dart';
import '../../config/app_config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UserDetailPage extends StatefulWidget {
  final String userId;

  const UserDetailPage({Key? key, required this.userId}) : super(key: key);

  @override
  State<UserDetailPage> createState() => _UserDetailPageState();
}

class _UserDetailPageState extends State<UserDetailPage> {
  User? user;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _fetchUserDetails();
  }

  Future<void> _fetchUserDetails() async {
    try {
      setState(() {
        isLoading = true;
        error = null;
      });

      print('📡 Fetching user details for ID: ${widget.userId}');
      
      final response = await http.get(
        Uri.parse('${AppConfig.adminUsers}/get-user/${widget.userId}')
      );

      print('🔍 API Response Status: ${response.statusCode}');
      print('🔍 API Response Body: ${response.body}');
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        if (data['success'] == true && data['user'] != null) {
          setState(() {
            user = User.fromJson(data['user']);
            isLoading = false;
          });
          print('✅ User details loaded successfully: ${user?.userName}');
        } else {
          setState(() {
            error = data['message'] ?? 'Không thể tải thông tin người dùng';
            isLoading = false;
          });
          print('❌ Failed to load user details: ${data['message']}');
        }
      } else {
        setState(() {
          error = 'Lỗi server: ${response.statusCode}';
          isLoading = false;
        });
        print('❌ Server error: ${response.statusCode}');
      }
    } catch (e) {
      setState(() {
        error = 'Lỗi kết nối: $e';
        isLoading = false;
      });
      print('❌ Error fetching user details: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: const Text('Chi tiết người dùng'),
        backgroundColor: const Color(0xFFD7B7A3),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchUserDetails,
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Đang tải thông tin người dùng...'),
          ],
        ),
      );
    }

    if (error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              error!,
              style: const TextStyle(fontSize: 16, color: Colors.red),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchUserDetails,
              child: const Text('Thử lại'),
            ),
          ],
        ),
      );
    }

    if (user == null) {
      return const Center(
        child: Text(
          'Không tìm thấy thông tin người dùng',
          style: TextStyle(fontSize: 16),
        ),
      );
    }

    final isAdmin = user!.role == 'admin';
    
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFFD7B7A3),
            backgroundImage: (user!.avatar != null && user!.avatar!.isNotEmpty)
                ? NetworkImage(user!.avatar!)
                : null,
            child: (user!.avatar == null || user!.avatar!.isEmpty)
                ? Text(
                    user!.userName.isNotEmpty ? user!.userName[0].toUpperCase() : '?',
                    style: const TextStyle(fontSize: 40, color: Colors.white),
                  )
                : null,
          ),
          const SizedBox(height: 20),
          Text(
            user!.userName,
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(user!.email, style: const TextStyle(fontSize: 16, color: Colors.grey)),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isAdmin ? Colors.red[100] : Colors.green[100],
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isAdmin ? 'Quản trị viên' : 'Người dùng',
              style: TextStyle(
                color: isAdmin ? Colors.red[800] : Colors.green[800],
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Divider(thickness: 1),
          const SizedBox(height: 10),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              'Địa chỉ:',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.brown[700]),
            ),
          ),
          const SizedBox(height: 6),
          if (user!.addresses != null && user!.addresses!.isNotEmpty)
            ...user!.addresses!.map((address) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      const Icon(Icons.location_on, size: 18, color: Colors.brown),
                      const SizedBox(width: 6),
                      Expanded(child: Text(address)),
                    ],
                  ),
                ))
          else
            const Text('Không có địa chỉ nào.'),
        ],
      ),
    );
  }
}

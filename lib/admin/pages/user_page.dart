import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../config/app_config.dart';
import '../models/admin_user_model.dart';
import '../../theme/colors.dart';
import 'user_detail_page.dart';

class UserPage extends StatefulWidget {
  const UserPage({Key? key}) : super(key: key);

  @override
  State<UserPage> createState() => _UserPageState();
}

class _UserPageState extends State<UserPage> {
  List<User> users = [];
  bool isLoading = true;
  String searchText = '';
  String selectedRole = 'Tất cả';
  final List<String> roles = ['Tất cả', 'admin', 'user'];

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    try {
      setState(() => isLoading = true);
      final response = await http.get(Uri.parse('${AppConfig.adminUsers}'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<dynamic> userList;
        if (data is List) {
          userList = data;
        } else if (data is Map && data['data'] is List) {
          userList = data['data'];
        } else if (data is Map && data['users'] is List) {
          userList = data['users'];
        } else {
          userList = [];
        }

        setState(() {
          users = userList.map((e) => User.fromJson(e)).toList();
          isLoading = false;
        });
      } else {
        throw Exception('Status code: ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải người dùng: $e')));
    }
  }

  Future<void> deleteUser(String id) async {
    try {
      final userToDelete = users.firstWhere((u) => u.id == id);
      final adminCount = users.where((u) => u.role == 'admin').length;

      if (userToDelete.role == 'admin' && adminCount <= 1) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('⚠️ Không thể xóa admin cuối cùng!')),
        );
        return;
      }

      final confirm = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Xác nhận xóa'),
          content: Text('Bạn có chắc muốn xóa người dùng "${userToDelete.userName}" không?'),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
            TextButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Xóa', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirm != true) return;

      final res = await http.delete(Uri.parse('${AppConfig.adminUsers}/$id'));

      if (res.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Đã xóa người dùng thành công!')),
        );
        fetchUsers();
      } else {
        final body = jsonDecode(res.body);
        final errorMessage = body['message'] ?? '❌ Xóa thất bại. Vui lòng thử lại.';
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(errorMessage)),
        );
      }
    } catch (e) {
      debugPrint('Lỗi khi xoá user: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Lỗi xảy ra: $e')),
      );
    }
  }

  Future<void> editUser(User user) async {
    final nameController = TextEditingController(text: user.userName);
    final emailController = TextEditingController(text: user.email);
    String role = user.role;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Chỉnh sửa người dùng'),
          content: SingleChildScrollView(
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(labelText: 'Tên người dùng'),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<String>(
                  value: role,
                  items: ['user', 'admin'].map((r) {
                    return DropdownMenuItem(value: r, child: Text(r));
                  }).toList(),
                  onChanged: (value) => role = value!,
                  decoration: const InputDecoration(labelText: 'Vai trò'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Hủy')),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C6B53),
              ),
              onPressed: () async {
                final body = {
                  'userName': nameController.text.trim(),
                  'email': emailController.text.trim(),
                  'role': role,
                };
                try {
                  final res = await http.put(
                    Uri.parse('${AppConfig.adminUsers}/${user.id}'),
                    headers: {'Content-Type': 'application/json'},
                    body: jsonEncode(body),
                  );

                  if (res.statusCode == 200) {
                    Navigator.pop(context, true);
                  } else {
                    final err = jsonDecode(res.body);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(err['message'] ?? '❌ Cập nhật thất bại')),
                    );
                  }
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('❌ Lỗi khi cập nhật: $e')),
                  );
                }
              },
              child: const Text('Lưu'),
            ),
          ],
        );
      },
    );

    if (result == true) {
      try {
        final res = await http.get(Uri.parse('${AppConfig.adminUsers}/${user.id}'));
        if (res.statusCode == 200) {
          final data = jsonDecode(res.body);
          final updatedUser = User.fromJson(
            data is Map && data['data'] != null ? data['data'] : data,
          );

          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => UserDetailPage(userId: updatedUser.id),
              ),
            );
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('✅ Đã cập nhật người dùng!')),
          );
          fetchUsers();
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('❌ Lỗi khi tải user mới: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredUsers = users.where((u) {
      final matchRole = selectedRole == 'Tất cả' || u.role == selectedRole;
      final matchSearch = u.userName.toLowerCase().contains(searchText.toLowerCase()) ||
          u.email.toLowerCase().contains(searchText.toLowerCase());
      return matchRole && matchSearch;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFFF8F3),
      appBar: AppBar(
        title: const Text('Quản lý người dùng'),
        backgroundColor: const Color(0xFF9C6B53),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: InputDecoration(
                prefixIcon: const Icon(Icons.search),
                hintText: 'Tìm theo tên hoặc email',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => searchText = value),
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: roles.map((role) {
                final selected = role == selectedRole;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ChoiceChip(
                    label: Text(role),
                    selected: selected,
                    selectedColor: const Color(0xFF9C6B53),
                    backgroundColor: const Color(0xFFF2E4DA),
                    onSelected: (_) => setState(() => selectedRole = role),
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.brown[800],
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredUsers.isEmpty
                    ? const Center(child: Text('Không có người dùng nào'))
                    : ListView.builder(
                        itemCount: filteredUsers.length,
                        itemBuilder: (context, index) {
                          final user = filteredUsers[index];
                          return Card(
                            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            color: Colors.white,
                            elevation: 2,
                            child: ListTile(
                              onTap: () {
                                // 🔧 FIX: Kiểm tra userId hợp lệ trước khi navigate
                                if (user.id.isEmpty) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Lỗi: ID người dùng không hợp lệ'),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                                
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => UserDetailPage(userId: user.id),
                                  ),
                                );
                              },
                              contentPadding: const EdgeInsets.all(12),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF9C6B53),
                                backgroundImage: user.avatar != null && user.avatar!.isNotEmpty
                                    ? NetworkImage(user.avatar!)
                                    : null,
                                child: user.avatar == null || user.avatar!.isEmpty
                                    ? Text(user.userName[0].toUpperCase(), style: const TextStyle(color: Colors.white))
                                    : null,
                              ),
                              title: Text(user.userName),
                              subtitle: Text('${user.email} - ${user.role}'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => editUser(user),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => deleteUser(user.id),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

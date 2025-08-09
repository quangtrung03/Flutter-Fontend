import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../Layout/masterlayout.dart';
import '../../providers/support_request_provider.dart';
import '../../providers/support_chat_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/support_request_model.dart';
import '../../theme/colors.dart';

class ContactScreen extends StatefulWidget {
  const ContactScreen({Key? key}) : super(key: key);

  @override
  State<ContactScreen> createState() => _ContactScreenState();
}

class _ContactScreenState extends State<ContactScreen> with TickerProviderStateMixin {
  late TabController _tabController;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _messageController = TextEditingController();
  final _chatMessageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    
    // Load chat thread và auto-fill user info nếu đã login
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<AuthProvider>().user;
      if (user != null) {
        context.read<SupportChatProvider>().loadThread(user.email);
        // Auto-fill user info trong contact form
        _nameController.text = user.userName;
        _emailController.text = user.email;
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _messageController.dispose();
    _chatMessageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MasterLayout(
      currentIndex: 3, // Contact tab
      child: Column(
        children: [
          // Tab Bar
          Container(
            color: Colors.white,
            child: TabBar(
              controller: _tabController,
              labelColor: AppColors.primary,
              unselectedLabelColor: Colors.grey,
              indicatorColor: AppColors.primary,
              tabs: const [
                Tab(text: 'Thông tin', icon: Icon(Icons.info_outline)),
                Tab(text: 'Liên hệ', icon: Icon(Icons.contact_support)),
                Tab(text: 'Chat', icon: Icon(Icons.chat_bubble_outline)),
              ],
            ),
          ),
          // Tab Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildInfoTab(),
                _buildContactTab(),
                _buildChatTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thông tin liên hệ',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildContactItem(
                    icon: Icons.location_on,
                    title: 'Địa chỉ',
                    content: '123 Đường ABC, Quận 1, TP.HCM',
                  ),
                  const Divider(),
                  _buildContactItem(
                    icon: Icons.phone,
                    title: 'Điện thoại',
                    content: '0123 456 789',
                  ),
                  const Divider(),
                  _buildContactItem(
                    icon: Icons.email,
                    title: 'Email',
                    content: 'info@coffeeshop.com',
                  ),
                  const Divider(),
                  _buildContactItem(
                    icon: Icons.access_time,
                    title: 'Giờ làm việc',
                    content: '7:00 - 22:00 (Thứ 2 - Chủ nhật)',
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Quick action buttons
          Row(
            children: [
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _tabController.animateTo(1),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.contact_support, size: 32, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Gửi yêu cầu', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Card(
                  child: InkWell(
                    onTap: () => _tabController.animateTo(2),
                    borderRadius: BorderRadius.circular(8),
                    child: const Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(Icons.chat, size: 32, color: AppColors.primary),
                          SizedBox(height: 8),
                          Text('Chat trực tiếp', textAlign: TextAlign.center),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Về chúng tôi',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Coffee Shop',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Chúng tôi là một cửa hàng cà phê chất lượng cao, chuyên phục vụ những tách cà phê ngon nhất với nguyên liệu tươi mới và công thức độc đáo.',
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Dịch vụ của chúng tôi:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildServiceItem('• Cà phê chất lượng cao'),
                  _buildServiceItem('• Giao hàng tận nơi'),
                  _buildServiceItem('• Phục vụ 24/7'),
                  _buildServiceItem('• Khuyến mãi thường xuyên'),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContactTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Consumer<SupportRequestProvider>(
        builder: (context, provider, _) {
          return Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Gửi yêu cầu hỗ trợ',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Họ và tên',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.person),
                  ),
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Nhập họ và tên' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.email),
                  ),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Nhập email';
                    if (!value.contains('@')) return 'Email không hợp lệ';
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _messageController,
                  decoration: const InputDecoration(
                    labelText: 'Nội dung yêu cầu hỗ trợ',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.message),
                    hintText: 'Mô tả chi tiết vấn đề bạn gặp phải...',
                  ),
                  maxLines: 5,
                  validator: (value) =>
                      value == null || value.isEmpty ? 'Nhập nội dung' : null,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: provider.isLoading ? null : () async {
                      if (_formKey.currentState!.validate()) {
                        final request = SupportRequest(
                          userEmail: _emailController.text,
                          userName: _nameController.text,
                          message: _messageController.text,
                        );
                        
                        final success = await provider.sendRequest(request);
                        
                        if (mounted) {
                          if (success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Gửi yêu cầu thành công! Chúng tôi sẽ phản hồi sớm nhất.'),
                                backgroundColor: Colors.green,
                              ),
                            );
                            _nameController.clear();
                            _emailController.clear();
                            _messageController.clear();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(provider.error ?? 'Gửi yêu cầu thất bại!'),
                                backgroundColor: Colors.red,
                              ),
                            );
                          }
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    child: provider.isLoading
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Text('Gửi yêu cầu hỗ trợ', style: TextStyle(fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Chúng tôi sẽ phản hồi yêu cầu của bạn trong vòng 24 giờ qua email hoặc chat.',
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildChatTab() {
    final user = Provider.of<AuthProvider>(context).user;
    
    if (user == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.login, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Bạn cần đăng nhập để sử dụng tính năng chat',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return Consumer<SupportChatProvider>(
      builder: (context, chatProvider, _) {
        return Column(
          children: [
            Expanded(
              child: chatProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : chatProvider.thread == null || chatProvider.thread!.messages.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.chat_bubble_outline, size: 64, color: Colors.grey),
                              SizedBox(height: 16),
                              Text(
                                'Chưa có tin nhắn nào.\nHãy bắt đầu cuộc trò chuyện!',
                                textAlign: TextAlign.center,
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          reverse: true,
                          padding: const EdgeInsets.all(16),
                          itemCount: chatProvider.thread!.messages.length,
                          itemBuilder: (context, index) {
                            final messages = chatProvider.thread!.messages.reversed.toList();
                            final message = messages[index];
                            final isUser = message.sender == 'user';
                            
                            return Align(
                              alignment: isUser ? Alignment.centerRight : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isUser ? AppColors.primary : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                constraints: BoxConstraints(
                                  maxWidth: MediaQuery.of(context).size.width * 0.7,
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      message.content,
                                      style: TextStyle(
                                        color: isUser ? Colors.white : Colors.black87,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      message.createdAt != null 
                                          ? _formatTime(message.createdAt!)
                                          : '',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: isUser ? Colors.white70 : Colors.grey,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
            ),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 5,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _chatMessageController,
                      decoration: const InputDecoration(
                        hintText: 'Nhập tin nhắn...',
                        border: OutlineInputBorder(),
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onFieldSubmitted: (_) => _sendMessage(chatProvider, user),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: chatProvider.isLoading
                          ? null
                          : () => _sendMessage(chatProvider, user),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  void _sendMessage(SupportChatProvider chatProvider, user) async {
    if (_chatMessageController.text.trim().isNotEmpty) {
      await chatProvider.sendUserMessage(
        user.email,
        user.userName,
        _chatMessageController.text.trim(),
      );
      _chatMessageController.clear();
    }
  }

  String _formatTime(DateTime dateTime) {
    return '${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(content),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildServiceItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(text),
    );
  }
} 